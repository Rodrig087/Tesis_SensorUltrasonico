/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 16/12/2016
Configuracion: PIC18F4550 8MHz, PLL activado 48MHz
Descripcion:
1.

---------------------------------------------------------------------------------------------------------------------------*/

// Declaracion de variables //
unsigned int contp;
unsigned short ie;
const short delay_p = 120;
const short np = 5;

void Interrupt(){

// Interrupcion por desbordamiento de TIMER 2 //
     if (TMR2IF_bit){
        if (ie==1){
            if ((contp>(delay_p))&&(contp<(delay_p+(np*2)))){
               RD0_bit = ~RD0_bit;
            }
            if (contp==(delay_p+(np*2))){
               TMR2ON_bit=0;                          //Apaga el TMR2
               RD0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
               ie = 0;
               contp = 0;
            }
        }
        contp++;                                  //Aumenta el contador en una unidad.
        TMR2IF_bit = 0;                           //Limpia la bandera de interrupcion de Timer2
     }
     
// Interrupcion INT0 //
    if (INTCON.INT0IF == 1){
       if (ie==0){
          TMR2ON_bit=1;                          //Enciende el TMR2.
          RD1_bit = ~RD1_bit;
       }
       ie = 1;
       INTCON.INT0IF = 0;                              //Limpia la bandera de interrupcion de INT0.
    }
     
}

void Configuracion() {

     INTCON.GIE = 1;                             //Habilita las interrupciones globales
     INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas

     INTCON.INT0IE = 1;                          //Habilita la interrupcion externas en INT0  !!!
     INTCON2.RBPU = 1;                           //PORTB pull-ups are enabled by individual port latch values
     INTCON2.INTEDG0 = 1;                        //Habilita la interrupcion por flanco de subida

     ADCON1 = 0b00001111;                        //Configuracion ADCON1
     CMCON = 0b00000111;

     T2CON = 0x00;                               //Configuracion T2CON: Post-escalador 1:1, Timer2 Off, Pre-escalador 1:1
     PIE1.TMR2IE = 1;                            //Habilita la interrupcion por desborde de Timer2                        ====> La interrupcion del TMR2 interfiere con la conversion del DHT22
     PR2 = 149;                                  //Produce una interrupcion cada 12,5us


     TRISD0_bit = 0;                             //Establece el pin D0 como salida
     TRISD1_bit = 0;

     ie = 0;

}


void main() {

     Configuracion();
}