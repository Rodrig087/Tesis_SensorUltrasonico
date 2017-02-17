// LCD module connections
sbit LCD_RS at RB0_bit;
sbit LCD_EN at RB1_bit;
sbit LCD_D4 at RB2_bit;
sbit LCD_D5 at RB3_bit;
sbit LCD_D6 at RB4_bit;
sbit LCD_D7 at RB5_bit;

sbit LCD_RS_Direction at TRISB0_bit;
sbit LCD_EN_Direction at TRISB1_bit;
sbit LCD_D4_Direction at TRISB2_bit;
sbit LCD_D5_Direction at TRISB3_bit;
sbit LCD_D6_Direction at TRISB4_bit;
sbit LCD_D7_Direction at TRISB5_bit;
// End LCD module connections


// Declaracion de variables //
//Variables para la lectura y almacenamiento del dato proveniente del UART
const short TP = 0x01;                                  //Identificador de tipo de sensor
const short Id = 0x07;                                  //Identificador de numero de esclavo
const short Psize = 4;                                  //Constante de longitud de trama de Peticion
const short Rsize = 6;                                  //Constante de longitud de trama de Respuesta
const short Hdr = 0xEE;                                 //Constante de delimitador de inicio de trama (0x20)
const short End = 0xFF;                                 //Constante de delimitador de final de trama (0x0D)
unsigned char Ptcn[Psize];                              //Trama de peticion
unsigned char Rspt[Rsize];                              //Trama de respuesta
short ir,ip,j;                                          //Subindices para las tramas de peticion y respuesta
unsigned short BanP;

//Variables para visualizar el dato en la LCD
short Bb;
char txt1[15];
unsigned short  *ptrTT2;
unsigned long TT2;
unsigned int T2;

// Interrupciones //
void interrupt(void){

      if (PIR1.F5){
         LATD0_bit = ~LATD0_bit;
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

      TRISD0_bit = 0;
      TRISD1_bit = 1;
      TRISC0_bit = 0;
      
      INTCON.GIE = 1;                             //Habilita las interrupciones globales
      INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
      INTCON2.RBPU = 0;
      
      ADCON1 = 0b00001111;                        //Configuracion ADCON1
      CMCON = 0b00000111;

      RCIE_bit = 1;                         // enable interrupt on UART1 receive
      TXIE_bit = 0;                         // disable interrupt on UART1 transmit
      PEIE_bit = 1;                         // enable peripheral interrupts
      GIE_bit = 1;

      UART1_Init(9600);                     // Inicializa el UART a 9600 bps
      Delay_ms(100);

      Lcd_Init();                           // Initialize LCD
      Lcd_Cmd(_LCD_CLEAR);                  // Clear display
      Lcd_Cmd(_LCD_CURSOR_OFF);             // Cursor off
}


void main() {

     Configuracion();
     LATC0_bit = 0;                                                   //Establece el Max485 en modo de lectura
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

            if ((RD1_bit==1)&&(Bb==0)){
               Bb = 1;
               for (ip=0;ip<Psize;ip++){
                    LATC0_bit = 1;                                    //Establece el Max485 en modo de escritura
                    UART1_WRITE(Ptcn[ip]);                          //Manda por Uart la trama de peticion
               }
               while(UART_Tx_Idle()==0);                            //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
               //Delay_ms(1);
               LATC0_bit = 0;                                         //Establece el Max485 en modo de lectura
            }

            if (BanP==1){
               if ((Rspt[0]==Hdr)&&(Rspt[Rsize-1]==End)){
                  if ((Rspt[1]==TP)&&(Rspt[2]==Id)){                //Verifica el identificador de tipo de sensor y el identificador de esclavo

                      for (ir=3;ir<5;ir++){
                        *(ptrTT2+(ir-3)) = Rspt[ir];               //Asigna a TT2 los datos tomados de la trama de peticion
                      }

                      BanP = 0;
                      ir=0;                                        //Limpia el subindice de la trama de peticion
                  }
               }
            }
            
            
            T2 = TT2;
            IntToStr(T2,txt1);

            Lcd_Out(1, 1, "T2: ");
            Lcd_Out(2,1,txt1);
            

            Delay_ms(10);
            Bb = 0;

     }

}