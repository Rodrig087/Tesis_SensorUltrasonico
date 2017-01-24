#line 1 "D:/Git/Tesis_SensorUltrasonico/DSP/ADC_DAC.c"
#line 14 "D:/Git/Tesis_SensorUltrasonico/DSP/ADC_DAC.c"
const float ca1 = 0.002080567135492;
const float ca2 = 0.004161134270985;
const float cb2 = -1.866892279711715;
const float cb3 = 0.875214548253684;


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

const unsigned int nm = 300;
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
float TOF;

char txt1[6], txt2[6], txt3[6], txt4[6] ;




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
#line 133 "D:/Git/Tesis_SensorUltrasonico/DSP/ADC_DAC.c"
 T1IF_bit = 0;
}

void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{

 if (contp<20){
 RB14_bit = ~RB14_bit;
 }else {
 RB14_bit = 0;
 IEC0.T2IE = 0;
 T2CON.TON = 0;
 IEC0.T1IE = 1;
 TMR1 = 0;
 T1CON.TON = 1;
 IEC0.AD1IE = 1;
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
 TRISB14_bit = 0;



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


 IPC3bits.AD1IP = 0x06;
 IPC0bits.T1IP = 0x07;
 IPC1bits.T2IP = 0x05;

}



void main() {

 Configuracion();

 Lcd_init();
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);

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


 if (bm==1){

 Velocidad();

 for (k=0;k<nm;k++){


 value = M[k]&0x01FF;
 if (M[k]<512){
 value = (M[k]+((512-M[k])*2))&0x01FE;
 }


 if (value>5){
 if (value>aux_value){
 aux_value=value;
 }
 else{
 aux_value=aux_value-5;
 if (aux_value<0){
 aux_value=value;
 }
 }
 }else{
 aux_value=0;
 }


 x0 = (float)(aux_value);
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

 TOF = (tmax)+dx;

 FloatToStr(nx, txt1);
 FloatToStr(dx, txt2);
 FloatToStr(tmax, txt3);
 FloatToStr(TOF, txt4);

 Lcd_Out(1,1,"nx: ");
 Lcd_Out_Cp(txt1);
 Lcd_Out(2,1,"dx: ");
 Lcd_Out_Cp(txt2);
 Lcd_Out(3,1,"tmax: ");
 Lcd_Out_Cp(txt3);
 Lcd_Out(4,1,"TOF: ");
 Lcd_Out_Cp(txt4);

 Delay_ms(1);

 bm = 0;

 }

 Delay_ms(10);
 }

}
