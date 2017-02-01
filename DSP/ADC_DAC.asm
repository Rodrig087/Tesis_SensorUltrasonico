
_Velocidad:
	LNK	#4

;ADC_DAC.c,73 :: 		void Velocidad(){
;ADC_DAC.c,78 :: 		Ow_Reset(&PORTA, 1);                        //Onewire reset signal
	PUSH	W10
	PUSH	W11
	PUSH	W12
	MOV	#1, W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;ADC_DAC.c,79 :: 		Ow_Write(&PORTA, 1, 0xCC);                  //Issue command SKIP_ROM
	MOV.B	#204, W12
	MOV	#1, W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,80 :: 		Ow_Write(&PORTA, 1, 0x44);                  //Issue command CONVERT_T
	MOV.B	#68, W12
	MOV	#1, W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,81 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad0:
	DEC	W7
	BRA NZ	L_Velocidad0
	NOP
;ADC_DAC.c,83 :: 		Ow_Reset(&PORTA, 1);
	MOV	#1, W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;ADC_DAC.c,84 :: 		Ow_Write(&PORTA, 1, 0xCC);                  //Issue command SKIP_ROM
	MOV.B	#204, W12
	MOV	#1, W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,85 :: 		Ow_Write(&PORTA, 1, 0xBE);                  //Issue command READ_SCRATCHPAD
	MOV.B	#190, W12
	MOV	#1, W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,86 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad2:
	DEC	W7
	BRA NZ	L_Velocidad2
	NOP
;ADC_DAC.c,88 :: 		Temp =  Ow_Read(&PORTA, 1);
	MOV	#1, W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
; Temp start address is: 10 (W5)
	ZE	W0, W5
;ADC_DAC.c,89 :: 		Temp = (Ow_Read(&PORTA, 1) << 8) + Temp;
	MOV	#1, W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
	ZE	W0, W0
	SL	W0, #8, W0
	ADD	W0, W5, W0
; Temp end address is: 10 (W5)
; Temp start address is: 4 (W2)
	MOV	W0, W2
;ADC_DAC.c,91 :: 		if (Temp & 0x8000) {
	BTSS	W0, #15
	GOTO	L__Velocidad24
;ADC_DAC.c,92 :: 		Temp = 0;                                //Si la temperatura es negativa la establece como cero.
	CLR	W2
; Temp end address is: 4 (W2)
;ADC_DAC.c,93 :: 		}
	GOTO	L_Velocidad4
L__Velocidad24:
;ADC_DAC.c,91 :: 		if (Temp & 0x8000) {
;ADC_DAC.c,93 :: 		}
L_Velocidad4:
;ADC_DAC.c,95 :: 		Rint = Temp >> 4;                           //Extrae la parte entera de la respuesta del sensor
; Temp start address is: 4 (W2)
	LSR	W2, #4, W0
; Rint start address is: 6 (W3)
	MOV	W0, W3
;ADC_DAC.c,96 :: 		Rfrac = ((Temp & 0x000F) * 625) / 10000.;   //Extrae la parte decimal de la respuesta del sensor
	AND	W2, #15, W1
; Temp end address is: 4 (W2)
	MOV	#625, W0
	MUL.UU	W1, W0, W0
	PUSH	W3
	CLR	W1
	CALL	__Long2Float
	MOV	#16384, W2
	MOV	#17948, W3
	CALL	__Div_FP
	POP	W3
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
;ADC_DAC.c,97 :: 		DSTemp = Rint + Rfrac;
	MOV	W3, W0
	CLR	W1
	CALL	__Long2Float
; Rint end address is: 6 (W3)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	MOV	W0, _DSTemp
	MOV	W1, _DSTemp+2
;ADC_DAC.c,99 :: 		VSnd = 331.45 * sqrt(1+(DsTemp/273));       //Expresa la temperatura en punto flotante
	MOV	#32768, W2
	MOV	#17288, W3
	CALL	__Div_FP
	MOV	#0, W2
	MOV	#16256, W3
	CALL	__AddSub_FP
	MOV.D	W0, W10
	CALL	_sqrt
	MOV	#47514, W2
	MOV	#17317, W3
	CALL	__Mul_FP
	MOV	W0, _VSnd
	MOV	W1, _VSnd+2
;ADC_DAC.c,100 :: 		}
L_end_Velocidad:
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _Velocidad

_Ext_interrupt0:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,105 :: 		void Ext_interrupt0() iv IVT_ADDR_INT0INTERRUPT{
;ADC_DAC.c,106 :: 		*(puntT1) = TMR2;                              //Almacena el valor de TMR2 en la palabra menos significativa de la variable T1_e
	MOV	_puntT1, W1
	MOV	TMR2, WREG
	MOV	W0, [W1]
;ADC_DAC.c,107 :: 		*(puntT1+1) = TMR3HLD;                            //Almacena el valor de TMR3HLD en la palabra mas significativa de la variable T1_e
	MOV	_puntT1, W0
	ADD	W0, #2, W1
	MOV	TMR3HLD, WREG
	MOV	W0, [W1]
;ADC_DAC.c,108 :: 		TMR3HLD = 0;
	CLR	TMR3HLD
;ADC_DAC.c,109 :: 		TMR2 = 0;
	CLR	TMR2
;ADC_DAC.c,110 :: 		LATA4_bit = ~LATA4_bit;
	BTG	LATA4_bit, BitPos(LATA4_bit+0)
;ADC_DAC.c,111 :: 		IEC0.T1IE = 1;                                //Habilita la interrupcion por desborde del TMR1 para dar inicio al muestreo del ADC
	BSET	IEC0, #3
;ADC_DAC.c,112 :: 		TMR1 = 0;                                     //Encera el TMR1
	CLR	TMR1
;ADC_DAC.c,113 :: 		T1CON.TON = 1;                                //Enciende el TMR1
	BSET	T1CON, #15
;ADC_DAC.c,114 :: 		INT0IF_bit = 0;                               //Limpia la bandera de interrupcion de INT0
	BCLR	INT0IF_bit, BitPos(INT0IF_bit+0)
;ADC_DAC.c,115 :: 		IEC0.INT0IE = 0;                              //Desabilita la interrupcion externa Int0
	BCLR	IEC0, #0
;ADC_DAC.c,116 :: 		T2CON.TON = 0;                                //Apaga el TMR2
	BCLR	T2CON, #15
;ADC_DAC.c,117 :: 		}
L_end_Ext_interrupt0:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _Ext_interrupt0

_ADC1Int:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,119 :: 		void ADC1Int() org IVT_ADDR_ADC1INTERRUPT {
;ADC_DAC.c,120 :: 		if (i<nm){
	MOV	_i, W1
	MOV	#260, W0
	CP	W1, W0
	BRA LTU	L__ADC1Int28
	GOTO	L_ADC1Int5
L__ADC1Int28:
;ADC_DAC.c,121 :: 		M[i] = ADC1BUF0;                           //Almacena el valor actual de la conversion del ADC en el vector M
	MOV	_i, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	ADC1BUF0, WREG
	MOV	W0, [W1]
;ADC_DAC.c,122 :: 		i++;                                       //Aumenta en 1 el subindice del vector de Muestras
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,123 :: 		} else {
	GOTO	L_ADC1Int6
L_ADC1Int5:
;ADC_DAC.c,124 :: 		bm = 1;                                    //Cambia el valor de la bandera bm para terminar con el muestreo y dar comienzo al procesamiento de la se�al
	MOV	#lo_addr(_bm), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,125 :: 		T1CON.TON = 0;                             //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,126 :: 		IEC0.T1IE = 0;                             //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,127 :: 		}
L_ADC1Int6:
;ADC_DAC.c,128 :: 		AD1IF_bit = 0;                                //Limpia la bandera de interrupcion del ADC
	BCLR	AD1IF_bit, BitPos(AD1IF_bit+0)
;ADC_DAC.c,129 :: 		}
L_end_ADC1Int:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _ADC1Int

_Timer1Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,131 :: 		void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
;ADC_DAC.c,132 :: 		if (bm==0){                                   //Cuando la bandera bm=0, la interrupcion por TMR1 es utilizada para el muestreo de la se�al de entrada
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__Timer1Interrupt30
	GOTO	L_Timer1Interrupt7
L__Timer1Interrupt30:
;ADC_DAC.c,133 :: 		SAMP_bit = 0;                              //Limpia el bit SAMP para iniciar la conversion del ADC
	BCLR	SAMP_bit, BitPos(SAMP_bit+0)
;ADC_DAC.c,134 :: 		}
L_Timer1Interrupt7:
;ADC_DAC.c,135 :: 		T1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,136 :: 		}
L_end_Timer1Interrupt:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _Timer1Interrupt

_Timer2Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,138 :: 		void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
;ADC_DAC.c,139 :: 		if (contp<10){                                //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (
	MOV	_contp, W0
	CP	W0, #10
	BRA LTU	L__Timer2Interrupt32
	GOTO	L_Timer2Interrupt8
L__Timer2Interrupt32:
;ADC_DAC.c,140 :: 		RB14_bit = ~RB14_bit;                    //Conmuta el valor del pin RB14
	BTG	RB14_bit, BitPos(RB14_bit+0)
;ADC_DAC.c,141 :: 		}else {
	GOTO	L_Timer2Interrupt9
L_Timer2Interrupt8:
;ADC_DAC.c,142 :: 		RB14_bit = 0;                            //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCLR	RB14_bit, BitPos(RB14_bit+0)
;ADC_DAC.c,144 :: 		IEC0.INT0IE = 1;                         //Habilita la interrupcion externa INT0
	BSET	IEC0, #0
;ADC_DAC.c,145 :: 		INT0IF_bit = 0;                          //Limpia la bandera de interrupcion de INT0
	BCLR	INT0IF_bit, BitPos(INT0IF_bit+0)
;ADC_DAC.c,146 :: 		IEC0.AD1IE = 1;                          //Habilita la interrupcion por conversion completa del ADC
	BSET	IEC0, #13
;ADC_DAC.c,148 :: 		T3CON.TON = 0;                           //Apaga el TMR3
	BCLR	T3CON, #15
;ADC_DAC.c,149 :: 		T2CON.TON = 0;                           //Apaga el TMR2
	BCLR	T2CON, #15
;ADC_DAC.c,150 :: 		T2CON.T32 = 1;                           //Enable 32-bit Timer mode
	BSET	T2CON, #3
;ADC_DAC.c,151 :: 		T2CON.TCS = 0;                           //Select internal instruction cycle clock
	BCLR	T2CON, #1
;ADC_DAC.c,152 :: 		T2CON.TGATE = 0;                         //Disable Gated Timer mode
	BCLR	T2CON, #6
;ADC_DAC.c,153 :: 		T2CONbits.TCKPS = 0b00;                  //Select 1:1 Prescaler
	MOV	#lo_addr(T2CONbits), W0
	MOV.B	[W0], W1
	MOV.B	#207, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(T2CONbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,154 :: 		TMR3 = 0;                                //Limpia el MSW del contador de 32-bit
	CLR	TMR3
;ADC_DAC.c,155 :: 		TMR2 = 0;                                //Limpia el LSW del contador de 32-bit
	CLR	TMR2
;ADC_DAC.c,159 :: 		PR3 = 0xFFFF;                            // Load 32-bit period value (msw)
	MOV	#65535, W0
	MOV	WREG, PR3
;ADC_DAC.c,160 :: 		PR2 = 0xFFFF;                            // Load 32-bit period value (lsw)
	MOV	#65535, W0
	MOV	WREG, PR2
;ADC_DAC.c,162 :: 		T2CON.TON = 1;                           //Inicializa el contador de 32 bits
	BSET	T2CON, #15
;ADC_DAC.c,164 :: 		LATA4_bit = ~LATA4_bit;
	BTG	LATA4_bit, BitPos(LATA4_bit+0)
;ADC_DAC.c,165 :: 		}
L_Timer2Interrupt9:
;ADC_DAC.c,166 :: 		contp++;                                      //Aumenta el contador en una unidad.
	MOV	#1, W1
	MOV	#lo_addr(_contp), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,167 :: 		T2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,168 :: 		}
L_end_Timer2Interrupt:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _Timer2Interrupt

_Configuracion:

;ADC_DAC.c,172 :: 		void Configuracion(){
;ADC_DAC.c,175 :: 		CLKDIVbits.PLLPRE = 0;                      //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,176 :: 		PLLFBD = 38;                                //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
	MOV	#38, W0
	MOV	WREG, PLLFBD
;ADC_DAC.c,177 :: 		CLKDIVbits.PLLPOST = 0;                     //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,180 :: 		AD1PCFGL = 0xFFFE;                          //Configura el puerto AN0 como entrada analogica y todas las demas como digitales
	MOV	#65534, W0
	MOV	WREG, AD1PCFGL
;ADC_DAC.c,181 :: 		TRISA0_bit = 1;                             //Set RA0 pin as input
	BSET	TRISA0_bit, BitPos(TRISA0_bit+0)
;ADC_DAC.c,183 :: 		TRISA4_bit = 0;                             //Set RA4 pin as output
	BCLR	TRISA4_bit, BitPos(TRISA4_bit+0)
;ADC_DAC.c,184 :: 		TRISB14_bit = 0;                            //Set RB14 pin as output
	BCLR	TRISB14_bit, BitPos(TRISB14_bit+0)
;ADC_DAC.c,185 :: 		TRISB7_bit = 1;                             //Set RB7 pin as input
	BSET	TRISB7_bit, BitPos(TRISB7_bit+0)
;ADC_DAC.c,188 :: 		AD1CON1.AD12B = 0;                          //Configura el ADC en modo de 10 bits
	BCLR	AD1CON1, #10
;ADC_DAC.c,189 :: 		AD1CON1bits.FORM = 0x00;                    //Formato de la canversion: 00->(0_1023)|01->(-512_511)|02->(0_0.999)|03->(-1_0.999)
	MOV	AD1CON1bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON1bits
;ADC_DAC.c,190 :: 		AD1CON1.SIMSAM = 0;                         //0 -> Muestrea m�ltiples canales individualmente en secuencia
	BCLR	AD1CON1, #3
;ADC_DAC.c,191 :: 		AD1CON1.ADSIDL = 0;                         //Continua con la operacion del modulo durante el modo desocupado
	BCLR	AD1CON1, #13
;ADC_DAC.c,192 :: 		AD1CON1.ASAM = 1;                           //Muestreo automatico
	BSET	AD1CON1, #2
;ADC_DAC.c,193 :: 		AD1CON1bits.SSRC = 0x00;                    //Conversion manual
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	[W0], W1
	MOV.B	#31, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,195 :: 		AD1CON2bits.VCFG = 0;                       //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
	MOV	AD1CON2bits, W1
	MOV	#8191, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,196 :: 		AD1CON2bits.CHPS = 0;                       //Selecciona unicamente el canal CH0
	MOV	AD1CON2bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,197 :: 		AD1CON2.CSCNA = 0;                          //No escanea las entradas de CH0 durante la Muestra A
	BCLR	AD1CON2, #10
;ADC_DAC.c,198 :: 		AD1CON2bits.SMPI = 0x00;                    //Numero de secuencias de muestreo/conversion por interrupcion (N+1)
	MOV	#lo_addr(AD1CON2bits), W0
	MOV.B	[W0], W1
	MOV.B	#195, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON2bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,199 :: 		AD1CON2.BUFM = 0;                           //Bit de selecci�n del modo de relleno del b�fer, 0 -> Siempre comienza a llenar el buffer desde el principio
	BCLR	AD1CON2, #1
;ADC_DAC.c,200 :: 		AD1CON2.ALTS = 0x00;                        //Utiliza siempre la selecci�n de entrada de canal para la muestra A
	BCLR	AD1CON2, #0
;ADC_DAC.c,202 :: 		AD1CON3.ADRC = 0;                           //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
	BCLR	AD1CON3, #15
;ADC_DAC.c,203 :: 		AD1CON3bits.ADCS = 0x02;                    //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
	MOV.B	#2, W0
	MOV.B	W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR.B	W1, [W0], W1
	MOV.B	#255, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(AD1CON3bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,204 :: 		AD1CON3bits.SAMC = 0x02;                    //Auto Sample Time bits, 2 -> 2*TAD (minimo periodo de muestreo para 10 bits)
	MOV	#512, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CON3bits
;ADC_DAC.c,206 :: 		AD1CHS0 = 0;                                //ADC1 INPUT CHANNEL 0 SELECT REGISTER
	CLR	AD1CHS0
;ADC_DAC.c,207 :: 		AD1CHS123 = 0;                              //AD1CHS123: ADC1 INPUT CHANNEL 1, 2, 3 SELECT REGISTER
	CLR	AD1CHS123
;ADC_DAC.c,209 :: 		AD1CSSL = 0x00;                             //Se salta todos los puertos ANx para los escaneos de entrada
	CLR	AD1CSSL
;ADC_DAC.c,213 :: 		AD1CON1.ADON = 1;                           //Enciende el modulo ADC
	BSET	AD1CON1, #15
;ADC_DAC.c,216 :: 		T1CON = 0x8000;                             //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T1CON
;ADC_DAC.c,217 :: 		IEC0.T1IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR1 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #3
;ADC_DAC.c,218 :: 		T1IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,219 :: 		PR1 = 200;                                  //Genera una interrupcion cada 5us (Fs=200KHz)
	MOV	#200, W0
	MOV	WREG, PR1
;ADC_DAC.c,222 :: 		T2CON = 0x8000;                             //Habilita el TMR2, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T2CON
;ADC_DAC.c,223 :: 		IEC0.T2IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR2 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #7
;ADC_DAC.c,224 :: 		T2IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,227 :: 		INTCON2.INT0EP = 0;                         //Interrupcion en flanco positivo
	BCLR	INTCON2, #0
;ADC_DAC.c,230 :: 		IPC3bits.AD1IP = 0x06;                      //Nivel de prioridad de interrupcion del ADC
	MOV.B	#96, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC3bits), W0
	XOR.B	W1, [W0], W1
	MOV.B	#112, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(IPC3bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC3bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,231 :: 		IPC0bits.T1IP = 0x07;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR1
	MOV	IPC0bits, W1
	MOV	#28672, W0
	IOR	W1, W0, W0
	MOV	WREG, IPC0bits
;ADC_DAC.c,232 :: 		IPC1bits.T2IP = 0x05;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR2
	MOV	#20480, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;ADC_DAC.c,233 :: 		IPC0bits.INT0IP = 0x04;                     //Nivel de prioridad de la interrupcion INT0
	MOV.B	#4, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #7, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC0bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,235 :: 		}
L_end_Configuracion:
	RETURN
; end of _Configuracion

_main:
	MOV	#2048, W15
	MOV	#6142, W0
	MOV	WREG, 32
	MOV	#1, W0
	MOV	WREG, 52
	MOV	#4, W0
	IOR	68
	LNK	#12

;ADC_DAC.c,239 :: 		void main() {
;ADC_DAC.c,241 :: 		Configuracion();
	PUSH	W10
	PUSH	W11
	PUSH	W12
	CALL	_Configuracion
;ADC_DAC.c,243 :: 		puntT1 = &T1_e;                             //Asocia el puntero "puntT1" con la direccion de memoria de la variable T1_e de tipo long
	MOV	#lo_addr(_T1_e), W0
	MOV	W0, _puntT1
;ADC_DAC.c,245 :: 		Lcd_init();                                 //Inicializa el LCD
	CALL	_Lcd_Init
;ADC_DAC.c,246 :: 		Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
	MOV.B	#1, W10
	CALL	_Lcd_Cmd
;ADC_DAC.c,247 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD
	MOV.B	#12, W10
	CALL	_Lcd_Cmd
;ADC_DAC.c,249 :: 		while(1){
L_main10:
;ADC_DAC.c,252 :: 		if (bm==0){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__main35
	GOTO	L_main12
L__main35:
;ADC_DAC.c,254 :: 		contp = 0;                                               //Limpia la variable del contador de pulsos
	CLR	W0
	MOV	W0, _contp
;ADC_DAC.c,255 :: 		RB14_bit = 0;                                            //Limpia el pin que produce los pulsos de exitacion del transductor
	BCLR	RB14_bit, BitPos(RB14_bit+0)
;ADC_DAC.c,256 :: 		T2CON.TON = 0;                                           //Apaga el TMR2
	BCLR	T2CON, #15
;ADC_DAC.c,257 :: 		T2CON = 0x0000;                                          //Configura el contador en modo de 16 bits
	CLR	T2CON
;ADC_DAC.c,258 :: 		TMR2 = 0;                                                //Encera el TMR2
	CLR	TMR2
;ADC_DAC.c,259 :: 		PR2 = 500;                                               //Genera una interrupcion cada 12.5us
	MOV	#500, W0
	MOV	WREG, PR2
;ADC_DAC.c,260 :: 		IEC0.T2IE = 1;                                           //Habilita la interrupcion por desborde del TMR2
	BSET	IEC0, #7
;ADC_DAC.c,261 :: 		T2CON.TON = 1;                                           //Enciende el TMR2
	BSET	T2CON, #15
;ADC_DAC.c,263 :: 		i = 0;                                                   //Limpia las variables asociadas al almacenamiento de la se�al muestreada
	CLR	W0
	MOV	W0, _i
;ADC_DAC.c,264 :: 		j = 0;
	CLR	W0
	MOV	W0, _j
;ADC_DAC.c,266 :: 		}
L_main12:
;ADC_DAC.c,269 :: 		if (bm==1){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__main36
	GOTO	L_main13
L__main36:
;ADC_DAC.c,271 :: 		for (k=0;k<nm;k++){
	CLR	W0
	MOV	W0, _k
L_main14:
	MOV	_k, W1
	MOV	#260, W0
	CP	W1, W0
	BRA LTU	L__main37
	GOTO	L_main15
L__main37:
;ADC_DAC.c,274 :: 		value = M[k]&0x01FF;                                 //Establece los datos en mod 512
	MOV	_k, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W3
	MOV	[W3], W2
	MOV	#511, W1
	MOV	#lo_addr(_value), W0
	AND	W2, W1, [W0]
;ADC_DAC.c,275 :: 		if (M[k]<512){
	MOV	[W3], W1
	MOV	#512, W0
	CP	W1, W0
	BRA LTU	L__main38
	GOTO	L_main17
L__main38:
;ADC_DAC.c,276 :: 		value = (M[k]+((512-M[k])*2))&0x01FE;             //Invierte la se�al y establece los datos en mod 511
	MOV	_k, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	#512, W0
	SUB	W0, [W1], W0
	SL	W0, #1, W0
	ADD	W0, [W1], W2
	MOV	#510, W1
	MOV	#lo_addr(_value), W0
	AND	W2, W1, [W0]
;ADC_DAC.c,277 :: 		}
L_main17:
;ADC_DAC.c,280 :: 		x0 = (float)(value);                                 //Adquisici�n de una muestra de 10 bits en, x[0].
	MOV	_value, W0
	CLR	W1
	CALL	__Long2Float
	MOV	W0, _x0
	MOV	W1, _x0+2
;ADC_DAC.c,281 :: 		y0 = ((x0+x2)*ca1)+(x1*ca2)-(y1*cb2)-(y2*cb3);       //Implementaci�n de la ecuaci�n en diferencias
	MOV	_x2, W2
	MOV	_x2+2, W3
	CALL	__AddSub_FP
	MOV	#34034, W2
	MOV	#15324, W3
	CALL	__Mul_FP
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	_x1, W0
	MOV	_x1+2, W1
	MOV	#34034, W2
	MOV	#15452, W3
	CALL	__Mul_FP
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	_y1, W0
	MOV	_y1+2, W1
	MOV	#41118, W2
	MOV	#49120, W3
	CALL	__Mul_FP
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	[W14+4], W0
	MOV	[W14+6], W1
	PUSH.D	W2
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__Sub_FP
	POP.D	W2
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	_y2, W0
	MOV	_y2+2, W1
	MOV	#9572, W2
	MOV	#16200, W3
	CALL	__Mul_FP
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	[W14+4], W0
	MOV	[W14+6], W1
	PUSH.D	W2
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__Sub_FP
	POP.D	W2
	MOV	W0, _y0
	MOV	W1, _y0+2
;ADC_DAC.c,283 :: 		y2 = y1;                                             //Corrimiento de los valores x(n), y y(n).
	MOV	_y1, W2
	MOV	_y1+2, W3
	MOV	W2, _y2
	MOV	W3, _y2+2
;ADC_DAC.c,284 :: 		y1 = y0;
	MOV	W0, _y1
	MOV	W1, _y1+2
;ADC_DAC.c,285 :: 		x2 = x1;
	MOV	_x1, W2
	MOV	_x1+2, W3
	MOV	W2, _x2
	MOV	W3, _x2+2
;ADC_DAC.c,286 :: 		x1 = x0;
	MOV	_x0, W2
	MOV	_x0+2, W3
	MOV	W2, _x1
	MOV	W3, _x1+2
;ADC_DAC.c,288 :: 		YY = (unsigned int)(y0);                             //Reconstrucci�n de la se�al: y en 10 bits.
	CALL	__Float2Longint
	MOV	W0, _YY
;ADC_DAC.c,289 :: 		R[k] = YY;
	MOV	_k, W1
	SL	W1, #1, W2
	MOV	#lo_addr(_R), W1
	ADD	W1, W2, W1
	MOV	W0, [W1]
;ADC_DAC.c,291 :: 		bm = 2;                                              //Cambia el estado de la bandera bm para dar paso al c�lculo del pmax y TOF
	MOV	#lo_addr(_bm), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,271 :: 		for (k=0;k<nm;k++){
	MOV	#1, W1
	MOV	#lo_addr(_k), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,293 :: 		}
	GOTO	L_main14
L_main15:
;ADC_DAC.c,295 :: 		}
L_main13:
;ADC_DAC.c,298 :: 		if (bm==2){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__main39
	GOTO	L_main18
L__main39:
;ADC_DAC.c,300 :: 		DSTemp = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _DSTemp
	MOV	W1, _DSTemp+2
;ADC_DAC.c,301 :: 		VSnd = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _VSnd
	MOV	W1, _VSnd+2
;ADC_DAC.c,302 :: 		Velocidad();                                                //Llama a la funcion para calcular la Velocidad del sonido
	CALL	_Velocidad
;ADC_DAC.c,304 :: 		yy0 = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _yy0
	MOV	W1, _yy0+2
;ADC_DAC.c,305 :: 		yy1 = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _yy1
	MOV	W1, _yy1+2
;ADC_DAC.c,306 :: 		yy2 = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _yy2
	MOV	W1, _yy2+2
;ADC_DAC.c,307 :: 		nx = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _nx
	MOV	W1, _nx+2
;ADC_DAC.c,308 :: 		dx = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _dx
	MOV	W1, _dx+2
;ADC_DAC.c,310 :: 		yy1 = Vector_Max(R, nm, &maxIndex);                         //Encuentra el valor maximo del vector R
	MOV	#lo_addr(_maxIndex), W0
	PUSH	W0
	MOV	#260, W0
	PUSH	W0
	MOV	#lo_addr(_R), W0
	PUSH	W0
	CALL	_Vector_Max
	SUB	#6, W15
	CLR	W1
	CALL	__Long2Float
	MOV	W0, [W14+8]
	MOV	W1, [W14+10]
	MOV	W0, _yy1
	MOV	W1, _yy1+2
;ADC_DAC.c,311 :: 		i1 = maxIndex;                                              //Asigna el subindice del valor maximo a la variable i1
	MOV	_maxIndex, W0
	MOV	W0, _i1
;ADC_DAC.c,312 :: 		i0 = i1 - 10;
	MOV	_maxIndex, W0
	SUB	W0, #10, W1
	MOV	W1, _i0
;ADC_DAC.c,313 :: 		i2 = i1 + 10;
	MOV	_maxIndex, W0
	ADD	W0, #10, W0
	MOV	W0, [W14+0]
	MOV	W0, _i2
;ADC_DAC.c,314 :: 		yy0 = R[i0];
	SL	W1, #1, W1
	MOV	#lo_addr(_R), W0
	ADD	W0, W1, W2
	MOV	[W2], W0
	CLR	W1
	CALL	__Long2Float
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	W0, _yy0
	MOV	W1, _yy0+2
;ADC_DAC.c,315 :: 		yy2 = R[i2];
	MOV	[W14+0], W0
	SL	W0, #1, W1
	MOV	#lo_addr(_R), W0
	ADD	W0, W1, W0
	MOV	[W0], W0
	CLR	W1
	CALL	__Long2Float
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	PUSH.D	W0
	MOV	[W14+0], W0
	MOV	[W14+2], W1
	MOV	W0, _yy2
	MOV	W1, _yy2+2
	POP.D	W0
;ADC_DAC.c,317 :: 		nx = (yy0-yy2)/(2.0*(yy0-(2.0*yy1)+yy2));                   //Factor de ajuste determinado por interpolacion parabolica
	MOV	[W14+4], W0
	MOV	[W14+6], W1
	PUSH.D	W2
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__Sub_FP
	POP.D	W2
	MOV	[W14+8], W2
	MOV	[W14+10], W3
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	#0, W0
	MOV	#16384, W1
	CALL	__Mul_FP
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	_yy0, W0
	MOV	_yy0+2, W1
	PUSH.D	W2
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__Sub_FP
	POP.D	W2
	MOV	_yy2, W2
	MOV	_yy2+2, W3
	CALL	__AddSub_FP
	MOV	#0, W2
	MOV	#16384, W3
	CALL	__Mul_FP
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	[W14+4], W0
	MOV	[W14+6], W1
	PUSH.D	W2
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__Div_FP
	POP.D	W2
	MOV	W0, _nx
	MOV	W1, _nx+2
;ADC_DAC.c,318 :: 		dx = nx * 50.0;
	MOV	#0, W2
	MOV	#16968, W3
	CALL	__Mul_FP
	MOV	W0, _dx
	MOV	W1, _dx+2
;ADC_DAC.c,319 :: 		tmax = ((float)(i1))*5.0;
	MOV	_i1, W0
	CLR	W1
	CALL	__Long2Float
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Mul_FP
	MOV	W0, _tmax
	MOV	W1, _tmax+2
;ADC_DAC.c,321 :: 		T2 = (tmax)+dx;
	MOV	_dx, W2
	MOV	_dx+2, W3
	CALL	__AddSub_FP
	MOV	W0, _T2
	MOV	W1, _T2+2
;ADC_DAC.c,323 :: 		bm = 3;
	MOV	#lo_addr(_bm), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,325 :: 		}
L_main18:
;ADC_DAC.c,327 :: 		if (bm==3){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA Z	L__main40
	GOTO	L_main19
L__main40:
;ADC_DAC.c,330 :: 		T1 = T1_e * 0.025;
	MOV	_T1_e, W0
	MOV	_T1_e+2, W1
	CALL	__Long2Float
	MOV	#52429, W2
	MOV	#15564, W3
	CALL	__Mul_FP
	MOV	W0, _T1
	MOV	W1, _T1+2
;ADC_DAC.c,331 :: 		TOF = T1 + T2;
	MOV	_T2, W2
	MOV	_T2+2, W3
	CALL	__AddSub_FP
	MOV	W0, _TOF
	MOV	W1, _TOF+2
;ADC_DAC.c,332 :: 		Dst = VSnd * (TOF / 20000.0);
	MOV	#16384, W2
	MOV	#18076, W3
	CALL	__Div_FP
	MOV	_VSnd, W2
	MOV	_VSnd+2, W3
	CALL	__Mul_FP
	MOV	W0, _Dst
	MOV	W1, _Dst+2
;ADC_DAC.c,334 :: 		FloatToStr(TOF, txt1);
	MOV	#lo_addr(_txt1), W12
	MOV	_TOF, W10
	MOV	_TOF+2, W11
	CALL	_FloatToStr
;ADC_DAC.c,335 :: 		FloatToStr(Dst, txt2);
	MOV	#lo_addr(_txt2), W12
	MOV	_Dst, W10
	MOV	_Dst+2, W11
	CALL	_FloatToStr
;ADC_DAC.c,337 :: 		Lcd_Out(1,1,"TOF: ");
	MOV	#lo_addr(?lstr1_ADC_DAC), W12
	MOV	#1, W11
	MOV	#1, W10
	CALL	_Lcd_Out
;ADC_DAC.c,338 :: 		Lcd_Out_Cp(txt1);
	MOV	#lo_addr(_txt1), W10
	CALL	_Lcd_Out_CP
;ADC_DAC.c,339 :: 		Lcd_Out(2,1,"Dst: ");
	MOV	#lo_addr(?lstr2_ADC_DAC), W12
	MOV	#1, W11
	MOV	#2, W10
	CALL	_Lcd_Out
;ADC_DAC.c,340 :: 		Lcd_Out_Cp(txt2);
	MOV	#lo_addr(_txt2), W10
	CALL	_Lcd_Out_CP
;ADC_DAC.c,342 :: 		Delay_ms(1);
	MOV	#13333, W7
L_main20:
	DEC	W7
	BRA NZ	L_main20
	NOP
;ADC_DAC.c,344 :: 		bm = 0;
	MOV	#lo_addr(_bm), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,346 :: 		}
L_main19:
;ADC_DAC.c,347 :: 		Delay_ms(10);
	MOV	#3, W8
	MOV	#2261, W7
L_main22:
	DEC	W7
	BRA NZ	L_main22
	DEC	W8
	BRA NZ	L_main22
;ADC_DAC.c,348 :: 		}
	GOTO	L_main10
;ADC_DAC.c,350 :: 		}
L_end_main:
	POP	W12
	POP	W11
	POP	W10
	ULNK
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
