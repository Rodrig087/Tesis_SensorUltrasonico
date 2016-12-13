#line 1 "D:/Git/Tesis_SensorUltrasonico/DSP/DSP.c"
#line 12 "D:/Git/Tesis_SensorUltrasonico/DSP/DSP.c"
void MainInit(){


 CLKDIVbits.PLLPRE = 0;
 PLLFBD = 38;
 CLKDIVbits.PLLPOST = 0;


 TRISB = 0;
 LATB = 0;

}

void main()
 {
 MainInit();
 while (1)
 {
 LATB0_bit = ~LATB0_bit;
 Delay_us(10);

 }

}
