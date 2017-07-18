
_Velocidad:
	LNK	#4

;ADC_DAC.c,102 :: 		void Velocidad(){
;ADC_DAC.c,107 :: 		Ow_Reset(&PORTA, 0);                          //Onewire reset signal
	PUSH	W10
	PUSH	W11
	PUSH	W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;ADC_DAC.c,108 :: 		Ow_Write(&PORTA, 0, 0xCC);                    //Issue command SKIP_ROM
	MOV.B	#204, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,109 :: 		Ow_Write(&PORTA, 0, 0x44);                    //Issue command CONVERT_T
	MOV.B	#68, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,110 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad0:
	DEC	W7
	BRA NZ	L_Velocidad0
	NOP
;ADC_DAC.c,112 :: 		Ow_Reset(&PORTA, 0);
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;ADC_DAC.c,113 :: 		Ow_Write(&PORTA, 0, 0xCC);                    //Issue command SKIP_ROM
	MOV.B	#204, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,114 :: 		Ow_Write(&PORTA, 0, 0xBE);                    //Issue command READ_SCRATCHPAD
	MOV.B	#190, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,115 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad2:
	DEC	W7
	BRA NZ	L_Velocidad2
	NOP
;ADC_DAC.c,117 :: 		Temp =  Ow_Read(&PORTA, 0);
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
; Temp start address is: 10 (W5)
	ZE	W0, W5
;ADC_DAC.c,118 :: 		Temp = (Ow_Read(&PORTA, 0) << 8) + Temp;
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
	ZE	W0, W0
	SL	W0, #8, W0
	ADD	W0, W5, W0
; Temp end address is: 10 (W5)
; Temp start address is: 4 (W2)
	MOV	W0, W2
;ADC_DAC.c,120 :: 		if (Temp & 0x8000) {
	BTSS	W0, #15
	GOTO	L__Velocidad102
;ADC_DAC.c,121 :: 		Temp = 0;                                  //Si la temperatura es negativa la establece como cero.
	CLR	W2
; Temp end address is: 4 (W2)
;ADC_DAC.c,122 :: 		}
	GOTO	L_Velocidad4
L__Velocidad102:
;ADC_DAC.c,120 :: 		if (Temp & 0x8000) {
;ADC_DAC.c,122 :: 		}
L_Velocidad4:
;ADC_DAC.c,124 :: 		Rint = Temp >> 4;                             //Extrae la parte entera de la respuesta del sensor
; Temp start address is: 4 (W2)
	LSR	W2, #4, W0
; Rint start address is: 6 (W3)
	MOV	W0, W3
;ADC_DAC.c,125 :: 		Rfrac = ((Temp & 0x000F) * 625) / 10000.;     //Extrae la parte decimal de la respuesta del sensor
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
;ADC_DAC.c,126 :: 		DSTemp = Rint + Rfrac;                        //Expresa la temperatura en punto flotante
	MOV	W3, W0
	CLR	W1
	CALL	__Long2Float
; Rint end address is: 6 (W3)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	MOV	W0, _DSTemp
	MOV	W1, _DSTemp+2
;ADC_DAC.c,128 :: 		VSnd = 331.45 * sqrt(1+(DsTemp/273));
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
;ADC_DAC.c,129 :: 		}
L_end_Velocidad:
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _Velocidad

_Pulse:
	LNK	#12

;ADC_DAC.c,132 :: 		void Pulse(){
;ADC_DAC.c,135 :: 		contp = 0;                                               //Limpia la variable del contador de pulsos
	CLR	W0
	MOV	W0, _contp
;ADC_DAC.c,136 :: 		RB2_bit = 0;                                             //Limpia el pin que produce los pulsos de exitacion del transductor
	BCLR	RB2_bit, BitPos(RB2_bit+0)
;ADC_DAC.c,138 :: 		T1CON.TON = 0;                                           //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,139 :: 		IEC0.T1IE = 0;                                           //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,141 :: 		TMR2 = 0;                                                //Encera el TMR2
	CLR	TMR2
;ADC_DAC.c,142 :: 		IEC0.T2IE = 1;                                           //Habilita la interrupcion por desborde del TMR2
	BSET	IEC0, #7
;ADC_DAC.c,143 :: 		T2CON.TON = 1;                                           //Enciende el TMR2
	BSET	T2CON, #15
;ADC_DAC.c,145 :: 		i = 0;                                                   //Limpia las variables asociadas al almacenamiento de la señal muestreada
	CLR	W0
	MOV	W0, _i
;ADC_DAC.c,148 :: 		while(bm!=1);                                            //Espera hasta que haya terminado de enviar y recibir todas las muestras
L_Pulse5:
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA NZ	L__Pulse126
	GOTO	L_Pulse6
L__Pulse126:
	GOTO	L_Pulse5
L_Pulse6:
;ADC_DAC.c,151 :: 		if (bm==1){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__Pulse127
	GOTO	L_Pulse7
L__Pulse127:
;ADC_DAC.c,154 :: 		Mmax = Vector_Max(M, nm, &MIndexMax);
	MOV	#lo_addr(_MIndexMax), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Max
	SUB	#6, W15
	MOV	W0, _Mmax
;ADC_DAC.c,155 :: 		Mmin = Vector_Min(M, nm, &MIndexMin);
	MOV	#lo_addr(_MIndexMin), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Min
	SUB	#6, W15
	MOV	W0, _Mmin
;ADC_DAC.c,156 :: 		Mmed = Mmax-((Mmax-Mmin)/2);
	MOV	#lo_addr(_Mmax), W1
	SUBR	W0, [W1], W0
	LSR	W0, #1, W2
	MOV	#lo_addr(_Mmax), W1
	MOV	#lo_addr(_Mmed), W0
	SUBR	W2, [W1], [W0]
;ADC_DAC.c,158 :: 		for (k=0;k<nm;k++){
	CLR	W0
	MOV	W0, _k
L_Pulse8:
	MOV	_k, W1
	MOV	#350, W0
	CP	W1, W0
	BRA LTU	L__Pulse128
	GOTO	L_Pulse9
L__Pulse128:
;ADC_DAC.c,161 :: 		value = M[k]-Mmed;
	MOV	_k, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W3
	MOV	[W3], W2
	MOV	#lo_addr(_Mmed), W1
	MOV	#lo_addr(_value), W0
	SUB	W2, [W1], [W0]
;ADC_DAC.c,162 :: 		if (M[k]<Mmed){
	MOV	[W3], W1
	MOV	#lo_addr(_Mmed), W0
	CP	W1, [W0]
	BRA LTU	L__Pulse129
	GOTO	L_Pulse11
L__Pulse129:
;ADC_DAC.c,163 :: 		value = (M[k]+((Mmed-M[k])*2))-(Mmed);
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
;ADC_DAC.c,164 :: 		}
L_Pulse11:
;ADC_DAC.c,167 :: 		x0 = (float)(value);                                 //Adquisición de una muestra de 10 bits en, x[0].
	MOV	_value, W0
	CLR	W1
	CALL	__Long2Float
	MOV	W0, _x0
	MOV	W1, _x0+2
;ADC_DAC.c,168 :: 		y0 = ((x0+x2)*ca1)+(x1*ca2)-(y1*cb2)-(y2*cb3);       //Implementación de la ecuación en diferencias
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
;ADC_DAC.c,170 :: 		y2 = y1;                                             //Corrimiento de los valores x(n), y y(n).
	MOV	_y1, W2
	MOV	_y1+2, W3
	MOV	W2, _y2
	MOV	W3, _y2+2
;ADC_DAC.c,171 :: 		y1 = y0;
	MOV	W0, _y1
	MOV	W1, _y1+2
;ADC_DAC.c,172 :: 		x2 = x1;
	MOV	_x1, W2
	MOV	_x1+2, W3
	MOV	W2, _x2
	MOV	W3, _x2+2
;ADC_DAC.c,173 :: 		x1 = x0;
	MOV	_x0, W2
	MOV	_x0+2, W3
	MOV	W2, _x1
	MOV	W3, _x1+2
;ADC_DAC.c,175 :: 		YY = (unsigned int)(y0);                             //Reconstrucción de la señal: y en 10 bits.
	CALL	__Float2Longint
	MOV	W0, _YY
;ADC_DAC.c,176 :: 		M[k] = YY;
	MOV	_k, W1
	SL	W1, #1, W2
	MOV	#lo_addr(_M), W1
	ADD	W1, W2, W1
	MOV	W0, [W1]
;ADC_DAC.c,158 :: 		for (k=0;k<nm;k++){
	MOV	#1, W1
	MOV	#lo_addr(_k), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,178 :: 		}
	GOTO	L_Pulse8
L_Pulse9:
;ADC_DAC.c,180 :: 		bm = 2;                                                  //Cambia el estado de la bandera bm para dar paso al cálculo del pmax y TOF
	MOV	#lo_addr(_bm), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,182 :: 		}
L_Pulse7:
;ADC_DAC.c,185 :: 		if (bm==2){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__Pulse130
	GOTO	L_Pulse12
L__Pulse130:
;ADC_DAC.c,187 :: 		yy1 = Vector_Max(M, nm, &maxIndex);                         //Encuentra el valor maximo del vector R
	MOV	#lo_addr(_maxIndex), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Max
	SUB	#6, W15
	MOV	W0, _yy1
;ADC_DAC.c,188 :: 		i1b = maxIndex;                                              //Asigna el subindice del valor maximo a la variable i1a
	MOV	_maxIndex, W0
	MOV	W0, _i1b
;ADC_DAC.c,189 :: 		i1a = 0;
	CLR	W0
	MOV	W0, _i1a
;ADC_DAC.c,191 :: 		while (M[i1a]<yy1){
L_Pulse13:
	MOV	_i1a, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W1
	MOV	#lo_addr(_yy1), W0
	CP	W1, [W0]
	BRA LTU	L__Pulse131
	GOTO	L_Pulse14
L__Pulse131:
;ADC_DAC.c,192 :: 		i1a++;
	MOV	#1, W1
	MOV	#lo_addr(_i1a), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,193 :: 		}
	GOTO	L_Pulse13
L_Pulse14:
;ADC_DAC.c,195 :: 		i1 = i1a+((i1b-i1a)/2);
	MOV	_i1b, W1
	MOV	#lo_addr(_i1a), W0
	SUB	W1, [W0], W0
	LSR	W0, #1, W1
	MOV	#lo_addr(_i1a), W0
	ADD	W1, [W0], W1
	MOV	W1, _i1
;ADC_DAC.c,196 :: 		i0 = i1 - dix;
	SUB	W1, #16, W0
	MOV	W0, _i0
;ADC_DAC.c,197 :: 		i2 = i1 + dix;
	ADD	W1, #16, W3
	MOV	W3, _i2
;ADC_DAC.c,199 :: 		yy0 = M[i0];
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W2
	MOV	W2, _yy0
;ADC_DAC.c,200 :: 		yy2 = M[i2];
	SL	W3, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W0
	MOV	W0, [W14+0]
	MOV	W0, _yy2
;ADC_DAC.c,202 :: 		yf0 = (float)(yy0);
	MOV	W2, W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+8]
	MOV	W1, [W14+10]
	MOV	W0, _yf0
	MOV	W1, _yf0+2
;ADC_DAC.c,203 :: 		yf1 = (float)(yy1);
	MOV	_yy1, W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	W0, _yf1
	MOV	W1, _yf1+2
;ADC_DAC.c,204 :: 		yf2 = (float)(yy2);
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
;ADC_DAC.c,206 :: 		nx = (yf0-yf2)/(2.0*(yf0-(2.0*yf1)+yf2));                   //Factor de ajuste determinado por interpolacion parabolica
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
;ADC_DAC.c,207 :: 		dx = nx*dix*tx;
	MOV	#0, W2
	MOV	#16768, W3
	CALL	__Mul_FP
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Mul_FP
	MOV	W0, _dx
	MOV	W1, _dx+2
;ADC_DAC.c,208 :: 		tmax = i1*tx;
	MOV	_i1, W0
	CLR	W1
	CALL	__Long2Float
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Mul_FP
	MOV	W0, _tmax
	MOV	W1, _tmax+2
;ADC_DAC.c,210 :: 		T2 = tmax+dx;
	MOV	_dx, W2
	MOV	_dx+2, W3
	CALL	__AddSub_FP
	MOV	W0, _T2
	MOV	W1, _T2+2
;ADC_DAC.c,212 :: 		}
L_Pulse12:
;ADC_DAC.c,214 :: 		}
L_end_Pulse:
	ULNK
	RETURN
; end of _Pulse

_Moda:

;ADC_DAC.c,216 :: 		int Moda(int VRpt[nd]){
;ADC_DAC.c,217 :: 		ME1=VRpt[0];
	MOV	[W10], W0
	MOV	W0, _ME1
;ADC_DAC.c,218 :: 		for (mi=0;mi<nd;mi++){
	MOV	#lo_addr(_mi), W1
	CLR	W0
	MOV.B	W0, [W1]
L_Moda15:
	MOV	#lo_addr(_mi), W0
	MOV.B	[W0], W0
	CP.B	W0, #20
	BRA LTU	L__Moda133
	GOTO	L_Moda16
L__Moda133:
;ADC_DAC.c,219 :: 		if (VRpt[mi]==ME1){
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W1
	MOV	#lo_addr(_ME1), W0
	CP	W1, [W0]
	BRA Z	L__Moda134
	GOTO	L_Moda18
L__Moda134:
;ADC_DAC.c,220 :: 		Mc1++;
	MOV.B	#1, W1
	MOV	#lo_addr(_Mc1), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,221 :: 		}else{
	GOTO	L_Moda19
L_Moda18:
;ADC_DAC.c,222 :: 		if (Mb2==0){
	MOV	#lo_addr(_Mb2), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__Moda135
	GOTO	L_Moda20
L__Moda135:
;ADC_DAC.c,223 :: 		ME2=VRpt[mi];
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W0
	MOV	W0, _ME2
;ADC_DAC.c,224 :: 		Mb2=1;
	MOV	#lo_addr(_Mb2), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,225 :: 		}
L_Moda20:
;ADC_DAC.c,226 :: 		if (VRpt[mi]==ME2){
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W1
	MOV	#lo_addr(_ME2), W0
	CP	W1, [W0]
	BRA Z	L__Moda136
	GOTO	L_Moda21
L__Moda136:
;ADC_DAC.c,227 :: 		Mc2++;
	MOV.B	#1, W1
	MOV	#lo_addr(_Mc2), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,228 :: 		}else{
	GOTO	L_Moda22
L_Moda21:
;ADC_DAC.c,229 :: 		if (Mb3==0){
	MOV	#lo_addr(_Mb3), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__Moda137
	GOTO	L_Moda23
L__Moda137:
;ADC_DAC.c,230 :: 		ME3=VRpt[mi];
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W0
	MOV	W0, _ME3
;ADC_DAC.c,231 :: 		Mb3=1;
	MOV	#lo_addr(_Mb3), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,232 :: 		}
L_Moda23:
;ADC_DAC.c,233 :: 		if (VRpt[mi]==ME3){
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W1
	MOV	#lo_addr(_ME3), W0
	CP	W1, [W0]
	BRA Z	L__Moda138
	GOTO	L_Moda24
L__Moda138:
;ADC_DAC.c,234 :: 		Mc3++;
	MOV.B	#1, W1
	MOV	#lo_addr(_Mc3), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,235 :: 		}
L_Moda24:
;ADC_DAC.c,236 :: 		}
L_Moda22:
;ADC_DAC.c,237 :: 		}
L_Moda19:
;ADC_DAC.c,218 :: 		for (mi=0;mi<nd;mi++){
	MOV.B	#1, W1
	MOV	#lo_addr(_mi), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,239 :: 		}
	GOTO	L_Moda15
L_Moda16:
;ADC_DAC.c,241 :: 		if ((Mc1>Mc2)&&(Mc1>Mc3)){
	MOV	#lo_addr(_Mc1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc2), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda139
	GOTO	L__Moda107
L__Moda139:
	MOV	#lo_addr(_Mc1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc3), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda140
	GOTO	L__Moda106
L__Moda140:
L__Moda105:
;ADC_DAC.c,242 :: 		return ME1;
	MOV	_ME1, W0
	GOTO	L_end_Moda
;ADC_DAC.c,241 :: 		if ((Mc1>Mc2)&&(Mc1>Mc3)){
L__Moda107:
L__Moda106:
;ADC_DAC.c,244 :: 		if ((Mc2>Mc1)&&(Mc2>Mc3)){
	MOV	#lo_addr(_Mc2), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc1), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda141
	GOTO	L__Moda109
L__Moda141:
	MOV	#lo_addr(_Mc2), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc3), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda142
	GOTO	L__Moda108
L__Moda142:
L__Moda104:
;ADC_DAC.c,245 :: 		return ME2;
	MOV	_ME2, W0
	GOTO	L_end_Moda
;ADC_DAC.c,244 :: 		if ((Mc2>Mc1)&&(Mc2>Mc3)){
L__Moda109:
L__Moda108:
;ADC_DAC.c,247 :: 		if ((Mc3>Mc1)&&(Mc3>Mc2)){
	MOV	#lo_addr(_Mc3), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc1), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda143
	GOTO	L__Moda111
L__Moda143:
	MOV	#lo_addr(_Mc3), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc2), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda144
	GOTO	L__Moda110
L__Moda144:
L__Moda103:
;ADC_DAC.c,248 :: 		return ME3;
	MOV	_ME3, W0
	GOTO	L_end_Moda
;ADC_DAC.c,247 :: 		if ((Mc3>Mc1)&&(Mc3>Mc2)){
L__Moda111:
L__Moda110:
;ADC_DAC.c,251 :: 		if (Mc1==Mc2){
	MOV	#lo_addr(_Mc1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc2), W0
	CP.B	W1, [W0]
	BRA Z	L__Moda145
	GOTO	L_Moda34
L__Moda145:
;ADC_DAC.c,252 :: 		return ME1;
	MOV	_ME1, W0
	GOTO	L_end_Moda
;ADC_DAC.c,253 :: 		}
L_Moda34:
;ADC_DAC.c,254 :: 		if (Mc1==Mc3){
	MOV	#lo_addr(_Mc1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc3), W0
	CP.B	W1, [W0]
	BRA Z	L__Moda146
	GOTO	L_Moda35
L__Moda146:
;ADC_DAC.c,255 :: 		return ME1;
	MOV	_ME1, W0
	GOTO	L_end_Moda
;ADC_DAC.c,256 :: 		}
L_Moda35:
;ADC_DAC.c,257 :: 		if (Mc2==Mc3){
	MOV	#lo_addr(_Mc2), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc3), W0
	CP.B	W1, [W0]
	BRA Z	L__Moda147
	GOTO	L_Moda36
L__Moda147:
;ADC_DAC.c,258 :: 		return ME2;
	MOV	_ME2, W0
	GOTO	L_end_Moda
;ADC_DAC.c,259 :: 		}
L_Moda36:
;ADC_DAC.c,262 :: 		}
L_end_Moda:
	RETURN
; end of _Moda

_Distancia:

;ADC_DAC.c,265 :: 		int Distancia(){
;ADC_DAC.c,267 :: 		conts = 0;                               //Limpia el contador de secuencias
	PUSH	W10
	PUSH	W11
	PUSH	W12
	MOV	#lo_addr(_conts), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,268 :: 		T2sum = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2sum
	MOV	W1, _T2sum+2
;ADC_DAC.c,269 :: 		T2prom = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2prom
	MOV	W1, _T2prom+2
;ADC_DAC.c,270 :: 		T2a = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2a
	MOV	W1, _T2a+2
;ADC_DAC.c,271 :: 		T2b = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2b
	MOV	W1, _T2b+2
;ADC_DAC.c,273 :: 		while (conts<Nsm){
L_Distancia37:
	MOV	#lo_addr(_conts), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA LT	L__Distancia149
	GOTO	L_Distancia38
L__Distancia149:
;ADC_DAC.c,274 :: 		Pulse();                           //Inicia una secuencia de medicion
	CALL	_Pulse
;ADC_DAC.c,275 :: 		T2b = T2;
	MOV	_T2, W0
	MOV	_T2+2, W1
	MOV	W0, _T2b
	MOV	W1, _T2b+2
;ADC_DAC.c,276 :: 		if ((T2b-T2a)<=T2umb){             //Verifica si el T2 actual esta dentro de un umbral pre-establecido
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
	BRA GT	L__Distancia150
	INC.B	W0
L__Distancia150:
	CP0.B	W0
	BRA NZ	L__Distancia151
	GOTO	L_Distancia39
L__Distancia151:
;ADC_DAC.c,277 :: 		T2sum = T2sum + T2b;            //Acumula la sumatoria de valores de T2 calculados por la funcion Pulse()
	MOV	_T2sum, W2
	MOV	_T2sum+2, W3
	MOV	_T2b, W0
	MOV	_T2b+2, W1
	CALL	__AddSub_FP
	MOV	W0, _T2sum
	MOV	W1, _T2sum+2
;ADC_DAC.c,278 :: 		conts++;                        //Aumenta el contador de secuencias
	MOV.B	#1, W1
	MOV	#lo_addr(_conts), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,279 :: 		}
L_Distancia39:
;ADC_DAC.c,280 :: 		T2a = T2b;
	MOV	_T2b, W0
	MOV	_T2b+2, W1
	MOV	W0, _T2a
	MOV	W1, _T2a+2
;ADC_DAC.c,281 :: 		}
	GOTO	L_Distancia37
L_Distancia38:
;ADC_DAC.c,283 :: 		T2prom = T2sum/Nsm;
	MOV	#0, W2
	MOV	#16448, W3
	MOV	_T2sum, W0
	MOV	_T2sum+2, W1
	CALL	__Div_FP
	MOV	W0, _T2prom
	MOV	W1, _T2prom+2
;ADC_DAC.c,285 :: 		Velocidad();                             //Calcula la velocidad del sonido
	CALL	_Velocidad
;ADC_DAC.c,288 :: 		TOF = (T1+T2prom-T2adj)/1.0e6;           //Calcula el TOF en seg
	MOV	#57344, W2
	MOV	#17579, W3
	MOV	_T2prom, W0
	MOV	_T2prom+2, W1
	CALL	__AddSub_FP
	MOV	_T2adj, W2
	MOV	_T2adj+2, W3
	CALL	__Sub_FP
	MOV	#9216, W2
	MOV	#18804, W3
	CALL	__Div_FP
	MOV	W0, _TOF
	MOV	W1, _TOF+2
;ADC_DAC.c,289 :: 		Dst = (VSnd*TOF/2.0) * 1000.0;           //Calcula la distancia en mm
	MOV	_VSnd, W2
	MOV	_VSnd+2, W3
	CALL	__Mul_FP
	MOV	#0, W2
	MOV	#16384, W3
	CALL	__Div_FP
	MOV	#0, W2
	MOV	#17530, W3
	CALL	__Mul_FP
	MOV	W0, _Dst
	MOV	W1, _Dst+2
;ADC_DAC.c,290 :: 		doub = modf(Dst, &iptr);
	MOV	#lo_addr(_iptr), W12
	MOV.D	W0, W10
	CALL	_modf
	MOV	W0, _doub
	MOV	W1, _doub+2
;ADC_DAC.c,291 :: 		if (doub>=0.5){
	MOV	#0, W2
	MOV	#16128, W3
	CALL	__Compare_Ge_Fp
	CP0	W0
	CLR.B	W0
	BRA LT	L__Distancia152
	INC.B	W0
L__Distancia152:
	CP0.B	W0
	BRA NZ	L__Distancia153
	GOTO	L_Distancia40
L__Distancia153:
;ADC_DAC.c,292 :: 		Dst=ceil(Dst);
	MOV	_Dst, W10
	MOV	_Dst+2, W11
	CALL	_ceil
	MOV	W0, _Dst
	MOV	W1, _Dst+2
;ADC_DAC.c,293 :: 		}else{
	GOTO	L_Distancia41
L_Distancia40:
;ADC_DAC.c,294 :: 		Dst=floor(Dst);
	MOV	_Dst, W10
	MOV	_Dst+2, W11
	CALL	_floor
	MOV	W0, _Dst
	MOV	W1, _Dst+2
;ADC_DAC.c,295 :: 		}
L_Distancia41:
;ADC_DAC.c,297 :: 		return Dst;
	MOV	_Dst, W0
	MOV	_Dst+2, W1
	CALL	__Float2Longint
;ADC_DAC.c,299 :: 		}
;ADC_DAC.c,297 :: 		return Dst;
;ADC_DAC.c,299 :: 		}
L_end_Distancia:
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _Distancia

_Calcular:
	LNK	#2

;ADC_DAC.c,301 :: 		void Calcular(){
;ADC_DAC.c,303 :: 		if (Ptcn[4]==0x03){
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	#lo_addr(_Ptcn+4), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA Z	L__Calcular155
	GOTO	L_Calcular42
L__Calcular155:
;ADC_DAC.c,305 :: 		Velocidad();
	CALL	_Velocidad
;ADC_DAC.c,306 :: 		Temperatura = (unsigned int)(DSTemp);    //Tranforma el dato de Temperatura de float a entero sin signo
	MOV	_DSTemp, W0
	MOV	_DSTemp+2, W1
	CALL	__Float2Longint
	MOV	W0, _Temperatura
;ADC_DAC.c,307 :: 		chTemp = (unsigned char *) & Temperatura;//Asocia el valor calculado de Temperatura al puntero chTemp
	MOV	#lo_addr(_Temperatura), W0
	MOV	W0, _chTemp
;ADC_DAC.c,309 :: 		} else {
	GOTO	L_Calcular43
L_Calcular42:
;ADC_DAC.c,311 :: 		for (vi=0;vi<nd;vi++){
	MOV	#lo_addr(_vi), W1
	CLR	W0
	MOV.B	W0, [W1]
L_Calcular44:
	MOV	#lo_addr(_vi), W0
	MOV.B	[W0], W0
	CP.B	W0, #20
	BRA LTU	L__Calcular156
	GOTO	L_Calcular45
L__Calcular156:
;ADC_DAC.c,312 :: 		Vdistancia[vi] = Distancia();        //Toma 10 lecturas de la distancia calculada y las almacena en un vector
	MOV	#lo_addr(_vi), W0
	ZE	[W0], W0
	SL	W0, #1, W1
	MOV	#lo_addr(_Vdistancia), W0
	ADD	W0, W1, W0
	MOV	W0, [W14+0]
	CALL	_Distancia
	MOV	[W14+0], W1
	MOV	W0, [W1]
;ADC_DAC.c,311 :: 		for (vi=0;vi<nd;vi++){
	MOV.B	#1, W1
	MOV	#lo_addr(_vi), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,313 :: 		}
	GOTO	L_Calcular44
L_Calcular45:
;ADC_DAC.c,315 :: 		Cdistancia = Moda(Vdistancia);           //Calcula la Moda del vector de distancias
	MOV	#lo_addr(_Vdistancia), W10
	CALL	_Moda
	MOV	W0, _Cdistancia
;ADC_DAC.c,317 :: 		FNivel = (Alt-Cdistancia)/1000.0;        //Calcula el Nivel de liquido en metros
	MOV	#lo_addr(_Alt), W1
	SUBR	W0, [W1], W0
	CLR	W1
	CALL	__Long2Float
	MOV	#0, W2
	MOV	#17530, W3
	CALL	__Div_FP
	MOV	W0, _FNivel
	MOV	W1, _FNivel+2
;ADC_DAC.c,318 :: 		FCaudal = 4960440*pow(FNivel,2.5);       //Calcula el Caudal en litros/hora
	MOV	#0, W12
	MOV	#16416, W13
	MOV.D	W0, W10
	CALL	_pow
	MOV	#24944, W2
	MOV	#19095, W3
	CALL	__Mul_FP
	MOV	W0, _FCaudal
	MOV	W1, _FCaudal+2
;ADC_DAC.c,320 :: 		IDst = (unsigned int)(Cdistancia);       //Tranforma el dato de distancia de float a entero sin signo
	MOV	_Cdistancia, W2
	MOV	W2, _IDst
;ADC_DAC.c,321 :: 		Caudal = (unsigned int)(FCaudal);        //Tranforma el dato de Caudal de float a entero sin signo
	CALL	__Float2Longint
	MOV	W0, _Caudal
;ADC_DAC.c,323 :: 		chIDst = (unsigned char *) & IDst;       //Asocia el valor calculado de Dst al puntero chDst
	MOV	#lo_addr(_IDst), W0
	MOV	W0, _chIDst
;ADC_DAC.c,324 :: 		chCaudal = (unsigned char *) & Caudal;   //Asocia el valor calculado de Temperatura al puntero chTemp
	MOV	#lo_addr(_Caudal), W0
	MOV	W0, _chCaudal
;ADC_DAC.c,326 :: 		}
L_Calcular43:
;ADC_DAC.c,327 :: 		}
L_end_Calcular:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _Calcular

_Responder:

;ADC_DAC.c,330 :: 		void Responder(unsigned int Reg){
;ADC_DAC.c,332 :: 		if (Reg==0x01){
	CP	W10, #1
	BRA Z	L__Responder158
	GOTO	L_Responder47
L__Responder158:
;ADC_DAC.c,333 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder48:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder159
	GOTO	L_Responder49
L__Responder159:
;ADC_DAC.c,334 :: 		Rspt[ir]=(*chIDst++);             //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Distancia calculada
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chIDst, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chIDst), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,333 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,335 :: 		}
	GOTO	L_Responder48
L_Responder49:
;ADC_DAC.c,336 :: 		}
L_Responder47:
;ADC_DAC.c,337 :: 		if (Reg==0x02){
	CP	W10, #2
	BRA Z	L__Responder160
	GOTO	L_Responder51
L__Responder160:
;ADC_DAC.c,338 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder52:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder161
	GOTO	L_Responder53
L__Responder161:
;ADC_DAC.c,339 :: 		Rspt[ir]=(*chCaudal++);           //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del Caudal calculado
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chCaudal, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chCaudal), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,338 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,340 :: 		}
	GOTO	L_Responder52
L_Responder53:
;ADC_DAC.c,341 :: 		}
L_Responder51:
;ADC_DAC.c,342 :: 		if (Reg==0x03){
	CP	W10, #3
	BRA Z	L__Responder162
	GOTO	L_Responder55
L__Responder162:
;ADC_DAC.c,343 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder56:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder163
	GOTO	L_Responder57
L__Responder163:
;ADC_DAC.c,344 :: 		Rspt[ir]=(*chTemp++);             //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Temperatura calculada
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chTemp, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chTemp), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,343 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,345 :: 		}
	GOTO	L_Responder56
L_Responder57:
;ADC_DAC.c,346 :: 		}
L_Responder55:
;ADC_DAC.c,348 :: 		Rspt[2]=Ptcn[2];                         //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOV	#lo_addr(_Rspt+2), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,350 :: 		RB5_bit = 1;                             //Establece el Max485 en modo de escritura
	BSET	RB5_bit, BitPos(RB5_bit+0)
;ADC_DAC.c,351 :: 		for (ir=0;ir<Rsize;ir++){
	MOV	#lo_addr(_ir), W1
	CLR	W0
	MOV.B	W0, [W1]
L_Responder59:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #6
	BRA LTU	L__Responder164
	GOTO	L_Responder60
L__Responder164:
;ADC_DAC.c,352 :: 		UART1_Write(Rspt[ir]);               //Envia la trama de respuesta
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W0
	PUSH	W10
	ZE	[W0], W10
	CALL	_UART1_Write
	POP	W10
;ADC_DAC.c,351 :: 		for (ir=0;ir<Rsize;ir++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,353 :: 		}
	GOTO	L_Responder59
L_Responder60:
;ADC_DAC.c,354 :: 		while(UART1_Tx_Idle()==0);               //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_Responder62:
	CALL	_UART1_Tx_Idle
	CP	W0, #0
	BRA Z	L__Responder165
	GOTO	L_Responder63
L__Responder165:
	GOTO	L_Responder62
L_Responder63:
;ADC_DAC.c,355 :: 		RB5_bit = 0;                             //Establece el Max485 en modo de lectura;
	BCLR	RB5_bit, BitPos(RB5_bit+0)
;ADC_DAC.c,357 :: 		for (ipp=3;ipp<5;ipp++){
	MOV	#lo_addr(_ipp), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
L_Responder64:
	MOV	#lo_addr(_ipp), W0
	MOV.B	[W0], W0
	CP.B	W0, #5
	BRA LTU	L__Responder166
	GOTO	L_Responder65
L__Responder166:
;ADC_DAC.c,358 :: 		Rspt[ipp]=0;;                        //Limpia la trama de respuesta
	MOV	#lo_addr(_ipp), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,357 :: 		for (ipp=3;ipp<5;ipp++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ipp), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,359 :: 		}
	GOTO	L_Responder64
L_Responder65:
;ADC_DAC.c,361 :: 		}
L_end_Responder:
	RETURN
; end of _Responder

_UART1Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;ADC_DAC.c,365 :: 		void UART1Interrupt() iv IVT_ADDR_U1RXINTERRUPT {
;ADC_DAC.c,367 :: 		if (UART1_Data_Ready()==1){
	CALL	_UART1_Data_Ready
	CP	W0, #1
	BRA Z	L__UART1Interrupt168
	GOTO	L_UART1Interrupt67
L__UART1Interrupt168:
;ADC_DAC.c,368 :: 		Dato = UART1_Read();
	CALL	_UART1_Read
	MOV	#lo_addr(_Dato), W1
	MOV.B	W0, [W1]
;ADC_DAC.c,369 :: 		}
L_UART1Interrupt67:
;ADC_DAC.c,370 :: 		if ((Dato==Hdr)&&(ip==0)){                    //Verifica que el primer dato en llegar sea el identificador de inicio de trama
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], W1
	MOV.B	#58, W0
	CP.B	W1, W0
	BRA Z	L__UART1Interrupt169
	GOTO	L__UART1Interrupt116
L__UART1Interrupt169:
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__UART1Interrupt170
	GOTO	L__UART1Interrupt115
L__UART1Interrupt170:
L__UART1Interrupt114:
;ADC_DAC.c,371 :: 		BanT = 1;                                 //Activa la bandera de trama
	MOV	#lo_addr(_BanT), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,372 :: 		Ptcn[ip] = Dato;                          //Almacena el Dato en la trama de peticion
	MOV	#lo_addr(_ip), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,370 :: 		if ((Dato==Hdr)&&(ip==0)){                    //Verifica que el primer dato en llegar sea el identificador de inicio de trama
L__UART1Interrupt116:
L__UART1Interrupt115:
;ADC_DAC.c,374 :: 		if ((Dato!=Hdr)&&(ip==0)){                    //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], W1
	MOV.B	#58, W0
	CP.B	W1, W0
	BRA NZ	L__UART1Interrupt171
	GOTO	L__UART1Interrupt118
L__UART1Interrupt171:
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__UART1Interrupt172
	GOTO	L__UART1Interrupt117
L__UART1Interrupt172:
L__UART1Interrupt113:
;ADC_DAC.c,375 :: 		ip=-1;                                    //Si es asi: reduce el subindice en una unidad
	MOV	#lo_addr(_ip), W1
	MOV.B	#255, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,374 :: 		if ((Dato!=Hdr)&&(ip==0)){                    //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
L__UART1Interrupt118:
L__UART1Interrupt117:
;ADC_DAC.c,377 :: 		if ((BanT==1)&&(ip!=0)){
	MOV	#lo_addr(_BanT), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__UART1Interrupt173
	GOTO	L__UART1Interrupt120
L__UART1Interrupt173:
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA NZ	L__UART1Interrupt174
	GOTO	L__UART1Interrupt119
L__UART1Interrupt174:
L__UART1Interrupt112:
;ADC_DAC.c,378 :: 		Ptcn[ip] = Dato;                          //Almacena el resto de datos en la trama de peticion si la bandera de trama esta activada
	MOV	#lo_addr(_ip), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,377 :: 		if ((BanT==1)&&(ip!=0)){
L__UART1Interrupt120:
L__UART1Interrupt119:
;ADC_DAC.c,381 :: 		ip++;                                         //Aumenta el subindice una unidad
	MOV.B	#1, W1
	MOV	#lo_addr(_ip), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,382 :: 		if (ip==Psize){                               //Verifica que se haya terminado de llenar la trama de datos
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #6
	BRA Z	L__UART1Interrupt175
	GOTO	L_UART1Interrupt77
L__UART1Interrupt175:
;ADC_DAC.c,383 :: 		BanP = 1;                                 //Habilita la bandera de lectura de datos
	MOV	#lo_addr(_BanP), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,384 :: 		BanT = 0;
	MOV	#lo_addr(_BanT), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,385 :: 		ip=0;                                     //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
	MOV	#lo_addr(_ip), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,386 :: 		}
L_UART1Interrupt77:
;ADC_DAC.c,388 :: 		U1RXIF_bit = 0;                               //Limpia la bandera de interrupcion de UARTRX
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;ADC_DAC.c,390 :: 		}
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

;ADC_DAC.c,393 :: 		void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
;ADC_DAC.c,395 :: 		SAMP_bit = 0;                                 //Limpia el bit SAMP para iniciar la conversion del ADC
	BCLR	SAMP_bit, BitPos(SAMP_bit+0)
;ADC_DAC.c,396 :: 		while (!AD1CON1bits.DONE);                    //Espera hasta que se complete la conversion
L_Timer1Interrupt78:
	BTSC	AD1CON1bits, #0
	GOTO	L_Timer1Interrupt79
	GOTO	L_Timer1Interrupt78
L_Timer1Interrupt79:
;ADC_DAC.c,397 :: 		if (i<nm){
	MOV	_i, W1
	MOV	#350, W0
	CP	W1, W0
	BRA LTU	L__Timer1Interrupt177
	GOTO	L_Timer1Interrupt80
L__Timer1Interrupt177:
;ADC_DAC.c,398 :: 		M[i] = ADC1BUF0;                           //Almacena el valor actual de la conversion del ADC en el vector M
	MOV	_i, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	ADC1BUF0, WREG
	MOV	W0, [W1]
;ADC_DAC.c,399 :: 		i++;                                       //Aumenta en 1 el subindice del vector de Muestras
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,400 :: 		} else {
	GOTO	L_Timer1Interrupt81
L_Timer1Interrupt80:
;ADC_DAC.c,401 :: 		bm = 1;                                    //Cambia el valor de la bandera bm para terminar con el muestreo y dar comienzo al procesamiento de la señal
	MOV	#lo_addr(_bm), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,402 :: 		T1CON.TON = 0;                             //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,403 :: 		IEC0.T1IE = 0;                             //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,404 :: 		}
L_Timer1Interrupt81:
;ADC_DAC.c,405 :: 		T1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,406 :: 		}
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

;ADC_DAC.c,409 :: 		void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
;ADC_DAC.c,410 :: 		if (contp<10){                                //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (
	MOV	_contp, W0
	CP	W0, #10
	BRA LTU	L__Timer2Interrupt179
	GOTO	L_Timer2Interrupt82
L__Timer2Interrupt179:
;ADC_DAC.c,411 :: 		RB2_bit = ~RB2_bit;                      //Conmuta el valor del pin RB14
	BTG	RB2_bit, BitPos(RB2_bit+0)
;ADC_DAC.c,412 :: 		}else {
	GOTO	L_Timer2Interrupt83
L_Timer2Interrupt82:
;ADC_DAC.c,413 :: 		RB2_bit = 0;                            //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCLR	RB2_bit, BitPos(RB2_bit+0)
;ADC_DAC.c,415 :: 		if (contp==110){
	MOV	#110, W1
	MOV	#lo_addr(_contp), W0
	CP	W1, [W0]
	BRA Z	L__Timer2Interrupt180
	GOTO	L_Timer2Interrupt84
L__Timer2Interrupt180:
;ADC_DAC.c,416 :: 		IEC0.T2IE = 0;                       //Desabilita la interrupcion por desborde del TMR2 para no interferir con las interrupciones por desborde de TMR1
	BCLR	IEC0, #7
;ADC_DAC.c,417 :: 		T2CON.TON = 0;                       //Apaga el TMR2
	BCLR	T2CON, #15
;ADC_DAC.c,418 :: 		IEC0.T1IE = 1;                       //Habilita la interrupcion por desborde del TMR1 para dar inicio al muestreo del ADC
	BSET	IEC0, #3
;ADC_DAC.c,419 :: 		TMR1 = 0;                            //Encera el TMR1
	CLR	TMR1
;ADC_DAC.c,420 :: 		T1IF_bit = 0;                        //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,421 :: 		T1CON.TON = 1;                       //Enciende el TMR1
	BSET	T1CON, #15
;ADC_DAC.c,422 :: 		bm=0;
	MOV	#lo_addr(_bm), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,423 :: 		}
L_Timer2Interrupt84:
;ADC_DAC.c,425 :: 		}
L_Timer2Interrupt83:
;ADC_DAC.c,426 :: 		contp++;                                      //Aumenta el contador en una unidad.
	MOV	#1, W1
	MOV	#lo_addr(_contp), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,427 :: 		T2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,428 :: 		}
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

;ADC_DAC.c,432 :: 		void Configuracion(){
;ADC_DAC.c,435 :: 		CLKDIVbits.PLLPRE = 0;                      //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,436 :: 		PLLFBD = 38;                                //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
	MOV	#38, W0
	MOV	WREG, PLLFBD
;ADC_DAC.c,437 :: 		CLKDIVbits.PLLPOST = 0;                     //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,440 :: 		AD1PCFGL = 0xFFFD;                          //Configura el puerto AN1 como entrada analogica y todas las demas como digitales
	MOV	#65533, W0
	MOV	WREG, AD1PCFGL
;ADC_DAC.c,441 :: 		TRISA1_bit = 1;                             //Establece el pin RA1 como entrada
	BSET	TRISA1_bit, BitPos(TRISA1_bit+0)
;ADC_DAC.c,442 :: 		TRISB = 0xFF40;                             //TRISB = 11111111 01000000
	MOV	#65344, W0
	MOV	WREG, TRISB
;ADC_DAC.c,445 :: 		AD1CON1.AD12B = 0;                          //Configura el ADC en modo de 10 bits
	BCLR	AD1CON1, #10
;ADC_DAC.c,446 :: 		AD1CON1bits.FORM = 0x00;                    //Formato de la canversion: 00->(0_1023)|01->(-512_511)|02->(0_0.999)|03->(-1_0.999)
	MOV	AD1CON1bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON1bits
;ADC_DAC.c,447 :: 		AD1CON1.SIMSAM = 0;                         //0 -> Muestrea múltiples canales individualmente en secuencia
	BCLR	AD1CON1, #3
;ADC_DAC.c,448 :: 		AD1CON1.ADSIDL = 0;                         //Continua con la operacion del modulo durante el modo desocupado
	BCLR	AD1CON1, #13
;ADC_DAC.c,449 :: 		AD1CON1.ASAM = 1;                           //Muestreo automatico
	BSET	AD1CON1, #2
;ADC_DAC.c,450 :: 		AD1CON1bits.SSRC = 0x00;                    //Conversion manual
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	[W0], W1
	MOV.B	#31, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,452 :: 		AD1CON2bits.VCFG = 0;                       //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
	MOV	AD1CON2bits, W1
	MOV	#8191, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,453 :: 		AD1CON2bits.CHPS = 0;                       //Selecciona unicamente el canal CH0
	MOV	AD1CON2bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,454 :: 		AD1CON2.CSCNA = 0;                          //No escanea las entradas de CH0 durante la Muestra A
	BCLR	AD1CON2, #10
;ADC_DAC.c,455 :: 		AD1CON2.BUFM = 0;                           //Bit de selección del modo de relleno del búfer, 0 -> Siempre comienza a llenar el buffer desde el principio
	BCLR	AD1CON2, #1
;ADC_DAC.c,456 :: 		AD1CON2.ALTS = 0x00;                        //Utiliza siempre la selección de entrada de canal para la muestra A
	BCLR	AD1CON2, #0
;ADC_DAC.c,458 :: 		AD1CON3.ADRC = 0;                           //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
	BCLR	AD1CON3, #15
;ADC_DAC.c,459 :: 		AD1CON3bits.ADCS = 0x02;                    //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
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
;ADC_DAC.c,460 :: 		AD1CON3bits.SAMC = 0x02;                    //Auto Sample Time bits, 2 -> 2*TAD (minimo periodo de muestreo para 10 bits)
	MOV	#512, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CON3bits
;ADC_DAC.c,462 :: 		AD1CHS0.CH0NB = 0;                          //Channel 0 negative input is VREF-
	BCLR	AD1CHS0, #15
;ADC_DAC.c,463 :: 		AD1CHS0bits.CH0SB = 0x01;                   //Channel 0 positive input is AN1
	MOV	#256, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CHS0bits
;ADC_DAC.c,464 :: 		AD1CHS0.CH0NA = 0;                          //Channel 0 negative input is VREF-
	BCLR	AD1CHS0, #7
;ADC_DAC.c,465 :: 		AD1CHS0bits.CH0SA = 0x01;                   //Channel 0 positive input is AN1
	MOV.B	#1, W0
	MOV.B	W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(AD1CHS0bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,467 :: 		AD1CHS123 = 0;                              //AD1CHS123: ADC1 INPUT CHANNEL 1, 2, 3 SELECT REGISTER
	CLR	AD1CHS123
;ADC_DAC.c,469 :: 		AD1CSSL = 0x00;                             //Se salta todos los puertos ANx para los escaneos de entrada
	CLR	AD1CSSL
;ADC_DAC.c,471 :: 		AD1CON1.ADON = 1;                           //Enciende el modulo ADC
	BSET	AD1CON1, #15
;ADC_DAC.c,474 :: 		T1CON = 0x8000;                             //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T1CON
;ADC_DAC.c,475 :: 		IEC0.T1IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR1 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #3
;ADC_DAC.c,476 :: 		T1IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,477 :: 		PR1 = 200;                                  //Genera una interrupcion cada 5us (Fs=200KHz)
	MOV	#200, W0
	MOV	WREG, PR1
;ADC_DAC.c,480 :: 		T2CON = 0x8000;                             //Habilita el TMR2, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T2CON
;ADC_DAC.c,481 :: 		IEC0.T2IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR2 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #7
;ADC_DAC.c,482 :: 		T2IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,483 :: 		PR2 = 500;                                  //Genera una interrupcion cada 12.5us
	MOV	#500, W0
	MOV	WREG, PR2
;ADC_DAC.c,486 :: 		RPINR18bits.U1RXR = 0x06;                   //Asisgna Rx a RP6
	MOV.B	#6, W0
	MOV.B	W0, W1
	MOV	#lo_addr(RPINR18bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(RPINR18bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(RPINR18bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,487 :: 		RPOR3bits.RP7R = 0x03;                      //Asigna Tx a RP7
	MOV	#768, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR3bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR3bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR3bits
;ADC_DAC.c,488 :: 		IEC0.U1RXIE = 1;                            //Habilita la interrupcion por recepcion de dato por UART
	BSET	IEC0, #11
;ADC_DAC.c,489 :: 		U1RXIF_bit = 0;                             //Limpia la bandera de interrupcion de UARTRX
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;ADC_DAC.c,492 :: 		IPC0bits.T1IP = 0x06;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#24576, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC0bits
;ADC_DAC.c,493 :: 		IPC1bits.T2IP = 0x05;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR2
	MOV	#20480, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;ADC_DAC.c,494 :: 		IPC2bits.U1RXIP = 0x07;                     //Nivel de prioridad de la interrupcion UARTRX
	MOV	IPC2bits, W1
	MOV	#28672, W0
	IOR	W1, W0, W0
	MOV	WREG, IPC2bits
;ADC_DAC.c,498 :: 		}
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

;ADC_DAC.c,502 :: 		void main() {
;ADC_DAC.c,504 :: 		Configuracion();
	PUSH	W10
	PUSH	W11
	CALL	_Configuracion
;ADC_DAC.c,506 :: 		UART1_Init(9600);                                        //Inicializa el modulo UART a 9600 bps
	MOV	#9600, W10
	MOV	#0, W11
	CALL	_UART1_Init
;ADC_DAC.c,507 :: 		Delay_ms(100);                                           //Espera hata que el modulo UART se estabilice
	MOV	#21, W8
	MOV	#22619, W7
L_main85:
	DEC	W7
	BRA NZ	L_main85
	DEC	W8
	BRA NZ	L_main85
;ADC_DAC.c,508 :: 		RB5_bit = 0;                                             //Establece el Max485 en modo de lectura
	BCLR	RB5_bit, BitPos(RB5_bit+0)
;ADC_DAC.c,510 :: 		Id = (PORTB&0xFF00)>>8;                                  //Lee el Id de esclavo establecido por el dipswitch
	MOV	PORTB, W1
	MOV	#65280, W0
	AND	W1, W0, W0
	LSR	W0, #8, W2
	MOV	W2, _Id
;ADC_DAC.c,511 :: 		T2adj = 460.0;                                           //Factor de calibracion de T2: Con Temp=20 y Vsnd=343.2, reduce la medida 1mm por cada 3 unidades que se aumente a este factor
	MOV	#0, W0
	MOV	#17382, W1
	MOV	W0, _T2adj
	MOV	W1, _T2adj+2
;ADC_DAC.c,514 :: 		chDP = &DatoPtcn;                                        //Asocia el valor de DatoPtcn al puntero chDP
	MOV	#lo_addr(_DatoPtcn), W0
	MOV	W0, _chDP
;ADC_DAC.c,515 :: 		ip=0;
	MOV	#lo_addr(_ip), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,517 :: 		Rspt[0] = Hdr;                                           //Se rellena el primer byte de la trama de respuesta con el delimitador de inicio de trama
	MOV	#lo_addr(_Rspt), W1
	MOV.B	#58, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,518 :: 		Rspt[1] = Id;                                            //Se rellena el segundo byte de la trama de repuesta con el Id del tipo de sensor
	MOV	#lo_addr(_Rspt+1), W0
	MOV.B	W2, [W0]
;ADC_DAC.c,519 :: 		Rspt[Rsize-1] = End;                                     //Se rellena el ultimo byte de la trama de repuesta con el delimitador de final de trama
	MOV	#lo_addr(_Rspt+5), W1
	MOV.B	#13, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,521 :: 		while(1){
L_main87:
;ADC_DAC.c,532 :: 		if (BanP==1){                                   //Verifica si se realizo una peticion
	MOV	#lo_addr(_BanP), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__main183
	GOTO	L_main89
L__main183:
;ADC_DAC.c,534 :: 		if ((Ptcn[1]==Id)&&(Ptcn[Psize-1]==End)){    //Verifica el identificador de esclavo y el byte de final de trama
	MOV	#lo_addr(_Ptcn+1), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Id), W0
	CP	W1, [W0]
	BRA Z	L__main184
	GOTO	L__main123
L__main184:
	MOV	#lo_addr(_Ptcn+5), W0
	MOV.B	[W0], W0
	CP.B	W0, #13
	BRA Z	L__main185
	GOTO	L__main122
L__main185:
L__main121:
;ADC_DAC.c,536 :: 		Fcn = Ptcn[2];                            //Almacena el tipo de funcion requerida
	MOV	#lo_addr(_Fcn), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,538 :: 		if (Fcn==0x01){                           //01: Lee el registro principal (Distancia)
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__main186
	GOTO	L_main93
L__main186:
;ADC_DAC.c,539 :: 		Calcular();                            //Realiza una secuencia de calculo
	CALL	_Calcular
;ADC_DAC.c,540 :: 		Responder(0x01);                       //Envia la trama de repuesta con el valor del registro 0x01
	MOV	#1, W10
	CALL	_Responder
;ADC_DAC.c,541 :: 		}
L_main93:
;ADC_DAC.c,543 :: 		if (Fcn==0x02){                           //02: Lee el registro especicfico (01:Distancia, 02:Caudal, 03:Temperatura)
	MOV	#lo_addr(_Fcn), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__main187
	GOTO	L_main94
L__main187:
;ADC_DAC.c,544 :: 		Calcular();                            //Realiza una secuencia de calculo
	CALL	_Calcular
;ADC_DAC.c,545 :: 		*chDP = Ptcn[4];                       //Almacena el byte 4 de la trama de peticion en el LSB de la variable DatoPtcn
	MOV	#lo_addr(_Ptcn+4), W1
	MOV	_chDP, W0
	MOV.B	[W1], [W0]
;ADC_DAC.c,546 :: 		*(chDP+1) = Ptcn[3];                   //Almacena el byte 3 de la trama de peticion en el MSB de la variable DatoPtcn
	MOV	_chDP, W0
	ADD	W0, #1, W1
	MOV	#lo_addr(_Ptcn+3), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,547 :: 		Responder(DatoPtcn);                   //Envia la trama de repuesta con el valor del registro requerido
	MOV	_DatoPtcn, W10
	CALL	_Responder
;ADC_DAC.c,548 :: 		}
L_main94:
;ADC_DAC.c,550 :: 		DatoPtcn = 0;                             //Limpia la variable
	CLR	W0
	MOV	W0, _DatoPtcn
;ADC_DAC.c,552 :: 		for (ipp=0;ipp<Psize;ipp++){
	MOV	#lo_addr(_ipp), W1
	CLR	W0
	MOV.B	W0, [W1]
L_main95:
	MOV	#lo_addr(_ipp), W0
	MOV.B	[W0], W0
	CP.B	W0, #6
	BRA LTU	L__main188
	GOTO	L_main96
L__main188:
;ADC_DAC.c,553 :: 		Ptcn[ipp]=0;                          //Limpia la trama de peticion
	MOV	#lo_addr(_ipp), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,552 :: 		for (ipp=0;ipp<Psize;ipp++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ipp), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,554 :: 		}
	GOTO	L_main95
L_main96:
;ADC_DAC.c,556 :: 		BanP = 0;                                 //Limpia la bandera de lectura de datos
	MOV	#lo_addr(_BanP), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,558 :: 		}else{
	GOTO	L_main98
;ADC_DAC.c,534 :: 		if ((Ptcn[1]==Id)&&(Ptcn[Psize-1]==End)){    //Verifica el identificador de esclavo y el byte de final de trama
L__main123:
L__main122:
;ADC_DAC.c,559 :: 		for (ipp=0;ipp<Psize;ipp++){
	MOV	#lo_addr(_ipp), W1
	CLR	W0
	MOV.B	W0, [W1]
L_main99:
	MOV	#lo_addr(_ipp), W0
	MOV.B	[W0], W0
	CP.B	W0, #6
	BRA LTU	L__main189
	GOTO	L_main100
L__main189:
;ADC_DAC.c,560 :: 		Ptcn[ipp]=0;                       //Limpia la trama de peticion
	MOV	#lo_addr(_ipp), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,559 :: 		for (ipp=0;ipp<Psize;ipp++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ipp), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,561 :: 		}
	GOTO	L_main99
L_main100:
;ADC_DAC.c,562 :: 		BanP = 0;                              //Limpia la bandera de lectura de datos
	MOV	#lo_addr(_BanP), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,563 :: 		}
L_main98:
;ADC_DAC.c,564 :: 		}
L_main89:
;ADC_DAC.c,566 :: 		}
	GOTO	L_main87
;ADC_DAC.c,568 :: 		}
L_end_main:
	POP	W11
	POP	W10
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
