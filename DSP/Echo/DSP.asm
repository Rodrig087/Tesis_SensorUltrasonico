
_Interrupt:

;DSP.c,16 :: 		void Interrupt(){
;DSP.c,19 :: 		if (TMR2IF_bit){
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_Interrupt0
;DSP.c,20 :: 		if (ie==1){
	MOVF        _ie+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt1
;DSP.c,21 :: 		if ((contp>(delay_p))&&(contp<(delay_p+(np*2)))){
	MOVLW       0
	MOVWF       R0 
	MOVF        _contp+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt11
	MOVF        _contp+0, 0 
	SUBLW       120
L__Interrupt11:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt4
	MOVLW       0
	SUBWF       _contp+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt12
	MOVLW       130
	SUBWF       _contp+0, 0 
L__Interrupt12:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt4
L__Interrupt8:
;DSP.c,22 :: 		RD0_bit = ~RD0_bit;
	BTG         RD0_bit+0, BitPos(RD0_bit+0) 
;DSP.c,23 :: 		}
L_Interrupt4:
;DSP.c,24 :: 		if (contp==(delay_p+(np*2))){
	MOVLW       0
	XORWF       _contp+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt13
	MOVLW       130
	XORWF       _contp+0, 0 
L__Interrupt13:
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt5
;DSP.c,25 :: 		TMR2ON_bit=0;                          //Apaga el TMR2
	BCF         TMR2ON_bit+0, BitPos(TMR2ON_bit+0) 
;DSP.c,26 :: 		RD0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;DSP.c,27 :: 		ie = 0;
	CLRF        _ie+0 
;DSP.c,28 :: 		contp = 0;
	CLRF        _contp+0 
	CLRF        _contp+1 
;DSP.c,29 :: 		}
L_Interrupt5:
;DSP.c,30 :: 		}
L_Interrupt1:
;DSP.c,31 :: 		contp++;                                  //Aumenta el contador en una unidad.
	INFSNZ      _contp+0, 1 
	INCF        _contp+1, 1 
;DSP.c,32 :: 		TMR2IF_bit = 0;                           //Limpia la bandera de interrupcion de Timer2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;DSP.c,33 :: 		}
L_Interrupt0:
;DSP.c,36 :: 		if (INTCON.INT0IF == 1){
	BTFSS       INTCON+0, 1 
	GOTO        L_Interrupt6
;DSP.c,37 :: 		if (ie==0){
	MOVF        _ie+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt7
;DSP.c,38 :: 		TMR2ON_bit=1;                          //Enciende el TMR2.
	BSF         TMR2ON_bit+0, BitPos(TMR2ON_bit+0) 
;DSP.c,39 :: 		RD1_bit = ~RD1_bit;
	BTG         RD1_bit+0, BitPos(RD1_bit+0) 
;DSP.c,40 :: 		}
L_Interrupt7:
;DSP.c,41 :: 		ie = 1;
	MOVLW       1
	MOVWF       _ie+0 
;DSP.c,42 :: 		INTCON.INT0IF = 0;                              //Limpia la bandera de interrupcion de INT0.
	BCF         INTCON+0, 1 
;DSP.c,43 :: 		}
L_Interrupt6:
;DSP.c,45 :: 		}
L_end_Interrupt:
L__Interrupt10:
	RETFIE      1
; end of _Interrupt

_Configuracion:

;DSP.c,47 :: 		void Configuracion() {
;DSP.c,49 :: 		INTCON.GIE = 1;                             //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;DSP.c,50 :: 		INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;DSP.c,52 :: 		INTCON.INT0IE = 1;                          //Habilita la interrupcion externas en INT0  !!!
	BSF         INTCON+0, 4 
;DSP.c,53 :: 		INTCON2.RBPU = 1;                           //PORTB pull-ups are enabled by individual port latch values
	BSF         INTCON2+0, 7 
;DSP.c,54 :: 		INTCON2.INTEDG0 = 1;                        //Habilita la interrupcion por flanco de subida
	BSF         INTCON2+0, 6 
;DSP.c,56 :: 		ADCON1 = 0b00001111;                        //Configuracion ADCON1
	MOVLW       15
	MOVWF       ADCON1+0 
;DSP.c,57 :: 		CMCON = 0b00000111;
	MOVLW       7
	MOVWF       CMCON+0 
;DSP.c,59 :: 		T2CON = 0x00;                               //Configuracion T2CON: Post-escalador 1:1, Timer2 Off, Pre-escalador 1:1
	CLRF        T2CON+0 
;DSP.c,60 :: 		PIE1.TMR2IE = 1;                            //Habilita la interrupcion por desborde de Timer2                        ====> La interrupcion del TMR2 interfiere con la conversion del DHT22
	BSF         PIE1+0, 1 
;DSP.c,61 :: 		PR2 = 149;                                  //Produce una interrupcion cada 12,5us
	MOVLW       149
	MOVWF       PR2+0 
;DSP.c,64 :: 		TRISD0_bit = 0;                             //Establece el pin D0 como salida
	BCF         TRISD0_bit+0, BitPos(TRISD0_bit+0) 
;DSP.c,65 :: 		TRISD1_bit = 0;
	BCF         TRISD1_bit+0, BitPos(TRISD1_bit+0) 
;DSP.c,67 :: 		ie = 0;
	CLRF        _ie+0 
;DSP.c,69 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;DSP.c,72 :: 		void main() {
;DSP.c,74 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;DSP.c,75 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
