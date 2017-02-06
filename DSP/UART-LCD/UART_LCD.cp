#line 1 "D:/Git/Tesis_SensorUltrasonico/DSP/UART-LCD/UART_LCD.c"

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





char uart_rd;
char txt1[6], txt2[6];
unsigned char *ptrTT2;
float T2;
unsigned long TT2;
unsigned short j;
unsigned char trama[4];


void interrupt(void){
 if (PIR1.F5){

 trama[j] = UART1_Read();
 j++;


 PIR1.F5 = 0;
 }
}



void Configuracion(){

 RCIE_bit = 0;
 TXIE_bit = 0;
 PEIE_bit = 1;
 GIE_bit = 1;

 UART1_Init(9600);
 Delay_ms(100);

 Lcd_Init();
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);
}


void main() {

 Configuracion();
 Lcd_Out(1, 1, "Hello!");
 ptrTT2 = &TT2;


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
