#line 1 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/UART-LCD/UART_LCD.c"

sbit LCD_RS at RB0_bit;
sbit LCD_EN at RB1_bit;
sbit LCD_D4 at RB2_bit;
sbit LCD_D5 at RB3_bit;
sbit LCD_D6 at RB4_bit;
sbit LCD_D7 at RB5_bit;

sbit LCD_RS_Direction at TRISB0_bit;
sbit LCD_EN_Direction at TRISB1_bit;
sbit LCD_D4_Direction at TRISB2_bit;
sbit LCD_D5_Direction at TRISB3_bit;
sbit LCD_D6_Direction at TRISB4_bit;
sbit LCD_D7_Direction at TRISB5_bit;





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


short Bb;
char txt1[15];
unsigned short *ptrTT2;
unsigned long TT2;
unsigned int T2;


void interrupt(void){

 if (PIR1.F5){
 LATD0_bit = ~LATD0_bit;
 Rspt[ir] = UART1_Read();
 ir++;
 if (ir==Rsize){
 BanP = 1;
 }
 PIR1.F5 = 0;
 }
}



void Configuracion(){

 TRISD0_bit = 0;
 TRISD1_bit = 1;
 TRISC0_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;
 INTCON2.RBPU = 0;

 ADCON1 = 0b00001111;
 CMCON = 0b00000111;

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
 LATC0_bit = 0;
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

 if ((RD1_bit==1)&&(Bb==0)){
 Bb = 1;
 for (ip=0;ip<Psize;ip++){
 LATC0_bit = 1;
 UART1_WRITE(Ptcn[ip]);
 }
 while(UART_Tx_Idle()==0);

 LATC0_bit = 0;
 }

 if (BanP==1){
 if ((Rspt[0]==Hdr)&&(Rspt[Rsize-1]==End)){
 if ((Rspt[1]==TP)&&(Rspt[2]==Id)){

 for (ir=3;ir<5;ir++){
 *(ptrTT2+(ir-3)) = Rspt[ir];
 }

 BanP = 0;
 ir=0;
 }
 }
 }


 T2 = TT2;
 IntToStr(T2,txt1);

 Lcd_Out(1, 1, "T2: ");
 Lcd_Out(2,1,txt1);


 Delay_ms(10);
 Bb = 0;

 }

}
