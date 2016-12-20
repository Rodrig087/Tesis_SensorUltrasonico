/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 13/12/2016
Configuracion: dsPIC P33FJ12GP201, XT=8MHz, PLL=80MHz
Descripcion:
1.Genera los pulsos de exitacion para el transductor ultrasonico.

---------------------------------------------------------------------------------------------------------------------------*/

// Declaracion de variables para el calculo de la distancia //
unsigned int contp;                              //Contador para controlar los pulsos de exitacion del transductor ultrasonico.

float TOF, Df;
float DSTemp, VSnd;

unsigned short BS;                               //Variable auxiliar para establecer el cambio de estado en el bit RD0.

char txt1[8], txt2[8];

// Conexiones del modulo LCD //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sbit LCD_RS at LATA4_bit;
sbit LCD_EN at LATB7_bit;
sbit LCD_D4 at LATB8_bit;
sbit LCD_D5 at LATB9_bit;
sbit LCD_D6 at LATB14_bit;
sbit LCD_D7 at LATB15_bit;
sbit LCD_RS_Direction at TRISA4_bit;
sbit LCD_EN_Direction at TRISB7_bit;
sbit LCD_D4_Direction at TRISB8_bit;
sbit LCD_D5_Direction at TRISB9_bit;
sbit LCD_D6_Direction at TRISB14_bit;
sbit LCD_D7_Direction at TRISB15_bit;

// Interrupciones //
void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
     if (contp<20){                              //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (42)
          BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
          RB0_bit = BS;
     }else {
          RB0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
          T1CON.TON = 0;
     }

     contp++;                                    //Aumenta el contador en una unidad.
     T1IF_bit = 0;                               //Limpia la bandera de interrupcion de Timer2
}


// Funcion para el calculo de la Velocidad del sonido en funcion de la temperatura //
void Velocidad(){
     unsigned int Temp;
     unsigned int Rint;
     float Rfrac;

     Ow_Reset(&PORTB, 4);                        //Onewire reset signal
     Ow_Write(&PORTB, 4, 0xCC);                  //Issue command SKIP_ROM
     Ow_Write(&PORTB, 4, 0x44);                  //Issue command CONVERT_T
     Delay_us(100);

     Ow_Reset(&PORTB, 4);
     Ow_Write(&PORTB, 4, 0xCC);                  //Issue command SKIP_ROM
     Ow_Write(&PORTB, 4, 0xBE);                  //Issue command READ_SCRATCHPAD
     Delay_us(100);

     Temp =  Ow_Read(&PORTB, 4);
     Temp = (Ow_Read(&PORTB, 4) << 8) + Temp;

     if (Temp & 0x8000) {
        Temp = 0;                                //Si la temperatura es negativa la establece como cero.
     }

     Rint = Temp >> 4;                           //Extrae la parte entera de la respuesta del sensor
     Rfrac = ((Temp & 0x000F) * 625) / 10000.;   //Extrae la parte decimal de la respuesta del sensor
     DSTemp = Rint + Rfrac;

     VSnd = 331.45 * sqrt(1+(DsTemp/273));       //Expresa la temperatura en punto flotante
}


// Configuraciones //
void Configuracion(){

     //Configuracion del PLL para generar un FOSC de 80MHz  a partir de un oscilador externo de 8MHz
     CLKDIVbits.PLLPRE = 0;                      //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
     PLLFBD = 41;                                //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
     CLKDIVbits.PLLPOST = 0;                     //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz

     //Configuracion del TMR1
     T1CON = 0x8000;                             //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
     T1IE_bit = 1;                               //Habilita la interrupcion por desborde de TMR1
     T1IF_bit = 0;                               //Limpia la bandera de interrupcion
     IPC0bits.T1IP = 0x01;                       //Establece el nivel de prioridad de la interrupcion
     PR1 = 495;                                  //Precarga del TMR1
     
     //Configuracion del ADC
     AD1CON1.AD12B = 0;                          //Configura el ADC en modo de 10 bits
     AD1PCFGL = 0xFFFC;                          //Configura los puertos AN0 y AN1 como entradas analogicas y todas las demas como digitales
     AD1CON2bits.VCFG = 0;                       //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
     AD1CON3.ADRC = 0;                           //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
     AD1CON3bits.ADCS = 0x02;                    //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
     AD1CON2bits.CHPS = 0x00;                    //Selecciona unicamente el canal CH0
     AD1CON1bits.SSRC = 0x00;                    //Selecciona la fuente de disparo de conversion !!
     AD1CON1bits.FORM = 0x01;                    //Selecciona el formato en que se presentaran los resultados de conversion, 01->Entero con signo(-512_511)
     AD1CON1.ADON = 1;                           //Enciende el modulo ADC
     
     
     //Configuracion de puertos
     TRISB0_bit = 0;                             //Establece el pin A3 como salida
     LATB0_bit = 0;                              //Limpia el pin A3
     
     //Inicializacion de variables
     BS = 0;
     contp = 0;
     
     //Inicializacion del LCD
     Lcd_init();                                 //Inicializa el LCD
     Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
     Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD

}


void main(){

 Configuracion();
 
 while (1){
 
       Velocidad();
       
       T1CON.TON = 1;
       contp = 0;
       BS = 0;
       
       FloatToStr(DSTemp, txt1);
       FloatToStr(VSnd, txt2);

       Lcd_Out(1,1,"Tmp: ");
       Lcd_Out_Cp(txt1);
       Lcd_Out(2,1,"Vel: ");
       Lcd_Out_Cp(txt2);

       
       Delay_ms(15);

 }

}