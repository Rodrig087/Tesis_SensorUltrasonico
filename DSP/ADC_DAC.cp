#line 1 "D:/Git/Tesis_SensorUltrasonico/DSP/ADC_DAC.c"
#line 14 "D:/Git/Tesis_SensorUltrasonico/DSP/ADC_DAC.c"
const float ca1 = 0.006729715343936;
const float ca2 = 0.013459430687873;
const float cb2 = -1.754901698487196;
const float cb3 = 0.781820559862941;


sbit LCD_RS at LATB0_bit;
sbit LCD_EN at LATB1_bit;
sbit LCD_D4 at LATB2_bit;
sbit LCD_D5 at LATB3_bit;
sbit LCD_D6 at LATB4_bit;
sbit LCD_D7 at LATB5_bit;
sbit LCD_RS_Direction at TRISB0_bit;
sbit LCD_EN_Direction at TRISB1_bit;
sbit LCD_D4_Direction at TRISB2_bit;
sbit LCD_D5_Direction at TRISB3_bit;
sbit LCD_D6_Direction at TRISB4_bit;
sbit LCD_D7_Direction at TRISB5_bit;




unsigned int contp;

float DSTemp, VSnd;

const unsigned int nm = 260;
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

unsigned int VP=0;
unsigned int maxIndex;
unsigned int i0, i1, i2;
float yy0, yy1, yy2;
float nx;
float dx;
float tmax;

unsigned int *puntT1, lsw, msw;
unsigned long T1_e;
float T1, T2;
float TOF, Dst;

char txt1[6], txt2[6], txt3[6], txt4[6] ;




void Velocidad(){
 unsigned int Temp;
 unsigned int Rint;
 float Rfrac;

 Ow_Reset(&PORTA, 1);
 Ow_Write(&PORTA, 1, 0xCC);
 Ow_Write(&PORTA, 1, 0x44);
 Delay_us(100);

 Ow_Reset(&PORTA, 1);
 Ow_Write(&PORTA, 1, 0xCC);
 Ow_Write(&PORTA, 1, 0xBE);
 Delay_us(100);

 Temp = Ow_Read(&PORTA, 1);
 Temp = (Ow_Read(&PORTA, 1) << 8) + Temp;

 if (Temp & 0x8000) {
 Temp = 0;
 }

 Rint = Temp >> 4;
 Rfrac = ((Temp & 0x000F) * 625) / 10000.;
 DSTemp = Rint + Rfrac;

 VSnd = 331.45 * sqrt(1+(DsTemp/273));
}




void Ext_interrupt0() iv IVT_ADDR_INT0INTERRUPT{
 *(puntT1) = TMR2;
 *(puntT1+1) = TMR3HLD;
 TMR3HLD = 0;
 TMR2 = 0;
 LATA4_bit = ~LATA4_bit;
 IEC0.T1IE = 1;
 TMR1 = 0;
 T1CON.TON = 1;
 INT0IF_bit = 0;
 IEC0.INT0IE = 0;
 T2CON.TON = 0;
}

void ADC1Int() org IVT_ADDR_ADC1INTERRUPT {
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
 if (bm==0){
 SAMP_bit = 0;
 }
 T1IF_bit = 0;
}

void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
 if (contp<10){
 RB14_bit = ~RB14_bit;
 }else {
 RB14_bit = 0;

 IEC0.INT0IE = 1;
 INT0IF_bit = 0;
 IEC0.AD1IE = 1;

 T3CON.TON = 0;
 T2CON.TON = 0;
 T2CON.T32 = 1;
 T2CON.TCS = 0;
 T2CON.TGATE = 0;
 T2CONbits.TCKPS = 0b00;
 TMR3 = 0;
 TMR2 = 0;



 PR3 = 0xFFFF;
 PR2 = 0xFFFF;

 T2CON.TON = 1;

 LATA4_bit = ~LATA4_bit;
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

 TRISA4_bit = 0;
 TRISB14_bit = 0;
 TRISB7_bit = 1;


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


 INTCON2.INT0EP = 0;


 IPC3bits.AD1IP = 0x06;
 IPC0bits.T1IP = 0x07;
 IPC1bits.T2IP = 0x05;
 IPC0bits.INT0IP = 0x04;

}



void main() {

 Configuracion();

 puntT1 = &T1_e;

 Lcd_init();
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);

 while(1){


 if (bm==0){

 contp = 0;
 RB14_bit = 0;
 T2CON.TON = 0;
 T2CON = 0x0000;
 TMR2 = 0;
 PR2 = 500;
 IEC0.T2IE = 1;
 T2CON.TON = 1;

 i = 0;
 j = 0;

 }


 if (bm==1){

 for (k=0;k<nm;k++){


 value = M[k]&0x01FF;
 if (M[k]<512){
 value = (M[k]+((512-M[k])*2))&0x01FE;
 }


 x0 = (float)(value);
 y0 = ((x0+x2)*ca1)+(x1*ca2)-(y1*cb2)-(y2*cb3);

 y2 = y1;
 y1 = y0;
 x2 = x1;
 x1 = x0;

 YY = (unsigned int)(y0);
 R[k] = YY;

 bm = 2;

 }

 }


 if (bm==2){

 DSTemp = 0.0;
 VSnd = 0.0;
 Velocidad();

 yy0 = 0.0;
 yy1 = 0.0;
 yy2 = 0.0;
 nx = 0.0;
 dx = 0.0;

 yy1 = Vector_Max(R, nm, &maxIndex);
 i1 = maxIndex;
 i0 = i1 - 10;
 i2 = i1 + 10;
 yy0 = R[i0];
 yy2 = R[i2];

 nx = (yy0-yy2)/(2.0*(yy0-(2.0*yy1)+yy2));
 dx = nx * 50.0;
 tmax = ((float)(i1))*5.0;

 T2 = (tmax)+dx;

 bm = 3;

 }

 if (bm==3){


 T1 = T1_e * 0.025;
 TOF = T1 + T2;
 Dst = VSnd * (TOF / 20000.0);

 FloatToStr(TOF, txt1);
 FloatToStr(Dst, txt2);

 Lcd_Out(1,1,"TOF: ");
 Lcd_Out_Cp(txt1);
 Lcd_Out(2,1,"Dst: ");
 Lcd_Out_Cp(txt2);

 Delay_ms(1);

 bm = 0;

 }
 Delay_ms(10);
 }

}
