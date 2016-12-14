#line 1 "D:/Git/Tesis_SensorUltrasonico/DSP/DSP.c"
#line 11 "D:/Git/Tesis_SensorUltrasonico/DSP/DSP.c"
unsigned int contp;

float TOF, Df, VSnd;
float DSTemp;

unsigned short BS;


void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
 if (contp<20){
 BS = ~BS;
 RB0_bit = BS;
 }else {
 RB0_bit = 0;
 TON_bit = 0;
 }

 contp++;
 T1IF_bit = 0;
}


void Velocidad(){
 unsigned int Temp;
 unsigned int Rint;
 float Rfrac;

 Ow_Reset(&PORTB, 1);
 Ow_Write(&PORTB, 1, 0xCC);
 Ow_Write(&PORTB, 1, 0x44);
 Delay_us(120);

 Ow_Reset(&PORTB, 1);
 Ow_Write(&PORTB, 1, 0xCC);
 Ow_Write(&PORTB, 1, 0xBE);

 Temp = Ow_Read(&PORTB, 1);
 Temp = (Ow_Read(&PORTB, 1) << 8) + Temp;

 if (Temp & 0x8000) {
 Temp = 0;
 }

 Rint = Temp >> 4;
 Rfrac = ((Temp & 0x000F) * 625) / 10000.;
 DSTemp = Rint + Rfrac;

 VSnd = 331.45 * sqrt(1+(DsTemp/273));
}


void MainInit(){


 CLKDIVbits.PLLPRE = 0;
 PLLFBD = 38;
 CLKDIVbits.PLLPOST = 0;


 TRISB = 0;
 LATB = 0;


 TON_bit = 1;
 T1IE_bit = 1;
 T1IF_bit = 0;
 IPC0 = IPC0 | 0x1000;
 PR1 = 500;


 BS = 0;
 contp = 0;


}

void main(){

 MainInit();

 while (1){

 Velocidad();

 TON_bit = 1;
 contp = 0;
 BS = 0;
 Delay_ms(15);

 }

}
