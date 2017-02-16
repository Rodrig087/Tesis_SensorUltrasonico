
_interrupt:

;UART_LCD.c,39 :: 		void interrupt(void){
;UART_LCD.c,41 :: 		if (PIR1.F5){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;UART_LCD.c,42 :: 		LATD0_bit = ~LATD0_bit;
	BTG         LATD0_bit+0, BitPos(LATD0_bit+0) 
;UART_LCD.c,43 :: 		Rspt[ir] = UART1_Read();                     //Almacena los datos de entrada byte a byte en el buffer de peticion
	MOVLW       _Rspt+0
	MOVWF       FLOC__interrupt+0 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FLOC__interrupt+1 
	MOVF        _ir+0, 0 
	ADDWF       FLOC__interrupt+0, 1 
	MOVLW       0
	BTFSC       _ir+0, 7 
	MOVLW       255
	ADDWFC      FLOC__interrupt+1, 1 
	CALL        _UART1_Read+0, 0
	MOVFF       FLOC__interrupt+0, FSR1
	MOVFF       FLOC__interrupt+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;UART_LCD.c,44 :: 		ir++;
	INCF        _ir+0, 1 
;UART_LCD.c,45 :: 		if (ir==Rsize){                              //Verifica que se haya terminado de llenar la trama de datos
	MOVF        _ir+0, 0 
	XORLW       6
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt1
;UART_LCD.c,46 :: 		BanP = 1;                                 //Habilita la bandera de lectura de datos
	MOVLW       1
	MOVWF       _BanP+0 
;UART_LCD.c,47 :: 		}
L_interrupt1:
;UART_LCD.c,48 :: 		PIR1.F5 = 0;                                 //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;UART_LCD.c,49 :: 		}
L_interrupt0:
;UART_LCD.c,50 :: 		}
L_end_interrupt:
L__interrupt27:
	RETFIE      1
; end of _interrupt

_Configuracion:

;UART_LCD.c,54 :: 		void Configuracion(){
;UART_LCD.c,56 :: 		TRISD0_bit = 0;
	BCF         TRISD0_bit+0, BitPos(TRISD0_bit+0) 
;UART_LCD.c,57 :: 		TRISD1_bit = 1;
	BSF         TRISD1_bit+0, BitPos(TRISD1_bit+0) 
;UART_LCD.c,59 :: 		INTCON.GIE = 1;                             //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;UART_LCD.c,60 :: 		INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;UART_LCD.c,61 :: 		INTCON2.RBPU = 0;
	BCF         INTCON2+0, 7 
;UART_LCD.c,63 :: 		ADCON1 = 0b00001111;                        //Configuracion ADCON1
	MOVLW       15
	MOVWF       ADCON1+0 
;UART_LCD.c,64 :: 		CMCON = 0b00000111;
	MOVLW       7
	MOVWF       CMCON+0 
;UART_LCD.c,66 :: 		RCIE_bit = 1;                         // enable interrupt on UART1 receive
	BSF         RCIE_bit+0, BitPos(RCIE_bit+0) 
;UART_LCD.c,67 :: 		TXIE_bit = 0;                         // disable interrupt on UART1 transmit
	BCF         TXIE_bit+0, BitPos(TXIE_bit+0) 
;UART_LCD.c,68 :: 		PEIE_bit = 1;                         // enable peripheral interrupts
	BSF         PEIE_bit+0, BitPos(PEIE_bit+0) 
;UART_LCD.c,69 :: 		GIE_bit = 1;
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
;UART_LCD.c,71 :: 		UART1_Init(9600);                     // Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       207
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;UART_LCD.c,72 :: 		Delay_ms(100);
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
;UART_LCD.c,74 :: 		Lcd_Init();                           // Initialize LCD
	CALL        _Lcd_Init+0, 0
;UART_LCD.c,75 :: 		Lcd_Cmd(_LCD_CLEAR);                  // Clear display
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;UART_LCD.c,76 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);             // Cursor off
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;UART_LCD.c,77 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;UART_LCD.c,80 :: 		void main() {
;UART_LCD.c,82 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;UART_LCD.c,83 :: 		Lcd_Out(1, 1, "Hello!");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_UART_LCD+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_UART_LCD+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;UART_LCD.c,84 :: 		delay_ms(1);
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
;UART_LCD.c,85 :: 		ptrTT2 = &TT2;
	MOVLW       _TT2+0
	MOVWF       _ptrTT2+0 
	MOVLW       hi_addr(_TT2+0)
	MOVWF       _ptrTT2+1 
;UART_LCD.c,87 :: 		Ptcn[0]=Hdr;
	MOVLW       238
	MOVWF       _Ptcn+0 
;UART_LCD.c,88 :: 		Ptcn[1]=Tp;
	MOVLW       1
	MOVWF       _Ptcn+1 
;UART_LCD.c,89 :: 		Ptcn[2]=Id;
	MOVLW       7
	MOVWF       _Ptcn+2 
;UART_LCD.c,90 :: 		Ptcn[3]=End;
	MOVLW       255
	MOVWF       _Ptcn+3 
;UART_LCD.c,92 :: 		Bb=0;
	CLRF        _Bb+0 
;UART_LCD.c,93 :: 		T2=0;
	CLRF        _T2+0 
	CLRF        _T2+1 
;UART_LCD.c,95 :: 		while (1){
L_main4:
;UART_LCD.c,97 :: 		if ((RD1_bit==1)&&(Bb==0)){
	BTFSS       RD1_bit+0, BitPos(RD1_bit+0) 
	GOTO        L_main8
	MOVF        _Bb+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main8
L__main25:
;UART_LCD.c,98 :: 		Bb = 1;
	MOVLW       1
	MOVWF       _Bb+0 
;UART_LCD.c,99 :: 		for (ip=0;ip<Psize;ip++){
	CLRF        _ip+0 
L_main9:
	MOVLW       128
	XORWF       _ip+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       4
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main10
;UART_LCD.c,100 :: 		UART1_WRITE(Ptcn[ip]);
	MOVLW       _Ptcn+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR0H 
	MOVF        _ip+0, 0 
	ADDWF       FSR0, 1 
	MOVLW       0
	BTFSC       _ip+0, 7 
	MOVLW       255
	ADDWFC      FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;UART_LCD.c,99 :: 		for (ip=0;ip<Psize;ip++){
	INCF        _ip+0, 1 
;UART_LCD.c,101 :: 		}
	GOTO        L_main9
L_main10:
;UART_LCD.c,102 :: 		}
L_main8:
;UART_LCD.c,104 :: 		if (BanP==1){
	MOVF        _BanP+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main12
;UART_LCD.c,105 :: 		if ((Rspt[0]==Hdr)&&(Rspt[Rsize-1]==End)){
	MOVF        _Rspt+0, 0 
	XORLW       238
	BTFSS       STATUS+0, 2 
	GOTO        L_main15
	MOVF        _Rspt+5, 0 
	XORLW       255
	BTFSS       STATUS+0, 2 
	GOTO        L_main15
L__main24:
;UART_LCD.c,106 :: 		if ((Rspt[1]==TP)&&(Rspt[2]==Id)){           //Verifica el identificador de tipo de sensor y el identificador de esclavo
	MOVF        _Rspt+1, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main18
	MOVF        _Rspt+2, 0 
	XORLW       7
	BTFSS       STATUS+0, 2 
	GOTO        L_main18
L__main23:
;UART_LCD.c,108 :: 		for (ir=3;ir<5;ir++){
	MOVLW       3
	MOVWF       _ir+0 
L_main19:
	MOVLW       128
	XORWF       _ir+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       5
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main20
;UART_LCD.c,109 :: 		*(ptrTT2+(ir-3)) = Rspt[ir];               //Asigna a TT2 los datos tomados de la trama de peticion
	MOVLW       3
	SUBWF       _ir+0, 0 
	MOVWF       R0 
	MOVLW       0
	BTFSC       _ir+0, 7 
	MOVLW       255
	MOVWF       R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVF        R0, 0 
	ADDWF       _ptrTT2+0, 0 
	MOVWF       FSR1 
	MOVF        R1, 0 
	ADDWFC      _ptrTT2+1, 0 
	MOVWF       FSR1H 
	MOVLW       _Rspt+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR0H 
	MOVF        _ir+0, 0 
	ADDWF       FSR0, 1 
	MOVLW       0
	BTFSC       _ir+0, 7 
	MOVLW       255
	ADDWFC      FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;UART_LCD.c,108 :: 		for (ir=3;ir<5;ir++){
	INCF        _ir+0, 1 
;UART_LCD.c,110 :: 		}
	GOTO        L_main19
L_main20:
;UART_LCD.c,112 :: 		BanP = 0;
	CLRF        _BanP+0 
;UART_LCD.c,113 :: 		ir=0;                                     //Limpia el subindice de la trama de peticion
	CLRF        _ir+0 
;UART_LCD.c,114 :: 		}
L_main18:
;UART_LCD.c,115 :: 		}
L_main15:
;UART_LCD.c,116 :: 		}
L_main12:
;UART_LCD.c,119 :: 		T2 = TT2;
	MOVF        _TT2+0, 0 
	MOVWF       _T2+0 
	MOVF        _TT2+1, 0 
	MOVWF       _T2+1 
;UART_LCD.c,120 :: 		IntToStr(T2,txt1);
	MOVF        _TT2+0, 0 
	MOVWF       FARG_IntToStr_input+0 
	MOVF        _TT2+1, 0 
	MOVWF       FARG_IntToStr_input+1 
	MOVLW       _txt1+0
	MOVWF       FARG_IntToStr_output+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_IntToStr_output+1 
	CALL        _IntToStr+0, 0
;UART_LCD.c,122 :: 		Lcd_Out(1, 1, "T2: ");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_UART_LCD+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_UART_LCD+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;UART_LCD.c,123 :: 		Lcd_Out(2,1,txt1);
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;UART_LCD.c,126 :: 		Delay_ms(10);
	MOVLW       26
	MOVWF       R12, 0
	MOVLW       248
	MOVWF       R13, 0
L_main22:
	DECFSZ      R13, 1, 1
	BRA         L_main22
	DECFSZ      R12, 1, 1
	BRA         L_main22
	NOP
;UART_LCD.c,127 :: 		Bb = 0;
	CLRF        _Bb+0 
;UART_LCD.c,129 :: 		}
	GOTO        L_main4
;UART_LCD.c,131 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
