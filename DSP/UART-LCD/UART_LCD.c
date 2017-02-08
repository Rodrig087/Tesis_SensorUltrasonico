// LCD module connections
sbit LCD_RS at RD0_bit;
sbit LCD_EN at RD1_bit;
sbit LCD_D4 at RD2_bit;
sbit LCD_D5 at RD3_bit;
sbit LCD_D6 at RD4_bit;
sbit LCD_D7 at RD5_bit;

sbit LCD_RS_Direction at TRISD0_bit;
sbit LCD_EN_Direction at TRISD1_bit;
sbit LCD_D4_Direction at TRISD2_bit;
sbit LCD_D5_Direction at TRISD3_bit;
sbit LCD_D6_Direction at TRISD4_bit;
sbit LCD_D7_Direction at TRISD5_bit;
// End LCD module connections


// Declaracion de variables //
//Variables para la lectura y almacenamiento del dato proveniente del UART
char Dato;
unsigned short i, j;
unsigned char trama[4];

unsigned short BanP, BanT;
char txt1[15];

unsigned short  *ptrTT2;
unsigned long TT2;
float T2;



// Interrupciones //
void interrupt(void){

      if (PIR1.F5){
      
         Dato = UART1_Read();                            //Lee el dato que llega por el modulo Uart1
         if (Dato==0x0D){                                //Verifica si el dato que llego es la cabecera
            BanP = 1;                                    //activa la bandera que permite almacenar los datos en el buffer
            Dato = 0;                                    //Limpia la variable Dato
            i=0;                                         //Limpia el subindice del vector de
         }
         
         if (BanP == 1){
            trama[i] = UART1_Read();                     //Almacena los datos de entrada byte a byte en el buffer de peticion
            i++;
            if (i==3){
               BanT = 1;
            }
         }
         
         PIR1.F5 = 0;                                    //Limpia la bandera de interrupcion
         
     }
}


// Configuracion //
void Configuracion(){

      INTCON.GIE = 1;                             //Habilita las interrupciones globales
      INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
      INTCON2.RBPU = 0;
      
      ADCON1 = 0b00001111;                        //Configuracion ADCON1
      CMCON = 0b00000111;

      RCIE_bit = 0;                         // enable interrupt on UART1 receive
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
     ptrTT2 = &TT2;
     
     while (1){

            if (BanT==1){
            
                for (j=0;j<4;j++){
                    *(ptrTT2+j) = trama[j];
                }
                
                BanP = 0;
                BanT = 0;
                
            }
            
            T2 = TT2 * 1.0;
            FloatToStr(T2,txt1);

            Lcd_Out(1, 1, "T2: ");
            Lcd_Out(2,1,txt1);
            

            
            Delay_ms(10);

     }

}