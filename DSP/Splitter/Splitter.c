/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 02/08/2016
Ultima modificacion: 17/02/2017
Estado: Modificando
Configuarcion: PIC18F25k22 8MHz
Descripcion:

---------------------------------------------------------------------------------------------------------------------------*/

// LCD module connections
sbit LCD_RS at RA0_bit;
sbit LCD_EN at RA1_bit;
sbit LCD_D4 at RA2_bit;
sbit LCD_D5 at RA3_bit;
sbit LCD_D6 at RA4_bit;
sbit LCD_D7 at RA5_bit;

sbit LCD_RS_Direction at TRISA0_bit;
sbit LCD_EN_Direction at TRISA1_bit;
sbit LCD_D4_Direction at TRISA2_bit;
sbit LCD_D5_Direction at TRISA3_bit;
sbit LCD_D6_Direction at TRISA4_bit;
sbit LCD_D7_Direction at TRISA5_bit;
// End LCD module connections

//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables para la peticion y respuesta de datos
short TP;                                               //Identificador de tipo de sensor
short Id;                                               //Identificador de numero de esclavo
const short Psize = 4;                                  //Constante de longitud de trama de Peticion
const short Rsize = 6;                                  //Constante de longitud de trama de Respuesta
const short Hdr = 0xEE;                                 //Constante de delimitador de inicio de trama
const short End = 0xFF;                                 //Constante de delimitador de final de trama
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];
short ir,ip,j;                                          //Subindices para las tramas de peticion y respuesta
unsigned short BanP;

//Variables para visualizar el dato en la LCD
short Bb;
char txt1[6];
unsigned short  *ptrTT2;
unsigned long TT2;
unsigned int T2;

void interrupt(void){

     if(PIR1.F5==1){                                   //Verifica la bandera de interrupcion del Uart1
        Rspt[ir] = UART1_Read();                     //Almacena los datos de entrada byte a byte en el buffer de peticion
         ir++;
         if (ir==Rsize){                              //Verifica que se haya terminado de llenar la trama de datos
            BanP = 1;                                 //Habilita la bandera de lectura de datos
         }
         PIR1.F5 = 0;                                 //Limpia la bandera de interrupcion
     }

}

// Configuracion //
void Configuracion(){

     ANSELA = 0;                                       //Configura el PORTA como digital
     ANSELB = 0;                                       //Configura el PORTB como digital

     TRISC5_bit = 0;                                   //Configura el pin C5 como salida
     TRISA1_bit = 0;

     GIE_bit = 1;                                      //Habilita las interrupciones globales
     PEIE_bit = 1;                                     //Habilita las interrupciones perifericas
     RC1IE_bit = 1;                                    //Habilita la interrupcion en UART1 receive
     TX1IE_bit = 0;                                    //Desabilita la interrupcion en UART1 transmit

     UART1_Init(9600);                                 //Inicializa el UART a 9600 bps
     Delay_ms(100);                                    //Espera para que el modulo UART se estabilice

     Lcd_Init();                                       // Initialize LCD
     Lcd_Cmd(_LCD_CLEAR);                              // Clear display
     Lcd_Cmd(_LCD_CURSOR_OFF);                         // Cursor off
}

void main() {

     Configuracion();

     Lcd_Out(1, 1, "Hello!");
     delay_ms(1);
     ptrTT2 = &TT2;

     Ptcn[0]=Hdr;
     Ptcn[1]=Tp;
     Ptcn[2]=Id;
     Ptcn[3]=End;

     Bb=0;
     T2=0;

     while (1){

           T2 = 265;
           IntToStr(T2,txt1);

           Lcd_Out(1, 1, "T2: ");
           Lcd_Out(2,1,txt1);

           RA1_bit = ~RA1_bit;

           Delay_ms(20);

     }
}