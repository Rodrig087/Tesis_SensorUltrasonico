
_interrupt:

;Splitter.c,28 :: 		void interrupt(void){
;Splitter.c,30 :: 		if(PIR1.F5==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;Splitter.c,31 :: 		ByPtcn = UART1_Read();                     //Lee el byte de peticion
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _ByPtcn+0 
;Splitter.c,32 :: 		if ((ByPtcn==Hdr)&&(ip==0)){               //Verifica que el primer dato en llegar sea el identificador de inicio de trama
	MOVF        R0, 0 
	XORLW       238
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt3
	MOVF        _ip+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt3
L__interrupt64:
;Splitter.c,33 :: 		BanAP = 1;                              //Activa la bandera de almacenamiento de trama de peticion
	MOVLW       1
	MOVWF       _BanAP+0 
;Splitter.c,34 :: 		Ptcn[ip] = ByPtcn;                      //Almacena el Dato en la trama de peticion
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
;Splitter.c,35 :: 		}
L_interrupt3:
;Splitter.c,36 :: 		if ((ByPtcn!=Hdr)&&(ip==0)){               //Verifica si el primer dato en llegar es diferente del identificador del inicio de trama
	MOVF        _ByPtcn+0, 0 
	XORLW       238
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt6
	MOVF        _ip+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt6
L__interrupt63:
;Splitter.c,37 :: 		ip=-1;                                  //Si es asi, reduce el subindice en una unidad
	MOVLW       255
	MOVWF       _ip+0 
;Splitter.c,38 :: 		}
L_interrupt6:
;Splitter.c,39 :: 		if ((BanAP==1)&&(ip!=0)){
	MOVF        _BanAP+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt9
	MOVF        _ip+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt9
L__interrupt62:
;Splitter.c,40 :: 		Ptcn[ip] = ByPtcn;                      //Almacena el resto de datos en la trama de peticion si la bandera de almacenamiento de trama esta activada
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
;Splitter.c,41 :: 		}
L_interrupt9:
;Splitter.c,42 :: 		ip++;                                      //Aumenta el subindice una unidad
	INCF        _ip+0, 1 
;Splitter.c,43 :: 		if (ip==Psize){                            //Verifica que se haya terminado de llenar la trama de peticion
	MOVF        _ip+0, 0 
	XORLW       4
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt10
;Splitter.c,44 :: 		BanLP = 1;                              //Habilita la bandera de lectura de peticion
	MOVLW       1
	MOVWF       _BanLP+0 
;Splitter.c,45 :: 		BanAP = 0;                              //Limpia la bandera de almacenamiento de trama de peticion
	CLRF        _BanAP+0 
;Splitter.c,46 :: 		ip=0;                                   //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
	CLRF        _ip+0 
;Splitter.c,47 :: 		}
L_interrupt10:
;Splitter.c,48 :: 		PIR1.F5 = 0;                               //Limpia la bandera de interrupcion de UART1
	BCF         PIR1+0, 5 
;Splitter.c,49 :: 		}
L_interrupt0:
;Splitter.c,51 :: 		if (PIR3.F5==1){
	BTFSS       PIR3+0, 5 
	GOTO        L_interrupt11
;Splitter.c,52 :: 		ByRspt = UART2_Read();                     //Lee el byte de respuesta
	CALL        _UART2_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _ByRspt+0 
;Splitter.c,53 :: 		if ((ByRspt==Hdr)&&(ir==0)){               //Verifica que el primer dato en llegar sea el identificador de inicio de trama
	MOVF        R0, 0 
	XORLW       238
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt14
	MOVF        _ir+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt14
L__interrupt61:
;Splitter.c,54 :: 		BanAR = 1;                              //Activa la bandera de almacenamiento de trama de respuesta
	MOVLW       1
	MOVWF       _BanAR+0 
;Splitter.c,55 :: 		Rspt[ir] = ByRspt;                      //Almacena el Dato en la trama de respuesta
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
;Splitter.c,56 :: 		}
L_interrupt14:
;Splitter.c,57 :: 		if ((ByRspt!=Hdr)&&(ir==0)){               //Verifica si el primer dato en llegar es diferente del identificador del inicio de trama
	MOVF        _ByRspt+0, 0 
	XORLW       238
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt17
	MOVF        _ir+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt17
L__interrupt60:
;Splitter.c,58 :: 		ir=-1;                                  //Si es asi, reduce el subindice en una unidad
	MOVLW       255
	MOVWF       _ir+0 
;Splitter.c,59 :: 		}
L_interrupt17:
;Splitter.c,60 :: 		if ((BanAR==1)&&(ir!=0)){
	MOVF        _BanAR+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt20
	MOVF        _ir+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt20
L__interrupt59:
;Splitter.c,61 :: 		Rspt[ir] = ByRspt;                      //Almacena el resto de datos en la trama de respuesta si la bandera de almacenamiento de trama esta activada
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
;Splitter.c,62 :: 		}
L_interrupt20:
;Splitter.c,63 :: 		ir++;                                      //Aumenta el subindice una unidad
	INCF        _ir+0, 1 
;Splitter.c,64 :: 		if (ir==Rsize){                            //Verifica que se haya terminado de llenar la trama de respuesta
	MOVF        _ir+0, 0 
	XORLW       6
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt21
;Splitter.c,65 :: 		BanLR = 1;                              //Habilita la bandera de lectura de respuesta
	MOVLW       1
	MOVWF       _BanLR+0 
;Splitter.c,66 :: 		BanAR = 0;                              //Limpia la bandera de almacenamiento de trama de respuesta
	CLRF        _BanAR+0 
;Splitter.c,67 :: 		ir=0;                                   //Limpia el subindice de la trama de respuesta para permitir una nueva secuencia de recepcion de datos
	CLRF        _ir+0 
;Splitter.c,68 :: 		}
L_interrupt21:
;Splitter.c,69 :: 		PIR3.F5 = 0;                               //Limpia la bandera de interrupcion de UART2
	BCF         PIR3+0, 5 
;Splitter.c,70 :: 		}
L_interrupt11:
;Splitter.c,73 :: 		}
L_end_interrupt:
L__interrupt70:
	RETFIE      1
; end of _interrupt

_Configuracion:

;Splitter.c,76 :: 		void Configuracion(){
;Splitter.c,78 :: 		ANSELB = 0;                                       //Configura PORTB como digital
	CLRF        ANSELB+0 
;Splitter.c,79 :: 		ANSELC = 0;                                       //Configura PORTC como digital
	CLRF        ANSELC+0 
;Splitter.c,81 :: 		TRISB5_bit = 0;                                   //Configura el pin B5 como salida
	BCF         TRISB5_bit+0, BitPos(TRISB5_bit+0) 
;Splitter.c,82 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;Splitter.c,84 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;Splitter.c,85 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;Splitter.c,88 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;Splitter.c,89 :: 		PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Splitter.c,90 :: 		PIE3.RC2IE = 1;                                   //Habilita la interrupcion en UART2 receive
	BSF         PIE3+0, 5 
;Splitter.c,91 :: 		PIR3.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR3+0, 5 
;Splitter.c,94 :: 		UART1_Init(9600);                                 //Inicializa el UART1 a 9600 bps
	BSF         BAUDCON+0, 3, 0
	MOVLW       2
	MOVWF       SPBRGH+0 
	MOVLW       8
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;Splitter.c,95 :: 		UART2_Init(9600);                                 //Inicializa el UART2 a 9600 bps
	BSF         BAUDCON2+0, 3, 0
	MOVLW       2
	MOVWF       SPBRGH2+0 
	MOVLW       8
	MOVWF       SPBRG2+0 
	BSF         TXSTA2+0, 2, 0
	CALL        _UART2_Init+0, 0
;Splitter.c,96 :: 		Delay_ms(100);                                    //Espera para que el modulo UART se estabilice
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
;Splitter.c,98 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;Splitter.c,100 :: 		void main() {
;Splitter.c,102 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;Splitter.c,103 :: 		ip=0;
	CLRF        _ip+0 
;Splitter.c,104 :: 		ir=0;
	CLRF        _ir+0 
;Splitter.c,106 :: 		while (1){
L_main23:
;Splitter.c,108 :: 		if (BanLP==1){                                          //Verifica la bandera de lectura de la trama de peticion
	MOVF        _BanLP+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main25
;Splitter.c,109 :: 		if ((Ptcn[0]==Hdr)&&(Ptcn[Psize-1]==End)){           //Verifica que el primer y el ultimo elemento de la trama correspondan a los delimitadores de inicio y fin de trama
	MOVF        _Ptcn+0, 0 
	XORLW       238
	BTFSS       STATUS+0, 2 
	GOTO        L_main28
	MOVF        _Ptcn+3, 0 
	XORLW       255
	BTFSS       STATUS+0, 2 
	GOTO        L_main28
L__main68:
;Splitter.c,110 :: 		if ((Ptcn[1]==TP)&&(Ptcn[2]==Id)){                //Verifica el identificador de tipo de sensor y el identificador de esclavo
	MOVF        _Ptcn+1, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main31
	MOVF        _Ptcn+2, 0 
	XORLW       7
	BTFSS       STATUS+0, 2 
	GOTO        L_main31
L__main67:
;Splitter.c,112 :: 		for (ipp=0;ipp<(Psize);ipp++){
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
;Splitter.c,113 :: 		UART2_Write(Ptcn[ipp]);                   //Reenvia la trama de peticion a travez del UART2
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
;Splitter.c,112 :: 		for (ipp=0;ipp<(Psize);ipp++){
	INCF        _ipp+0, 1 
;Splitter.c,114 :: 		}
	GOTO        L_main32
L_main33:
;Splitter.c,115 :: 		for (ipp=0;ipp<(Psize);ipp++){
	CLRF        _ipp+0 
L_main35:
	MOVLW       128
	XORWF       _ipp+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       4
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main36
;Splitter.c,116 :: 		Ptcn[ipp]=0;;                             //Limpia la trama de peticion
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
;Splitter.c,115 :: 		for (ipp=0;ipp<(Psize);ipp++){
	INCF        _ipp+0, 1 
;Splitter.c,117 :: 		}
	GOTO        L_main35
L_main36:
;Splitter.c,118 :: 		BanLP = 0;                                     //Limpia la bandera de lectura de la trama de peticion
	CLRF        _BanLP+0 
;Splitter.c,120 :: 		}
L_main31:
;Splitter.c,121 :: 		} else {
	GOTO        L_main38
L_main28:
;Splitter.c,123 :: 		for (ipp=0;ipp<(Psize-1);ipp++){
	CLRF        _ipp+0 
L_main39:
	MOVLW       128
	XORWF       _ipp+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       3
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main40
;Splitter.c,124 :: 		Ptcn[ipp]=0;;                            //Limpia la trama de peticion
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
;Splitter.c,123 :: 		for (ipp=0;ipp<(Psize-1);ipp++){
	INCF        _ipp+0, 1 
;Splitter.c,125 :: 		}
	GOTO        L_main39
L_main40:
;Splitter.c,126 :: 		BanLP = 0;                                    //Limpia la bandera de lectura de la trama de peticion
	CLRF        _BanLP+0 
;Splitter.c,128 :: 		}
L_main38:
;Splitter.c,129 :: 		}
L_main25:
;Splitter.c,132 :: 		if (BanLR==1){                                          //Verifica la bandera de lectura de la trama de respuesta
	MOVF        _BanLR+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main42
;Splitter.c,133 :: 		if ((Rspt[0]==Hdr)&&(Rspt[Rsize-1]==End)){           //Verifica que el primer y el ultimo elemento de la trama correspondan a los delimitadores de inicio y fin de trama
	MOVF        _Rspt+0, 0 
	XORLW       238
	BTFSS       STATUS+0, 2 
	GOTO        L_main45
	MOVF        _Rspt+5, 0 
	XORLW       255
	BTFSS       STATUS+0, 2 
	GOTO        L_main45
L__main66:
;Splitter.c,134 :: 		if ((Rspt[1]==TP)&&(Rspt[2]==Id)){                //Verifica el identificador de tipo de sensor y el identificador de esclavo
	MOVF        _Rspt+1, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main48
	MOVF        _Rspt+2, 0 
	XORLW       7
	BTFSS       STATUS+0, 2 
	GOTO        L_main48
L__main65:
;Splitter.c,136 :: 		for (irr=0;irr<(Rsize);irr++){
	CLRF        _irr+0 
L_main49:
	MOVLW       128
	XORWF       _irr+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       6
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main50
;Splitter.c,137 :: 		UART1_Write(Rspt[irr]);                  //Reenvia la trama de respuesta a travez del UART1
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
;Splitter.c,136 :: 		for (irr=0;irr<(Rsize);irr++){
	INCF        _irr+0, 1 
;Splitter.c,138 :: 		}
	GOTO        L_main49
L_main50:
;Splitter.c,139 :: 		for (irr=0;irr<(Rsize);irr++){
	CLRF        _irr+0 
L_main52:
	MOVLW       128
	XORWF       _irr+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       6
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main53
;Splitter.c,140 :: 		Rspt[irr]=0;;                            //Limpia la trama de respuesta
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
;Splitter.c,139 :: 		for (irr=0;irr<(Rsize);irr++){
	INCF        _irr+0, 1 
;Splitter.c,141 :: 		}
	GOTO        L_main52
L_main53:
;Splitter.c,142 :: 		BanLR = 0;                                    //Limpia la bandera de lectura de la trama de respuesta
	CLRF        _BanLR+0 
;Splitter.c,144 :: 		}
L_main48:
;Splitter.c,145 :: 		} else {
	GOTO        L_main55
L_main45:
;Splitter.c,147 :: 		for (irr=0;irr<(Rsize-1);irr++){
	CLRF        _irr+0 
L_main56:
	MOVLW       128
	XORWF       _irr+0, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       5
	SUBWF       R0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main57
;Splitter.c,148 :: 		Rspt[irr]=0;;                            //Limpia la trama de respuesta
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
;Splitter.c,147 :: 		for (irr=0;irr<(Rsize-1);irr++){
	INCF        _irr+0, 1 
;Splitter.c,149 :: 		}
	GOTO        L_main56
L_main57:
;Splitter.c,150 :: 		BanLR = 0;                                    //Limpia la bandera de lectura de la trama de respuesta
	CLRF        _BanLR+0 
;Splitter.c,152 :: 		}
L_main55:
;Splitter.c,153 :: 		}
L_main42:
;Splitter.c,157 :: 		}
	GOTO        L_main23
;Splitter.c,158 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
