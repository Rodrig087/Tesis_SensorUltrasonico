
_Velocidad:

;ADC_DAC.c,77 :: 		void Velocidad(){
;ADC_DAC.c,82 :: 		Ow_Reset(&PORTA, 0);                          //Onewire reset signal
	PUSH	W10
	PUSH	W11
	PUSH	W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;ADC_DAC.c,83 :: 		Ow_Write(&PORTA, 0, 0xCC);                    //Issue command SKIP_ROM
	MOV.B	#204, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,84 :: 		Ow_Write(&PORTA, 0, 0x44);                    //Issue command CONVERT_T
	MOV.B	#68, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,85 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad0:
	DEC	W7
	BRA NZ	L_Velocidad0
	NOP
;ADC_DAC.c,87 :: 		Ow_Reset(&PORTA, 0);
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;ADC_DAC.c,88 :: 		Ow_Write(&PORTA, 0, 0xCC);                    //Issue command SKIP_ROM
	MOV.B	#204, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,89 :: 		Ow_Write(&PORTA, 0, 0xBE);                    //Issue command READ_SCRATCHPAD
	MOV.B	#190, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,90 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad2:
	DEC	W7
	BRA NZ	L_Velocidad2
	NOP
;ADC_DAC.c,92 :: 		Temp =  Ow_Read(&PORTA, 0);
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
; Temp start address is: 10 (W5)
	ZE	W0, W5
;ADC_DAC.c,93 :: 		Temp = (Ow_Read(&PORTA, 0) << 8) + Temp;
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
	ZE	W0, W0
	SL	W0, #8, W0
	ADD	W0, W5, W0
; Temp end address is: 10 (W5)
;ADC_DAC.c,95 :: 		if (Temp & 0x8000) {
	BTSS	W0, #15
	GOTO	L_Velocidad4
;ADC_DAC.c,97 :: 		}
L_Velocidad4:
;ADC_DAC.c,102 :: 		DSTemp = 17.0;                                //Temperatura Arduino
	MOV	#0, W0
	MOV	#16776, W1
	MOV	W0, _DSTemp
	MOV	W1, _DSTemp+2
;ADC_DAC.c,104 :: 		VSnd = 331.45 * sqrt(1+(DsTemp/273));         //Expresa la temperatura en punto flotante
	MOV	#63616, W10
	MOV	#16263, W11
	CALL	_sqrt
	MOV	#47514, W2
	MOV	#17317, W3
	CALL	__Mul_FP
	MOV	W0, _VSnd
	MOV	W1, _VSnd+2
;ADC_DAC.c,105 :: 		}
L_end_Velocidad:
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _Velocidad

_Pulse:
	LNK	#12

;ADC_DAC.c,108 :: 		void Pulse(){
;ADC_DAC.c,111 :: 		contp = 0;                                               //Limpia la variable del contador de pulsos
	CLR	W0
	MOV	W0, _contp
;ADC_DAC.c,112 :: 		RB0_bit = 0;                                            //Limpia el pin que produce los pulsos de exitacion del transductor
	BCLR	RB0_bit, BitPos(RB0_bit+0)
;ADC_DAC.c,114 :: 		T1CON.TON = 0;                                           //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,115 :: 		IEC0.T1IE = 0;                                           //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,117 :: 		TMR2 = 0;                                                //Encera el TMR2
	CLR	TMR2
;ADC_DAC.c,118 :: 		IEC0.T2IE = 1;                                           //Habilita la interrupcion por desborde del TMR2
	BSET	IEC0, #7
;ADC_DAC.c,119 :: 		T2CON.TON = 1;                                           //Enciende el TMR2
	BSET	T2CON, #15
;ADC_DAC.c,121 :: 		i = 0;                                                   //Limpia las variables asociadas al almacenamiento de la se�al muestreada
	CLR	W0
	MOV	W0, _i
;ADC_DAC.c,124 :: 		while(bm!=1);                                            //Espera hasta que haya terminado de enviar y recibir todas las muestras
L_Pulse5:
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA NZ	L__Pulse66
	GOTO	L_Pulse6
L__Pulse66:
	GOTO	L_Pulse5
L_Pulse6:
;ADC_DAC.c,127 :: 		if (bm==1){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__Pulse67
	GOTO	L_Pulse7
L__Pulse67:
;ADC_DAC.c,130 :: 		Mmax = Vector_Max(M, nm, &MIndexMax);
	MOV	#lo_addr(_MIndexMax), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Max
	SUB	#6, W15
	MOV	W0, _Mmax
;ADC_DAC.c,131 :: 		Mmin = Vector_Min(M, nm, &MIndexMin);
	MOV	#lo_addr(_MIndexMin), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Min
	SUB	#6, W15
	MOV	W0, _Mmin
;ADC_DAC.c,132 :: 		Mmed = Mmax-((Mmax-Mmin)/2);
	MOV	#lo_addr(_Mmax), W1
	SUBR	W0, [W1], W0
	LSR	W0, #1, W2
	MOV	#lo_addr(_Mmax), W1
	MOV	#lo_addr(_Mmed), W0
	SUBR	W2, [W1], [W0]
;ADC_DAC.c,134 :: 		for (k=0;k<nm;k++){
	CLR	W0
	MOV	W0, _k
L_Pulse8:
	MOV	_k, W1
	MOV	#350, W0
	CP	W1, W0
	BRA LTU	L__Pulse68
	GOTO	L_Pulse9
L__Pulse68:
;ADC_DAC.c,137 :: 		value = M[k]-Mmed;
	MOV	_k, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W3
	MOV	[W3], W2
	MOV	#lo_addr(_Mmed), W1
	MOV	#lo_addr(_value), W0
	SUB	W2, [W1], [W0]
;ADC_DAC.c,138 :: 		if (M[k]<Mmed){
	MOV	[W3], W1
	MOV	#lo_addr(_Mmed), W0
	CP	W1, [W0]
	BRA LTU	L__Pulse69
	GOTO	L_Pulse11
L__Pulse69:
;ADC_DAC.c,139 :: 		value = (M[k]+((Mmed-M[k])*2))-(Mmed);
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
;ADC_DAC.c,140 :: 		}
L_Pulse11:
;ADC_DAC.c,143 :: 		x0 = (float)(value);                                 //Adquisici�n de una muestra de 10 bits en, x[0].
	MOV	_value, W0
	CLR	W1
	CALL	__Long2Float
	MOV	W0, _x0
	MOV	W1, _x0+2
;ADC_DAC.c,144 :: 		y0 = ((x0+x2)*ca1)+(x1*ca2)-(y1*cb2)-(y2*cb3);       //Implementaci�n de la ecuaci�n en diferencias
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
;ADC_DAC.c,146 :: 		y2 = y1;                                             //Corrimiento de los valores x(n), y y(n).
	MOV	_y1, W2
	MOV	_y1+2, W3
	MOV	W2, _y2
	MOV	W3, _y2+2
;ADC_DAC.c,147 :: 		y1 = y0;
	MOV	W0, _y1
	MOV	W1, _y1+2
;ADC_DAC.c,148 :: 		x2 = x1;
	MOV	_x1, W2
	MOV	_x1+2, W3
	MOV	W2, _x2
	MOV	W3, _x2+2
;ADC_DAC.c,149 :: 		x1 = x0;
	MOV	_x0, W2
	MOV	_x0+2, W3
	MOV	W2, _x1
	MOV	W3, _x1+2
;ADC_DAC.c,151 :: 		YY = (unsigned int)(y0);                             //Reconstrucci�n de la se�al: y en 10 bits.
	CALL	__Float2Longint
	MOV	W0, _YY
;ADC_DAC.c,152 :: 		M[k] = YY;
	MOV	_k, W1
	SL	W1, #1, W2
	MOV	#lo_addr(_M), W1
	ADD	W1, W2, W1
	MOV	W0, [W1]
;ADC_DAC.c,134 :: 		for (k=0;k<nm;k++){
	MOV	#1, W1
	MOV	#lo_addr(_k), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,154 :: 		}
	GOTO	L_Pulse8
L_Pulse9:
;ADC_DAC.c,156 :: 		bm = 2;                                                  //Cambia el estado de la bandera bm para dar paso al c�lculo del pmax y TOF
	MOV	#lo_addr(_bm), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,158 :: 		}
L_Pulse7:
;ADC_DAC.c,161 :: 		if (bm==2){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__Pulse70
	GOTO	L_Pulse12
L__Pulse70:
;ADC_DAC.c,163 :: 		yy1 = Vector_Max(M, nm, &maxIndex);                       //Encuentra el valor maximo del vector R
	MOV	#lo_addr(_maxIndex), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Max
	SUB	#6, W15
	MOV	W0, _yy1
;ADC_DAC.c,164 :: 		i1b = maxIndex;                                           //Asigna el subindice del valor maximo a la variable i1a
	MOV	_maxIndex, W0
	MOV	W0, _i1b
;ADC_DAC.c,165 :: 		i1a = 0;
	CLR	W0
	MOV	W0, _i1a
;ADC_DAC.c,167 :: 		while (M[i1a]<yy1){
L_Pulse13:
	MOV	_i1a, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W1
	MOV	#lo_addr(_yy1), W0
	CP	W1, [W0]
	BRA LTU	L__Pulse71
	GOTO	L_Pulse14
L__Pulse71:
;ADC_DAC.c,168 :: 		i1a++;
	MOV	#1, W1
	MOV	#lo_addr(_i1a), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,169 :: 		}
	GOTO	L_Pulse13
L_Pulse14:
;ADC_DAC.c,171 :: 		i1 = i1a+((i1b-i1a)/2);
	MOV	_i1b, W1
	MOV	#lo_addr(_i1a), W0
	SUB	W1, [W0], W0
	LSR	W0, #1, W1
	MOV	#lo_addr(_i1a), W0
	ADD	W1, [W0], W1
	MOV	W1, _i1
;ADC_DAC.c,172 :: 		i0 = i1 - dix;
	SUB	W1, #16, W0
	MOV	W0, _i0
;ADC_DAC.c,173 :: 		i2 = i1 + dix;
	ADD	W1, #16, W3
	MOV	W3, _i2
;ADC_DAC.c,175 :: 		yy0 = M[i0];
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W2
	MOV	W2, _yy0
;ADC_DAC.c,176 :: 		yy2 = M[i2];
	SL	W3, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W0
	MOV	W0, [W14+0]
	MOV	W0, _yy2
;ADC_DAC.c,178 :: 		yf0 = (float)(yy0);
	MOV	W2, W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+8]
	MOV	W1, [W14+10]
	MOV	W0, _yf0
	MOV	W1, _yf0+2
;ADC_DAC.c,179 :: 		yf1 = (float)(yy1);
	MOV	_yy1, W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	W0, _yf1
	MOV	W1, _yf1+2
;ADC_DAC.c,180 :: 		yf2 = (float)(yy2);
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
;ADC_DAC.c,182 :: 		nx = (yf0-yf2)/(2.0*(yf0-(2.0*yf1)+yf2));                   //Factor de ajuste determinado por interpolacion parabolica
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
;ADC_DAC.c,183 :: 		dx = nx*dix*tx;
	MOV	#0, W2
	MOV	#16768, W3
	CALL	__Mul_FP
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Mul_FP
	MOV	W0, _dx
	MOV	W1, _dx+2
;ADC_DAC.c,184 :: 		tmax = i1*tx;
	MOV	_i1, W0
	CLR	W1
	CALL	__Long2Float
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Mul_FP
	MOV	W0, _tmax
	MOV	W1, _tmax+2
;ADC_DAC.c,186 :: 		T2 = tmax+dx;
	MOV	_dx, W2
	MOV	_dx+2, W3
	CALL	__AddSub_FP
	MOV	W0, _T2
	MOV	W1, _T2+2
;ADC_DAC.c,188 :: 		imax = (unsigned int)(T2/tx);
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Div_FP
	CALL	__Float2Longint
	MOV	W0, _imax
;ADC_DAC.c,189 :: 		M[0]=500;
	MOV	#500, W0
	MOV	W0, _M
;ADC_DAC.c,190 :: 		M[i0]=250;
	MOV	_i0, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	#250, W0
	MOV	W0, [W1]
;ADC_DAC.c,191 :: 		M[i1]=350;
	MOV	_i1, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	#350, W0
	MOV	W0, [W1]
;ADC_DAC.c,192 :: 		M[imax]=800;
	MOV	_imax, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	#800, W0
	MOV	W0, [W1]
;ADC_DAC.c,193 :: 		M[i2]=250;
	MOV	_i2, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	#250, W0
	MOV	W0, [W1]
;ADC_DAC.c,194 :: 		M[nm-2]=500;
	MOV	#500, W0
	MOV	W0, _M+696
;ADC_DAC.c,196 :: 		}
L_Pulse12:
;ADC_DAC.c,198 :: 		}
L_end_Pulse:
	ULNK
	RETURN
; end of _Pulse

_Distancia:

;ADC_DAC.c,201 :: 		void Distancia(){
;ADC_DAC.c,203 :: 		conts = 0;                               //Limpia el contador de secuencias
	MOV	#lo_addr(_conts), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,204 :: 		T2sum = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2sum
	MOV	W1, _T2sum+2
;ADC_DAC.c,205 :: 		T2prom = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2prom
	MOV	W1, _T2prom+2
;ADC_DAC.c,206 :: 		T2a = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2a
	MOV	W1, _T2a+2
;ADC_DAC.c,207 :: 		T2b = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2b
	MOV	W1, _T2b+2
;ADC_DAC.c,209 :: 		while (conts<Nsm){
L_Distancia15:
	MOV	#lo_addr(_conts), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA LT	L__Distancia73
	GOTO	L_Distancia16
L__Distancia73:
;ADC_DAC.c,210 :: 		Pulse();                           //Inicia una secuencia de medicion
	CALL	_Pulse
;ADC_DAC.c,211 :: 		T2b = T2;
	MOV	_T2, W0
	MOV	_T2+2, W1
	MOV	W0, _T2b
	MOV	W1, _T2b+2
;ADC_DAC.c,212 :: 		if ((T2b-T2a)<=T2umb){             //Verifica si el T2 actual esta dentro de un umbral pre-establecido
	MOV	_T2, W0
	MOV	_T2+2, W1
	MOV	_T2a, W2
	MOV	_T2a+2, W3
	CALL	__Sub_FP
	MOV	#0, W2
	MOV	#16448, W3
	CALL	__Compare_Le_Fp
	CP0	W0
	CLR.B	W0
	BRA GT	L__Distancia74
	INC.B	W0
L__Distancia74:
	CP0.B	W0
	BRA NZ	L__Distancia75
	GOTO	L_Distancia17
L__Distancia75:
;ADC_DAC.c,213 :: 		T2sum = T2sum + T2b;            //Acumula la sumatoria de valores de T2 calculados por la funcion Pulse()
	MOV	_T2sum, W2
	MOV	_T2sum+2, W3
	MOV	_T2b, W0
	MOV	_T2b+2, W1
	CALL	__AddSub_FP
	MOV	W0, _T2sum
	MOV	W1, _T2sum+2
;ADC_DAC.c,214 :: 		conts++;                        //Aumenta el contador de secuencias
	MOV.B	#1, W1
	MOV	#lo_addr(_conts), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,215 :: 		}
L_Distancia17:
;ADC_DAC.c,216 :: 		T2a = T2b;
	MOV	_T2b, W0
	MOV	_T2b+2, W1
	MOV	W0, _T2a
	MOV	W1, _T2a+2
;ADC_DAC.c,217 :: 		}
	GOTO	L_Distancia15
L_Distancia16:
;ADC_DAC.c,219 :: 		T2prom = T2sum/Nsm;
	MOV	#0, W2
	MOV	#16448, W3
	MOV	_T2sum, W0
	MOV	_T2sum+2, W1
	CALL	__Div_FP
	MOV	W0, _T2prom
	MOV	W1, _T2prom+2
;ADC_DAC.c,221 :: 		Velocidad();                             //Calcula la velocidad del sonido
	CALL	_Velocidad
;ADC_DAC.c,224 :: 		TOF = (T1+T2prom-T2adj)/2.0e6;           //Calcula el TOF en seg
	MOV	#57344, W2
	MOV	#17579, W3
	MOV	_T2prom, W0
	MOV	_T2prom+2, W1
	CALL	__AddSub_FP
	MOV	#32768, W2
	MOV	#17391, W3
	CALL	__Sub_FP
	MOV	#9216, W2
	MOV	#18932, W3
	CALL	__Div_FP
	MOV	W0, _TOF
	MOV	W1, _TOF+2
;ADC_DAC.c,225 :: 		Dst = VSnd * TOF * 1000.0;               //Calcula la distancia en mm
	MOV	_VSnd, W2
	MOV	_VSnd+2, W3
	CALL	__Mul_FP
	MOV	#0, W2
	MOV	#17530, W3
	CALL	__Mul_FP
	MOV	W0, _Dst
	MOV	W1, _Dst+2
;ADC_DAC.c,227 :: 		IDst = (unsigned int)(Dst);              //Tranforma el dato de distancia de float a entero sin signo
	CALL	__Float2Longint
	MOV	W0, _IDst
;ADC_DAC.c,228 :: 		chIDst = (unsigned char *) & IDst;       //Asocia el valor calculado de Dst al puntero chDst
	MOV	#lo_addr(_IDst), W0
	MOV	W0, _chIDst
;ADC_DAC.c,230 :: 		for (ir=3;ir<5;ir++){
	MOV	#lo_addr(_ir), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
L_Distancia18:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #5
	BRA LTU	L__Distancia76
	GOTO	L_Distancia19
L__Distancia76:
;ADC_DAC.c,231 :: 		Rspt[ir]=(*chIDst++);                //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la distancia calculada
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chIDst, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chIDst), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,230 :: 		for (ir=3;ir<5;ir++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,232 :: 		}
	GOTO	L_Distancia18
L_Distancia19:
;ADC_DAC.c,234 :: 		}
L_end_Distancia:
	RETURN
; end of _Distancia

_UART1Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,238 :: 		void UART1Interrupt() iv IVT_ADDR_U1RXINTERRUPT {
;ADC_DAC.c,240 :: 		Dato = UART1_Read();
	CALL	_UART1_Read
	MOV	#lo_addr(_Dato), W1
	MOV.B	W0, [W1]
;ADC_DAC.c,242 :: 		if ((Dato==Hdr)&&(ip==0)){                    //Verifica que el primer dato en llegar sea el identificador de inicio de trama
	MOV.B	#238, W1
	CP.B	W0, W1
	BRA Z	L__UART1Interrupt78
	GOTO	L__UART1Interrupt59
L__UART1Interrupt78:
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__UART1Interrupt79
	GOTO	L__UART1Interrupt58
L__UART1Interrupt79:
L__UART1Interrupt57:
;ADC_DAC.c,243 :: 		BanT = 1;                                 //Activa la bandera de trama
	MOV	#lo_addr(_BanT), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,244 :: 		Ptcn[ip] = Dato;                          //Almacena el Dato en la trama de peticion
	MOV	#lo_addr(_ip), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,242 :: 		if ((Dato==Hdr)&&(ip==0)){                    //Verifica que el primer dato en llegar sea el identificador de inicio de trama
L__UART1Interrupt59:
L__UART1Interrupt58:
;ADC_DAC.c,246 :: 		if ((Dato!=Hdr)&&(ip==0)){                    //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], W1
	MOV.B	#238, W0
	CP.B	W1, W0
	BRA NZ	L__UART1Interrupt80
	GOTO	L__UART1Interrupt61
L__UART1Interrupt80:
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__UART1Interrupt81
	GOTO	L__UART1Interrupt60
L__UART1Interrupt81:
L__UART1Interrupt56:
;ADC_DAC.c,247 :: 		ip=-1;                                    //Si es asi: reduce el subindice en una unidad
	MOV	#lo_addr(_ip), W1
	MOV.B	#255, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,246 :: 		if ((Dato!=Hdr)&&(ip==0)){                    //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
L__UART1Interrupt61:
L__UART1Interrupt60:
;ADC_DAC.c,249 :: 		if ((BanT==1)&&(ip!=0)){
	MOV	#lo_addr(_BanT), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__UART1Interrupt82
	GOTO	L__UART1Interrupt63
L__UART1Interrupt82:
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA NZ	L__UART1Interrupt83
	GOTO	L__UART1Interrupt62
L__UART1Interrupt83:
L__UART1Interrupt55:
;ADC_DAC.c,250 :: 		Ptcn[ip] = Dato;                          //Almacena el resto de datos en la trama de peticion si la bandera de trama esta activada
	MOV	#lo_addr(_ip), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,249 :: 		if ((BanT==1)&&(ip!=0)){
L__UART1Interrupt63:
L__UART1Interrupt62:
;ADC_DAC.c,253 :: 		ip++;                                         //Aumenta el subindice una unidad
	MOV.B	#1, W1
	MOV	#lo_addr(_ip), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,254 :: 		if (ip==Psize){                               //Verifica que se haya terminado de llenar la trama de datos
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #4
	BRA Z	L__UART1Interrupt84
	GOTO	L_UART1Interrupt30
L__UART1Interrupt84:
;ADC_DAC.c,255 :: 		BanP = 1;                                 //Habilita la bandera de lectura de datos
	MOV	#lo_addr(_BanP), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,256 :: 		BanT = 0;
	MOV	#lo_addr(_BanT), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,257 :: 		ip=0;                                     //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
	MOV	#lo_addr(_ip), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,258 :: 		}
L_UART1Interrupt30:
;ADC_DAC.c,260 :: 		U1RXIF_bit = 0;                               //Limpia la bandera de interrupcion de UARTRX
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;ADC_DAC.c,262 :: 		}
L_end_UART1Interrupt:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _UART1Interrupt

_Timer1Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,265 :: 		void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
;ADC_DAC.c,267 :: 		SAMP_bit = 0;                                 //Limpia el bit SAMP para iniciar la conversion del ADC
	BCLR	SAMP_bit, BitPos(SAMP_bit+0)
;ADC_DAC.c,268 :: 		while (!AD1CON1bits.DONE);                    //Espera hasta que se complete la conversion
L_Timer1Interrupt31:
	BTSC	AD1CON1bits, #0
	GOTO	L_Timer1Interrupt32
	GOTO	L_Timer1Interrupt31
L_Timer1Interrupt32:
;ADC_DAC.c,269 :: 		if (i<nm){
	MOV	_i, W1
	MOV	#350, W0
	CP	W1, W0
	BRA LTU	L__Timer1Interrupt86
	GOTO	L_Timer1Interrupt33
L__Timer1Interrupt86:
;ADC_DAC.c,270 :: 		M[i] = ADC1BUF0;                           //Almacena el valor actual de la conversion del ADC en el vector M
	MOV	_i, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	ADC1BUF0, WREG
	MOV	W0, [W1]
;ADC_DAC.c,271 :: 		i++;                                       //Aumenta en 1 el subindice del vector de Muestras
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,272 :: 		} else {
	GOTO	L_Timer1Interrupt34
L_Timer1Interrupt33:
;ADC_DAC.c,273 :: 		bm = 1;                                    //Cambia el valor de la bandera bm para terminar con el muestreo y dar comienzo al procesamiento de la se�al
	MOV	#lo_addr(_bm), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,274 :: 		T1CON.TON = 0;                             //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,275 :: 		IEC0.T1IE = 0;                             //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,276 :: 		}
L_Timer1Interrupt34:
;ADC_DAC.c,277 :: 		T1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,278 :: 		}
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

;ADC_DAC.c,281 :: 		void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
;ADC_DAC.c,282 :: 		if (contp<10){                                //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (
	MOV	_contp, W0
	CP	W0, #10
	BRA LTU	L__Timer2Interrupt88
	GOTO	L_Timer2Interrupt35
L__Timer2Interrupt88:
;ADC_DAC.c,283 :: 		RB0_bit = ~RB0_bit;                      //Conmuta el valor del pin RB14
	BTG	RB0_bit, BitPos(RB0_bit+0)
;ADC_DAC.c,284 :: 		}else {
	GOTO	L_Timer2Interrupt36
L_Timer2Interrupt35:
;ADC_DAC.c,285 :: 		RB0_bit = 0;                            //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCLR	RB0_bit, BitPos(RB0_bit+0)
;ADC_DAC.c,287 :: 		if (contp==110){
	MOV	#110, W1
	MOV	#lo_addr(_contp), W0
	CP	W1, [W0]
	BRA Z	L__Timer2Interrupt89
	GOTO	L_Timer2Interrupt37
L__Timer2Interrupt89:
;ADC_DAC.c,288 :: 		IEC0.T2IE = 0;                       //Desabilita la interrupcion por desborde del TMR2 para no interferir con las interrupciones por desborde de TMR1
	BCLR	IEC0, #7
;ADC_DAC.c,289 :: 		T2CON.TON = 0;                       //Apaga el TMR2
	BCLR	T2CON, #15
;ADC_DAC.c,290 :: 		IEC0.T1IE = 1;                       //Habilita la interrupcion por desborde del TMR1 para dar inicio al muestreo del ADC
	BSET	IEC0, #3
;ADC_DAC.c,291 :: 		TMR1 = 0;                            //Encera el TMR1
	CLR	TMR1
;ADC_DAC.c,292 :: 		T1IF_bit = 0;                        //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,293 :: 		T1CON.TON = 1;                       //Enciende el TMR1
	BSET	T1CON, #15
;ADC_DAC.c,294 :: 		bm=0;
	MOV	#lo_addr(_bm), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,295 :: 		}
L_Timer2Interrupt37:
;ADC_DAC.c,297 :: 		}
L_Timer2Interrupt36:
;ADC_DAC.c,298 :: 		contp++;                                      //Aumenta el contador en una unidad.
	MOV	#1, W1
	MOV	#lo_addr(_contp), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,299 :: 		T2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,300 :: 		}
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

;ADC_DAC.c,304 :: 		void Configuracion(){
;ADC_DAC.c,307 :: 		CLKDIVbits.PLLPRE = 0;                      //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,308 :: 		PLLFBD = 38;                                //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
	MOV	#38, W0
	MOV	WREG, PLLFBD
;ADC_DAC.c,309 :: 		CLKDIVbits.PLLPOST = 0;                     //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,312 :: 		AD1PCFGL = 0xFFFD;                          //Configura el puerto AN1 como entrada analogica y todas las demas como digitales
	MOV	#65533, W0
	MOV	WREG, AD1PCFGL
;ADC_DAC.c,313 :: 		TRISA1_bit = 1;                             //Establece el pin RA1 como entrada
	BSET	TRISA1_bit, BitPos(TRISA1_bit+0)
;ADC_DAC.c,314 :: 		TRISB = 0xFF80;                             //TRISB = 11111111 10000000
	MOV	#65408, W0
	MOV	WREG, TRISB
;ADC_DAC.c,317 :: 		AD1CON1.AD12B = 0;                          //Configura el ADC en modo de 10 bits
	BCLR	AD1CON1, #10
;ADC_DAC.c,318 :: 		AD1CON1bits.FORM = 0x00;                    //Formato de la canversion: 00->(0_1023)|01->(-512_511)|02->(0_0.999)|03->(-1_0.999)
	MOV	AD1CON1bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON1bits
;ADC_DAC.c,319 :: 		AD1CON1.SIMSAM = 0;                         //0 -> Muestrea m�ltiples canales individualmente en secuencia
	BCLR	AD1CON1, #3
;ADC_DAC.c,320 :: 		AD1CON1.ADSIDL = 0;                         //Continua con la operacion del modulo durante el modo desocupado
	BCLR	AD1CON1, #13
;ADC_DAC.c,321 :: 		AD1CON1.ASAM = 1;                           //Muestreo automatico
	BSET	AD1CON1, #2
;ADC_DAC.c,322 :: 		AD1CON1bits.SSRC = 0x00;                    //Conversion manual
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	[W0], W1
	MOV.B	#31, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,324 :: 		AD1CON2bits.VCFG = 0;                       //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
	MOV	AD1CON2bits, W1
	MOV	#8191, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,325 :: 		AD1CON2bits.CHPS = 0;                       //Selecciona unicamente el canal CH0
	MOV	AD1CON2bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,326 :: 		AD1CON2.CSCNA = 0;                          //No escanea las entradas de CH0 durante la Muestra A
	BCLR	AD1CON2, #10
;ADC_DAC.c,327 :: 		AD1CON2.BUFM = 0;                           //Bit de selecci�n del modo de relleno del b�fer, 0 -> Siempre comienza a llenar el buffer desde el principio
	BCLR	AD1CON2, #1
;ADC_DAC.c,328 :: 		AD1CON2.ALTS = 0x00;                        //Utiliza siempre la selecci�n de entrada de canal para la muestra A
	BCLR	AD1CON2, #0
;ADC_DAC.c,330 :: 		AD1CON3.ADRC = 0;                           //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
	BCLR	AD1CON3, #15
;ADC_DAC.c,331 :: 		AD1CON3bits.ADCS = 0x02;                    //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
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
;ADC_DAC.c,332 :: 		AD1CON3bits.SAMC = 0x02;                    //Auto Sample Time bits, 2 -> 2*TAD (minimo periodo de muestreo para 10 bits)
	MOV	#512, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CON3bits
;ADC_DAC.c,334 :: 		AD1CHS0.CH0NB = 0;                          //Channel 0 negative input is VREF-
	BCLR	AD1CHS0, #15
;ADC_DAC.c,335 :: 		AD1CHS0bits.CH0SB = 0x01;                   //Channel 0 positive input is AN1
	MOV	#256, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CHS0bits
;ADC_DAC.c,336 :: 		AD1CHS0.CH0NA = 0;                          //Channel 0 negative input is VREF-
	BCLR	AD1CHS0, #7
;ADC_DAC.c,337 :: 		AD1CHS0bits.CH0SA = 0x01;                   //Channel 0 positive input is AN1
	MOV.B	#1, W0
	MOV.B	W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(AD1CHS0bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,339 :: 		AD1CHS123 = 0;                              //AD1CHS123: ADC1 INPUT CHANNEL 1, 2, 3 SELECT REGISTER
	CLR	AD1CHS123
;ADC_DAC.c,341 :: 		AD1CSSL = 0x00;                             //Se salta todos los puertos ANx para los escaneos de entrada
	CLR	AD1CSSL
;ADC_DAC.c,343 :: 		AD1CON1.ADON = 1;                           //Enciende el modulo ADC
	BSET	AD1CON1, #15
;ADC_DAC.c,346 :: 		T1CON = 0x8000;                             //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T1CON
;ADC_DAC.c,347 :: 		IEC0.T1IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR1 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #3
;ADC_DAC.c,348 :: 		T1IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,349 :: 		PR1 = 200;                                  //Genera una interrupcion cada 5us (Fs=200KHz)
	MOV	#200, W0
	MOV	WREG, PR1
;ADC_DAC.c,352 :: 		T2CON = 0x8000;                             //Habilita el TMR2, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T2CON
;ADC_DAC.c,353 :: 		IEC0.T2IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR2 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #7
;ADC_DAC.c,354 :: 		T2IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,355 :: 		PR2 = 500;                                  //Genera una interrupcion cada 12.5us
	MOV	#500, W0
	MOV	WREG, PR2
;ADC_DAC.c,358 :: 		RPINR18bits.U1RXR = 0x07;                   //Asisgna Rx a RP12
	MOV.B	#7, W0
	MOV.B	W0, W1
	MOV	#lo_addr(RPINR18bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(RPINR18bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(RPINR18bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,359 :: 		RPOR3bits.RP6R = 0x03;                      //Asigna Tx a RP13
	MOV.B	#3, W0
	MOV.B	W0, W1
	MOV	#lo_addr(RPOR3bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(RPOR3bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(RPOR3bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,360 :: 		IEC0.U1RXIE = 1;                            //Habilita la interrupcion por recepcion de dato por UART
	BSET	IEC0, #11
;ADC_DAC.c,361 :: 		U1RXIF_bit = 0;                             //Limpia la bandera de interrupcion de UARTRX
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;ADC_DAC.c,365 :: 		IPC0bits.T1IP = 0x06;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#24576, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC0bits
;ADC_DAC.c,366 :: 		IPC1bits.T2IP = 0x05;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR2
	MOV	#20480, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;ADC_DAC.c,367 :: 		IPC2bits.U1RXIP = 0x07;                     //Nivel de prioridad de la interrupcion UARTRX
	MOV	IPC2bits, W1
	MOV	#28672, W0
	IOR	W1, W0, W0
	MOV	WREG, IPC2bits
;ADC_DAC.c,371 :: 		}
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

;ADC_DAC.c,375 :: 		void main() {
;ADC_DAC.c,377 :: 		Configuracion();
	PUSH	W10
	PUSH	W11
	CALL	_Configuracion
;ADC_DAC.c,379 :: 		UART1_Init(9600);                                           // Initialize UART module at 9600 bps
	MOV	#9600, W10
	MOV	#0, W11
	CALL	_UART1_Init
;ADC_DAC.c,380 :: 		Delay_ms(100);                                              // Wait for UART module to stabilize
	MOV	#21, W8
	MOV	#22619, W7
L_main38:
	DEC	W7
	BRA NZ	L_main38
	DEC	W8
	BRA NZ	L_main38
;ADC_DAC.c,381 :: 		RB5_bit = 0;                                                //Establece el Max485 en modo de lectura;
	BCLR	RB5_bit, BitPos(RB5_bit+0)
;ADC_DAC.c,383 :: 		TpId = (PORTB&0xFF00)>>8;
	MOV	PORTB, W1
	MOV	#65280, W0
	AND	W1, W0, W0
	LSR	W0, #8, W1
	MOV	#lo_addr(_TpId), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,384 :: 		TP = TpId>>4;
	SE	W1, W0
	ASR	W0, #4, W2
	MOV	#lo_addr(_TP), W0
	MOV.B	W2, [W0]
;ADC_DAC.c,385 :: 		Id = TPId&0xF;
	MOV	#lo_addr(_Id), W0
	AND.B	W1, #15, [W0]
;ADC_DAC.c,387 :: 		Rspt[0] = Hdr;                                              //Se rellena el primer byte de la trama de respuesta con el delimitador de inicio de trama
	MOV	#lo_addr(_Rspt), W1
	MOV.B	#238, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,388 :: 		Rspt[1] = Tp;                                               //Se rellena el segundo byte de la trama de repuesta con el Id del tipo de sensor
	MOV	#lo_addr(_Rspt+1), W0
	MOV.B	W2, [W0]
;ADC_DAC.c,389 :: 		Rspt[2] = Id;                                               //Se rellena el tercer byte de la trama de repuesta con el Id de esclavo
	MOV	#lo_addr(_Rspt+2), W1
	MOV	#lo_addr(_Id), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,390 :: 		Rspt[Rsize-1] = End;                                        //Se rellena el ultimo byte de la trama de repuesta con el delimitador de final de trama
	MOV	#lo_addr(_Rspt+5), W1
	MOV.B	#255, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,394 :: 		UART1_Write(0x00);                                 //Indica el comienzo de una secuencia de muestreo
	CLR	W10
	CALL	_UART1_Write
;ADC_DAC.c,395 :: 		UART1_Write(0x0D);
	MOV	#13, W10
	CALL	_UART1_Write
;ADC_DAC.c,397 :: 		Pulse();                                           //Realiza una secuencia de muestreo y estimacion del punto maximo
	CALL	_Pulse
;ADC_DAC.c,399 :: 		for (ir=0;ir<nm;ir++){
	MOV	#lo_addr(_ir), W1
	CLR	W0
	MOV.B	W0, [W1]
L_main42:
;ADC_DAC.c,400 :: 		while(UART_Tx_Idle()==0);                     //Espera hasta que se haya terminado de enviar todos los datos antes de continuar
L_main45:
	CALL	_UART_Tx_Idle
	CP	W0, #0
	BRA Z	L__main92
	GOTO	L_main46
L__main92:
	GOTO	L_main45
L_main46:
;ADC_DAC.c,401 :: 		TT2 = M[ir];                                  //Guarda cada uno de los valores de M en TT2
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W0
	CLR	W1
	MOV	W0, _TT2
	MOV	W1, _TT2+2
;ADC_DAC.c,402 :: 		chTT2 = (unsigned char *) & TT2;
	MOV	#lo_addr(_TT2), W0
	MOV	W0, _chTT2
;ADC_DAC.c,403 :: 		for (l=0;l<2;l++){                            //Genera la trama de 2 Bytes
	CLR	W0
	MOV	W0, _l
L_main47:
	MOV	_l, W0
	CP	W0, #2
	BRA LTU	L__main93
	GOTO	L_main48
L__main93:
;ADC_DAC.c,404 :: 		trama[l]=(*chTT2++);
	MOV	#lo_addr(_trama), W1
	MOV	#lo_addr(_l), W0
	ADD	W1, [W0], W1
	MOV	_chTT2, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chTT2), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,403 :: 		for (l=0;l<2;l++){                            //Genera la trama de 2 Bytes
	MOV	#1, W1
	MOV	#lo_addr(_l), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,405 :: 		}
	GOTO	L_main47
L_main48:
;ADC_DAC.c,406 :: 		for (l=1;l>=0;l--){                           //Envia la trama de 2 Bytes
	MOV	#1, W0
	MOV	W0, _l
L_main50:
	MOV	_l, W0
	CP	W0, #0
	BRA GEU	L__main94
	GOTO	L_main51
L__main94:
;ADC_DAC.c,407 :: 		UART1_Write(trama[l]);
	MOV	#lo_addr(_trama), W1
	MOV	#lo_addr(_l), W0
	ADD	W1, [W0], W0
	ZE	[W0], W10
	CALL	_UART1_Write
;ADC_DAC.c,406 :: 		for (l=1;l>=0;l--){                           //Envia la trama de 2 Bytes
	MOV	#1, W1
	MOV	#lo_addr(_l), W0
	SUBR	W1, [W0], [W0]
;ADC_DAC.c,408 :: 		}
	GOTO	L_main50
L_main51:
;ADC_DAC.c,409 :: 		UART1_Write(0x0D);                            //Salto de linea
	MOV	#13, W10
	CALL	_UART1_Write
;ADC_DAC.c,399 :: 		for (ir=0;ir<nm;ir++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,410 :: 		}
	GOTO	L_main42
;ADC_DAC.c,419 :: 		}
L_end_main:
	POP	W11
	POP	W10
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
