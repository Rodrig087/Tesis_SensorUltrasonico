/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 02/08/2016
Ultima modificacion: 17/02/2017
Estado: Modificando
Configuarcion: PIC18F25k22 8MHz
Descripcion:

---------------------------------------------------------------------------------------------------------------------------*/

// LCD module connections
sbit LCD_RS at RB5_bit;
sbit LCD_EN at RB4_bit;
sbit LCD_D4 at RB3_bit;
sbit LCD_D5 at RB2_bit;
sbit LCD_D6 at RB1_bit;
sbit LCD_D7 at RB0_bit;

sbit LCD_RS_Direction at TRISB5_bit;
sbit LCD_EN_Direction at TRISB4_bit;
sbit LCD_D4_Direction at TRISB3_bit;
sbit LCD_D5_Direction at TRISB2_bit;
sbit LCD_D6_Direction at TRISB1_bit;
sbit LCD_D7_Direction at TRISB0_bit;
// End LCD module connections

//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables para la peticion y respuesta de datos
const short Id = 0x02;                                  //Identificador de tipo de sensor
const short Fcn = 0x02;                                  //Identificador de numero de esclavo
const short Psize = 6;                                  //Constante de longitud de trama de Peticion
const short Rsize = 6;                                  //Constante de longitud de trama de Respuesta
const short Hdr = 0x3A;                                 //Constante de delimitador de inicio de trama
const short End = 0x0D;                                 //Constante de delimitador de final de trama
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];
short ir, irr, ip, j;                                          //Subindices para las tramas de peticion y respuesta
unsigned short BanP, BanT;
unsigned short Dato;

//Variables para visualizar el dato en la LCD
short Bb;
char txt1[16];
char txt2[] = "Distancia: ";
unsigned short  *ptrDst;
unsigned int Dst;

void interrupt(void){
     if(PIR1.F5==1){

        Dato = UART1_Read();

        if ((Dato==Hdr)&&(ir==0)){                   //Verifica que el primer dato en llegar sea el identificador de inicio de trama
           BanT = 1;                                 //Activa una bandera de trama
           Rspt[ir] = Dato;                          //Almacena el Dato en la trama de respuesta
        }
        if ((Dato!=Hdr)&&(ir==0)){                   //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
           ir=-1;                                    //Si es asi, reduce el subindice en una unidad
        }
        if ((BanT==1)&&(ir!=0)){
           Rspt[ir] = Dato;                          //Almacena el resto de datos en la trama de respuesta si la bandera de trama esta activada
        }

        ir++;                                        //Aumenta el subindice una unidad
        if (ir==Rsize){                              //Verifica que se haya terminado de llenar la trama de datos
           BanP = 1;                                 //Habilita la bandera de lectura de datos
           ir=0;                                     //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
        }

        PIR1.F5 = 0;                                 //Limpia la bandera de interrupcion
     }
}

// Configuracion //
void Configuracion(){

     ANSELA = 0;                                       //Configura el PORTA como digital
     ANSELB = 0;                                       //Configura el PORTB como digital
     ANSELC = 0;                                       //Configura el PORTC como digital

     TRISC5_bit = 0;                                   //Configura el pin C5 como salida
     TRISA0_bit = 1;
     TRISA1_bit = 0;

     INTCON.GIE = 1;                                   //Habilita las interrupciones globales
     INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
     INTCON.RBIF = 0;

     PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
     PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion

     UART1_Init(9600);                                 //Inicializa el UART a 9600 bps
     Delay_ms(100);                                    //Espera para que el modulo UART se estabilice

     Lcd_Init();                                       // Initialize LCD
     Lcd_Cmd(_LCD_CLEAR);                              // Clear display
     Lcd_Cmd(_LCD_CURSOR_OFF);                         // Cursor off
}

void main() {

     Configuracion();
     RC5_bit = 0;                                                   //Establece el Max485 en modo de lectura;

     ptrDst = &Dst;

     Ptcn[0]=Hdr;
     Ptcn[1]=Id;
     Ptcn[2]=Fcn;
     Ptcn[3]=0x00;
     Ptcn[4]=0x02;
     Ptcn[5]=End;

     Bb=0;
     Dst=0;

     while (1){

           if ((RA0_bit==1)&&(Bb==0)){
               Bb = 1;
               RC5_bit = 1;                                         //Establece el Max485 en modo de escritura
               for (ip=0;ip<Psize;ip++){
                    UART1_WRITE(Ptcn[ip]);                          //Manda por Uart la trama de peticion
               }
               Dst = 0;
               while(UART_Tx_Idle()==0);                            //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
               RC5_bit = 0;                                         //Establece el Max485 en modo de lectura;
            } else if (RA0_bit==0){
               Bb = 0;
            }

            if (BanP==1){
               if ((Rspt[1]==Id)&&(Rspt[Rsize-1]==End)){

                    *ptrDst = Rspt[4];
                    *(ptrDst+1) = Rspt[3];

                    for (irr=0;irr<(Rsize-1);irr++){
                         Rspt[irr]=0;;                            //Limpia los bits de datos de la trama de respuesta
                    }
                    BanP = 0;


               } else {

                      for (irr=0;irr<(Rsize-1);irr++){
                           Rspt[irr]=0;;                            //Limpia los bits de datos de la trama de respuesta
                      }
                      BanP = 0;

               }
            }


           IntToStr(Dst,txt1);

           Lcd_Out(1,1,"Distancia:");
           Lcd_Out(2,1,txt1);

           Delay_ms(20);

     }
}