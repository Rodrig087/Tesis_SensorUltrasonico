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
char uart_rd;
char txt1[6], txt2[6];
unsigned char  *ptrTT2;
float T2;
unsigned long TT2;
unsigned short j;
unsigned char trama[4];

// Interrupciones //
void interrupt(void){
      if (PIR1.F5){
         //if (j<4){
             trama[j] = UART1_Read();
             j++;
         //}
         
         PIR1.F5 = 0;
     }
}


// Configuracion //
void Configuracion(){

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
     //ptrT2 = (unsigned char *) & T2;
     
     while (1){

            
            *(ptrTT2) = trama[3];
            *(ptrTT2+1) = trama[2];
            *(ptrTT2+2) = trama[1];
            *(ptrTT2+3) = trama[0];
            
            j=0;
            
            T2 = TT2 / 100.0;
            FloatToStr(T2,txt1);

            Lcd_Out(1, 1, "T2: ");
            Lcd_Out_Cp(txt1);
            

     }

}