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
sbit LCD_RS at LATB4_bit;
sbit LCD_EN at LATB7_bit;
sbit LCD_D4 at LATB8_bit;
sbit LCD_D5 at LATB9_bit;
sbit LCD_D6 at LATB14_bit;
sbit LCD_D7 at LATB15_bit;
sbit LCD_RS_Direction at TRISB4_bit;
sbit LCD_EN_Direction at TRISB7_bit;
sbit LCD_D4_Direction at TRISB8_bit;
sbit LCD_D5_Direction at TRISB9_bit;
sbit LCD_D6_Direction at TRISB14_bit;
sbit LCD_D7_Direction at TRISB15_bit;

// Interrupciones //
void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
     if (contp<20){                             //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (42)
          BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
          RB0_bit = BS;
     }else {
          RB0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
          TON_bit = 0;
     }

     contp++;                                    //Aumenta el contador en una unidad.
     T1IF_bit = 0;                               //Limpia la bandera de interrupcion de Timer2
}


// Funcion para el calculo de la Velocidad del sonido en funcion de la temperatura //
void Velocidad(){
     unsigned int Temp;
     unsigned int Rint;
     float Rfrac;

     Ow_Reset(&PORTB, 1);                                 //Onewire reset signal
     Ow_Write(&PORTB, 1, 0xCC);                           //Issue command SKIP_ROM
     Ow_Write(&PORTB, 1, 0x44);                           //Issue command CONVERT_T
     Delay_us(120);

     Ow_Reset(&PORTB, 1);
     Ow_Write(&PORTB, 1, 0xCC);                           //Issue command SKIP_ROM
     Ow_Write(&PORTB, 1, 0xBE);                           //Issue command READ_SCRATCHPAD
     Delay_ms(400);

     Temp =  Ow_Read(&PORTB, 1);
     Temp = (Ow_Read(&PORTB, 1) << 8) + Temp;

     if (Temp & 0x8000) {
        Temp = 0;                                         //Si la temperatura es negativa la establece como cero.
     }

     Rint = Temp >> 4;                                    //Extrae la parte entera de la respuesta del sensor
     Rfrac = ((Temp & 0x000F) * 625) / 10000.;            //Extrae la parte decimal de la respuesta del sensor
     DSTemp = Rint + Rfrac;

     VSnd = 331.45 * sqrt(1+(DsTemp/273));                //Expresa la temperatura en punto flotante
}


// Configuraciones //
void MainInit(){

     //Configuracion del PLL para generar un FOSC de 80MHz  a partir de un oscilador externo de 8MHz
     CLKDIVbits.PLLPRE = 0;   //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
     PLLFBD = 38;             //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
     CLKDIVbits.PLLPOST = 0;  //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
     
     //Configuracion de puertos
     TRISB = 0;               //Initialize PORTB as output
     LATB = 0;                //Set PORTB to zero
     
     //Configuracion del TMR1
     TON_bit = 1;
     T1IE_bit = 1;
     T1IF_bit = 0;
     IPC0 = IPC0 | 0x1000;
     PR1 = 500;
     
     //Inicializacion de variables
     BS = 0;
     contp = 0;
     
     //Inicializacion del LCD
     Lcd_init();                                 //Inicializa el LCD
     Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
     Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD
     
     ADPCFG = 0xFFFF;

}


void main(){

 MainInit();
 
 while (1){
 
       Velocidad();
       
       TON_bit = 1;
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