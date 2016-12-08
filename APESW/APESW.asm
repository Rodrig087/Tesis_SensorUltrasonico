
_Interrupt:

;APESW.c,72 :: 		void Interrupt(){
;APESW.c,75 :: 		if (TMR2IF_bit){                             //Verifica si ocurrio una interrupcion por desbordamiento del TMR2.
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_Interrupt0
;APESW.c,77 :: 		if (contp<=20){                           //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (42)
	MOVLW       0
	MOVWF       R0 
	MOVF        _contp+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt33
	MOVF        _contp+0, 0 
	SUBLW       20
L__Interrupt33:
	BTFSS       STATUS+0, 0 
	GOTO        L_Interrupt1
;APESW.c,78 :: 		BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
	COMF        _BS+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _BS+0 
;APESW.c,79 :: 		RD0_bit = BS;
	BTFSC       R0, 0 
	GOTO        L__Interrupt34
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
	GOTO        L__Interrupt35
L__Interrupt34:
	BSF         RD0_bit+0, BitPos(RD0_bit+0) 
L__Interrupt35:
;APESW.c,85 :: 		} else {
	GOTO        L_Interrupt2
L_Interrupt1:
;APESW.c,86 :: 		TMR2ON_bit=0;                          //Apaga el TMR2
	BCF         TMR2ON_bit+0, BitPos(TMR2ON_bit+0) 
;APESW.c,87 :: 		RD0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;APESW.c,88 :: 		TMR1ON_bit=1;                          //Enciende el TMR1.
	BSF         TMR1ON_bit+0, BitPos(TMR1ON_bit+0) 
;APESW.c,89 :: 		TMR1L=0X00;                            //Limpia los bits menos significativos del TMR1.
	CLRF        TMR1L+0 
;APESW.c,90 :: 		TMR1H=0X00;                            //Limpia los bits mas significativos del TMR1.
	CLRF        TMR1H+0 
;APESW.c,91 :: 		}
L_Interrupt2:
;APESW.c,93 :: 		contp++;                                  //Aumenta el contador en una unidad.
	INFSNZ      _contp+0, 1 
	INCF        _contp+1, 1 
;APESW.c,94 :: 		TMR2IF_bit = 0;                           //Limpia la bandera de interrupcion de Timer2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;APESW.c,96 :: 		}
L_Interrupt0:
;APESW.c,99 :: 		if (INTCON.INT0IF == 1){                     //Verifica si ocurrio una interrupcion externa en INT0.
	BTFSS       INTCON+0, 1 
	GOTO        L_Interrupt3
;APESW.c,102 :: 		*(punT1) = TMR1L;                         //Carga el valor actual de TMR1L en los 8 bits menos significativos de la variable contT de tipo entero.
	MOVFF       _punT1+0, FSR1
	MOVFF       _punT1+1, FSR1H
	MOVF        TMR1L+0, 0 
	MOVWF       POSTINC1+0 
;APESW.c,103 :: 		*(punT1+1) = TMR1H;                       //Carga el valor actual de TMR1H en los 8 bits mas significativos de la variable  contT de tipo entero.
	MOVLW       1
	ADDWF       _punT1+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _punT1+1, 0 
	MOVWF       FSR1H 
	MOVF        TMR1H+0, 0 
	MOVWF       POSTINC1+0 
;APESW.c,105 :: 		T2 = contT;                               //Carga el contenido actual de la variable contT en la variable T2.
	MOVF        _contT+0, 0 
	MOVWF       _T2+0 
	MOVF        _contT+1, 0 
	MOVWF       _T2+1 
;APESW.c,106 :: 		DT = (T2-T1);                             //Halla la diferencia entre los valores actual y anterior de la variable contT (en nanosegundos).
	MOVF        _T1+0, 0 
	SUBWF       _contT+0, 0 
	MOVWF       _DT+0 
	MOVF        _T1+1, 0 
	SUBWFB      _contT+1, 0 
	MOVWF       _DT+1 
;APESW.c,108 :: 		if (F1<=3){
	MOVF        _F1+0, 0 
	SUBLW       3
	BTFSS       STATUS+0, 0 
	GOTO        L_Interrupt4
;APESW.c,109 :: 		if (DT>(300-Tht)&&DT<(300+Tht)){      //Realiza una comparacion para verificar cuando se estabilice la primera fase de la senal
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
	GOTO        L__Interrupt36
	MOVF        _DT+0, 0 
	SUBWF       R1, 0 
L__Interrupt36:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt7
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
	GOTO        L__Interrupt37
	MOVF        R1, 0 
	SUBWF       _DT+0, 0 
L__Interrupt37:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt7
L__Interrupt30:
;APESW.c,110 :: 		F1++;
	INCF        _F1+0, 1 
;APESW.c,111 :: 		if (F1==3) {                       //Si 3 intervalos consecutivos cumplen con la condicion de estabilizacion, se empieza con el proceso de busqueda de cambio de fase
	MOVF        _F1+0, 0 
	XORLW       3
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt8
;APESW.c,112 :: 		DF1 = T2;                       //Almacena el valor actual de la variable T2 para la referencia de inicio de deteccion de fase
	MOVF        _T2+0, 0 
	MOVWF       _DF1+0 
;APESW.c,113 :: 		BF1 = 1;                        //Activa la bandera de deteccion de la fase 1
	MOVLW       1
	MOVWF       _BF1+0 
;APESW.c,114 :: 		}
L_Interrupt8:
;APESW.c,115 :: 		} else {
	GOTO        L_Interrupt9
L_Interrupt7:
;APESW.c,116 :: 		F1=0;                              //Resetea el contador si no encuentra 3 intervalos iguales
	CLRF        _F1+0 
;APESW.c,117 :: 		}
L_Interrupt9:
;APESW.c,118 :: 		}
L_Interrupt4:
;APESW.c,120 :: 		if (BF1==1){                                     //Inicia  la deteccion del primer cambio de fase
	MOVF        _BF1+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt10
;APESW.c,121 :: 		F2++;
	INCF        _F2+0, 1 
;APESW.c,122 :: 		DF2 = (T2-DF1);
	MOVF        _DF1+0, 0 
	SUBWF       _T2+0, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	MOVWF       _DF2+0 
;APESW.c,123 :: 		DFT1 = ((F2*2)-1)*150;
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
;APESW.c,124 :: 		if ((DFT1>(DF2-Tht))&&(DFT1<(DF2+Tht))){
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
	GOTO        L__Interrupt38
	MOVF        R3, 0 
	SUBWF       R1, 0 
L__Interrupt38:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt13
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
	GOTO        L__Interrupt39
	MOVF        R1, 0 
	SUBWF       _DFT1+0, 0 
L__Interrupt39:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt13
L__Interrupt29:
;APESW.c,125 :: 		RE1_bit = 1;
	BSF         RE1_bit+0, BitPos(RE1_bit+0) 
;APESW.c,126 :: 		DF2 = T2;
	MOVF        _T2+0, 0 
	MOVWF       _DF2+0 
;APESW.c,127 :: 		BF2 = 1;
	MOVLW       1
	MOVWF       _BF2+0 
	MOVLW       0
	MOVWF       _BF2+1 
;APESW.c,128 :: 		BF1 = 0;
	CLRF        _BF1+0 
;APESW.c,129 :: 		}
L_Interrupt13:
;APESW.c,130 :: 		}
L_Interrupt10:
;APESW.c,132 :: 		if (BF2==1){
	MOVLW       0
	XORWF       _BF2+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt40
	MOVLW       1
	XORWF       _BF2+0, 0 
L__Interrupt40:
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt14
;APESW.c,133 :: 		F3++;
	INCF        _F3+0, 1 
;APESW.c,134 :: 		DF3 = (T2-DF2);
	MOVF        _DF2+0, 0 
	SUBWF       _T2+0, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	MOVWF       _DF3+0 
;APESW.c,135 :: 		DFT2 = ((F3*2)-1)*150;                       //!!!!!
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
;APESW.c,136 :: 		if ((DFT2>(DF3-Tht))&&(DFT2<(DF3+Tht))){
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
	GOTO        L__Interrupt41
	MOVF        R3, 0 
	SUBWF       R1, 0 
L__Interrupt41:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt17
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
	GOTO        L__Interrupt42
	MOVF        R1, 0 
	SUBWF       _DFT2+0, 0 
L__Interrupt42:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt17
L__Interrupt28:
;APESW.c,137 :: 		RE1_bit = 0;
	BCF         RE1_bit+0, BitPos(RE1_bit+0) 
;APESW.c,138 :: 		DF3 = T2;
	MOVF        _T2+0, 0 
	MOVWF       _DF3+0 
;APESW.c,139 :: 		BF2 = 0;
	CLRF        _BF2+0 
	CLRF        _BF2+1 
;APESW.c,140 :: 		TMR1ON_bit = 0;                          //Apaga el TMR1.
	BCF         TMR1ON_bit+0, BitPos(TMR1ON_bit+0) 
;APESW.c,141 :: 		contT = 0;                               //Limpia el contenido de la variable contT.
	CLRF        _contT+0 
	CLRF        _contT+1 
;APESW.c,142 :: 		}
L_Interrupt17:
;APESW.c,143 :: 		}
L_Interrupt14:
;APESW.c,145 :: 		T1 = contT;                                     //Actualiza T1 con el valor actual del contador contT.
	MOVF        _contT+0, 0 
	MOVWF       _T1+0 
	MOVF        _contT+1, 0 
	MOVWF       _T1+1 
;APESW.c,146 :: 		INTCON.INT0IF = 0;                              //Limpia la bandera de interrupcion de INT0.
	BCF         INTCON+0, 1 
;APESW.c,148 :: 		}
L_Interrupt3:
;APESW.c,150 :: 		if (TMR1IF_bit){
	BTFSS       TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
	GOTO        L_Interrupt18
;APESW.c,151 :: 		TMR1IF_bit=0;                             //Limpia la bandera de interrupcion de Timer1.
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;APESW.c,152 :: 		}
L_Interrupt18:
;APESW.c,154 :: 		}
L_end_Interrupt:
L__Interrupt32:
	RETFIE      1
; end of _Interrupt

_Velocidad:

;APESW.c,158 :: 		void Velocidad(){
;APESW.c,163 :: 		Ow_Reset(&PORTE, 2);                                 // Onewire reset signal
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Reset_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Reset_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Reset_pin+0 
	CALL        _Ow_Reset+0, 0
;APESW.c,164 :: 		Ow_Write(&PORTE, 2, 0xCC);                           // Issue command SKIP_ROM
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Write_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Write_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Write_pin+0 
	MOVLW       204
	MOVWF       FARG_Ow_Write_data_+0 
	CALL        _Ow_Write+0, 0
;APESW.c,165 :: 		Ow_Write(&PORTE, 2, 0x44);                           // Issue command CONVERT_T
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Write_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Write_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Write_pin+0 
	MOVLW       68
	MOVWF       FARG_Ow_Write_data_+0 
	CALL        _Ow_Write+0, 0
;APESW.c,166 :: 		Delay_us(120);
	MOVLW       2
	MOVWF       R12, 0
	MOVLW       221
	MOVWF       R13, 0
L_Velocidad19:
	DECFSZ      R13, 1, 1
	BRA         L_Velocidad19
	DECFSZ      R12, 1, 1
	BRA         L_Velocidad19
	NOP
	NOP
;APESW.c,168 :: 		Ow_Reset(&PORTE, 2);
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Reset_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Reset_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Reset_pin+0 
	CALL        _Ow_Reset+0, 0
;APESW.c,169 :: 		Ow_Write(&PORTE, 2, 0xCC);                           // Issue command SKIP_ROM
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Write_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Write_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Write_pin+0 
	MOVLW       204
	MOVWF       FARG_Ow_Write_data_+0 
	CALL        _Ow_Write+0, 0
;APESW.c,170 :: 		Ow_Write(&PORTE, 2, 0xBE);                           // Issue command READ_SCRATCHPAD
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Write_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Write_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Write_pin+0 
	MOVLW       190
	MOVWF       FARG_Ow_Write_data_+0 
	CALL        _Ow_Write+0, 0
;APESW.c,172 :: 		Temp =  Ow_Read(&PORTE, 2);
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
;APESW.c,173 :: 		Temp = (Ow_Read(&PORTE, 2) << 8) + Temp;
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
;APESW.c,175 :: 		if (Temp & 0x8000) {
	BTFSS       R3, 7 
	GOTO        L_Velocidad20
;APESW.c,176 :: 		Temp = 0;                                         // Si la temperatura es negativa la establece como cero.
	CLRF        Velocidad_Temp_L0+0 
	CLRF        Velocidad_Temp_L0+1 
;APESW.c,177 :: 		}
L_Velocidad20:
;APESW.c,179 :: 		Rint = Temp >> 4;                                    // Extrae la parte entera de la respuesta del sensor
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
;APESW.c,180 :: 		Rfrac = ((Temp & 0x000F) * 625) / 10000.;            // Extrae la parte decimal de la respuesta del sensor
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
;APESW.c,181 :: 		DSTemp = Rint + Rfrac;
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
;APESW.c,183 :: 		VSnd = 331.45 * sqrt(1+(DsTemp/273));                  // Expresa la temperatura en punto flotante
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
;APESW.c,184 :: 		}
L_end_Velocidad:
	RETURN      0
; end of _Velocidad

_Configuracion:

;APESW.c,188 :: 		void Configuracion() {
;APESW.c,190 :: 		INTCON.GIE = 1;                             //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;APESW.c,191 :: 		INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;APESW.c,193 :: 		INTCON.INT0IE = 1;                          //Habilita la interrupcion externas en INT0  !!!
	BSF         INTCON+0, 4 
;APESW.c,194 :: 		INTCON2.RBPU = 1;                           //PORTB pull-ups are enabled by individual port latch values
	BSF         INTCON2+0, 7 
;APESW.c,195 :: 		INTCON2.INTEDG0 = 1;                        //Habilita la interrupcion por flanco de subida
	BSF         INTCON2+0, 6 
;APESW.c,197 :: 		ADCON1 = 0b00001111;                        //Configuracion ADCON1
	MOVLW       15
	MOVWF       ADCON1+0 
;APESW.c,198 :: 		CMCON = 0b00000111;
	MOVLW       7
	MOVWF       CMCON+0 
;APESW.c,200 :: 		T1CON=0x00;                                 //Configuracion T1CON: 16 bits, Timer1 Off, Pre-escalador 1:1
	CLRF        T1CON+0 
;APESW.c,201 :: 		TMR1IE_bit = 1;                             //Habilita la interrupcion por desborde de Timer1
	BSF         TMR1IE_bit+0, BitPos(TMR1IE_bit+0) 
;APESW.c,203 :: 		T2CON = 0x00;                               //Configuracion T2CON: Post-escalador 1:1, Timer2 Off, Pre-escalador 1:1
	CLRF        T2CON+0 
;APESW.c,204 :: 		PIE1.TMR2IE = 1;                            //Habilita la interrupcion por desborde de Timer2                        ====> La interrupcion del TMR2 interfiere con la conversion del DHT22
	BSF         PIE1+0, 1 
;APESW.c,205 :: 		PR2 = 149;                                  //Produce una interrupcion cada 12,5us
	MOVLW       149
	MOVWF       PR2+0 
;APESW.c,207 :: 		TRISD0_bit = 0;                             //Establece el pin D0 como salida
	BCF         TRISD0_bit+0, BitPos(TRISD0_bit+0) 
;APESW.c,208 :: 		TRISD1_bit = 0;                             //Establece el pin D1 como salida
	BCF         TRISD1_bit+0, BitPos(TRISD1_bit+0) 
;APESW.c,210 :: 		TRISE0_bit = 0;
	BCF         TRISE0_bit+0, BitPos(TRISE0_bit+0) 
;APESW.c,211 :: 		TRISE1_bit = 0;
	BCF         TRISE1_bit+0, BitPos(TRISE1_bit+0) 
;APESW.c,213 :: 		TRISB = 0x07;                               //Establece los pines B0, B1 y B2 como entradas
	MOVLW       7
	MOVWF       TRISB+0 
;APESW.c,215 :: 		}
L_end_Configuracion:
	RETURN      0
; end of _Configuracion

_main:

;APESW.c,218 :: 		void main() {
;APESW.c,220 :: 		Configuracion();
	CALL        _Configuracion+0, 0
;APESW.c,222 :: 		RD0_bit = 0;                                //Limpia el pin D0
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;APESW.c,223 :: 		RD1_bit = 1;                                //Limpia el pin D1
	BSF         RD1_bit+0, BitPos(RD1_bit+0) 
;APESW.c,224 :: 		RE1_bit = 0;
	BCF         RE1_bit+0, BitPos(RE1_bit+0) 
;APESW.c,225 :: 		PORTB = 0;                                  //Limpia el puerto B
	CLRF        PORTB+0 
;APESW.c,227 :: 		punT1 = &contT;                             //Asocia el puntero punT1 con la direccion de memoria de la variable contT de tipo entero
	MOVLW       _contT+0
	MOVWF       _punT1+0 
	MOVLW       hi_addr(_contT+0)
	MOVWF       _punT1+1 
;APESW.c,228 :: 		punDt = &Di;                                //Asocia el puntero punDt con la direccion de memoria de la variable Di de tipo entero
	MOVLW       _Di+0
	MOVWF       _punDt+0 
	MOVLW       hi_addr(_Di+0)
	MOVWF       _punDt+1 
;APESW.c,230 :: 		contp = 0;                                  //Limpia todas las variables
	CLRF        _contp+0 
	CLRF        _contp+1 
;APESW.c,231 :: 		contTOF = 0;
	CLRF        _contTOF+0 
	CLRF        _contTOF+1 
;APESW.c,232 :: 		BS = 0;
	CLRF        _BS+0 
;APESW.c,233 :: 		FP = 0;
	CLRF        _FP+0 
;APESW.c,234 :: 		T1 = 0;
	CLRF        _T1+0 
	CLRF        _T1+1 
;APESW.c,235 :: 		T2 = 0;
	CLRF        _T2+0 
	CLRF        _T2+1 
;APESW.c,236 :: 		TOF = 0;
	CLRF        _TOF+0 
	CLRF        _TOF+1 
	CLRF        _TOF+2 
	CLRF        _TOF+3 
;APESW.c,237 :: 		Di = 0;
	CLRF        _Di+0 
	CLRF        _Di+1 
;APESW.c,238 :: 		FEC = 0;
	CLRF        _FEC+0 
;APESW.c,239 :: 		F1 = 0;
	CLRF        _F1+0 
;APESW.c,240 :: 		F2 = 0;
	CLRF        _F2+0 
;APESW.c,241 :: 		F3 = 0;
	CLRF        _F3+0 
;APESW.c,242 :: 		BF1 = 0;
	CLRF        _BF1+0 
;APESW.c,243 :: 		BF2 = 0;
	CLRF        _BF2+0 
	CLRF        _BF2+1 
;APESW.c,244 :: 		BF3 = 0;
	CLRF        _BF3+0 
	CLRF        _BF3+1 
;APESW.c,245 :: 		DFT1 = 0;
	CLRF        _DFT1+0 
;APESW.c,246 :: 		DFT2 = 0;
	CLRF        _DFT2+0 
;APESW.c,248 :: 		Rspt[0] = Hdr;
	MOVLW       32
	MOVWF       _Rspt+0 
;APESW.c,249 :: 		Rspt[1] = idSlv;
	MOVLW       49
	MOVWF       _Rspt+1 
;APESW.c,250 :: 		Rspt[4] = End;
	MOVLW       13
	MOVWF       _Rspt+4 
;APESW.c,252 :: 		Lcd_init();                                 //Inicializa el LCD
	CALL        _Lcd_Init+0, 0
;APESW.c,253 :: 		Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,254 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,256 :: 		UART1_Init(9600);                           // Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	MOVLW       4
	MOVWF       SPBRGH+0 
	MOVLW       225
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;APESW.c,257 :: 		Delay_ms(100);                              // Wait for UART module to stabilize
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_main21:
	DECFSZ      R13, 1, 1
	BRA         L_main21
	DECFSZ      R12, 1, 1
	BRA         L_main21
	DECFSZ      R11, 1, 1
	BRA         L_main21
	NOP
;APESW.c,259 :: 		while (1){
L_main22:
;APESW.c,262 :: 		Velocidad();                          //Invoca la funcion para calcular la Velocidad del sonido
	CALL        _Velocidad+0, 0
;APESW.c,264 :: 		BS = 0;
	CLRF        _BS+0 
;APESW.c,265 :: 		contp = 0;                            //Limpia los contadores
	CLRF        _contp+0 
	CLRF        _contp+1 
;APESW.c,266 :: 		contT = 0;
	CLRF        _contT+0 
	CLRF        _contT+1 
;APESW.c,267 :: 		T1=0;
	CLRF        _T1+0 
	CLRF        _T1+1 
;APESW.c,268 :: 		T2=0;
	CLRF        _T2+0 
	CLRF        _T2+1 
;APESW.c,269 :: 		DT=0;
	CLRF        _DT+0 
	CLRF        _DT+1 
;APESW.c,271 :: 		F1 = 0;                               //Limpia las variables utilizadas en la deteccion de cambio de fase
	CLRF        _F1+0 
;APESW.c,272 :: 		F2 = 0;
	CLRF        _F2+0 
;APESW.c,273 :: 		F3 = 0;
	CLRF        _F3+0 
;APESW.c,274 :: 		BF1 = 0;
	CLRF        _BF1+0 
;APESW.c,275 :: 		BF2 = 0;
	CLRF        _BF2+0 
	CLRF        _BF2+1 
;APESW.c,276 :: 		BF3 = 0;
	CLRF        _BF3+0 
	CLRF        _BF3+1 
;APESW.c,277 :: 		DF1 = 0;
	CLRF        _DF1+0 
;APESW.c,278 :: 		DF2 = 0;
	CLRF        _DF2+0 
;APESW.c,279 :: 		DF3 = 0;
	CLRF        _DF3+0 
;APESW.c,280 :: 		DFT1 = 0;
	CLRF        _DFT1+0 
;APESW.c,281 :: 		DFT2 = 0;
	CLRF        _DFT2+0 
;APESW.c,283 :: 		TMR2ON_bit=1;                         //Enciende el TMR2.
	BSF         TMR2ON_bit+0, BitPos(TMR2ON_bit+0) 
;APESW.c,286 :: 		TOF = (contTOF)*(4./48);               //Calcula el valor de TOF (en microsegundos)
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
;APESW.c,287 :: 		Df = ((VSnd * TOF ) / 2000);          //Calcula la distancia en funcion del TOF
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
;APESW.c,288 :: 		Di = Df*10;                           //Almacena la distancia en una variable de tipo entero
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
;APESW.c,290 :: 		for (i=2;i<4;i++){                    //Rellena la trama de cuerpo de datos de 4 bytes
	MOVLW       2
	MOVWF       _i+0 
L_main24:
	MOVLW       4
	SUBWF       _i+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main25
;APESW.c,291 :: 		Rspt[i]=(*punDt++);               //El operador * permite acceder al valor de la direccion del puntero,
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
;APESW.c,290 :: 		for (i=2;i<4;i++){                    //Rellena la trama de cuerpo de datos de 4 bytes
	INCF        _i+0, 1 
;APESW.c,292 :: 		}
	GOTO        L_main24
L_main25:
;APESW.c,294 :: 		FloatToStr(TOF, txt1);
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
;APESW.c,295 :: 		FloatToStr(Df, txt2);
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
;APESW.c,297 :: 		Lcd_Out(1,1,"TOF: ");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,298 :: 		Lcd_Out_Cp(txt1);                     //Visualiza el valor del TOF en el LCD*/
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_CP_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_CP_text+1 
	CALL        _Lcd_Out_CP+0, 0
;APESW.c,299 :: 		Lcd_Out(2,1,"Dst: ");
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,300 :: 		Lcd_Out_Cp(txt2);                     //Visualiza el valor del TOF en el LCD*/
	MOVLW       _txt2+0
	MOVWF       FARG_Lcd_Out_CP_text+0 
	MOVLW       hi_addr(_txt2+0)
	MOVWF       FARG_Lcd_Out_CP_text+1 
	CALL        _Lcd_Out_CP+0, 0
;APESW.c,302 :: 		delay_ms(15);
	MOVLW       234
	MOVWF       R12, 0
	MOVLW       195
	MOVWF       R13, 0
L_main27:
	DECFSZ      R13, 1, 1
	BRA         L_main27
	DECFSZ      R12, 1, 1
	BRA         L_main27
;APESW.c,304 :: 		}
	GOTO        L_main22
;APESW.c,305 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
