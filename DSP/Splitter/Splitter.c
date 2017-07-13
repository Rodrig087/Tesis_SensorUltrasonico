/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 21/02/2017
Ultima modificacion: 21/02/2017
Configuracion: PIC18F25k22 XT=20MHz
Descripcion:

---------------------------------------------------------------------------------------------------------------------------*/


//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables para la peticion y respuesta de datos
const short Psize = 6;                                  //Constante de longitud de trama de Peticion
const short Rsize = 6;                                  //Constante de longitud de trama de Respuesta
const short Hdr = 0x3A;                                 //Constante de delimitador de inicio de trama
const short End = 0x0D;                                 //Constante de delimitador de final de trama
unsigned char Ptcn[Psize];                              //Vector de trama de peticion
unsigned char Rspt[Rsize];                              //Vector de trama de respuesta
short ir, irr, ip, ipp;                                 //Subindices para las tramas de peticion y respuesta
unsigned short BanLP, BanLR;                            //Banderas de lectura de tramas de peticion y respuesta
unsigned short BanAR, BanAP;                            //Banderas de almacenamiento de tramas de peticion y respuesta
unsigned short ByRspt, ByPtcn;                          //Bytes de peticion y respuesta


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
void interrupt(void){
//Interrupcion UART1
     if(PIR1.F5==1){
        RC4_bit = 1;
        ByPtcn = UART1_Read();                     //Lee el byte de peticion
        if ((ByPtcn==Hdr)&&(ip==0)){               //Verifica que el primer dato en llegar sea el identificador de inicio de trama
           BanAP = 1;                              //Activa la bandera de almacenamiento de trama de peticion
           Ptcn[ip] = ByPtcn;                      //Almacena el Dato en la trama de peticion
        }
        if ((ByPtcn!=Hdr)&&(ip==0)){               //Verifica si el primer dato en llegar es diferente del identificador del inicio de trama
           ip=-1;                                  //Si es asi, reduce el subindice en una unidad
        }
        if ((BanAP==1)&&(ip!=0)){
           Ptcn[ip] = ByPtcn;                      //Almacena el resto de datos en la trama de peticion si la bandera de almacenamiento de trama esta activada
        }
        ip++;                                      //Aumenta el subindice una unidad
        if (ip==Psize){                            //Verifica que se haya terminado de llenar la trama de peticion
           BanLP = 1;                              //Habilita la bandera de lectura de peticion
           BanAP = 0;                              //Limpia la bandera de almacenamiento de trama de peticion
           ip=0;                                   //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
        }
        RC4_bit = 0;
        PIR1.F5 = 0;                               //Limpia la bandera de interrupcion de UART1
     }
//Interrupcion UART2
     if (PIR3.F5==1){
        RB4_bit = 1;
        ByRspt = UART2_Read();                     //Lee el byte de respuesta
        if ((ByRspt==Hdr)&&(ir==0)){               //Verifica que el primer dato en llegar sea el identificador de inicio de trama
           BanAR = 1;                              //Activa la bandera de almacenamiento de trama de respuesta
           Rspt[ir] = ByRspt;                      //Almacena el Dato en la trama de respuesta
        }
        if ((ByRspt!=Hdr)&&(ir==0)){               //Verifica si el primer dato en llegar es diferente del identificador del inicio de trama
           ir=-1;                                  //Si es asi, reduce el subindice en una unidad
        }
        if ((BanAR==1)&&(ir!=0)){
           Rspt[ir] = ByRspt;                      //Almacena el resto de datos en la trama de respuesta si la bandera de almacenamiento de trama esta activada
        }
        ir++;                                      //Aumenta el subindice una unidad
        if (ir==Rsize){                            //Verifica que se haya terminado de llenar la trama de respuesta
           BanLR = 1;                              //Habilita la bandera de lectura de respuesta
           BanAR = 0;                              //Limpia la bandera de almacenamiento de trama de respuesta
           ir=0;                                   //Limpia el subindice de la trama de respuesta para permitir una nueva secuencia de recepcion de datos
        }
        RB4_bit = 0;
        PIR3.F5 = 0;                               //Limpia la bandera de interrupcion de UART2
     }


}

// Configuracion //
void Configuracion(){

     ANSELB = 0;                                       //Configura PORTB como digital
     ANSELC = 0;                                       //Configura PORTC como digital

     TRISB5_bit = 0;                                   //Configura el pin B5 como salida
     TRISC5_bit = 0;                                   //Configura el pin C5 como salida
     TRISB4_bit = 0;                                   //Configura el pin B5 como salida
     TRISC4_bit = 0;                                   //Configura el pin C5 como salida

     INTCON.GIE = 1;                                   //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
     //INTCON.RBIF = 0;                     //Revisar> NPI por que puse esto
     
     PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
     PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
     PIE3.RC2IE = 1;                                   //Habilita la interrupcion en UART2 receive
     PIR3.F5 = 0;                                      //Limpia la bandera de interrupcion
     

     UART1_Init(9600);                                 //Inicializa el UART1 a 9600 bps
     UART2_Init(9600);                                 //Inicializa el UART2 a 9600 bps
     Delay_ms(100);                                    //Espera para que el modulo UART se estabilice

}

void main() {

     Configuracion();
     RC5_bit = 0;                                                   //Establece el Max485-1 en modo de lectura;
     RB5_bit = 0;                                                   //Establece el Max485-2 en modo de lectura;
     ip=0;
     ir=0;

     while (1){

           if (BanLP==1){                                          //Verifica la bandera de lectura de la trama de peticion
               //RC4_bit = 1;
               if ((Ptcn[0]==Hdr)&&(Ptcn[Psize-1]==End)){           //Verifica que el primer y el ultimo elemento de la trama correspondan a los delimitadores de inicio y fin de trama

                     RB5_bit = 1;                                   //Establece el Max485-2 en modo de escritura

                     for (ipp=0;ipp<(Psize);ipp++){
                          UART2_Write(Ptcn[ipp]);                   //Reenvia la trama de peticion a travez del UART2
                     }

                     while(UART2_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
                     RB5_bit = 0;                                   //Establece el Max485-2 en modo de lectura;

                     for (ipp=0;ipp<(Psize);ipp++){
                          Ptcn[ipp]=0;;                             //Limpia la trama de peticion
                     }

                     BanLP = 0;                                     //Limpia la bandera de lectura de la trama de peticion


               } else {

                      for (ipp=0;ipp<(Psize-1);ipp++){
                           Ptcn[ipp]=0;;                            //Limpia la trama de peticion
                      }

                      BanLP = 0;                                    //Limpia la bandera de lectura de la trama de peticion

               }
               //RC4_bit = 0;
            }


            if (BanLR==1){                                          //Verifica la bandera de lectura de la trama de respuesta
               //RB4_bit = 1;
               if ((Rspt[0]==Hdr)&&(Rspt[Rsize-1]==End)){           //Verifica que el primer y el ultimo elemento de la trama correspondan a los delimitadores de inicio y fin de trama

                      RC5_bit = 1;                                  //Establece el Max485-1 en modo de escritura

                      for (irr=0;irr<(Rsize);irr++){
                           UART1_Write(Rspt[irr]);                  //Reenvia la trama de respuesta a travez del UART1
                      }

                      while(UART1_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
                      RC5_bit = 0;                                   //Establece el Max485-2 en modo de lectura;

                      for (irr=0;irr<(Rsize);irr++){
                           Rspt[irr]=0;;                            //Limpia la trama de respuesta
                      }

                      BanLR = 0;                                    //Limpia la bandera de lectura de la trama de respuesta


               } else {

                      for (irr=0;irr<(Rsize-1);irr++){
                           Rspt[irr]=0;;                            //Limpia la trama de respuesta
                      }
                      BanLR = 0;                                    //Limpia la bandera de lectura de la trama de respuesta

               }
               //RB4_bit = 0;
            }


     }
}