/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 13/12/2016
Configuracion: dsPIC P33FJ12GP201, XT=8MHz, PLL=80MHz
Descripcion:
1.Genera los pulsos de exitacion para el transductor ultrasonico.

---------------------------------------------------------------------------------------------------------------------------*/

// Variables //

// Declaracion de variables para el calculo de la distancia //
unsigned int contp;                              //Contador para controlar los pulsos de exitacion del transductor ultrasonico.

float TOF, Df;
float DSTemp, VSnd;

unsigned short BS;                               //Variable auxiliar para establecer el cambio de estado en el bit RD0.

char txt1[8], txt2[8];

// Conexiones //

// Conexiones del modulo LCD //
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

// Conexiones del modulo DAC  //
sbit Chip_Select at LATB1_bit;
sbit Chip_Select_Direction at TRISB1_bit;

// Funciones //

// Funcion para el calculo de la Velocidad del sonido en funcion de la temperatura
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

//Funcion para control del DAC
void DAC_Output(unsigned int valueDAC) {
     char temp;

     Chip_Select = 0;                            //Seleccionar chip DAC

     // Send High Byte
     temp = (valueDAC >> 8) & 0x0F;              //Store valueDAC[11..8] to temp[3..0]
     temp |= 0x30;                               //Define DAC setting, see MCP4921 datasheet
     SPI1_Write(temp);                           //Send high byte via SPI

     // Send Low Byte
     temp = valueDAC;                            //Store valueDAC[7..0] to temp[7..0]
     SPI1_Write(temp);                           //Send low byte via SPI

     Chip_Select = 1;                            //Deseleccionar chip DAC
}


// Interrupciones //

//Interrupcion por desbordamiento del TMR1
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

//Interrupcion por conversion completada del ADC
void ADC1Int() org IVT_ADDR_ADC1INTERRUPT {
   DAC_Output(ADC1BUF0);                         //Invoca a la funcion de control del DAC
   AD1IF_bit = 0;                                //Limpia la bandera de interrupcion del ADC
}


// Configuraciones //
void Configuracion(){

     //Configuracion del PLL para generar un FOSC de 80MHz  a partir de un oscilador externo de 8MHz
     CLKDIVbits.PLLPRE = 0;                      //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
     PLLFBD = 41;                                //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
     CLKDIVbits.PLLPOST = 0;                     //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
     
     //Configuracion de puertos
     TRISB0_bit = 0;                             //Establece el pin B0 como salida
     TRISA0_bit = 1;
     LATB0_bit = 0;                              //Limpia el pin A3

     //Configuracion del TMR1
     T1CON = 0x8000;                             //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
     T1IE_bit = 1;                               //Habilita la interrupcion por desborde de TMR1
     T1IF_bit = 0;                               //Limpia la bandera de interrupcion
     IPC0bits.T1IP = 0x01;                       //Establece el nivel de prioridad de la interrupcion
     PR1 = 495;                                  //Precarga del TMR1
     
     //Configuracion del ADC
     AD1CON1.AD12B = 0;                          //Configura el ADC en modo de 10 bits
     AD1CON1bits.SSRC = 0x07;                    //Internal counter ends sampling and starts conversion (auto-convert)
     AD1CON1bits.FORM = 0x01;                    //Selecciona el formato en que se presentaran los resultados de conversion, 01->Entero con signo(-512_511)
     AD1CON1.ASAM = 0;                           //El muestreo comienza cuando se ajusta el bit SAMP (Para muestreo manual)
     AD1CON1.SIMSAM = 0;                         //0 -> Muestrea múltiples canales individualmente en secuencia
     AD1CON1.ADSIDL = 0;                         //Continua con la operacion del modulo durante el modo desocupado

     AD1CON2bits.VCFG = 0;                       //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
     AD1CON2bits.CHPS = 0x00;                    //Selecciona unicamente el canal CH0
     AD1CON2.CSCNA = 0;                          //No escanea las entradas de CH0 durante la Muestra A
     AD1CON2bits.SMPI = 0;                       //Sample/Convert Sequences Per Interrupt Selection bits
     AD1CON2.BUFM = 0;                           //Bit de selección del modo de relleno del búfer, 0 -> Siempre comienza a llenar el buffer desde el principio
     AD1CON2.ALTS = 0x00;                        //Utiliza siempre la selección de entrada de canal para la muestra A

     AD1CON3.ADRC = 0;                           //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
     AD1CON3bits.ADCS = 0x02;                    //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
     AD1CON3bits.SAMC = 0;                       //Auto Sample Time bits, 0 -> 0 TAD

     AD1CHS0 = 0;                                //ADC1 INPUT CHANNEL 0 SELECT REGISTER
     AD1CHS123 = 0;                              //AD1CHS123: ADC1 INPUT CHANNEL 1, 2, 3 SELECT REGISTER

     AD1PCFGL = 0xFFFE;                          //Configura el puerto AN0 como entrada analogica y todas las demas como digitales
     AD1CSSL = 0x00;                             //Se salta todos los puertos ANx para los escaneos de entrada

     IEC0.AD1IE = 0x00;                          //Activa la interrupcion por conversion completa del ADC
     IPC3bits.AD1IP = 1;                         //Nivel de prioridad de interrupcion del ADC = 1
     
     AD1CON1.ADON = 1;                           //Enciende el modulo ADC
     
     //Inicializacion del DAC
     SPI1_Init();                                //Inicializa el modulo DAC
     
     //Inicializacion de variables
     BS = 0;
     contp = 0;
     
     /*//Inicializacion del LCD
     Lcd_init();                                 //Inicializa el modulo LCD
     Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
     Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD*/
     


}


void main(){

 Configuracion();
 //value = 2048;                          // When program starts, DAC gives
 
 while (1){
 
       Velocidad();
       
       T1CON.TON = 1;
       contp = 0;
       BS = 0;
       
       DAC_Output(ADC1BUF0);
       
       Delay_ms(15);

 }

}