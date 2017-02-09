/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 13/01/2017
Configuracion: dsPIC P33FJ32MC202, XT=8MHz, PLL=80MHz
Descripcion:
1.
---------------------------------------------------------------------------------------------------------------------------*/
//Coeficientes filtro IIR (Fs=200KHz, T/2=650us)
const float ca1 = 0.006745773600345;
const float ca2 = 0.013491547200690;
const float cb2 = -1.754594315763869;
const float cb3 = 0.781577410165250;

//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables para la generacion de pulsos de exitacion del transductor ultrasonico
unsigned int contp;
//Variables para el calculo de la Velocidad del sonido:
float DSTemp, VSnd;
//Variables para el almacenamiento de la señal muestreada:
const unsigned int nm = 350;
unsigned int M[nm];
unsigned int i;
unsigned int k;
short bm;
//Variables para la deteccion de la Envolvente de la señal
unsigned int value = 0;
unsigned int aux_value = 0;
//Variables para el filtrado de la señal
float x0=0, x1=0, x2=0, y0=0, y1=0, y2=0;
unsigned int YY = 0;
//Variables para determinar el tiempo de maximo de la funcion
unsigned int Mmax=0;
unsigned int Mmin=0;
unsigned int Mmed=0;
unsigned int MIndexMax;
unsigned int MIndexMin;
unsigned int maxIndex;
unsigned int i0, i1, i2, imax;
unsigned int i1a, i1b;
const short dix=8;
const float tx=5.0;
int yy0, yy1, yy2;
float yf0, yf1, yf2;
float nx, dx, tmax;
//Variables para calcular el TOF
float T1, T2;
float TOF, Dst;
//Variables para la visualizacion de datos en el LCD
char txt1[6], txt2[6], txt3[6], txt4[6] ;
//Variables para peticion de datos
short bp;
short conts;
float T2sum,T2prom;
unsigned long TT2;
unsigned char  *chT2;
unsigned char trama[4];
short l;


/////////////////////////////////////////////////////////////////// Funciones //////////////////////////////////////////////////////////////
//Funcion para el calculo de la Velocidad del sonido en funcion de la temperatura registrada por el sensor DS18B20
void Velocidad(){
     unsigned int Temp;
     unsigned int Rint;
     float Rfrac;

     Ow_Reset(&PORTA, 1);                        //Onewire reset signal
     Ow_Write(&PORTA, 1, 0xCC);                  //Issue command SKIP_ROM
     Ow_Write(&PORTA, 1, 0x44);                  //Issue command CONVERT_T
     Delay_us(100);

     Ow_Reset(&PORTA, 1);
     Ow_Write(&PORTA, 1, 0xCC);                  //Issue command SKIP_ROM
     Ow_Write(&PORTA, 1, 0xBE);                  //Issue command READ_SCRATCHPAD
     Delay_us(100);

     Temp =  Ow_Read(&PORTA, 1);
     Temp = (Ow_Read(&PORTA, 1) << 8) + Temp;

     if (Temp & 0x8000) {
        Temp = 0;                                //Si la temperatura es negativa la establece como cero.
     }

     Rint = Temp >> 4;                           //Extrae la parte entera de la respuesta del sensor
     Rfrac = ((Temp & 0x000F) * 625) / 10000.;   //Extrae la parte decimal de la respuesta del sensor
     DSTemp = Rint + Rfrac;

     VSnd = 331.45 * sqrt(1+(DsTemp/273));       //Expresa la temperatura en punto flotante
}

//Funcion para la generacion y procesamiento de la señal
void Pulse(){

            // Generacion de pulsos y captura de la señal de retorno //
            contp = 0;                                               //Limpia la variable del contador de pulsos
            RB14_bit = 0;                                            //Limpia el pin que produce los pulsos de exitacion del transductor

            T1CON.TON = 0;                                           //Apaga el TMR1
            IEC0.T1IE = 0;                                           //Desabilita la interrupcion por desborde del TMR1

            TMR2 = 0;                                                //Encera el TMR2
            IEC0.T2IE = 1;                                           //Habilita la interrupcion por desborde del TMR2
            T2CON.TON = 1;                                           //Enciende el TMR2

            i = 0;                                                   //Limpia las variables asociadas al almacenamiento de la señal muestreada


            while(bm!=1);                                            //Espera hasta que haya terminado de enviar y recibir todas las muestras

            // Procesamiento de la señal capturada //
            if (bm==1){

                //Determinacion de la amplitud media de la señal
                Mmax = Vector_Max(M, nm, &MIndexMax);
                Mmin = Vector_Min(M, nm, &MIndexMin);
                Mmed = Mmax-((Mmax-Mmin)/2);

                for (k=0;k<nm;k++){

                    //Valor absoluto
                    value = M[k]-Mmed;
                    if (M[k]<Mmed){
                       value = (M[k]+((Mmed-M[k])*2))-(Mmed);
                    }

                    //Filtrado
                    x0 = (float)(value);                                 //Adquisición de una muestra de 10 bits en, x[0].
                    y0 = ((x0+x2)*ca1)+(x1*ca2)-(y1*cb2)-(y2*cb3);       //Implementación de la ecuación en diferencias

                    y2 = y1;                                             //Corrimiento de los valores x(n), y y(n).
                    y1 = y0;
                    x2 = x1;
                    x1 = x0;

                    YY = (unsigned int)(y0);                             //Reconstrucción de la señal: y en 10 bits.
                    M[k] = YY;

                }

                bm = 2;                                                  //Cambia el estado de la bandera bm para dar paso al cálculo del pmax y TOF

            }

            // Cálculo del punto maximo y TOF
            if (bm==2){

               yy1 = Vector_Max(M, nm, &maxIndex);                         //Encuentra el valor maximo del vector R
               i1b = maxIndex;                                              //Asigna el subindice del valor maximo a la variable i1a
               i1a = 0;
              
               while (M[i1a]<yy1){
                     i1a++;
               }
               
               i1 = i1a+((i1b-i1a)/2);
               i0 = i1 - dix;
               i2 = i1 + dix;
               
               yy0 = M[i0];
               yy2 = M[i2];
               
               yf0 = (float)(yy0);
               yf1 = (float)(yy1);
               yf2 = (float)(yy2);

               nx = (yf0-yf2)/(2.0*(yf0-(2.0*yf1)+yf2));                   //Factor de ajuste determinado por interpolacion parabolica
               dx = nx*dix*tx;
               tmax = i1*tx;

               T2 = tmax+dx;

            }

}

////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
//Interrupcion por conversion completada del ADC
void ADC1Int() org IVT_ADDR_ADC1INTERRUPT {
     if (i<nm){
        M[i] = ADC1BUF0;                           //Almacena el valor actual de la conversion del ADC en el vector M
        i++;                                       //Aumenta en 1 el subindice del vector de Muestras
     } 
     else{
        bm = 1;                                    //Cambia el valor de la bandera bm para terminar con el muestreo y dar comienzo al procesamiento de la señal
        T1CON.TON = 0;                             //Apaga el TMR1
        IEC0.T1IE = 0;                             //Desabilita la interrupcion por desborde del TMR1
     }

     AD1IF_bit = 0;                                //Limpia la bandera de interrupcion del ADC
}

//Interrupcion por desbordamiento del TMR1
void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
     RB15_bit = ~RB15_bit;
     SAMP_bit = 0;                              //Limpia el bit SAMP para iniciar la conversion del ADC
     T1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
}

//Interrupcion por desbordamiento del TMR2
void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
     if (contp<10){                                //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (
          RB14_bit = ~RB14_bit;                    //Conmuta el valor del pin RB14
     }else {
          RB14_bit = 0;                            //Pone a cero despues de enviar todos los pulsos de exitacion.

          if (contp==110){
              IEC0.T2IE = 0;                       //Desabilita la interrupcion por desborde del TMR2 para no interferir con las interrupciones por desborde de TMR1 y por conversion completa del ADC
              T2CON.TON = 0;                       //Apaga el TMR2
              IEC0.AD1IE = 1;                      //Habilita la interrupcion por conversion completa del ADC
              IEC0.T1IE = 1;                       //Habilita la interrupcion por desborde del TMR1 para dar inicio al muestreo del ADC
              TMR1 = 0;                            //Encera el TMR1
              T1IF_bit = 0;                        //Limpia la bandera de interrupcion por desbordamiento del TMR1
              T1CON.TON = 1;                       //Enciende el TMR1
              bm=0;
          }

     }
     contp++;                                      //Aumenta el contador en una unidad.
     T2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
}


///////////////////////////////////////////////////////////// Configuraciones //////////////////////////////////////////////////////////////
void Configuracion(){

     //Configuracion del PLL para generar un FOSC de 80MHz  a partir de un oscilador externo de 8MHz
     CLKDIVbits.PLLPRE = 0;                      //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
     PLLFBD = 38;                                //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
     CLKDIVbits.PLLPOST = 0;                     //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz

     //Configuracion de puertos
     AD1PCFGL = 0xFFFE;                          //Configura el puerto AN0 como entrada analogica y todas las demas como digitales
     TRISA0_bit = 1;                             //Set RA0 pin as input
     TRISA4_bit = 1;                             //Set RA4 pin as input
     TRISB = 0;                                  //Set RB14 pin as output

     //Configuracion del ADC
     AD1CON1.AD12B = 0;                          //Configura el ADC en modo de 10 bits
     AD1CON1bits.FORM = 0x00;                    //Formato de la canversion: 00->(0_1023)|01->(-512_511)|02->(0_0.999)|03->(-1_0.999)
     AD1CON1.SIMSAM = 0;                         //0 -> Muestrea múltiples canales individualmente en secuencia
     AD1CON1.ADSIDL = 0;                         //Continua con la operacion del modulo durante el modo desocupado
     AD1CON1.ASAM = 1;                           //Muestreo automatico
     AD1CON1bits.SSRC = 0x00;                    //Conversion manual

     AD1CON2bits.VCFG = 0;                       //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
     AD1CON2bits.CHPS = 0;                       //Selecciona unicamente el canal CH0
     AD1CON2.CSCNA = 0;                          //No escanea las entradas de CH0 durante la Muestra A
     AD1CON2bits.SMPI = 0x00;                    //Numero de secuencias de muestreo/conversion por interrupcion (N+1)
     AD1CON2.BUFM = 0;                           //Bit de selección del modo de relleno del búfer, 0 -> Siempre comienza a llenar el buffer desde el principio
     AD1CON2.ALTS = 0x00;                        //Utiliza siempre la selección de entrada de canal para la muestra A

     AD1CON3.ADRC = 0;                           //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
     AD1CON3bits.ADCS = 0x02;                    //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
     AD1CON3bits.SAMC = 0x02;                    //Auto Sample Time bits, 2 -> 2*TAD (minimo periodo de muestreo para 10 bits)

     AD1CHS0 = 0;                                //ADC1 INPUT CHANNEL 0 SELECT REGISTER
     AD1CHS123 = 0;                              //AD1CHS123: ADC1 INPUT CHANNEL 1, 2, 3 SELECT REGISTER

     AD1CSSL = 0x00;                             //Se salta todos los puertos ANx para los escaneos de entrada

     AD1CON1.ADON = 1;                           //Enciende el modulo ADC

     //Configuracion del TMR1
     T1CON = 0x8000;                             //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
     IEC0.T1IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR1 desabilitada para no interferir con la lectura del sensor de temperatura
     T1IF_bit = 0;                               //Limpia la bandera de interrupcion
     PR1 = 200;                                  //Genera una interrupcion cada 5us (Fs=200KHz)
     
     ////Configuracion del TMR2
     T2CON = 0x8000;                             //Habilita el TMR2, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
     IEC0.T2IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR2 desabilitada para no interferir con la lectura del sensor de temperatura
     T2IF_bit = 0;                               //Limpia la bandera de interrupcion
     PR2 = 500;                                  //Genera una interrupcion cada 12.5us

     //Configuracion INT0
     INTCON2.INT0EP = 0;                         //Interrupcion en flanco positivo
     
     //Nivel de prioridad de las interrupciones (+alta -> +prioridad)
     IPC3bits.AD1IP = 0x06;                      //Nivel de prioridad de interrupcion del ADC
     IPC0bits.T1IP = 0x07;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR1
     IPC1bits.T2IP = 0x05;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR2
     IPC0bits.INT0IP = 0x04;                     //Nivel de prioridad de la interrupcion INT0
     
     //Configuracion UART
     RPINR18bits.U1RXR = 0x0C;                   //Asisgna Rx a RP12
     RPOR6bits.RP13R = 0x03;                     //Asigna Tx a RP13
     
}


//////////////////////////////////////////////////////////////// main ////////////////////////////////////////////////////////////////
void main() {

     Configuracion();
     
     UART1_Init(9600);               // Initialize UART module at 9600 bps
     Delay_ms(100);                  // Wait for UART module to stabilize
     //UART_Write_Text("Start");

     while(1){

              TOF = 0.0;
              Dst = 0.0;
              T2sum = 0.0;
              T2prom = 0.0;
              conts = 0;

              while (conts<5){
                    Pulse();
                    T2sum = T2sum + T2;
                    conts++;
              }
              
              T2prom=(T2sum/5);
              //Velocidad();
              
              //T1 = 100 * 12.5;
              //TOF = T1 + T2prom;
              //Dst = VSnd * (TOF / 20000.0);

              TT2 = T2Prom * 100.0;

              chT2 = (unsigned char *) & TT2;

              for (l=0;l<4;l++){
                 trama[l]=(*chT2++);
              }
              
              UART1_Write(0xEE);
              
              for (l=0;l<4;l++){
                 UART1_Write(trama[l]);
              }
              
              //UART1_Write(0xFF);
              
              Delay_ms(10);
              
     }

}