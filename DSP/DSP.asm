
_Velocidad:
	LNK	#4

;DSP.c,45 :: 		void Velocidad(){
;DSP.c,50 :: 		Ow_Reset(&PORTB, 4);                        //Onewire reset signal
	PUSH	W10
	PUSH	W11
	PUSH	W12
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Reset
;DSP.c,51 :: 		Ow_Write(&PORTB, 4, 0xCC);                  //Issue command SKIP_ROM
	MOV.B	#204, W12
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;DSP.c,52 :: 		Ow_Write(&PORTB, 4, 0x44);                  //Issue command CONVERT_T
	MOV.B	#68, W12
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;DSP.c,53 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad0:
	DEC	W7
	BRA NZ	L_Velocidad0
	NOP
;DSP.c,55 :: 		Ow_Reset(&PORTB, 4);
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Reset
;DSP.c,56 :: 		Ow_Write(&PORTB, 4, 0xCC);                  //Issue command SKIP_ROM
	MOV.B	#204, W12
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;DSP.c,57 :: 		Ow_Write(&PORTB, 4, 0xBE);                  //Issue command READ_SCRATCHPAD
	MOV.B	#190, W12
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;DSP.c,58 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad2:
	DEC	W7
	BRA NZ	L_Velocidad2
	NOP
;DSP.c,60 :: 		Temp =  Ow_Read(&PORTB, 4);
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Read
; Temp start address is: 10 (W5)
	ZE	W0, W5
;DSP.c,61 :: 		Temp = (Ow_Read(&PORTB, 4) << 8) + Temp;
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Read
	ZE	W0, W0
	SL	W0, #8, W0
	ADD	W0, W5, W0
; Temp end address is: 10 (W5)
; Temp start address is: 4 (W2)
	MOV	W0, W2
;DSP.c,63 :: 		if (Temp & 0x8000) {
	BTSS	W0, #15
	GOTO	L__Velocidad11
;DSP.c,64 :: 		Temp = 0;                                //Si la temperatura es negativa la establece como cero.
	CLR	W2
; Temp end address is: 4 (W2)
;DSP.c,65 :: 		}
	GOTO	L_Velocidad4
L__Velocidad11:
;DSP.c,63 :: 		if (Temp & 0x8000) {
;DSP.c,65 :: 		}
L_Velocidad4:
;DSP.c,67 :: 		Rint = Temp >> 4;                           //Extrae la parte entera de la respuesta del sensor
; Temp start address is: 4 (W2)
	LSR	W2, #4, W0
; Rint start address is: 6 (W3)
	MOV	W0, W3
;DSP.c,68 :: 		Rfrac = ((Temp & 0x000F) * 625) / 10000.;   //Extrae la parte decimal de la respuesta del sensor
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
;DSP.c,69 :: 		DSTemp = Rint + Rfrac;
	MOV	W3, W0
	CLR	W1
	CALL	__Long2Float
; Rint end address is: 6 (W3)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	MOV	W0, _DSTemp
	MOV	W1, _DSTemp+2
;DSP.c,71 :: 		VSnd = 331.45 * sqrt(1+(DsTemp/273));       //Expresa la temperatura en punto flotante
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
;DSP.c,72 :: 		}
L_end_Velocidad:
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _Velocidad

_DAC_Output:

;DSP.c,75 :: 		void DAC_Output(unsigned int valueDAC) {
;DSP.c,78 :: 		Chip_Select = 0;                            //Seleccionar chip DAC
	BCLR	LATB1_bit, BitPos(LATB1_bit+0)
;DSP.c,81 :: 		temp = (valueDAC >> 8) & 0x0F;              //Store valueDAC[11..8] to temp[3..0]
	LSR	W10, #8, W0
	AND	W0, #15, W0
;DSP.c,82 :: 		temp |= 0x30;                               //Define DAC setting, see MCP4921 datasheet
	ZE	W0, W1
	MOV	#48, W0
	IOR	W1, W0, W0
;DSP.c,83 :: 		SPI1_Write(temp);                           //Send high byte via SPI
	PUSH	W10
	ZE	W0, W10
	CALL	_SPI1_Write
	POP	W10
;DSP.c,87 :: 		SPI1_Write(temp);                           //Send low byte via SPI
	ZE	W10, W10
	CALL	_SPI1_Write
;DSP.c,89 :: 		Chip_Select = 1;                            //Deseleccionar chip DAC
	BSET	LATB1_bit, BitPos(LATB1_bit+0)
;DSP.c,90 :: 		}
L_end_DAC_Output:
	RETURN
; end of _DAC_Output

_Timer1Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;DSP.c,96 :: 		void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
;DSP.c,97 :: 		if (contp<20){                              //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (42)
	MOV	_contp, W0
	CP	W0, #20
	BRA LTU	L__Timer1Interrupt15
	GOTO	L_Timer1Interrupt5
L__Timer1Interrupt15:
;DSP.c,98 :: 		BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
	MOV	#lo_addr(_BS), W0
	MOV.B	[W0], W0
	COM.B	W0, W1
	MOV	#lo_addr(_BS), W0
	MOV.B	W1, [W0]
;DSP.c,99 :: 		RB0_bit = BS;
	BTSS	W1, #0
	BCLR	RB0_bit, BitPos(RB0_bit+0)
	BTSC	W1, #0
	BSET	RB0_bit, BitPos(RB0_bit+0)
;DSP.c,100 :: 		}else {
	GOTO	L_Timer1Interrupt6
L_Timer1Interrupt5:
;DSP.c,101 :: 		RB0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCLR	RB0_bit, BitPos(RB0_bit+0)
;DSP.c,102 :: 		T1CON.TON = 0;
	BCLR	T1CON, #15
;DSP.c,103 :: 		}
L_Timer1Interrupt6:
;DSP.c,105 :: 		contp++;                                    //Aumenta el contador en una unidad.
	MOV	#1, W1
	MOV	#lo_addr(_contp), W0
	ADD	W1, [W0], [W0]
;DSP.c,106 :: 		T1IF_bit = 0;                               //Limpia la bandera de interrupcion de Timer2
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;DSP.c,107 :: 		}
L_end_Timer1Interrupt:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _Timer1Interrupt

_ADC1Int:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;DSP.c,110 :: 		void ADC1Int() org IVT_ADDR_ADC1INTERRUPT {
;DSP.c,111 :: 		DAC_Output(ADC1BUF0);                         //Invoca a la funcion de control del DAC
	PUSH	W10
	MOV	ADC1BUF0, W10
	CALL	_DAC_Output
;DSP.c,112 :: 		AD1IF_bit = 0;                                //Limpia la bandera de interrupcion del ADC
	BCLR	AD1IF_bit, BitPos(AD1IF_bit+0)
;DSP.c,113 :: 		}
L_end_ADC1Int:
	POP	W10
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _ADC1Int

_Configuracion:

;DSP.c,117 :: 		void Configuracion(){
;DSP.c,120 :: 		CLKDIVbits.PLLPRE = 0;                      //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;DSP.c,121 :: 		PLLFBD = 41;                                //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
	MOV	#41, W0
	MOV	WREG, PLLFBD
;DSP.c,122 :: 		CLKDIVbits.PLLPOST = 0;                     //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;DSP.c,125 :: 		TRISB0_bit = 0;                             //Establece el pin B0 como salida
	BCLR	TRISB0_bit, BitPos(TRISB0_bit+0)
;DSP.c,126 :: 		TRISA0_bit = 1;
	BSET	TRISA0_bit, BitPos(TRISA0_bit+0)
;DSP.c,127 :: 		LATB0_bit = 0;                              //Limpia el pin A3
	BCLR	LATB0_bit, BitPos(LATB0_bit+0)
;DSP.c,130 :: 		T1CON = 0x8000;                             //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T1CON
;DSP.c,131 :: 		T1IE_bit = 1;                               //Habilita la interrupcion por desborde de TMR1
	BSET	T1IE_bit, BitPos(T1IE_bit+0)
;DSP.c,132 :: 		T1IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;DSP.c,133 :: 		IPC0bits.T1IP = 0x01;                       //Establece el nivel de prioridad de la interrupcion
	MOV	#4096, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC0bits
;DSP.c,134 :: 		PR1 = 495;                                  //Precarga del TMR1
	MOV	#495, W0
	MOV	WREG, PR1
;DSP.c,137 :: 		AD1CON1.AD12B = 0;                          //Configura el ADC en modo de 10 bits
	BCLR	AD1CON1, #10
;DSP.c,138 :: 		AD1CON1bits.SSRC = 0x07;                    //Internal counter ends sampling and starts conversion (auto-convert)
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	IOR.B	W1, W0, W1
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	W1, [W0]
;DSP.c,139 :: 		AD1CON1bits.FORM = 0x01;                    //Selecciona el formato en que se presentaran los resultados de conversion, 01->Entero con signo(-512_511)
	MOV	#256, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CON1bits), W0
	XOR	W1, [W0], W1
	MOV	#768, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CON1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CON1bits
;DSP.c,140 :: 		AD1CON1.ASAM = 0;                           //El muestreo comienza cuando se ajusta el bit SAMP (Para muestreo manual)
	BCLR	AD1CON1, #2
;DSP.c,141 :: 		AD1CON1.SIMSAM = 0;                         //0 -> Muestrea múltiples canales individualmente en secuencia
	BCLR	AD1CON1, #3
;DSP.c,142 :: 		AD1CON1.ADSIDL = 0;                         //Continua con la operacion del modulo durante el modo desocupado
	BCLR	AD1CON1, #13
;DSP.c,144 :: 		AD1CON2bits.VCFG = 0;                       //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
	MOV	AD1CON2bits, W1
	MOV	#8191, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;DSP.c,145 :: 		AD1CON2bits.CHPS = 0x00;                    //Selecciona unicamente el canal CH0
	MOV	AD1CON2bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;DSP.c,146 :: 		AD1CON2.CSCNA = 0;                          //No escanea las entradas de CH0 durante la Muestra A
	BCLR	AD1CON2, #10
;DSP.c,147 :: 		AD1CON2bits.SMPI = 0;                       //Sample/Convert Sequences Per Interrupt Selection bits
	MOV	#lo_addr(AD1CON2bits), W0
	MOV.B	[W0], W1
	MOV.B	#195, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON2bits), W0
	MOV.B	W1, [W0]
;DSP.c,148 :: 		AD1CON2.BUFM = 0;                           //Bit de selección del modo de relleno del búfer, 0 -> Siempre comienza a llenar el buffer desde el principio
	BCLR	AD1CON2, #1
;DSP.c,149 :: 		AD1CON2.ALTS = 0x00;                        //Utiliza siempre la selección de entrada de canal para la muestra A
	BCLR	AD1CON2, #0
;DSP.c,151 :: 		AD1CON3.ADRC = 0;                           //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
	BCLR	AD1CON3, #15
;DSP.c,152 :: 		AD1CON3bits.ADCS = 0x02;                    //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
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
;DSP.c,153 :: 		AD1CON3bits.SAMC = 0;                       //Auto Sample Time bits, 0 -> 0 TAD
	MOV	AD1CON3bits, W1
	MOV	#57599, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON3bits
;DSP.c,155 :: 		AD1CHS0 = 0;                                //ADC1 INPUT CHANNEL 0 SELECT REGISTER
	CLR	AD1CHS0
;DSP.c,156 :: 		AD1CHS123 = 0;                              //AD1CHS123: ADC1 INPUT CHANNEL 1, 2, 3 SELECT REGISTER
	CLR	AD1CHS123
;DSP.c,158 :: 		AD1PCFGL = 0xFFFE;                          //Configura el puerto AN0 como entrada analogica y todas las demas como digitales
	MOV	#65534, W0
	MOV	WREG, AD1PCFGL
;DSP.c,159 :: 		AD1CSSL = 0x00;                             //Se salta todos los puertos ANx para los escaneos de entrada
	CLR	AD1CSSL
;DSP.c,161 :: 		IEC0.AD1IE = 0x00;                          //Activa la interrupcion por conversion completa del ADC
	BCLR	IEC0, #13
;DSP.c,162 :: 		IPC3bits.AD1IP = 1;                         //Nivel de prioridad de interrupcion del ADC = 1
	MOV.B	#16, W0
	MOV.B	W0, W1
	MOV	#lo_addr(IPC3bits), W0
	XOR.B	W1, [W0], W1
	MOV.B	#112, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(IPC3bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(IPC3bits), W0
	MOV.B	W1, [W0]
;DSP.c,164 :: 		AD1CON1.ADON = 1;                           //Enciende el modulo ADC
	BSET	AD1CON1, #15
;DSP.c,167 :: 		SPI1_Init();                                //Inicializa el modulo DAC
	CALL	_SPI1_Init
;DSP.c,170 :: 		BS = 0;
	MOV	#lo_addr(_BS), W1
	CLR	W0
	MOV.B	W0, [W1]
;DSP.c,171 :: 		contp = 0;
	CLR	W0
	MOV	W0, _contp
;DSP.c,180 :: 		}
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

;DSP.c,183 :: 		void main(){
;DSP.c,185 :: 		Configuracion();
	PUSH	W10
	CALL	_Configuracion
;DSP.c,188 :: 		while (1){
L_main7:
;DSP.c,190 :: 		Velocidad();
	CALL	_Velocidad
;DSP.c,192 :: 		T1CON.TON = 1;
	BSET	T1CON, #15
;DSP.c,193 :: 		contp = 0;
	CLR	W0
	MOV	W0, _contp
;DSP.c,194 :: 		BS = 0;
	MOV	#lo_addr(_BS), W1
	CLR	W0
	MOV.B	W0, [W1]
;DSP.c,196 :: 		DAC_Output(ADC1BUF0);
	MOV	ADC1BUF0, W10
	CALL	_DAC_Output
;DSP.c,198 :: 		Delay_ms(15);
	MOV	#4, W8
	MOV	#3392, W7
L_main9:
	DEC	W7
	BRA NZ	L_main9
	DEC	W8
	BRA NZ	L_main9
;DSP.c,200 :: 		}
	GOTO	L_main7
;DSP.c,202 :: 		}
L_end_main:
	POP	W10
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
