
_interrupt:

;Master.c,48 :: 		void interrupt(void){
;Master.c,49 :: 		if(PIR1.F5==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;Master.c,51 :: 		Dato = UART1_Read();
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _Dato+0 
;Master.c,53 :: 		if ((Dato==Hdr)&&(ir==0)){                   //Verifica que el primer dato en llegar sea el identificador de inicio de trama
	MOVF        R0, 0 
	XORLW       58
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt3
	MOVF        _ir+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt3
L__interrupt38:
;Master.c,54 :: 		BanT = 1;                                 //Activa una bandera de trama
	MOVLW       1
	MOVWF       _BanT+0 
;Master.c,55 :: 		Rspt[ir] = Dato;                          //Almacena el Dato en la trama de respuesta
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
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,56 :: 		}
L_interrupt3:
;Master.c,57 :: 		if ((Dato!=Hdr)&&(ir==0)){                   //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
	MOVF        _Dato+0, 0 
	XORLW       58
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt6
	MOVF        _ir+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt6
L__interrupt37:
;Master.c,58 :: 		ir=-1;                                    //Si es asi, reduce el subindice en una unidad
	MOVLW       255
	MOVWF       _ir+0 
;Master.c,59 :: 		}
L_interrupt6:
;Master.c,60 :: 		if ((BanT==1)&&(ir!=0)){
	MOVF        _BanT+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt9
	MOVF        _ir+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt9
L__interrupt36:
;Master.c,61 :: 		Rspt[ir] = Dato;                          //Almacena el resto de datos en la trama de respuesta si la bandera de trama esta activada
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
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Master.c,62 :: 		}
L_interrupt9:
;Master.c,64 :: 		ir++;                                        //Aumenta el subindice una unidad
	INCF        _ir+0, 1 
;Master.c,65 :: 		if (ir==Rsize){                              //Verifica que se haya terminado de llenar la trama de datos
	MOVF        _ir+0, 0 
	XORLW       6
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt10
;Master.c,66 :: 		BanP = 1;                                 //Habilita la bandera de lectura de datos
	MOVLW       1
	MOVWF       _BanP+0 
;Master.c,67 :: 		ir=0;                                     //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
	CLRF        _ir+0 
;Master.c,68 :: 		}
L_interrupt10:
;Master.c,70 :: 		PIR1.F5 = 0;                                 //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Master.c,71 :: 		}
L_interrupt0:
;Master.c,72 :: 		}
L_end_interrupt:
L__interrupt42:
	RETFIE      1
; end of _interrupt

_Configuracion:

;Master.c,75 :: 		void Configuracion(){
;Master.c,77 :: 		ANSELA = 0;                                       //Configura el PORTA como digital
	CLRF        ANSELA+0 
;Master.c,78 :: 		ANSELB = 0;                                       //Configura el PORTB como digital
	CLRF        ANSELB+0 
;Master.c,79 :: 		ANSELC = 0;                                       //Configura el PORTC como digital
	CLRF        ANSELC+0 
;Master.c,81 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;Master.c,82 :: 		TRISA0_bit = 1;
	BSF         TRISA0_bit+0, BitPos(TRISA0_bit+0) 
;Master.c,83 :: 		TRISA1_bit = 0;
	BCF         TRISA1_bit+0, BitPos(TRISA1_bit+0) 
;Master.c,85 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;Master.c,86 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;Master.c,87 :: 		INTCON.RBIF = 0;
	BCF         INTCON+0, 0 
;Master.c,89 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;Master.c,90 :: 		PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Master.c,92 :: 		UART1_Init(9600);                                 //Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	MOVLW       2
	MOVWF       SPBRGH+0 
	MOVLW       8
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;Master.c,93 :: 		Delay_ms(100);                                    //Espera para que el modulo UART se estabilice
	MOVLW       3
	MOVWF       R11, 0
	MOVLW       138
	MOVWF       R12, 0
	MOVLW       85
	MOVWF       R13, 0
L_Configuracion11:
	DECFSZ      R13, 1, 1
	BRA         L_Configuracion11
	DECFSZ      R12, 1, 1
	BRA         L_Configuracion11
	DECFSZ      R11, 1, 1
	BRA         L_Configuracion11
	NOP
	NOP
;Master.c,95 :: 		Lcd_Init();                                       // Initialize LCD
	CALL        _Lcd_Init+0, 0
;Master.c,96 :: 		Lcd_Cmd(_LCD_CLEAR);                              // Clear display
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;Master.c,97 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);                         // Cursor off
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;Master.c,98 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;Master.c,100 :: 		void main() {
;Master.c,102 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;Master.c,103 :: 		RC5_bit = 0;                                                   //Establece el Max485 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Master.c,105 :: 		ptrDst = &Dst;
	MOVLW       _Dst+0
	MOVWF       _ptrDst+0 
	MOVLW       hi_addr(_Dst+0)
	MOVWF       _ptrDst+1 
;Master.c,107 :: 		Ptcn[0]=Hdr;
	MOVLW       58
	MOVWF       _Ptcn+0 
;Master.c,108 :: 		Ptcn[1]=Id;
	MOVLW       2
	MOVWF       _Ptcn+1 
;Master.c,109 :: 		Ptcn[2]=Fcn;
	MOVLW       2
	MOVWF       _Ptcn+2 
;Master.c,110 :: 		Ptcn[3]=0x00;
	CLRF        _Ptcn+3 
;Master.c,111 :: 		Ptcn[4]=0x02;
	MOVLW       2
	MOVWF       _Ptcn+4 
;Master.c,112 :: 		Ptcn[5]=End;
	MOVLW       13
	MOVWF       _Ptcn+5 
;Master.c,114 :: 		Bb=0;
	CLRF        _Bb+0 
;Master.c,115 :: 		Dst=0;
	CLRF        _Dst+0 
	CLRF        _Dst+1 
;Master.c,117 :: 		while (1){
L_main12:
;Master.c,119 :: 		if ((RA0_bit==1)&&(Bb==0)){
	BTFSS       RA0_bit+0, BitPos(RA0_bit+0) 
	GOTO        L_main16
	MOVF        _Bb+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main16
L__main40:
;Master.c,120 :: 		Bb = 1;
	MOVLW       1
	MOVWF       _Bb+0 
;Master.c,121 :: 		RC5_bit = 1;                                         //Establece el Max485 en modo de escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;Master.c,122 :: 		for (ip=0;ip<Psize;ip++){
	CLRF        _ip+0 
L_main17:
	MOVLW       128
	XORWF       _ip+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       6
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main18
;Master.c,123 :: 		UART1_WRITE(Ptcn[ip]);                          //Manda por Uart la trama de peticion
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
;Master.c,122 :: 		for (ip=0;ip<Psize;ip++){
	INCF        _ip+0, 1 
;Master.c,124 :: 		}
	GOTO        L_main17
L_main18:
;Master.c,125 :: 		Dst = 0;
	CLRF        _Dst+0 
	CLRF        _Dst+1 
;Master.c,126 :: 		while(UART_Tx_Idle()==0);                            //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_main20:
	CALL        _UART_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main21
	GOTO        L_main20
L_main21:
;Master.c,127 :: 		RC5_bit = 0;                                         //Establece el Max485 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Master.c,128 :: 		} else if (RA0_bit==0){
	GOTO        L_main22
L_main16:
	BTFSC       RA0_bit+0, BitPos(RA0_bit+0) 
	GOTO        L_main23
;Master.c,129 :: 		Bb = 0;
	CLRF        _Bb+0 
;Master.c,130 :: 		}
L_main23:
L_main22:
;Master.c,132 :: 		if (BanP==1){
	MOVF        _BanP+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main24
;Master.c,133 :: 		if ((Rspt[1]==Id)&&(Rspt[Rsize-1]==End)){
	MOVF        _Rspt+1, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_main27
	MOVF        _Rspt+5, 0 
	XORLW       13
	BTFSS       STATUS+0, 2 
	GOTO        L_main27
L__main39:
;Master.c,135 :: 		*ptrDst = Rspt[4];
	MOVFF       _ptrDst+0, FSR1
	MOVFF       _ptrDst+1, FSR1H
	MOVF        _Rspt+4, 0 
	MOVWF       POSTINC1+0 
;Master.c,136 :: 		*(ptrDst+1) = Rspt[3];
	MOVLW       1
	ADDWF       _ptrDst+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _ptrDst+1, 0 
	MOVWF       FSR1H 
	MOVF        _Rspt+3, 0 
	MOVWF       POSTINC1+0 
;Master.c,138 :: 		for (irr=0;irr<(Rsize-1);irr++){
	CLRF        _irr+0 
L_main28:
	MOVLW       128
	XORWF       _irr+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       5
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main29
;Master.c,139 :: 		Rspt[irr]=0;;                            //Limpia los bits de datos de la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _irr+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _irr+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	CLRF        POSTINC1+0 
;Master.c,138 :: 		for (irr=0;irr<(Rsize-1);irr++){
	INCF        _irr+0, 1 
;Master.c,140 :: 		}
	GOTO        L_main28
L_main29:
;Master.c,141 :: 		BanP = 0;
	CLRF        _BanP+0 
;Master.c,144 :: 		} else {
	GOTO        L_main31
L_main27:
;Master.c,146 :: 		for (irr=0;irr<(Rsize-1);irr++){
	CLRF        _irr+0 
L_main32:
	MOVLW       128
	XORWF       _irr+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       5
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main33
;Master.c,147 :: 		Rspt[irr]=0;;                            //Limpia los bits de datos de la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _irr+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _irr+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	CLRF        POSTINC1+0 
;Master.c,146 :: 		for (irr=0;irr<(Rsize-1);irr++){
	INCF        _irr+0, 1 
;Master.c,148 :: 		}
	GOTO        L_main32
L_main33:
;Master.c,149 :: 		BanP = 0;
	CLRF        _BanP+0 
;Master.c,151 :: 		}
L_main31:
;Master.c,152 :: 		}
L_main24:
;Master.c,155 :: 		IntToStr(Dst,txt1);
	MOVF        _Dst+0, 0 
	MOVWF       FARG_IntToStr_input+0 
	MOVF        _Dst+1, 0 
	MOVWF       FARG_IntToStr_input+1 
	MOVLW       _txt1+0
	MOVWF       FARG_IntToStr_output+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_IntToStr_output+1 
	CALL        _IntToStr+0, 0
;Master.c,157 :: 		Lcd_Out(1,1,"Distancia:");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_Master+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_Master+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;Master.c,158 :: 		Lcd_Out(2,1,txt1);
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;Master.c,160 :: 		Delay_ms(20);
	MOVLW       130
	MOVWF       R12, 0
	MOVLW       221
	MOVWF       R13, 0
L_main35:
	DECFSZ      R13, 1, 1
	BRA         L_main35
	DECFSZ      R12, 1, 1
	BRA         L_main35
	NOP
	NOP
;Master.c,162 :: 		}
	GOTO        L_main12
;Master.c,163 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
