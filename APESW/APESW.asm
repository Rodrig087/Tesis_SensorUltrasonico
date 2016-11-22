
_Interrupt:

;APESW.c,72 :: 		void Interrupt(){
;APESW.c,75 :: 		if (TMR2IF_bit){                             //Verifica si ocurrio una interrupcion por desbordamiento del TMR2.
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_Interrupt0
;APESW.c,77 :: 		if (contp<=64){                           //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (42)
	MOVLW       0
	MOVWF       R0 
	MOVF        _contp+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt35
	MOVF        _contp+0, 0 
	SUBLW       64
L__Interrupt35:
	BTFSS       STATUS+0, 0 
	GOTO        L_Interrupt1
;APESW.c,78 :: 		BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
	COMF        _BS+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _BS+0 
;APESW.c,79 :: 		RD0_bit = BS;
	BTFSC       R0, 0 
	GOTO        L__Interrupt36
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
	GOTO        L__Interrupt37
L__Interrupt36:
	BSF         RD0_bit+0, BitPos(RD0_bit+0) 
L__Interrupt37:
;APESW.c,80 :: 		if (contp==20){                        //Cambia el valor de la variable auxiliar para producir  (20)
	MOVLW       0
	XORWF       _contp+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt38
	MOVLW       20
	XORWF       _contp+0, 0 
L__Interrupt38:
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt2
;APESW.c,81 :: 		BS = 0;                             //el primer cambio de fase en la siguiente iteracion.
	CLRF        _BS+0 
;APESW.c,82 :: 		}
L_Interrupt2:
;APESW.c,83 :: 		if (contp==43){                        //Cambia el valor de la variable auxiliar para producir  (20)
	MOVLW       0
	XORWF       _contp+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt39
	MOVLW       43
	XORWF       _contp+0, 0 
L__Interrupt39:
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt3
;APESW.c,84 :: 		BS = 0;                             //el segundo cambio de fase en la siguiente iteracion.
	CLRF        _BS+0 
;APESW.c,85 :: 		}
L_Interrupt3:
;APESW.c,87 :: 		} else {
	GOTO        L_Interrupt4
L_Interrupt1:
;APESW.c,88 :: 		TMR2ON_bit=0;                          //Apaga el TMR2
	BCF         TMR2ON_bit+0, BitPos(TMR2ON_bit+0) 
;APESW.c,89 :: 		RD0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;APESW.c,90 :: 		TMR1ON_bit=1;                          //Enciende el TMR1.
	BSF         TMR1ON_bit+0, BitPos(TMR1ON_bit+0) 
;APESW.c,91 :: 		TMR1L=0X00;                            //Limpia los bits menos significativos del TMR1.
	CLRF        TMR1L+0 
;APESW.c,92 :: 		TMR1H=0X00;                            //Limpia los bits mas significativos del TMR1.
	CLRF        TMR1H+0 
;APESW.c,93 :: 		}
L_Interrupt4:
;APESW.c,95 :: 		contp++;                                  //Aumenta el contador en una unidad.
	INFSNZ      _contp+0, 1 
	INCF        _contp+1, 1 
;APESW.c,96 :: 		TMR2IF_bit = 0;                           //Limpia la bandera de interrupcion de Timer2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;APESW.c,98 :: 		}
L_Interrupt0:
;APESW.c,101 :: 		if (INTCON.INT0IF == 1){                     //Verifica si ocurrio una interrupcion externa en INT0.
	BTFSS       INTCON+0, 1 
	GOTO        L_Interrupt5
;APESW.c,104 :: 		*(punT1) = TMR1L;                         //Carga el valor actual de TMR1L en los 8 bits menos significativos de la variable contT de tipo entero.
	MOVFF       _punT1+0, FSR1
	MOVFF       _punT1+1, FSR1H
	MOVF        TMR1L+0, 0 
	MOVWF       POSTINC1+0 
;APESW.c,105 :: 		*(punT1+1) = TMR1H;                       //Carga el valor actual de TMR1H en los 8 bits mas significativos de la variable  contT de tipo entero.
	MOVLW       1
	ADDWF       _punT1+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _punT1+1, 0 
	MOVWF       FSR1H 
	MOVF        TMR1H+0, 0 
	MOVWF       POSTINC1+0 
;APESW.c,107 :: 		T2 = contT;                               //Carga el contenido actual de la variable contT en la variable T2.
	MOVF        _contT+0, 0 
	MOVWF       _T2+0 
	MOVF        _contT+1, 0 
	MOVWF       _T2+1 
;APESW.c,108 :: 		DT = (T2-T1);                             //Halla la diferencia entre los valores actual y anterior de la variable contT (en nanosegundos).
	MOVF        _T1+0, 0 
	SUBWF       _contT+0, 0 
	MOVWF       _DT+0 
	MOVF        _T1+1, 0 
	SUBWFB      _contT+1, 0 
	MOVWF       _DT+1 
;APESW.c,110 :: 		if (F1<=3){
	MOVF        _F1+0, 0 
	SUBLW       3
	BTFSS       STATUS+0, 0 
	GOTO        L_Interrupt6
;APESW.c,111 :: 		if (DT>(300-Tht)&&DT<(300+Tht)){      //Realiza una comparacion para verificar cuando se estabilice la primera fase de la senal
	MOVF        _ThT+0, 0 
	SUBLW       44
	MOVWF       R1 
	MOVLW       0
	MOVWF       R2 
	MOVLW       1
	SUBFWB      R2, 1 
	MOVF        _DT+1, 0 
	SUBWF       R2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt40
	MOVF        _DT+0, 0 
	SUBWF       R1, 0 
L__Interrupt40:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt9
	MOVLW       44
	MOVWF       R1 
	MOVLW       1
	MOVWF       R2 
	MOVF        _ThT+0, 0 
	ADDWF       R1, 1 
	BTFSC       STATUS+0, 0 
	INCF        R2, 1 
	MOVF        R2, 0 
	SUBWF       _DT+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt41
	MOVF        R1, 0 
	SUBWF       _DT+0, 0 
L__Interrupt41:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt9
L__Interrupt32:
;APESW.c,112 :: 		F1++;
	INCF        _F1+0, 1 
;APESW.c,113 :: 		if (F1==3) {                       //Si 3 intervalos consecutivos cumplen con la condicion de estabilizacion, se empieza con el proceso de busqueda de cambio de fase
	MOVF        _F1+0, 0 
	XORLW       3
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt10
;APESW.c,114 :: 		DF1 = T2;                       //Almacena el valor actual de la variable T2 para la referencia de inicio de deteccion de fase
	MOVF        _T2+0, 0 
	MOVWF       _DF1+0 
;APESW.c,115 :: 		BF1 = 1;                        //Activa la bandera de deteccion de la fase 1
	MOVLW       1
	MOVWF       _BF1+0 
;APESW.c,116 :: 		}
L_Interrupt10:
;APESW.c,117 :: 		} else {
	GOTO        L_Interrupt11
L_Interrupt9:
;APESW.c,118 :: 		F1=0;                              //Resetea el contador si no encuentra 3 intervalos iguales
	CLRF        _F1+0 
;APESW.c,119 :: 		}
L_Interrupt11:
;APESW.c,120 :: 		}
L_Interrupt6:
;APESW.c,122 :: 		if (BF1==1){                                     //Inicia  la deteccion del primer cambio de fase
	MOVF        _BF1+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt12
;APESW.c,123 :: 		F2++;
	INCF        _F2+0, 1 
;APESW.c,124 :: 		DF2 = (T2-DF1);
	MOVF        _DF1+0, 0 
	SUBWF       _T2+0, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	MOVWF       _DF2+0 
;APESW.c,125 :: 		DFT1 = ((F2*2)-1)*150;
	MOVF        _F2+0, 0 
	MOVWF       R0 
	RLCF        R0, 1 
	BCF         R0, 0 
	DECF        R0, 1 
	MOVLW       150
	MULWF       R0 
	MOVF        PRODL+0, 0 
	MOVWF       R3 
	MOVF        R3, 0 
	MOVWF       _DFT1+0 
;APESW.c,126 :: 		if ((DFT1>(DF2-Tht))&&(DFT1<(DF2+Tht))){
	MOVF        _ThT+0, 0 
	SUBWF       R2, 0 
	MOVWF       R1 
	CLRF        R2 
	MOVLW       0
	SUBWFB      R2, 1 
	MOVLW       128
	XORWF       R2, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt42
	MOVF        R3, 0 
	SUBWF       R1, 0 
L__Interrupt42:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt15
	MOVF        _ThT+0, 0 
	ADDWF       _DF2+0, 0 
	MOVWF       R1 
	CLRF        R2 
	MOVLW       0
	ADDWFC      R2, 1 
	MOVLW       128
	MOVWF       R0 
	MOVLW       128
	XORWF       R2, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt43
	MOVF        R1, 0 
	SUBWF       _DFT1+0, 0 
L__Interrupt43:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt15
L__Interrupt31:
;APESW.c,127 :: 		RE1_bit = 1;
	BSF         RE1_bit+0, BitPos(RE1_bit+0) 
;APESW.c,128 :: 		DF2 = T2;
	MOVF        _T2+0, 0 
	MOVWF       _DF2+0 
;APESW.c,129 :: 		BF2 = 1;
	MOVLW       1
	MOVWF       _BF2+0 
	MOVLW       0
	MOVWF       _BF2+1 
;APESW.c,130 :: 		BF1 = 0;
	CLRF        _BF1+0 
;APESW.c,131 :: 		}
L_Interrupt15:
;APESW.c,132 :: 		}
L_Interrupt12:
;APESW.c,134 :: 		if (BF2==1){
	MOVLW       0
	XORWF       _BF2+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt44
	MOVLW       1
	XORWF       _BF2+0, 0 
L__Interrupt44:
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt16
;APESW.c,135 :: 		F3++;
	INCF        _F3+0, 1 
;APESW.c,136 :: 		DF3 = (T2-DF2);
	MOVF        _DF2+0, 0 
	SUBWF       _T2+0, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	MOVWF       _DF3+0 
;APESW.c,137 :: 		DFT2 = ((F3*2)-1)*150;                       //!!!!!
	MOVF        _F3+0, 0 
	MOVWF       R0 
	RLCF        R0, 1 
	BCF         R0, 0 
	DECF        R0, 1 
	MOVLW       150
	MULWF       R0 
	MOVF        PRODL+0, 0 
	MOVWF       R3 
	MOVF        R3, 0 
	MOVWF       _DFT2+0 
;APESW.c,138 :: 		if ((DFT2>(DF3-Tht))&&(DFT2<(DF3+Tht))){
	MOVF        _ThT+0, 0 
	SUBWF       R2, 0 
	MOVWF       R1 
	CLRF        R2 
	MOVLW       0
	SUBWFB      R2, 1 
	MOVLW       128
	XORWF       R2, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt45
	MOVF        R3, 0 
	SUBWF       R1, 0 
L__Interrupt45:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt19
	MOVF        _ThT+0, 0 
	ADDWF       _DF3+0, 0 
	MOVWF       R1 
	CLRF        R2 
	MOVLW       0
	ADDWFC      R2, 1 
	MOVLW       128
	MOVWF       R0 
	MOVLW       128
	XORWF       R2, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt46
	MOVF        R1, 0 
	SUBWF       _DFT2+0, 0 
L__Interrupt46:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt19
L__Interrupt30:
;APESW.c,139 :: 		RE1_bit = 0;
	BCF         RE1_bit+0, BitPos(RE1_bit+0) 
;APESW.c,140 :: 		DF3 = T2;
	MOVF        _T2+0, 0 
	MOVWF       _DF3+0 
;APESW.c,141 :: 		BF2 = 0;
	CLRF        _BF2+0 
	CLRF        _BF2+1 
;APESW.c,142 :: 		TMR1ON_bit = 0;                          //Apaga el TMR1.
	BCF         TMR1ON_bit+0, BitPos(TMR1ON_bit+0) 
;APESW.c,143 :: 		contT = 0;                               //Limpia el contenido de la variable contT.
	CLRF        _contT+0 
	CLRF        _contT+1 
;APESW.c,144 :: 		}
L_Interrupt19:
;APESW.c,145 :: 		}
L_Interrupt16:
;APESW.c,147 :: 		T1 = contT;                                     //Actualiza T1 con el valor actual del contador contT.
	MOVF        _contT+0, 0 
	MOVWF       _T1+0 
	MOVF        _contT+1, 0 
	MOVWF       _T1+1 
;APESW.c,148 :: 		INTCON.INT0IF = 0;                              //Limpia la bandera de interrupcion de INT0.
	BCF         INTCON+0, 1 
;APESW.c,150 :: 		}
L_Interrupt5:
;APESW.c,152 :: 		if (TMR1IF_bit){
	BTFSS       TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
	GOTO        L_Interrupt20
;APESW.c,153 :: 		TMR1IF_bit=0;                             //Limpia la bandera de interrupcion de Timer1.
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;APESW.c,154 :: 		}
L_Interrupt20:
;APESW.c,156 :: 		}
L_end_Interrupt:
L__Interrupt34:
	RETFIE      1
; end of _Interrupt

_Velocidad:

;APESW.c,160 :: 		void Velocidad(){
;APESW.c,165 :: 		Ow_Reset(&PORTE, 2);                                 // Onewire reset signal
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Reset_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Reset_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Reset_pin+0 
	CALL        _Ow_Reset+0, 0
;APESW.c,166 :: 		Ow_Write(&PORTE, 2, 0xCC);                           // Issue command SKIP_ROM
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Write_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Write_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Write_pin+0 
	MOVLW       204
	MOVWF       FARG_Ow_Write_data_+0 
	CALL        _Ow_Write+0, 0
;APESW.c,167 :: 		Ow_Write(&PORTE, 2, 0x44);                           // Issue command CONVERT_T
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Write_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Write_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Write_pin+0 
	MOVLW       68
	MOVWF       FARG_Ow_Write_data_+0 
	CALL        _Ow_Write+0, 0
;APESW.c,168 :: 		Delay_us(120);
	MOVLW       2
	MOVWF       R12, 0
	MOVLW       221
	MOVWF       R13, 0
L_Velocidad21:
	DECFSZ      R13, 1, 1
	BRA         L_Velocidad21
	DECFSZ      R12, 1, 1
	BRA         L_Velocidad21
	NOP
	NOP
;APESW.c,170 :: 		Ow_Reset(&PORTE, 2);
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Reset_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Reset_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Reset_pin+0 
	CALL        _Ow_Reset+0, 0
;APESW.c,171 :: 		Ow_Write(&PORTE, 2, 0xCC);                           // Issue command SKIP_ROM
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Write_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Write_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Write_pin+0 
	MOVLW       204
	MOVWF       FARG_Ow_Write_data_+0 
	CALL        _Ow_Write+0, 0
;APESW.c,172 :: 		Ow_Write(&PORTE, 2, 0xBE);                           // Issue command READ_SCRATCHPAD
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Write_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Write_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Write_pin+0 
	MOVLW       190
	MOVWF       FARG_Ow_Write_data_+0 
	CALL        _Ow_Write+0, 0
;APESW.c,174 :: 		Temp =  Ow_Read(&PORTE, 2);
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Read_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Read_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Read_pin+0 
	CALL        _Ow_Read+0, 0
	MOVF        R0, 0 
	MOVWF       Velocidad_Temp_L0+0 
	MOVLW       0
	MOVWF       Velocidad_Temp_L0+1 
;APESW.c,175 :: 		Temp = (Ow_Read(&PORTE, 2) << 8) + Temp;
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Read_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Read_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Read_pin+0 
	CALL        _Ow_Read+0, 0
	MOVF        R0, 0 
	MOVWF       R5 
	CLRF        R4 
	MOVF        Velocidad_Temp_L0+0, 0 
	ADDWF       R4, 0 
	MOVWF       R2 
	MOVF        Velocidad_Temp_L0+1, 0 
	ADDWFC      R5, 0 
	MOVWF       R3 
	MOVF        R2, 0 
	MOVWF       Velocidad_Temp_L0+0 
	MOVF        R3, 0 
	MOVWF       Velocidad_Temp_L0+1 
;APESW.c,177 :: 		if (Temp & 0x8000) {
	BTFSS       R3, 7 
	GOTO        L_Velocidad22
;APESW.c,178 :: 		Temp = 0;                                         // Si la temperatura es negativa la establece como cero.
	CLRF        Velocidad_Temp_L0+0 
	CLRF        Velocidad_Temp_L0+1 
;APESW.c,179 :: 		}
L_Velocidad22:
;APESW.c,181 :: 		Rint = Temp >> 4;                                    // Extrae la parte entera de la respuesta del sensor
	MOVF        Velocidad_Temp_L0+0, 0 
	MOVWF       FLOC__Velocidad+4 
	MOVF        Velocidad_Temp_L0+1, 0 
	MOVWF       FLOC__Velocidad+5 
	RRCF        FLOC__Velocidad+5, 1 
	RRCF        FLOC__Velocidad+4, 1 
	BCF         FLOC__Velocidad+5, 7 
	RRCF        FLOC__Velocidad+5, 1 
	RRCF        FLOC__Velocidad+4, 1 
	BCF         FLOC__Velocidad+5, 7 
	RRCF        FLOC__Velocidad+5, 1 
	RRCF        FLOC__Velocidad+4, 1 
	BCF         FLOC__Velocidad+5, 7 
	RRCF        FLOC__Velocidad+5, 1 
	RRCF        FLOC__Velocidad+4, 1 
	BCF         FLOC__Velocidad+5, 7 
;APESW.c,182 :: 		Rfrac = ((Temp & 0x000F) * 625) / 10000.;            // Extrae la parte decimal de la respuesta del sensor
	MOVLW       15
	ANDWF       Velocidad_Temp_L0+0, 0 
	MOVWF       R0 
	MOVF        Velocidad_Temp_L0+1, 0 
	MOVWF       R1 
	MOVLW       0
	ANDWF       R1, 1 
	MOVLW       113
	MOVWF       R4 
	MOVLW       2
	MOVWF       R5 
	CALL        _Mul_16X16_U+0, 0
	CALL        _word2double+0, 0
	MOVLW       0
	MOVWF       R4 
	MOVLW       64
	MOVWF       R5 
	MOVLW       28
	MOVWF       R6 
	MOVLW       140
	MOVWF       R7 
	CALL        _Div_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       FLOC__Velocidad+0 
	MOVF        R1, 0 
	MOVWF       FLOC__Velocidad+1 
	MOVF        R2, 0 
	MOVWF       FLOC__Velocidad+2 
	MOVF        R3, 0 
	MOVWF       FLOC__Velocidad+3 
	MOVF        FLOC__Velocidad+4, 0 
	MOVWF       R0 
	MOVF        FLOC__Velocidad+5, 0 
	MOVWF       R1 
	CALL        _word2double+0, 0
;APESW.c,183 :: 		DSTemp = Rint + Rfrac;
	MOVF        FLOC__Velocidad+0, 0 
	MOVWF       R4 
	MOVF        FLOC__Velocidad+1, 0 
	MOVWF       R5 
	MOVF        FLOC__Velocidad+2, 0 
	MOVWF       R6 
	MOVF        FLOC__Velocidad+3, 0 
	MOVWF       R7 
	CALL        _Add_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       _DSTemp+0 
	MOVF        R1, 0 
	MOVWF       _DSTemp+1 
	MOVF        R2, 0 
	MOVWF       _DSTemp+2 
	MOVF        R3, 0 
	MOVWF       _DSTemp+3 
;APESW.c,185 :: 		VSnd = 331.45 * sqrt(1+(DsTemp/273));                  // Expresa la temperatura en punto flotante
	MOVLW       0
	MOVWF       R4 
	MOVLW       128
	MOVWF       R5 
	MOVLW       8
	MOVWF       R6 
	MOVLW       135
	MOVWF       R7 
	CALL        _Div_32x32_FP+0, 0
	MOVLW       0
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVLW       0
	MOVWF       R6 
	MOVLW       127
	MOVWF       R7 
	CALL        _Add_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       FARG_sqrt_x+0 
	MOVF        R1, 0 
	MOVWF       FARG_sqrt_x+1 
	MOVF        R2, 0 
	MOVWF       FARG_sqrt_x+2 
	MOVF        R3, 0 
	MOVWF       FARG_sqrt_x+3 
	CALL        _sqrt+0, 0
	MOVLW       154
	MOVWF       R4 
	MOVLW       185
	MOVWF       R5 
	MOVLW       37
	MOVWF       R6 
	MOVLW       135
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       _VSnd+0 
	MOVF        R1, 0 
	MOVWF       _VSnd+1 
	MOVF        R2, 0 
	MOVWF       _VSnd+2 
	MOVF        R3, 0 
	MOVWF       _VSnd+3 
;APESW.c,186 :: 		}
L_end_Velocidad:
	RETURN      0
; end of _Velocidad

_Configuracion:

;APESW.c,190 :: 		void Configuracion() {
;APESW.c,192 :: 		INTCON.GIE = 1;                             //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;APESW.c,193 :: 		INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;APESW.c,195 :: 		INTCON.INT0IE = 1;                          //Habilita la interrupcion externas en INT0  !!!
	BSF         INTCON+0, 4 
;APESW.c,196 :: 		INTCON2.RBPU = 1;                           //PORTB pull-ups are enabled by individual port latch values
	BSF         INTCON2+0, 7 
;APESW.c,197 :: 		INTCON2.INTEDG0 = 1;                        //Habilita la interrupcion por flanco de subida
	BSF         INTCON2+0, 6 
;APESW.c,199 :: 		ADCON1 = 0b00001111;                        //Configuracion ADCON1
	MOVLW       15
	MOVWF       ADCON1+0 
;APESW.c,200 :: 		CMCON = 0b00000111;
	MOVLW       7
	MOVWF       CMCON+0 
;APESW.c,202 :: 		T1CON=0x00;                                 //Configuracion T1CON: 16 bits, Timer1 Off, Pre-escalador 1:1
	CLRF        T1CON+0 
;APESW.c,203 :: 		TMR1IE_bit = 1;                             //Habilita la interrupcion por desborde de Timer1
	BSF         TMR1IE_bit+0, BitPos(TMR1IE_bit+0) 
;APESW.c,205 :: 		T2CON = 0x00;                               //Configuracion T2CON: Post-escalador 1:1, Timer2 Off, Pre-escalador 1:1
	CLRF        T2CON+0 
;APESW.c,206 :: 		PIE1.TMR2IE = 1;                            //Habilita la interrupcion por desborde de Timer2                        ====> La interrupcion del TMR2 interfiere con la conversion del DHT22
	BSF         PIE1+0, 1 
;APESW.c,207 :: 		PR2 = 149;                                  //Produce una interrupcion cada 12,5us
	MOVLW       149
	MOVWF       PR2+0 
;APESW.c,209 :: 		TRISD0_bit = 0;                             //Establece el pin D0 como salida
	BCF         TRISD0_bit+0, BitPos(TRISD0_bit+0) 
;APESW.c,210 :: 		TRISD1_bit = 0;                             //Establece el pin D1 como salida
	BCF         TRISD1_bit+0, BitPos(TRISD1_bit+0) 
;APESW.c,212 :: 		TRISE0_bit = 0;
	BCF         TRISE0_bit+0, BitPos(TRISE0_bit+0) 
;APESW.c,213 :: 		TRISE1_bit = 0;
	BCF         TRISE1_bit+0, BitPos(TRISE1_bit+0) 
;APESW.c,215 :: 		TRISB = 0x07;                               //Establece los pines B0, B1 y B2 como entradas
	MOVLW       7
	MOVWF       TRISB+0 
;APESW.c,217 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;APESW.c,220 :: 		void main() {
;APESW.c,222 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;APESW.c,224 :: 		RD0_bit = 0;                                //Limpia el pin D0
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;APESW.c,225 :: 		RD1_bit = 1;                                //Limpia el pin D1
	BSF         RD1_bit+0, BitPos(RD1_bit+0) 
;APESW.c,226 :: 		RE1_bit = 0;
	BCF         RE1_bit+0, BitPos(RE1_bit+0) 
;APESW.c,227 :: 		PORTB = 0;                                  //Limpia el puerto B
	CLRF        PORTB+0 
;APESW.c,229 :: 		punT1 = &contT;                             //Asocia el puntero punT1 con la direccion de memoria de la variable contT de tipo entero
	MOVLW       _contT+0
	MOVWF       _punT1+0 
	MOVLW       hi_addr(_contT+0)
	MOVWF       _punT1+1 
;APESW.c,230 :: 		punDt = &Di;                                //Asocia el puntero punDt con la direccion de memoria de la variable Di de tipo entero
	MOVLW       _Di+0
	MOVWF       _punDt+0 
	MOVLW       hi_addr(_Di+0)
	MOVWF       _punDt+1 
;APESW.c,232 :: 		contp = 0;                                  //Limpia todas las variables
	CLRF        _contp+0 
	CLRF        _contp+1 
;APESW.c,233 :: 		contTOF = 0;
	CLRF        _contTOF+0 
	CLRF        _contTOF+1 
;APESW.c,234 :: 		BS = 0;
	CLRF        _BS+0 
;APESW.c,235 :: 		FP = 0;
	CLRF        _FP+0 
;APESW.c,236 :: 		T1 = 0;
	CLRF        _T1+0 
	CLRF        _T1+1 
;APESW.c,237 :: 		T2 = 0;
	CLRF        _T2+0 
	CLRF        _T2+1 
;APESW.c,238 :: 		TOF = 0;
	CLRF        _TOF+0 
	CLRF        _TOF+1 
	CLRF        _TOF+2 
	CLRF        _TOF+3 
;APESW.c,239 :: 		Di = 0;
	CLRF        _Di+0 
	CLRF        _Di+1 
;APESW.c,240 :: 		FEC = 0;
	CLRF        _FEC+0 
;APESW.c,241 :: 		F1 = 0;
	CLRF        _F1+0 
;APESW.c,242 :: 		F2 = 0;
	CLRF        _F2+0 
;APESW.c,243 :: 		F3 = 0;
	CLRF        _F3+0 
;APESW.c,244 :: 		BF1 = 0;
	CLRF        _BF1+0 
;APESW.c,245 :: 		BF2 = 0;
	CLRF        _BF2+0 
	CLRF        _BF2+1 
;APESW.c,246 :: 		BF3 = 0;
	CLRF        _BF3+0 
	CLRF        _BF3+1 
;APESW.c,247 :: 		DFT1 = 0;
	CLRF        _DFT1+0 
;APESW.c,248 :: 		DFT2 = 0;
	CLRF        _DFT2+0 
;APESW.c,250 :: 		Rspt[0] = Hdr;
	MOVLW       32
	MOVWF       _Rspt+0 
;APESW.c,251 :: 		Rspt[1] = idSlv;
	MOVLW       49
	MOVWF       _Rspt+1 
;APESW.c,252 :: 		Rspt[4] = End;
	MOVLW       13
	MOVWF       _Rspt+4 
;APESW.c,254 :: 		Lcd_init();                                 //Inicializa el LCD
	CALL        _Lcd_Init+0, 0
;APESW.c,255 :: 		Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,256 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,258 :: 		UART1_Init(9600);                           // Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	MOVLW       4
	MOVWF       SPBRGH+0 
	MOVLW       225
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;APESW.c,259 :: 		Delay_ms(100);                              // Wait for UART module to stabilize
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_main23:
	DECFSZ      R13, 1, 1
	BRA         L_main23
	DECFSZ      R12, 1, 1
	BRA         L_main23
	DECFSZ      R11, 1, 1
	BRA         L_main23
	NOP
;APESW.c,261 :: 		while (1){
L_main24:
;APESW.c,264 :: 		Velocidad();                          //Invoca la funcion para calcular la Velocidad del sonido
	CALL        _Velocidad+0, 0
;APESW.c,266 :: 		BS = 0;
	CLRF        _BS+0 
;APESW.c,267 :: 		contp = 0;                            //Limpia los contadores
	CLRF        _contp+0 
	CLRF        _contp+1 
;APESW.c,268 :: 		contT = 0;
	CLRF        _contT+0 
	CLRF        _contT+1 
;APESW.c,269 :: 		T1=0;
	CLRF        _T1+0 
	CLRF        _T1+1 
;APESW.c,270 :: 		T2=0;
	CLRF        _T2+0 
	CLRF        _T2+1 
;APESW.c,271 :: 		DT=0;
	CLRF        _DT+0 
	CLRF        _DT+1 
;APESW.c,273 :: 		F1 = 0;                               //Limpia las variables utilizadas en la deteccion de cambio de fase
	CLRF        _F1+0 
;APESW.c,274 :: 		F2 = 0;
	CLRF        _F2+0 
;APESW.c,275 :: 		F3 = 0;
	CLRF        _F3+0 
;APESW.c,276 :: 		BF1 = 0;
	CLRF        _BF1+0 
;APESW.c,277 :: 		BF2 = 0;
	CLRF        _BF2+0 
	CLRF        _BF2+1 
;APESW.c,278 :: 		BF3 = 0;
	CLRF        _BF3+0 
	CLRF        _BF3+1 
;APESW.c,279 :: 		DF1 = 0;
	CLRF        _DF1+0 
;APESW.c,280 :: 		DF2 = 0;
	CLRF        _DF2+0 
;APESW.c,281 :: 		DF3 = 0;
	CLRF        _DF3+0 
;APESW.c,282 :: 		DFT1 = 0;
	CLRF        _DFT1+0 
;APESW.c,283 :: 		DFT2 = 0;
	CLRF        _DFT2+0 
;APESW.c,285 :: 		TMR2ON_bit=1;                         //Enciende el TMR2.
	BSF         TMR2ON_bit+0, BitPos(TMR2ON_bit+0) 
;APESW.c,288 :: 		TOF = (contTOF)*(4./48);               //Calcula el valor de TOF (en microsegundos)
	MOVF        _contTOF+0, 0 
	MOVWF       R0 
	MOVF        _contTOF+1, 0 
	MOVWF       R1 
	CALL        _word2double+0, 0
	MOVLW       171
	MOVWF       R4 
	MOVLW       170
	MOVWF       R5 
	MOVLW       42
	MOVWF       R6 
	MOVLW       123
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       _TOF+0 
	MOVF        R1, 0 
	MOVWF       _TOF+1 
	MOVF        R2, 0 
	MOVWF       _TOF+2 
	MOVF        R3, 0 
	MOVWF       _TOF+3 
;APESW.c,289 :: 		Df = ((VSnd * TOF ) / 2000);          //Calcula la distancia en funcion del TOF
	MOVF        _VSnd+0, 0 
	MOVWF       R4 
	MOVF        _VSnd+1, 0 
	MOVWF       R5 
	MOVF        _VSnd+2, 0 
	MOVWF       R6 
	MOVF        _VSnd+3, 0 
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
	MOVLW       0
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVLW       122
	MOVWF       R6 
	MOVLW       137
	MOVWF       R7 
	CALL        _Div_32x32_FP+0, 0
	MOVF        R0, 0 
	MOVWF       _Df+0 
	MOVF        R1, 0 
	MOVWF       _Df+1 
	MOVF        R2, 0 
	MOVWF       _Df+2 
	MOVF        R3, 0 
	MOVWF       _Df+3 
;APESW.c,290 :: 		Di = Df*10;                           //Almacena la distancia en una variable de tipo entero
	MOVLW       0
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	MOVLW       32
	MOVWF       R6 
	MOVLW       130
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
	CALL        _double2word+0, 0
	MOVF        R0, 0 
	MOVWF       _Di+0 
	MOVF        R1, 0 
	MOVWF       _Di+1 
;APESW.c,292 :: 		for (i=2;i<4;i++){                    //Rellena la trama de cuerpo de datos de 4 bytes
	MOVLW       2
	MOVWF       _i+0 
L_main26:
	MOVLW       4
	SUBWF       _i+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main27
;APESW.c,293 :: 		Rspt[i]=(*punDt++);               //El operador * permite acceder al valor de la direccion del puntero,
	MOVLW       _Rspt+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR1H 
	MOVF        _i+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVFF       _punDt+0, FSR0
	MOVFF       _punDt+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
	INFSNZ      _punDt+0, 1 
	INCF        _punDt+1, 1 
;APESW.c,292 :: 		for (i=2;i<4;i++){                    //Rellena la trama de cuerpo de datos de 4 bytes
	INCF        _i+0, 1 
;APESW.c,294 :: 		}
	GOTO        L_main26
L_main27:
;APESW.c,296 :: 		FloatToStr(TOF, txt1);
	MOVF        _TOF+0, 0 
	MOVWF       FARG_FloatToStr_fnum+0 
	MOVF        _TOF+1, 0 
	MOVWF       FARG_FloatToStr_fnum+1 
	MOVF        _TOF+2, 0 
	MOVWF       FARG_FloatToStr_fnum+2 
	MOVF        _TOF+3, 0 
	MOVWF       FARG_FloatToStr_fnum+3 
	MOVLW       _txt1+0
	MOVWF       FARG_FloatToStr_str+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_FloatToStr_str+1 
	CALL        _FloatToStr+0, 0
;APESW.c,297 :: 		FloatToStr(Df, txt2);
	MOVF        _Df+0, 0 
	MOVWF       FARG_FloatToStr_fnum+0 
	MOVF        _Df+1, 0 
	MOVWF       FARG_FloatToStr_fnum+1 
	MOVF        _Df+2, 0 
	MOVWF       FARG_FloatToStr_fnum+2 
	MOVF        _Df+3, 0 
	MOVWF       FARG_FloatToStr_fnum+3 
	MOVLW       _txt2+0
	MOVWF       FARG_FloatToStr_str+0 
	MOVLW       hi_addr(_txt2+0)
	MOVWF       FARG_FloatToStr_str+1 
	CALL        _FloatToStr+0, 0
;APESW.c,299 :: 		Lcd_Out(1,1,"TOF: ");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,300 :: 		Lcd_Out_Cp(txt1);                     //Visualiza el valor del TOF en el LCD*/
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_CP_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_CP_text+1 
	CALL        _Lcd_Out_CP+0, 0
;APESW.c,301 :: 		Lcd_Out(2,1,"Dst: ");
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,302 :: 		Lcd_Out_Cp(txt2);                     //Visualiza el valor del TOF en el LCD*/
	MOVLW       _txt2+0
	MOVWF       FARG_Lcd_Out_CP_text+0 
	MOVLW       hi_addr(_txt2+0)
	MOVWF       FARG_Lcd_Out_CP_text+1 
	CALL        _Lcd_Out_CP+0, 0
;APESW.c,304 :: 		delay_ms(15);
	MOVLW       234
	MOVWF       R12, 0
	MOVLW       195
	MOVWF       R13, 0
L_main29:
	DECFSZ      R13, 1, 1
	BRA         L_main29
	DECFSZ      R12, 1, 1
	BRA         L_main29
;APESW.c,306 :: 		}
	GOTO        L_main24
;APESW.c,307 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
