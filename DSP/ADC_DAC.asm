
_Envolvente:

;ADC_DAC.c,50 :: 		void Envolvente() {
;ADC_DAC.c,52 :: 		}
L_end_Envolvente:
	RETURN
; end of _Envolvente

_Velocidad:
	LNK	#4

;ADC_DAC.c,54 :: 		void Velocidad(){
;ADC_DAC.c,59 :: 		Ow_Reset(&PORTB, 15);                        //Onewire reset signal
	PUSH	W10
	PUSH	W11
	PUSH	W12
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Reset
;ADC_DAC.c,60 :: 		Ow_Write(&PORTB, 15, 0xCC);                  //Issue command SKIP_ROM
	MOV.B	#204, W12
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;ADC_DAC.c,61 :: 		Ow_Write(&PORTB, 15, 0x44);                  //Issue command CONVERT_T
	MOV.B	#68, W12
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;ADC_DAC.c,62 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad0:
	DEC	W7
	BRA NZ	L_Velocidad0
	NOP
;ADC_DAC.c,64 :: 		Ow_Reset(&PORTB, 15);
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Reset
;ADC_DAC.c,65 :: 		Ow_Write(&PORTB, 15, 0xCC);                  //Issue command SKIP_ROM
	MOV.B	#204, W12
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;ADC_DAC.c,66 :: 		Ow_Write(&PORTB, 15, 0xBE);                  //Issue command READ_SCRATCHPAD
	MOV.B	#190, W12
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;ADC_DAC.c,67 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad2:
	DEC	W7
	BRA NZ	L_Velocidad2
	NOP
;ADC_DAC.c,69 :: 		Temp =  Ow_Read(&PORTB, 15);
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Read
; Temp start address is: 10 (W5)
	ZE	W0, W5
;ADC_DAC.c,70 :: 		Temp = (Ow_Read(&PORTB, 15) << 8) + Temp;
	MOV	#15, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Read
	ZE	W0, W0
	SL	W0, #8, W0
	ADD	W0, W5, W0
; Temp end address is: 10 (W5)
; Temp start address is: 4 (W2)
	MOV	W0, W2
;ADC_DAC.c,72 :: 		if (Temp & 0x8000) {
	BTSS	W0, #15
	GOTO	L__Velocidad26
;ADC_DAC.c,73 :: 		Temp = 0;                                //Si la temperatura es negativa la establece como cero.
	CLR	W2
; Temp end address is: 4 (W2)
;ADC_DAC.c,74 :: 		}
	GOTO	L_Velocidad4
L__Velocidad26:
;ADC_DAC.c,72 :: 		if (Temp & 0x8000) {
;ADC_DAC.c,74 :: 		}
L_Velocidad4:
;ADC_DAC.c,76 :: 		Rint = Temp >> 4;                           //Extrae la parte entera de la respuesta del sensor
; Temp start address is: 4 (W2)
	LSR	W2, #4, W0
; Rint start address is: 6 (W3)
	MOV	W0, W3
;ADC_DAC.c,77 :: 		Rfrac = ((Temp & 0x000F) * 625) / 10000.;   //Extrae la parte decimal de la respuesta del sensor
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
;ADC_DAC.c,78 :: 		DSTemp = Rint + Rfrac;
	MOV	W3, W0
	CLR	W1
	CALL	__Long2Float
; Rint end address is: 6 (W3)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	MOV	W0, _DSTemp
	MOV	W1, _DSTemp+2
;ADC_DAC.c,80 :: 		VSnd = 331.45 * sqrt(1+(DsTemp/273));       //Expresa la temperatura en punto flotante
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
;ADC_DAC.c,81 :: 		}
L_end_Velocidad:
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _Velocidad

_Timer1Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,86 :: 		void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
;ADC_DAC.c,87 :: 		LATA1_bit = ~LATA1_bit;                       //Auxiliar para ver el proceso de la interrupcion
	BTG	LATA1_bit, BitPos(LATA1_bit+0)
;ADC_DAC.c,88 :: 		if (bm==0){                                   //Cuando la bandera bm=0, la interrupcion por TMR1 es utilizada para el muestreo de la se�al de entrada
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__Timer1Interrupt30
	GOTO	L_Timer1Interrupt5
L__Timer1Interrupt30:
;ADC_DAC.c,89 :: 		SAMP_bit = 0;                              //Limpia el bit SAMP para iniciar la conversion del ADC
	BCLR	SAMP_bit, BitPos(SAMP_bit+0)
;ADC_DAC.c,90 :: 		while (!AD1CON1bits.DONE);                 // Wait for the conversion to complete
L_Timer1Interrupt6:
	BTSC	AD1CON1bits, #0
	GOTO	L_Timer1Interrupt7
	GOTO	L_Timer1Interrupt6
L_Timer1Interrupt7:
;ADC_DAC.c,91 :: 		if (i<nm){
	MOV	_i, W1
	MOV	#365, W0
	CP	W1, W0
	BRA LTU	L__Timer1Interrupt31
	GOTO	L_Timer1Interrupt8
L__Timer1Interrupt31:
;ADC_DAC.c,92 :: 		M[i] = ADC1BUF0;                       //Almacena el valor actual de la conversion del ADC en el vector M
	MOV	_i, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	ADC1BUF0, WREG
	MOV	W0, [W1]
;ADC_DAC.c,93 :: 		i++;                                   //Aumenta en 1 el subindice del vector de Muestras
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,94 :: 		} else {
	GOTO	L_Timer1Interrupt9
L_Timer1Interrupt8:
;ADC_DAC.c,95 :: 		bm = 1;                                    //Cambia el valor de la bandera bm para terminar con el muestreo y dar comienzo al procesamiento de la se�al
	MOV	#lo_addr(_bm), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,96 :: 		T1CON.TON = 0;                             //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,97 :: 		IEC0.T1IE = 0;                             //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,98 :: 		}
L_Timer1Interrupt9:
;ADC_DAC.c,99 :: 		}
L_Timer1Interrupt5:
;ADC_DAC.c,100 :: 		if (bm==1) {                                  //Cuando la bandera bm=1, la interrupcion por TMR1 es utilizada para la reconstruccion de la se�al mediante el DAC
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__Timer1Interrupt32
	GOTO	L_Timer1Interrupt10
L__Timer1Interrupt32:
;ADC_DAC.c,101 :: 		if (j<nm){
	MOV	_j, W1
	MOV	#365, W0
	CP	W1, W0
	BRA LTU	L__Timer1Interrupt33
	GOTO	L_Timer1Interrupt11
L__Timer1Interrupt33:
;ADC_DAC.c,102 :: 		LATB = (R[j]&0x7F)|((r[j]<<1)&0x700);
	MOV	_j, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_R), W0
	ADD	W0, W1, W0
	MOV	[W0], W1
	MOV	#127, W0
	AND	W1, W0, W2
	SL	W1, #1, W1
	MOV	#1792, W0
	AND	W1, W0, W1
	MOV	#lo_addr(LATB), W0
	IOR	W2, W1, [W0]
;ADC_DAC.c,103 :: 		j++;
	MOV	#1, W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,104 :: 		} else {
	GOTO	L_Timer1Interrupt12
L_Timer1Interrupt11:
;ADC_DAC.c,105 :: 		bm = 0;                               //Cambia el valor de la bandera bm para permitir un nuevo muestreo
	MOV	#lo_addr(_bm), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,106 :: 		IEC0.T1IE = 0;                        //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,107 :: 		}
L_Timer1Interrupt12:
;ADC_DAC.c,108 :: 		}
L_Timer1Interrupt10:
;ADC_DAC.c,109 :: 		T1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,110 :: 		}
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

;ADC_DAC.c,112 :: 		void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
;ADC_DAC.c,114 :: 		if (contp<10){                                //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (
	MOV	_contp, W0
	CP	W0, #10
	BRA LTU	L__Timer2Interrupt35
	GOTO	L_Timer2Interrupt13
L__Timer2Interrupt35:
;ADC_DAC.c,115 :: 		RB14_bit = ~RB14_bit;                    //Conmuta el valor del pin RB14
	BTG	RB14_bit, BitPos(RB14_bit+0)
;ADC_DAC.c,116 :: 		} else {
	GOTO	L_Timer2Interrupt14
L_Timer2Interrupt13:
;ADC_DAC.c,117 :: 		RB14_bit = 0;                            //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCLR	RB14_bit, BitPos(RB14_bit+0)
;ADC_DAC.c,118 :: 		if (contp==104){
	MOV	#104, W1
	MOV	#lo_addr(_contp), W0
	CP	W1, [W0]
	BRA Z	L__Timer2Interrupt36
	GOTO	L_Timer2Interrupt15
L__Timer2Interrupt36:
;ADC_DAC.c,119 :: 		LATA4_bit = ~LATA4_bit;
	BTG	LATA4_bit, BitPos(LATA4_bit+0)
;ADC_DAC.c,120 :: 		IEC0.T2IE = 0;                       //Desabilita la interrupcion por desborde del TMR2 para no interferir con las interrupciones por desborde de TMR1 y por conversion completa del ADC
	BCLR	IEC0, #7
;ADC_DAC.c,121 :: 		T2CON.TON = 0;                       //Apaga el TMR2
	BCLR	T2CON, #15
;ADC_DAC.c,122 :: 		IEC0.AD1IE = 0;                      //Habilita la interrupcion por conversion completa del ADC
	BCLR	IEC0, #13
;ADC_DAC.c,123 :: 		IEC0.T1IE = 1;                       //Habilita la interrupcion por desborde del TMR1 para dar inicio al muestreo del ADC
	BSET	IEC0, #3
;ADC_DAC.c,124 :: 		TMR1 = 0;                            //Encera el TMR1
	CLR	TMR1
;ADC_DAC.c,125 :: 		T1CON.TON = 1;                       //Enciende el TMR1
	BSET	T1CON, #15
;ADC_DAC.c,126 :: 		}
L_Timer2Interrupt15:
;ADC_DAC.c,127 :: 		}
L_Timer2Interrupt14:
;ADC_DAC.c,128 :: 		contp++;                                      //Aumenta el contador en una unidad.
	MOV	#1, W1
	MOV	#lo_addr(_contp), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,129 :: 		T2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,130 :: 		}
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

;ADC_DAC.c,134 :: 		void Configuracion(){
;ADC_DAC.c,137 :: 		CLKDIVbits.PLLPRE = 0;                        //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,138 :: 		PLLFBD = 38;                                  //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
	MOV	#38, W0
	MOV	WREG, PLLFBD
;ADC_DAC.c,139 :: 		CLKDIVbits.PLLPOST = 0;                       //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,142 :: 		AD1PCFGL = 0xFFFE;                            //Configura el puerto AN0 como entrada analogica y todas las demas como digitales
	MOV	#65534, W0
	MOV	WREG, AD1PCFGL
;ADC_DAC.c,143 :: 		TRISA0_bit = 1;                               //Set RA0 pin as input
	BSET	TRISA0_bit, BitPos(TRISA0_bit+0)
;ADC_DAC.c,144 :: 		TRISA1_bit = 0;                               //Set RA1 pin as output
	BCLR	TRISA1_bit, BitPos(TRISA1_bit+0)
;ADC_DAC.c,145 :: 		TRISA4_bit = 0;
	BCLR	TRISA4_bit, BitPos(TRISA4_bit+0)
;ADC_DAC.c,146 :: 		TRISB = 0x8080;                               //Establece los pines 8 y 15 como entradas y todas las demas como salidas
	MOV	#32896, W0
	MOV	WREG, TRISB
;ADC_DAC.c,149 :: 		AD1CON1.AD12B = 0;                            //Configura el ADC en modo de 10 bits
	BCLR	AD1CON1, #10
;ADC_DAC.c,150 :: 		AD1CON1bits.FORM = 0x00;                      //Formato de la canversion: 00->(0_1023)|01->(-512_511)|02->(0_0.999)|03->(-1_0.999)
	MOV	AD1CON1bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON1bits
;ADC_DAC.c,151 :: 		AD1CON1.SIMSAM = 0;                           //0 -> Muestrea m�ltiples canales individualmente en secuencia
	BCLR	AD1CON1, #3
;ADC_DAC.c,152 :: 		AD1CON1.ADSIDL = 1;                           //Continua con la operacion del modulo durante el modo desocupado
	BSET	AD1CON1, #13
;ADC_DAC.c,153 :: 		AD1CON1.ASAM = 1;                             //Muestreo automatico
	BSET	AD1CON1, #2
;ADC_DAC.c,154 :: 		AD1CON1bits.SSRC = 0x00;                      //Conversion manual
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	[W0], W1
	MOV.B	#31, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,156 :: 		AD1CON2bits.VCFG = 0;                         //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
	MOV	AD1CON2bits, W1
	MOV	#8191, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,157 :: 		AD1CON2bits.CHPS = 0;                         //Selecciona unicamente el canal CH0
	MOV	AD1CON2bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,158 :: 		AD1CON2.CSCNA = 0;                            //No escanea las entradas de CH0 durante la Muestra A
	BCLR	AD1CON2, #10
;ADC_DAC.c,160 :: 		AD1CON2.BUFM = 0;                             //Bit de selecci�n del modo de relleno del b�fer, 0 -> Siempre comienza a llenar el buffer desde el principio
	BCLR	AD1CON2, #1
;ADC_DAC.c,161 :: 		AD1CON2.ALTS = 0x00;                          //Utiliza siempre la selecci�n de entrada de canal para la muestra A
	BCLR	AD1CON2, #0
;ADC_DAC.c,163 :: 		AD1CON3.ADRC = 0;                             //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
	BCLR	AD1CON3, #15
;ADC_DAC.c,164 :: 		AD1CON3bits.ADCS = 0x00;                      //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
	MOV	#lo_addr(AD1CON3bits), W0
	MOV.B	[W0], W1
	MOV.B	#0, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,167 :: 		AD1CHS0 = 0;                                  //ADC1 INPUT CHANNEL 0 SELECT REGISTER
	CLR	AD1CHS0
;ADC_DAC.c,168 :: 		AD1CHS123 = 0;                                //AD1CHS123: ADC1 INPUT CHANNEL 1, 2, 3 SELECT REGISTER
	CLR	AD1CHS123
;ADC_DAC.c,170 :: 		AD1CSSL = 0x00;                               //Se salta todos los puertos ANx para los escaneos de entrada
	CLR	AD1CSSL
;ADC_DAC.c,174 :: 		AD1CON1.ADON = 1;                             //Enciende el modulo ADC
	BSET	AD1CON1, #15
;ADC_DAC.c,177 :: 		T1CON = 0x8000;                               //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T1CON
;ADC_DAC.c,178 :: 		IEC0.T1IE = 0;                                //Inicializa el programa con la interrupcion por desborde de TMR1 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #3
;ADC_DAC.c,179 :: 		T1IF_bit = 0;                                 //Limpia la bandera de interrupcion
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,180 :: 		PR1 = 200;                                    //Genera una interrupcion cada 5us (Fs=200KHz)
	MOV	#200, W0
	MOV	WREG, PR1
;ADC_DAC.c,183 :: 		T2CON = 0x8000;                               //Habilita el TMR2, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T2CON
;ADC_DAC.c,184 :: 		IEC0.T2IE = 0;                                //Inicializa el programa con la interrupcion por desborde de TMR2 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #7
;ADC_DAC.c,185 :: 		T2IF_bit = 0;                                 //Limpia la bandera de interrupcion
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,186 :: 		PR2 = 500;                                    //Genera una interrupcion cada 12.5us
	MOV	#500, W0
	MOV	WREG, PR2
;ADC_DAC.c,189 :: 		INTCON2.INT0EP = 0;                           //Interrupcion en flanco positivo
	BCLR	INTCON2, #0
;ADC_DAC.c,193 :: 		IPC0bits.T1IP = 0x07;                         //Nivel de prioridad de la interrupcion por desbordamiento del TMR1
	MOV	IPC0bits, W1
	MOV	#28672, W0
	IOR	W1, W0, W0
	MOV	WREG, IPC0bits
;ADC_DAC.c,194 :: 		IPC1bits.T2IP = 0x05;                         //Nivel de prioridad de la interrupcion por desbordamiento del TMR2
	MOV	#20480, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;ADC_DAC.c,195 :: 		IPC0bits.INT0IP = 0x04;                       //Nivel de prioridad de la interrupcion INT0
	MOV.B	#4, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #7, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC0bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,196 :: 		}
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
	LNK	#8

;ADC_DAC.c,200 :: 		void main() {
;ADC_DAC.c,202 :: 		Configuracion();
	CALL	_Configuracion
;ADC_DAC.c,204 :: 		while(1){
L_main16:
;ADC_DAC.c,207 :: 		if (bm==0){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__main39
	GOTO	L_main18
L__main39:
;ADC_DAC.c,209 :: 		contp = 0;                                               //Limpia la variable del contador de pulsos
	CLR	W0
	MOV	W0, _contp
;ADC_DAC.c,210 :: 		RB14_bit = 0;                                            //Limpia el pin que produce los pulsos de exitacion del transductor
	BCLR	RB14_bit, BitPos(RB14_bit+0)
;ADC_DAC.c,211 :: 		IEC0.T2IE = 1;                                           //Habilita la interrupcion por desborde del TMR2
	BSET	IEC0, #7
;ADC_DAC.c,212 :: 		TMR2 = 0;                                                //Encera el TMR2
	CLR	TMR2
;ADC_DAC.c,213 :: 		T2CON.TON = 1;                                           //Enciende el TMR2
	BSET	T2CON, #15
;ADC_DAC.c,215 :: 		i = 0;                                                   //Limpia las variables asociadas al almacenamiento de la se�al muestreada
	CLR	W0
	MOV	W0, _i
;ADC_DAC.c,216 :: 		j = 0;
	CLR	W0
	MOV	W0, _j
;ADC_DAC.c,218 :: 		}
	GOTO	L_main19
L_main18:
;ADC_DAC.c,223 :: 		Velocidad();                                             //Llama a la funcion para calcular la Velocidad del sonido
	CALL	_Velocidad
;ADC_DAC.c,226 :: 		VMmax = Vector_Max(M, nm, &IndexMax);
	MOV	#lo_addr(_IndexMax), W0
	PUSH	W0
	MOV	#365, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Max
	SUB	#6, W15
	MOV	W0, _VMmax
;ADC_DAC.c,227 :: 		VMmin = Vector_Min(M, nm, &IndexMin);
	MOV	#lo_addr(_IndexMin), W0
	PUSH	W0
	MOV	#365, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Min
	SUB	#6, W15
	MOV	W0, _VMmin
;ADC_DAC.c,228 :: 		VMmed = VMmax-((VMmax-VMmin)/2);
	MOV	#lo_addr(_VMmax), W1
	SUBR	W0, [W1], W0
	LSR	W0, #1, W2
	MOV	#lo_addr(_VMmax), W1
	MOV	#lo_addr(_VMmed), W0
	SUBR	W2, [W1], [W0]
;ADC_DAC.c,230 :: 		for (k=0;k<nm;k++){
	CLR	W0
	MOV	W0, _k
L_main20:
	MOV	_k, W1
	MOV	#365, W0
	CP	W1, W0
	BRA LTU	L__main40
	GOTO	L_main21
L__main40:
;ADC_DAC.c,234 :: 		value = M[k]-VMmed;
	MOV	_k, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W3
	MOV	[W3], W2
	MOV	#lo_addr(_VMmed), W1
	MOV	#lo_addr(_value), W0
	SUB	W2, [W1], [W0]
;ADC_DAC.c,235 :: 		if (M[k]<VMmed){
	MOV	[W3], W1
	MOV	#lo_addr(_VMmed), W0
	CP	W1, [W0]
	BRA LTU	L__main41
	GOTO	L_main23
L__main41:
;ADC_DAC.c,236 :: 		value = (M[k]+((VMmed-M[k])*2))-(VMmed);
	MOV	_k, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	_VMmed, W0
	SUB	W0, [W1], W0
	SL	W0, #1, W0
	ADD	W0, [W1], W2
	MOV	#lo_addr(_VMmed), W1
	MOV	#lo_addr(_value), W0
	SUB	W2, [W1], [W0]
;ADC_DAC.c,237 :: 		}
L_main23:
;ADC_DAC.c,245 :: 		x0 = (float)(value);                             //Adquisici�n de una muestra de 10 bits en, x[0].
	MOV	_value, W0
	CLR	W1
	CALL	__Long2Float
	MOV	W0, _x0
	MOV	W1, _x0+2
;ADC_DAC.c,246 :: 		y0 = ((x0+x2)*ca1)+(x1*ca2)-(y1*cb2)-(y2*cb3);       //Implementaci�n de la ecuaci�n en diferencias
	MOV	_x2, W2
	MOV	_x2+2, W3
	CALL	__AddSub_FP
	MOV	#2982, W2
	MOV	#15325, W3
	CALL	__Mul_FP
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	_x1, W0
	MOV	_x1+2, W1
	MOV	#2982, W2
	MOV	#15453, W3
	CALL	__Mul_FP
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	_y1, W0
	MOV	_y1+2, W1
	MOV	#38540, W2
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
	MOV	#5493, W2
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
;ADC_DAC.c,248 :: 		y2 = y1;                                             //Corrimiento de los valores x(n), y y(n).
	MOV	_y1, W2
	MOV	_y1+2, W3
	MOV	W2, _y2
	MOV	W3, _y2+2
;ADC_DAC.c,249 :: 		y1 = y0;
	MOV	W0, _y1
	MOV	W1, _y1+2
;ADC_DAC.c,250 :: 		x2 = x1;
	MOV	_x1, W2
	MOV	_x1+2, W3
	MOV	W2, _x2
	MOV	W3, _x2+2
;ADC_DAC.c,251 :: 		x1 = x0;
	MOV	_x0, W2
	MOV	_x0+2, W3
	MOV	W2, _x1
	MOV	W3, _x1+2
;ADC_DAC.c,253 :: 		YY = (unsigned int)(y0);                             //Reconstrucci�n de la se�al: y en 10 bits.
	CALL	__Float2Longint
	MOV	W0, _YY
;ADC_DAC.c,255 :: 		R[k] = YY;
	MOV	_k, W1
	SL	W1, #1, W2
	MOV	#lo_addr(_R), W1
	ADD	W1, W2, W1
	MOV	W0, [W1]
;ADC_DAC.c,230 :: 		for (k=0;k<nm;k++){
	MOV	#1, W1
	MOV	#lo_addr(_k), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,257 :: 		}
	GOTO	L_main20
L_main21:
;ADC_DAC.c,259 :: 		T1CON.TON = 1;                                           //Enciende el TMR1
	BSET	T1CON, #15
;ADC_DAC.c,260 :: 		IEC0.T1IE = 1;                                           //Habilita la interrupcion por desborde del TMR1
	BSET	IEC0, #3
;ADC_DAC.c,262 :: 		}
L_main19:
;ADC_DAC.c,264 :: 		Delay_ms(10);
	MOV	#3, W8
	MOV	#2261, W7
L_main24:
	DEC	W7
	BRA NZ	L_main24
	DEC	W8
	BRA NZ	L_main24
;ADC_DAC.c,266 :: 		}
	GOTO	L_main16
;ADC_DAC.c,268 :: 		}
L_end_main:
	ULNK
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
