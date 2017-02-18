#line 1 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/Splitter/Splitter.c"
#line 12 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/Splitter/Splitter.c"
sbit LCD_RS at RB5_bit;
sbit LCD_EN at RB4_bit;
sbit LCD_D4 at RB3_bit;
sbit LCD_D5 at RB2_bit;
sbit LCD_D6 at RB1_bit;
sbit LCD_D7 at RB0_bit;

sbit LCD_RS_Direction at TRISB5_bit;
sbit LCD_EN_Direction at TRISB4_bit;
sbit LCD_D4_Direction at TRISB3_bit;
sbit LCD_D5_Direction at TRISB2_bit;
sbit LCD_D6_Direction at TRISB1_bit;
sbit LCD_D7_Direction at TRISB0_bit;




const short TP = 0x01;
const short Id = 0x07;
const short Psize = 4;
const short Rsize = 6;
const short Hdr = 0xEE;
const short End = 0xFF;
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];
short ir,ip,j;
unsigned short BanP;
unsigned short dato;


short Bb;
char txt1[16];
char txt2[] = "Distancia: ";
unsigned short *ptrDst;
unsigned int Dst;

void interrupt(void){
 if(PIR1.F5==1){
 RA1_bit = ~RA1_bit;
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
 ANSELC = 0;

 TRISC5_bit = 0;
 TRISA0_bit = 1;
 TRISA1_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;
 INTCON.RBIF = 0;

 PIE1.RC1IE = 1;
 PIR1.F5 = 0;

 UART1_Init(9600);
 Delay_ms(100);

 Lcd_Init();
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);
}

void main() {

 Configuracion();

 ptrDst = &Dst;

 Ptcn[0]=Hdr;
 Ptcn[1]=Tp;
 Ptcn[2]=Id;
 Ptcn[3]=End;

 Bb=0;
 Dst=0;

 while (1){

 if ((RA0_bit==1)&&(Bb==0)){
 Bb = 1;
 for (ip=0;ip<Psize;ip++){
 UART1_WRITE(Ptcn[ip]);
 }

 }

 if (BanP==1){
 if ((Rspt[0]==Hdr)&&(Rspt[Rsize-1]==End)){
 if ((Rspt[1]==TP)&&(Rspt[2]==Id)){

 for (ir=3;ir<5;ir++){
 *(ptrDst+(ir-3)) = Rspt[ir];
 }
 for (ir=0;ir<(Rsize-1);ir++){
 Rspt[ir]=0;;
 }

 BanP = 0;
 ir=0;

 }
 } else {

 for (ir=0;ir<(Rsize-1);ir++){
 Rspt[ir]=0;;
 }
 BanP = 0;
 ir=0;

 }
 }

 IntToStr(Dst,txt1);

 Lcd_Out(1,1,"Distancia:");
 Lcd_Out(2,1,txt1);

 Delay_ms(20);
 Bb = 0;

 }
}
