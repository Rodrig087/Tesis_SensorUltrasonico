#line 1 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/Splitter/Splitter.c"
#line 13 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/Splitter/Splitter.c"
const short Psize = 6;
const short Rsize = 6;
const short Hdr = 0x3A;
const short End = 0x0D;
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];
short ir, irr, ip, ipp;
unsigned short BanLP, BanLR;
unsigned short BanAR, BanAP;
unsigned short ByRspt, ByPtcn;



void interrupt(void){

 if(PIR1.F5==1){
 RC4_bit = 1;
 ByPtcn = UART1_Read();
 if ((ByPtcn==Hdr)&&(ip==0)){
 BanAP = 1;
 Ptcn[ip] = ByPtcn;
 }
 if ((ByPtcn!=Hdr)&&(ip==0)){
 ip=-1;
 }
 if ((BanAP==1)&&(ip!=0)){
 Ptcn[ip] = ByPtcn;
 }
 ip++;
 if (ip==Psize){
 BanLP = 1;
 BanAP = 0;
 ip=0;
 }
 RC4_bit = 0;
 PIR1.F5 = 0;
 }

 if (PIR3.F5==1){
 RB4_bit = 1;
 ByRspt = UART2_Read();
 if ((ByRspt==Hdr)&&(ir==0)){
 BanAR = 1;
 Rspt[ir] = ByRspt;
 }
 if ((ByRspt!=Hdr)&&(ir==0)){
 ir=-1;
 }
 if ((BanAR==1)&&(ir!=0)){
 Rspt[ir] = ByRspt;
 }
 ir++;
 if (ir==Rsize){
 BanLR = 1;
 BanAR = 0;
 ir=0;
 }
 RB4_bit = 0;
 PIR3.F5 = 0;
 }


}


void Configuracion(){

 ANSELB = 0;
 ANSELC = 0;

 TRISB5_bit = 0;
 TRISC5_bit = 0;
 TRISB4_bit = 0;
 TRISC4_bit = 0;

 INTCON.GIE = 1;
 INTCON.PEIE = 1;


 PIE1.RC1IE = 1;
 PIR1.F5 = 0;
 PIE3.RC2IE = 1;
 PIR3.F5 = 0;


 UART1_Init(9600);
 UART2_Init(9600);
 Delay_ms(100);

}

void main() {

 Configuracion();
 RC5_bit = 0;
 RB5_bit = 0;
 ip=0;
 ir=0;

 while (1){

 if (BanLP==1){

 if ((Ptcn[0]==Hdr)&&(Ptcn[Psize-1]==End)){

 RB5_bit = 1;

 for (ipp=0;ipp<(Psize);ipp++){
 UART2_Write(Ptcn[ipp]);
 }

 while(UART2_Tx_Idle()==0);
 RB5_bit = 0;

 for (ipp=0;ipp<(Psize);ipp++){
 Ptcn[ipp]=0;;
 }

 BanLP = 0;


 } else {

 for (ipp=0;ipp<(Psize-1);ipp++){
 Ptcn[ipp]=0;;
 }

 BanLP = 0;

 }

 }


 if (BanLR==1){

 if ((Rspt[0]==Hdr)&&(Rspt[Rsize-1]==End)){

 RC5_bit = 1;

 for (irr=0;irr<(Rsize);irr++){
 UART1_Write(Rspt[irr]);
 }

 while(UART1_Tx_Idle()==0);
 RC5_bit = 0;

 for (irr=0;irr<(Rsize);irr++){
 Rspt[irr]=0;;
 }

 BanLR = 0;


 } else {

 for (irr=0;irr<(Rsize-1);irr++){
 Rspt[irr]=0;;
 }
 BanLR = 0;

 }

 }


 }
}
