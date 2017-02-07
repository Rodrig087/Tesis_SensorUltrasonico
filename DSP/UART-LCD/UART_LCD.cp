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





char Dato;
unsigned short i, j;
unsigned char trama[4];

unsigned short BanP, BanT;
char txt1[15];

unsigned short *ptrTT2;
unsigned long TT2;
float T2;




void interrupt(void){

 if (PIR1.F5){

 Dato = UART1_Read();
 if (Dato==0x0D){
 BanP = 1;
 Dato = 0;
 i=0;
 }

 if (BanP == 1){
 trama[i] = UART1_Read();
 i++;
 if (i==3){
 BanT = 1;
 }
 }

 PIR1.F5 = 0;

 }
}



void Configuracion(){

 RCIE_bit = 1;
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
