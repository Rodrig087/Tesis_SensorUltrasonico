
_interrupt:

;UART_LCD.c,38 :: 		void interrupt(void){
;UART_LCD.c,40 :: 		if (PIR1.F5){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;UART_LCD.c,41 :: 		LATD0_bit = ~LATD0_bit;
	BTG         LATD0_bit+0, BitPos(LATD0_bit+0) 
;UART_LCD.c,42 :: 		trama[i] = UART1_Read();                     //Almacena los datos de entrada byte a byte en el buffer de peticion
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
;UART_LCD.c,43 :: 		i++;
	INCF        _i+0, 1 
;UART_LCD.c,44 :: 		if (i==4){                                   //Verifica que se haya terminado de llenar la trama de datos
	MOVF        _i+0, 0 
	XORLW       4
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt1
;UART_LCD.c,45 :: 		BanL = 1;                                 //Habilita la bandera de lectura de datos
	MOVLW       1
	MOVWF       _BanL+0 
;UART_LCD.c,46 :: 		}
L_interrupt1:
;UART_LCD.c,47 :: 		PIR1.F5 = 0;                                 //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;UART_LCD.c,48 :: 		}
L_interrupt0:
;UART_LCD.c,49 :: 		}
L_end_interrupt:
L__interrupt19:
	RETFIE      1
; end of _interrupt

_Configuracion:

;UART_LCD.c,53 :: 		void Configuracion(){
;UART_LCD.c,55 :: 		TRISD0_bit = 0;
	BCF         TRISD0_bit+0, BitPos(TRISD0_bit+0) 
;UART_LCD.c,56 :: 		TRISD1_bit = 1;
	BSF         TRISD1_bit+0, BitPos(TRISD1_bit+0) 
;UART_LCD.c,58 :: 		INTCON.GIE = 1;                             //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;UART_LCD.c,59 :: 		INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;UART_LCD.c,60 :: 		INTCON2.RBPU = 0;
	BCF         INTCON2+0, 7 
;UART_LCD.c,62 :: 		ADCON1 = 0b00001111;                        //Configuracion ADCON1
	MOVLW       15
	MOVWF       ADCON1+0 
;UART_LCD.c,63 :: 		CMCON = 0b00000111;
	MOVLW       7
	MOVWF       CMCON+0 
;UART_LCD.c,65 :: 		RCIE_bit = 1;                         // enable interrupt on UART1 receive
	BSF         RCIE_bit+0, BitPos(RCIE_bit+0) 
;UART_LCD.c,66 :: 		TXIE_bit = 0;                         // disable interrupt on UART1 transmit
	BCF         TXIE_bit+0, BitPos(TXIE_bit+0) 
;UART_LCD.c,67 :: 		PEIE_bit = 1;                         // enable peripheral interrupts
	BSF         PEIE_bit+0, BitPos(PEIE_bit+0) 
;UART_LCD.c,68 :: 		GIE_bit = 1;
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
;UART_LCD.c,70 :: 		UART1_Init(9600);                     // Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       207
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;UART_LCD.c,71 :: 		Delay_ms(100);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       4
	MOVWF       R12, 0
	MOVLW       186
	MOVWF       R13, 0
L_Configuracion2:
	DECFSZ      R13, 1, 1
	BRA         L_Configuracion2
	DECFSZ      R12, 1, 1
	BRA         L_Configuracion2
	DECFSZ      R11, 1, 1
	BRA         L_Configuracion2
	NOP
;UART_LCD.c,73 :: 		Lcd_Init();                           // Initialize LCD
	CALL        _Lcd_Init+0, 0
;UART_LCD.c,74 :: 		Lcd_Cmd(_LCD_CLEAR);                  // Clear display
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;UART_LCD.c,75 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);             // Cursor off
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;UART_LCD.c,76 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;UART_LCD.c,79 :: 		void main() {
;UART_LCD.c,81 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;UART_LCD.c,82 :: 		Lcd_Out(1, 1, "Hello!");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_UART_LCD+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_UART_LCD+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;UART_LCD.c,83 :: 		delay_ms(1);
	MOVLW       3
	MOVWF       R12, 0
	MOVLW       151
	MOVWF       R13, 0
L_main3:
	DECFSZ      R13, 1, 1
	BRA         L_main3
	DECFSZ      R12, 1, 1
	BRA         L_main3
	NOP
	NOP
;UART_LCD.c,84 :: 		ptrTT2 = &TT2;
	MOVLW       _TT2+0
	MOVWF       _ptrTT2+0 
	MOVLW       hi_addr(_TT2+0)
	MOVWF       _ptrTT2+1 
;UART_LCD.c,86 :: 		Ptcn[0]=0xEE;
	MOVLW       238
	MOVWF       _Ptcn+0 
;UART_LCD.c,87 :: 		Ptcn[1]=0x01;
	MOVLW       1
	MOVWF       _Ptcn+1 
;UART_LCD.c,88 :: 		Ptcn[2]=0x07;
	MOVLW       7
	MOVWF       _Ptcn+2 
;UART_LCD.c,89 :: 		Ptcn[3]=0xFF;
	MOVLW       255
	MOVWF       _Ptcn+3 
;UART_LCD.c,91 :: 		Bb=0;
	CLRF        _Bb+0 
;UART_LCD.c,93 :: 		while (1){
L_main4:
;UART_LCD.c,95 :: 		if ((RD1_bit==1)&&(Bb==0)){
	BTFSS       RD1_bit+0, BitPos(RD1_bit+0) 
	GOTO        L_main8
	MOVF        _Bb+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main8
L__main17:
;UART_LCD.c,96 :: 		Bb = 1;
	MOVLW       1
	MOVWF       _Bb+0 
;UART_LCD.c,97 :: 		for (j=0;j<4;j++){
	CLRF        _j+0 
L_main9:
	MOVLW       4
	SUBWF       _j+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main10
;UART_LCD.c,98 :: 		UART1_WRITE(Ptcn[j]);
	MOVLW       _Ptcn+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR0H 
	MOVF        _j+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;UART_LCD.c,97 :: 		for (j=0;j<4;j++){
	INCF        _j+0, 1 
;UART_LCD.c,99 :: 		}
	GOTO        L_main9
L_main10:
;UART_LCD.c,100 :: 		}
L_main8:
;UART_LCD.c,102 :: 		if (BanL==1){
	MOVF        _BanL+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main12
;UART_LCD.c,104 :: 		for (j=1;j<5;j++){
	MOVLW       1
	MOVWF       _j+0 
L_main13:
	MOVLW       5
	SUBWF       _j+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main14
;UART_LCD.c,106 :: 		trama2[j-1]= trama[j];
	DECF        _j+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _trama2+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_trama2+0)
	ADDWFC      R1, 0 
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
;UART_LCD.c,104 :: 		for (j=1;j<5;j++){
	INCF        _j+0, 1 
;UART_LCD.c,107 :: 		}
	GOTO        L_main13
L_main14:
;UART_LCD.c,109 :: 		BanL = 0;
	CLRF        _BanL+0 
;UART_LCD.c,110 :: 		i=0;
	CLRF        _i+0 
;UART_LCD.c,112 :: 		}
L_main12:
;UART_LCD.c,114 :: 		T2 = TT2 / 100.0;
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
;UART_LCD.c,115 :: 		FloatToStr(T2,txt1);
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
;UART_LCD.c,117 :: 		Lcd_Out(1, 1, "T2: ");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_UART_LCD+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_UART_LCD+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;UART_LCD.c,118 :: 		Lcd_Out(2,1,txt1);
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;UART_LCD.c,121 :: 		Delay_ms(10);
	MOVLW       26
	MOVWF       R12, 0
	MOVLW       248
	MOVWF       R13, 0
L_main16:
	DECFSZ      R13, 1, 1
	BRA         L_main16
	DECFSZ      R12, 1, 1
	BRA         L_main16
	NOP
;UART_LCD.c,122 :: 		Bb = 0;
	CLRF        _Bb+0 
;UART_LCD.c,124 :: 		}
	GOTO        L_main4
;UART_LCD.c,126 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
