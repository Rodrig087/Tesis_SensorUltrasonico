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
char Dato;
unsigned short i, j;
unsigned char trama[5];
unsigned char trama2[4];
unsigned char Ptcn[4];

unsigned short BanP, BanL;
char txt1[15];

unsigned short  *ptrTT2;
unsigned long TT2;
float T2;

short Bb;



// Interrupciones //
void interrupt(void){

      if (PIR1.F5){
         LATD0_bit = ~LATD0_bit;
         trama[i] = UART1_Read();                     //Almacena los datos de entrada byte a byte en el buffer de peticion
         i++;
         if (i==4){                                   //Verifica que se haya terminado de llenar la trama de datos
            BanL = 1;                                 //Habilita la bandera de lectura de datos
         }
         PIR1.F5 = 0;                                 //Limpia la bandera de interrupcion
     }
}


// Configuracion //
void Configuracion(){

      TRISD0_bit = 0;
      TRISD1_bit = 1;
      
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
     Lcd_Out(1, 1, "Hello!");
     delay_ms(1);
     ptrTT2 = &TT2;
     
     Ptcn[0]=0xEE;
     Ptcn[1]=0x01;
     Ptcn[2]=0x07;
     Ptcn[3]=0xFF;
     
     Bb=0;
     
     while (1){

            if ((RD1_bit==1)&&(Bb==0)){
               Bb = 1;
               for (j=0;j<4;j++){
                    UART1_WRITE(Ptcn[j]);
               }
            }

            if (BanL==1){
            
                for (j=1;j<5;j++){
                    //*(ptrTT2+j) = trama[j];
                    trama2[j-1]= trama[j];
                }

                BanL = 0;
                i=0;
                
            }
            
            T2 = TT2 / 100.0;
            FloatToStr(T2,txt1);

            Lcd_Out(1, 1, "T2: ");
            Lcd_Out(2,1,txt1);
            

            Delay_ms(10);
            Bb = 0;

     }

}