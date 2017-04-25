
_Velocidad:
	LNK	#4

;ADC_DAC.c,65 :: 		void Velocidad(){
;ADC_DAC.c,70 :: 		Ow_Reset(&PORTA, 0);                        //Onewire reset signal
	PUSH	W10
	PUSH	W11
	PUSH	W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;ADC_DAC.c,71 :: 		Ow_Write(&PORTA, 0, 0xCC);                  //Issue command SKIP_ROM
	MOV.B	#204, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,72 :: 		Ow_Write(&PORTA, 0, 0x44);                  //Issue command CONVERT_T
	MOV.B	#68, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,73 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad0:
	DEC	W7
	BRA NZ	L_Velocidad0
	NOP
;ADC_DAC.c,75 :: 		Ow_Reset(&PORTA, 0);
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;ADC_DAC.c,76 :: 		Ow_Write(&PORTA, 0, 0xCC);                  //Issue command SKIP_ROM
	MOV.B	#204, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,77 :: 		Ow_Write(&PORTA, 0, 0xBE);                  //Issue command READ_SCRATCHPAD
	MOV.B	#190, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,78 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad2:
	DEC	W7
	BRA NZ	L_Velocidad2
	NOP
;ADC_DAC.c,80 :: 		Temp =  Ow_Read(&PORTA, 0);
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
; Temp start address is: 10 (W5)
	ZE	W0, W5
;ADC_DAC.c,81 :: 		Temp = (Ow_Read(&PORTA, 0) << 8) + Temp;
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
	ZE	W0, W0
	SL	W0, #8, W0
	ADD	W0, W5, W0
; Temp end address is: 10 (W5)
; Temp start address is: 4 (W2)
	MOV	W0, W2
;ADC_DAC.c,83 :: 		if (Temp & 0x8000) {
	BTSS	W0, #15
	GOTO	L__Velocidad45
;ADC_DAC.c,84 :: 		Temp = 0;                                //Si la temperatura es negativa la establece como cero.
	CLR	W2
; Temp end address is: 4 (W2)
;ADC_DAC.c,85 :: 		}
	GOTO	L_Velocidad4
L__Velocidad45:
;ADC_DAC.c,83 :: 		if (Temp & 0x8000) {
;ADC_DAC.c,85 :: 		}
L_Velocidad4:
;ADC_DAC.c,87 :: 		Rint = Temp >> 4;                           //Extrae la parte entera de la respuesta del sensor
; Temp start address is: 4 (W2)
	LSR	W2, #4, W0
; Rint start address is: 6 (W3)
	MOV	W0, W3
;ADC_DAC.c,88 :: 		Rfrac = ((Temp & 0x000F) * 625) / 10000.;   //Extrae la parte decimal de la respuesta del sensor
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
;ADC_DAC.c,89 :: 		DSTemp = Rint + Rfrac;
	MOV	W3, W0
	CLR	W1
	CALL	__Long2Float
; Rint end address is: 6 (W3)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	MOV	W0, _DSTemp
	MOV	W1, _DSTemp+2
;ADC_DAC.c,91 :: 		VSnd = 331.45 * sqrt(1+(DsTemp/273));       //Expresa la temperatura en punto flotante
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
;ADC_DAC.c,92 :: 		}
L_end_Velocidad:
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _Velocidad

_Pulse:
	LNK	#12

;ADC_DAC.c,95 :: 		void Pulse(){
;ADC_DAC.c,100 :: 		contp = 0;                                               //Limpia la variable del contador de pulsos
	CLR	W0
	MOV	W0, _contp
;ADC_DAC.c,101 :: 		RB2_bit = 0;                                            //Limpia el pin que produce los pulsos de exitacion del transductor
	BCLR	RB2_bit, BitPos(RB2_bit+0)
;ADC_DAC.c,103 :: 		T1CON.TON = 0;                                           //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,104 :: 		IEC0.T1IE = 0;                                           //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,106 :: 		TMR2 = 0;                                                //Encera el TMR2
	CLR	TMR2
;ADC_DAC.c,107 :: 		IEC0.T2IE = 1;                                           //Habilita la interrupcion por desborde del TMR2
	BSET	IEC0, #7
;ADC_DAC.c,108 :: 		T2CON.TON = 1;                                           //Enciende el TMR2
	BSET	T2CON, #15
;ADC_DAC.c,110 :: 		i = 0;                                                   //Limpia las variables asociadas al almacenamiento de la señal muestreada
	CLR	W0
	MOV	W0, _i
;ADC_DAC.c,111 :: 		j = 0;
	CLR	W0
	MOV	W0, _j
;ADC_DAC.c,115 :: 		while(bm!=1);                                                //Espera hasta que haya terminado de enviar y recibir todas las muestras
L_Pulse5:
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA NZ	L__Pulse48
	GOTO	L_Pulse6
L__Pulse48:
	GOTO	L_Pulse5
L_Pulse6:
;ADC_DAC.c,118 :: 		if (bm==1){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__Pulse49
	GOTO	L_Pulse7
L__Pulse49:
;ADC_DAC.c,121 :: 		Mmax = Vector_Max(M, nm, &MIndexMax);
	MOV	#lo_addr(_MIndexMax), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Max
	SUB	#6, W15
	MOV	W0, _Mmax
;ADC_DAC.c,122 :: 		Mmin = Vector_Min(M, nm, &MIndexMin);
	MOV	#lo_addr(_MIndexMin), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Min
	SUB	#6, W15
	MOV	W0, _Mmin
;ADC_DAC.c,123 :: 		Mmed = Mmax-((Mmax-Mmin)/2);
	MOV	#lo_addr(_Mmax), W1
	SUBR	W0, [W1], W0
	LSR	W0, #1, W2
	MOV	#lo_addr(_Mmax), W1
	MOV	#lo_addr(_Mmed), W0
	SUBR	W2, [W1], [W0]
;ADC_DAC.c,125 :: 		for (k=0;k<nm;k++){
	CLR	W0
	MOV	W0, _k
L_Pulse8:
	MOV	_k, W1
	MOV	#350, W0
	CP	W1, W0
	BRA LTU	L__Pulse50
	GOTO	L_Pulse9
L__Pulse50:
;ADC_DAC.c,128 :: 		value = M[k]-Mmed;
	MOV	_k, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W3
	MOV	[W3], W2
	MOV	#lo_addr(_Mmed), W1
	MOV	#lo_addr(_value), W0
	SUB	W2, [W1], [W0]
;ADC_DAC.c,129 :: 		if (M[k]<Mmed){
	MOV	[W3], W1
	MOV	#lo_addr(_Mmed), W0
	CP	W1, [W0]
	BRA LTU	L__Pulse51
	GOTO	L_Pulse11
L__Pulse51:
;ADC_DAC.c,130 :: 		value = (M[k]+((Mmed-M[k])*2))-(Mmed);
	MOV	_k, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	_Mmed, W0
	SUB	W0, [W1], W0
	SL	W0, #1, W0
	ADD	W0, [W1], W2
	MOV	#lo_addr(_Mmed), W1
	MOV	#lo_addr(_value), W0
	SUB	W2, [W1], [W0]
;ADC_DAC.c,131 :: 		}
L_Pulse11:
;ADC_DAC.c,134 :: 		x0 = (float)(value);                                 //Adquisición de una muestra de 10 bits en, x[0].
	MOV	_value, W0
	CLR	W1
	CALL	__Long2Float
	MOV	W0, _x0
	MOV	W1, _x0+2
;ADC_DAC.c,135 :: 		y0 = ((x0+x2)*ca1)+(x1*ca2)-(y1*cb2)-(y2*cb3);       //Implementación de la ecuación en diferencias
	MOV	_x2, W2
	MOV	_x2+2, W3
	CALL	__AddSub_FP
	MOV	#58496, W2
	MOV	#15250, W3
	CALL	__Mul_FP
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	_x1, W0
	MOV	_x1+2, W1
	MOV	#58496, W2
	MOV	#15378, W3
	CALL	__Mul_FP
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	_y1, W0
	MOV	_y1+2, W1
	MOV	#41926, W2
	MOV	#49126, W3
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
	MOV	#57007, W2
	MOV	#16209, W3
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
;ADC_DAC.c,137 :: 		y2 = y1;                                             //Corrimiento de los valores x(n), y y(n).
	MOV	_y1, W2
	MOV	_y1+2, W3
	MOV	W2, _y2
	MOV	W3, _y2+2
;ADC_DAC.c,138 :: 		y1 = y0;
	MOV	W0, _y1
	MOV	W1, _y1+2
;ADC_DAC.c,139 :: 		x2 = x1;
	MOV	_x1, W2
	MOV	_x1+2, W3
	MOV	W2, _x2
	MOV	W3, _x2+2
;ADC_DAC.c,140 :: 		x1 = x0;
	MOV	_x0, W2
	MOV	_x0+2, W3
	MOV	W2, _x1
	MOV	W3, _x1+2
;ADC_DAC.c,142 :: 		YY = (unsigned int)(y0);                             //Reconstrucción de la señal: y en 10 bits.
	CALL	__Float2Longint
	MOV	W0, _YY
;ADC_DAC.c,143 :: 		M[k] = YY;
	MOV	_k, W1
	SL	W1, #1, W2
	MOV	#lo_addr(_M), W1
	ADD	W1, W2, W1
	MOV	W0, [W1]
;ADC_DAC.c,125 :: 		for (k=0;k<nm;k++){
	MOV	#1, W1
	MOV	#lo_addr(_k), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,145 :: 		}
	GOTO	L_Pulse8
L_Pulse9:
;ADC_DAC.c,147 :: 		bm = 2;                                                  //Cambia el estado de la bandera bm para dar paso al cálculo del pmax y TOF
	MOV	#lo_addr(_bm), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,149 :: 		}
L_Pulse7:
;ADC_DAC.c,152 :: 		if (bm==2){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__Pulse52
	GOTO	L_Pulse12
L__Pulse52:
;ADC_DAC.c,154 :: 		yy1 = Vector_Max(M, nm, &maxIndex);                      //Encuentra el valor maximo del vector R
	MOV	#lo_addr(_maxIndex), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Max
	SUB	#6, W15
	MOV	W0, _yy1
;ADC_DAC.c,155 :: 		i1b = maxIndex;                                          //Asigna el subindice del valor maximo a la variable i1a
	MOV	_maxIndex, W0
	MOV	W0, _i1b
;ADC_DAC.c,156 :: 		i1a = 0;
	CLR	W0
	MOV	W0, _i1a
;ADC_DAC.c,158 :: 		while (M[i1a]<yy1){
L_Pulse13:
	MOV	_i1a, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W1
	MOV	#lo_addr(_yy1), W0
	CP	W1, [W0]
	BRA LTU	L__Pulse53
	GOTO	L_Pulse14
L__Pulse53:
;ADC_DAC.c,159 :: 		i1a++;
	MOV	#1, W1
	MOV	#lo_addr(_i1a), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,160 :: 		}
	GOTO	L_Pulse13
L_Pulse14:
;ADC_DAC.c,162 :: 		i1 = i1a+((i1b-i1a)/2);
	MOV	_i1b, W1
	MOV	#lo_addr(_i1a), W0
	SUB	W1, [W0], W0
	LSR	W0, #1, W1
	MOV	#lo_addr(_i1a), W0
	ADD	W1, [W0], W1
	MOV	W1, _i1
;ADC_DAC.c,163 :: 		i0 = i1 - dix;
	SUB	W1, #15, W0
	MOV	W0, _i0
;ADC_DAC.c,164 :: 		i2 = i1 + dix;
	ADD	W1, #15, W3
	MOV	W3, _i2
;ADC_DAC.c,166 :: 		yy0 = M[i0];
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W2
	MOV	W2, _yy0
;ADC_DAC.c,167 :: 		yy2 = M[i2];
	SL	W3, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W0
	MOV	W0, [W14+0]
	MOV	W0, _yy2
;ADC_DAC.c,169 :: 		yf0 = (float)(yy0);
	MOV	W2, W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+8]
	MOV	W1, [W14+10]
	MOV	W0, _yf0
	MOV	W1, _yf0+2
;ADC_DAC.c,170 :: 		yf1 = (float)(yy1);
	MOV	_yy1, W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	W0, _yf1
	MOV	W1, _yf1+2
;ADC_DAC.c,171 :: 		yf2 = (float)(yy2);
	MOV	[W14+0], W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	PUSH.D	W0
	MOV	[W14+0], W0
	MOV	[W14+2], W1
	MOV	W0, _yf2
	MOV	W1, _yf2+2
	POP.D	W0
;ADC_DAC.c,173 :: 		nx = (yf0-yf2)/(2.0*(yf0-(2.0*yf1)+yf2));                //Factor de ajuste determinado por interpolacion parabolica
	MOV	[W14+8], W0
	MOV	[W14+10], W1
	PUSH.D	W2
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__Sub_FP
	POP.D	W2
	MOV	[W14+4], W2
	MOV	[W14+6], W3
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	#0, W0
	MOV	#16384, W1
	CALL	__Mul_FP
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	_yf0, W0
	MOV	_yf0+2, W1
	PUSH.D	W2
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__Sub_FP
	POP.D	W2
	MOV	_yf2, W2
	MOV	_yf2+2, W3
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
;ADC_DAC.c,174 :: 		dx = nx*dix*tx;
	MOV	#0, W2
	MOV	#16752, W3
	CALL	__Mul_FP
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Mul_FP
	MOV	W0, _dx
	MOV	W1, _dx+2
;ADC_DAC.c,175 :: 		tmax = i1*tx;
	MOV	_i1, W0
	CLR	W1
	CALL	__Long2Float
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Mul_FP
	MOV	W0, _tmax
	MOV	W1, _tmax+2
;ADC_DAC.c,177 :: 		T2 = tmax+dx;
	MOV	_dx, W2
	MOV	_dx+2, W3
	CALL	__AddSub_FP
	MOV	W0, _T2
	MOV	W1, _T2+2
;ADC_DAC.c,178 :: 		imax = (unsigned int)(T2/tx);
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Div_FP
	CALL	__Float2Longint
	MOV	W0, _imax
;ADC_DAC.c,180 :: 		M[i0]=40;
	MOV	_i0, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	#40, W0
	MOV	W0, [W1]
;ADC_DAC.c,181 :: 		M[i1]=50;
	MOV	_i1, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	#50, W0
	MOV	W0, [W1]
;ADC_DAC.c,182 :: 		M[imax]=60;
	MOV	_imax, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	#60, W0
	MOV	W0, [W1]
;ADC_DAC.c,183 :: 		M[i2]=40;
	MOV	_i2, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	#40, W0
	MOV	W0, [W1]
;ADC_DAC.c,185 :: 		IEC0.T1IE = 1;                                           //Habilita la interrupcion por desborde del TMR1 para dar inicio al muestreo del ADC
	BSET	IEC0, #3
;ADC_DAC.c,186 :: 		TMR1 = 0;                                                //Encera el TMR1
	CLR	TMR1
;ADC_DAC.c,187 :: 		T1IF_bit = 0;                                            //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,188 :: 		T1CON.TON = 1;                                           //Enciende el TMR1
	BSET	T1CON, #15
;ADC_DAC.c,189 :: 		bm = 3;
	MOV	#lo_addr(_bm), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,191 :: 		}
L_Pulse12:
;ADC_DAC.c,193 :: 		while(bm!=4);
L_Pulse15:
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #4
	BRA NZ	L__Pulse54
	GOTO	L_Pulse16
L__Pulse54:
	GOTO	L_Pulse15
L_Pulse16:
;ADC_DAC.c,194 :: 		}
L_end_Pulse:
	ULNK
	RETURN
; end of _Pulse

_Timer1Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,198 :: 		void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
;ADC_DAC.c,199 :: 		RB3_bit = ~RB3_bit;
	BTG	RB3_bit, BitPos(RB3_bit+0)
;ADC_DAC.c,200 :: 		if (bm==0){                                   //Cuando la bandera bm=0, la interrupcion por TMR1 es utilizada para el muestreo de la señal de entrada
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__Timer1Interrupt56
	GOTO	L_Timer1Interrupt17
L__Timer1Interrupt56:
;ADC_DAC.c,201 :: 		SAMP_bit = 0;                              //Limpia el bit SAMP para iniciar la conversion del ADC
	BCLR	SAMP_bit, BitPos(SAMP_bit+0)
;ADC_DAC.c,202 :: 		while (!AD1CON1bits.DONE);                 //Espera hasta que se complete la conversion
L_Timer1Interrupt18:
	BTSC	AD1CON1bits, #0
	GOTO	L_Timer1Interrupt19
	GOTO	L_Timer1Interrupt18
L_Timer1Interrupt19:
;ADC_DAC.c,203 :: 		if (i<nm){
	MOV	_i, W1
	MOV	#350, W0
	CP	W1, W0
	BRA LTU	L__Timer1Interrupt57
	GOTO	L_Timer1Interrupt20
L__Timer1Interrupt57:
;ADC_DAC.c,204 :: 		M[i] = ADC1BUF0;                        //Almacena el valor actual de la conversion del ADC en el vector M
	MOV	_i, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	ADC1BUF0, WREG
	MOV	W0, [W1]
;ADC_DAC.c,205 :: 		i++;                                    //Aumenta en 1 el subindice del vector de Muestras
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,206 :: 		} else {
	GOTO	L_Timer1Interrupt21
L_Timer1Interrupt20:
;ADC_DAC.c,207 :: 		bm = 1;                                 //Cambia el valor de la bandera bm para terminar con el muestreo y dar comienzo al procesamiento de la señal
	MOV	#lo_addr(_bm), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,208 :: 		T1CON.TON = 0;                          //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,209 :: 		IEC0.T1IE = 0;                          //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,210 :: 		}
L_Timer1Interrupt21:
;ADC_DAC.c,211 :: 		}
L_Timer1Interrupt17:
;ADC_DAC.c,213 :: 		if (bm==3) {                                  //Cuando la bandera bm=3, la interrupcion por TMR1 es utilizada para la reconstruccion de la señal mediante el DAC
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA Z	L__Timer1Interrupt58
	GOTO	L_Timer1Interrupt22
L__Timer1Interrupt58:
;ADC_DAC.c,214 :: 		if (j<nm){
	MOV	_j, W1
	MOV	#350, W0
	CP	W1, W0
	BRA LTU	L__Timer1Interrupt59
	GOTO	L_Timer1Interrupt23
L__Timer1Interrupt59:
;ADC_DAC.c,216 :: 		j++;
	MOV	#1, W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,217 :: 		} else {
	GOTO	L_Timer1Interrupt24
L_Timer1Interrupt23:
;ADC_DAC.c,218 :: 		bm = 4;                               //Cambia el valor de la bandera bm para terminar con el muestreo y dar comienzo al procesamiento de la señal
	MOV	#lo_addr(_bm), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,219 :: 		T1CON.TON = 0;                        //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,220 :: 		IEC0.T1IE = 0;                        //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,221 :: 		}
L_Timer1Interrupt24:
;ADC_DAC.c,222 :: 		}
L_Timer1Interrupt22:
;ADC_DAC.c,223 :: 		T1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,224 :: 		}
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

;ADC_DAC.c,226 :: 		void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
;ADC_DAC.c,227 :: 		if (contp<10){                                //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (
	MOV	_contp, W0
	CP	W0, #10
	BRA LTU	L__Timer2Interrupt61
	GOTO	L_Timer2Interrupt25
L__Timer2Interrupt61:
;ADC_DAC.c,228 :: 		RB2_bit = ~RB2_bit;                    //Conmuta el valor del pin RB14
	BTG	RB2_bit, BitPos(RB2_bit+0)
;ADC_DAC.c,229 :: 		}else {
	GOTO	L_Timer2Interrupt26
L_Timer2Interrupt25:
;ADC_DAC.c,230 :: 		RB2_bit = 0;                            //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCLR	RB2_bit, BitPos(RB2_bit+0)
;ADC_DAC.c,232 :: 		if (contp==110){
	MOV	#110, W1
	MOV	#lo_addr(_contp), W0
	CP	W1, [W0]
	BRA Z	L__Timer2Interrupt62
	GOTO	L_Timer2Interrupt27
L__Timer2Interrupt62:
;ADC_DAC.c,233 :: 		IEC0.T2IE = 0;                       //Desabilita la interrupcion por desborde del TMR2 para no interferir con las interrupciones por desborde de TMR1 y por conversion completa del ADC
	BCLR	IEC0, #7
;ADC_DAC.c,234 :: 		T2CON.TON = 0;                       //Apaga el TMR2
	BCLR	T2CON, #15
;ADC_DAC.c,235 :: 		IEC0.T1IE = 1;                       //Habilita la interrupcion por desborde del TMR1 para dar inicio al muestreo del ADC
	BSET	IEC0, #3
;ADC_DAC.c,236 :: 		TMR1 = 0;                            //Encera el TMR1
	CLR	TMR1
;ADC_DAC.c,237 :: 		T1IF_bit = 0;                        //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,238 :: 		T1CON.TON = 1;                       //Enciende el TMR1
	BSET	T1CON, #15
;ADC_DAC.c,239 :: 		bm=0;
	MOV	#lo_addr(_bm), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,240 :: 		}
L_Timer2Interrupt27:
;ADC_DAC.c,242 :: 		}
L_Timer2Interrupt26:
;ADC_DAC.c,243 :: 		contp++;                                      //Aumenta el contador en una unidad.
	MOV	#1, W1
	MOV	#lo_addr(_contp), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,244 :: 		T2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,245 :: 		}
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

;ADC_DAC.c,249 :: 		void Configuracion(){
;ADC_DAC.c,252 :: 		CLKDIVbits.PLLPRE = 0;                      //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,253 :: 		PLLFBD = 38;                                //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
	MOV	#38, W0
	MOV	WREG, PLLFBD
;ADC_DAC.c,254 :: 		CLKDIVbits.PLLPOST = 0;                     //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,257 :: 		AD1PCFGL = 0xFFFD;                          //Configura el puerto AN1 como entrada analogica y todas las demas como digitales
	MOV	#65533, W0
	MOV	WREG, AD1PCFGL
;ADC_DAC.c,258 :: 		TRISA0_bit = 1;                             //Set RA0 pin as input
	BSET	TRISA0_bit, BitPos(TRISA0_bit+0)
;ADC_DAC.c,259 :: 		TRISA4_bit = 1;                             //Set RA4 pin as input
	BSET	TRISA4_bit, BitPos(TRISA4_bit+0)
;ADC_DAC.c,260 :: 		TRISB = 0x00;                             //TRISB = 11111111 00000000
	CLR	TRISB
;ADC_DAC.c,263 :: 		AD1CON1.AD12B = 0;                          //Configura el ADC en modo de 10 bits
	BCLR	AD1CON1, #10
;ADC_DAC.c,264 :: 		AD1CON1bits.FORM = 0x00;                    //Formato de la canversion: 00->(0_1023)|01->(-512_511)|02->(0_0.999)|03->(-1_0.999)
	MOV	AD1CON1bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON1bits
;ADC_DAC.c,265 :: 		AD1CON1.SIMSAM = 0;                         //0 -> Muestrea múltiples canales individualmente en secuencia
	BCLR	AD1CON1, #3
;ADC_DAC.c,266 :: 		AD1CON1.ADSIDL = 0;                         //Continua con la operacion del modulo durante el modo desocupado
	BCLR	AD1CON1, #13
;ADC_DAC.c,267 :: 		AD1CON1.ASAM = 1;                           //Muestreo automatico
	BSET	AD1CON1, #2
;ADC_DAC.c,268 :: 		AD1CON1bits.SSRC = 0x00;                    //Conversion manual
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	[W0], W1
	MOV.B	#31, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,270 :: 		AD1CON2bits.VCFG = 0;                       //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
	MOV	AD1CON2bits, W1
	MOV	#8191, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,271 :: 		AD1CON2bits.CHPS = 0;                       //Selecciona unicamente el canal CH0
	MOV	AD1CON2bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,272 :: 		AD1CON2.CSCNA = 0;                          //No escanea las entradas de CH0 durante la Muestra A
	BCLR	AD1CON2, #10
;ADC_DAC.c,273 :: 		AD1CON2.BUFM = 0;                           //Bit de selección del modo de relleno del búfer, 0 -> Siempre comienza a llenar el buffer desde el principio
	BCLR	AD1CON2, #1
;ADC_DAC.c,274 :: 		AD1CON2.ALTS = 0x00;                        //Utiliza siempre la selección de entrada de canal para la muestra A
	BCLR	AD1CON2, #0
;ADC_DAC.c,276 :: 		AD1CON3.ADRC = 0;                           //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
	BCLR	AD1CON3, #15
;ADC_DAC.c,277 :: 		AD1CON3bits.ADCS = 0x02;                    //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
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
;ADC_DAC.c,278 :: 		AD1CON3bits.SAMC = 0x02;                    //Auto Sample Time bits, 2 -> 2*TAD (minimo periodo de muestreo para 10 bits)
	MOV	#512, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CON3bits
;ADC_DAC.c,280 :: 		AD1CHS0.CH0NB = 0;                          //Channel 0 negative input is VREF-
	BCLR	AD1CHS0, #15
;ADC_DAC.c,281 :: 		AD1CHS0bits.CH0SB = 0x01;                   //Channel 0 positive input is AN1
	MOV	#256, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CHS0bits
;ADC_DAC.c,282 :: 		AD1CHS0.CH0NA = 0;                          //Channel 0 negative input is VREF-
	BCLR	AD1CHS0, #7
;ADC_DAC.c,283 :: 		AD1CHS0bits.CH0SA = 0x01;                   //Channel 0 positive input is AN1
	MOV.B	#1, W0
	MOV.B	W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(AD1CHS0bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,285 :: 		AD1CHS123 = 0;                              //AD1CHS123: ADC1 INPUT CHANNEL 1, 2, 3 SELECT REGISTER
	CLR	AD1CHS123
;ADC_DAC.c,287 :: 		AD1CSSL = 0x00;                             //Se salta todos los puertos ANx para los escaneos de entrada
	CLR	AD1CSSL
;ADC_DAC.c,289 :: 		AD1CON1.ADON = 1;                           //Enciende el modulo ADC
	BSET	AD1CON1, #15
;ADC_DAC.c,292 :: 		T1CON = 0x8000;                             //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T1CON
;ADC_DAC.c,293 :: 		IEC0.T1IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR1 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #3
;ADC_DAC.c,294 :: 		T1IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,295 :: 		PR1 = 200;                                  //Genera una interrupcion cada 5us (Fs=200KHz)
	MOV	#200, W0
	MOV	WREG, PR1
;ADC_DAC.c,298 :: 		T2CON = 0x8000;                             //Habilita el TMR2, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T2CON
;ADC_DAC.c,299 :: 		IEC0.T2IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR2 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #7
;ADC_DAC.c,300 :: 		T2IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,301 :: 		PR2 = 500;                                  //Genera una interrupcion cada 12.5us
	MOV	#500, W0
	MOV	WREG, PR2
;ADC_DAC.c,304 :: 		IPC0bits.T1IP = 0x07;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR1
	MOV	IPC0bits, W1
	MOV	#28672, W0
	IOR	W1, W0, W0
	MOV	WREG, IPC0bits
;ADC_DAC.c,305 :: 		IPC1bits.T2IP = 0x06;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR2
	MOV	#24576, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;ADC_DAC.c,308 :: 		RPINR18bits.U1RXR = 0x07;                   //Asisgna Rx a RP7
	MOV.B	#7, W0
	MOV.B	W0, W1
	MOV	#lo_addr(RPINR18bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(RPINR18bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(RPINR18bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,309 :: 		RPOR3bits.RP6R = 0x03;                      //Asigna Tx a RP6
	MOV.B	#3, W0
	MOV.B	W0, W1
	MOV	#lo_addr(RPOR3bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(RPOR3bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(RPOR3bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,311 :: 		}
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

;ADC_DAC.c,315 :: 		void main() {
;ADC_DAC.c,317 :: 		Configuracion();
	PUSH	W10
	PUSH	W11
	CALL	_Configuracion
;ADC_DAC.c,319 :: 		UART1_Init(9600);               // Initialize UART module at 9600 bps
	MOV	#9600, W10
	MOV	#0, W11
	CALL	_UART1_Init
;ADC_DAC.c,320 :: 		Delay_ms(100);                  // Wait for UART module to stabilize
	MOV	#21, W8
	MOV	#22619, W7
L_main28:
	DEC	W7
	BRA NZ	L_main28
	DEC	W8
	BRA NZ	L_main28
;ADC_DAC.c,322 :: 		while(1){
L_main30:
;ADC_DAC.c,324 :: 		UART1_Write(0x00);                       //Indica el comienzo de una secuencia
	CLR	W10
	CALL	_UART1_Write
;ADC_DAC.c,325 :: 		UART1_Write(0x0D);
	MOV	#13, W10
	CALL	_UART1_Write
;ADC_DAC.c,327 :: 		Pulse();
	CALL	_Pulse
;ADC_DAC.c,329 :: 		for (j=0;j<nm;j++){
	CLR	W0
	MOV	W0, _j
L_main32:
	MOV	_j, W1
	MOV	#350, W0
	CP	W1, W0
	BRA LTU	L__main65
	GOTO	L_main33
L__main65:
;ADC_DAC.c,330 :: 		while(UART_Tx_Idle()==0);           //Espera hasta que se haya terminado de enviar todos los datos antes de continuar
L_main35:
	CALL	_UART_Tx_Idle
	CP	W0, #0
	BRA Z	L__main66
	GOTO	L_main36
L__main66:
	GOTO	L_main35
L_main36:
;ADC_DAC.c,331 :: 		TT2 = M[j];                         //Guarda cada uno de los valores de M en TT2
	MOV	_j, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W0
	CLR	W1
	MOV	W0, _TT2
	MOV	W1, _TT2+2
;ADC_DAC.c,332 :: 		chT2 = (unsigned char *) & TT2;
	MOV	#lo_addr(_TT2), W0
	MOV	W0, _chT2
;ADC_DAC.c,333 :: 		for (l=0;l<2;l++){                  //Genera la trama de 2 Bytes
	MOV	#lo_addr(_l), W1
	CLR	W0
	MOV.B	W0, [W1]
L_main37:
	MOV	#lo_addr(_l), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA LT	L__main67
	GOTO	L_main38
L__main67:
;ADC_DAC.c,334 :: 		trama[l]=(*chT2++);
	MOV	#lo_addr(_l), W0
	SE	[W0], W1
	MOV	#lo_addr(_trama), W0
	ADD	W0, W1, W1
	MOV	_chT2, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chT2), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,333 :: 		for (l=0;l<2;l++){                  //Genera la trama de 2 Bytes
	MOV.B	#1, W1
	MOV	#lo_addr(_l), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,335 :: 		}
	GOTO	L_main37
L_main38:
;ADC_DAC.c,336 :: 		for (l=1;l>=0;l--){                 //Envia la trama de 2 Bytes
	MOV	#lo_addr(_l), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
L_main40:
	MOV	#lo_addr(_l), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA GE	L__main68
	GOTO	L_main41
L__main68:
;ADC_DAC.c,337 :: 		UART1_Write(trama[l]);
	MOV	#lo_addr(_l), W0
	SE	[W0], W1
	MOV	#lo_addr(_trama), W0
	ADD	W0, W1, W0
	ZE	[W0], W10
	CALL	_UART1_Write
;ADC_DAC.c,336 :: 		for (l=1;l>=0;l--){                 //Envia la trama de 2 Bytes
	MOV.B	#1, W1
	MOV	#lo_addr(_l), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,338 :: 		}
	GOTO	L_main40
L_main41:
;ADC_DAC.c,339 :: 		UART1_Write(0x0D);                  //Salto de linea
	MOV	#13, W10
	CALL	_UART1_Write
;ADC_DAC.c,329 :: 		for (j=0;j<nm;j++){
	MOV	#1, W1
	MOV	#lo_addr(_j), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,340 :: 		}
	GOTO	L_main32
L_main33:
;ADC_DAC.c,342 :: 		UART1_Write(0x00);                       //Indica el fin de una secuencia
	CLR	W10
	CALL	_UART1_Write
;ADC_DAC.c,343 :: 		UART1_Write(0x0D);
	MOV	#13, W10
	CALL	_UART1_Write
;ADC_DAC.c,345 :: 		Delay_ms(10);
	MOV	#3, W8
	MOV	#2261, W7
L_main43:
	DEC	W7
	BRA NZ	L_main43
	DEC	W8
	BRA NZ	L_main43
;ADC_DAC.c,347 :: 		}
	GOTO	L_main30
;ADC_DAC.c,349 :: 		}
L_end_main:
	POP	W11
	POP	W10
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
