
_Interrupt:

;APESW.c,55 :: 		void Interrupt(){
;APESW.c,58 :: 		if (TMR2IF_bit){                             //Verifica si ocurrio una interrupcion por desbordamiento del TMR2.
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_Interrupt0
;APESW.c,60 :: 		RD1_bit = ~RD1_bit;                       //Genera un tren de pulsos de 40KHz en el pin RD1
	BTG         RD1_bit+0, BitPos(RD1_bit+0) 
;APESW.c,62 :: 		if (contw<=43){                           //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (43)
	MOVLW       0
	MOVWF       R0 
	MOVF        _contw+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt10
	MOVF        _contw+0, 0 
	SUBLW       43
L__Interrupt10:
	BTFSS       STATUS+0, 0 
	GOTO        L_Interrupt1
;APESW.c,63 :: 		BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
	COMF        _BS+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _BS+0 
;APESW.c,64 :: 		RD0_bit = BS;
	BTFSC       R0, 0 
	GOTO        L__Interrupt11
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
	GOTO        L__Interrupt12
L__Interrupt11:
	BSF         RD0_bit+0, BitPos(RD0_bit+0) 
L__Interrupt12:
;APESW.c,67 :: 		TMR1ON_bit=1;                          //Enciende el TMR1.
	BSF         TMR1ON_bit+0, BitPos(TMR1ON_bit+0) 
;APESW.c,68 :: 		TMR1L=0X00;                            //Limpia los bits menos significativos del TMR1.
	CLRF        TMR1L+0 
;APESW.c,69 :: 		TMR1H=0X00;                            //Limpia los bits mas significativos del TMR1.
	CLRF        TMR1H+0 
;APESW.c,71 :: 		if (contw==22){                        //Cambia el valor de la variable auxiliar para producir  (22)
	MOVLW       0
	XORWF       _contw+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt13
	MOVLW       22
	XORWF       _contw+0, 0 
L__Interrupt13:
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt2
;APESW.c,72 :: 		BS = 0;                          //el cambio de fase en la siguiente iteracion.
	CLRF        _BS+0 
;APESW.c,73 :: 		}
L_Interrupt2:
;APESW.c,75 :: 		} else {
	GOTO        L_Interrupt3
L_Interrupt1:
;APESW.c,76 :: 		RD0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;APESW.c,77 :: 		*(punT1) = TMR1L;                      //Carga el valor actual de TMR1L en los 8 bits menos significativos de la variable contT de tipo entero.
	MOVFF       _punT1+0, FSR1
	MOVFF       _punT1+1, FSR1H
	MOVF        TMR1L+0, 0 
	MOVWF       POSTINC1+0 
;APESW.c,78 :: 		*(punT1+1) = TMR1H;                    //Carga el valor actual de TMR1H en los 8 bits mas significativos de la variable  contT de tipo entero.
	MOVLW       1
	ADDWF       _punT1+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _punT1+1, 0 
	MOVWF       FSR1H 
	MOVF        TMR1H+0, 0 
	MOVWF       POSTINC1+0 
;APESW.c,79 :: 		contT1 = contT;                        //Carga el contenido de la variable contT en la variable contT1.
	MOVF        _contT+0, 0 
	MOVWF       _contT1+0 
	MOVF        _contT+1, 0 
	MOVWF       _contT1+1 
;APESW.c,80 :: 		TMR1ON_bit=0;                          //Apaga el TMR1.
	BCF         TMR1ON_bit+0, BitPos(TMR1ON_bit+0) 
;APESW.c,81 :: 		contT = 0;                             //Limpia el contenido de la variable contT.
	CLRF        _contT+0 
	CLRF        _contT+1 
;APESW.c,82 :: 		INTCON.INT0IF = 0;                     //Limpia la bandera de interrupcion de INT0.
	BCF         INTCON+0, 1 
;APESW.c,83 :: 		}
L_Interrupt3:
;APESW.c,85 :: 		if (contw>=800){                          //Limpia el contador cada 800 interrupciones (10ms) para el reenvio de los pulsos
	MOVLW       3
	SUBWF       _contw+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt14
	MOVLW       32
	SUBWF       _contw+0, 0 
L__Interrupt14:
	BTFSS       STATUS+0, 0 
	GOTO        L_Interrupt4
;APESW.c,86 :: 		contw = 0;                             //de exitacion del transductor ultrasonico.
	CLRF        _contw+0 
	CLRF        _contw+1 
;APESW.c,87 :: 		}
L_Interrupt4:
;APESW.c,89 :: 		contw++;                                  //Aumenta el contador en una unidad.
	INFSNZ      _contw+0, 1 
	INCF        _contw+1, 1 
;APESW.c,90 :: 		TMR2IF_bit = 0;                           //Limpia la bandera de interrupcion de Timer2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;APESW.c,91 :: 		}
L_Interrupt0:
;APESW.c,93 :: 		}
L_end_Interrupt:
L__Interrupt9:
	RETFIE      1
; end of _Interrupt

_main:

;APESW.c,97 :: 		void main() {
;APESW.c,99 :: 		INTCON.GIE = 1;                             //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;APESW.c,100 :: 		INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;APESW.c,102 :: 		INTCON.INT0IE = 1;                          //Habilita la interrupcion externas en INT0
	BSF         INTCON+0, 4 
;APESW.c,103 :: 		INTCON2.RBPU = 1;                           //PORTB pull-ups are enabled by individual port latch values
	BSF         INTCON2+0, 7 
;APESW.c,104 :: 		INTCON2.INTEDG0 = 1;                        //Habilita la interrupcion por flanco de subida
	BSF         INTCON2+0, 6 
;APESW.c,106 :: 		ADCON1 = 0b00010111;                        //Configuracion ADCON1
	MOVLW       23
	MOVWF       ADCON1+0 
;APESW.c,107 :: 		CMCON = 0b00000111;
	MOVLW       7
	MOVWF       CMCON+0 
;APESW.c,109 :: 		T1CON=0x00;                                 //Configuracion T1CON: 16 bits, Timer1 On, Pre-escalador 1:1
	CLRF        T1CON+0 
;APESW.c,110 :: 		TMR1IE_bit = 1;                             //Habilita la interrupcion por desborde de Timer1
	BSF         TMR1IE_bit+0, BitPos(TMR1IE_bit+0) 
;APESW.c,112 :: 		T2CON = 0x04;                               //Configuracion T2CON: Post-escalador 1:1, Timer2 On, Pre-escalador 1:1
	MOVLW       4
	MOVWF       T2CON+0 
;APESW.c,113 :: 		PIE1.TMR2IE = 1;                            //Habilita la interrupcion por desborde de Timer2
	BSF         PIE1+0, 1 
;APESW.c,114 :: 		PR2 = 149;                                  //Produce una interrupcion cada 12,5us
	MOVLW       149
	MOVWF       PR2+0 
;APESW.c,116 :: 		TRISD0_bit = 0;                             //Establece el pin D0 como salida
	BCF         TRISD0_bit+0, BitPos(TRISD0_bit+0) 
;APESW.c,117 :: 		TRISD1_bit = 0;                             //Establece el pin D1 como salida
	BCF         TRISD1_bit+0, BitPos(TRISD1_bit+0) 
;APESW.c,119 :: 		TRISB = 0x07;                               //Establece los pines B0, B1 y B2 como entradas
	MOVLW       7
	MOVWF       TRISB+0 
;APESW.c,121 :: 		RD0_bit = 0;                                //Limpia el pin D0
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;APESW.c,122 :: 		RD1_bit = 0;                                //Limpia el pin D1
	BCF         RD1_bit+0, BitPos(RD1_bit+0) 
;APESW.c,123 :: 		PORTB = 0;                                  //Limpia el puerto B
	CLRF        PORTB+0 
;APESW.c,125 :: 		punT1 = &contT;                             //Asocia el puntero punT1 con la direccion de memoria de la variable contT de tipo entero
	MOVLW       _contT+0
	MOVWF       _punT1+0 
	MOVLW       hi_addr(_contT+0)
	MOVWF       _punT1+1 
;APESW.c,127 :: 		contw = 0;                                  //Limpia todas las variables
	CLRF        _contw+0 
	CLRF        _contw+1 
;APESW.c,128 :: 		contT1 = 0;
	CLRF        _contT1+0 
	CLRF        _contT1+1 
;APESW.c,129 :: 		BS = 0;
	CLRF        _BS+0 
;APESW.c,130 :: 		FP = 0;
	CLRF        _FP+0 
;APESW.c,131 :: 		T1 = 0;
	CLRF        _T1+0 
	CLRF        _T1+1 
;APESW.c,132 :: 		T2 = 0;
	CLRF        _T2+0 
	CLRF        _T2+1 
;APESW.c,133 :: 		TOFT = 0;
	CLRF        _TOFT+0 
	CLRF        _TOFT+1 
	CLRF        _TOFT+2 
	CLRF        _TOFT+3 
;APESW.c,135 :: 		Lcd_init();                                 //Inicializa el LCD
	CALL        _Lcd_Init+0, 0
;APESW.c,136 :: 		Lcd_Out(1,1,"INICIANDO...");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,137 :: 		Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,138 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,140 :: 		while (1){
L_main5:
;APESW.c,142 :: 		TOFT = (contT1 * 0.0833333);          //Calcula el valor de TOF
	MOVF        _contT1+0, 0 
	MOVWF       R0 
	MOVF        _contT1+1, 0 
	MOVWF       R1 
	CALL        _word2double+0, 0
	MOVLW       166
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
;APESW.c,144 :: 		FloatToStr(TOFT, txt1);               //Convierte el valor del TOF en string
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
;APESW.c,145 :: 		Lcd_Out(1,1,"Duracion: ");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,146 :: 		Lcd_Out_Cp(txt1);                     //Visualiza el valor del TOF en el LCD
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_CP_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_CP_text+1 
	CALL        _Lcd_Out_CP+0, 0
;APESW.c,148 :: 		delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_main7:
	DECFSZ      R13, 1, 1
	BRA         L_main7
	DECFSZ      R12, 1, 1
	BRA         L_main7
	NOP
	NOP
;APESW.c,150 :: 		}
	GOTO        L_main5
;APESW.c,151 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
