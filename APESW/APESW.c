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
unsigned short ThT = 200;                      //Constante de umbral de tiempo (en nanosegundos)
unsigned short Dms;                            //Variable para almacenar la parte mas significativa del dato de respuesta
unsigned short Dmn;                            //Variable para almacenar la parte menos significativa del dato de respuesta
unsigned short F1, F2;                         //Variables para almacenar los pulsos de cada fase

//Declaracion de variables para el calculo de la distancia
unsigned int contp;                            //Contador para controlar los pulsos de exitacion del transductor ultrasonico.
unsigned int contT;                            //Variable asociada a los punteros.
unsigned int contT1;                           //Variable para almacenar la cuenta del TMR1.
unsigned int T1;
unsigned int T2;
unsigned int DT;
unsigned int Di;

unsigned short BS;                             //Variable auxiliar para establecer el cambio de estado en el bit RD0.
unsigned short FP;                             //Bandera de deteccion de cambio de fase
unsigned short FEC;                            //Bandera de deteccion ECO
unsigned short FIE;                            //Bandera de interrupcion externa
unsigned short i,j,k;

float TOF, Df, VSnd;
float DSTemp;

unsigned long DHTvalue;

char *punT1;                                   //Variable tipo puntero para calcular el numero de pulsos del TMR1
char *punDt;                                   //Variable tipo puntero para preparar la trama de datos de respuesta

char txt1[8], txt2[8];
unsigned char Ptcn[Psize];
unsigned char Rspt[Rsize];


// Conexiones del modulo LCD //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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


// Inicio de interrupciones ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void Interrupt(){
//--------------------------------------------------------------------------------------------------------------------------------------------
//Interrupcion TIMER 2:
    if (TMR2IF_bit){                             //Verifica si ocurrio una interrupcion por desbordamiento del TMR2.
       
       //RD1_bit = ~RD1_bit;
       
       if (contp<=42){                           //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (43)
          BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
          RD0_bit = BS;

          if (contp==24){                        //Se empieza a contar el tiempo desde el primer pulso en alto despues del cambio de fase. 25
             TMR1ON_bit=1;                       //Enciende el TMR1.
             TMR1L=0X00;                         //Limpia los bits menos significativos del TMR1.
             TMR1H=0X00;                         //Limpia los bits mas significativos del TMR1.
          }
          if (contp==20){                        //Cambia el valor de la variable auxiliar para producir  (22)
             BS = 0;                             //el cambio de fase en la siguiente iteracion.
             //RD1_bit = 1;                        //Inicio del pulso de indicacion del TOF
          }

       } else {
          RD0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
       }

       contp++;                                  //Aumenta el contador en una unidad.
       TMR2IF_bit = 0;                           //Limpia la bandera de interrupcion de Timer2
    
    }
//--------------------------------------------------------------------------------------------------------------------------------------------
//Interrupcion INT0:
    if (INTCON.INT0IF == 1){                     //Verifica si ocurrio una interrupcion externa en INT0.
    
       //puntT1 = &contT                         //Recuerda que el puntero puntT1 apunta a la variable contT
       *(punT1) = TMR1L;                         //Carga el valor actual de TMR1L en los 8 bits menos significativos de la variable contT de tipo entero.
       *(punT1+1) = TMR1H;                       //Carga el valor actual de TMR1H en los 8 bits mas significativos de la variable  contT de tipo entero.
       
       T2 = contT;                               //Carga el contenido actual de la variable contT en la variable T2.
       DT = (T2-T1);                             //Halla la diferencia entre los valores actual y anterior de la variable contT (en nanosegundos).
       
       if ((DT>(25000-Tht))||(DT<(25000+Tht))){    //Realiza una comparacion para verificar cuando se estabilice la primera fase de la senal
          F1++;
          if (F1==5) {                           //Si 5 intervalos consecutivos cumplen con la condicion de estabilizacion, se empieza con el proceso de busqueda de cambio de fase
             RD1_bit = ~RD1_bit;

          }
       }
       
       
       /*T2 = contp;                               //Carga el valor actual del contador contw en la variable T2.
       DT = T2-T1;                               //Halla la diferencia entre los valores actual y anterior del contador contw.

       if ((T2>43)&&(DT!=T2)&&(DT!=2)){          //Detecta el cambio de fase segun el resultado de la diferencia.
          contT1 = contT;                        //Carga el contenido de la variable contT en la variable contT1.
          TMR1ON_bit=0;                          //Apaga el TMR1.
          //TMR2ON_bit=0;                          //Apaga el TMR2.
          contT = 0;                             //Limpia el contenido de la variable contT.
          RD1_bit = ~RD1_bit;
          FEC = 1;                               //Cambia el estado de la bandera de deteccion de eco
       }*/
       
       T1 = contT;                               //Actualiza T1 con el valor actual del contador contT.
       INTCON.INT0IF = 0;                        //Limpia la bandera de interrupcion de INT0.
       
    }
    
    if (TMR1IF_bit){
       TMR1IF_bit=0;                             //Limpia la bandera de interrupcion de Timer1.
    }
    
}


// Funcion para el calculo de la Velocidad del sonido en funcion de la temperatura ////////////////////////////////////////////////////////
void Velocidad(){
     unsigned int Temp;
     unsigned int Rint;
     float Rfrac;

     Ow_Reset(&PORTE, 2);                                 // Onewire reset signal
     Ow_Write(&PORTE, 2, 0xCC);                           // Issue command SKIP_ROM
     Ow_Write(&PORTE, 2, 0x44);                           // Issue command CONVERT_T
     Delay_us(120);

     Ow_Reset(&PORTE, 2);
     Ow_Write(&PORTE, 2, 0xCC);                           // Issue command SKIP_ROM
     Ow_Write(&PORTE, 2, 0xBE);                           // Issue command READ_SCRATCHPAD

     Temp =  Ow_Read(&PORTE, 2);
     Temp = (Ow_Read(&PORTE, 2) << 8) + Temp;

     if (Temp & 0x8000) {
        Temp = 0;                                         // Si la temperatura es negativa la establece como cero.
     }

     Rint = Temp >> 4;                                    // Extrae la parte entera de la respuesta del sensor
     Rfrac = ((Temp & 0x000F) * 625) / 10000.;            // Extrae la parte decimal de la respuesta del sensor
     DSTemp = Rint + Rfrac; 
     
     VSnd = 331.45 * sqrt(1+(DsTemp/273));                  // Expresa la temperatura en punto flotante
}


// Configuracion ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void Configuracion() {

     INTCON.GIE = 1;                             //Habilita las interrupciones globales
     INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas

     INTCON.INT0IE = 1;                          //Habilita la interrupcion externas en INT0  !!!
     INTCON2.RBPU = 1;                           //PORTB pull-ups are enabled by individual port latch values
     INTCON2.INTEDG0 = 1;                        //Habilita la interrupcion por flanco de subida

     ADCON1 = 0b00001111;                        //Configuracion ADCON1
     CMCON = 0b00000111;

     T1CON=0x00;                                 //Configuracion T1CON: 16 bits, Timer1 Off, Pre-escalador 1:1
     TMR1IE_bit = 1;                             //Habilita la interrupcion por desborde de Timer1

     T2CON = 0x00;                               //Configuracion T2CON: Post-escalador 1:1, Timer2 Off, Pre-escalador 1:1
     PIE1.TMR2IE = 1;                            //Habilita la interrupcion por desborde de Timer2                        ====> La interrupcion del TMR2 interfiere con la conversion del DHT22
     PR2 = 149;                                  //Produce una interrupcion cada 12,5us

     TRISD0_bit = 0;                             //Establece el pin D0 como salida
     TRISD1_bit = 0;                             //Establece el pin D1 como salida

     TRISB = 0x07;                               //Establece los pines B0, B1 y B2 como entradas

}


void main() {

     Configuracion();

     RD0_bit = 0;                                //Limpia el pin D0
     RD1_bit = 0;                                //Limpia el pin D1
     PORTB = 0;                                  //Limpia el puerto B
     
     punT1 = &contT;                             //Asocia el puntero punT1 con la direccion de memoria de la variable contT de tipo entero
     punDt = &Di;                                //Asocia el puntero punDt con la direccion de memoria de la variable Di de tipo entero
     
     contp = 0;                                  //Limpia todas las variables
     contT1 = 0;
     BS = 0;
     FP = 0;
     T1 = 0;
     T2 = 0;
     TOF = 0;
     Di = 0;
     FEC = 0;
     F1 = 0;
     F2 = 0;
     
     Rspt[0] = Hdr;
     Rspt[1] = idSlv;
     Rspt[4] = End;

     Lcd_init();                                 //Inicializa el LCD
     Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
     Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD
     
     UART1_Init(9600);                           // Inicializa el UART a 9600 bps
     Delay_ms(100);                              // Wait for UART module to stabilize

     while (1){
     
           //INT0IE_bit = 0;
           Velocidad();                       //Invoca la funcion para calcular la Velocidad del sonido
           //INT0IE_bit = 1;
           
           BS = 0;
           contp = 0;                            //Limpia los contadores
           T1=0;
           T2=0;
           DT=0;
           
           F1 = 0;
           
           TMR2ON_bit=1;                         //Enciende el TMR2.

           
           TOF = (contT1)*(4./48);               //Calcula el valor de TOF
           Df = ((VSnd * TOF ) / 2000);          //Calcula la distancia en funcion del TOF
           Di = Df*10;                           //Almacena la distancia en una variable de tipo entero

           for (i=2;i<4;i++){                    //Rellena la trama de cuerpo de datos de 4 bytes
               Rspt[i]=(*punDt++);               //El operador * permite acceder al valor de la direccion del puntero,
           }
           
           FloatToStr(Vsnd, txt1);
           FloatToStr(Df, txt2);

           Lcd_Out(1,1,"Vel: ");
           Lcd_Out_Cp(txt1);                     //Visualiza el valor del TOF en el LCD*/
           Lcd_Out(2,1,"Dst: ");
           Lcd_Out_Cp(txt2);                     //Visualiza el valor del TOF en el LCD*/
           
           delay_ms(15);
           TMR2ON_bit=0;

     }
}