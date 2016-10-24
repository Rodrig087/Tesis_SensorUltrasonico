#line 1 "E:/Milton/Github/Tesis/SensorUltrasonico/APESW/APESW.c"
#line 16 "E:/Milton/Github/Tesis/SensorUltrasonico/APESW/APESW.c"
const short idSlv = 0x31;
const short Psize = 4;
const short Rsize = 5;
const short Hdr = 0x20;
const short End = 0x0D;
unsigned short Dms;
unsigned short Dmn;


unsigned int contw;
unsigned int contT;
unsigned int contT1;
unsigned int T1;
unsigned int T2;
unsigned int DT;

unsigned short BS;
unsigned short FP;
unsigned short FIE;
unsigned short i,j,k;

float TOF, Df;
unsigned int Di;

char *punT1;
char *punDt;

char txt1[8], txt2[8];
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];


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
 RD1_bit = 1;
 }

 } else {
 RD0_bit = 0;
 FP = 1;
 }

 if (contw>=800){
 contw = 0;
 T1=0;
 T2=0;
 DT=0;
 }

 contw++;
 TMR2IF_bit = 0;
 }



 if (INTCON.INT0IF == 1){
 *(punT1) = TMR1L;
 *(punT1+1) = TMR1H;
 T2 = contw;
 DT = T2-T1;

 if ((T2>43)&&(DT!=T2)&&(DT!=2)){
 contT1 = contT;
 TMR1ON_bit=0;
 contT = 0;
 RD1_bit = 0;
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
 punDt = &Di;

 contw = 0;
 contT1 = 0;
 BS = 0;
 FP = 0;
 T1 = 0;
 T2 = 0;
 TOF = 0;
 Di = 0;

 Rspt[0] = Hdr;
 Rspt[1] = idSlv;
 Rspt[4] = End;

 Lcd_init();

 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);

 UART1_Init(9600);
 Delay_ms(100);

 while (1){

 TOF = (contT1)*(4./48);
 Df = (343. * TOF ) / 2000;
 Di = Df*10;


 for (i=2;i<4;i++){
 Rspt[i]=(*punDt++);
 }

 FloatToStr(Df, txt1);
 IntToStr(Di, txt2);

 Lcd_Out(1,1,"Df: ");
 Lcd_Out_Cp(txt1);
 Lcd_Out(2,1,"Di: ");
 Lcd_Out_Cp(txt2);

 for (j=0;j<=4;j++){
 UART1_Write(Rspt[j]);
 }

 delay_ms(1);

 }
}
