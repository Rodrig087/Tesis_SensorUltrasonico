
_interrupt:

;Splitter.c,48 :: 		void interrupt(void){
;Splitter.c,49 :: 		if(PIR1.F5==1){                                 //Verifica la bandera de interrupcion del Uart1
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;Splitter.c,57 :: 		dato = UART1_Read();
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _dato+0 
;Splitter.c,58 :: 		BanP = 1;
	MOVLW       1
	MOVWF       _BanP+0 
;Splitter.c,59 :: 		}
L_interrupt0:
;Splitter.c,60 :: 		}
L_end_interrupt:
L__interrupt14:
	RETFIE      1
; end of _interrupt

_Configuracion:

;Splitter.c,63 :: 		void Configuracion(){
;Splitter.c,65 :: 		ANSELA = 0;                                       //Configura el PORTA como digital
	CLRF        ANSELA+0 
;Splitter.c,66 :: 		ANSELB = 0;                                       //Configura el PORTB como digital
	CLRF        ANSELB+0 
;Splitter.c,67 :: 		ANSELC = 0;                                       //Configura el PORTC como digital
	CLRF        ANSELC+0 
;Splitter.c,69 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;Splitter.c,70 :: 		TRISA0_bit = 1;
	BSF         TRISA0_bit+0, BitPos(TRISA0_bit+0) 
;Splitter.c,71 :: 		TRISA1_bit = 0;
	BCF         TRISA1_bit+0, BitPos(TRISA1_bit+0) 
;Splitter.c,73 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;Splitter.c,74 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;Splitter.c,75 :: 		INTCON.RBIF = 0;
	BCF         INTCON+0, 0 
;Splitter.c,77 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;Splitter.c,78 :: 		PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Splitter.c,80 :: 		UART1_Init(9600);                                 //Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       207
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;Splitter.c,81 :: 		Delay_ms(100);                                    //Espera para que el modulo UART se estabilice
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
;Splitter.c,83 :: 		Lcd_Init();                                       // Initialize LCD
	CALL        _Lcd_Init+0, 0
;Splitter.c,84 :: 		Lcd_Cmd(_LCD_CLEAR);                              // Clear display
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;Splitter.c,85 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);                         // Cursor off
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;Splitter.c,86 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;Splitter.c,88 :: 		void main() {
;Splitter.c,90 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;Splitter.c,92 :: 		ptrDst = &Dst;
	MOVLW       _Dst+0
	MOVWF       _ptrDst+0 
	MOVLW       hi_addr(_Dst+0)
	MOVWF       _ptrDst+1 
;Splitter.c,94 :: 		Ptcn[0]=Hdr;
	MOVLW       238
	MOVWF       _Ptcn+0 
;Splitter.c,95 :: 		Ptcn[1]=Tp;
	MOVLW       1
	MOVWF       _Ptcn+1 
;Splitter.c,96 :: 		Ptcn[2]=Id;
	MOVLW       7
	MOVWF       _Ptcn+2 
;Splitter.c,97 :: 		Ptcn[3]=End;
	MOVLW       255
	MOVWF       _Ptcn+3 
;Splitter.c,99 :: 		Bb=0;
	CLRF        _Bb+0 
;Splitter.c,100 :: 		Dst=0;
	CLRF        _Dst+0 
	CLRF        _Dst+1 
;Splitter.c,102 :: 		while (1){
L_main2:
;Splitter.c,104 :: 		if ((RA0_bit==1)&&(Bb==0)){
	BTFSS       RA0_bit+0, BitPos(RA0_bit+0) 
	GOTO        L_main6
	MOVF        _Bb+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main6
L__main12:
;Splitter.c,105 :: 		Bb = 1;
	MOVLW       1
	MOVWF       _Bb+0 
;Splitter.c,106 :: 		for (ip=0;ip<Psize;ip++){
	CLRF        _ip+0 
L_main7:
	MOVLW       128
	XORWF       _ip+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       4
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main8
;Splitter.c,107 :: 		UART1_WRITE(Ptcn[ip]);                          //Manda por Uart la trama de peticion
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
;Splitter.c,106 :: 		for (ip=0;ip<Psize;ip++){
	INCF        _ip+0, 1 
;Splitter.c,108 :: 		}
	GOTO        L_main7
L_main8:
;Splitter.c,110 :: 		}
L_main6:
;Splitter.c,138 :: 		if (BanP==1){
	MOVF        _BanP+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main10
;Splitter.c,139 :: 		Dst = Dst+1;
	INFSNZ      _Dst+0, 1 
	INCF        _Dst+1, 1 
;Splitter.c,140 :: 		BanP=0;
	CLRF        _BanP+0 
;Splitter.c,141 :: 		}
L_main10:
;Splitter.c,143 :: 		IntToStr(Dst,txt1);
	MOVF        _Dst+0, 0 
	MOVWF       FARG_IntToStr_input+0 
	MOVF        _Dst+1, 0 
	MOVWF       FARG_IntToStr_input+1 
	MOVLW       _txt1+0
	MOVWF       FARG_IntToStr_output+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_IntToStr_output+1 
	CALL        _IntToStr+0, 0
;Splitter.c,145 :: 		Lcd_Out(1,1,"Distancia:");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_Splitter+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_Splitter+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;Splitter.c,146 :: 		Lcd_Out(2,1,txt1);
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;Splitter.c,148 :: 		Delay_ms(20);
	MOVLW       52
	MOVWF       R12, 0
	MOVLW       241
	MOVWF       R13, 0
L_main11:
	DECFSZ      R13, 1, 1
	BRA         L_main11
	DECFSZ      R12, 1, 1
	BRA         L_main11
	NOP
	NOP
;Splitter.c,149 :: 		Bb = 0;
	CLRF        _Bb+0 
;Splitter.c,151 :: 		}
	GOTO        L_main2
;Splitter.c,152 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
