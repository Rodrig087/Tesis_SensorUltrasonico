
_interrupt:

;Splitter.c,28 :: 		void interrupt(void){
;Splitter.c,30 :: 		if(PIR1.F5==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;Splitter.c,31 :: 		RC5_bit = 0;                               //Establece el Max485-1 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,32 :: 		ByPtcn = UART1_Read();                     //Lee el byte de peticion
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _ByPtcn+0 
;Splitter.c,33 :: 		if ((ByPtcn==Hdr)&&(ip==0)){               //Verifica que el primer dato en llegar sea el identificador de inicio de trama
	MOVF        R0, 0 
	XORLW       238
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt3
	MOVF        _ip+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt3
L__interrupt68:
;Splitter.c,34 :: 		BanAP = 1;                              //Activa la bandera de almacenamiento de trama de peticion
	MOVLW       1
	MOVWF       _BanAP+0 
;Splitter.c,35 :: 		Ptcn[ip] = ByPtcn;                      //Almacena el Dato en la trama de peticion
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _ip+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _ip+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVF        _ByPtcn+0, 0 
	MOVWF       POSTINC1+0 
;Splitter.c,36 :: 		}
L_interrupt3:
;Splitter.c,37 :: 		if ((ByPtcn!=Hdr)&&(ip==0)){               //Verifica si el primer dato en llegar es diferente del identificador del inicio de trama
	MOVF        _ByPtcn+0, 0 
	XORLW       238
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt6
	MOVF        _ip+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt6
L__interrupt67:
;Splitter.c,38 :: 		ip=-1;                                  //Si es asi, reduce el subindice en una unidad
	MOVLW       255
	MOVWF       _ip+0 
;Splitter.c,39 :: 		}
L_interrupt6:
;Splitter.c,40 :: 		if ((BanAP==1)&&(ip!=0)){
	MOVF        _BanAP+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt9
	MOVF        _ip+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt9
L__interrupt66:
;Splitter.c,41 :: 		Ptcn[ip] = ByPtcn;                      //Almacena el resto de datos en la trama de peticion si la bandera de almacenamiento de trama esta activada
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _ip+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _ip+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	MOVF        _ByPtcn+0, 0 
	MOVWF       POSTINC1+0 
;Splitter.c,42 :: 		}
L_interrupt9:
;Splitter.c,43 :: 		ip++;                                      //Aumenta el subindice una unidad
	INCF        _ip+0, 1 
;Splitter.c,44 :: 		if (ip==Psize){                            //Verifica que se haya terminado de llenar la trama de peticion
	MOVF        _ip+0, 0 
	XORLW       4
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt10
;Splitter.c,45 :: 		BanLP = 1;                              //Habilita la bandera de lectura de peticion
	MOVLW       1
	MOVWF       _BanLP+0 
;Splitter.c,46 :: 		BanAP = 0;                              //Limpia la bandera de almacenamiento de trama de peticion
	CLRF        _BanAP+0 
;Splitter.c,47 :: 		ip=0;                                   //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
	CLRF        _ip+0 
;Splitter.c,48 :: 		}
L_interrupt10:
;Splitter.c,49 :: 		PIR1.F5 = 0;                               //Limpia la bandera de interrupcion de UART1
	BCF         PIR1+0, 5 
;Splitter.c,50 :: 		}
L_interrupt0:
;Splitter.c,52 :: 		if (PIR3.F5==1){
	BTFSS       PIR3+0, 5 
	GOTO        L_interrupt11
;Splitter.c,53 :: 		RB5_bit = 0;                               //Establece el Max485-1 en modo de lectura;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;Splitter.c,54 :: 		ByRspt = UART2_Read();                     //Lee el byte de respuesta
	CALL        _UART2_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _ByRspt+0 
;Splitter.c,55 :: 		if ((ByRspt==Hdr)&&(ir==0)){               //Verifica que el primer dato en llegar sea el identificador de inicio de trama
	MOVF        R0, 0 
	XORLW       238
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt14
	MOVF        _ir+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt14
L__interrupt65:
;Splitter.c,56 :: 		BanAR = 1;                              //Activa la bandera de almacenamiento de trama de respuesta
	MOVLW       1
	MOVWF       _BanAR+0 
;Splitter.c,57 :: 		Rspt[ir] = ByRspt;                      //Almacena el Dato en la trama de respuesta
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
	MOVF        _ByRspt+0, 0 
	MOVWF       POSTINC1+0 
;Splitter.c,58 :: 		}
L_interrupt14:
;Splitter.c,59 :: 		if ((ByRspt!=Hdr)&&(ir==0)){               //Verifica si el primer dato en llegar es diferente del identificador del inicio de trama
	MOVF        _ByRspt+0, 0 
	XORLW       238
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt17
	MOVF        _ir+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt17
L__interrupt64:
;Splitter.c,60 :: 		ir=-1;                                  //Si es asi, reduce el subindice en una unidad
	MOVLW       255
	MOVWF       _ir+0 
;Splitter.c,61 :: 		}
L_interrupt17:
;Splitter.c,62 :: 		if ((BanAR==1)&&(ir!=0)){
	MOVF        _BanAR+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt20
	MOVF        _ir+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt20
L__interrupt63:
;Splitter.c,63 :: 		Rspt[ir] = ByRspt;                      //Almacena el resto de datos en la trama de respuesta si la bandera de almacenamiento de trama esta activada
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
	MOVF        _ByRspt+0, 0 
	MOVWF       POSTINC1+0 
;Splitter.c,64 :: 		}
L_interrupt20:
;Splitter.c,65 :: 		ir++;                                      //Aumenta el subindice una unidad
	INCF        _ir+0, 1 
;Splitter.c,66 :: 		if (ir==Rsize){                            //Verifica que se haya terminado de llenar la trama de respuesta
	MOVF        _ir+0, 0 
	XORLW       6
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt21
;Splitter.c,67 :: 		BanLR = 1;                              //Habilita la bandera de lectura de respuesta
	MOVLW       1
	MOVWF       _BanLR+0 
;Splitter.c,68 :: 		BanAR = 0;                              //Limpia la bandera de almacenamiento de trama de respuesta
	CLRF        _BanAR+0 
;Splitter.c,69 :: 		ir=0;                                   //Limpia el subindice de la trama de respuesta para permitir una nueva secuencia de recepcion de datos
	CLRF        _ir+0 
;Splitter.c,70 :: 		}
L_interrupt21:
;Splitter.c,71 :: 		PIR3.F5 = 0;                               //Limpia la bandera de interrupcion de UART2
	BCF         PIR3+0, 5 
;Splitter.c,72 :: 		}
L_interrupt11:
;Splitter.c,75 :: 		}
L_end_interrupt:
L__interrupt74:
	RETFIE      1
; end of _interrupt

_Configuracion:

;Splitter.c,78 :: 		void Configuracion(){
;Splitter.c,80 :: 		ANSELB = 0;                                       //Configura PORTB como digital
	CLRF        ANSELB+0 
;Splitter.c,81 :: 		ANSELC = 0;                                       //Configura PORTC como digital
	CLRF        ANSELC+0 
;Splitter.c,83 :: 		TRISB5_bit = 0;                                   //Configura el pin B5 como salida
	BCF         TRISB5_bit+0, BitPos(TRISB5_bit+0) 
;Splitter.c,84 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;Splitter.c,86 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;Splitter.c,87 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;Splitter.c,90 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;Splitter.c,91 :: 		PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Splitter.c,92 :: 		PIE3.RC2IE = 1;                                   //Habilita la interrupcion en UART2 receive
	BSF         PIE3+0, 5 
;Splitter.c,93 :: 		PIR3.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR3+0, 5 
;Splitter.c,96 :: 		UART1_Init(9600);                                 //Inicializa el UART1 a 9600 bps
	BSF         BAUDCON+0, 3, 0
	MOVLW       2
	MOVWF       SPBRGH+0 
	MOVLW       8
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;Splitter.c,97 :: 		UART2_Init(9600);                                 //Inicializa el UART2 a 9600 bps
	BSF         BAUDCON2+0, 3, 0
	MOVLW       2
	MOVWF       SPBRGH2+0 
	MOVLW       8
	MOVWF       SPBRG2+0 
	BSF         TXSTA2+0, 2, 0
	CALL        _UART2_Init+0, 0
;Splitter.c,98 :: 		Delay_ms(100);                                    //Espera para que el modulo UART se estabilice
	MOVLW       3
	MOVWF       R11, 0
	MOVLW       138
	MOVWF       R12, 0
	MOVLW       85
	MOVWF       R13, 0
L_Configuracion22:
	DECFSZ      R13, 1, 1
	BRA         L_Configuracion22
	DECFSZ      R12, 1, 1
	BRA         L_Configuracion22
	DECFSZ      R11, 1, 1
	BRA         L_Configuracion22
	NOP
	NOP
;Splitter.c,100 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;Splitter.c,102 :: 		void main() {
;Splitter.c,104 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;Splitter.c,105 :: 		RC5_bit = 0;                                                   //Establece el Max485-1 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,106 :: 		RB5_bit = 0;                                                   //Establece el Max485-2 en modo de lectura;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;Splitter.c,107 :: 		ip=0;
	CLRF        _ip+0 
;Splitter.c,108 :: 		ir=0;
	CLRF        _ir+0 
;Splitter.c,110 :: 		while (1){
L_main23:
;Splitter.c,112 :: 		if (BanLP==1){                                          //Verifica la bandera de lectura de la trama de peticion
	MOVF        _BanLP+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main25
;Splitter.c,113 :: 		if ((Ptcn[0]==Hdr)&&(Ptcn[Psize-1]==End)){           //Verifica que el primer y el ultimo elemento de la trama correspondan a los delimitadores de inicio y fin de trama
	MOVF        _Ptcn+0, 0 
	XORLW       238
	BTFSS       STATUS+0, 2 
	GOTO        L_main28
	MOVF        _Ptcn+3, 0 
	XORLW       255
	BTFSS       STATUS+0, 2 
	GOTO        L_main28
L__main72:
;Splitter.c,114 :: 		if ((Ptcn[1]==TP)&&(Ptcn[2]==Id)){                //Verifica el identificador de tipo de sensor y el identificador de esclavo
	MOVF        _Ptcn+1, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main31
	MOVF        _Ptcn+2, 0 
	XORLW       7
	BTFSS       STATUS+0, 2 
	GOTO        L_main31
L__main71:
;Splitter.c,116 :: 		RB5_bit = 1;                                   //Establece el Max485-2 en modo de escritura
	BSF         RB5_bit+0, BitPos(RB5_bit+0) 
;Splitter.c,118 :: 		for (ipp=0;ipp<(Psize);ipp++){
	CLRF        _ipp+0 
L_main32:
	MOVLW       128
	XORWF       _ipp+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       4
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main33
;Splitter.c,119 :: 		UART2_Write(Ptcn[ipp]);                   //Reenvia la trama de peticion a travez del UART2
	MOVLW       _Ptcn+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR0H 
	MOVF        _ipp+0, 0 
	ADDWF       FSR0, 1 
	MOVLW       0
	BTFSC       _ipp+0, 7 
	MOVLW       255
	ADDWFC      FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART2_Write_data_+0 
	CALL        _UART2_Write+0, 0
;Splitter.c,118 :: 		for (ipp=0;ipp<(Psize);ipp++){
	INCF        _ipp+0, 1 
;Splitter.c,120 :: 		}
	GOTO        L_main32
L_main33:
;Splitter.c,122 :: 		while(UART2_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_main35:
	CALL        _UART2_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main36
	GOTO        L_main35
L_main36:
;Splitter.c,123 :: 		RB5_bit = 0;                                   //Establece el Max485-2 en modo de lectura;
	BCF         RB5_bit+0, BitPos(RB5_bit+0) 
;Splitter.c,125 :: 		for (ipp=0;ipp<(Psize);ipp++){
	CLRF        _ipp+0 
L_main37:
	MOVLW       128
	XORWF       _ipp+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       4
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main38
;Splitter.c,126 :: 		Ptcn[ipp]=0;;                             //Limpia la trama de peticion
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _ipp+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _ipp+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	CLRF        POSTINC1+0 
;Splitter.c,125 :: 		for (ipp=0;ipp<(Psize);ipp++){
	INCF        _ipp+0, 1 
;Splitter.c,127 :: 		}
	GOTO        L_main37
L_main38:
;Splitter.c,129 :: 		BanLP = 0;                                     //Limpia la bandera de lectura de la trama de peticion
	CLRF        _BanLP+0 
;Splitter.c,131 :: 		}
L_main31:
;Splitter.c,132 :: 		} else {
	GOTO        L_main40
L_main28:
;Splitter.c,134 :: 		for (ipp=0;ipp<(Psize-1);ipp++){
	CLRF        _ipp+0 
L_main41:
	MOVLW       128
	XORWF       _ipp+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       3
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main42
;Splitter.c,135 :: 		Ptcn[ipp]=0;;                            //Limpia la trama de peticion
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _ipp+0, 0 
	ADDWF       FSR1, 1 
	MOVLW       0
	BTFSC       _ipp+0, 7 
	MOVLW       255
	ADDWFC      FSR1H, 1 
	CLRF        POSTINC1+0 
;Splitter.c,134 :: 		for (ipp=0;ipp<(Psize-1);ipp++){
	INCF        _ipp+0, 1 
;Splitter.c,136 :: 		}
	GOTO        L_main41
L_main42:
;Splitter.c,138 :: 		BanLP = 0;                                    //Limpia la bandera de lectura de la trama de peticion
	CLRF        _BanLP+0 
;Splitter.c,140 :: 		}
L_main40:
;Splitter.c,141 :: 		}
L_main25:
;Splitter.c,144 :: 		if (BanLR==1){                                          //Verifica la bandera de lectura de la trama de respuesta
	MOVF        _BanLR+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main44
;Splitter.c,145 :: 		if ((Rspt[0]==Hdr)&&(Rspt[Rsize-1]==End)){           //Verifica que el primer y el ultimo elemento de la trama correspondan a los delimitadores de inicio y fin de trama
	MOVF        _Rspt+0, 0 
	XORLW       238
	BTFSS       STATUS+0, 2 
	GOTO        L_main47
	MOVF        _Rspt+5, 0 
	XORLW       255
	BTFSS       STATUS+0, 2 
	GOTO        L_main47
L__main70:
;Splitter.c,146 :: 		if ((Rspt[1]==TP)&&(Rspt[2]==Id)){                //Verifica el identificador de tipo de sensor y el identificador de esclavo
	MOVF        _Rspt+1, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main50
	MOVF        _Rspt+2, 0 
	XORLW       7
	BTFSS       STATUS+0, 2 
	GOTO        L_main50
L__main69:
;Splitter.c,148 :: 		RC5_bit = 1;                                  //Establece el Max485-1 en modo de escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,150 :: 		for (irr=0;irr<(Rsize);irr++){
	CLRF        _irr+0 
L_main51:
	MOVLW       128
	XORWF       _irr+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       6
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main52
;Splitter.c,151 :: 		UART1_Write(Rspt[irr]);                  //Reenvia la trama de respuesta a travez del UART1
	MOVLW       _Rspt+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR0H 
	MOVF        _irr+0, 0 
	ADDWF       FSR0, 1 
	MOVLW       0
	BTFSC       _irr+0, 7 
	MOVLW       255
	ADDWFC      FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Splitter.c,150 :: 		for (irr=0;irr<(Rsize);irr++){
	INCF        _irr+0, 1 
;Splitter.c,152 :: 		}
	GOTO        L_main51
L_main52:
;Splitter.c,154 :: 		while(UART1_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_main54:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main55
	GOTO        L_main54
L_main55:
;Splitter.c,155 :: 		RC5_bit = 0;                                   //Establece el Max485-2 en modo de lectura;
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Splitter.c,157 :: 		for (irr=0;irr<(Rsize);irr++){
	CLRF        _irr+0 
L_main56:
	MOVLW       128
	XORWF       _irr+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       6
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main57
;Splitter.c,158 :: 		Rspt[irr]=0;;                            //Limpia la trama de respuesta
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
;Splitter.c,157 :: 		for (irr=0;irr<(Rsize);irr++){
	INCF        _irr+0, 1 
;Splitter.c,159 :: 		}
	GOTO        L_main56
L_main57:
;Splitter.c,161 :: 		BanLR = 0;                                    //Limpia la bandera de lectura de la trama de respuesta
	CLRF        _BanLR+0 
;Splitter.c,163 :: 		}
L_main50:
;Splitter.c,164 :: 		} else {
	GOTO        L_main59
L_main47:
;Splitter.c,166 :: 		for (irr=0;irr<(Rsize-1);irr++){
	CLRF        _irr+0 
L_main60:
	MOVLW       128
	XORWF       _irr+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       5
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main61
;Splitter.c,167 :: 		Rspt[irr]=0;;                            //Limpia la trama de respuesta
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
;Splitter.c,166 :: 		for (irr=0;irr<(Rsize-1);irr++){
	INCF        _irr+0, 1 
;Splitter.c,168 :: 		}
	GOTO        L_main60
L_main61:
;Splitter.c,169 :: 		BanLR = 0;                                    //Limpia la bandera de lectura de la trama de respuesta
	CLRF        _BanLR+0 
;Splitter.c,171 :: 		}
L_main59:
;Splitter.c,172 :: 		}
L_main44:
;Splitter.c,176 :: 		}
	GOTO        L_main23
;Splitter.c,177 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
