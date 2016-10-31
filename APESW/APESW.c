/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 25/08/2016
Configuracion: PIC18F4550 8MHz, PLL activado 48MHz
Descripcion: 
1.Genera los pulsos de exitacion para el transductor ultrasonico en el pin RD0 por medio de interrupciones del TMR2 cada 12,5us.
2.Genera una senal para controlar la modulacion AM en el pin RD1.
3.Recibe los pulsos de eco por medio de la interrupcion externa INT0, e identifica el cambio de fase.
4.Calcula el tiempo trasnscurrido entre los cambios de fase de la senal emitida y la senal recibida por medio del TMR1.
5.Visualiza el dato de TOF en un LCD 16x2.
6.Arma una trama de datos de 5 bytes de respuesta con el siguiente formato:
  |Header|Id_Slave|Dato+significativo|Dato-significativo|End|
6.Envia los datos mediante RS-485
---------------------------------------------------------------------------------------------------------------------------*/
//Declaracion de constantes y variables para la trama de datos ////////////////////////////////////////////////////////////////////////////
const short idSlv = 0x31;                      //Id del Esclavo
const short Psize = 4;                         //Constante de longitud de trama de Peticion
const short Rsize = 5;                         //Constante de longitud de trama de Respuesta
const short Hdr = 0x20;                        //Constante de delimitador de inicio de trama
const short End = 0x0D;                        //Constante de delimitador de final de trama
unsigned short Dms;                             //Constante para almacenar la parte mas significativa del dato de respuesta
unsigned short Dmn;                             //Constante para almacenar la parte menos significativa del dato de respuesta

//Declaracion de variables para el calculo de la distancia
unsigned int contw;                            //Contador para controlar los pulsos de exitacion del transductor ultrasonico.
unsigned int contT;                            //Variable asociada a los punteros.
unsigned int contT1;                           //Variable para almacenar la cuenta del TMR1.
unsigned int T1;
unsigned int T2;
unsigned int DT;
unsigned int Di;

unsigned short BS;                             //Variable auxiliar para establecer el cambio de estado en el bit RD0.
unsigned short FP;                             //Bandera de deteccion de cambio de fase
unsigned short FIE;                            //Bandera de interrupcion externa
unsigned short i,j,k;

float TOF, Df, VSnd;
float Temp, Rh;

unsigned long DHTvalue;

char *punT1;                                   //Variable tipo puntero para calcular el numero de pulsos del TMR1
char *punDt;                                   //Variable tipo puntero para preparar la trama de datos de respuesta

char txt1[8], txt2[8];
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];
// Fin de declaracion de variables //////////////////////////////////////////////////////////////////////////////////////////////////////////

// Conexiones del modulo LCD ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
sbit LCD_RS at RD2_bit;
sbit LCD_EN at RD3_bit;
sbit LCD_D4 at RD4_bit;
sbit LCD_D5 at RD5_bit;
sbit LCD_D6 at RD6_bit;
sbit LCD_D7 at RD7_bit;
sbit LCD_RS_Direction at TRISD2_bit;
sbit LCD_EN_Direction at TRISD3_bit;
sbit LCD_D4_Direction at TRISD4_bit;
sbit LCD_D5_Direction at TRISD5_bit;
sbit LCD_D6_Direction at TRISD6_bit;
sbit LCD_D7_Direction at TRISD7_bit;
// Fin conexiones del modulo LCD /////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Conexiones del sensor DHT22 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
sbit DHT22_Pin at RC2_bit;
sbit DHT22_Pin_Direction at TRISC2_bit;
// Fin conexiones sensor DHT22 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Inicio de interrupciones ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void Interrupt(){
//--------------------------------------------------------------------------------------------------------------------------------------------
//Interrupcion TIMER 2:
    if (TMR2IF_bit){                             //Verifica si ocurrio una interrupcion por desbordamiento del TMR2.

       //RD1_bit = ~RD1_bit;                       //Genera un tren de pulsos de 40KHz en el pin RD1
       
       if (contw<=43){                           //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (43)
          BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
          RD0_bit = BS;

          if (contw==25){                        //Se empieza a contar el tiempo desde el primer pulso en alto despues del cambio de fase. 25
             TMR1ON_bit=1;                       //Enciende el TMR1.
             TMR1L=0X00;                         //Limpia los bits menos significativos del TMR1.
             TMR1H=0X00;                         //Limpia los bits mas significativos del TMR1.
          }
          if (contw==22){                        //Cambia el valor de la variable auxiliar para producir  (22)
                BS = 0;                          //el cambio de fase en la siguiente iteracion.
                RD1_bit = 1;                     //Inicio del pulso de indicacion del TOF
          }

       } else {
          RD0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
          FP = 1;                                //Habilita la bandera de deteccion de fase para permitir la deteccion una vez que se hayan terminado de enviar todos los pulsos de exitacion
       }

       if (contw>=800){                          //Limpia el contador cada 800 interrupciones (10ms) para el reenvio de los pulsos
          contw = 0;                             //de exitacion del transductor ultrasonico.
          T1=0;
          T2=0;
          DT=0;
       }

       contw++;                                  //Aumenta el contador en una unidad.
       TMR2IF_bit = 0;                           //Limpia la bandera de interrupcion de Timer2
    }
//--------------------------------------------------------------------------------------------------------------------------------------------
//Interrupcion INT0:
    if (INTCON.INT0IF == 1){                     //Verifica si ocurrio una interrupcion externa en INT0.
       *(punT1) = TMR1L;                         //Carga el valor actual de TMR1L en los 8 bits menos significativos de la variable contT de tipo entero.
       *(punT1+1) = TMR1H;                       //Carga el valor actual de TMR1H en los 8 bits mas significativos de la variable  contT de tipo entero.
       T2 = contw;                               //Carga el valor actual del contador contw en la variable T2.
       DT = T2-T1;                               //Halla la diferencia entre los valores actual y anterior del contador contw.
       
       if ((T2>43)&&(DT!=T2)&&(DT!=2)){          //Detecta el cambio de fase segun el resultado de la diferencia.
          contT1 = contT;                        //Carga el contenido de la variable contT en la variable contT1.
          TMR1ON_bit=0;                          //Apaga el TMR1.
          contT = 0;                             //Limpia el contenido de la variable contT.
          RD1_bit = 0;
       }
       
       T1 = contw;                               //Actualiza T1 con el valor actual del contador contw.
       INTCON.INT0IF = 0;                        //Limpia la bandera de interrupcion de INT0.
    }
    
    if (TMR1IF_bit){
       TMR1IF_bit=0;                             //Limpia la bandera de interrupcion de Timer1.
    }
}
// Fin de interrupciones ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Funcion para el calculo de la Velocidad del sonido en funcion de la temperatura ////////////////////////////////////////////////////////
void Velocidad(){
    DHTvalue = DHT22_readData();
    if ((DHTvalue != 0x63636363) && (DHTvalue != 0x58585858)) {
       Temp = (DHTvalue & 0xFFFF) / 10.;
       DHTvalue = DHTvalue >> 16;
       RH = (DHTvalue & 0xFFFF) / 10.;
       VSnd = 331.45 * sqrt(1+(Temp/273));
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void main() {

     INTCON.GIE = 1;                             //Habilita las interrupciones globales
     INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
     
     INTCON.INT0IE = 1;                          //Habilita la interrupcion externas en INT0
     INTCON2.RBPU = 1;                           //PORTB pull-ups are enabled by individual port latch values
     INTCON2.INTEDG0 = 1;                        //Habilita la interrupcion por flanco de subida
     
     ADCON1 = 0b00010111;                        //Configuracion ADCON1
     CMCON = 0b00000111;

     T1CON=0x00;                                 //Configuracion T1CON: 16 bits, Timer1 On, Pre-escalador 1:1
     TMR1IE_bit = 1;                             //Habilita la interrupcion por desborde de Timer1

     T2CON = 0x04;                               //Configuracion T2CON: Post-escalador 1:1, Timer2 On, Pre-escalador 1:1
     PIE1.TMR2IE = 1;                            //Habilita la interrupcion por desborde de Timer2
     PR2 = 149;                                  //Produce una interrupcion cada 12,5us

     TRISD0_bit = 0;                             //Establece el pin D0 como salida
     TRISD1_bit = 0;                             //Establece el pin D1 como salida

     TRISB = 0x07;                               //Establece los pines B0, B1 y B2 como entradas
     
     RD0_bit = 0;                                //Limpia el pin D0
     RD1_bit = 0;                                //Limpia el pin D1
     PORTB = 0;                                  //Limpia el puerto B
     
     punT1 = &contT;                             //Asocia el puntero punT1 con la direccion de memoria de la variable contT de tipo entero
     punDt = &Di;                                //Asocia el puntero punDt con la direccion de memoria de la variable Di de tipo entero
     
     contw = 0;                                  //Limpia todas las variables
     contT1 = 0;
     BS = 0;
     FP = 0;
     T1 = 0;
     T2 = 0;
     TOF = 0;
     Di = 0;
     
     Rspt[0] = Hdr;
     Rspt[1] = idSlv;
     Rspt[4] = End;

     Lcd_init();                                 //Inicializa el LCD
     Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
     Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD
     
     UART1_Init(9600);                           // Inicializa el UART a 9600 bps
     Delay_ms(100);                              // Wait for UART module to stabilize

     while (1){

           Velocidad();                          //Invoca la funcion para calcular la Velocidad del sonido

           TOF = (contT1)*(4./48);               //Calcula el valor de TOF
           Df = (VSnd * TOF ) / 2000;            //Calcula la distancia en funcion del TOF
           Di = Df*10;                           //Almacena la distancia en una variable de tipo entero

           for (i=2;i<4;i++){                    //Rellena la trama de cuerpo de datos de 4 bytes
               Rspt[i]=(*punDt++);               //El operador * permite acceder al valor de la direccion del puntero,
           }
           
           FloatToStr(VSnd, txt1);
           FloatToStr(Df, txt2);                   //Convierte el valor de la distancia en string
           
           Lcd_Out(1,1,"Vel: ");
           Lcd_Out_Cp(txt1);
           Lcd_Out(2,1,"Dis: ");
           Lcd_Out_Cp(txt2);                     //Visualiza el valor del TOF en el LCD*/

           for (j=0;j<=4;j++){
               UART1_Write(Rspt[j]);             //Visualiza la trama recibida en el LCD
           }

           delay_ms(1);

     }
}