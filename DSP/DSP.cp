#line 1 "D:/Git/Tesis_SensorUltrasonico/DSP/DSP.c"
#line 13 "D:/Git/Tesis_SensorUltrasonico/DSP/DSP.c"
unsigned int contp;

float TOF, Df;
float DSTemp, VSnd;

unsigned short BS;

char txt1[8], txt2[8];




sbit LCD_RS at LATA4_bit;
sbit LCD_EN at LATB7_bit;
sbit LCD_D4 at LATB8_bit;
sbit LCD_D5 at LATB9_bit;
sbit LCD_D6 at LATB14_bit;
sbit LCD_D7 at LATB15_bit;
sbit LCD_RS_Direction at TRISA4_bit;
sbit LCD_EN_Direction at TRISB7_bit;
sbit LCD_D4_Direction at TRISB8_bit;
sbit LCD_D5_Direction at TRISB9_bit;
sbit LCD_D6_Direction at TRISB14_bit;
sbit LCD_D7_Direction at TRISB15_bit;


sbit Chip_Select at LATB1_bit;
sbit Chip_Select_Direction at TRISB1_bit;




void Velocidad(){
 unsigned int Temp;
 unsigned int Rint;
 float Rfrac;

 Ow_Reset(&PORTB, 4);
 Ow_Write(&PORTB, 4, 0xCC);
 Ow_Write(&PORTB, 4, 0x44);
 Delay_us(100);

 Ow_Reset(&PORTB, 4);
 Ow_Write(&PORTB, 4, 0xCC);
 Ow_Write(&PORTB, 4, 0xBE);
 Delay_us(100);

 Temp = Ow_Read(&PORTB, 4);
 Temp = (Ow_Read(&PORTB, 4) << 8) + Temp;

 if (Temp & 0x8000) {
 Temp = 0;
 }

 Rint = Temp >> 4;
 Rfrac = ((Temp & 0x000F) * 625) / 10000.;
 DSTemp = Rint + Rfrac;

 VSnd = 331.45 * sqrt(1+(DsTemp/273));
}


void DAC_Output(unsigned int valueDAC) {
 char temp;

 Chip_Select = 0;


 temp = (valueDAC >> 8) & 0x0F;
 temp |= 0x30;
 SPI1_Write(temp);


 temp = valueDAC;
 SPI1_Write(temp);

 Chip_Select = 1;
}





void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
 if (contp<20){
 BS = ~BS;
 RB0_bit = BS;
 }else {
 RB0_bit = 0;
 T1CON.TON = 0;
 }

 contp++;
 T1IF_bit = 0;
}


void ADC1Int() org IVT_ADDR_ADC1INTERRUPT {
 DAC_Output(ADC1BUF0);
 AD1IF_bit = 0;
}



void Configuracion(){


 CLKDIVbits.PLLPRE = 0;
 PLLFBD = 41;
 CLKDIVbits.PLLPOST = 0;


 TRISB0_bit = 0;
 TRISA0_bit = 1;
 LATB0_bit = 0;


 T1CON = 0x8000;
 T1IE_bit = 1;
 T1IF_bit = 0;
 IPC0bits.T1IP = 0x01;
 PR1 = 495;


 AD1CON1.AD12B = 0;
 AD1CON1bits.SSRC = 0x07;
 AD1CON1bits.FORM = 0x01;
 AD1CON1.ASAM = 0;
 AD1CON1.SIMSAM = 0;
 AD1CON1.ADSIDL = 0;

 AD1CON2bits.VCFG = 0;
 AD1CON2bits.CHPS = 0x00;
 AD1CON2.CSCNA = 0;
 AD1CON2bits.SMPI = 0;
 AD1CON2.BUFM = 0;
 AD1CON2.ALTS = 0x00;

 AD1CON3.ADRC = 0;
 AD1CON3bits.ADCS = 0x02;
 AD1CON3bits.SAMC = 0;

 AD1CHS0 = 0;
 AD1CHS123 = 0;

 AD1PCFGL = 0xFFFE;
 AD1CSSL = 0x00;

 IEC0.AD1IE = 0x00;
 IPC3bits.AD1IP = 1;

 AD1CON1.ADON = 1;


 SPI1_Init();


 BS = 0;
 contp = 0;
#line 180 "D:/Git/Tesis_SensorUltrasonico/DSP/DSP.c"
}


void main(){

 Configuracion();


 while (1){

 Velocidad();

 T1CON.TON = 1;
 contp = 0;
 BS = 0;

 DAC_Output(ADC1BUF0);

 Delay_ms(15);

 }

}
