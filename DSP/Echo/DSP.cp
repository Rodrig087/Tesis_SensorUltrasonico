#line 1 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/Echo/DSP.c"
#line 11 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/Echo/DSP.c"
unsigned int contp;
unsigned short ie;
const short delay_p = 120;
const short np = 5;

void Interrupt(){


 if (TMR2IF_bit){
 if (ie==1){
 if ((contp>(delay_p))&&(contp<(delay_p+(np*2)))){
 RD0_bit = ~RD0_bit;
 }
 if (contp==(delay_p+(np*2))){
 TMR2ON_bit=0;
 RD0_bit = 0;
 ie = 0;
 contp = 0;
 }
 }
 contp++;
 TMR2IF_bit = 0;
 }


 if (INTCON.INT0IF == 1){
 if (ie==0){
 TMR2ON_bit=1;
 RD1_bit = ~RD1_bit;
 }
 ie = 1;
 INTCON.INT0IF = 0;
 }

}

void Configuracion() {

 INTCON.GIE = 1;
 INTCON.PEIE = 1;

 INTCON.INT0IE = 1;
 INTCON2.RBPU = 1;
 INTCON2.INTEDG0 = 1;

 ADCON1 = 0b00001111;
 CMCON = 0b00000111;

 T2CON = 0x00;
 PIE1.TMR2IE = 1;
 PR2 = 149;


 TRISD0_bit = 0;
 TRISD1_bit = 0;

 ie = 0;

}


void main() {

 Configuracion();
}
