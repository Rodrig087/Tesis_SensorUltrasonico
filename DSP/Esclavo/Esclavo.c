/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 07/07/2017
Ultima modificacion: 07/07/2017
Configuracion: PIC18F25k22 XT=8MHz
Descripcion:

---------------------------------------------------------------------------------------------------------------------------*/

//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables para la peticion y respuesta de datos
unsigned int Id;                                        //Identificador de esclavo
const short Psize = 6;                                  //Constante de longitud de trama de Peticion
const short Rsize = 6;                                  //Constante de longitud de trama de Respuesta
const short Hdr = 0x3A;                                 //Constante de delimitador de inicio de trama (0x3A)
const short End = 0x0D;                                 //Constante de delimitador de final de trama (0x0D)
unsigned char Ptcn[Psize];                              //Trama de peticion
unsigned char Rspt[Rsize];                              //Trama de respuesta
unsigned short ir, ip, ipp;                             //Subindices para las tramas de peticion y respuesta
unsigned short BanP, BanT;                              //Bandera de peticion de datos
unsigned short Fcn;                                     //Variable para el tipo de funcion
unsigned int DatoPtcn;                                  //Variable para el Dato de la peticion
unsigned short *chDP;                                   //Variable tipo puntero para el dato de peticion
unsigned short Dato;                                    //Variable para almacenar los datos que recibe por Uart

//Variables para el calculo de la temperatura y la humedad
unsigned int ITemp, IHmd, Sum;                          //Variables tipo entero para los datos de temperatura y humedad
unsigned char *chTemp, *chHmd;                          //Variables tipo puntero para la Temperatura, Caudal y factor de calibracion
unsigned char  Check, T_byte1, T_byte2, RH_byte1, RH_byte2;


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(void){
//Interrupcion UART1
     if(PIR1.F5==1){

        if (UART1_Data_Ready()==1){
           Dato = UART1_Read();
        }
        if ((Dato==Hdr)&&(ip==0)){                       //Verifica que el primer dato en llegar sea el identificador de inicio de trama
           BanT = 1;                                     //Activa la bandera de trama
           Ptcn[ip] = Dato;                              //Almacena el Dato en la trama de peticion
        }
        if ((Dato!=Hdr)&&(ip==0)){                       //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
           ip=-1;                                        //Si es asi: reduce el subindice en una unidad
        }
        if ((BanT==1)&&(ip!=0)){
           Ptcn[ip] = Dato;                              //Almacena el resto de datos en la trama de peticion si la bandera de trama esta activada
        }
        ip++;                                            //Aumenta el subindice una unidad
        if (ip==Psize){                                  //Verifica que se haya terminado de llenar la trama de datos
           BanP = 1;                                     //Habilita la bandera de lectura de datos
           BanT = 0;
           ip=0;                                         //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
        }

        PIR1.F5 = 0;                                     //Limpia la bandera de interrupcion de UART1
     }
}

// Funciones //

void StartSignal(){
     TRISB4_bit = 0;                                     //Configure RD0 as output
     RB4_bit = 0;                                        //RD0 sends 0 to the sensor
     delay_ms(18);
     RB4_bit = 1;                                        //RD0 sends 1 to the sensor
     delay_us(30);
     TRISB4_bit = 1;                                     //Configure RD0 as input
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
           while(!RB4_bit);                              //Espera hasta RB4 pase a alto
           delay_us(30);
           if(RB4_bit == 0){
                i&= ~(1<<(7 - j));                       //Clear bit (7-b)
           }else {
                i|= (1 << (7 - j));                      //Set bit (7-b)
                while(RB4_bit);                          //Espera hasta RB4 pase a bajo
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
     
                     if (ITemp > 0X8000){                //Temperatura negativa
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
     
     chTemp = (unsigned char *) & ITemp;                 //Asocia el valor calculado de Temperatura al puntero chTemp
     chHmd = (unsigned char *) & IHmd;                   //Asocia el valor calculado de Temperatura al puntero chTemp

}

void Responder(unsigned int Reg){

     if (Reg==0x01){
        for (ir=4;ir>=3;ir--){
            Rspt[ir]=(*chTemp++);                        //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Temperatura calculada
        }
     }
     
     if (Reg==0x02){
        for (ir=4;ir>=3;ir--){
            Rspt[ir]=(*chHmd++);                         //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Humedad calculada
        }
     }
     
     Rspt[2]=Ptcn[2];                                    //Rellena el byte 2 con el tipo de funcion de la trama de peticion

     RC5_bit = 1;                                        //Establece el Max485 en modo de escritura

     for (ir=0;ir<Rsize;ir++){
         UART1_Write(Rspt[ir]);                          //Envia la trama de respuesta
     }
     while(UART1_Tx_Idle()==0);                          //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     
     RC5_bit = 0;                                        //Establece el Max485 en modo de lectura

     for (ir=3;ir<5;ir++){
         Rspt[ir]=0;;                                    //Limpia la trama de respuesta
     }

}

// Configuracion //
void Configuracion(){

     ANSELA = 0;                                       //Configura PORTA como digital
     ANSELB = 0;                                       //Configura PORTB como digital
     ANSELC = 0;                                       //Configura PORTC como digital

     TRISA = 1;                                        //Configura el puerto A como entrada
     TRISC4_bit = 0;                                   //Configura el pin C4 como salida
     TRISC5_bit = 0;                                   //Configura el pin C5 como salida
     TRISC0_bit = 1;                                   //Configura el pin C0 como entrada
     TRISC1_bit = 1;                                   //Configura el pin C1 como entrada


     INTCON.GIE = 1;                                   //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas

     PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
     PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion

     UART1_Init(9600);                                 //Inicializa el UART1 a 9600 bps
     Delay_ms(100);                                    //Espera para que el modulo UART se estabilice

}


void main() {
    
     Configuracion();
     RC5_bit = 0;                                             //Inicia el Max 485 en modo lectura

     //Id = (PORTA&0x3F)+((PORTC&0x03)<<6);
     Id=0x02;
     
     chDP = &DatoPtcn;                                        //Asocia el valor de DatoPtcn al puntero chDP
     ip=0;

     Rspt[0] = Hdr;                                           //Se rellena el primer byte de la trama de respuesta con el delimitador de inicio de trama
     Rspt[1] = Id;                                            //Se rellena el segundo byte de la trama de repuesta con el Id del tipo de sensor
     Rspt[Rsize-1] = End;                                     //Se rellena el ultimo byte de la trama de repuesta con el delimitador de final de trama

     while (1){
     
           //Calcular();
           //Responder(DatoPtcn);
           
           
           if (BanP==1){                                      //Verifica si se realizo una peticion
                 RC4_bit = 1;
                 if ((Ptcn[1]==Id)&&(Ptcn[Psize-1]==End)){    //Verifica el identificador de esclavo y el byte de final de trama

                    Fcn = Ptcn[2];

                    if (Fcn==0x02){                           //02: Lee un registro especicfico (01:Temperatura, 02:Humedad)
                       Calcular();                            //Realiza una secuencia de calculo
                       *chDP = Ptcn[4];                       //Almacena el byte 4 de la trama de peticion en el LSB de la variable DatoPtcn
                       *(chDP+1) = Ptcn[3];                   //Almacena el byte 3 de la trama de peticion en el MSB de la variable DatoPtcn
                       Responder(DatoPtcn);                   //Envia la trama de repuesta con el valor del registro requerido
                    }

                    DatoPtcn = 0;                             //Limpia la variable
                    for (ipp=0;ipp<Psize;ipp++){
                        Ptcn[ipp]=0;                          //Limpia la trama de peticion
                    }
                    BanP = 0;                                 //Limpia la bandera de lectura de datos

                 } else{
                       for (ipp=0;ipp<Psize;ipp++){
                           Ptcn[ipp]=0;                       //Limpia la trama de peticion
                       }
                       BanP = 0;                              //Limpia la bandera de lectura de datos
                 }
                 RC4_bit = 0;
           }
           Delay_ms(50);                                      //Retraso necesario para que la Rpi tenga tiempo de recibir la trama de respuesta
           
     }

}