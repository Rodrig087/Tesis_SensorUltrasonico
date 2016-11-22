#line 1 "E:/Milton/Github/Tesis/SensorUltrasonico/APESW/APESW.c"
#line 16 "E:/Milton/Github/Tesis/SensorUltrasonico/APESW/APESW.c"
const short idSlv = 0x31;
const short Psize = 4;
const short Rsize = 5;
const short Hdr = 0x20;
const short End = 0x0D;
unsigned short ThT = 8;
unsigned short Dms;
unsigned short Dmn;
unsigned short F1, F2;
unsigned short DF1, DF2, DFT;


unsigned int contp;
unsigned int contT;
unsigned int contTOF;
unsigned int T1;
unsigned int T2;
unsigned int DT;
unsigned int Di;

unsigned short BS;
unsigned short FP;
unsigned short FEC;
unsigned short FIE;
unsigned short i,j,k;

float TOF, Df, VSnd;
float DSTemp;

unsigned long DHTvalue;

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

 if (contp<=42){
 BS = ~BS;
 RD0_bit = BS;
 if (contp==20){
 BS = 0;
 }

 } else {
 TMR2ON_bit=0;
 RD0_bit = 0;
 TMR1ON_bit=1;
 TMR1L=0X00;
 TMR1H=0X00;
 }

 contp++;
 TMR2IF_bit = 0;

 }


 if (INTCON.INT0IF == 1){


 *(punT1) = TMR1L;
 *(punT1+1) = TMR1H;

 T2 = contT;
 DT = (T2-T1);

 if (F1<=3){
 if (DT>(298-Tht)&&DT<(298+Tht)){
 F1++;
 if (F1==3) {
 DF1 = T2;
 RE1_bit = 1;

 }
 } else {
 F1=0;
 }
 }

 if (DF1>0){
 F2++;
 DF2 = (T2-DF1);
 DFT = ((F2*2)-1)*149;
 if (DFT>(DF2-Tht)&&DFT<(DF2+Tht)){
 contTOF = T2;
 RE1_bit = 0;
 DF1 = 0;
 TMR1ON_bit = 0;
 contT = 0;
 }
 }


 T1 = contT;
 INTCON.INT0IF = 0;

 }

 if (TMR1IF_bit){
 TMR1IF_bit=0;
 }

}



void Velocidad(){
 unsigned int Temp;
 unsigned int Rint;
 float Rfrac;

 Ow_Reset(&PORTE, 2);
 Ow_Write(&PORTE, 2, 0xCC);
 Ow_Write(&PORTE, 2, 0x44);
 Delay_us(120);

 Ow_Reset(&PORTE, 2);
 Ow_Write(&PORTE, 2, 0xCC);
 Ow_Write(&PORTE, 2, 0xBE);

 Temp = Ow_Read(&PORTE, 2);
 Temp = (Ow_Read(&PORTE, 2) << 8) + Temp;

 if (Temp & 0x8000) {
 Temp = 0;
 }

 Rint = Temp >> 4;
 Rfrac = ((Temp & 0x000F) * 625) / 10000.;
 DSTemp = Rint + Rfrac;

 VSnd = 331.45 * sqrt(1+(DsTemp/273));
}



void Configuracion() {

 INTCON.GIE = 1;
 INTCON.PEIE = 1;

 INTCON.INT0IE = 1;
 INTCON2.RBPU = 1;
 INTCON2.INTEDG0 = 0;

 ADCON1 = 0b00001111;
 CMCON = 0b00000111;

 T1CON=0x00;
 TMR1IE_bit = 1;

 T2CON = 0x00;
 PIE1.TMR2IE = 1;
 PR2 = 149;

 TRISD0_bit = 0;
 TRISD1_bit = 0;

 TRISE0_bit = 0;
 TRISE1_bit = 0;

 TRISB = 0x07;

}


void main() {

 Configuracion();

 RD0_bit = 0;
 RD1_bit = 1;
 RE1_bit = 0;
 PORTB = 0;

 punT1 = &contT;
 punDt = &Di;

 contp = 0;
 contTOF = 0;
 BS = 0;
 FP = 0;
 T1 = 0;
 T2 = 0;
 TOF = 0;
 Di = 0;
 FEC = 0;
 F1 = 0;
 F2 = 0;
 DFT = 0;

 Rspt[0] = Hdr;
 Rspt[1] = idSlv;
 Rspt[4] = End;

 Lcd_init();
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);

 UART1_Init(9600);
 Delay_ms(100);

 while (1){


 Velocidad();

 BS = 0;
 contp = 0;
 contT = 0;
 T1=0;
 T2=0;
 DT=0;

 F1 = 0;
 F2 = 0;
 DF1 = 0;
 DF2 = 0;
 DFT = 0;

 TMR2ON_bit=1;


 TOF = (contTOF)*(4./48);
 Df = ((VSnd * TOF ) / 2000);
 Di = Df*10;

 for (i=2;i<4;i++){
 Rspt[i]=(*punDt++);
 }

 FloatToStr(TOF, txt1);
 FloatToStr(Df, txt2);

 Lcd_Out(1,1,"TOF: ");
 Lcd_Out_Cp(txt1);
 Lcd_Out(2,1,"Dst: ");
 Lcd_Out_Cp(txt2);

 delay_ms(15);

 }
}
