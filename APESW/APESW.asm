
_Interrupt:

;APESW.c,56 :: 		void Interrupt(){
;APESW.c,59 :: 		if (TMR2IF_bit){                             //Verifica si ocurrio una interrupcion por desbordamiento del TMR2.
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_Interrupt0
;APESW.c,61 :: 		RD1_bit = ~RD1_bit;                       //Genera un tren de pulsos de 40KHz en el pin RD1
	BTG         RD1_bit+0, BitPos(RD1_bit+0) 
;APESW.c,63 :: 		if (contw<=67){                           //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (43)
	MOVLW       0
	MOVWF       R0 
	MOVF        _contw+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt20
	MOVF        _contw+0, 0 
	SUBLW       67
L__Interrupt20:
	BTFSS       STATUS+0, 0 
	GOTO        L_Interrupt1
;APESW.c,64 :: 		BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
	COMF        _BS+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _BS+0 
;APESW.c,65 :: 		RD0_bit = BS;
	BTFSC       R0, 0 
	GOTO        L__Interrupt21
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
	GOTO        L__Interrupt22
L__Interrupt21:
	BSF         RD0_bit+0, BitPos(RD0_bit+0) 
L__Interrupt22:
;APESW.c,67 :: 		if (contw==90){                        //Se empieza a contar el tiempo desde el primer pulso en alto despues del cambio de fase. 25
	MOVLW       0
	XORWF       _contw+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt23
	MOVLW       90
	XORWF       _contw+0, 0 
L__Interrupt23:
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt2
;APESW.c,68 :: 		TMR1ON_bit=1;                       //Enciende el TMR1.
	BSF         TMR1ON_bit+0, BitPos(TMR1ON_bit+0) 
;APESW.c,69 :: 		TMR1L=0X00;                         //Limpia los bits menos significativos del TMR1.
	CLRF        TMR1L+0 
;APESW.c,70 :: 		TMR1H=0X00;                         //Limpia los bits mas significativos del TMR1.
	CLRF        TMR1H+0 
;APESW.c,71 :: 		}
L_Interrupt2:
;APESW.c,72 :: 		if ((contw==22)||(contw==45)){                        //Cambia el valor de la variable auxiliar para producir  (22)
	MOVLW       0
	XORWF       _contw+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt24
	MOVLW       22
	XORWF       _contw+0, 0 
L__Interrupt24:
	BTFSC       STATUS+0, 2 
	GOTO        L__Interrupt17
	MOVLW       0
	XORWF       _contw+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt25
	MOVLW       45
	XORWF       _contw+0, 0 
L__Interrupt25:
	BTFSC       STATUS+0, 2 
	GOTO        L__Interrupt17
	GOTO        L_Interrupt5
L__Interrupt17:
;APESW.c,73 :: 		BS = ~BS;                          //el cambio de fase en la siguiente iteracion.
	COMF        _BS+0, 1 
;APESW.c,74 :: 		}
L_Interrupt5:
;APESW.c,76 :: 		} else {
	GOTO        L_Interrupt6
L_Interrupt1:
;APESW.c,77 :: 		RD0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;APESW.c,78 :: 		FP = 1;                                //Habilita la bandera de deteccion de fase para permitir la deteccion una vez que se hayan terminado de enviar todos los pulsos de exitacion
	MOVLW       1
	MOVWF       _FP+0 
;APESW.c,79 :: 		}
L_Interrupt6:
;APESW.c,81 :: 		if (contw>=800){                          //Limpia el contador cada 800 interrupciones (10ms) para el reenvio de los pulsos
	MOVLW       3
	SUBWF       _contw+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt26
	MOVLW       32
	SUBWF       _contw+0, 0 
L__Interrupt26:
	BTFSS       STATUS+0, 0 
	GOTO        L_Interrupt7
;APESW.c,82 :: 		contw = 0;                             //de exitacion del transductor ultrasonico.
	CLRF        _contw+0 
	CLRF        _contw+1 
;APESW.c,83 :: 		T1=0;
	CLRF        _T1+0 
	CLRF        _T1+1 
;APESW.c,84 :: 		T2=0;
	CLRF        _T2+0 
	CLRF        _T2+1 
;APESW.c,85 :: 		DT=0;
	CLRF        _DT+0 
	CLRF        _DT+1 
;APESW.c,86 :: 		}
L_Interrupt7:
;APESW.c,88 :: 		contw++;                                  //Aumenta el contador en una unidad.
	INFSNZ      _contw+0, 1 
	INCF        _contw+1, 1 
;APESW.c,89 :: 		TMR2IF_bit = 0;                           //Limpia la bandera de interrupcion de Timer2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;APESW.c,90 :: 		}
L_Interrupt0:
;APESW.c,94 :: 		if (INTCON.INT0IF == 1){                     //Verifica si ocurrio una interrupcion externa en INT0.
	BTFSS       INTCON+0, 1 
	GOTO        L_Interrupt8
;APESW.c,95 :: 		*(punT1) = TMR1L;                         //Carga el valor actual de TMR1L en los 8 bits menos significativos de la variable contT de tipo entero.
	MOVFF       _punT1+0, FSR1
	MOVFF       _punT1+1, FSR1H
	MOVF        TMR1L+0, 0 
	MOVWF       POSTINC1+0 
;APESW.c,96 :: 		*(punT1+1) = TMR1H;                       //Carga el valor actual de TMR1H en los 8 bits mas significativos de la variable  contT de tipo entero.
	MOVLW       1
	ADDWF       _punT1+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _punT1+1, 0 
	MOVWF       FSR1H 
	MOVF        TMR1H+0, 0 
	MOVWF       POSTINC1+0 
;APESW.c,97 :: 		T2 = contw;                               //Carga el valor actual del contador contw en la variable T2.
	MOVF        _contw+0, 0 
	MOVWF       _T2+0 
	MOVF        _contw+1, 0 
	MOVWF       _T2+1 
;APESW.c,98 :: 		DT = T2-T1;                               //Halla la diferencia entre los valores actual y anterior del contador contw.
	MOVF        _T1+0, 0 
	SUBWF       _contw+0, 0 
	MOVWF       _DT+0 
	MOVF        _T1+1, 0 
	SUBWFB      _contw+1, 0 
	MOVWF       _DT+1 
;APESW.c,100 :: 		if ((FP==1)&&(T2>43)&&(DT!=T2)&&(DT!=2)){          //Detecta el cambio de fase segun el resultado de la diferencia.
	MOVF        _FP+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt11
	MOVLW       0
	MOVWF       R0 
	MOVF        _T2+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt27
	MOVF        _T2+0, 0 
	SUBLW       43
L__Interrupt27:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt11
	MOVF        _DT+1, 0 
	XORWF       _T2+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt28
	MOVF        _T2+0, 0 
	XORWF       _DT+0, 0 
L__Interrupt28:
	BTFSC       STATUS+0, 2 
	GOTO        L_Interrupt11
	MOVLW       0
	XORWF       _DT+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt29
	MOVLW       2
	XORWF       _DT+0, 0 
L__Interrupt29:
	BTFSC       STATUS+0, 2 
	GOTO        L_Interrupt11
L__Interrupt16:
;APESW.c,101 :: 		contT1 = contT;                        //Carga el contenido de la variable contT en la variable contT1.
	MOVF        _contT+0, 0 
	MOVWF       _contT1+0 
	MOVF        _contT+1, 0 
	MOVWF       _contT1+1 
;APESW.c,102 :: 		TMR1ON_bit=0;                          //Apaga el TMR1.
	BCF         TMR1ON_bit+0, BitPos(TMR1ON_bit+0) 
;APESW.c,103 :: 		contT = 0;
	CLRF        _contT+0 
	CLRF        _contT+1 
;APESW.c,104 :: 		FP = 0;                             //Limpia el contenido de la variable contT.
	CLRF        _FP+0 
;APESW.c,105 :: 		}
L_Interrupt11:
;APESW.c,107 :: 		T1 = contw;                               //Actualiza T1 con el valor actual del contador contw.
	MOVF        _contw+0, 0 
	MOVWF       _T1+0 
	MOVF        _contw+1, 0 
	MOVWF       _T1+1 
;APESW.c,108 :: 		INTCON.INT0IF = 0;                        //Limpia la bandera de interrupcion de INT0.
	BCF         INTCON+0, 1 
;APESW.c,109 :: 		}
L_Interrupt8:
;APESW.c,111 :: 		if (TMR1IF_bit){
	BTFSS       TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
	GOTO        L_Interrupt12
;APESW.c,112 :: 		TMR1IF_bit=0;                             //Limpia la bandera de interrupcion de Timer1.
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;APESW.c,113 :: 		}
L_Interrupt12:
;APESW.c,114 :: 		}
L_end_Interrupt:
L__Interrupt19:
	RETFIE      1
; end of _Interrupt

_main:

;APESW.c,118 :: 		void main() {
;APESW.c,120 :: 		INTCON.GIE = 1;                             //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;APESW.c,121 :: 		INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;APESW.c,123 :: 		INTCON.INT0IE = 1;                          //Habilita la interrupcion externas en INT0
	BSF         INTCON+0, 4 
;APESW.c,124 :: 		INTCON2.RBPU = 1;                           //PORTB pull-ups are enabled by individual port latch values
	BSF         INTCON2+0, 7 
;APESW.c,125 :: 		INTCON2.INTEDG0 = 1;                        //Habilita la interrupcion por flanco de subida
	BSF         INTCON2+0, 6 
;APESW.c,127 :: 		ADCON1 = 0b00010111;                        //Configuracion ADCON1
	MOVLW       23
	MOVWF       ADCON1+0 
;APESW.c,128 :: 		CMCON = 0b00000111;
	MOVLW       7
	MOVWF       CMCON+0 
;APESW.c,130 :: 		T1CON=0x00;                                 //Configuracion T1CON: 16 bits, Timer1 On, Pre-escalador 1:1
	CLRF        T1CON+0 
;APESW.c,131 :: 		TMR1IE_bit = 1;                             //Habilita la interrupcion por desborde de Timer1
	BSF         TMR1IE_bit+0, BitPos(TMR1IE_bit+0) 
;APESW.c,133 :: 		T2CON = 0x04;                               //Configuracion T2CON: Post-escalador 1:1, Timer2 On, Pre-escalador 1:1
	MOVLW       4
	MOVWF       T2CON+0 
;APESW.c,134 :: 		PIE1.TMR2IE = 1;                            //Habilita la interrupcion por desborde de Timer2
	BSF         PIE1+0, 1 
;APESW.c,135 :: 		PR2 = 149;                                  //Produce una interrupcion cada 12,5us
	MOVLW       149
	MOVWF       PR2+0 
;APESW.c,137 :: 		TRISD0_bit = 0;                             //Establece el pin D0 como salida
	BCF         TRISD0_bit+0, BitPos(TRISD0_bit+0) 
;APESW.c,138 :: 		TRISD1_bit = 0;                             //Establece el pin D1 como salida
	BCF         TRISD1_bit+0, BitPos(TRISD1_bit+0) 
;APESW.c,140 :: 		TRISB = 0x07;                               //Establece los pines B0, B1 y B2 como entradas
	MOVLW       7
	MOVWF       TRISB+0 
;APESW.c,142 :: 		RD0_bit = 0;                                //Limpia el pin D0
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;APESW.c,143 :: 		RD1_bit = 0;                                //Limpia el pin D1
	BCF         RD1_bit+0, BitPos(RD1_bit+0) 
;APESW.c,144 :: 		PORTB = 0;                                  //Limpia el puerto B
	CLRF        PORTB+0 
;APESW.c,146 :: 		punT1 = &contT;                             //Asocia el puntero punT1 con la direccion de memoria de la variable contT de tipo entero
	MOVLW       _contT+0
	MOVWF       _punT1+0 
	MOVLW       hi_addr(_contT+0)
	MOVWF       _punT1+1 
;APESW.c,148 :: 		contw = 0;                                  //Limpia todas las variables
	CLRF        _contw+0 
	CLRF        _contw+1 
;APESW.c,149 :: 		contT1 = 0;
	CLRF        _contT1+0 
	CLRF        _contT1+1 
;APESW.c,150 :: 		BS = 0;
	CLRF        _BS+0 
;APESW.c,151 :: 		FP = 0;
	CLRF        _FP+0 
;APESW.c,152 :: 		T1 = 0;
	CLRF        _T1+0 
	CLRF        _T1+1 
;APESW.c,153 :: 		T2 = 0;
	CLRF        _T2+0 
	CLRF        _T2+1 
;APESW.c,154 :: 		TOFT = 0;
	CLRF        _TOFT+0 
	CLRF        _TOFT+1 
	CLRF        _TOFT+2 
	CLRF        _TOFT+3 
;APESW.c,156 :: 		Lcd_init();                                 //Inicializa el LCD
	CALL        _Lcd_Init+0, 0
;APESW.c,157 :: 		Lcd_Out(1,1,"INICIANDO...");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,158 :: 		Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,159 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,161 :: 		while (1){
L_main13:
;APESW.c,163 :: 		TOFT = (contT1)*(4./48);          //Calcula el valor de TOF
	MOVF        _contT1+0, 0 
	MOVWF       R0 
	MOVF        _contT1+1, 0 
	MOVWF       R1 
	CALL        _word2double+0, 0
	MOVLW       171
	MOVWF       R4 
	MOVLW       170
	MOVWF       R5 
	MOVLW       42
	MOVWF       R6 
	MOVLW       123
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       _TOFT+0 
	MOVF        R1, 0 
	MOVWF       _TOFT+1 
	MOVF        R2, 0 
	MOVWF       _TOFT+2 
	MOVF        R3, 0 
	MOVWF       _TOFT+3 
;APESW.c,165 :: 		FloatToStr(TOFT, txt1);               //Convierte el valor del TOF en string
	MOVF        R0, 0 
	MOVWF       FARG_FloatToStr_fnum+0 
	MOVF        R1, 0 
	MOVWF       FARG_FloatToStr_fnum+1 
	MOVF        R2, 0 
	MOVWF       FARG_FloatToStr_fnum+2 
	MOVF        R3, 0 
	MOVWF       FARG_FloatToStr_fnum+3 
	MOVLW       _txt1+0
	MOVWF       FARG_FloatToStr_str+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_FloatToStr_str+1 
	CALL        _FloatToStr+0, 0
;APESW.c,166 :: 		Lcd_Out(1,1,"TOF: ");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,167 :: 		Lcd_Out_Cp(txt1);                     //Visualiza el valor del TOF en el LCD
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_CP_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_CP_text+1 
	CALL        _Lcd_Out_CP+0, 0
;APESW.c,169 :: 		delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_main15:
	DECFSZ      R13, 1, 1
	BRA         L_main15
	DECFSZ      R12, 1, 1
	BRA         L_main15
	NOP
	NOP
;APESW.c,171 :: 		}
	GOTO        L_main13
;APESW.c,172 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
