/*-------------------------------------------------------------------------------------------------------------------------
Autor: Milton Munoz
Fecha de creacion: 13/12/2016
Configuracion: dsPIC P33FJ12GP201, XT=8MHz, PLL=80MHz
Descripcion:
1.Genera los pulsos de exitacion para el transductor ultrasonico.

---------------------------------------------------------------------------------------------------------------------------*/



void MainInit(){

     //Configuracion del PLL para generar un FOSC de 80MHz  a partir de un oscilador externo de 8MHz
     CLKDIVbits.PLLPRE = 0;   //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
     PLLFBD = 38;             //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
     CLKDIVbits.PLLPOST = 0;  //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
     
     //Configuracion de puertos
     TRISB = 0;             // Initialize PORTB as output
     LATB = 0;              // Set PORTB to zero

}

void main()
 {
 MainInit();
 while (1)                      // Infinite loop
 {
       LATB0_bit = ~LATB0_bit;        // Invert PORTB value
       Delay_us(10);
       
 }

}