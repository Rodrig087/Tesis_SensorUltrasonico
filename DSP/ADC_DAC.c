/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 13/01/2017
Configuracion: dsPIC P33FJ32MC202, XT=8MHz, PLL=80MHz
Descripcion:
1.Realiza la lectura del sensor de temperatura DS18B20 para estimar la velocidad del sonido.
2.Genera los pulsos de exitacion para el transductor ultrasonico mediante interrupciones por desbordamiento del TMR2.
3.Realiza la conversion analogica-digital de la senal de eco recibida por del receptor ultrasonico a una frecuencia de muestreo determinada
  por el desbordamiento del TMR1.
4.Realiza la deteccion de envolvente de la senal muestreada.
5.
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
const unsigned int nm = 365;
unsigned int M[nm];
unsigned int R[nm];
unsigned int i;
unsigned int j;
unsigned int k;
short bm;
//Variables para la deteccion de la Envolvente de la senal
unsigned int value = 0;
unsigned int aux_value = 0;
// Declaracion de variables //
float x0=0, x1=0, x2=0, y0=0, y1=0, y2=0;
unsigned int YY = 0;
//Variables para determinar el maximo de la funcion
unsigned int VMmax=0;
unsigned int VMmin=0;
unsigned int VMmed=0;
unsigned int IndexMax;
unsigned int IndexMin;
//Variables para controlar la interrupcion externa
short int0_en = 0;


/////////////////////////////////////////////////////////////////// Funciones //////////////////////////////////////////////////////////////
//Funcion para la deteccion de la Envolvente de la senal
void Envolvente() {

}
//Funcion para el calculo de la Velocidad del sonido en funcion de la temperatura registrada por el sensor DS18B20
void Velocidad(){
     unsigned int Temp;
     unsigned int Rint;
     float Rfrac;

     Ow_Reset(&PORTB, 15);                        //Onewire reset signal
     Ow_Write(&PORTB, 15, 0xCC);                  //Issue command SKIP_ROM
     Ow_Write(&PORTB, 15, 0x44);                  //Issue command CONVERT_T
     Delay_us(100);

     Ow_Reset(&PORTB, 15);
     Ow_Write(&PORTB, 15, 0xCC);                  //Issue command SKIP_ROM
     Ow_Write(&PORTB, 15, 0xBE);                  //Issue command READ_SCRATCHPAD
     Delay_us(100);

     Temp =  Ow_Read(&PORTB, 15);
     Temp = (Ow_Read(&PORTB, 15) << 8) + Temp;

     if (Temp & 0x8000) {
        Temp = 0;                                //Si la temperatura es negativa la establece como cero.
     }

     Rint = Temp >> 4;                           //Extrae la parte entera de la respuesta del sensor
     Rfrac = ((Temp & 0x000F) * 625) / 10000.;   //Extrae la parte decimal de la respuesta del sensor
     DSTemp = Rint + Rfrac;

     VSnd = 331.45 * sqrt(1+(DsTemp/273));       //Expresa la temperatura en punto flotante
}


////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
//Interrupcion por conversion completada del ADC
void ADC1Int() org IVT_ADDR_ADC1INTERRUPT {
     IEC0.INT0IE = 0;
     if (i<nm){
        M[i] = ADC1BUF0;                           //Almacena el valor actual de la conversion del ADC en el vector M
        i++;                                       //Aumenta en 1 el subindice del vector de Muestras
     } else {
        bm = 1;                                    //Cambia el valor de la bandera bm para terminar con el muestreo y dar comienzo al procesamiento de la señal
        T1CON.TON = 0;                             //Apaga el TMR1
        IEC0.T1IE = 0;                             //Desabilita la interrupcion por desborde del TMR1
     }
     AD1IF_bit = 0;                                //Limpia la bandera de interrupcion del ADC
}
//Interrupcion por desbordamiento del TMR1
void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
     LATA1_bit = ~LATA1_bit;                       //Auxiliar para ver el proceso de la interrupcion
     if (bm==0){                                   //Cuando la bandera bm=0, la interrupcion por TMR1 es utilizada para el muestreo de la señal de entrada
        SAMP_bit = 0;                              //Limpia el bit SAMP para iniciar la conversion del ADC
     }
     if (bm==1) {                                  //Cuando la bandera bm=1, la interrupcion por TMR1 es utilizada para la reconstruccion de la señal mediante el DAC
          if (j<nm){
             LATB = (R[j]&0x7F)|((r[j]<<1)&0x700);
             j++;
          } else {
             bm = 0;                               //Cambia el valor de la bandera bm para permitir un nuevo muestreo
             IEC0.T1IE = 0;                        //Desabilita la interrupcion por desborde del TMR1
          }
     }
     T1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
}
//Interrupcion por desbordamiento del TMR2
void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
     //LATA4_bit = ~LATA4_bit;                     //Auxiliar para ver el proceso de la interrupcion
     if (contp<10){                                //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (
          RB14_bit = ~RB14_bit;                    //Conmuta el valor del pin RB14
     } else {
          RB14_bit = 0;                            //Pone a cero despues de enviar todos los pulsos de exitacion.
          if (contp==104){
              LATA4_bit = ~LATA4_bit;
              IEC0.T2IE = 0;                       //Desabilita la interrupcion por desborde del TMR2 para no interferir con las interrupciones por desborde de TMR1 y por conversion completa del ADC
              T2CON.TON = 0;                       //Apaga el TMR2
              IEC0.AD1IE = 1;                      //Habilita la interrupcion por conversion completa del ADC
              IEC0.T1IE = 1;                       //Habilita la interrupcion por desborde del TMR1 para dar inicio al muestreo del ADC
              TMR1 = 0;                            //Encera el TMR1
              T1CON.TON = 1;                       //Enciende el TMR1
          }
     }
     contp++;                                      //Aumenta el contador en una unidad.
     T2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
}


///////////////////////////////////////////////////////////// Configuraciones //////////////////////////////////////////////////////////////
void Configuracion(){

     //Configuracion del PLL para generar un FOSC de 80MHz  a partir de un oscilador externo de 8MHz
     CLKDIVbits.PLLPRE = 0;                        //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
     PLLFBD = 38;                                  //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
     CLKDIVbits.PLLPOST = 0;                       //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz

     //Configuracion de puertos
     AD1PCFGL = 0xFFFE;                            //Configura el puerto AN0 como entrada analogica y todas las demas como digitales
     TRISA0_bit = 1;                               //Set RA0 pin as input
     TRISA1_bit = 0;                               //Set RA1 pin as output
     TRISA4_bit = 0;
     TRISB = 0x8080;                               //Establece los pines 8 y 15 como entradas y todas las demas como salidas

     //Configuracion del ADC
     AD1CON1.AD12B = 0;                            //Configura el ADC en modo de 10 bits
     AD1CON1bits.FORM = 0x00;                      //Formato de la canversion: 00->(0_1023)|01->(-512_511)|02->(0_0.999)|03->(-1_0.999)
     AD1CON1.SIMSAM = 0;                           //0 -> Muestrea múltiples canales individualmente en secuencia
     AD1CON1.ADSIDL = 0;                           //Continua con la operacion del modulo durante el modo desocupado
     AD1CON1.ASAM = 1;                             //Muestreo automatico
     AD1CON1bits.SSRC = 0x00;                      //Conversion manual

     AD1CON2bits.VCFG = 0;                         //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
     AD1CON2bits.CHPS = 0;                         //Selecciona unicamente el canal CH0
     AD1CON2.CSCNA = 0;                            //No escanea las entradas de CH0 durante la Muestra A
     AD1CON2bits.SMPI = 0x00;                      //Numero de secuencias de muestreo/conversion por interrupcion (N+1)
     AD1CON2.BUFM = 0;                             //Bit de selección del modo de relleno del búfer, 0 -> Siempre comienza a llenar el buffer desde el principio
     AD1CON2.ALTS = 0x00;                          //Utiliza siempre la selección de entrada de canal para la muestra A

     AD1CON3.ADRC = 0;                             //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
     AD1CON3bits.ADCS = 0x02;                      //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
     AD1CON3bits.SAMC = 0x02;                      //Auto Sample Time bits, 2 -> 2*TAD (minimo periodo de muestreo para 10 bits)

     AD1CHS0 = 0;                                  //ADC1 INPUT CHANNEL 0 SELECT REGISTER
     AD1CHS123 = 0;                                //AD1CHS123: ADC1 INPUT CHANNEL 1, 2, 3 SELECT REGISTER

     AD1CSSL = 0x00;                               //Se salta todos los puertos ANx para los escaneos de entrada

     //IEC0.AD1IE = 0x00;                          //Activa la interrupcion por conversion completa del ADC

     AD1CON1.ADON = 1;                             //Enciende el modulo ADC

     //Configuracion del TMR1
     T1CON = 0x8000;                               //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
     IEC0.T1IE = 0;                                //Inicializa el programa con la interrupcion por desborde de TMR1 desabilitada para no interferir con la lectura del sensor de temperatura
     T1IF_bit = 0;                                 //Limpia la bandera de interrupcion
     PR1 = 200;                                    //Genera una interrupcion cada 5us (Fs=200KHz)
     
     ////Configuracion del TMR2
     T2CON = 0x8000;                               //Habilita el TMR2, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
     IEC0.T2IE = 0;                                //Inicializa el programa con la interrupcion por desborde de TMR2 desabilitada para no interferir con la lectura del sensor de temperatura
     T2IF_bit = 0;                                 //Limpia la bandera de interrupcion
     PR2 = 500;                                    //Genera una interrupcion cada 12.5us
     
     //Configuracion INT0
     INTCON2.INT0EP = 0;                           //Interrupcion en flanco positivo
     
     //Nivel de prioridad de las interrupciones (+alta -> +prioridad)
     IPC3bits.AD1IP = 0x06;                        //Nivel de prioridad de interrupcion del ADC
     IPC0bits.T1IP = 0x07;                         //Nivel de prioridad de la interrupcion por desbordamiento del TMR1
     IPC1bits.T2IP = 0x05;                         //Nivel de prioridad de la interrupcion por desbordamiento del TMR2
     IPC0bits.INT0IP = 0x04;                       //Nivel de prioridad de la interrupcion INT0
}


//////////////////////////////////////////////////////////////// main ////////////////////////////////////////////////////////////////
void main() {

     Configuracion();
     
     while(1){
              //bm=1;
              // Generacion de pulsos y captura de la señal de retorno //
              if (bm==0){

                  contp = 0;                                               //Limpia la variable del contador de pulsos
                  RB14_bit = 0;                                            //Limpia el pin que produce los pulsos de exitacion del transductor
                  IEC0.T2IE = 1;                                           //Habilita la interrupcion por desborde del TMR2
                  TMR2 = 0;                                                //Encera el TMR2
                  T2CON.TON = 1;                                           //Enciende el TMR2
                  
                  i = 0;                                                   //Limpia las variables asociadas al almacenamiento de la señal muestreada
                  j = 0;

              }
              
              // Procesamiento de la señal capturada //
              else {

                  Velocidad();                                             //Llama a la funcion para calcular la Velocidad del sonido
                  
                  //Determinacion punto medio señal
                  VMmax = Vector_Max(M, nm, &IndexMax);
                  VMmin = Vector_Min(M, nm, &IndexMin);
                  VMmed = VMmax-((VMmax-VMmin)/2);
                  
                  for (k=0;k<nm;k++){
                  
                      //Valor absoluto
                      //value = M[k];
                      value = M[k]-VMmed;
                      if (M[k]<VMmed){
                         value = (M[k]+((VMmed-M[k])*2))-(VMmed);
                      }
                      /*value = M[k]&0x01FF;                                 //Establece los datos en mod 512
                      if (M[k]<512){
                         value = (M[k]+((512-M[k])*2))&0x01FE;             //Invierte la señal y establece los datos en mod 511
                      }*/

                      
                      //Filtrado
                      x0 = (float)(value);                             //Adquisición de una muestra de 10 bits en, x[0].
                      y0 = ((x0+x2)*ca1)+(x1*ca2)-(y1*cb2)-(y2*cb3);       //Implementación de la ecuación en diferencias

                      y2 = y1;                                             //Corrimiento de los valores x(n), y y(n).
                      y1 = y0;
                      x2 = x1;
                      x1 = x0;

                      YY = (unsigned int)(y0);                             //Reconstrucción de la señal: y en 10 bits.
                      
                      R[k] = YY;
                      
                  }

                  T1CON.TON = 1;                                           //Enciende el TMR1
                  IEC0.T1IE = 1;                                           //Habilita la interrupcion por desborde del TMR1
                  
              }
              
              Delay_ms(10);
              
     }

}