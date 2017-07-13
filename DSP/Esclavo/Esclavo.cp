#line 1 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/Esclavo/Esclavo.c"
#line 12 "E:/Milton/Github/Tesis/SensorUltrasonico/DSP/Esclavo/Esclavo.c"
unsigned int Id;
const short Psize = 6;
const short Rsize = 6;
const short Hdr = 0x3A;
const short End = 0x0D;
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];
unsigned short ir, ip, ipp;
unsigned short BanP, BanT;
unsigned short Fcn;
unsigned int DatoPtcn;
unsigned short *chDP;
unsigned short Dato;


unsigned int ITemp, IHmd, Sum;
unsigned char *chTemp, *chHmd;
unsigned char Check, T_byte1, T_byte2, RH_byte1, RH_byte2;



void interrupt(void){

 if(PIR1.F5==1){

 if (UART1_Data_Ready()==1){
 Dato = UART1_Read();
 }
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

 PIR1.F5 = 0;
 }
}



void StartSignal(){
 TRISB4_bit = 0;
 RB4_bit = 0;
 delay_ms(18);
 RB4_bit = 1;
 delay_us(30);
 TRISB4_bit = 1;
}

void CheckResponse(){
 Check = 0;
 delay_us(40);
 if (RB4_bit == 0){
 delay_us(80);
 if (RB4_bit == 1){
 Check = 1;
 delay_us(40);
 }
 }
}

char ReadData(){
 char i, j;
 for(j = 0; j < 8; j++){
 while(!RB4_bit);
 delay_us(30);
 if(RB4_bit == 0){
 i&= ~(1<<(7 - j));
 }else {
 i|= (1 << (7 - j));
 while(RB4_bit);
 }
 }
 return i;
}

void Calcular(){

 StartSignal();
 CheckResponse();
 if(Check == 1){
 RH_byte1 = ReadData();
 RH_byte2 = ReadData();
 T_byte1 = ReadData();
 T_byte2 = ReadData();
 Sum = ReadData();
 if(Sum == ((RH_byte1+RH_byte2+T_byte1+T_byte2) & 0XFF)){
 ITemp = T_byte1;
 ITemp = (ITemp << 8) | T_byte2;
 IHmd = RH_byte1;
 IHmd = (IHmd << 8) | RH_byte2;
 ITemp = ITemp/10;
 IHmd = IHmd/10;

 if (ITemp > 0X8000){
 ITemp = 0;
 IHmd = 0;
 }

 } else {
 ITemp = 100;
 IHmd = 100;
 }
 } else {
 ITemp = 200;
 IHmd = 200;
 }

 chTemp = (unsigned char *) & ITemp;
 chHmd = (unsigned char *) & IHmd;

}

void Responder(unsigned int Reg){

 if (Reg==0x01){
 for (ir=4;ir>=3;ir--){
 Rspt[ir]=(*chTemp++);
 }
 }

 if (Reg==0x02){
 for (ir=4;ir>=3;ir--){
 Rspt[ir]=(*chHmd++);
 }
 }

 Rspt[2]=Ptcn[2];

 RC5_bit = 1;

 for (ir=0;ir<Rsize;ir++){
 UART1_Write(Rspt[ir]);
 }
 while(UART1_Tx_Idle()==0);

 RC5_bit = 0;

 for (ir=3;ir<5;ir++){
 Rspt[ir]=0;;
 }

}


void Configuracion(){

 ANSELA = 0;
 ANSELB = 0;
 ANSELC = 0;

 TRISA = 1;
 TRISC4_bit = 0;
 TRISC5_bit = 0;
 TRISC0_bit = 1;
 TRISC1_bit = 1;


 INTCON.GIE = 1;
 INTCON.PEIE = 1;

 PIE1.RC1IE = 1;
 PIR1.F5 = 0;

 UART1_Init(9600);
 Delay_ms(100);

}


void main() {

 Configuracion();
 RC5_bit = 0;


 Id=0x02;

 chDP = &DatoPtcn;
 ip=0;

 Rspt[0] = Hdr;
 Rspt[1] = Id;
 Rspt[Rsize-1] = End;

 while (1){





 if (BanP==1){
 RC4_bit = 1;
 if ((Ptcn[1]==Id)&&(Ptcn[Psize-1]==End)){

 Fcn = Ptcn[2];

 if (Fcn==0x02){
 Calcular();
 *chDP = Ptcn[4];
 *(chDP+1) = Ptcn[3];
 Responder(DatoPtcn);
 }

 DatoPtcn = 0;
 for (ipp=0;ipp<Psize;ipp++){
 Ptcn[ipp]=0;
 }
 BanP = 0;

 } else{
 for (ipp=0;ipp<Psize;ipp++){
 Ptcn[ipp]=0;
 }
 BanP = 0;
 }
 RC4_bit = 0;
 }
 Delay_ms(50);

 }

}
