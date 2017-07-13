
_interrupt:

;Esclavo.c,33 :: 		void interrupt(void){
;Esclavo.c,35 :: 		if(PIR1.F5==1){
	BTFSS       PIR1+0, 5 
	GOTO        L_interrupt0
;Esclavo.c,37 :: 		if (UART1_Data_Ready()==1){
	CALL        _UART1_Data_Ready+0, 0
	MOVF        R0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt1
;Esclavo.c,38 :: 		Dato = UART1_Read();
	CALL        _UART1_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _Dato+0 
;Esclavo.c,39 :: 		}
L_interrupt1:
;Esclavo.c,40 :: 		if ((Dato==Hdr)&&(ip==0)){                       //Verifica que el primer dato en llegar sea el identificador de inicio de trama
	MOVF        _Dato+0, 0 
	XORLW       58
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt4
	MOVF        _ip+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt4
L__interrupt68:
;Esclavo.c,41 :: 		BanT = 1;                                     //Activa la bandera de trama
	MOVLW       1
	MOVWF       _BanT+0 
;Esclavo.c,42 :: 		Ptcn[ip] = Dato;                              //Almacena el Dato en la trama de peticion
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _ip+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,43 :: 		}
L_interrupt4:
;Esclavo.c,44 :: 		if ((Dato!=Hdr)&&(ip==0)){                       //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
	MOVF        _Dato+0, 0 
	XORLW       58
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt7
	MOVF        _ip+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt7
L__interrupt67:
;Esclavo.c,45 :: 		ip=-1;                                        //Si es asi: reduce el subindice en una unidad
	MOVLW       255
	MOVWF       _ip+0 
;Esclavo.c,46 :: 		}
L_interrupt7:
;Esclavo.c,47 :: 		if ((BanT==1)&&(ip!=0)){
	MOVF        _BanT+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt10
	MOVF        _ip+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_interrupt10
L__interrupt66:
;Esclavo.c,48 :: 		Ptcn[ip] = Dato;                              //Almacena el resto de datos en la trama de peticion si la bandera de trama esta activada
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _ip+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        _Dato+0, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,49 :: 		}
L_interrupt10:
;Esclavo.c,50 :: 		ip++;                                            //Aumenta el subindice una unidad
	INCF        _ip+0, 1 
;Esclavo.c,51 :: 		if (ip==Psize){                                  //Verifica que se haya terminado de llenar la trama de datos
	MOVF        _ip+0, 0 
	XORLW       6
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt11
;Esclavo.c,52 :: 		BanP = 1;                                     //Habilita la bandera de lectura de datos
	MOVLW       1
	MOVWF       _BanP+0 
;Esclavo.c,53 :: 		BanT = 0;
	CLRF        _BanT+0 
;Esclavo.c,54 :: 		ip=0;                                         //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
	CLRF        _ip+0 
;Esclavo.c,55 :: 		}
L_interrupt11:
;Esclavo.c,57 :: 		PIR1.F5 = 0;                                     //Limpia la bandera de interrupcion de UART1
	BCF         PIR1+0, 5 
;Esclavo.c,58 :: 		}
L_interrupt0:
;Esclavo.c,59 :: 		}
L_end_interrupt:
L__interrupt71:
	RETFIE      1
; end of _interrupt

_StartSignal:

;Esclavo.c,63 :: 		void StartSignal(){
;Esclavo.c,64 :: 		TRISB4_bit = 0;                                     //Configure RD0 as output
	BCF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;Esclavo.c,65 :: 		RB4_bit = 0;                                        //RD0 sends 0 to the sensor
	BCF         RB4_bit+0, BitPos(RB4_bit+0) 
;Esclavo.c,66 :: 		delay_ms(18);
	MOVLW       47
	MOVWF       R12, 0
	MOVLW       191
	MOVWF       R13, 0
L_StartSignal12:
	DECFSZ      R13, 1, 1
	BRA         L_StartSignal12
	DECFSZ      R12, 1, 1
	BRA         L_StartSignal12
	NOP
	NOP
;Esclavo.c,67 :: 		RB4_bit = 1;                                        //RD0 sends 1 to the sensor
	BSF         RB4_bit+0, BitPos(RB4_bit+0) 
;Esclavo.c,68 :: 		delay_us(30);
	MOVLW       19
	MOVWF       R13, 0
L_StartSignal13:
	DECFSZ      R13, 1, 1
	BRA         L_StartSignal13
	NOP
	NOP
;Esclavo.c,69 :: 		TRISB4_bit = 1;                                     //Configure RD0 as input
	BSF         TRISB4_bit+0, BitPos(TRISB4_bit+0) 
;Esclavo.c,70 :: 		}
L_end_StartSignal:
	RETURN      0
; end of _StartSignal

_CheckResponse:

;Esclavo.c,72 :: 		void CheckResponse(){
;Esclavo.c,73 :: 		Check = 0;
	CLRF        _Check+0 
;Esclavo.c,74 :: 		delay_us(40);
	MOVLW       26
	MOVWF       R13, 0
L_CheckResponse14:
	DECFSZ      R13, 1, 1
	BRA         L_CheckResponse14
	NOP
;Esclavo.c,75 :: 		if (RB4_bit == 0){
	BTFSC       RB4_bit+0, BitPos(RB4_bit+0) 
	GOTO        L_CheckResponse15
;Esclavo.c,76 :: 		delay_us(80);
	MOVLW       53
	MOVWF       R13, 0
L_CheckResponse16:
	DECFSZ      R13, 1, 1
	BRA         L_CheckResponse16
;Esclavo.c,77 :: 		if (RB4_bit == 1){
	BTFSS       RB4_bit+0, BitPos(RB4_bit+0) 
	GOTO        L_CheckResponse17
;Esclavo.c,78 :: 		Check = 1;
	MOVLW       1
	MOVWF       _Check+0 
;Esclavo.c,79 :: 		delay_us(40);
	MOVLW       26
	MOVWF       R13, 0
L_CheckResponse18:
	DECFSZ      R13, 1, 1
	BRA         L_CheckResponse18
	NOP
;Esclavo.c,80 :: 		}
L_CheckResponse17:
;Esclavo.c,81 :: 		}
L_CheckResponse15:
;Esclavo.c,82 :: 		}
L_end_CheckResponse:
	RETURN      0
; end of _CheckResponse

_ReadData:

;Esclavo.c,84 :: 		char ReadData(){
;Esclavo.c,86 :: 		for(j = 0; j < 8; j++){
	CLRF        R3 
L_ReadData19:
	MOVLW       8
	SUBWF       R3, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_ReadData20
;Esclavo.c,87 :: 		while(!RB4_bit);                              //Espera hasta RB4 pase a alto
L_ReadData22:
	BTFSC       RB4_bit+0, BitPos(RB4_bit+0) 
	GOTO        L_ReadData23
	GOTO        L_ReadData22
L_ReadData23:
;Esclavo.c,88 :: 		delay_us(30);
	MOVLW       19
	MOVWF       R13, 0
L_ReadData24:
	DECFSZ      R13, 1, 1
	BRA         L_ReadData24
	NOP
	NOP
;Esclavo.c,89 :: 		if(RB4_bit == 0){
	BTFSC       RB4_bit+0, BitPos(RB4_bit+0) 
	GOTO        L_ReadData25
;Esclavo.c,90 :: 		i&= ~(1<<(7 - j));                       //Clear bit (7-b)
	MOVF        R3, 0 
	SUBLW       7
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       R1 
	MOVLW       1
	MOVWF       R0 
	MOVF        R1, 0 
L__ReadData75:
	BZ          L__ReadData76
	RLCF        R0, 1 
	BCF         R0, 0 
	ADDLW       255
	GOTO        L__ReadData75
L__ReadData76:
	COMF        R0, 1 
	MOVF        R0, 0 
	ANDWF       R2, 1 
;Esclavo.c,91 :: 		}else {
	GOTO        L_ReadData26
L_ReadData25:
;Esclavo.c,92 :: 		i|= (1 << (7 - j));                      //Set bit (7-b)
	MOVF        R3, 0 
	SUBLW       7
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       R1 
	MOVLW       1
	MOVWF       R0 
	MOVF        R1, 0 
L__ReadData77:
	BZ          L__ReadData78
	RLCF        R0, 1 
	BCF         R0, 0 
	ADDLW       255
	GOTO        L__ReadData77
L__ReadData78:
	MOVF        R0, 0 
	IORWF       R2, 1 
;Esclavo.c,93 :: 		while(RB4_bit);                          //Espera hasta RB4 pase a bajo
L_ReadData27:
	BTFSS       RB4_bit+0, BitPos(RB4_bit+0) 
	GOTO        L_ReadData28
	GOTO        L_ReadData27
L_ReadData28:
;Esclavo.c,94 :: 		}
L_ReadData26:
;Esclavo.c,86 :: 		for(j = 0; j < 8; j++){
	INCF        R3, 1 
;Esclavo.c,95 :: 		}
	GOTO        L_ReadData19
L_ReadData20:
;Esclavo.c,96 :: 		return i;
	MOVF        R2, 0 
	MOVWF       R0 
;Esclavo.c,97 :: 		}
L_end_ReadData:
	RETURN      0
; end of _ReadData

_Calcular:

;Esclavo.c,99 :: 		void Calcular(){
;Esclavo.c,101 :: 		StartSignal();
	CALL        _StartSignal+0, 0
;Esclavo.c,102 :: 		CheckResponse();
	CALL        _CheckResponse+0, 0
;Esclavo.c,103 :: 		if(Check == 1){
	MOVF        _Check+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_Calcular29
;Esclavo.c,104 :: 		RH_byte1 = ReadData();
	CALL        _ReadData+0, 0
	MOVF        R0, 0 
	MOVWF       _RH_byte1+0 
;Esclavo.c,105 :: 		RH_byte2 = ReadData();
	CALL        _ReadData+0, 0
	MOVF        R0, 0 
	MOVWF       _RH_byte2+0 
;Esclavo.c,106 :: 		T_byte1 = ReadData();
	CALL        _ReadData+0, 0
	MOVF        R0, 0 
	MOVWF       _T_byte1+0 
;Esclavo.c,107 :: 		T_byte2 = ReadData();
	CALL        _ReadData+0, 0
	MOVF        R0, 0 
	MOVWF       _T_byte2+0 
;Esclavo.c,108 :: 		Sum = ReadData();
	CALL        _ReadData+0, 0
	MOVF        R0, 0 
	MOVWF       _Sum+0 
	MOVLW       0
	MOVWF       _Sum+1 
;Esclavo.c,109 :: 		if(Sum == ((RH_byte1+RH_byte2+T_byte1+T_byte2) & 0XFF)){
	MOVF        _RH_byte2+0, 0 
	ADDWF       _RH_byte1+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVF        _T_byte1+0, 0 
	ADDWF       R0, 1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVF        _T_byte2+0, 0 
	ADDWF       R0, 1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       255
	ANDWF       R0, 0 
	MOVWF       R2 
	MOVF        R1, 0 
	MOVWF       R3 
	MOVLW       0
	ANDWF       R3, 1 
	MOVF        _Sum+1, 0 
	XORWF       R3, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Calcular80
	MOVF        R2, 0 
	XORWF       _Sum+0, 0 
L__Calcular80:
	BTFSS       STATUS+0, 2 
	GOTO        L_Calcular30
;Esclavo.c,110 :: 		ITemp = T_byte1;
	MOVF        _T_byte1+0, 0 
	MOVWF       _ITemp+0 
	MOVLW       0
	MOVWF       _ITemp+1 
;Esclavo.c,111 :: 		ITemp = (ITemp << 8) | T_byte2;
	MOVF        _ITemp+0, 0 
	MOVWF       R1 
	CLRF        R0 
	MOVF        _T_byte2+0, 0 
	IORWF       R0, 0 
	MOVWF       R3 
	MOVF        R1, 0 
	MOVWF       R4 
	MOVLW       0
	IORWF       R4, 1 
	MOVF        R3, 0 
	MOVWF       _ITemp+0 
	MOVF        R4, 0 
	MOVWF       _ITemp+1 
;Esclavo.c,112 :: 		IHmd = RH_byte1;
	MOVF        _RH_byte1+0, 0 
	MOVWF       _IHmd+0 
	MOVLW       0
	MOVWF       _IHmd+1 
;Esclavo.c,113 :: 		IHmd = (IHmd << 8) | RH_byte2;
	MOVF        _IHmd+0, 0 
	MOVWF       R1 
	CLRF        R0 
	MOVF        _RH_byte2+0, 0 
	IORWF       R0, 0 
	MOVWF       FLOC__Calcular+2 
	MOVF        R1, 0 
	MOVWF       FLOC__Calcular+3 
	MOVLW       0
	IORWF       FLOC__Calcular+3, 1 
	MOVF        FLOC__Calcular+2, 0 
	MOVWF       _IHmd+0 
	MOVF        FLOC__Calcular+3, 0 
	MOVWF       _IHmd+1 
;Esclavo.c,114 :: 		ITemp = ITemp/10;
	MOVF        R3, 0 
	MOVWF       R0 
	MOVF        R4, 0 
	MOVWF       R1 
	MOVLW       10
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	CALL        _Div_16X16_U+0, 0
	MOVF        R0, 0 
	MOVWF       FLOC__Calcular+0 
	MOVF        R1, 0 
	MOVWF       FLOC__Calcular+1 
	MOVF        FLOC__Calcular+0, 0 
	MOVWF       _ITemp+0 
	MOVF        FLOC__Calcular+1, 0 
	MOVWF       _ITemp+1 
;Esclavo.c,115 :: 		IHmd = IHmd/10;
	MOVLW       10
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVF        FLOC__Calcular+2, 0 
	MOVWF       R0 
	MOVF        FLOC__Calcular+3, 0 
	MOVWF       R1 
	CALL        _Div_16X16_U+0, 0
	MOVF        R0, 0 
	MOVWF       _IHmd+0 
	MOVF        R1, 0 
	MOVWF       _IHmd+1 
;Esclavo.c,117 :: 		if (ITemp > 0X8000){                //Temperatura negativa
	MOVF        FLOC__Calcular+1, 0 
	SUBLW       128
	BTFSS       STATUS+0, 2 
	GOTO        L__Calcular81
	MOVF        FLOC__Calcular+0, 0 
	SUBLW       0
L__Calcular81:
	BTFSC       STATUS+0, 0 
	GOTO        L_Calcular31
;Esclavo.c,118 :: 		ITemp = 0;
	CLRF        _ITemp+0 
	CLRF        _ITemp+1 
;Esclavo.c,119 :: 		IHmd = 0;
	CLRF        _IHmd+0 
	CLRF        _IHmd+1 
;Esclavo.c,120 :: 		}
L_Calcular31:
;Esclavo.c,122 :: 		} else {
	GOTO        L_Calcular32
L_Calcular30:
;Esclavo.c,123 :: 		ITemp = 100;
	MOVLW       100
	MOVWF       _ITemp+0 
	MOVLW       0
	MOVWF       _ITemp+1 
;Esclavo.c,124 :: 		IHmd = 100;
	MOVLW       100
	MOVWF       _IHmd+0 
	MOVLW       0
	MOVWF       _IHmd+1 
;Esclavo.c,125 :: 		}
L_Calcular32:
;Esclavo.c,126 :: 		} else {
	GOTO        L_Calcular33
L_Calcular29:
;Esclavo.c,127 :: 		ITemp = 200;
	MOVLW       200
	MOVWF       _ITemp+0 
	MOVLW       0
	MOVWF       _ITemp+1 
;Esclavo.c,128 :: 		IHmd = 200;
	MOVLW       200
	MOVWF       _IHmd+0 
	MOVLW       0
	MOVWF       _IHmd+1 
;Esclavo.c,129 :: 		}
L_Calcular33:
;Esclavo.c,131 :: 		chTemp = (unsigned char *) & ITemp;                 //Asocia el valor calculado de Temperatura al puntero chTemp
	MOVLW       _ITemp+0
	MOVWF       _chTemp+0 
	MOVLW       hi_addr(_ITemp+0)
	MOVWF       _chTemp+1 
;Esclavo.c,132 :: 		chHmd = (unsigned char *) & IHmd;                   //Asocia el valor calculado de Temperatura al puntero chTemp
	MOVLW       _IHmd+0
	MOVWF       _chHmd+0 
	MOVLW       hi_addr(_IHmd+0)
	MOVWF       _chHmd+1 
;Esclavo.c,134 :: 		}
L_end_Calcular:
	RETURN      0
; end of _Calcular

_Responder:

;Esclavo.c,136 :: 		void Responder(unsigned int Reg){
;Esclavo.c,138 :: 		if (Reg==0x01){
	MOVLW       0
	XORWF       FARG_Responder_Reg+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Responder83
	MOVLW       1
	XORWF       FARG_Responder_Reg+0, 0 
L__Responder83:
	BTFSS       STATUS+0, 2 
	GOTO        L_Responder34
;Esclavo.c,139 :: 		for (ir=4;ir>=3;ir--){
	MOVLW       4
	MOVWF       _ir+0 
L_Responder35:
	MOVLW       3
	SUBWF       _ir+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_Responder36
;Esclavo.c,140 :: 		Rspt[ir]=(*chTemp++);                        //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Temperatura calculada
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _ir+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVFF       _chTemp+0, FSR0
	MOVFF       _chTemp+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
	INFSNZ      _chTemp+0, 1 
	INCF        _chTemp+1, 1 
;Esclavo.c,139 :: 		for (ir=4;ir>=3;ir--){
	DECF        _ir+0, 1 
;Esclavo.c,141 :: 		}
	GOTO        L_Responder35
L_Responder36:
;Esclavo.c,142 :: 		}
L_Responder34:
;Esclavo.c,144 :: 		if (Reg==0x02){
	MOVLW       0
	XORWF       FARG_Responder_Reg+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Responder84
	MOVLW       2
	XORWF       FARG_Responder_Reg+0, 0 
L__Responder84:
	BTFSS       STATUS+0, 2 
	GOTO        L_Responder38
;Esclavo.c,145 :: 		for (ir=4;ir>=3;ir--){
	MOVLW       4
	MOVWF       _ir+0 
L_Responder39:
	MOVLW       3
	SUBWF       _ir+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_Responder40
;Esclavo.c,146 :: 		Rspt[ir]=(*chHmd++);                         //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Humedad calculada
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _ir+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVFF       _chHmd+0, FSR0
	MOVFF       _chHmd+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
	INFSNZ      _chHmd+0, 1 
	INCF        _chHmd+1, 1 
;Esclavo.c,145 :: 		for (ir=4;ir>=3;ir--){
	DECF        _ir+0, 1 
;Esclavo.c,147 :: 		}
	GOTO        L_Responder39
L_Responder40:
;Esclavo.c,148 :: 		}
L_Responder38:
;Esclavo.c,150 :: 		Rspt[2]=Ptcn[2];                                    //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOVF        _Ptcn+2, 0 
	MOVWF       _Rspt+2 
;Esclavo.c,152 :: 		RC5_bit = 1;                                        //Establece el Max485 en modo de escritura
	BSF         RC5_bit+0, BitPos(RC5_bit+0) 
;Esclavo.c,154 :: 		for (ir=0;ir<Rsize;ir++){
	CLRF        _ir+0 
L_Responder42:
	MOVLW       6
	SUBWF       _ir+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_Responder43
;Esclavo.c,155 :: 		UART1_Write(Rspt[ir]);                          //Envia la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR0H 
	MOVF        _ir+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;Esclavo.c,154 :: 		for (ir=0;ir<Rsize;ir++){
	INCF        _ir+0, 1 
;Esclavo.c,156 :: 		}
	GOTO        L_Responder42
L_Responder43:
;Esclavo.c,157 :: 		while(UART1_Tx_Idle()==0);                          //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_Responder45:
	CALL        _UART1_Tx_Idle+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_Responder46
	GOTO        L_Responder45
L_Responder46:
;Esclavo.c,159 :: 		RC5_bit = 0;                                        //Establece el Max485 en modo de lectura
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Esclavo.c,161 :: 		for (ir=3;ir<5;ir++){
	MOVLW       3
	MOVWF       _ir+0 
L_Responder47:
	MOVLW       5
	SUBWF       _ir+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_Responder48
;Esclavo.c,162 :: 		Rspt[ir]=0;;                                    //Limpia la trama de respuesta
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _ir+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	CLRF        POSTINC1+0 
;Esclavo.c,161 :: 		for (ir=3;ir<5;ir++){
	INCF        _ir+0, 1 
;Esclavo.c,163 :: 		}
	GOTO        L_Responder47
L_Responder48:
;Esclavo.c,165 :: 		}
L_end_Responder:
	RETURN      0
; end of _Responder

_Configuracion:

;Esclavo.c,168 :: 		void Configuracion(){
;Esclavo.c,170 :: 		ANSELA = 0;                                       //Configura PORTA como digital
	CLRF        ANSELA+0 
;Esclavo.c,171 :: 		ANSELB = 0;                                       //Configura PORTB como digital
	CLRF        ANSELB+0 
;Esclavo.c,172 :: 		ANSELC = 0;                                       //Configura PORTC como digital
	CLRF        ANSELC+0 
;Esclavo.c,174 :: 		TRISA = 1;                                        //Configura el puerto A como entrada
	MOVLW       1
	MOVWF       TRISA+0 
;Esclavo.c,175 :: 		TRISC4_bit = 0;                                   //Configura el pin C4 como salida
	BCF         TRISC4_bit+0, BitPos(TRISC4_bit+0) 
;Esclavo.c,176 :: 		TRISC5_bit = 0;                                   //Configura el pin C5 como salida
	BCF         TRISC5_bit+0, BitPos(TRISC5_bit+0) 
;Esclavo.c,177 :: 		TRISC0_bit = 1;                                   //Configura el pin C0 como entrada
	BSF         TRISC0_bit+0, BitPos(TRISC0_bit+0) 
;Esclavo.c,178 :: 		TRISC1_bit = 1;                                   //Configura el pin C1 como entrada
	BSF         TRISC1_bit+0, BitPos(TRISC1_bit+0) 
;Esclavo.c,181 :: 		INTCON.GIE = 1;                                   //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;Esclavo.c,182 :: 		INTCON.PEIE = 1;                                  //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;Esclavo.c,184 :: 		PIE1.RC1IE = 1;                                   //Habilita la interrupcion en UART1 receive
	BSF         PIE1+0, 5 
;Esclavo.c,185 :: 		PIR1.F5 = 0;                                      //Limpia la bandera de interrupcion
	BCF         PIR1+0, 5 
;Esclavo.c,187 :: 		UART1_Init(9600);                                 //Inicializa el UART1 a 9600 bps
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       207
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;Esclavo.c,188 :: 		Delay_ms(100);                                    //Espera para que el modulo UART se estabilice
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       4
	MOVWF       R12, 0
	MOVLW       186
	MOVWF       R13, 0
L_Configuracion50:
	DECFSZ      R13, 1, 1
	BRA         L_Configuracion50
	DECFSZ      R12, 1, 1
	BRA         L_Configuracion50
	DECFSZ      R11, 1, 1
	BRA         L_Configuracion50
	NOP
;Esclavo.c,190 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;Esclavo.c,193 :: 		void main() {
;Esclavo.c,195 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;Esclavo.c,196 :: 		RC5_bit = 0;                                             //Inicia el Max 485 en modo lectura
	BCF         RC5_bit+0, BitPos(RC5_bit+0) 
;Esclavo.c,199 :: 		Id=0x02;
	MOVLW       2
	MOVWF       _Id+0 
	MOVLW       0
	MOVWF       _Id+1 
;Esclavo.c,201 :: 		chDP = &DatoPtcn;                                        //Asocia el valor de DatoPtcn al puntero chDP
	MOVLW       _DatoPtcn+0
	MOVWF       _chDP+0 
	MOVLW       hi_addr(_DatoPtcn+0)
	MOVWF       _chDP+1 
;Esclavo.c,202 :: 		ip=0;
	CLRF        _ip+0 
;Esclavo.c,204 :: 		Rspt[0] = Hdr;                                           //Se rellena el primer byte de la trama de respuesta con el delimitador de inicio de trama
	MOVLW       58
	MOVWF       _Rspt+0 
;Esclavo.c,205 :: 		Rspt[1] = Id;                                            //Se rellena el segundo byte de la trama de repuesta con el Id del tipo de sensor
	MOVLW       2
	MOVWF       _Rspt+1 
;Esclavo.c,206 :: 		Rspt[Rsize-1] = End;                                     //Se rellena el ultimo byte de la trama de repuesta con el delimitador de final de trama
	MOVLW       13
	MOVWF       _Rspt+5 
;Esclavo.c,208 :: 		while (1){
L_main51:
;Esclavo.c,214 :: 		if (BanP==1){                                      //Verifica si se realizo una peticion
	MOVF        _BanP+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main53
;Esclavo.c,215 :: 		RC4_bit = 1;
	BSF         RC4_bit+0, BitPos(RC4_bit+0) 
;Esclavo.c,216 :: 		if ((Ptcn[1]==Id)&&(Ptcn[Psize-1]==End)){    //Verifica el identificador de esclavo y el byte de final de trama
	MOVLW       0
	XORWF       _Id+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main87
	MOVF        _Id+0, 0 
	XORWF       _Ptcn+1, 0 
L__main87:
	BTFSS       STATUS+0, 2 
	GOTO        L_main56
	MOVF        _Ptcn+5, 0 
	XORLW       13
	BTFSS       STATUS+0, 2 
	GOTO        L_main56
L__main69:
;Esclavo.c,218 :: 		Fcn = Ptcn[2];
	MOVF        _Ptcn+2, 0 
	MOVWF       _Fcn+0 
;Esclavo.c,220 :: 		if (Fcn==0x02){                           //02: Lee un registro especicfico (01:Temperatura, 02:Humedad)
	MOVF        _Ptcn+2, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_main57
;Esclavo.c,221 :: 		Calcular();                            //Realiza una secuencia de calculo
	CALL        _Calcular+0, 0
;Esclavo.c,222 :: 		*chDP = Ptcn[4];                       //Almacena el byte 4 de la trama de peticion en el LSB de la variable DatoPtcn
	MOVFF       _chDP+0, FSR1
	MOVFF       _chDP+1, FSR1H
	MOVF        _Ptcn+4, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,223 :: 		*(chDP+1) = Ptcn[3];                   //Almacena el byte 3 de la trama de peticion en el MSB de la variable DatoPtcn
	MOVLW       1
	ADDWF       _chDP+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _chDP+1, 0 
	MOVWF       FSR1H 
	MOVF        _Ptcn+3, 0 
	MOVWF       POSTINC1+0 
;Esclavo.c,224 :: 		Responder(DatoPtcn);                   //Envia la trama de repuesta con el valor del registro requerido
	MOVF        _DatoPtcn+0, 0 
	MOVWF       FARG_Responder_Reg+0 
	MOVF        _DatoPtcn+1, 0 
	MOVWF       FARG_Responder_Reg+1 
	CALL        _Responder+0, 0
;Esclavo.c,225 :: 		}
L_main57:
;Esclavo.c,227 :: 		DatoPtcn = 0;                             //Limpia la variable
	CLRF        _DatoPtcn+0 
	CLRF        _DatoPtcn+1 
;Esclavo.c,228 :: 		for (ipp=0;ipp<Psize;ipp++){
	CLRF        _ipp+0 
L_main58:
	MOVLW       6
	SUBWF       _ipp+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main59
;Esclavo.c,229 :: 		Ptcn[ipp]=0;                          //Limpia la trama de peticion
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _ipp+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	CLRF        POSTINC1+0 
;Esclavo.c,228 :: 		for (ipp=0;ipp<Psize;ipp++){
	INCF        _ipp+0, 1 
;Esclavo.c,230 :: 		}
	GOTO        L_main58
L_main59:
;Esclavo.c,231 :: 		BanP = 0;                                 //Limpia la bandera de lectura de datos
	CLRF        _BanP+0 
;Esclavo.c,233 :: 		} else{
	GOTO        L_main61
L_main56:
;Esclavo.c,234 :: 		for (ipp=0;ipp<Psize;ipp++){
	CLRF        _ipp+0 
L_main62:
	MOVLW       6
	SUBWF       _ipp+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main63
;Esclavo.c,235 :: 		Ptcn[ipp]=0;                       //Limpia la trama de peticion
	MOVLW       _Ptcn+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Ptcn+0)
	MOVWF       FSR1H 
	MOVF        _ipp+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	CLRF        POSTINC1+0 
;Esclavo.c,234 :: 		for (ipp=0;ipp<Psize;ipp++){
	INCF        _ipp+0, 1 
;Esclavo.c,236 :: 		}
	GOTO        L_main62
L_main63:
;Esclavo.c,237 :: 		BanP = 0;                              //Limpia la bandera de lectura de datos
	CLRF        _BanP+0 
;Esclavo.c,238 :: 		}
L_main61:
;Esclavo.c,239 :: 		RC4_bit = 0;
	BCF         RC4_bit+0, BitPos(RC4_bit+0) 
;Esclavo.c,240 :: 		}
L_main53:
;Esclavo.c,241 :: 		Delay_ms(50);                                      //Retraso necesario para que la Rpi tenga tiempo de recibir la trama de respuesta
	MOVLW       130
	MOVWF       R12, 0
	MOVLW       221
	MOVWF       R13, 0
L_main65:
	DECFSZ      R13, 1, 1
	BRA         L_main65
	DECFSZ      R12, 1, 1
	BRA         L_main65
	NOP
	NOP
;Esclavo.c,243 :: 		}
	GOTO        L_main51
;Esclavo.c,245 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
