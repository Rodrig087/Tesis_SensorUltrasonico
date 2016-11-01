
_Interrupt:

;APESW.c,73 :: 		void Interrupt(){
;APESW.c,76 :: 		if (TMR2IF_bit){                             //Verifica si ocurrio una interrupcion por desbordamiento del TMR2.
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_Interrupt0
;APESW.c,80 :: 		if (contw<=43){                           //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (43)
	MOVLW       0
	MOVWF       R0 
	MOVF        _contw+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt33
	MOVF        _contw+0, 0 
	SUBLW       43
L__Interrupt33:
	BTFSS       STATUS+0, 0 
	GOTO        L_Interrupt1
;APESW.c,81 :: 		BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
	COMF        _BS+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _BS+0 
;APESW.c,82 :: 		RD0_bit = BS;
	BTFSC       R0, 0 
	GOTO        L__Interrupt34
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
	GOTO        L__Interrupt35
L__Interrupt34:
	BSF         RD0_bit+0, BitPos(RD0_bit+0) 
L__Interrupt35:
;APESW.c,84 :: 		if (contw==25){                        //Se empieza a contar el tiempo desde el primer pulso en alto despues del cambio de fase. 25
	MOVLW       0
	XORWF       _contw+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt36
	MOVLW       25
	XORWF       _contw+0, 0 
L__Interrupt36:
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt2
;APESW.c,85 :: 		TMR1ON_bit=1;                       //Enciende el TMR1.
	BSF         TMR1ON_bit+0, BitPos(TMR1ON_bit+0) 
;APESW.c,86 :: 		TMR1L=0X00;                         //Limpia los bits menos significativos del TMR1.
	CLRF        TMR1L+0 
;APESW.c,87 :: 		TMR1H=0X00;                         //Limpia los bits mas significativos del TMR1.
	CLRF        TMR1H+0 
;APESW.c,88 :: 		}
L_Interrupt2:
;APESW.c,89 :: 		if (contw==22){                        //Cambia el valor de la variable auxiliar para producir  (22)
	MOVLW       0
	XORWF       _contw+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt37
	MOVLW       22
	XORWF       _contw+0, 0 
L__Interrupt37:
	BTFSS       STATUS+0, 2 
	GOTO        L_Interrupt3
;APESW.c,90 :: 		BS = 0;                          //el cambio de fase en la siguiente iteracion.
	CLRF        _BS+0 
;APESW.c,91 :: 		RD1_bit = 1;                     //Inicio del pulso de indicacion del TOF
	BSF         RD1_bit+0, BitPos(RD1_bit+0) 
;APESW.c,92 :: 		}
L_Interrupt3:
;APESW.c,94 :: 		} else {
	GOTO        L_Interrupt4
L_Interrupt1:
;APESW.c,95 :: 		RD0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;APESW.c,96 :: 		FP = 1;                                //Habilita la bandera de deteccion de fase para permitir la deteccion una vez que se hayan terminado de enviar todos los pulsos de exitacion
	MOVLW       1
	MOVWF       _FP+0 
;APESW.c,97 :: 		}
L_Interrupt4:
;APESW.c,99 :: 		if (contw>=800){                          //Limpia el contador cada 800 interrupciones (10ms) para el reenvio de los pulsos
	MOVLW       3
	SUBWF       _contw+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt38
	MOVLW       32
	SUBWF       _contw+0, 0 
L__Interrupt38:
	BTFSS       STATUS+0, 0 
	GOTO        L_Interrupt5
;APESW.c,100 :: 		contw = 0;                             //de exitacion del transductor ultrasonico.
	CLRF        _contw+0 
	CLRF        _contw+1 
;APESW.c,101 :: 		T1=0;
	CLRF        _T1+0 
	CLRF        _T1+1 
;APESW.c,102 :: 		T2=0;
	CLRF        _T2+0 
	CLRF        _T2+1 
;APESW.c,103 :: 		DT=0;
	CLRF        _DT+0 
	CLRF        _DT+1 
;APESW.c,104 :: 		}
L_Interrupt5:
;APESW.c,106 :: 		contw++;                                  //Aumenta el contador en una unidad.
	INFSNZ      _contw+0, 1 
	INCF        _contw+1, 1 
;APESW.c,107 :: 		TMR2IF_bit = 0;                           //Limpia la bandera de interrupcion de Timer2
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;APESW.c,108 :: 		}
L_Interrupt0:
;APESW.c,111 :: 		if (INTCON.INT0IF == 1){                     //Verifica si ocurrio una interrupcion externa en INT0.
	BTFSS       INTCON+0, 1 
	GOTO        L_Interrupt6
;APESW.c,112 :: 		*(punT1) = TMR1L;                         //Carga el valor actual de TMR1L en los 8 bits menos significativos de la variable contT de tipo entero.
	MOVFF       _punT1+0, FSR1
	MOVFF       _punT1+1, FSR1H
	MOVF        TMR1L+0, 0 
	MOVWF       POSTINC1+0 
;APESW.c,113 :: 		*(punT1+1) = TMR1H;                       //Carga el valor actual de TMR1H en los 8 bits mas significativos de la variable  contT de tipo entero.
	MOVLW       1
	ADDWF       _punT1+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      _punT1+1, 0 
	MOVWF       FSR1H 
	MOVF        TMR1H+0, 0 
	MOVWF       POSTINC1+0 
;APESW.c,114 :: 		T2 = contw;                               //Carga el valor actual del contador contw en la variable T2.
	MOVF        _contw+0, 0 
	MOVWF       _T2+0 
	MOVF        _contw+1, 0 
	MOVWF       _T2+1 
;APESW.c,115 :: 		DT = T2-T1;                               //Halla la diferencia entre los valores actual y anterior del contador contw.
	MOVF        _T1+0, 0 
	SUBWF       _contw+0, 0 
	MOVWF       _DT+0 
	MOVF        _T1+1, 0 
	SUBWFB      _contw+1, 0 
	MOVWF       _DT+1 
;APESW.c,117 :: 		if ((T2>43)&&(DT!=T2)&&(DT!=2)){          //Detecta el cambio de fase segun el resultado de la diferencia.
	MOVLW       0
	MOVWF       R0 
	MOVF        _contw+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt39
	MOVF        _contw+0, 0 
	SUBLW       43
L__Interrupt39:
	BTFSC       STATUS+0, 0 
	GOTO        L_Interrupt9
	MOVF        _DT+1, 0 
	XORWF       _T2+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt40
	MOVF        _T2+0, 0 
	XORWF       _DT+0, 0 
L__Interrupt40:
	BTFSC       STATUS+0, 2 
	GOTO        L_Interrupt9
	MOVLW       0
	XORWF       _DT+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__Interrupt41
	MOVLW       2
	XORWF       _DT+0, 0 
L__Interrupt41:
	BTFSC       STATUS+0, 2 
	GOTO        L_Interrupt9
L__Interrupt29:
;APESW.c,118 :: 		contT1 = contT;                        //Carga el contenido de la variable contT en la variable contT1.
	MOVF        _contT+0, 0 
	MOVWF       _contT1+0 
	MOVF        _contT+1, 0 
	MOVWF       _contT1+1 
;APESW.c,119 :: 		TMR1ON_bit=0;                          //Apaga el TMR1.
	BCF         TMR1ON_bit+0, BitPos(TMR1ON_bit+0) 
;APESW.c,120 :: 		contT = 0;                             //Limpia el contenido de la variable contT.
	CLRF        _contT+0 
	CLRF        _contT+1 
;APESW.c,121 :: 		RD1_bit = 0;
	BCF         RD1_bit+0, BitPos(RD1_bit+0) 
;APESW.c,122 :: 		}
L_Interrupt9:
;APESW.c,124 :: 		T1 = contw;                               //Actualiza T1 con el valor actual del contador contw.
	MOVF        _contw+0, 0 
	MOVWF       _T1+0 
	MOVF        _contw+1, 0 
	MOVWF       _T1+1 
;APESW.c,125 :: 		INTCON.INT0IF = 0;                        //Limpia la bandera de interrupcion de INT0.
	BCF         INTCON+0, 1 
;APESW.c,126 :: 		}
L_Interrupt6:
;APESW.c,128 :: 		if (TMR1IF_bit){
	BTFSS       TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
	GOTO        L_Interrupt10
;APESW.c,129 :: 		TMR1IF_bit=0;                             //Limpia la bandera de interrupcion de Timer1.
	BCF         TMR1IF_bit+0, BitPos(TMR1IF_bit+0) 
;APESW.c,130 :: 		}
L_Interrupt10:
;APESW.c,131 :: 		}
L_end_Interrupt:
L__Interrupt32:
	RETFIE      1
; end of _Interrupt

_DSRead:

;APESW.c,135 :: 		void DSRead(){
;APESW.c,140 :: 		Ow_Reset(&PORTE, 2);                                 // Onewire reset signal
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Reset_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Reset_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Reset_pin+0 
	CALL        _Ow_Reset+0, 0
;APESW.c,141 :: 		Ow_Write(&PORTE, 2, 0xCC);                           // Issue command SKIP_ROM
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Write_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Write_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Write_pin+0 
	MOVLW       204
	MOVWF       FARG_Ow_Write_data_+0 
	CALL        _Ow_Write+0, 0
;APESW.c,142 :: 		Ow_Write(&PORTE, 2, 0x44);                           // Issue command CONVERT_T
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Write_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Write_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Write_pin+0 
	MOVLW       68
	MOVWF       FARG_Ow_Write_data_+0 
	CALL        _Ow_Write+0, 0
;APESW.c,143 :: 		Delay_us(120);
	MOVLW       2
	MOVWF       R12, 0
	MOVLW       221
	MOVWF       R13, 0
L_DSRead11:
	DECFSZ      R13, 1, 1
	BRA         L_DSRead11
	DECFSZ      R12, 1, 1
	BRA         L_DSRead11
	NOP
	NOP
;APESW.c,145 :: 		Ow_Reset(&PORTE, 2);
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Reset_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Reset_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Reset_pin+0 
	CALL        _Ow_Reset+0, 0
;APESW.c,146 :: 		Ow_Write(&PORTE, 2, 0xCC);                           // Issue command SKIP_ROM
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Write_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Write_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Write_pin+0 
	MOVLW       204
	MOVWF       FARG_Ow_Write_data_+0 
	CALL        _Ow_Write+0, 0
;APESW.c,147 :: 		Ow_Write(&PORTE, 2, 0xBE);                           // Issue command READ_SCRATCHPAD
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Write_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Write_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Write_pin+0 
	MOVLW       190
	MOVWF       FARG_Ow_Write_data_+0 
	CALL        _Ow_Write+0, 0
;APESW.c,149 :: 		Temp =  Ow_Read(&PORTE, 2);
	MOVLW       PORTE+0
	MOVWF       FARG_Ow_Read_port+0 
	MOVLW       hi_addr(PORTE+0)
	MOVWF       FARG_Ow_Read_port+1 
	MOVLW       2
	MOVWF       FARG_Ow_Read_pin+0 
	CALL        _Ow_Read+0, 0
	MOVF        R0, 0 
	MOVWF       DSRead_Temp_L0+0 
	MOVLW       0
	MOVWF       DSRead_Temp_L0+1 
;APESW.c,150 :: 		Temp = (Ow_Read(&PORTE, 2) << 8) + Temp;
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
	MOVF        DSRead_Temp_L0+0, 0 
	ADDWF       R4, 0 
	MOVWF       R2 
	MOVF        DSRead_Temp_L0+1, 0 
	ADDWFC      R5, 0 
	MOVWF       R3 
	MOVF        R2, 0 
	MOVWF       DSRead_Temp_L0+0 
	MOVF        R3, 0 
	MOVWF       DSRead_Temp_L0+1 
;APESW.c,152 :: 		if (Temp & 0x8000) {
	BTFSS       R3, 7 
	GOTO        L_DSRead12
;APESW.c,153 :: 		Temp = 0;                                         // Si la temperatura es negativa la establece como cero.
	CLRF        DSRead_Temp_L0+0 
	CLRF        DSRead_Temp_L0+1 
;APESW.c,154 :: 		}
L_DSRead12:
;APESW.c,156 :: 		Rint = Temp >> 4;                                    // Extrae la parte entera de la respuesta del sensor
	MOVF        DSRead_Temp_L0+0, 0 
	MOVWF       FLOC__DSRead+4 
	MOVF        DSRead_Temp_L0+1, 0 
	MOVWF       FLOC__DSRead+5 
	RRCF        FLOC__DSRead+5, 1 
	RRCF        FLOC__DSRead+4, 1 
	BCF         FLOC__DSRead+5, 7 
	RRCF        FLOC__DSRead+5, 1 
	RRCF        FLOC__DSRead+4, 1 
	BCF         FLOC__DSRead+5, 7 
	RRCF        FLOC__DSRead+5, 1 
	RRCF        FLOC__DSRead+4, 1 
	BCF         FLOC__DSRead+5, 7 
	RRCF        FLOC__DSRead+5, 1 
	RRCF        FLOC__DSRead+4, 1 
	BCF         FLOC__DSRead+5, 7 
;APESW.c,157 :: 		Rfrac = ((Temp & 0x000F) * 625) / 10000.;            // Extrae la parte decimal de la respuesta del sensor
	MOVLW       15
	ANDWF       DSRead_Temp_L0+0, 0 
	MOVWF       R0 
	MOVF        DSRead_Temp_L0+1, 0 
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
	MOVWF       FLOC__DSRead+0 
	MOVF        R1, 0 
	MOVWF       FLOC__DSRead+1 
	MOVF        R2, 0 
	MOVWF       FLOC__DSRead+2 
	MOVF        R3, 0 
	MOVWF       FLOC__DSRead+3 
	MOVF        FLOC__DSRead+4, 0 
	MOVWF       R0 
	MOVF        FLOC__DSRead+5, 0 
	MOVWF       R1 
	CALL        _word2double+0, 0
;APESW.c,158 :: 		DSTemp = Rint + Rfrac;                               // Expresa la temperatura en punto flotante
	MOVF        FLOC__DSRead+0, 0 
	MOVWF       R4 
	MOVF        FLOC__DSRead+1, 0 
	MOVWF       R5 
	MOVF        FLOC__DSRead+2, 0 
	MOVWF       R6 
	MOVF        FLOC__DSRead+3, 0 
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
;APESW.c,159 :: 		}
L_end_DSRead:
	RETURN      0
; end of _DSRead

_Velocidad:

;APESW.c,164 :: 		void Velocidad(){
;APESW.c,165 :: 		DSRead();
	CALL        _DSRead+0, 0
;APESW.c,166 :: 		Temp = DSTemp;
	MOVF        _DSTemp+0, 0 
	MOVWF       _Temp+0 
	MOVF        _DSTemp+1, 0 
	MOVWF       _Temp+1 
	MOVF        _DSTemp+2, 0 
	MOVWF       _Temp+2 
	MOVF        _DSTemp+3, 0 
	MOVWF       _Temp+3 
;APESW.c,167 :: 		VSnd = 331.45 * sqrt(1+(Temp/273));
	MOVLW       0
	MOVWF       R4 
	MOVLW       128
	MOVWF       R5 
	MOVLW       8
	MOVWF       R6 
	MOVLW       135
	MOVWF       R7 
	MOVF        _DSTemp+0, 0 
	MOVWF       R0 
	MOVF        _DSTemp+1, 0 
	MOVWF       R1 
	MOVF        _DSTemp+2, 0 
	MOVWF       R2 
	MOVF        _DSTemp+3, 0 
	MOVWF       R3 
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
;APESW.c,168 :: 		}
L_end_Velocidad:
	RETURN      0
; end of _Velocidad

_main:

;APESW.c,171 :: 		void main() {
;APESW.c,173 :: 		INTCON.GIE = 1;                             //Habilita las interrupciones globales
	BSF         INTCON+0, 7 
;APESW.c,174 :: 		INTCON.PEIE = 1;                            //Habilita las interrupciones perifericas
	BSF         INTCON+0, 6 
;APESW.c,176 :: 		INTCON.INT0IE = 1;                          //Habilita la interrupcion externas en INT0
	BSF         INTCON+0, 4 
;APESW.c,177 :: 		INTCON2.RBPU = 1;                           //PORTB pull-ups are enabled by individual port latch values
	BSF         INTCON2+0, 7 
;APESW.c,178 :: 		INTCON2.INTEDG0 = 1;                        //Habilita la interrupcion por flanco de subida
	BSF         INTCON2+0, 6 
;APESW.c,180 :: 		ADCON1 = 0b00001111;                        //Configuracion ADCON1
	MOVLW       15
	MOVWF       ADCON1+0 
;APESW.c,181 :: 		CMCON = 0b00000111;
	MOVLW       7
	MOVWF       CMCON+0 
;APESW.c,183 :: 		T1CON=0x00;                                 //Configuracion T1CON: 16 bits, Timer1 On, Pre-escalador 1:1
	CLRF        T1CON+0 
;APESW.c,184 :: 		TMR1IE_bit = 1;                             //Habilita la interrupcion por desborde de Timer1
	BSF         TMR1IE_bit+0, BitPos(TMR1IE_bit+0) 
;APESW.c,186 :: 		T2CON = 0x04;                               //Configuracion T2CON: Post-escalador 1:1, Timer2 On, Pre-escalador 1:1
	MOVLW       4
	MOVWF       T2CON+0 
;APESW.c,187 :: 		PIE1.TMR2IE = 1;                            //Habilita la interrupcion por desborde de Timer2                        ====> La interrupcion del TMR2 interfiere con la conversion del DHT22
	BSF         PIE1+0, 1 
;APESW.c,188 :: 		PR2 = 149;                                  //Produce una interrupcion cada 12,5us
	MOVLW       149
	MOVWF       PR2+0 
;APESW.c,190 :: 		TRISD0_bit = 0;                             //Establece el pin D0 como salida
	BCF         TRISD0_bit+0, BitPos(TRISD0_bit+0) 
;APESW.c,191 :: 		TRISD1_bit = 0;                             //Establece el pin D1 como salida
	BCF         TRISD1_bit+0, BitPos(TRISD1_bit+0) 
;APESW.c,193 :: 		TRISB = 0x07;                               //Establece los pines B0, B1 y B2 como entradas
	MOVLW       7
	MOVWF       TRISB+0 
;APESW.c,195 :: 		RD0_bit = 0;                                //Limpia el pin D0
	BCF         RD0_bit+0, BitPos(RD0_bit+0) 
;APESW.c,196 :: 		RD1_bit = 0;                                //Limpia el pin D1
	BCF         RD1_bit+0, BitPos(RD1_bit+0) 
;APESW.c,197 :: 		PORTB = 0;                                  //Limpia el puerto B
	CLRF        PORTB+0 
;APESW.c,199 :: 		punT1 = &contT;                             //Asocia el puntero punT1 con la direccion de memoria de la variable contT de tipo entero
	MOVLW       _contT+0
	MOVWF       _punT1+0 
	MOVLW       hi_addr(_contT+0)
	MOVWF       _punT1+1 
;APESW.c,200 :: 		punDt = &Di;                                //Asocia el puntero punDt con la direccion de memoria de la variable Di de tipo entero
	MOVLW       _Di+0
	MOVWF       _punDt+0 
	MOVLW       hi_addr(_Di+0)
	MOVWF       _punDt+1 
;APESW.c,202 :: 		contw = 0;                                  //Limpia todas las variables
	CLRF        _contw+0 
	CLRF        _contw+1 
;APESW.c,203 :: 		contT1 = 0;
	CLRF        _contT1+0 
	CLRF        _contT1+1 
;APESW.c,204 :: 		BS = 0;
	CLRF        _BS+0 
;APESW.c,205 :: 		FP = 0;
	CLRF        _FP+0 
;APESW.c,206 :: 		T1 = 0;
	CLRF        _T1+0 
	CLRF        _T1+1 
;APESW.c,207 :: 		T2 = 0;
	CLRF        _T2+0 
	CLRF        _T2+1 
;APESW.c,208 :: 		TOF = 0;
	CLRF        _TOF+0 
	CLRF        _TOF+1 
	CLRF        _TOF+2 
	CLRF        _TOF+3 
;APESW.c,209 :: 		Di = 0;
	CLRF        _Di+0 
	CLRF        _Di+1 
;APESW.c,211 :: 		Rspt[0] = Hdr;
	MOVLW       32
	MOVWF       _Rspt+0 
;APESW.c,212 :: 		Rspt[1] = idSlv;
	MOVLW       49
	MOVWF       _Rspt+1 
;APESW.c,213 :: 		Rspt[4] = End;
	MOVLW       13
	MOVWF       _Rspt+4 
;APESW.c,215 :: 		Lcd_init();                                 //Inicializa el LCD
	CALL        _Lcd_Init+0, 0
;APESW.c,216 :: 		Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,217 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,219 :: 		UART1_Init(9600);                           // Inicializa el UART a 9600 bps
	BSF         BAUDCON+0, 3, 0
	MOVLW       4
	MOVWF       SPBRGH+0 
	MOVLW       225
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;APESW.c,220 :: 		Delay_ms(100);                              // Wait for UART module to stabilize
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_main13:
	DECFSZ      R13, 1, 1
	BRA         L_main13
	DECFSZ      R12, 1, 1
	BRA         L_main13
	DECFSZ      R11, 1, 1
	BRA         L_main13
	NOP
;APESW.c,222 :: 		while (1){
L_main14:
;APESW.c,224 :: 		Velocidad();                          //Invoca la funcion para calcular la Velocidad del sonido
	CALL        _Velocidad+0, 0
;APESW.c,226 :: 		TOF = (contT1)*(4./48);               //Calcula el valor de TOF
	MOVF        _contT1+0, 0 
	MOVWF       R0 
	MOVF        _contT1+1, 0 
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
;APESW.c,227 :: 		Df = (VSnd * TOF ) / 2000;            //Calcula la distancia en funcion del TOF
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
;APESW.c,228 :: 		Di = Df*10;                           //Almacena la distancia en una variable de tipo entero
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
;APESW.c,230 :: 		for (i=2;i<4;i++){                    //Rellena la trama de cuerpo de datos de 4 bytes
	MOVLW       2
	MOVWF       _i+0 
L_main16:
	MOVLW       4
	SUBWF       _i+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main17
;APESW.c,231 :: 		Rspt[i]=(*punDt++);               //El operador * permite acceder al valor de la direccion del puntero,
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
;APESW.c,230 :: 		for (i=2;i<4;i++){                    //Rellena la trama de cuerpo de datos de 4 bytes
	INCF        _i+0, 1 
;APESW.c,232 :: 		}
	GOTO        L_main16
L_main17:
;APESW.c,234 :: 		FloatToStr(Temp, txt1);
	MOVF        _Temp+0, 0 
	MOVWF       FARG_FloatToStr_fnum+0 
	MOVF        _Temp+1, 0 
	MOVWF       FARG_FloatToStr_fnum+1 
	MOVF        _Temp+2, 0 
	MOVWF       FARG_FloatToStr_fnum+2 
	MOVF        _Temp+3, 0 
	MOVWF       FARG_FloatToStr_fnum+3 
	MOVLW       _txt1+0
	MOVWF       FARG_FloatToStr_str+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_FloatToStr_str+1 
	CALL        _FloatToStr+0, 0
;APESW.c,235 :: 		FloatToStr(Vsnd, txt2);                   //Convierte el valor de la distancia en string
	MOVF        _VSnd+0, 0 
	MOVWF       FARG_FloatToStr_fnum+0 
	MOVF        _VSnd+1, 0 
	MOVWF       FARG_FloatToStr_fnum+1 
	MOVF        _VSnd+2, 0 
	MOVWF       FARG_FloatToStr_fnum+2 
	MOVF        _VSnd+3, 0 
	MOVWF       FARG_FloatToStr_fnum+3 
	MOVLW       _txt2+0
	MOVWF       FARG_FloatToStr_str+0 
	MOVLW       hi_addr(_txt2+0)
	MOVWF       FARG_FloatToStr_str+1 
	CALL        _FloatToStr+0, 0
;APESW.c,237 :: 		if (DHTvalue == 0x63636363){
	MOVF        _DHTvalue+3, 0 
	XORLW       99
	BTFSS       STATUS+0, 2 
	GOTO        L__main45
	MOVF        _DHTvalue+2, 0 
	XORLW       99
	BTFSS       STATUS+0, 2 
	GOTO        L__main45
	MOVF        _DHTvalue+1, 0 
	XORLW       99
	BTFSS       STATUS+0, 2 
	GOTO        L__main45
	MOVF        _DHTvalue+0, 0 
	XORLW       99
L__main45:
	BTFSS       STATUS+0, 2 
	GOTO        L_main19
;APESW.c,238 :: 		Lcd_Out(1, 1, "  No response   ");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,239 :: 		}
L_main19:
;APESW.c,240 :: 		if (DHTvalue == 0x58585858){
	MOVF        _DHTvalue+3, 0 
	XORLW       88
	BTFSS       STATUS+0, 2 
	GOTO        L__main46
	MOVF        _DHTvalue+2, 0 
	XORLW       88
	BTFSS       STATUS+0, 2 
	GOTO        L__main46
	MOVF        _DHTvalue+1, 0 
	XORLW       88
	BTFSS       STATUS+0, 2 
	GOTO        L__main46
	MOVF        _DHTvalue+0, 0 
	XORLW       88
L__main46:
	BTFSS       STATUS+0, 2 
	GOTO        L_main20
;APESW.c,241 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;APESW.c,242 :: 		Lcd_Out(1, 1, "Check sum error ");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,243 :: 		} else if ((DHTvalue != 0x63636363) && (DHTvalue != 0x58585858)){
	GOTO        L_main21
L_main20:
	MOVF        _DHTvalue+3, 0 
	XORLW       99
	BTFSS       STATUS+0, 2 
	GOTO        L__main47
	MOVF        _DHTvalue+2, 0 
	XORLW       99
	BTFSS       STATUS+0, 2 
	GOTO        L__main47
	MOVF        _DHTvalue+1, 0 
	XORLW       99
	BTFSS       STATUS+0, 2 
	GOTO        L__main47
	MOVF        _DHTvalue+0, 0 
	XORLW       99
L__main47:
	BTFSC       STATUS+0, 2 
	GOTO        L_main24
	MOVF        _DHTvalue+3, 0 
	XORLW       88
	BTFSS       STATUS+0, 2 
	GOTO        L__main48
	MOVF        _DHTvalue+2, 0 
	XORLW       88
	BTFSS       STATUS+0, 2 
	GOTO        L__main48
	MOVF        _DHTvalue+1, 0 
	XORLW       88
	BTFSS       STATUS+0, 2 
	GOTO        L__main48
	MOVF        _DHTvalue+0, 0 
	XORLW       88
L__main48:
	BTFSC       STATUS+0, 2 
	GOTO        L_main24
L__main30:
;APESW.c,244 :: 		Lcd_Out(1,1,"Tmp: ");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr3_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr3_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,245 :: 		Lcd_Out_Cp(txt1);
	MOVLW       _txt1+0
	MOVWF       FARG_Lcd_Out_CP_text+0 
	MOVLW       hi_addr(_txt1+0)
	MOVWF       FARG_Lcd_Out_CP_text+1 
	CALL        _Lcd_Out_CP+0, 0
;APESW.c,246 :: 		}
L_main24:
L_main21:
;APESW.c,248 :: 		Lcd_Out(2,1,"Vel: ");
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr4_APESW+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr4_APESW+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;APESW.c,249 :: 		Lcd_Out_Cp(txt2);                     //Visualiza el valor del TOF en el LCD*/
	MOVLW       _txt2+0
	MOVWF       FARG_Lcd_Out_CP_text+0 
	MOVLW       hi_addr(_txt2+0)
	MOVWF       FARG_Lcd_Out_CP_text+1 
	CALL        _Lcd_Out_CP+0, 0
;APESW.c,251 :: 		for (j=0;j<=4;j++){
	CLRF        _j+0 
L_main25:
	MOVF        _j+0, 0 
	SUBLW       4
	BTFSS       STATUS+0, 0 
	GOTO        L_main26
;APESW.c,252 :: 		UART1_Write(Rspt[j]);             //Visualiza la trama recibida en el LCD
	MOVLW       _Rspt+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_Rspt+0)
	MOVWF       FSR0H 
	MOVF        _j+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;APESW.c,251 :: 		for (j=0;j<=4;j++){
	INCF        _j+0, 1 
;APESW.c,253 :: 		}
	GOTO        L_main25
L_main26:
;APESW.c,255 :: 		delay_ms(1);
	MOVLW       16
	MOVWF       R12, 0
	MOVLW       148
	MOVWF       R13, 0
L_main28:
	DECFSZ      R13, 1, 1
	BRA         L_main28
	DECFSZ      R12, 1, 1
	BRA         L_main28
	NOP
;APESW.c,257 :: 		}
	GOTO        L_main14
;APESW.c,258 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
