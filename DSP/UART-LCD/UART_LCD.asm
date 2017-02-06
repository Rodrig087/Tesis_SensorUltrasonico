
_interrupt:

;UART_LCD.c,29 :: 		void interrupt(void){
;UART_LCD.c,30 :: 		if (PIR1.F5){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;UART_LCD.c,32 :: 		trama[j] = UART1_Read();
	MOVLW       _trama+0
	MOVWF       FLOC__interrupt+0 
	MOVLW       hi_addr(_trama+0)
	MOVWF       FLOC__interrupt+1 
	MOVF        _j+0, 0 
	ADDWF       FLOC__interrupt+0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FLOC__interrupt+1, 1 
	CALL        _UART1_Read+0, 0
	MOVFF       FLOC__interrupt+0, FSR1
	MOVFF       FLOC__interrupt+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;UART_LCD.c,33 :: 		j++;
	INCF        _j+0, 1 
;UART_LCD.c,36 :: 		PIR1.F5 = 0;
	BCF         PIR1+0, 5 
;UART_LCD.c,37 :: 		}
L_interrupt0:
;UART_LCD.c,38 :: 		}
L_end_interrupt:
L__interrupt5:
	RETFIE      1
; end of _interrupt

_Configuracion:

;UART_LCD.c,42 :: 		void Configuracion(){
;UART_LCD.c,44 :: 		RCIE_bit = 0;                         // enable interrupt on UART1 receive
	BCF         RCIE_bit+0, BitPos(RCIE_bit+0) 
;UART_LCD.c,45 :: 		TXIE_bit = 0;                         // disable interrupt on UART1 transmit
	BCF         TXIE_bit+0, BitPos(TXIE_bit+0) 
;UART_LCD.c,46 :: 		PEIE_bit = 1;                         // enable peripheral interrupts
	BSF         PEIE_bit+0, BitPos(PEIE_bit+0) 
;UART_LCD.c,47 :: 		GIE_bit = 1;
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
;UART_LCD.c,49 :: 		UART1_Init(9600);                     // Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       207
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;UART_LCD.c,50 :: 		Delay_ms(100);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       4
	MOVWF       R12, 0
	MOVLW       186
	MOVWF       R13, 0
L_Configuracion1:
	DECFSZ      R13, 1, 1
	BRA         L_Configuracion1
	DECFSZ      R12, 1, 1
	BRA         L_Configuracion1
	DECFSZ      R11, 1, 1
	BRA         L_Configuracion1
	NOP
;UART_LCD.c,52 :: 		Lcd_Init();                           // Initialize LCD
	CALL        _Lcd_Init+0, 0
;UART_LCD.c,53 :: 		Lcd_Cmd(_LCD_CLEAR);                  // Clear display
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;UART_LCD.c,54 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);             // Cursor off
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;UART_LCD.c,55 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;UART_LCD.c,58 :: 		void main() {
;UART_LCD.c,60 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;UART_LCD.c,61 :: 		Lcd_Out(1, 1, "Hello!");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_UART_LCD+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_UART_LCD+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;UART_LCD.c,62 :: 		ptrTT2 = &TT2;
	MOVLW       _TT2+0
	MOVWF       _ptrTT2+0 
	MOVLW       hi_addr(_TT2+0)
	MOVWF       _ptrTT2+1 
;UART_LCD.c,65 :: 		while (1){
L_main2:
;UART_LCD.c,68 :: 		*(ptrTT2) = trama[3];
	MOVFF       _ptrTT2+0, FSR1
	MOVFF       _ptrTT2+1, FSR1H
	MOVF        _trama+3, 0 
	MOVWF       POSTINC1+0 
;UART_LCD.c,69 :: 		*(ptrTT2+1) = trama[2];
	MOVLW       1
	ADDWF       _ptrTT2+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _ptrTT2+1, 0 
	MOVWF       FSR1H 
	MOVF        _trama+2, 0 
	MOVWF       POSTINC1+0 
;UART_LCD.c,70 :: 		*(ptrTT2+2) = trama[1];
	MOVLW       2
	ADDWF       _ptrTT2+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _ptrTT2+1, 0 
	MOVWF       FSR1H 
	MOVF        _trama+1, 0 
	MOVWF       POSTINC1+0 
;UART_LCD.c,71 :: 		*(ptrTT2+3) = trama[0];
	MOVLW       3
	ADDWF       _ptrTT2+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _ptrTT2+1, 0 
	MOVWF       FSR1H 
	MOVF        _trama+0, 0 
	MOVWF       POSTINC1+0 
;UART_LCD.c,73 :: 		j=0;
	CLRF        _j+0 
;UART_LCD.c,75 :: 		T2 = TT2 / 100.0;
	MOVF        _TT2+0, 0 
	MOVWF       R0 
	MOVF        _TT2+1, 0 
	MOVWF       R1 
	MOVF        _TT2+2, 0 
	MOVWF       R2 
	MOVF        _TT2+3, 0 
	MOVWF       R3 
	CALL        _longword2double+0, 0
	MOVLW       0
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVLW       72
	MOVWF       R6 
	MOVLW       133
	MOVWF       R7 
	CALL        _Div_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       _T2+0 
	MOVF        R1, 0 
	MOVWF       _T2+1 
	MOVF        R2, 0 
	MOVWF       _T2+2 
	MOVF        R3, 0 
	MOVWF       _T2+3 
;UART_LCD.c,76 :: 		FloatToStr(T2,txt1);
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
;UART_LCD.c,78 :: 		Lcd_Out(1, 1, "T2: ");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_UART_LCD+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_UART_LCD+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;UART_LCD.c,79 :: 		Lcd_Out_Cp(txt1);
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_CP_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_CP_text+1 
	CALL        _Lcd_Out_CP+0, 0
;UART_LCD.c,82 :: 		}
	GOTO        L_main2
;UART_LCD.c,84 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
