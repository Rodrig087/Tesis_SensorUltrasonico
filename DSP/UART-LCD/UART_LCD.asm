
_interrupt:

;UART_LCD.c,34 :: 		void interrupt(void){
;UART_LCD.c,36 :: 		if (PIR1.F5){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;UART_LCD.c,38 :: 		Dato = UART1_Read();                            //Lee el dato que llega por el modulo Uart1
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _Dato+0 
;UART_LCD.c,39 :: 		if (Dato==0x0D){                                //Verifica si el dato que llego es la cabecera
	MOVF        R0, 0 
	XORLW       13
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt1
;UART_LCD.c,40 :: 		BanP = 1;                                    //activa la bandera que permite almacenar los datos en el buffer
	MOVLW       1
	MOVWF       _BanP+0 
;UART_LCD.c,41 :: 		Dato = 0;                                    //Limpia la variable Dato
	CLRF        _Dato+0 
;UART_LCD.c,42 :: 		i=0;                                         //Limpia el subindice del vector de
	CLRF        _i+0 
;UART_LCD.c,43 :: 		}
L_interrupt1:
;UART_LCD.c,45 :: 		if (BanP == 1){
	MOVF        _BanP+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt2
;UART_LCD.c,46 :: 		trama[i] = UART1_Read();                     //Almacena los datos de entrada byte a byte en el buffer de peticion
	MOVLW       _trama+0
	MOVWF       FLOC__interrupt+0 
	MOVLW       hi_addr(_trama+0)
	MOVWF       FLOC__interrupt+1 
	MOVF        _i+0, 0 
	ADDWF       FLOC__interrupt+0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FLOC__interrupt+1, 1 
	CALL        _UART1_Read+0, 0
	MOVFF       FLOC__interrupt+0, FSR1
	MOVFF       FLOC__interrupt+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;UART_LCD.c,47 :: 		i++;
	INCF        _i+0, 1 
;UART_LCD.c,48 :: 		if (i==3){
	MOVF        _i+0, 0 
	XORLW       3
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt3
;UART_LCD.c,49 :: 		BanT = 1;
	MOVLW       1
	MOVWF       _BanT+0 
;UART_LCD.c,50 :: 		}
L_interrupt3:
;UART_LCD.c,51 :: 		}
L_interrupt2:
;UART_LCD.c,53 :: 		PIR1.F5 = 0;                                    //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;UART_LCD.c,55 :: 		}
L_interrupt0:
;UART_LCD.c,56 :: 		}
L_end_interrupt:
L__interrupt13:
	RETFIE      1
; end of _interrupt

_Configuracion:

;UART_LCD.c,60 :: 		void Configuracion(){
;UART_LCD.c,62 :: 		INTCON.GIE = 1;                             //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;UART_LCD.c,63 :: 		INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;UART_LCD.c,64 :: 		INTCON2.RBPU = 0;
	BCF         INTCON2+0, 7 
;UART_LCD.c,66 :: 		ADCON1 = 0b00001111;                        //Configuracion ADCON1
	MOVLW       15
	MOVWF       ADCON1+0 
;UART_LCD.c,67 :: 		CMCON = 0b00000111;
	MOVLW       7
	MOVWF       CMCON+0 
;UART_LCD.c,69 :: 		RCIE_bit = 0;                         // enable interrupt on UART1 receive
	BCF         RCIE_bit+0, BitPos(RCIE_bit+0) 
;UART_LCD.c,70 :: 		TXIE_bit = 0;                         // disable interrupt on UART1 transmit
	BCF         TXIE_bit+0, BitPos(TXIE_bit+0) 
;UART_LCD.c,71 :: 		PEIE_bit = 1;                         // enable peripheral interrupts
	BSF         PEIE_bit+0, BitPos(PEIE_bit+0) 
;UART_LCD.c,72 :: 		GIE_bit = 1;
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
;UART_LCD.c,74 :: 		UART1_Init(9600);                     // Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       207
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;UART_LCD.c,75 :: 		Delay_ms(100);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       4
	MOVWF       R12, 0
	MOVLW       186
	MOVWF       R13, 0
L_Configuracion4:
	DECFSZ      R13, 1, 1
	BRA         L_Configuracion4
	DECFSZ      R12, 1, 1
	BRA         L_Configuracion4
	DECFSZ      R11, 1, 1
	BRA         L_Configuracion4
	NOP
;UART_LCD.c,77 :: 		Lcd_Init();                           // Initialize LCD
	CALL        _Lcd_Init+0, 0
;UART_LCD.c,78 :: 		Lcd_Cmd(_LCD_CLEAR);                  // Clear display
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;UART_LCD.c,79 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);             // Cursor off
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;UART_LCD.c,80 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;UART_LCD.c,83 :: 		void main() {
;UART_LCD.c,85 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;UART_LCD.c,86 :: 		Lcd_Out(1, 1, "Hello!");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_UART_LCD+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_UART_LCD+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;UART_LCD.c,87 :: 		ptrTT2 = &TT2;
	MOVLW       _TT2+0
	MOVWF       _ptrTT2+0 
	MOVLW       hi_addr(_TT2+0)
	MOVWF       _ptrTT2+1 
;UART_LCD.c,89 :: 		while (1){
L_main5:
;UART_LCD.c,91 :: 		if (BanT==1){
	MOVF        _BanT+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main7
;UART_LCD.c,93 :: 		for (j=0;j<4;j++){
	CLRF        _j+0 
L_main8:
	MOVLW       4
	SUBWF       _j+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main9
;UART_LCD.c,94 :: 		*(ptrTT2+j) = trama[j];
	MOVF        _j+0, 0 
	ADDWF       _ptrTT2+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _ptrTT2+1, 0 
	MOVWF       FSR1H 
	MOVLW       _trama+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_trama+0)
	MOVWF       FSR0H 
	MOVF        _j+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;UART_LCD.c,93 :: 		for (j=0;j<4;j++){
	INCF        _j+0, 1 
;UART_LCD.c,95 :: 		}
	GOTO        L_main8
L_main9:
;UART_LCD.c,97 :: 		BanP = 0;
	CLRF        _BanP+0 
;UART_LCD.c,98 :: 		BanT = 0;
	CLRF        _BanT+0 
;UART_LCD.c,100 :: 		}
L_main7:
;UART_LCD.c,102 :: 		T2 = TT2 * 1.0;
	MOVF        _TT2+0, 0 
	MOVWF       R0 
	MOVF        _TT2+1, 0 
	MOVWF       R1 
	MOVF        _TT2+2, 0 
	MOVWF       R2 
	MOVF        _TT2+3, 0 
	MOVWF       R3 
	CALL        _longword2double+0, 0
	MOVF        R0, 0 
	MOVWF       _T2+0 
	MOVF        R1, 0 
	MOVWF       _T2+1 
	MOVF        R2, 0 
	MOVWF       _T2+2 
	MOVF        R3, 0 
	MOVWF       _T2+3 
;UART_LCD.c,103 :: 		FloatToStr(T2,txt1);
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
;UART_LCD.c,105 :: 		Lcd_Out(1, 1, "T2: ");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_UART_LCD+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_UART_LCD+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;UART_LCD.c,106 :: 		Lcd_Out(2,1,txt1);
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;UART_LCD.c,110 :: 		Delay_ms(10);
	MOVLW       26
	MOVWF       R12, 0
	MOVLW       248
	MOVWF       R13, 0
L_main11:
	DECFSZ      R13, 1, 1
	BRA         L_main11
	DECFSZ      R12, 1, 1
	BRA         L_main11
	NOP
;UART_LCD.c,112 :: 		}
	GOTO        L_main5
;UART_LCD.c,114 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
