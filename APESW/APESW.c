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
6.Envia los datos mediante RS-485
---------------------------------------------------------------------------------------------------------------------------*/
//Declaracion de constantes
const short idSlv = 0x31;                      //Id del Esclavo
const short Psize = 4;                         //Constante de longitud de trama de Peticion
const short Rsize = 5;                         //Constante de longitud de trama de Respuesta
const short Hdr = 0x20;                        //Constante de delimitador de inicio de trama
const short End = 0x0D;                        //Constante de delimitador de final de trama

//Declaracion de variables.
unsigned int contw;                            //Contador para controlar los pulsos de exitacion del transductor ultrasonico.
unsigned int contT;                            //Variable asociada a los punteros.
unsigned int contT1;                           //Variable para almacenar la cuenta del TMR1.
unsigned int T1;
unsigned int T2;
unsigned int DT;

unsigned short BS;                             //Variable auxiliar para establecer el cambio de estado en el bit RD0.
unsigned short FP;                             //Bandera de deteccion de cambio de fase

float TOFT;

char *punT1;                                   //Variable tipo puntero

char txt1[10], txt2[10];
unsigned char Ptcn[Psize];


// Conexiones del modulo LCD
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


void Interrupt(){
//--------------------------------------------------------------------------------------------------------------------------------------------
//Interrupcion TIMER 2:
    if (TMR2IF_bit){                             //Verifica si ocurrio una interrupcion por desbordamiento del TMR2.

       RD1_bit = ~RD1_bit;                       //Genera un tren de pulsos de 40KHz en el pin RD1
       
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
          }

       } else {
          RD0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
          FP = 1;                                //Habilita la bandera de deteccion de fase para permitir la deteccion una vez que se hayan
       }                                         //terminado de enviar todos los pulsos de exitacion

       if (contw>=800){                          //Limpia el contador cada 800 interrupciones (10ms) para el reenvio de los pulsos
          contw = 0;                             //de exitacion del transductor ultrasonico.
       }

       contw++;                                  //Aumenta el contador en una unidad.
       TMR2IF_bit = 0;                           //Limpia la bandera de interrupcion de Timer2
    }
//--------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------
//Interrupcion INT0:
    if (INTCON.INT0IF == 1){                     //Verifica si ocurrio una interrupcion externa en INT0.
       *(punT1) = TMR1L;                         //Carga el valor actual de TMR1L en los 8 bits menos significativos de la variable contT de tipo entero.
       *(punT1+1) = TMR1H;                       //Carga el valor actual de TMR1H en los 8 bits mas significativos de la variable  contT de tipo entero.
       T2 = contw;                               //Carga el valor actual del contador contw en la variable T2.
       DT = T2-T1;                               //Halla la diferencia entre los valores actual y anterior del contador contw.
       if ((FP==1)&&(T2>43)&&(DT!=T2)&&(DT!=2)){ //Detecta el cambio de fase segun el resultado de la diferencia.
          contT1 = contT;                        //Carga el contenido de la variable contT en la variable contT1.
          TMR1ON_bit=0;                          //Apaga el TMR1.
          contT = 0;                             //Limpia el contenido de la variable contT.
          FP = 0;                                //Limpia la bandera de deteccion de fase para evitar detectar 2 cambios seguidos.
       }
       T1 = contw;                               //Actualiza T1 con el valor actual del contador contw.
       INTCON.INT0IF = 0;                        //Limpia la bandera de interrupcion de INT0.
    }
    
    if (TMR1IF_bit){
       TMR1IF_bit=0;                             //Limpia la bandera de interrupcion de Timer1.
    }
}
//--------------------------------------------------------------------------------------------------------------------------------------------


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
     
     contw = 0;                                  //Limpia todas las variables
     contT1 = 0;
     BS = 0;
     FP = 0;
     T1 = 0;
     T2 = 0;
     TOFT = 0;
     
     Lcd_init();                                 //Inicializa el LCD
     Lcd_Out(1,1,"INICIANDO...");
     Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
     Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD

     while (1){

           TOFT = (contT1 * 0.1666);          //Calcula el valor de TOF
           
           FloatToStr(TOFT, txt1);               //Convierte el valor del TOF en string
           Lcd_Out(1,1,"TOF: ");
           Lcd_Out_Cp(txt1);                     //Visualiza el valor del TOF en el LCD

           delay_ms(1);

     }
}