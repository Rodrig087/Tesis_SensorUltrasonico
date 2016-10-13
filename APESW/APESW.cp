#line 1 "E:/Milton/Github/Tesis/SensorUltrasonico/APESW/APESW.c"
#line 14 "E:/Milton/Github/Tesis/SensorUltrasonico/APESW/APESW.c"
const short idSlv = 0x31;
const short Psize = 4;
const short Rsize = 5;
const short Hdr = 0x20;
const short End = 0x0D;


unsigned int contw;
unsigned int contT;
unsigned int contT1;
unsigned int T1;
unsigned int T2;
unsigned int DT;

unsigned short BS;

float TOFT;

char *punT1;

char txt1[10], txt2[10];
unsigned char Ptcn[Psize];



sbit LCD_RS at RD2_bit;
sbit LCD_EN at RD3_bit;
sbit LCD_D4 at RD4_bit;
sbit LCD_D5 at RD5_bit;
sbit LCD_D6 at RD6_bit;
sbit LCD_D7 at RD7_bit;

sbit LCD_RS_Direction at TRISD2_bit;
sbit LCD_EN_Direction at TRISD3_bit;
sbit LCD_D4_Direction at TRISD4_bit;
sbit LCD_D5_Direction at TRISD5_bit;
sbit LCD_D6_Direction at TRISD6_bit;
sbit LCD_D7_Direction at TRISD7_bit;


void Interrupt(){

 if (TMR2IF_bit){

 if (contw<=43){
 BS = ~BS;
 RD0_bit = BS;
 if (contw==25){
 TMR1ON_bit=1;
 TMR1L=0X00;
 TMR1H=0X00;
 }
 if (contw==22){
 BS = 0;
 }

 } else {
 RD0_bit = 0;
 }

 if (contw>=800){
 contw = 0;
 }

 contw++;
 TMR2IF_bit = 0;
 }

 if (INTCON.INT0IF == 1){
 *(punT1) = TMR1L;
 *(punT1+1) = TMR1H;
 T2 = contw;
 DT = T2-T1;
 if ((DT>2)&&(DT<10)){
 contT1 = contT;
 TMR1ON_bit=0;
 contT = 0;
 }
 T1 = contw;
 INTCON.INT0IF = 0;
 }

 if (TMR1IF_bit){
 TMR1IF_bit=0;
 }
}



void main() {

 INTCON.GIE = 1;
 INTCON.PEIE = 1;

 INTCON.INT0IE = 1;
 INTCON2.RBPU = 1;
 INTCON2.INTEDG0 = 1;

 ADCON1 = 0b00010111;
 CMCON = 0b00000111;

 T1CON=0x00;
 TMR1IE_bit = 1;

 T2CON = 0x04;
 PIE1.TMR2IE = 1;
 PR2 = 149;

 TRISD0_bit = 0;
 TRISD1_bit = 0;

 TRISB = 0x07;

 RD0_bit = 0;
 RD1_bit = 0;
 PORTB = 0;

 punT1 = &contT;

 contw = 0;
 contT1 = 0;
 BS = 0;
 T1 = 0;
 T2 = 0;
 TOFT = 0;

 Lcd_init();
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);

 while (1){

 TOFT = (contT1 * 0.1) - 2.49;

 FloatToStr(TOFT, txt1);
 Lcd_Out(1,1,"TOF: ");
 Lcd_Out_Cp(txt1);

 delay_ms(1);

 }
}
