#line 1 "D:/Git/Tesis_SensorUltrasonico/DSP/ADC_DAC.c"
#line 16 "D:/Git/Tesis_SensorUltrasonico/DSP/ADC_DAC.c"
unsigned int contp;
unsigned short BS;

float DSTemp, VSnd;

unsigned int value = 0;
unsigned int aux_value = 0;

unsigned int VM=0;




void Envolvente() {

 if (ADC1BUF0>512){
 value = (ADC1BUF0-512);
 }
 if (ADC1BUF0==512){
 value = 0;
 }
 if (ADC1BUF0==0){
 value = 0;
 }
 if (ADC1BUF0<512){
 value = (ADC1BUF0+((512-ADC1BUF0)*2))-513;
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

 LATB = aux_value;
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
 Envolvente();
 AD1IF_bit = 0;
}

void Timer1Int() org IVT_ADDR_T1INTERRUPT {
 SAMP_bit = 0;
 T1IF_bit = 0;
}

void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
 if (contp<20){
 BS = ~BS;
 RB14_bit = BS;
 }else {
 RB14_bit = 0;
 IEC0.T2IE = 0;
 IEC0.T1IE = 1;
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
 TRISA1_bit = 1;
 TRISB = 0x8000;


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

 IEC0.AD1IE = 0x01;

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

 while(1){
 Velocidad();

 T2CON.TON = 1;
 IEC0.T2IE = 1;

 contp = 0;
 BS = 0;

 Delay_ms(15);
 }

}
