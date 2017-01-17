
_Envolvente:

;ADC_DAC.c,42 :: 		void Envolvente() {
;ADC_DAC.c,45 :: 		if (ADC1BUF0>512){
	MOV	ADC1BUF0, W1
	MOV	#512, W0
	CP	W1, W0
	BRA GTU	L__Envolvente22
	GOTO	L_Envolvente0
L__Envolvente22:
;ADC_DAC.c,46 :: 		value = (ADC1BUF0-512);
	MOV	ADC1BUF0, W2
	MOV	#512, W1
	MOV	#lo_addr(_value), W0
	SUB	W2, W1, [W0]
;ADC_DAC.c,47 :: 		}
L_Envolvente0:
;ADC_DAC.c,48 :: 		if (ADC1BUF0==512){
	MOV	ADC1BUF0, W1
	MOV	#512, W0
	CP	W1, W0
	BRA Z	L__Envolvente23
	GOTO	L_Envolvente1
L__Envolvente23:
;ADC_DAC.c,49 :: 		value = 0;
	CLR	W0
	MOV	W0, _value
;ADC_DAC.c,50 :: 		}
L_Envolvente1:
;ADC_DAC.c,51 :: 		if (ADC1BUF0==0){
	MOV	ADC1BUF0, WREG
	CP	W0, #0
	BRA Z	L__Envolvente24
	GOTO	L_Envolvente2
L__Envolvente24:
;ADC_DAC.c,52 :: 		value = 0;
	CLR	W0
	MOV	W0, _value
;ADC_DAC.c,53 :: 		}
L_Envolvente2:
;ADC_DAC.c,54 :: 		if (ADC1BUF0<512){
	MOV	ADC1BUF0, W1
	MOV	#512, W0
	CP	W1, W0
	BRA LTU	L__Envolvente25
	GOTO	L_Envolvente3
L__Envolvente25:
;ADC_DAC.c,55 :: 		value = (ADC1BUF0+((512-ADC1BUF0)*2))-513;
	MOV	#512, W1
	MOV	#lo_addr(ADC1BUF0), W0
	SUB	W1, [W0], W0
	SL	W0, #1, W1
	MOV	#lo_addr(ADC1BUF0), W0
	ADD	W1, [W0], W2
	MOV	#513, W1
	MOV	#lo_addr(_value), W0
	SUB	W2, W1, [W0]
;ADC_DAC.c,56 :: 		}
L_Envolvente3:
;ADC_DAC.c,59 :: 		if (value>5){
	MOV	_value, W0
	CP	W0, #5
	BRA GTU	L__Envolvente26
	GOTO	L_Envolvente4
L__Envolvente26:
;ADC_DAC.c,61 :: 		if (value>aux_value){
	MOV	_value, W1
	MOV	#lo_addr(_aux_value), W0
	CP	W1, [W0]
	BRA GTU	L__Envolvente27
	GOTO	L_Envolvente5
L__Envolvente27:
;ADC_DAC.c,62 :: 		aux_value=value;
	MOV	_value, W0
	MOV	W0, _aux_value
;ADC_DAC.c,64 :: 		}
	GOTO	L_Envolvente6
L_Envolvente5:
;ADC_DAC.c,66 :: 		aux_value=aux_value-5;
	MOV	_aux_value, W0
	SUB	W0, #5, W0
	MOV	W0, _aux_value
;ADC_DAC.c,67 :: 		if (aux_value<0){
	CP	W0, #0
	BRA LTU	L__Envolvente28
	GOTO	L_Envolvente7
L__Envolvente28:
;ADC_DAC.c,68 :: 		aux_value=value;
	MOV	_value, W0
	MOV	W0, _aux_value
;ADC_DAC.c,69 :: 		}
L_Envolvente7:
;ADC_DAC.c,70 :: 		}
L_Envolvente6:
;ADC_DAC.c,72 :: 		}else{
	GOTO	L_Envolvente8
L_Envolvente4:
;ADC_DAC.c,73 :: 		aux_value=0;
	CLR	W0
	MOV	W0, _aux_value
;ADC_DAC.c,75 :: 		}
L_Envolvente8:
;ADC_DAC.c,78 :: 		input[inext] = aux_value;                   // Fetch sample
	MOV	_inext, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_input), W0
	ADD	W0, W1, W1
	MOV	_aux_value, W0
	MOV	W0, [W1]
;ADC_DAC.c,88 :: 		inext);         // Current sample
	PUSH	_inext
;ADC_DAC.c,87 :: 		output,         // Input buffer
	MOV	#lo_addr(_output), W0
	PUSH	W0
;ADC_DAC.c,86 :: 		BUFFER_SIZE,    // Input buffer length
	MOV	#8, W0
	PUSH	W0
;ADC_DAC.c,85 :: 		input,          // Input buffer
	MOV	#lo_addr(_input), W0
	PUSH	W0
;ADC_DAC.c,84 :: 		FILTER_ORDER+1, // Filter order + 1
	MOV	#3, W0
	PUSH	W0
;ADC_DAC.c,83 :: 		COEFF_A,        // a coefficients of the filter
	MOV	#lo_addr(_COEFF_A), W0
	PUSH	W0
;ADC_DAC.c,82 :: 		COEFF_B,        // b coefficients of the filter
	MOV	#lo_addr(_COEFF_B), W0
	PUSH	W0
;ADC_DAC.c,81 :: 		SCALE_A,        //
	MOV	#65535, W0
	PUSH	W0
;ADC_DAC.c,80 :: 		CurrentValue = IIR_Radix( SCALE_B,        //
	MOV	#7, W0
	PUSH	W0
;ADC_DAC.c,88 :: 		inext);         // Current sample
	CALL	_Iir_Radix
	SUB	#18, W15
; CurrentValue start address is: 6 (W3)
	MOV	W0, W3
;ADC_DAC.c,90 :: 		output[inext] = CurrentValue;
	MOV	_inext, W1
	SL	W1, #1, W2
	MOV	#lo_addr(_output), W1
	ADD	W1, W2, W1
	MOV	W0, [W1]
;ADC_DAC.c,91 :: 		inext = (inext+1) & (BUFFER_SIZE-1);      // inext = (inext + 1) mod BUFFER_SIZE;
	MOV	_inext, W0
	ADD	W0, #1, W1
	MOV	#lo_addr(_inext), W0
	AND	W1, #7, [W0]
;ADC_DAC.c,94 :: 		LATB = CurrentValue;
	MOV	W3, LATB
; CurrentValue end address is: 6 (W3)
;ADC_DAC.c,96 :: 		}
L_end_Envolvente:
	RETURN
; end of _Envolvente

_Velocidad:
	LNK	#4

;ADC_DAC.c,98 :: 		void Velocidad(){
;ADC_DAC.c,103 :: 		Ow_Reset(&PORTB, 15);                        //Onewire reset signal
	PUSH	W10
	PUSH	W11
	PUSH	W12
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Reset
;ADC_DAC.c,104 :: 		Ow_Write(&PORTB, 15, 0xCC);                  //Issue command SKIP_ROM
	MOV.B	#204, W12
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;ADC_DAC.c,105 :: 		Ow_Write(&PORTB, 15, 0x44);                  //Issue command CONVERT_T
	MOV.B	#68, W12
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;ADC_DAC.c,106 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad9:
	DEC	W7
	BRA NZ	L_Velocidad9
	NOP
;ADC_DAC.c,108 :: 		Ow_Reset(&PORTB, 15);
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Reset
;ADC_DAC.c,109 :: 		Ow_Write(&PORTB, 15, 0xCC);                  //Issue command SKIP_ROM
	MOV.B	#204, W12
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;ADC_DAC.c,110 :: 		Ow_Write(&PORTB, 15, 0xBE);                  //Issue command READ_SCRATCHPAD
	MOV.B	#190, W12
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;ADC_DAC.c,111 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad11:
	DEC	W7
	BRA NZ	L_Velocidad11
	NOP
;ADC_DAC.c,113 :: 		Temp =  Ow_Read(&PORTB, 15);
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Read
; Temp start address is: 10 (W5)
	ZE	W0, W5
;ADC_DAC.c,114 :: 		Temp = (Ow_Read(&PORTB, 15) << 8) + Temp;
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Read
	ZE	W0, W0
	SL	W0, #8, W0
	ADD	W0, W5, W0
; Temp end address is: 10 (W5)
; Temp start address is: 4 (W2)
	MOV	W0, W2
;ADC_DAC.c,116 :: 		if (Temp & 0x8000) {
	BTSS	W0, #15
	GOTO	L__Velocidad20
;ADC_DAC.c,117 :: 		Temp = 0;                                //Si la temperatura es negativa la establece como cero.
	CLR	W2
; Temp end address is: 4 (W2)
;ADC_DAC.c,118 :: 		}
	GOTO	L_Velocidad13
L__Velocidad20:
;ADC_DAC.c,116 :: 		if (Temp & 0x8000) {
;ADC_DAC.c,118 :: 		}
L_Velocidad13:
;ADC_DAC.c,120 :: 		Rint = Temp >> 4;                           //Extrae la parte entera de la respuesta del sensor
; Temp start address is: 4 (W2)
	LSR	W2, #4, W0
; Rint start address is: 6 (W3)
	MOV	W0, W3
;ADC_DAC.c,121 :: 		Rfrac = ((Temp & 0x000F) * 625) / 10000.;   //Extrae la parte decimal de la respuesta del sensor
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
;ADC_DAC.c,122 :: 		DSTemp = Rint + Rfrac;
	MOV	W3, W0
	CLR	W1
	CALL	__Long2Float
; Rint end address is: 6 (W3)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	MOV	W0, _DSTemp
	MOV	W1, _DSTemp+2
;ADC_DAC.c,124 :: 		VSnd = 331.45 * sqrt(1+(DsTemp/273));       //Expresa la temperatura en punto flotante
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
;ADC_DAC.c,125 :: 		}
L_end_Velocidad:
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _Velocidad

_ADC1Int:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,130 :: 		void ADC1Int() org IVT_ADDR_ADC1INTERRUPT {
;ADC_DAC.c,131 :: 		Envolvente();                                 //Llama a la funcion para detectar la Envolvente de la senal
	CALL	_Envolvente
;ADC_DAC.c,132 :: 		AD1IF_bit = 0;                                //Limpia la bandera de interrupcion del ADC
	BCLR	AD1IF_bit, BitPos(AD1IF_bit+0)
;ADC_DAC.c,133 :: 		}
L_end_ADC1Int:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _ADC1Int

_Timer1Int:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,135 :: 		void Timer1Int() org IVT_ADDR_T1INTERRUPT {
;ADC_DAC.c,136 :: 		SAMP_bit = 0;                                 //Limpia el bit SAMP para iniciar la conversion del ADC
	BCLR	SAMP_bit, BitPos(SAMP_bit+0)
;ADC_DAC.c,137 :: 		T1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,138 :: 		}
L_end_Timer1Int:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _Timer1Int

_Timer2Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,140 :: 		void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
;ADC_DAC.c,141 :: 		if (contp<20){                                //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (
	MOV	_contp, W0
	CP	W0, #20
	BRA LTU	L__Timer2Interrupt33
	GOTO	L_Timer2Interrupt14
L__Timer2Interrupt33:
;ADC_DAC.c,142 :: 		BS = ~BS;                                //Variable auxiliar para establecer el cambio de estado en el bit RD0.
	MOV	#lo_addr(_BS), W0
	MOV.B	[W0], W0
	COM.B	W0, W1
	MOV	#lo_addr(_BS), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,143 :: 		RB14_bit = BS;
	BTSS	W1, #0
	BCLR	RB14_bit, BitPos(RB14_bit+0)
	BTSC	W1, #0
	BSET	RB14_bit, BitPos(RB14_bit+0)
;ADC_DAC.c,144 :: 		}else {
	GOTO	L_Timer2Interrupt15
L_Timer2Interrupt14:
;ADC_DAC.c,145 :: 		RB14_bit = 0;                            //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCLR	RB14_bit, BitPos(RB14_bit+0)
;ADC_DAC.c,146 :: 		IEC0.T2IE = 0;                           //Desabilita la interrupcion por desborde del TMR2 para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #7
;ADC_DAC.c,147 :: 		IEC0.T1IE = 1;                           //Habilita la interrupcion por desborde del TMR1 para dar inicio al muestreo del ADC
	BSET	IEC0, #3
;ADC_DAC.c,148 :: 		}
L_Timer2Interrupt15:
;ADC_DAC.c,149 :: 		contp++;                                      //Aumenta el contador en una unidad.
	MOV	#1, W1
	MOV	#lo_addr(_contp), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,150 :: 		T2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,151 :: 		}
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

;ADC_DAC.c,155 :: 		void Configuracion(){
;ADC_DAC.c,158 :: 		CLKDIVbits.PLLPRE = 0;                      //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,159 :: 		PLLFBD = 38;                                //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
	MOV	#38, W0
	MOV	WREG, PLLFBD
;ADC_DAC.c,160 :: 		CLKDIVbits.PLLPOST = 0;                     //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,163 :: 		AD1PCFGL = 0xFFFE;                          //Configura el puerto AN0 como entrada analogica y todas las demas como digitales
	MOV	#65534, W0
	MOV	WREG, AD1PCFGL
;ADC_DAC.c,164 :: 		TRISA0_bit = 1;                             //Set RA0 pin as input
	BSET	TRISA0_bit, BitPos(TRISA0_bit+0)
;ADC_DAC.c,165 :: 		TRISA1_bit = 0;                             //Set RA1 pin as output
	BCLR	TRISA1_bit, BitPos(TRISA1_bit+0)
;ADC_DAC.c,166 :: 		TRISB = 0x8000;                             //Establece los pines 0-14 de PORTB como salidas y el pin 15 como entrada
	MOV	#32768, W0
	MOV	WREG, TRISB
;ADC_DAC.c,169 :: 		AD1CON1.AD12B = 0;                          //Configura el ADC en modo de 10 bits
	BCLR	AD1CON1, #10
;ADC_DAC.c,170 :: 		AD1CON1bits.FORM = 0x00;                    //!!Selecciona el formato en que se presentaran los resultados de conversion, 01->Entero con signo(-512_511)
	MOV	AD1CON1bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON1bits
;ADC_DAC.c,171 :: 		AD1CON1.SIMSAM = 0;                         //0 -> Muestrea múltiples canales individualmente en secuencia
	BCLR	AD1CON1, #3
;ADC_DAC.c,172 :: 		AD1CON1.ADSIDL = 0;                         //Continua con la operacion del modulo durante el modo desocupado
	BCLR	AD1CON1, #13
;ADC_DAC.c,173 :: 		AD1CON1.ASAM = 1;                           //Muestreo automatico
	BSET	AD1CON1, #2
;ADC_DAC.c,174 :: 		AD1CON1bits.SSRC = 0x00;                    //Conversion manual
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	[W0], W1
	MOV.B	#31, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,176 :: 		AD1CON2bits.VCFG = 0;                       //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
	MOV	AD1CON2bits, W1
	MOV	#8191, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,177 :: 		AD1CON2bits.CHPS = 0;                       //Selecciona unicamente el canal CH0
	MOV	AD1CON2bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,178 :: 		AD1CON2.CSCNA = 0;                          //No escanea las entradas de CH0 durante la Muestra A
	BCLR	AD1CON2, #10
;ADC_DAC.c,179 :: 		AD1CON2bits.SMPI = 0x00;                    //Numero de secuencias de muestreo/conversion por interrupcion (N+1)
	MOV	#lo_addr(AD1CON2bits), W0
	MOV.B	[W0], W1
	MOV.B	#195, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON2bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,180 :: 		AD1CON2.BUFM = 0;                           //Bit de selección del modo de relleno del búfer, 0 -> Siempre comienza a llenar el buffer desde el principio
	BCLR	AD1CON2, #1
;ADC_DAC.c,181 :: 		AD1CON2.ALTS = 0x00;                        //Utiliza siempre la selección de entrada de canal para la muestra A
	BCLR	AD1CON2, #0
;ADC_DAC.c,183 :: 		AD1CON3.ADRC = 0;                           //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
	BCLR	AD1CON3, #15
;ADC_DAC.c,184 :: 		AD1CON3bits.ADCS = 0x02;                    //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
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
;ADC_DAC.c,185 :: 		AD1CON3bits.SAMC = 0x02;                    //Auto Sample Time bits, 2 -> 2*TAD (minimo periodo de muestreo para 10 bits)
	MOV	#512, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CON3bits
;ADC_DAC.c,187 :: 		AD1CHS0 = 0;                                //ADC1 INPUT CHANNEL 0 SELECT REGISTER
	CLR	AD1CHS0
;ADC_DAC.c,188 :: 		AD1CHS123 = 0;                              //AD1CHS123: ADC1 INPUT CHANNEL 1, 2, 3 SELECT REGISTER
	CLR	AD1CHS123
;ADC_DAC.c,190 :: 		AD1CSSL = 0x00;                             //Se salta todos los puertos ANx para los escaneos de entrada
	CLR	AD1CSSL
;ADC_DAC.c,192 :: 		IEC0.AD1IE = 0x01;                          //Activa la interrupcion por conversion completa del ADC
	BSET	IEC0, #13
;ADC_DAC.c,194 :: 		AD1CON1.ADON = 1;                           //Enciende el modulo ADC
	BSET	AD1CON1, #15
;ADC_DAC.c,197 :: 		T1CON = 0x8000;                             //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T1CON
;ADC_DAC.c,198 :: 		IEC0.T1IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR1 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #3
;ADC_DAC.c,199 :: 		T1IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,200 :: 		PR1 = 200;                                  //Genera una interrupcion cada 5us (Fs=200KHz)
	MOV	#200, W0
	MOV	WREG, PR1
;ADC_DAC.c,203 :: 		T2CON = 0x8000;                             //Habilita el TMR2, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T2CON
;ADC_DAC.c,204 :: 		IEC0.T2IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR2 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #7
;ADC_DAC.c,205 :: 		T2IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,206 :: 		PR2 = 500;                                  //Genera una interrupcion cada 12.5us
	MOV	#500, W0
	MOV	WREG, PR2
;ADC_DAC.c,209 :: 		IPC3bits.AD1IP = 0x06;                      //Nivel de prioridad de interrupcion del ADC
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
;ADC_DAC.c,210 :: 		IPC0bits.T1IP = 0x07;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR1
	MOV	IPC0bits, W1
	MOV	#28672, W0
	IOR	W1, W0, W0
	MOV	WREG, IPC0bits
;ADC_DAC.c,211 :: 		IPC1bits.T2IP = 0x05;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR2
	MOV	#20480, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;ADC_DAC.c,213 :: 		}
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

;ADC_DAC.c,217 :: 		void main() {
;ADC_DAC.c,219 :: 		Configuracion();
	CALL	_Configuracion
;ADC_DAC.c,221 :: 		while(1){
L_main16:
;ADC_DAC.c,223 :: 		IEC0.T1IE = 0;                     //Desabilita la interrupcion por desborde del TMR1 para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #3
;ADC_DAC.c,225 :: 		Velocidad();                       //Llama a la funcion para calcular la Velocidad del sonido
	CALL	_Velocidad
;ADC_DAC.c,227 :: 		inext   = 0;                              // Initialize buffer index
	CLR	W0
	MOV	W0, _inext
;ADC_DAC.c,228 :: 		Vector_Set(input, BUFFER_SIZE, 0);        // Clear input buffer
	CLR	W0
	PUSH	W0
	MOV	#8, W0
	PUSH	W0
	MOV	#lo_addr(_input), W0
	PUSH	W0
	CALL	_Vector_Set
	SUB	#6, W15
;ADC_DAC.c,229 :: 		Vector_Set(output, BUFFER_SIZE, 0);       // Clear output buffer
	CLR	W0
	PUSH	W0
	MOV	#8, W0
	PUSH	W0
	MOV	#lo_addr(_output), W0
	PUSH	W0
	CALL	_Vector_Set
	SUB	#6, W15
;ADC_DAC.c,231 :: 		T2CON.TON = 1;                     //Enciende el TMR2
	BSET	T2CON, #15
;ADC_DAC.c,232 :: 		IEC0.T2IE = 1;                     //Habilita la interrupcion pos desborde del TMR2
	BSET	IEC0, #7
;ADC_DAC.c,234 :: 		contp = 0;                         //Limpia la variable del contador de pulsos
	CLR	W0
	MOV	W0, _contp
;ADC_DAC.c,235 :: 		BS = 0;                            //Limpia la variable auxiliar de cambio de estado de los pulsos
	MOV	#lo_addr(_BS), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,240 :: 		Delay_ms(15);
	MOV	#4, W8
	MOV	#3392, W7
L_main18:
	DEC	W7
	BRA NZ	L_main18
	DEC	W8
	BRA NZ	L_main18
;ADC_DAC.c,241 :: 		}
	GOTO	L_main16
;ADC_DAC.c,243 :: 		}
L_end_main:
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
