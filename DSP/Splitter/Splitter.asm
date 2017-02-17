
_interrupt:

;Splitter.c,46 :: 		void interrupt(void){
;Splitter.c,47 :: 		if(PIR1.F5==1){                                 //Verifica la bandera de interrupcion del Uart1
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;Splitter.c,48 :: 		RA1_bit = ~RA1_bit;
	BTG         RA1_bit+0, BitPos(RA1_bit+0) 
;Splitter.c,49 :: 		Rspt[ir] = UART1_Read();                     //Almacena los datos de entrada byte a byte en el buffer de peticion
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
;Splitter.c,50 :: 		ir++;
	INCF        _ir+0, 1 
;Splitter.c,51 :: 		if (ir==Rsize){                              //Verifica que se haya terminado de llenar la trama de datos
	MOVF        _ir+0, 0 
	XORLW       6
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt1
;Splitter.c,52 :: 		BanP = 1;                                 //Habilita la bandera de lectura de datos
	MOVLW       1
	MOVWF       _BanP+0 
;Splitter.c,53 :: 		}
L_interrupt1:
;Splitter.c,54 :: 		PIR1.F5 = 0;                              //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Splitter.c,55 :: 		}
L_interrupt0:
;Splitter.c,56 :: 		}
L_end_interrupt:
L__interrupt34:
	RETFIE      1
; end of _interrupt

_Configuracion:

;Splitter.c,59 :: 		void Configuracion(){
;Splitter.c,61 :: 		ANSELA = 0;                                       //Configura el PORTA como digital
	CLRF        ANSELA+0 
;Splitter.c,62 :: 		ANSELB = 0;                                       //Configura el PORTB como digital
	CLRF        ANSELB+0 
;Splitter.c,64 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;Splitter.c,65 :: 		TRISA0_bit = 1;
	BSF         TRISA0_bit+0, BitPos(TRISA0_bit+0) 
;Splitter.c,66 :: 		TRISA1_bit = 0;
	BCF         TRISA1_bit+0, BitPos(TRISA1_bit+0) 
;Splitter.c,68 :: 		GIE_bit = 1;                                      //Habilita las interrupciones globales
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
;Splitter.c,69 :: 		PEIE_bit = 1;                                     //Habilita las interrupciones perifericas
	BSF         PEIE_bit+0, BitPos(PEIE_bit+0) 
;Splitter.c,70 :: 		RC1IE_bit = 1;                                    //Habilita la interrupcion en UART1 receive
	BSF         RC1IE_bit+0, BitPos(RC1IE_bit+0) 
;Splitter.c,71 :: 		TX1IE_bit = 0;                                    //Desabilita la interrupcion en UART1 transmit
	BCF         TX1IE_bit+0, BitPos(TX1IE_bit+0) 
;Splitter.c,72 :: 		PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Splitter.c,74 :: 		UART1_Init(9600);                                 //Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       207
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;Splitter.c,75 :: 		Delay_ms(100);                                    //Espera para que el modulo UART se estabilice
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
;Splitter.c,77 :: 		Lcd_Init();                                       // Initialize LCD
	CALL        _Lcd_Init+0, 0
;Splitter.c,78 :: 		Lcd_Cmd(_LCD_CLEAR);                              // Clear display
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;Splitter.c,79 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);                         // Cursor off
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;Splitter.c,80 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;Splitter.c,82 :: 		void main() {
;Splitter.c,84 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;Splitter.c,86 :: 		Lcd_Out(1, 1, "Hello!");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_Splitter+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_Splitter+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;Splitter.c,87 :: 		delay_ms(1);
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
;Splitter.c,88 :: 		ptrDst = &Dst;
	MOVLW       _Dst+0
	MOVWF       _ptrDst+0 
	MOVLW       hi_addr(_Dst+0)
	MOVWF       _ptrDst+1 
;Splitter.c,90 :: 		Ptcn[0]=Hdr;
	MOVLW       238
	MOVWF       _Ptcn+0 
;Splitter.c,91 :: 		Ptcn[1]=Tp;
	MOVLW       1
	MOVWF       _Ptcn+1 
;Splitter.c,92 :: 		Ptcn[2]=Id;
	MOVLW       7
	MOVWF       _Ptcn+2 
;Splitter.c,93 :: 		Ptcn[3]=End;
	MOVLW       255
	MOVWF       _Ptcn+3 
;Splitter.c,95 :: 		Bb=0;
	CLRF        _Bb+0 
;Splitter.c,96 :: 		Dst=0;
	CLRF        _Dst+0 
	CLRF        _Dst+1 
;Splitter.c,98 :: 		while (1){
L_main4:
;Splitter.c,100 :: 		if ((RA0_bit==1)&&(Bb==0)){
	BTFSS       RA0_bit+0, BitPos(RA0_bit+0) 
	GOTO        L_main8
	MOVF        _Bb+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main8
L__main32:
;Splitter.c,101 :: 		Bb = 1;
	MOVLW       1
	MOVWF       _Bb+0 
;Splitter.c,102 :: 		for (ip=0;ip<Psize;ip++){
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
;Splitter.c,103 :: 		UART1_WRITE(Ptcn[ip]);                          //Manda por Uart la trama de peticion
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
;Splitter.c,102 :: 		for (ip=0;ip<Psize;ip++){
	INCF        _ip+0, 1 
;Splitter.c,104 :: 		}
	GOTO        L_main9
L_main10:
;Splitter.c,106 :: 		}
L_main8:
;Splitter.c,108 :: 		if (BanP==1){
	MOVF        _BanP+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main12
;Splitter.c,109 :: 		if ((Rspt[0]==Hdr)&&(Rspt[Rsize-1]==End)){
	MOVF        _Rspt+0, 0 
	XORLW       238
	BTFSS       STATUS+0, 2 
	GOTO        L_main15
	MOVF        _Rspt+5, 0 
	XORLW       255
	BTFSS       STATUS+0, 2 
	GOTO        L_main15
L__main31:
;Splitter.c,110 :: 		if ((Rspt[1]==TP)&&(Rspt[2]==Id)){                //Verifica el identificador de tipo de sensor y el identificador de esclavo
	MOVF        _Rspt+1, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main18
	MOVF        _Rspt+2, 0 
	XORLW       7
	BTFSS       STATUS+0, 2 
	GOTO        L_main18
L__main30:
;Splitter.c,112 :: 		for (ir=3;ir<5;ir++){
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
;Splitter.c,113 :: 		*(ptrDst+(ir-3)) = Rspt[ir];               //Asigna a TT2 los datos tomados de la trama de peticion
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
	ADDWF       _ptrDst+0, 0 
	MOVWF       FSR1 
	MOVF        R1, 0 
	ADDWFC      _ptrDst+1, 0 
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
;Splitter.c,112 :: 		for (ir=3;ir<5;ir++){
	INCF        _ir+0, 1 
;Splitter.c,114 :: 		}
	GOTO        L_main19
L_main20:
;Splitter.c,115 :: 		for (ir=0;ir<(Rsize-1);ir++){
	CLRF        _ir+0 
L_main22:
	MOVLW       128
	XORWF       _ir+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       5
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main23
;Splitter.c,116 :: 		Rspt[ir]=0;;                            //Limpia los bits de datos de la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _ir+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _ir+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	CLRF        POSTINC1+0 
;Splitter.c,115 :: 		for (ir=0;ir<(Rsize-1);ir++){
	INCF        _ir+0, 1 
;Splitter.c,117 :: 		}
	GOTO        L_main22
L_main23:
;Splitter.c,119 :: 		BanP = 0;
	CLRF        _BanP+0 
;Splitter.c,120 :: 		ir=0;                                        //Limpia el subindice de la trama de peticion
	CLRF        _ir+0 
;Splitter.c,122 :: 		}
L_main18:
;Splitter.c,123 :: 		} else {
	GOTO        L_main25
L_main15:
;Splitter.c,125 :: 		for (ir=0;ir<(Rsize-1);ir++){
	CLRF        _ir+0 
L_main26:
	MOVLW       128
	XORWF       _ir+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       5
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main27
;Splitter.c,126 :: 		Rspt[ir]=0;;                            //Limpia los bits de datos de la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _ir+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _ir+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	CLRF        POSTINC1+0 
;Splitter.c,125 :: 		for (ir=0;ir<(Rsize-1);ir++){
	INCF        _ir+0, 1 
;Splitter.c,127 :: 		}
	GOTO        L_main26
L_main27:
;Splitter.c,128 :: 		BanP = 0;
	CLRF        _BanP+0 
;Splitter.c,129 :: 		ir=0;
	CLRF        _ir+0 
;Splitter.c,131 :: 		}
L_main25:
;Splitter.c,132 :: 		}
L_main12:
;Splitter.c,134 :: 		IntToStr(Dst,txt1);
	MOVF        _Dst+0, 0 
	MOVWF       FARG_IntToStr_input+0 
	MOVF        _Dst+1, 0 
	MOVWF       FARG_IntToStr_input+1 
	MOVLW       _txt1+0
	MOVWF       FARG_IntToStr_output+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_IntToStr_output+1 
	CALL        _IntToStr+0, 0
;Splitter.c,136 :: 		Lcd_Out(1, 1, "T2");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_Splitter+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_Splitter+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;Splitter.c,137 :: 		Lcd_Out(2,1,txt1);
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;Splitter.c,139 :: 		Delay_ms(10);
	MOVLW       26
	MOVWF       R12, 0
	MOVLW       248
	MOVWF       R13, 0
L_main29:
	DECFSZ      R13, 1, 1
	BRA         L_main29
	DECFSZ      R12, 1, 1
	BRA         L_main29
	NOP
;Splitter.c,140 :: 		Bb = 0;
	CLRF        _Bb+0 
;Splitter.c,142 :: 		}
	GOTO        L_main4
;Splitter.c,143 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
