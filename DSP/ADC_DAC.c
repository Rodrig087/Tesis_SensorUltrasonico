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
//Coeficientes filtro IIR
unsigned int ca1 = 0x3B56;                       //Coeficientes de a escalados con un factor de 7   (ax*2^7 -> 16bQ7)
unsigned int ca2 = 0x76AD;
unsigned int cb1 = 0x4000;                       //Coeficientes de b escalados con un factor de -1  (ax*2^-1 -> 16bQ-1)
unsigned int cb2 = 0x8B59;
unsigned int cb3 = 0x3594;

//////////////////////////////////////////////////// Declaracion de variables //////////////////////////////////////////////////////////////
//Variables para la generacion de pulsos de exitacion del transductor ultrasonico
unsigned int contp;
unsigned short BS;
//Variables para el calculo de la Velocidad del sonido:
float DSTemp, VSnd;
//Variables para el almacenamiento de la señal muestreada:
const unsigned int nm = 300;
unsigned int M[nm];
unsigned int i;
unsigned int j;
short bm;
//Variables para la deteccion de la Envolvente de la senal
unsigned int value = 0;
unsigned int aux_value = 0;
//Variables para determinar el maximo de la funcion
/*unsigned int VP=0;
unsigned int y0=0, y1=0, y2=0;*/
//Variables para realizar el filtrado
/*long x0=0, x1=0, x2=0, y0=0, y1=0, y2=0;                         //32 bits
unsigned int YY = 0;*/


/////////////////////////////////////////////////////////////////// Funciones //////////////////////////////////////////////////////////////
//Funcion para la deteccion de la Envolvente de la senal
void Envolvente() {

     //Valor absoluto de la funcion
     value = ADC1BUF0&0x01FF;                               //mod 512
     if (ADC1BUF0<512){
        value = (ADC1BUF0+((512-ADC1BUF0)*2))&0x01FE;
     }

   //Holding
    if (value>5){
         if (value>aux_value){
            aux_value=value;
         }
         else{
            aux_value=aux_value-5;
            if (aux_value<0){
               aux_value=value;
            }
         }
     }else{
           aux_value=0;
     }

     //Visualizacion de la senal tratada en el puerto B
     LATB = (aux_value);

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
     if (i<nm){
        M[i] = ADC1BUF0;                           //Almacena el valor actual de la conversion del ADC en el vector M
        i++;                                       //Aumenta en 1 el subindice del vector de Muestras
     } else {
        bm = 1;                                    //Cuando el indice del vector de muestras M llega a nm, habilta la bandera bm para terminar con el muestreo y permitir la reconstruccion de la señal mediante el mismo TMR1
        i = 0;                                     //Limpia el indice del vector de muestras
        IEC0.T1IE = 0;                             //Desabilita la interrupcion por desborde del TMR1
        //IEC0.AD1IE = 0;                            //Desabilita la interrupcion por conversion completa del ADC
     }
     AD1IF_bit = 0;                                //Limpia la bandera de interrupcion del ADC
}
//Interrupcion por desbordamiento del TMR1
void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
     LATA1_bit = ~LATA1_bit;
     if (bm==0){                                   //Cuando la bandera bm=0, la interrupcion por TMR1 es utilizada para el muestreo de la señal de entrada
        SAMP_bit = 0;                              //Limpia el bit SAMP para iniciar la conversion del ADC
     }
     if (bm==1) {                                  //Cuando la bandera bm=1, la interrupcion por TMR1 es utilizada para la reconstruccion de la señal mediante el DAC
          if (j<nm){
             LATB = M[j];
             j++;
          } else {
             j = 0;
             bm = 0;
          }
     }
     T1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
}
//Interrupcion por desbordamiento del TMR2
void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
     if (contp<20){                                //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (
          BS = ~BS;                                //Variable auxiliar para establecer el cambio de estado en el bit RD0.
          RB14_bit = BS;
     }else {
          RB14_bit = 0;                            //Pone a cero despues de enviar todos los pulsos de exitacion.
          IEC0.T2IE = 0;                           //Desabilita la interrupcion por desborde del TMR2 para no interferir con las interrupciones por desborde de TMR1 y por conversion completa del ADC
          IEC0.T1IE = 1;                           //Habilita la interrupcion por desborde del TMR1 para dar inicio al muestreo del ADC
          IEC0.AD1IE = 1;                          //Habilita la interrupcion por conversion completa del ADC
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
     TRISA1_bit = 0;                             //Set RA1 pin as output
     TRISB = 0x8000;                             //Establece los pines 0-14 de PORTB como salidas y el pin 15 como entrada

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

     //IEC0.AD1IE = 0x00;                          //Activa la interrupcion por conversion completa del ADC

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
     
     //Nivel de prioridad de las interrupciones (+alta -> +prioridad)
     IPC3bits.AD1IP = 0x06;                      //Nivel de prioridad de interrupcion del ADC
     IPC0bits.T1IP = 0x07;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR1
     IPC1bits.T2IP = 0x05;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR2

}


//////////////////////////////////////////////////////////////// main ////////////////////////////////////////////////////////////////
void main() {

     Configuracion();
     
     while(1){
     
              IEC0.T1IE = 0;                     //Desabilita la interrupcion por desborde del TMR1 para no interferir con la lectura del sensor de temperatura

              Velocidad();                       //Llama a la funcion para calcular la Velocidad del sonido

              contp = 0;                         //Limpia la variable del contador de pulsos
              BS = 0;                            //Limpia la variable auxiliar de cambio de estado de los pulsos
              
              i = 0;                             //Limpia las variables asociadas al almacenamiento de la señal muestreada
              j = 0;
              bm = 0;
              
              IEC0.T2IE = 1;                     //Habilita la interrupcion pos desborde del TMR2
              T2CON.TON = 1;                     //Enciende el TMR2
              
              //--------------------------------------------------------------------------------------------------------------------------------------
              
              Delay_ms(10);

              
              if (bm==1) {
                 IEC0.T1IE = 1;
              }
              
              //IEC0.T1IE = 1;

              //VP = 0;                  //Limpia la variable de deteccion del punto maximo

              
              //Delay_ms(30);
     }

}