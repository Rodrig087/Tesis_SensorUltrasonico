                                          /*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 13/01/2017
Configuracion: dsPIC P33FJ32MC202, XT=8MHz, PLL=80MHz
Descripcion:
1.
---------------------------------------------------------------------------------------------------------------------------*/
//Funcion de transferencia h(n) filtro FIR (Fs=200KHz, Fc=5547Hz) Ventana Hamming
const float h[]=
{
0,                        //h(0)
8.655082858474001e-04,    //h(1)
0.003740336116716,        //h(2)
0.008801023059201,        //h(3)
0.015858487391720,        //h(4)
0.024356432913204,        //h(5)
0.033436118860918,        //h(6)
0.042058476113843,        //h(7)
0.049163467317092,        //h(8)
0.053839086446614,        //h(9)
0.055470000000000,        //h(10)
0.053839086446614,        //h(11)
0.049163467317092,        //h(12)
0.042058476113843,        //h(13)
0.033436118860918,        //h(14)
0.024356432913204,        //h(15)
0.015858487391720,        //h(16)
0.008801023059201,        //h(17)
0.003740336116716,        //h(18)
8.655082858474001e-04,    //h(19)
0                         //h(20)
};


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
unsigned int Altura;                                    //Variable para almacenar la Altura de instalacion del sensor
unsigned int Nivel;
float FNivel, FCaudal;                                  //Variables para almacenar el Nivel y el Caudal en punto flotante
unsigned int Temperatura, Caudal, Kadj, ITOF;           //Variables para almacenar la Temperatura, Caudal, factor de calibracion, TOF en entero sin signo
unsigned char *chTemp, *chCaudal, *chNivel, 
*chKadj, *chTOF, *chAltura;                             //Variables tipo puntero para la Temperatura, Caudal, Nivel, factor de calibracion, TOF
float FDReal;                                           //Variable para almacenar la distancia real para la calibracion
unsigned int IT2prom;
unsigned char *chT2prom;
float doub;
float *iptr;
short num;                                              //Variable para realizar pruebas

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
const unsigned short O = 21;
float XFIR[O];
unsigned int f;
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
const short dix=20;                                     //Intervalo de interpolacion
const float tx=5.0;                                     //Periodo de muestreo
int yy0, yy1, yy2;
float yf0, yf1, yf2;
float nx, dx, tmax;

//Variables para calcular la Distancia
short conts;
float T2a, T2b;
const short Nsm=3;                                      //Numero maximo de secuencias de medicion (3)
const float T2umb = 3.0;                                //Umbral para precision (3us)
const float T1 = 1375.0;                                //T0+T1
float T2adj;                                            //Variable para la calibracion de T2
float T2sum,T2prom;
float T2, TOF, Dst;
unsigned int IDst;
unsigned char *chIDst;
long TT2;
unsigned char *chTT2;
unsigned int Cdistancia;
unsigned int Vdistancia[10];

//Variables para calcular la moda estadistica
unsigned int ME1=0, ME2=0, ME3=0;                       //Variables para almacenar los 3 posibles valores de una medicion de distancia
unsigned short Mb2=0, Mb3=0;                            //Banderas
unsigned short Mc1=0, Mc2=0, Mc3=0;                     //Contadores de mediciones de distancia
unsigned short mi=0, vi=0;                              //Subindices para el calculo de la Moda y la Distancia
const short nd = 10;                                    //Numero de secuencias de medicion de Distancia

/////////////////////////////////////////////////////////////////// Funciones //////////////////////////////////////////////////////////////
//Funcion para el calculo de la Velocidad del sonido en funcion de la temperatura registrada por el sensor DS18B20
void Velocidad(){
     unsigned int Temp;
     unsigned int Rint;
     float Rfrac;

     Ow_Reset(&PORTA, 0);                          //Onewire reset signal
     Ow_Write(&PORTA, 0, 0xCC);                    //Issue command SKIP_ROM
     Ow_Write(&PORTA, 0, 0x44);                    //Issue command CONVERT_T
     Delay_us(100);

     Ow_Reset(&PORTA, 0);
     Ow_Write(&PORTA, 0, 0xCC);                    //Issue command SKIP_ROM
     Ow_Write(&PORTA, 0, 0xBE);                    //Issue command READ_SCRATCHPAD
     Delay_us(100);

     Temp =  Ow_Read(&PORTA, 0);
     Temp = (Ow_Read(&PORTA, 0) << 8) + Temp;

     if (Temp & 0x8000) {
        Temp = 0;                                  //Si la temperatura es negativa la establece como cero.
     }

     Rint = Temp >> 4;                             //Extrae la parte entera de la respuesta del sensor
     Rfrac = ((Temp & 0x000F) * 625) / 10000.;     //Extrae la parte decimal de la respuesta del sensor
     DSTemp = Rint + Rfrac;                        //Expresa la temperatura en punto flotante

     VSnd = 331.45 * sqrt(1+(DsTemp/273));
}

//Funcion para la generacion y procesamiento de la señal
void Pulse(){

            // Generacion de pulsos y captura de la señal de retorno //
            contp = 0;                                               //Limpia la variable del contador de pulsos
            RB2_bit = 0;                                             //Limpia el pin que produce los pulsos de exitacion del transductor

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
                    //Corrimiento continuo de la señal x[n]
                    for( f=O-1; f!=0; f-- ) XFIR[f]=XFIR[f-1];
                    //Adquisición de una muestra de 10 bits en, x[0]
                    XFIR[0] = (float)(value);
                    //Convolución continúa.
                    y0 = 0.0; for( f=0; f<O; f++ ) y0 += h[f]*XFIR[f];

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

int Moda(int VRpt[nd]){
    
    ME1=0;
    ME2=0;
    ME3=0;
    Mb2=0;
    Mb3=0;
    Mc1=0;
    Mc2=0;
    Mc3=0;
    
    ME1=VRpt[0];
    
    for (mi=0;mi<nd;mi++){
        if (VRpt[mi]==ME1){
           Mc1++;
        }else{
            if (Mb2==0){
               ME2=VRpt[mi];
               Mb2=1;
            }
            if (VRpt[mi]==ME2){
               Mc2++;
            }else{
                  if (Mb3==0){
                     ME3=VRpt[mi];
                     Mb3=1;
                  }
                  if (VRpt[mi]==ME3){
                     Mc3++;
                  }
            }
        }
    
    }
    
    if ((Mc1>Mc2)&&(Mc1>Mc3)){
       return ME1;
    }
    if ((Mc2>Mc1)&&(Mc2>Mc3)){
       return ME2;
    }
    if ((Mc3>Mc1)&&(Mc3>Mc2)){
       return ME3;
    }
    
    if (Mc1==Mc2){
       return ME1;
    }
    if (Mc1==Mc3){
       return ME1;
    }
    if (Mc2==Mc3){
       return ME2;
    }
    

}

//Funcion para el calculo de la Distancia
int Distancia(){

     conts = 0;                               //Limpia el contador de secuencias
     T2sum = 0.0;
     T2prom = 0.0;
     T2a = 0.0;
     T2b = 0.0;

     while (conts<Nsm){
           Pulse();                           //Inicia una secuencia de medicion
           T2b = T2;
           if ((T2b-T2a)<=T2umb){             //Verifica si el T2 actual esta dentro de un umbral pre-establecido
              T2sum = T2sum + T2b;            //Acumula la sumatoria de valores de T2 calculados por la funcion Pulse()
              conts++;                        //Aumenta el contador de secuencias
           }
           T2a = T2b;
     }

     T2prom = T2sum/Nsm;

     Velocidad();                             //Calcula la velocidad del sonido
     //VSnd = 343.2;

     TOF = (T1+T2prom-T2adj)/1.0e6;           //Calcula el TOF en seg
     Dst = (VSnd*TOF/2.0) * 1000.0;           //Calcula la distancia en mm
     doub = modf(Dst, &iptr);
     if (doub>=0.5){
        Dst=ceil(Dst);
     }else{
        Dst=floor(Dst);
     }
     
     return Dst;

}

void Calcular(){

     if (Ptcn[4]==0x04){
     
        Velocidad();
        Temperatura = (unsigned int)(DSTemp);    //Tranforma el dato de Temperatura de float a entero sin signo
        chTemp = (unsigned char *) & Temperatura;//Asocia el valor calculado de Temperatura al puntero chTemp
        
     } else {
     
       for (vi=0;vi<nd;vi++){
           Vdistancia[vi] = Distancia();        //Toma 10 lecturas de la distancia calculada y las almacena en un vector
       }

       Cdistancia = Moda(Vdistancia);           //Calcula la Moda del vector de distancias
       
       //Correccion de la distancia
       if ((Cdistancia>=268)&&(Cdistancia<=283)){
          Cdistancia = Cdistancia - 3;
       } else {
          Cdistancia = Cdistancia + 1;
       }

       Cdistancia = Cdistancia + (float)(Kadj); //Ajusta el valor de la Distancia calculada segun el factor de calibracion Kadj
       Nivel = Altura - Cdistancia;             //Calcula el Nivel en mm
       FNivel = Nivel/1000.0;                   //Calcula el Nivel de liquido en metros
       FCaudal = 4960440*pow(FNivel,2.5);       //Calcula el Caudal en litros/hora

       IDst = (unsigned int)(Cdistancia);       //Tranforma el dato de distancia de float a entero sin signo
       Caudal = (unsigned int)(FCaudal);        //Tranforma el dato de Caudal de float a entero sin signo
       ITOF = (unsigned int)(TOF);              //Tranforma el dato de TOF de float a entero sin signo

       chIDst = (unsigned char *) & IDst;       //Asocia el valor calculado de IDst al puntero chDst
       chNivel = (unsigned char *) & Nivel;     //Asocia el valor calculado de Nivel al puntero chNivel
       chCaudal = (unsigned char *) & Caudal;   //Asocia el valor calculado de Caudal al puntero chCaudal
       chTOF = (unsigned char *) & ITOF;        //Asocia el valor calculado de TOF al puntero chTOF
     
     }
}

//Funcion para Responder una peticion
void Responder(unsigned int Reg){

     switch(Reg){
         case 1:    //Respuesta de Nivel
                    for (ir=4;ir>=3;ir--){
                        Rspt[ir]=(*chNivel++);             //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del Nivel calculado
                    }
                    Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
                    break;
                    
         case 2:    //Respuesta de Distancia
                    for (ir=4;ir>=3;ir--){
                        Rspt[ir]=(*chIDst++);              //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del Distancia calculada
                    }
                    Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
                    break;
                    
         case 3:    //Respuesta de TOF
                    for (ir=4;ir>=3;ir--){
                        Rspt[ir]=(*chTOF++);               //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del TOF calculado
                    }
                    Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
                    break;
                    
         case 4:    //Respuesta de Temperatura
                    for (ir=4;ir>=3;ir--){
                        Rspt[ir]=(*chTemp++);              //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Temperatura calculada
                    }
                    break;
                    
         case 5:    //Respuesta de Caudal
                    for (ir=4;ir>=3;ir--){
                        Rspt[ir]=(*chCaudal++);            //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del Caudal calculado
                    }
                    Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
                    break;
                    
         case 6:    //Respuesta de Altura de instalacion
                    chAltura = (unsigned char *) & Altura; //Asocia el valor de la variable Altura  al puntero chDst
                    for (ir=4;ir>=3;ir--){
                        Rspt[ir]=(*chAltura++);            //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Altura de instalacion
                    }
                    Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
                    break;
         
         default:   Rspt[3]=0x00;                          //Rellena el campo de datos con el mensaje de error 0x00E2: Registro no disponible
                    Rspt[4]=0xE2;
                    Rspt[2]=0xEE;                          //Rellena el byre 2 con el aviso de error 0xEE
     }
     
     if (Reg==0x01){
        for (ir=4;ir>=3;ir--){
            Rspt[ir]=(*chIDst++);             //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Distancia calculada
        }
     }
     if (Reg==0x02){
        for (ir=4;ir>=3;ir--){
            Rspt[ir]=(*chCaudal++);           //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del Caudal calculado
        }
     }
     if (Reg==0x03){
        for (ir=4;ir>=3;ir--){
            Rspt[ir]=(*chTemp++);             //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Temperatura calculada
        }
     }
     if (Reg==0x03){
        for (ir=4;ir>=3;ir--){
            Rspt[ir]=(*chTemp++);             //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Temperatura calculada
        }
     }
     if (Reg==0x03){
        for (ir=4;ir>=3;ir--){
            Rspt[ir]=(*chTemp++);             //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Temperatura calculada
        }
     }
     

     RB5_bit = 1;                             //Establece el Max485 en modo de escritura
     for (ir=0;ir<Rsize;ir++){
         UART1_Write(Rspt[ir]);               //Envia la trama de respuesta
     }
     while(UART1_Tx_Idle()==0);               //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
     RB5_bit = 0;                             //Establece el Max485 en modo de lectura;

     for (ipp=3;ipp<5;ipp++){
         Rspt[ipp]=0;;                        //Limpia la trama de respuesta
     }

}

////////////////////////////////////////////////////////////// Interrupciones //////////////////////////////////////////////////////////////
//Interrupcion por recepcion de datos a travez de UART
void UART1Interrupt() iv IVT_ADDR_U1RXINTERRUPT {

     if (UART1_Data_Ready()==1){
        Dato = UART1_Read();
     }
     if ((Dato==Hdr)&&(ip==0)){                    //Verifica que el primer dato en llegar sea el identificador de inicio de trama
         BanT = 1;                                 //Activa la bandera de trama
         Ptcn[ip] = Dato;                          //Almacena el Dato en la trama de peticion
     }
     if ((Dato!=Hdr)&&(ip==0)){                    //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
         ip=-1;                                    //Si es asi: reduce el subindice en una unidad
     }
     if ((BanT==1)&&(ip!=0)){
         Ptcn[ip] = Dato;                          //Almacena el resto de datos en la trama de peticion si la bandera de trama esta activada
     }

     ip++;                                         //Aumenta el subindice una unidad
     if (ip==Psize){                               //Verifica que se haya terminado de llenar la trama de datos
         BanP = 1;                                 //Habilita la bandera de lectura de datos
         BanT = 0;
         ip=0;                                     //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
     }

     U1RXIF_bit = 0;                               //Limpia la bandera de interrupcion de UARTRX

}

//Interrupcion por desbordamiento del TMR1
void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{

     SAMP_bit = 0;                                 //Limpia el bit SAMP para iniciar la conversion del ADC
     while (!AD1CON1bits.DONE);                    //Espera hasta que se complete la conversion
     if (i<nm){
        M[i] = ADC1BUF0;                           //Almacena el valor actual de la conversion del ADC en el vector M
        i++;                                       //Aumenta en 1 el subindice del vector de Muestras
     } else {
        bm = 1;                                    //Cambia el valor de la bandera bm para terminar con el muestreo y dar comienzo al procesamiento de la señal
        T1CON.TON = 0;                             //Apaga el TMR1
        IEC0.T1IE = 0;                             //Desabilita la interrupcion por desborde del TMR1
     }
     T1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
}

//Interrupcion por desbordamiento del TMR2
void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
     if (contp<10){                                //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (
          RB2_bit = ~RB2_bit;                      //Conmuta el valor del pin RB14
     }else {
          RB2_bit = 0;                            //Pone a cero despues de enviar todos los pulsos de exitacion.

          if (contp==110){
              IEC0.T2IE = 0;                       //Desabilita la interrupcion por desborde del TMR2 para no interferir con las interrupciones por desborde de TMR1
              T2CON.TON = 0;                       //Apaga el TMR2
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
     AD1PCFGL = 0xFFFD;                          //Configura el puerto AN1 como entrada analogica y todas las demas como digitales
     TRISA1_bit = 1;                             //Establece el pin RA1 como entrada
     TRISB = 0xFF40;                             //TRISB = 11111111 01000000

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
     AD1CON2.BUFM = 0;                           //Bit de selección del modo de relleno del búfer, 0 -> Siempre comienza a llenar el buffer desde el principio
     AD1CON2.ALTS = 0x00;                        //Utiliza siempre la selección de entrada de canal para la muestra A

     AD1CON3.ADRC = 0;                           //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
     AD1CON3bits.ADCS = 0x02;                    //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
     AD1CON3bits.SAMC = 0x02;                    //Auto Sample Time bits, 2 -> 2*TAD (minimo periodo de muestreo para 10 bits)

     AD1CHS0.CH0NB = 0;                          //Channel 0 negative input is VREF-
     AD1CHS0bits.CH0SB = 0x01;                   //Channel 0 positive input is AN1
     AD1CHS0.CH0NA = 0;                          //Channel 0 negative input is VREF-
     AD1CHS0bits.CH0SA = 0x01;                   //Channel 0 positive input is AN1

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

      //Configuracion UART
     RPINR18bits.U1RXR = 0x06;                   //Asisgna Rx a RP6
     RPOR3bits.RP7R = 0x03;                      //Asigna Tx a RP7
     IEC0.U1RXIE = 1;                            //Habilita la interrupcion por recepcion de dato por UART
     U1RXIF_bit = 0;                             //Limpia la bandera de interrupcion de UARTRX

     //Nivel de prioridad de las interrupciones (+alta -> +prioridad)
     IPC0bits.T1IP = 0x06;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR1
     IPC1bits.T2IP = 0x05;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR2
     IPC2bits.U1RXIP = 0x07;                     //Nivel de prioridad de la interrupcion UARTRX



}


//////////////////////////////////////////////////////////////// main ////////////////////////////////////////////////////////////////
void main() {

     Configuracion();

     UART1_Init(9600);                                        //Inicializa el modulo UART a 9600 bps
     Delay_ms(100);                                           //Espera hata que el modulo UART se estabilice
     RB5_bit = 0;                                             //Establece el Max485 en modo de lectura

     Id = (PORTB&0xFF00)>>8;                                  //Lee el Id de esclavo establecido por el dipswitch
     T2adj = 460.0;                                           //Factor de calibracion de T2: Con Temp=20 y Vsnd=343.2, reduce la medida 1mm por cada 3 unidades que se aumente a este factor
     //T2adj = 280.0;
     Altura = 300;                                            //Fija la altura de instalacion del sensor en 300mm
     Kadj = 0;                                                //Fija la constante de ajuste en 0
     
     chDP = &DatoPtcn;                                        //Asocia el valor de DatoPtcn al puntero chDP
     ip=0;

     Rspt[0] = Hdr;                                           //Se rellena el primer byte de la trama de respuesta con el delimitador de inicio de trama
     Rspt[1] = Id;                                            //Se rellena el segundo byte de la trama de repuesta con el Id del tipo de sensor
     Rspt[Rsize-1] = End;                                     //Se rellena el ultimo byte de la trama de repuesta con el delimitador de final de trama

     while(1){

              /*BanP=1;
              Ptcn[0]=Hdr;
              Ptcn[1]=Id;
              Ptcn[2]=0x01;
              Ptcn[3]=0x00;
              Ptcn[4]=0x00;
              Ptcn[5]=End;*/


              if (BanP==1){                                   //Verifica si se realizo una peticion

                 if ((Ptcn[1]==Id)&&(Ptcn[Psize-1]==End)){    //Verifica el identificador de esclavo y el byte de final de trama

                    Fcn = Ptcn[2];                            //Almacena el tipo de funcion requerida

                    switch(Fcn){
                        case 1:    //01: Lee el registro principal (05:Caudal)
                                   Calcular();                //Realiza una secuencia de calculo
                                   Responder(0x06);           //Envia la trama de repuesta con el valor del registro principal
                        
                        case 2:    //02: Lee el registro especifico (01:Nivel, 02:Distancia, 03:TOF, 04:Temperatura)
                                   Calcular();                //Realiza una secuencia de calculo
                                   *chDP = Ptcn[4];           //Almacena el byte 4 de la trama de peticion en el LSB de la variable DatoPtcn
                                   *(chDP+1) = Ptcn[3];       //Almacena el byte 3 de la trama de peticion en el MSB de la variable DatoPtcn
                                   Responder(DatoPtcn);       //Envia la trama de repuesta con el valor del registro requerido
                        
                        case 3:    //03: Establece la altura de instalacion
                                   *chDP = Ptcn[4];           //Almacena el byte 4 de la trama de peticion en el LSB de la variable DatoPtcn
                                   *(chDP+1) = Ptcn[3];       //Almacena el byte 3 de la trama de peticion en el MSB de la variable DatoPtcn
                                   Altura =  DatoPtcn;        //Almacena el valor de DatoPtcn en la variable Altura
                                   Responder(0x06);           //Envia la trama de repuesta con el valor de la Altura de instalacion
                        
                        case 4:    //04: Establece el factor de calibracion
                                   *chDP = Ptcn[4];           //Almacena el byte 4 de la trama de peticion en el LSB de la variable DatoPtcn
                                   *(chDP+1) = 0x00;          //Establece en 0 el MSB de la variable DatoPtcn
                                   Kadj = DatoPtcn;           //Almacena el valor de DatoPtcn en la variable Kadj
                                   if (Ptcn[3]==0x11){        //Verifica si el byte 3 es igual a 0x11, de ser asi cambia el signo de la variable Kadj
                                      Kadj = -Kadj;
                                   }
                                   Calcular();                //Realiza una secuencia de calculo
                                   Responder(0x02);           //Envia la trama de repuesta con el valor de la Distancia calculada
                        
                        default:   Rspt[3]=0x00;              //Rellena el campo de datos con el mensaje de error 0x00E1: Funcion no disponible
                                   Rspt[4]=0xE1;
                                   Rspt[2]=0xEE;              //Rellena el byte 2 con el aviso de error 0xEE
                    }

                    DatoPtcn = 0;                             //Limpia la variable DatoPtcn
                    
                    for (ipp=0;ipp<Psize;ipp++){
                        Ptcn[ipp]=0;                          //Limpia la trama de peticion
                    }
                    
                    BanP = 0;                                 //Limpia la bandera de lectura de datos

                 }else{
                       for (ipp=0;ipp<Psize;ipp++){
                           Ptcn[ipp]=0;                       //Limpia la trama de peticion
                       }
                       BanP = 0;                              //Limpia la bandera de lectura de datos
                 }
              }

     }

}