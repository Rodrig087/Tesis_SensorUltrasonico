#line 1 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/dsPIC/ADC_DAC.c"
#line 9 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/dsPIC/ADC_DAC.c"
const float ca1 = 0.004482805534581;
const float ca2 = 0.008965611069163;
const float cb2 = -1.801872917973333;
const float cb3 = 0.819804140111658;



short TpId;
short TP;
short Id;
const short Psize = 4;
const short Rsize = 6;
const short Hdr = 0xEE;
const short End = 0xFF;
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];
unsigned short ir, ip, ipp;
unsigned short BanP, BanT;
const short Nsm=3;
unsigned short Dato;


unsigned int contp;

float DSTemp, VSnd;

const unsigned int nm = 350;
unsigned int M[nm];
unsigned int i;
unsigned int k;
short bm;

unsigned int value = 0;
unsigned int aux_value = 0;

float x0=0, x1=0, x2=0, y0=0, y1=0, y2=0;
unsigned int YY = 0;

unsigned int Mmax=0;
unsigned int Mmin=0;
unsigned int Mmed=0;
unsigned int MIndexMax;
unsigned int MIndexMin;
unsigned int maxIndex;
unsigned int i0, i1, i2, imax;
unsigned int i1a, i1b;
const short dix=16;
const float tx=5.0;
int yy0, yy1, yy2;
float yf0, yf1, yf2;
float nx, dx, tmax;

short conts;
float T2a, T2b;
const float T2umb = 3.0;
const float T1 = 1375.0;
const float T2adj = 479.0;
float T2sum,T2prom;
float T2, TOF, Dst;
unsigned int IDst;
unsigned char *chIDst;

long TT2;
unsigned char *chTT2;




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
 RB0_bit = 0;

 T1CON.TON = 0;
 IEC0.T1IE = 0;

 TMR2 = 0;
 IEC0.T2IE = 1;
 T2CON.TON = 1;

 i = 0;


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


 x0 = (float)(value);
 y0 = ((x0+x2)*ca1)+(x1*ca2)-(y1*cb2)-(y2*cb3);

 y2 = y1;
 y1 = y0;
 x2 = x1;
 x1 = x0;

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

 }

}


void Distancia(){

 conts = 0;
 T2sum = 0.0;
 T2prom = 0.0;
 T2a = 0.0;
 T2b = 0.0;

 while (conts<Nsm){
 Pulse();
 T2b = T2;
 if ((T2b-T2a)<=T2umb){
 T2sum = T2sum + T2b;
 conts++;
 }
 T2a = T2b;
 }

 T2prom = T2sum/Nsm;

 Velocidad();


 TOF = (T1+T2prom-T2adj)/2.0e6;
 Dst = VSnd * TOF * 1000.0;

 IDst = (unsigned int)(Dst);
 chIDst = (unsigned char *) & IDst;

 for (ir=3;ir<5;ir++){
 Rspt[ir]=(*chIDst++);
 }

}



void UART1Interrupt() iv IVT_ADDR_U1RXINTERRUPT {

 Dato = UART1_Read();

 if ((Dato==Hdr)&&(ip==0)){
 BanT = 1;
 Ptcn[ip] = Dato;
 }
 if ((Dato!=Hdr)&&(ip==0)){
 ip=-1;
 }
 if ((BanT==1)&&(ip!=0)){
 Ptcn[ip] = Dato;
 }

 ip++;
 if (ip==Psize){
 BanP = 1;
 BanT = 0;
 ip=0;
 }

 U1RXIF_bit = 0;

}


void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{

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
 T1IF_bit = 0;
}


void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
 if (contp<10){
 RB0_bit = ~RB0_bit;
 }else {
 RB0_bit = 0;

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
 TRISA1_bit = 1;
 TRISB = 0xFF80;


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


 RPINR18bits.U1RXR = 0x07;
 RPOR3bits.RP6R = 0x03;
 IEC0.U1RXIE = 1;
 U1RXIF_bit = 0;



 IPC0bits.T1IP = 0x06;
 IPC1bits.T2IP = 0x05;
 IPC2bits.U1RXIP = 0x07;



}



void main() {

 Configuracion();

 UART1_Init(9600);
 Delay_ms(100);
 RB5_bit = 0;
#line 378 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/dsPIC/ADC_DAC.c"
 ip=0;

 TP = 0x01;
 Id = 0x07;

 Rspt[0] = Hdr;
 Rspt[1] = Tp;
 Rspt[2] = Id;
 Rspt[Rsize-1] = End;

 while(1){

 if (BanP==1){
 if ((Ptcn[0]==Hdr)&&(Ptcn[Psize-1]==End)){
 if ((Ptcn[1]==Tp)&&(Ptcn[2]==Id)){

 Distancia();

 RB5_bit = 1;
 for (ir=0;ir<Rsize;ir++){
 UART1_Write(Rspt[ir]);
 }
 while(UART1_Tx_Idle()==0);
 RB5_bit = 0;

 for (ipp=0;ipp<Psize;ipp++){
 Ptcn[ipp]=0;
 }
 for (ipp=3;ipp<5;ipp++){
 Rspt[ipp]=0;;
 }

 BanP = 0;

 }
 }else{
 for (ipp=0;ipp<Psize;ipp++){
 Ptcn[ipp]=0;
 }
 BanP = 0;
 }
 }



 Delay_ms(10);

 }

}
