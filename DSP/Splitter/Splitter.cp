#line 1 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/Splitter/Splitter.c"
#line 12 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/Splitter/Splitter.c"
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




short TP;
short Id;
const short Psize = 4;
const short Rsize = 6;
const short Hdr = 0xEE;
const short End = 0xFF;
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];
short ir,ip,j;
unsigned short BanP;


short Bb;
char txt1[6];
unsigned short *ptrTT2;
unsigned long TT2;
unsigned int T2;

void interrupt(void){

 if(PIR1.F5==1){
 Rspt[ir] = UART1_Read();
 ir++;
 if (ir==Rsize){
 BanP = 1;
 }
 PIR1.F5 = 0;
 }

}


void Configuracion(){

 ANSELA = 0;
 ANSELB = 0;

 TRISC5_bit = 0;
 TRISA1_bit = 0;

 GIE_bit = 1;
 PEIE_bit = 1;
 RC1IE_bit = 1;
 TX1IE_bit = 0;

 UART1_Init(9600);
 Delay_ms(100);

 Lcd_Init();
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);
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
