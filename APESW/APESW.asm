
_Interrupt:

;APESW.c,63 :: 		void Interrupt(){
;APESW.c,66 :: 		if (TMR2IF_bit){                             //Verifica si ocurrio una interrupcion por desbordamiento del TMR2.
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_Interrupt0
;APESW.c,68 :: 		RD1_bit = ~RD1_bit;                       //Genera un tren de pulsos de 40KHz en el pin RD1
	BTG         RD1_bit+0, BitPos(RD1_bit+0) 
;APESW.c,70 :: 		if (contw<=43){                           //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (43)
	MOVLW       0
	MOVWF       R0 
	MOVF        _contw+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt24
	MOVF        _contw+0, 0 
	SUBLW       43
L__Interrupt24:
	BTFSS       STATUS+0, 0 
	GOTO        L_Interrupt1
;APESW.c,71 :: 		BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
	COMF        _BS+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _BS+0 
;APESW.c,72 :: 		RD0_bit = BS;
	BTFSC       R0, 0 
	GOTO        L__Interrupt25
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
	GOTO        L__Interrupt26
L__Interrupt25:
	BSF         RD0_bit+0, BitPos(RD0_bit+0) 
L__Interrupt26:
;APESW.c,74 :: 		if (contw==25){                        //Se empieza a contar el tiempo desde el primer pulso en alto despues del cambio de fase. 25
	MOVLW       0
	XORWF       _contw+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt27
	MOVLW       25
	XORWF       _contw+0, 0 
L__Interrupt27:
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt2
;APESW.c,75 :: 		TMR1ON_bit=1;                       //Enciende el TMR1.
	BSF         TMR1ON_bit+0, BitPos(TMR1ON_bit+0) 
;APESW.c,76 :: 		TMR1L=0X00;                         //Limpia los bits menos significativos del TMR1.
	CLRF        TMR1L+0 
;APESW.c,77 :: 		TMR1H=0X00;                         //Limpia los bits mas significativos del TMR1.
	CLRF        TMR1H+0 
;APESW.c,78 :: 		}
L_Interrupt2:
;APESW.c,79 :: 		if (contw==22){                        //Cambia el valor de la variable auxiliar para producir  (22)
	MOVLW       0
	XORWF       _contw+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt28
	MOVLW       22
	XORWF       _contw+0, 0 
L__Interrupt28:
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt3
;APESW.c,80 :: 		BS = 0;                          //el cambio de fase en la siguiente iteracion.
	CLRF        _BS+0 
;APESW.c,81 :: 		}
L_Interrupt3:
;APESW.c,83 :: 		} else {
	GOTO        L_Interrupt4
L_Interrupt1:
;APESW.c,84 :: 		RD0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;APESW.c,85 :: 		FP = 1;                                //Habilita la bandera de deteccion de fase para permitir la deteccion una vez que se hayan terminado de enviar todos los pulsos de exitacion
	MOVLW       1
	MOVWF       _FP+0 
;APESW.c,86 :: 		}
L_Interrupt4:
;APESW.c,88 :: 		if (contw>=800){                          //Limpia el contador cada 800 interrupciones (10ms) para el reenvio de los pulsos
	MOVLW       3
	SUBWF       _contw+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt29
	MOVLW       32
	SUBWF       _contw+0, 0 
L__Interrupt29:
	BTFSS       STATUS+0, 0 
	GOTO        L_Interrupt5
;APESW.c,89 :: 		contw = 0;                             //de exitacion del transductor ultrasonico.
	CLRF        _contw+0 
	CLRF        _contw+1 
;APESW.c,90 :: 		T1=0;
	CLRF        _T1+0 
	CLRF        _T1+1 
;APESW.c,91 :: 		T2=0;
	CLRF        _T2+0 
	CLRF        _T2+1 
;APESW.c,92 :: 		DT=0;
	CLRF        _DT+0 
	CLRF        _DT+1 
;APESW.c,93 :: 		}
L_Interrupt5:
;APESW.c,95 :: 		contw++;                                  //Aumenta el contador en una unidad.
	INFSNZ      _contw+0, 1 
	INCF        _contw+1, 1 
;APESW.c,96 :: 		TMR2IF_bit = 0;                           //Limpia la bandera de interrupcion de Timer2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;APESW.c,97 :: 		}
L_Interrupt0:
;APESW.c,101 :: 		if (INTCON.INT0IF == 1){                     //Verifica si ocurrio una interrupcion externa en INT0.
	BTFSS       INTCON+0, 1 
	GOTO        L_Interrupt6
;APESW.c,102 :: 		*(punT1) = TMR1L;                         //Carga el valor actual de TMR1L en los 8 bits menos significativos de la variable contT de tipo entero.
	MOVFF       _punT1+0, FSR1
	MOVFF       _punT1+1, FSR1H
	MOVF        TMR1L+0, 0 
	MOVWF       POSTINC1+0 
;APESW.c,103 :: 		*(punT1+1) = TMR1H;                       //Carga el valor actual de TMR1H en los 8 bits mas significativos de la variable  contT de tipo entero.
	MOVLW       1
	ADDWF       _punT1+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _punT1+1, 0 
	MOVWF       FSR1H 
	MOVF        TMR1H+0, 0 
	MOVWF       POSTINC1+0 
;APESW.c,104 :: 		T2 = contw;                               //Carga el valor actual del contador contw en la variable T2.
	MOVF        _contw+0, 0 
	MOVWF       _T2+0 
	MOVF        _contw+1, 0 
	MOVWF       _T2+1 
;APESW.c,105 :: 		DT = T2-T1;                               //Halla la diferencia entre los valores actual y anterior del contador contw.
	MOVF        _T1+0, 0 
	SUBWF       _contw+0, 0 
	MOVWF       _DT+0 
	MOVF        _T1+1, 0 
	SUBWFB      _contw+1, 0 
	MOVWF       _DT+1 
;APESW.c,107 :: 		if ((T2>43)&&(DT!=T2)&&(DT!=2)){          //Detecta el cambio de fase segun el resultado de la diferencia.
	MOVLW       0
	MOVWF       R0 
	MOVF        _contw+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt30
	MOVF        _contw+0, 0 
	SUBLW       43
L__Interrupt30:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt9
	MOVF        _DT+1, 0 
	XORWF       _T2+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt31
	MOVF        _T2+0, 0 
	XORWF       _DT+0, 0 
L__Interrupt31:
	BTFSC       STATUS+0, 2 
	GOTO        L_Interrupt9
	MOVLW       0
	XORWF       _DT+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt32
	MOVLW       2
	XORWF       _DT+0, 0 
L__Interrupt32:
	BTFSC       STATUS+0, 2 
	GOTO        L_Interrupt9
L__Interrupt21:
;APESW.c,108 :: 		contT1 = contT;                        //Carga el contenido de la variable contT en la variable contT1.
	MOVF        _contT+0, 0 
	MOVWF       _contT1+0 
	MOVF        _contT+1, 0 
	MOVWF       _contT1+1 
;APESW.c,109 :: 		TMR1ON_bit=0;                          //Apaga el TMR1.
	BCF         TMR1ON_bit+0, BitPos(TMR1ON_bit+0) 
;APESW.c,110 :: 		contT = 0;                             //Limpia el contenido de la variable contT.
	CLRF        _contT+0 
	CLRF        _contT+1 
;APESW.c,111 :: 		}
L_Interrupt9:
;APESW.c,113 :: 		T1 = contw;                               //Actualiza T1 con el valor actual del contador contw.
	MOVF        _contw+0, 0 
	MOVWF       _T1+0 
	MOVF        _contw+1, 0 
	MOVWF       _T1+1 
;APESW.c,114 :: 		INTCON.INT0IF = 0;                        //Limpia la bandera de interrupcion de INT0.
	BCF         INTCON+0, 1 
;APESW.c,115 :: 		}
L_Interrupt6:
;APESW.c,117 :: 		if (TMR1IF_bit){
	BTFSS       TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
	GOTO        L_Interrupt10
;APESW.c,118 :: 		TMR1IF_bit=0;                             //Limpia la bandera de interrupcion de Timer1.
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;APESW.c,119 :: 		}
L_Interrupt10:
;APESW.c,120 :: 		}
L_end_Interrupt:
L__Interrupt23:
	RETFIE      1
; end of _Interrupt

_main:

;APESW.c,124 :: 		void main() {
;APESW.c,126 :: 		INTCON.GIE = 1;                             //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;APESW.c,127 :: 		INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;APESW.c,129 :: 		INTCON.INT0IE = 1;                          //Habilita la interrupcion externas en INT0
	BSF         INTCON+0, 4 
;APESW.c,130 :: 		INTCON2.RBPU = 1;                           //PORTB pull-ups are enabled by individual port latch values
	BSF         INTCON2+0, 7 
;APESW.c,131 :: 		INTCON2.INTEDG0 = 1;                        //Habilita la interrupcion por flanco de subida
	BSF         INTCON2+0, 6 
;APESW.c,133 :: 		ADCON1 = 0b00010111;                        //Configuracion ADCON1
	MOVLW       23
	MOVWF       ADCON1+0 
;APESW.c,134 :: 		CMCON = 0b00000111;
	MOVLW       7
	MOVWF       CMCON+0 
;APESW.c,136 :: 		T1CON=0x00;                                 //Configuracion T1CON: 16 bits, Timer1 On, Pre-escalador 1:1
	CLRF        T1CON+0 
;APESW.c,137 :: 		TMR1IE_bit = 1;                             //Habilita la interrupcion por desborde de Timer1
	BSF         TMR1IE_bit+0, BitPos(TMR1IE_bit+0) 
;APESW.c,139 :: 		T2CON = 0x04;                               //Configuracion T2CON: Post-escalador 1:1, Timer2 On, Pre-escalador 1:1
	MOVLW       4
	MOVWF       T2CON+0 
;APESW.c,140 :: 		PIE1.TMR2IE = 1;                            //Habilita la interrupcion por desborde de Timer2
	BSF         PIE1+0, 1 
;APESW.c,141 :: 		PR2 = 149;                                  //Produce una interrupcion cada 12,5us
	MOVLW       149
	MOVWF       PR2+0 
;APESW.c,143 :: 		TRISD0_bit = 0;                             //Establece el pin D0 como salida
	BCF         TRISD0_bit+0, BitPos(TRISD0_bit+0) 
;APESW.c,144 :: 		TRISD1_bit = 0;                             //Establece el pin D1 como salida
	BCF         TRISD1_bit+0, BitPos(TRISD1_bit+0) 
;APESW.c,146 :: 		TRISB = 0x07;                               //Establece los pines B0, B1 y B2 como entradas
	MOVLW       7
	MOVWF       TRISB+0 
;APESW.c,148 :: 		RD0_bit = 0;                                //Limpia el pin D0
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;APESW.c,149 :: 		RD1_bit = 0;                                //Limpia el pin D1
	BCF         RD1_bit+0, BitPos(RD1_bit+0) 
;APESW.c,150 :: 		PORTB = 0;                                  //Limpia el puerto B
	CLRF        PORTB+0 
;APESW.c,152 :: 		punT1 = &contT;                             //Asocia el puntero punT1 con la direccion de memoria de la variable contT de tipo entero
	MOVLW       _contT+0
	MOVWF       _punT1+0 
	MOVLW       hi_addr(_contT+0)
	MOVWF       _punT1+1 
;APESW.c,153 :: 		punDt = &Di;                                //Asocia el puntero punDt con la direccion de memoria de la variable Di de tipo entero
	MOVLW       _Di+0
	MOVWF       _punDt+0 
	MOVLW       hi_addr(_Di+0)
	MOVWF       _punDt+1 
;APESW.c,155 :: 		contw = 0;                                  //Limpia todas las variables
	CLRF        _contw+0 
	CLRF        _contw+1 
;APESW.c,156 :: 		contT1 = 0;
	CLRF        _contT1+0 
	CLRF        _contT1+1 
;APESW.c,157 :: 		BS = 0;
	CLRF        _BS+0 
;APESW.c,158 :: 		FP = 0;
	CLRF        _FP+0 
;APESW.c,159 :: 		T1 = 0;
	CLRF        _T1+0 
	CLRF        _T1+1 
;APESW.c,160 :: 		T2 = 0;
	CLRF        _T2+0 
	CLRF        _T2+1 
;APESW.c,161 :: 		TOF = 0;
	CLRF        _TOF+0 
	CLRF        _TOF+1 
	CLRF        _TOF+2 
	CLRF        _TOF+3 
;APESW.c,162 :: 		Di = 0;
	CLRF        _Di+0 
	CLRF        _Di+1 
;APESW.c,164 :: 		Rspt[0] = Hdr;
	MOVLW       32
	MOVWF       _Rspt+0 
;APESW.c,165 :: 		Rspt[1] = idSlv;
	MOVLW       49
	MOVWF       _Rspt+1 
;APESW.c,166 :: 		Rspt[4] = End;
	MOVLW       13
	MOVWF       _Rspt+4 
;APESW.c,168 :: 		Lcd_init();                                 //Inicializa el LCD
	CALL        _Lcd_Init+0, 0
;APESW.c,170 :: 		Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,171 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,173 :: 		UART1_Init(9600);                           // Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	MOVLW       4
	MOVWF       SPBRGH+0 
	MOVLW       225
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;APESW.c,174 :: 		Delay_ms(100);                              // Wait for UART module to stabilize
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_main11:
	DECFSZ      R13, 1, 1
	BRA         L_main11
	DECFSZ      R12, 1, 1
	BRA         L_main11
	DECFSZ      R11, 1, 1
	BRA         L_main11
	NOP
;APESW.c,176 :: 		while (1){
L_main12:
;APESW.c,178 :: 		TOF = (contT1)*(4./48);               //Calcula el valor de TOF
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
	MOVWF       _TOF+0 
	MOVF        R1, 0 
	MOVWF       _TOF+1 
	MOVF        R2, 0 
	MOVWF       _TOF+2 
	MOVF        R3, 0 
	MOVWF       _TOF+3 
;APESW.c,179 :: 		Df = (343. * TOF ) / 2000;            //Calcula la distancia en funcion del TOF
	MOVLW       0
	MOVWF       R4 
	MOVLW       128
	MOVWF       R5 
	MOVLW       43
	MOVWF       R6 
	MOVLW       135
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
	MOVLW       0
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVLW       122
	MOVWF       R6 
	MOVLW       137
	MOVWF       R7 
	CALL        _Div_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       _Df+0 
	MOVF        R1, 0 
	MOVWF       _Df+1 
	MOVF        R2, 0 
	MOVWF       _Df+2 
	MOVF        R3, 0 
	MOVWF       _Df+3 
;APESW.c,180 :: 		Di = Df*10;
	MOVLW       0
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVLW       32
	MOVWF       R6 
	MOVLW       130
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
	CALL        _double2word+0, 0
	MOVF        R0, 0 
	MOVWF       _Di+0 
	MOVF        R1, 0 
	MOVWF       _Di+1 
;APESW.c,183 :: 		for (i=2;i<4;i++){                    //Rellena la trama de cuerpo de datos de 4 bytes
	MOVLW       2
	MOVWF       _i+0 
L_main14:
	MOVLW       4
	SUBWF       _i+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main15
;APESW.c,184 :: 		Rspt[i]=(*punDt++);               //El operador * permite acceder al valor de la direccion del puntero,
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _i+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVFF       _punDt+0, FSR0
	MOVFF       _punDt+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
	INFSNZ      _punDt+0, 1 
	INCF        _punDt+1, 1 
;APESW.c,183 :: 		for (i=2;i<4;i++){                    //Rellena la trama de cuerpo de datos de 4 bytes
	INCF        _i+0, 1 
;APESW.c,185 :: 		}
	GOTO        L_main14
L_main15:
;APESW.c,187 :: 		FloatToStr(Df, txt1);
	MOVF        _Df+0, 0 
	MOVWF       FARG_FloatToStr_fnum+0 
	MOVF        _Df+1, 0 
	MOVWF       FARG_FloatToStr_fnum+1 
	MOVF        _Df+2, 0 
	MOVWF       FARG_FloatToStr_fnum+2 
	MOVF        _Df+3, 0 
	MOVWF       FARG_FloatToStr_fnum+3 
	MOVLW       _txt1+0
	MOVWF       FARG_FloatToStr_str+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_FloatToStr_str+1 
	CALL        _FloatToStr+0, 0
;APESW.c,188 :: 		IntToStr(Di, txt2);                   //Convierte el valor de la distancia en string
	MOVF        _Di+0, 0 
	MOVWF       FARG_IntToStr_input+0 
	MOVF        _Di+1, 0 
	MOVWF       FARG_IntToStr_input+1 
	MOVLW       _txt2+0
	MOVWF       FARG_IntToStr_output+0 
	MOVLW       hi_addr(_txt2+0)
	MOVWF       FARG_IntToStr_output+1 
	CALL        _IntToStr+0, 0
;APESW.c,190 :: 		Lcd_Out(1,1,"Df: ");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,191 :: 		Lcd_Out_Cp(txt1);
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_CP_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_CP_text+1 
	CALL        _Lcd_Out_CP+0, 0
;APESW.c,192 :: 		Lcd_Out(2,1,"Di: ");
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,193 :: 		Lcd_Out_Cp(txt2);                     //Visualiza el valor del TOF en el LCD*/
	MOVLW       _txt2+0
	MOVWF       FARG_Lcd_Out_CP_text+0 
	MOVLW       hi_addr(_txt2+0)
	MOVWF       FARG_Lcd_Out_CP_text+1 
	CALL        _Lcd_Out_CP+0, 0
;APESW.c,195 :: 		for (j=0;j<=4;j++){
	CLRF        _j+0 
L_main17:
	MOVF        _j+0, 0 
	SUBLW       4
	BTFSS       STATUS+0, 0 
	GOTO        L_main18
;APESW.c,196 :: 		UART1_Write(Rspt[j]);             //Visualiza la trama recibida en el LCD
	MOVLW       _Rspt+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR0H 
	MOVF        _j+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;APESW.c,195 :: 		for (j=0;j<=4;j++){
	INCF        _j+0, 1 
;APESW.c,197 :: 		}
	GOTO        L_main17
L_main18:
;APESW.c,199 :: 		delay_ms(1);
	MOVLW       16
	MOVWF       R12, 0
	MOVLW       148
	MOVWF       R13, 0
L_main20:
	DECFSZ      R13, 1, 1
	BRA         L_main20
	DECFSZ      R12, 1, 1
	BRA         L_main20
	NOP
;APESW.c,201 :: 		}
	GOTO        L_main12
;APESW.c,202 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
