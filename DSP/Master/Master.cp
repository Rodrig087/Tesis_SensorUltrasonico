#line 1 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/Master/Master.c"
#line 12 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/Master/Master.c"
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




const short Id = 0x02;
const short Fcn = 0x02;
const short Psize = 6;
const short Rsize = 6;
const short Hdr = 0x3A;
const short End = 0x0D;
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];
short ir, irr, ip, j;
unsigned short BanP, BanT;
unsigned short Dato;


short Bb;
char txt1[16];
char txt2[] = "Distancia: ";
unsigned short *ptrDst;
unsigned int Dst;

void interrupt(void){
 if(PIR1.F5==1){

 Dato = UART1_Read();

 if ((Dato==Hdr)&&(ir==0)){
 BanT = 1;
 Rspt[ir] = Dato;
 }
 if ((Dato!=Hdr)&&(ir==0)){
 ir=-1;
 }
 if ((BanT==1)&&(ir!=0)){
 Rspt[ir] = Dato;
 }

 ir++;
 if (ir==Rsize){
 BanP = 1;
 ir=0;
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
 RC5_bit = 0;

 ptrDst = &Dst;

 Ptcn[0]=Hdr;
 Ptcn[1]=Id;
 Ptcn[2]=Fcn;
 Ptcn[3]=0x00;
 Ptcn[4]=0x02;
 Ptcn[5]=End;

 Bb=0;
 Dst=0;

 while (1){

 if ((RA0_bit==1)&&(Bb==0)){
 Bb = 1;
 RC5_bit = 1;
 for (ip=0;ip<Psize;ip++){
 UART1_WRITE(Ptcn[ip]);
 }
 Dst = 0;
 while(UART_Tx_Idle()==0);
 RC5_bit = 0;
 } else if (RA0_bit==0){
 Bb = 0;
 }

 if (BanP==1){
 if ((Rspt[1]==Id)&&(Rspt[Rsize-1]==End)){

 *ptrDst = Rspt[4];
 *(ptrDst+1) = Rspt[3];

 for (irr=0;irr<(Rsize-1);irr++){
 Rspt[irr]=0;;
 }
 BanP = 0;


 } else {

 for (irr=0;irr<(Rsize-1);irr++){
 Rspt[irr]=0;;
 }
 BanP = 0;

 }
 }


 IntToStr(Dst,txt1);

 Lcd_Out(1,1,"Distancia:");
 Lcd_Out(2,1,txt1);

 Delay_ms(20);

 }
}
