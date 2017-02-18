/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 02/08/2016
Ultima modificacion: 17/02/2017
Estado: Modificando
Configuarcion: PIC18F25k22 8MHz
Descripcion:

---------------------------------------------------------------------------------------------------------------------------*/

// LCD module connections
sbit LCD_RS at RB5_bit;
sbit LCD_EN at RB4_bit;
sbit LCD_D4 at RB3_bit;
sbit LCD_D5 at RB2_bit;
sbit LCD_D6 at RB1_bit;
sbit LCD_D7 at RB0_bit;

sbit LCD_RS_Direction at TRISB5_bit;
sbit LCD_EN_Direction at TRISB4_bit;
sbit LCD_D4_Direction at TRISB3_bit;
sbit LCD_D5_Direction at TRISB2_bit;
sbit LCD_D6_Direction at TRISB1_bit;
sbit LCD_D7_Direction at TRISB0_bit;
// End LCD module connections

//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables para la peticion y respuesta de datos
const short TP = 0x01;                                  //Identificador de tipo de sensor
const short Id = 0x07;                                  //Identificador de numero de esclavo
const short Psize = 4;                                  //Constante de longitud de trama de Peticion
const short Rsize = 6;                                  //Constante de longitud de trama de Respuesta
const short Hdr = 0xEE;                                 //Constante de delimitador de inicio de trama
const short End = 0xFF;                                 //Constante de delimitador de final de trama
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];
short ir,ip,j;                                          //Subindices para las tramas de peticion y respuesta
unsigned short BanP;
unsigned short dato;

//Variables para visualizar el dato en la LCD
short Bb;
char txt1[16];
char txt2[] = "Distancia: ";
unsigned short  *ptrDst;
unsigned int Dst;

void interrupt(void){
     if(PIR1.F5==1){                                 //Verifica la bandera de interrupcion del Uart1
        RA1_bit = ~RA1_bit;
        Rspt[ir] = UART1_Read();                     //Almacena los datos de entrada byte a byte en el buffer de peticion
        ir++;
        if (ir==Rsize){                              //Verifica que se haya terminado de llenar la trama de datos
           BanP = 1;                                 //Habilita la bandera de lectura de datos
        }
        PIR1.F5 = 0;                            //Limpia la bandera de interrupcion
     }
}

// Configuracion //
void Configuracion(){

     ANSELA = 0;                                       //Configura el PORTA como digital
     ANSELB = 0;                                       //Configura el PORTB como digital
     ANSELC = 0;                                       //Configura el PORTC como digital

     TRISC5_bit = 0;                                   //Configura el pin C5 como salida
     TRISA0_bit = 1;
     TRISA1_bit = 0;

     INTCON.GIE = 1;                                   //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
     INTCON.RBIF = 0;
     
     PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
     PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion

     UART1_Init(9600);                                 //Inicializa el UART a 9600 bps
     Delay_ms(100);                                    //Espera para que el modulo UART se estabilice

     Lcd_Init();                                       // Initialize LCD
     Lcd_Cmd(_LCD_CLEAR);                              // Clear display
     Lcd_Cmd(_LCD_CURSOR_OFF);                         // Cursor off
}

void main() {

     Configuracion();

     ptrDst = &Dst;

     Ptcn[0]=Hdr;
     Ptcn[1]=Tp;
     Ptcn[2]=Id;
     Ptcn[3]=End;

     Bb=0;
     Dst=0;

     while (1){

           if ((RA0_bit==1)&&(Bb==0)){
               Bb = 1;
               for (ip=0;ip<Psize;ip++){
                    UART1_WRITE(Ptcn[ip]);                          //Manda por Uart la trama de peticion
               }
               //while(UART_Tx_Idle()==0);                            //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
            }

            if (BanP==1){
               if ((Rspt[0]==Hdr)&&(Rspt[Rsize-1]==End)){
                  if ((Rspt[1]==TP)&&(Rspt[2]==Id)){                //Verifica el identificador de tipo de sensor y el identificador de esclavo

                      for (ir=3;ir<5;ir++){
                        *(ptrDst+(ir-3)) = Rspt[ir];               //Asigna a TT2 los datos tomados de la trama de peticion
                      }
                      for (ir=0;ir<(Rsize-1);ir++){
                           Rspt[ir]=0;;                            //Limpia los bits de datos de la trama de respuesta
                      }

                      BanP = 0;
                      ir=0;                                        //Limpia el subindice de la trama de peticion

                  }
               } else {

                      for (ir=0;ir<(Rsize-1);ir++){
                           Rspt[ir]=0;;                            //Limpia los bits de datos de la trama de respuesta
                      }
                      BanP = 0;
                      ir=0;

               }
            }

           IntToStr(Dst,txt1);

           Lcd_Out(1,1,"Distancia:");
           Lcd_Out(2,1,txt1);

           Delay_ms(20);
           Bb = 0;

     }
}