#line 1 "D:/Git/Tesis_SensorUltrasonico/DSP/ADC_DAC.c"
#line 14 "D:/Git/Tesis_SensorUltrasonico/DSP/ADC_DAC.c"
const float ca1 = 0.006745773600345;
const float ca2 = 0.013491547200690;
const float cb2 = -1.754594315763869;
const float cb3 = 0.781577410165250;



unsigned int contp;

float DSTemp, VSnd;

const unsigned int nm = 365;
unsigned int M[nm];
unsigned int R[nm];
unsigned int i;
unsigned int j;
unsigned int k;
short bm;

unsigned int value = 0;
unsigned int aux_value = 0;

float x0=0, x1=0, x2=0, y0=0, y1=0, y2=0;
unsigned int YY = 0;

unsigned int VMmax=0;
unsigned int VMmin=0;
unsigned int VMmed=0;
unsigned int IndexMax;
unsigned int IndexMin;

short int0_en = 0;




void Envolvente() {

}

void Velocidad(){
 unsigned int Temp;
 unsigned int Rint;
 float Rfrac;

 Ow_Reset(&PORTB, 15);
 Ow_Write(&PORTB, 15, 0xCC);
 Ow_Write(&PORTB, 15, 0x44);
 Delay_us(100);

 Ow_Reset(&PORTB, 15);
 Ow_Write(&PORTB, 15, 0xCC);
 Ow_Write(&PORTB, 15, 0xBE);
 Delay_us(100);

 Temp = Ow_Read(&PORTB, 15);
 Temp = (Ow_Read(&PORTB, 15) << 8) + Temp;

 if (Temp & 0x8000) {
 Temp = 0;
 }

 Rint = Temp >> 4;
 Rfrac = ((Temp & 0x000F) * 625) / 10000.;
 DSTemp = Rint + Rfrac;

 VSnd = 331.45 * sqrt(1+(DsTemp/273));
}




void ADC1Int() org IVT_ADDR_ADC1INTERRUPT {
 IEC0.INT0IE = 0;
 if (i<nm){
 M[i] = ADC1BUF0;
 i++;
 } else {
 bm = 1;
 T1CON.TON = 0;
 IEC0.T1IE = 0;
 }
 AD1IF_bit = 0;
}

void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
 LATA1_bit = ~LATA1_bit;
 if (bm==0){
 SAMP_bit = 0;
 }
 if (bm==1) {
 if (j<nm){
 LATB = (R[j]&0x7F)|((r[j]<<1)&0x700);
 j++;
 } else {
 bm = 0;
 IEC0.T1IE = 0;
 }
 }
 T1IF_bit = 0;
}

void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{

 if (contp<10){
 RB14_bit = ~RB14_bit;
 } else {
 RB14_bit = 0;
 if (contp==104){
 LATA4_bit = ~LATA4_bit;
 IEC0.T2IE = 0;
 T2CON.TON = 0;
 IEC0.AD1IE = 1;
 IEC0.T1IE = 1;
 TMR1 = 0;
 T1CON.TON = 1;
 }
 }
 contp++;
 T2IF_bit = 0;
}



void Configuracion(){


 CLKDIVbits.PLLPRE = 0;
 PLLFBD = 38;
 CLKDIVbits.PLLPOST = 0;


 AD1PCFGL = 0xFFFE;
 TRISA0_bit = 1;
 TRISA1_bit = 0;
 TRISA4_bit = 0;
 TRISB = 0x8080;


 AD1CON1.AD12B = 0;
 AD1CON1bits.FORM = 0x00;
 AD1CON1.SIMSAM = 0;
 AD1CON1.ADSIDL = 0;
 AD1CON1.ASAM = 1;
 AD1CON1bits.SSRC = 0x00;

 AD1CON2bits.VCFG = 0;
 AD1CON2bits.CHPS = 0;
 AD1CON2.CSCNA = 0;
 AD1CON2bits.SMPI = 0x00;
 AD1CON2.BUFM = 0;
 AD1CON2.ALTS = 0x00;

 AD1CON3.ADRC = 0;
 AD1CON3bits.ADCS = 0x02;
 AD1CON3bits.SAMC = 0x02;

 AD1CHS0 = 0;
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


 INTCON2.INT0EP = 0;


 IPC3bits.AD1IP = 0x06;
 IPC0bits.T1IP = 0x07;
 IPC1bits.T2IP = 0x05;
 IPC0bits.INT0IP = 0x04;
}



void main() {

 Configuracion();

 while(1){


 if (bm==0){

 contp = 0;
 RB14_bit = 0;
 IEC0.T2IE = 1;
 TMR2 = 0;
 T2CON.TON = 1;

 i = 0;
 j = 0;

 }


 else {

 Velocidad();


 VMmax = Vector_Max(M, nm, &IndexMax);
 VMmin = Vector_Min(M, nm, &IndexMin);
 VMmed = VMmax-((VMmax-VMmin)/2);

 for (k=0;k<nm;k++){



 value = M[k]-VMmed;
 if (M[k]<VMmed){
 value = (M[k]+((VMmed-M[k])*2))-(VMmed);
 }
#line 249 "D:/Git/Tesis_SensorUltrasonico/DSP/ADC_DAC.c"
 x0 = (float)(value);
 y0 = ((x0+x2)*ca1)+(x1*ca2)-(y1*cb2)-(y2*cb3);

 y2 = y1;
 y1 = y0;
 x2 = x1;
 x1 = x0;

 YY = (unsigned int)(y0);

 R[k] = YY;

 }

 T1CON.TON = 1;
 IEC0.T1IE = 1;

 }

 Delay_ms(10);

 }

}
