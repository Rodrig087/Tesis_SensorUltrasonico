#line 1 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/dsPIC/ADC_DAC.c"
#line 9 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/dsPIC/ADC_DAC.c"
const float h[]=
{
0,
3.251384999241953e-04,
0.001575110004776,
0.004329299981286,
0.009215597951451,
0.016562374380979,
0.026042906090692,
0.036510596395369,
0.046158863555439,
0.052995863262555,
0.055470000000000,
0.052995863262555,
0.046158863555439,
0.036510596395369,
0.026042906090692,
0.016562374380979,
0.009215597951451,
0.004329299981286,
0.001575110004776,
3.251384999241943e-04,
0
};



unsigned int contp;

float DSTemp, VSnd;

const unsigned int nm = 350;
unsigned int M[nm];
unsigned int i;
unsigned int j;
unsigned int k;
short bm;

unsigned int value = 0;
unsigned int aux_value = 0;

float x0=0, x1=0, x2=0, y0=0, y1=0, y2=0;
const unsigned short O = 21;
float XFIR[O];
unsigned int f;
unsigned int YY = 0;

unsigned int Mmax=0;
unsigned int Mmin=0;
unsigned int Mmed=0;
unsigned int MIndexMax;
unsigned int MIndexMin;

unsigned int VP=0;
unsigned int maxIndex;
unsigned int i0, i1, i2, imax;
unsigned int i1a, i1b;
const short dix=15;
const float tx=5.0;
int yy0, yy1, yy2;
float yf0, yf1, yf2;
float nx, dx, tmax;

float T1, T2;
float TOF, Dst;

char txt1[6], txt2[6], txt3[6], txt4[6] ;

short bp;
short conts;
float T2a,T2b,dT2;
unsigned long TT2;
unsigned char *chT2;
unsigned char trama[4];
short l;




void Velocidad(){
 unsigned int Temp;
 unsigned int Rint;
 float Rfrac;

 Ow_Reset(&PORTA, 0);
 Ow_Write(&PORTA, 0, 0xCC);
 Ow_Write(&PORTA, 0, 0x44);
 Delay_us(100);

 Ow_Reset(&PORTA, 0);
 Ow_Write(&PORTA, 0, 0xCC);
 Ow_Write(&PORTA, 0, 0xBE);
 Delay_us(100);

 Temp = Ow_Read(&PORTA, 0);
 Temp = (Ow_Read(&PORTA, 0) << 8) + Temp;

 if (Temp & 0x8000) {
 Temp = 0;
 }

 Rint = Temp >> 4;
 Rfrac = ((Temp & 0x000F) * 625) / 10000.;
 DSTemp = Rint + Rfrac;

 VSnd = 331.45 * sqrt(1+(DsTemp/273));
}


void Pulse(){




 contp = 0;
 RB2_bit = 0;

 T1CON.TON = 0;
 IEC0.T1IE = 0;

 TMR2 = 0;
 IEC0.T2IE = 1;
 T2CON.TON = 1;

 i = 0;
 j = 0;



 while(bm!=1);


 if (bm==1){


 Mmax = Vector_Max(M, nm, &MIndexMax);
 Mmin = Vector_Min(M, nm, &MIndexMin);
 Mmed = Mmax-((Mmax-Mmin)/2);

 for (k=0;k<nm;k++){


 value = M[k]-Mmed;
 if (M[k]<Mmed){
 value = (M[k]+((Mmed-M[k])*2))-(Mmed);
 }



 for( f=O-1; f!=0; f-- ) XFIR[f]=XFIR[f-1];

 XFIR[0] = (float)(value);

 y0 = 0.0; for( f=0; f<O; f++ ) y0 += h[f]*XFIR[f];



 YY = (unsigned int)(y0);
 M[k] = YY;

 }

 bm = 2;

 }


 if (bm==2){

 yy1 = Vector_Max(M, nm, &maxIndex);
 i1b = maxIndex;
 i1a = 0;

 while (M[i1a]<yy1){
 i1a++;
 }

 i1 = i1a+((i1b-i1a)/2);
 i0 = i1 - dix;
 i2 = i1 + dix;

 yy0 = M[i0];
 yy2 = M[i2];

 yf0 = (float)(yy0);
 yf1 = (float)(yy1);
 yf2 = (float)(yy2);

 nx = (yf0-yf2)/(2.0*(yf0-(2.0*yf1)+yf2));
 dx = nx*dix*tx;
 tmax = i1*tx;

 T2 = tmax+dx;
 imax = (unsigned int)(T2/tx);

 IEC0.T1IE = 1;
 TMR1 = 0;
 T1IF_bit = 0;
 T1CON.TON = 1;
 bm = 3;

 }

 while(bm!=4);
}



void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
 RB3_bit = ~RB3_bit;
 if (bm==0){
 SAMP_bit = 0;
 while (!AD1CON1bits.DONE);
 if (i<nm){
 M[i] = ADC1BUF0;
 i++;
 } else {
 bm = 1;
 T1CON.TON = 0;
 IEC0.T1IE = 0;
 }
 }

 if (bm==3) {
 if (j<nm){

 j++;
 } else {
 bm = 4;
 T1CON.TON = 0;
 IEC0.T1IE = 0;
 }
 }
 T1IF_bit = 0;
}

void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
 if (contp<10){
 RB2_bit = ~RB2_bit;
 }else {
 RB2_bit = 0;

 if (contp==110){
 IEC0.T2IE = 0;
 T2CON.TON = 0;
 IEC0.T1IE = 1;
 TMR1 = 0;
 T1IF_bit = 0;
 T1CON.TON = 1;
 bm=0;
 }

 }
 contp++;
 T2IF_bit = 0;
}



void Configuracion(){


 CLKDIVbits.PLLPRE = 0;
 PLLFBD = 38;
 CLKDIVbits.PLLPOST = 0;


 AD1PCFGL = 0xFFFD;
 TRISA0_bit = 1;
 TRISA4_bit = 1;
 TRISB = 0xFF00;


 AD1CON1.AD12B = 0;
 AD1CON1bits.FORM = 0x00;
 AD1CON1.SIMSAM = 0;
 AD1CON1.ADSIDL = 0;
 AD1CON1.ASAM = 1;
 AD1CON1bits.SSRC = 0x00;

 AD1CON2bits.VCFG = 0;
 AD1CON2bits.CHPS = 0;
 AD1CON2.CSCNA = 0;
 AD1CON2.BUFM = 0;
 AD1CON2.ALTS = 0x00;

 AD1CON3.ADRC = 0;
 AD1CON3bits.ADCS = 0x02;
 AD1CON3bits.SAMC = 0x02;

 AD1CHS0.CH0NB = 0;
 AD1CHS0bits.CH0SB = 0x01;
 AD1CHS0.CH0NA = 0;
 AD1CHS0bits.CH0SA = 0x01;

 AD1CHS123 = 0;

 AD1CSSL = 0x00;

 AD1CON1.ADON = 1;


 T1CON = 0x8000;
 IEC0.T1IE = 0;
 T1IF_bit = 0;
 PR1 = 200;


 T2CON = 0x8000;
 IEC0.T2IE = 0;
 T2IF_bit = 0;
 PR2 = 500;


 IPC0bits.T1IP = 0x07;
 IPC1bits.T2IP = 0x06;


 RPINR18bits.U1RXR = 0x07;
 RPOR3bits.RP6R = 0x03;

}



void main() {

 Configuracion();

 UART1_Init(9600);
 Delay_ms(100);

 while(1){

 UART1_Write(0x00);
 UART1_Write(0x0D);

 Pulse();

 for (j=0;j<nm;j++){
 while(UART_Tx_Idle()==0);
 TT2 = M[j];
 chT2 = (unsigned char *) & TT2;
 for (l=0;l<2;l++){
 trama[l]=(*chT2++);
 }
 for (l=1;l>=0;l--){
 UART1_Write(trama[l]);
 }
 UART1_Write(0x0D);
 }

 UART1_Write(0x00);
 UART1_Write(0x0D);

 Delay_ms(10);

 }

}
