
_Velocidad:
	LNK	#4

;ADC_DAC.c,128 :: 		void Velocidad(){
;ADC_DAC.c,133 :: 		Ow_Reset(&PORTA, 0);                          //Onewire reset signal
	PUSH	W10
	PUSH	W11
	PUSH	W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;ADC_DAC.c,134 :: 		Ow_Write(&PORTA, 0, 0xCC);                    //Issue command SKIP_ROM
	MOV.B	#204, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,135 :: 		Ow_Write(&PORTA, 0, 0x44);                    //Issue command CONVERT_T
	MOV.B	#68, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,136 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad0:
	DEC	W7
	BRA NZ	L_Velocidad0
	NOP
;ADC_DAC.c,138 :: 		Ow_Reset(&PORTA, 0);
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Reset
;ADC_DAC.c,139 :: 		Ow_Write(&PORTA, 0, 0xCC);                    //Issue command SKIP_ROM
	MOV.B	#204, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,140 :: 		Ow_Write(&PORTA, 0, 0xBE);                    //Issue command READ_SCRATCHPAD
	MOV.B	#190, W12
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Write
;ADC_DAC.c,141 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad2:
	DEC	W7
	BRA NZ	L_Velocidad2
	NOP
;ADC_DAC.c,143 :: 		Temp =  Ow_Read(&PORTA, 0);
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
; Temp start address is: 10 (W5)
	ZE	W0, W5
;ADC_DAC.c,144 :: 		Temp = (Ow_Read(&PORTA, 0) << 8) + Temp;
	CLR	W11
	MOV	#lo_addr(PORTA), W10
	CALL	_Ow_Read
	ZE	W0, W0
	SL	W0, #8, W0
	ADD	W0, W5, W0
; Temp end address is: 10 (W5)
; Temp start address is: 4 (W2)
	MOV	W0, W2
;ADC_DAC.c,146 :: 		if (Temp & 0x8000) {
	BTSS	W0, #15
	GOTO	L__Velocidad133
;ADC_DAC.c,147 :: 		Temp = 0;                                  //Si la temperatura es negativa la establece como cero.
	CLR	W2
; Temp end address is: 4 (W2)
;ADC_DAC.c,148 :: 		}
	GOTO	L_Velocidad4
L__Velocidad133:
;ADC_DAC.c,146 :: 		if (Temp & 0x8000) {
;ADC_DAC.c,148 :: 		}
L_Velocidad4:
;ADC_DAC.c,150 :: 		Rint = Temp >> 4;                             //Extrae la parte entera de la respuesta del sensor
; Temp start address is: 4 (W2)
	LSR	W2, #4, W0
; Rint start address is: 6 (W3)
	MOV	W0, W3
;ADC_DAC.c,151 :: 		Rfrac = ((Temp & 0x000F) * 625) / 10000.;     //Extrae la parte decimal de la respuesta del sensor
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
;ADC_DAC.c,152 :: 		DSTemp = Rint + Rfrac;                        //Expresa la temperatura en punto flotante
	MOV	W3, W0
	CLR	W1
	CALL	__Long2Float
; Rint end address is: 6 (W3)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	MOV	W0, _DSTemp
	MOV	W1, _DSTemp+2
;ADC_DAC.c,154 :: 		VSnd = 331.45 * sqrt(1+(DsTemp/273));
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
;ADC_DAC.c,155 :: 		}
L_end_Velocidad:
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _Velocidad

_Pulse:
	LNK	#12

;ADC_DAC.c,158 :: 		void Pulse(){
;ADC_DAC.c,161 :: 		contp = 0;                                               //Limpia la variable del contador de pulsos
	CLR	W0
	MOV	W0, _contp
;ADC_DAC.c,162 :: 		RB2_bit = 0;                                             //Limpia el pin que produce los pulsos de exitacion del transductor
	BCLR	RB2_bit, BitPos(RB2_bit+0)
;ADC_DAC.c,164 :: 		T1CON.TON = 0;                                           //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,165 :: 		IEC0.T1IE = 0;                                           //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,167 :: 		TMR2 = 0;                                                //Encera el TMR2
	CLR	TMR2
;ADC_DAC.c,168 :: 		IEC0.T2IE = 1;                                           //Habilita la interrupcion por desborde del TMR2
	BSET	IEC0, #7
;ADC_DAC.c,169 :: 		T2CON.TON = 1;                                           //Enciende el TMR2
	BSET	T2CON, #15
;ADC_DAC.c,171 :: 		i = 0;                                                   //Limpia las variables asociadas al almacenamiento de la señal muestreada
	CLR	W0
	MOV	W0, _i
;ADC_DAC.c,174 :: 		while(bm!=1);                                            //Espera hasta que haya terminado de enviar y recibir todas las muestras
L_Pulse5:
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA NZ	L__Pulse160
	GOTO	L_Pulse6
L__Pulse160:
	GOTO	L_Pulse5
L_Pulse6:
;ADC_DAC.c,177 :: 		if (bm==1){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__Pulse161
	GOTO	L_Pulse7
L__Pulse161:
;ADC_DAC.c,180 :: 		Mmax = Vector_Max(M, nm, &MIndexMax);
	MOV	#lo_addr(_MIndexMax), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Max
	SUB	#6, W15
	MOV	W0, _Mmax
;ADC_DAC.c,181 :: 		Mmin = Vector_Min(M, nm, &MIndexMin);
	MOV	#lo_addr(_MIndexMin), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Min
	SUB	#6, W15
	MOV	W0, _Mmin
;ADC_DAC.c,182 :: 		Mmed = Mmax-((Mmax-Mmin)/2);
	MOV	#lo_addr(_Mmax), W1
	SUBR	W0, [W1], W0
	LSR	W0, #1, W2
	MOV	#lo_addr(_Mmax), W1
	MOV	#lo_addr(_Mmed), W0
	SUBR	W2, [W1], [W0]
;ADC_DAC.c,184 :: 		for (k=0;k<nm;k++){
	CLR	W0
	MOV	W0, _k
L_Pulse8:
	MOV	_k, W1
	MOV	#350, W0
	CP	W1, W0
	BRA LTU	L__Pulse162
	GOTO	L_Pulse9
L__Pulse162:
;ADC_DAC.c,187 :: 		value = M[k]-Mmed;
	MOV	_k, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W3
	MOV	[W3], W2
	MOV	#lo_addr(_Mmed), W1
	MOV	#lo_addr(_value), W0
	SUB	W2, [W1], [W0]
;ADC_DAC.c,188 :: 		if (M[k]<Mmed){
	MOV	[W3], W1
	MOV	#lo_addr(_Mmed), W0
	CP	W1, [W0]
	BRA LTU	L__Pulse163
	GOTO	L_Pulse11
L__Pulse163:
;ADC_DAC.c,189 :: 		value = (M[k]+((Mmed-M[k])*2))-(Mmed);
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
;ADC_DAC.c,190 :: 		}
L_Pulse11:
;ADC_DAC.c,194 :: 		for( f=O-1; f!=0; f-- ) XFIR[f]=XFIR[f-1];
	MOV	#20, W0
	MOV	W0, _f
L_Pulse12:
	MOV	_f, W0
	CP	W0, #0
	BRA NZ	L__Pulse164
	GOTO	L_Pulse13
L__Pulse164:
	MOV	_f, W0
	SL	W0, #2, W1
	MOV	#lo_addr(_XFIR), W0
	ADD	W0, W1, W2
	MOV	_f, W0
	DEC	W0
	SL	W0, #2, W1
	MOV	#lo_addr(_XFIR), W0
	ADD	W0, W1, W0
	MOV	[W0++], [W2++]
	MOV	[W0--], [W2--]
	MOV	#1, W1
	MOV	#lo_addr(_f), W0
	SUBR	W1, [W0], [W0]
	GOTO	L_Pulse12
L_Pulse13:
;ADC_DAC.c,196 :: 		XFIR[0] = (float)(value);
	MOV	_value, W0
	CLR	W1
	CALL	__Long2Float
	MOV	W0, _XFIR
	MOV	W1, _XFIR+2
;ADC_DAC.c,198 :: 		y0 = 0.0; for( f=0; f<O; f++ ) y0 += h[f]*XFIR[f];
	CLR	W0
	CLR	W1
	MOV	W0, _y0
	MOV	W1, _y0+2
	CLR	W0
	MOV	W0, _f
L_Pulse15:
	MOV	_f, W0
	CP	W0, #21
	BRA LTU	L__Pulse165
	GOTO	L_Pulse16
L__Pulse165:
	MOV	_f, W0
	SL	W0, #2, W2
	MOV	#lo_addr(_h), W0
	ADD	W0, W2, W1
	MOV	#___Lib_System_DefaultPage, W0
	MOV	WREG, 52
	MOV	[W1++], W3
	MOV	[W1--], W4
	MOV	#lo_addr(_XFIR), W0
	ADD	W0, W2, W2
	MOV.D	[W2], W0
	MOV	W3, W2
	MOV	W4, W3
	CALL	__Mul_FP
	MOV	_y0, W2
	MOV	_y0+2, W3
	CALL	__AddSub_FP
	MOV	W0, _y0
	MOV	W1, _y0+2
	MOV	#1, W1
	MOV	#lo_addr(_f), W0
	ADD	W1, [W0], [W0]
	GOTO	L_Pulse15
L_Pulse16:
;ADC_DAC.c,200 :: 		YY = (unsigned int)(y0);                             //Reconstrucción de la señal: y en 10 bits.
	MOV	_y0, W0
	MOV	_y0+2, W1
	CALL	__Float2Longint
	MOV	W0, _YY
;ADC_DAC.c,201 :: 		M[k] = YY;
	MOV	_k, W1
	SL	W1, #1, W2
	MOV	#lo_addr(_M), W1
	ADD	W1, W2, W1
	MOV	W0, [W1]
;ADC_DAC.c,184 :: 		for (k=0;k<nm;k++){
	MOV	#1, W1
	MOV	#lo_addr(_k), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,203 :: 		}
	GOTO	L_Pulse8
L_Pulse9:
;ADC_DAC.c,205 :: 		bm = 2;                                                  //Cambia el estado de la bandera bm para dar paso al cálculo del pmax y TOF
	MOV	#lo_addr(_bm), W1
	MOV.B	#2, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,207 :: 		}
L_Pulse7:
;ADC_DAC.c,210 :: 		if (bm==2){
	MOV	#lo_addr(_bm), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA Z	L__Pulse166
	GOTO	L_Pulse18
L__Pulse166:
;ADC_DAC.c,212 :: 		yy1 = Vector_Max(M, nm, &maxIndex);                         //Encuentra el valor maximo del vector R
	MOV	#lo_addr(_maxIndex), W0
	PUSH	W0
	MOV	#350, W0
	PUSH	W0
	MOV	#lo_addr(_M), W0
	PUSH	W0
	CALL	_Vector_Max
	SUB	#6, W15
	MOV	W0, _yy1
;ADC_DAC.c,213 :: 		i1b = maxIndex;                                              //Asigna el subindice del valor maximo a la variable i1a
	MOV	_maxIndex, W0
	MOV	W0, _i1b
;ADC_DAC.c,214 :: 		i1a = 0;
	CLR	W0
	MOV	W0, _i1a
;ADC_DAC.c,216 :: 		while (M[i1a]<yy1){
L_Pulse19:
	MOV	_i1a, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W1
	MOV	#lo_addr(_yy1), W0
	CP	W1, [W0]
	BRA LTU	L__Pulse167
	GOTO	L_Pulse20
L__Pulse167:
;ADC_DAC.c,217 :: 		i1a++;
	MOV	#1, W1
	MOV	#lo_addr(_i1a), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,218 :: 		}
	GOTO	L_Pulse19
L_Pulse20:
;ADC_DAC.c,220 :: 		i1 = i1a+((i1b-i1a)/2);
	MOV	_i1b, W1
	MOV	#lo_addr(_i1a), W0
	SUB	W1, [W0], W0
	LSR	W0, #1, W1
	MOV	#lo_addr(_i1a), W0
	ADD	W1, [W0], W1
	MOV	W1, _i1
;ADC_DAC.c,221 :: 		i0 = i1 - dix;
	SUB	W1, #20, W0
	MOV	W0, _i0
;ADC_DAC.c,222 :: 		i2 = i1 + dix;
	ADD	W1, #20, W3
	MOV	W3, _i2
;ADC_DAC.c,224 :: 		yy0 = M[i0];
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W2
	MOV	W2, _yy0
;ADC_DAC.c,225 :: 		yy2 = M[i2];
	SL	W3, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W0
	MOV	[W0], W0
	MOV	W0, [W14+0]
	MOV	W0, _yy2
;ADC_DAC.c,227 :: 		yf0 = (float)(yy0);
	MOV	W2, W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+8]
	MOV	W1, [W14+10]
	MOV	W0, _yf0
	MOV	W1, _yf0+2
;ADC_DAC.c,228 :: 		yf1 = (float)(yy1);
	MOV	_yy1, W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+4]
	MOV	W1, [W14+6]
	MOV	W0, _yf1
	MOV	W1, _yf1+2
;ADC_DAC.c,229 :: 		yf2 = (float)(yy2);
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
;ADC_DAC.c,231 :: 		nx = (yf0-yf2)/(2.0*(yf0-(2.0*yf1)+yf2));                   //Factor de ajuste determinado por interpolacion parabolica
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
;ADC_DAC.c,232 :: 		dx = nx*dix*tx;
	MOV	#0, W2
	MOV	#16800, W3
	CALL	__Mul_FP
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Mul_FP
	MOV	W0, _dx
	MOV	W1, _dx+2
;ADC_DAC.c,233 :: 		tmax = i1*tx;
	MOV	_i1, W0
	CLR	W1
	CALL	__Long2Float
	MOV	#0, W2
	MOV	#16544, W3
	CALL	__Mul_FP
	MOV	W0, _tmax
	MOV	W1, _tmax+2
;ADC_DAC.c,235 :: 		T2 = tmax+dx;
	MOV	_dx, W2
	MOV	_dx+2, W3
	CALL	__AddSub_FP
	MOV	W0, _T2
	MOV	W1, _T2+2
;ADC_DAC.c,237 :: 		}
L_Pulse18:
;ADC_DAC.c,239 :: 		}
L_end_Pulse:
	ULNK
	RETURN
; end of _Pulse

_Moda:

;ADC_DAC.c,241 :: 		int Moda(int VRpt[nd]){
;ADC_DAC.c,243 :: 		ME1=0;
	CLR	W0
	MOV	W0, _ME1
;ADC_DAC.c,244 :: 		ME2=0;
	CLR	W0
	MOV	W0, _ME2
;ADC_DAC.c,245 :: 		ME3=0;
	CLR	W0
	MOV	W0, _ME3
;ADC_DAC.c,246 :: 		Mb2=0;
	MOV	#lo_addr(_Mb2), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,247 :: 		Mb3=0;
	MOV	#lo_addr(_Mb3), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,248 :: 		Mc1=0;
	MOV	#lo_addr(_Mc1), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,249 :: 		Mc2=0;
	MOV	#lo_addr(_Mc2), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,250 :: 		Mc3=0;
	MOV	#lo_addr(_Mc3), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,252 :: 		ME1=VRpt[0];
	MOV	[W10], W0
	MOV	W0, _ME1
;ADC_DAC.c,254 :: 		for (mi=0;mi<nd;mi++){
	MOV	#lo_addr(_mi), W1
	CLR	W0
	MOV.B	W0, [W1]
L_Moda21:
	MOV	#lo_addr(_mi), W0
	MOV.B	[W0], W0
	CP.B	W0, #10
	BRA LTU	L__Moda169
	GOTO	L_Moda22
L__Moda169:
;ADC_DAC.c,255 :: 		if (VRpt[mi]==ME1){
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W1
	MOV	#lo_addr(_ME1), W0
	CP	W1, [W0]
	BRA Z	L__Moda170
	GOTO	L_Moda24
L__Moda170:
;ADC_DAC.c,256 :: 		Mc1++;
	MOV.B	#1, W1
	MOV	#lo_addr(_Mc1), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,257 :: 		}else{
	GOTO	L_Moda25
L_Moda24:
;ADC_DAC.c,258 :: 		if (Mb2==0){
	MOV	#lo_addr(_Mb2), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__Moda171
	GOTO	L_Moda26
L__Moda171:
;ADC_DAC.c,259 :: 		ME2=VRpt[mi];
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W0
	MOV	W0, _ME2
;ADC_DAC.c,260 :: 		Mb2=1;
	MOV	#lo_addr(_Mb2), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,261 :: 		}
L_Moda26:
;ADC_DAC.c,262 :: 		if (VRpt[mi]==ME2){
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W1
	MOV	#lo_addr(_ME2), W0
	CP	W1, [W0]
	BRA Z	L__Moda172
	GOTO	L_Moda27
L__Moda172:
;ADC_DAC.c,263 :: 		Mc2++;
	MOV.B	#1, W1
	MOV	#lo_addr(_Mc2), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,264 :: 		}else{
	GOTO	L_Moda28
L_Moda27:
;ADC_DAC.c,265 :: 		if (Mb3==0){
	MOV	#lo_addr(_Mb3), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__Moda173
	GOTO	L_Moda29
L__Moda173:
;ADC_DAC.c,266 :: 		ME3=VRpt[mi];
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W0
	MOV	W0, _ME3
;ADC_DAC.c,267 :: 		Mb3=1;
	MOV	#lo_addr(_Mb3), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,268 :: 		}
L_Moda29:
;ADC_DAC.c,269 :: 		if (VRpt[mi]==ME3){
	MOV	#lo_addr(_mi), W0
	ZE	[W0], W0
	SL	W0, #1, W0
	ADD	W10, W0, W0
	MOV	[W0], W1
	MOV	#lo_addr(_ME3), W0
	CP	W1, [W0]
	BRA Z	L__Moda174
	GOTO	L_Moda30
L__Moda174:
;ADC_DAC.c,270 :: 		Mc3++;
	MOV.B	#1, W1
	MOV	#lo_addr(_Mc3), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,271 :: 		}
L_Moda30:
;ADC_DAC.c,272 :: 		}
L_Moda28:
;ADC_DAC.c,273 :: 		}
L_Moda25:
;ADC_DAC.c,254 :: 		for (mi=0;mi<nd;mi++){
	MOV.B	#1, W1
	MOV	#lo_addr(_mi), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,275 :: 		}
	GOTO	L_Moda21
L_Moda22:
;ADC_DAC.c,277 :: 		if ((Mc1>Mc2)&&(Mc1>Mc3)){
	MOV	#lo_addr(_Mc1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc2), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda175
	GOTO	L__Moda138
L__Moda175:
	MOV	#lo_addr(_Mc1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc3), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda176
	GOTO	L__Moda137
L__Moda176:
L__Moda136:
;ADC_DAC.c,278 :: 		return ME1;
	MOV	_ME1, W0
	GOTO	L_end_Moda
;ADC_DAC.c,277 :: 		if ((Mc1>Mc2)&&(Mc1>Mc3)){
L__Moda138:
L__Moda137:
;ADC_DAC.c,280 :: 		if ((Mc2>Mc1)&&(Mc2>Mc3)){
	MOV	#lo_addr(_Mc2), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc1), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda177
	GOTO	L__Moda140
L__Moda177:
	MOV	#lo_addr(_Mc2), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc3), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda178
	GOTO	L__Moda139
L__Moda178:
L__Moda135:
;ADC_DAC.c,281 :: 		return ME2;
	MOV	_ME2, W0
	GOTO	L_end_Moda
;ADC_DAC.c,280 :: 		if ((Mc2>Mc1)&&(Mc2>Mc3)){
L__Moda140:
L__Moda139:
;ADC_DAC.c,283 :: 		if ((Mc3>Mc1)&&(Mc3>Mc2)){
	MOV	#lo_addr(_Mc3), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc1), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda179
	GOTO	L__Moda142
L__Moda179:
	MOV	#lo_addr(_Mc3), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc2), W0
	CP.B	W1, [W0]
	BRA GTU	L__Moda180
	GOTO	L__Moda141
L__Moda180:
L__Moda134:
;ADC_DAC.c,284 :: 		return ME3;
	MOV	_ME3, W0
	GOTO	L_end_Moda
;ADC_DAC.c,283 :: 		if ((Mc3>Mc1)&&(Mc3>Mc2)){
L__Moda142:
L__Moda141:
;ADC_DAC.c,287 :: 		if (Mc1==Mc2){
	MOV	#lo_addr(_Mc1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc2), W0
	CP.B	W1, [W0]
	BRA Z	L__Moda181
	GOTO	L_Moda40
L__Moda181:
;ADC_DAC.c,288 :: 		return ME1;
	MOV	_ME1, W0
	GOTO	L_end_Moda
;ADC_DAC.c,289 :: 		}
L_Moda40:
;ADC_DAC.c,290 :: 		if (Mc1==Mc3){
	MOV	#lo_addr(_Mc1), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc3), W0
	CP.B	W1, [W0]
	BRA Z	L__Moda182
	GOTO	L_Moda41
L__Moda182:
;ADC_DAC.c,291 :: 		return ME1;
	MOV	_ME1, W0
	GOTO	L_end_Moda
;ADC_DAC.c,292 :: 		}
L_Moda41:
;ADC_DAC.c,293 :: 		if (Mc2==Mc3){
	MOV	#lo_addr(_Mc2), W0
	MOV.B	[W0], W1
	MOV	#lo_addr(_Mc3), W0
	CP.B	W1, [W0]
	BRA Z	L__Moda183
	GOTO	L_Moda42
L__Moda183:
;ADC_DAC.c,294 :: 		return ME2;
	MOV	_ME2, W0
	GOTO	L_end_Moda
;ADC_DAC.c,295 :: 		}
L_Moda42:
;ADC_DAC.c,298 :: 		}
L_end_Moda:
	RETURN
; end of _Moda

_Distancia:

;ADC_DAC.c,301 :: 		int Distancia(){
;ADC_DAC.c,303 :: 		conts = 0;                               //Limpia el contador de secuencias
	PUSH	W10
	PUSH	W11
	PUSH	W12
	MOV	#lo_addr(_conts), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,304 :: 		T2sum = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2sum
	MOV	W1, _T2sum+2
;ADC_DAC.c,305 :: 		T2prom = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2prom
	MOV	W1, _T2prom+2
;ADC_DAC.c,306 :: 		T2a = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2a
	MOV	W1, _T2a+2
;ADC_DAC.c,307 :: 		T2b = 0.0;
	CLR	W0
	CLR	W1
	MOV	W0, _T2b
	MOV	W1, _T2b+2
;ADC_DAC.c,309 :: 		while (conts<Nsm){
L_Distancia43:
	MOV	#lo_addr(_conts), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA LT	L__Distancia185
	GOTO	L_Distancia44
L__Distancia185:
;ADC_DAC.c,310 :: 		Pulse();                           //Inicia una secuencia de medicion
	CALL	_Pulse
;ADC_DAC.c,311 :: 		T2b = T2;
	MOV	_T2, W0
	MOV	_T2+2, W1
	MOV	W0, _T2b
	MOV	W1, _T2b+2
;ADC_DAC.c,312 :: 		if ((T2b-T2a)<=T2umb){             //Verifica si el T2 actual esta dentro de un umbral pre-establecido
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
	BRA GT	L__Distancia186
	INC.B	W0
L__Distancia186:
	CP0.B	W0
	BRA NZ	L__Distancia187
	GOTO	L_Distancia45
L__Distancia187:
;ADC_DAC.c,313 :: 		T2sum = T2sum + T2b;            //Acumula la sumatoria de valores de T2 calculados por la funcion Pulse()
	MOV	_T2sum, W2
	MOV	_T2sum+2, W3
	MOV	_T2b, W0
	MOV	_T2b+2, W1
	CALL	__AddSub_FP
	MOV	W0, _T2sum
	MOV	W1, _T2sum+2
;ADC_DAC.c,314 :: 		conts++;                        //Aumenta el contador de secuencias
	MOV.B	#1, W1
	MOV	#lo_addr(_conts), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,315 :: 		}
L_Distancia45:
;ADC_DAC.c,316 :: 		T2a = T2b;
	MOV	_T2b, W0
	MOV	_T2b+2, W1
	MOV	W0, _T2a
	MOV	W1, _T2a+2
;ADC_DAC.c,317 :: 		}
	GOTO	L_Distancia43
L_Distancia44:
;ADC_DAC.c,319 :: 		T2prom = T2sum/Nsm;
	MOV	#0, W2
	MOV	#16448, W3
	MOV	_T2sum, W0
	MOV	_T2sum+2, W1
	CALL	__Div_FP
	MOV	W0, _T2prom
	MOV	W1, _T2prom+2
;ADC_DAC.c,321 :: 		Velocidad();                             //Calcula la velocidad del sonido
	CALL	_Velocidad
;ADC_DAC.c,324 :: 		TOF = (T1+T2prom-T2adj)/1.0e6;           //Calcula el TOF en seg
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
;ADC_DAC.c,325 :: 		Dst = (VSnd*TOF/2.0) * 1000.0;           //Calcula la distancia en mm
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
;ADC_DAC.c,326 :: 		doub = modf(Dst, &iptr);
	MOV	#lo_addr(_iptr), W12
	MOV.D	W0, W10
	CALL	_modf
	MOV	W0, _doub
	MOV	W1, _doub+2
;ADC_DAC.c,327 :: 		if (doub>=0.5){
	MOV	#0, W2
	MOV	#16128, W3
	CALL	__Compare_Ge_Fp
	CP0	W0
	CLR.B	W0
	BRA LT	L__Distancia188
	INC.B	W0
L__Distancia188:
	CP0.B	W0
	BRA NZ	L__Distancia189
	GOTO	L_Distancia46
L__Distancia189:
;ADC_DAC.c,328 :: 		Dst=ceil(Dst);
	MOV	_Dst, W10
	MOV	_Dst+2, W11
	CALL	_ceil
	MOV	W0, _Dst
	MOV	W1, _Dst+2
;ADC_DAC.c,329 :: 		}else{
	GOTO	L_Distancia47
L_Distancia46:
;ADC_DAC.c,330 :: 		Dst=floor(Dst);
	MOV	_Dst, W10
	MOV	_Dst+2, W11
	CALL	_floor
	MOV	W0, _Dst
	MOV	W1, _Dst+2
;ADC_DAC.c,331 :: 		}
L_Distancia47:
;ADC_DAC.c,333 :: 		return Dst;
	MOV	_Dst, W0
	MOV	_Dst+2, W1
	CALL	__Float2Longint
;ADC_DAC.c,335 :: 		}
;ADC_DAC.c,333 :: 		return Dst;
;ADC_DAC.c,335 :: 		}
L_end_Distancia:
	POP	W12
	POP	W11
	POP	W10
	RETURN
; end of _Distancia

_Calcular:
	LNK	#4

;ADC_DAC.c,337 :: 		void Calcular(){
;ADC_DAC.c,339 :: 		if (Ptcn[4]==0x04){
	PUSH	W10
	PUSH	W11
	PUSH	W12
	PUSH	W13
	MOV	#lo_addr(_Ptcn+4), W0
	MOV.B	[W0], W0
	CP.B	W0, #4
	BRA Z	L__Calcular191
	GOTO	L_Calcular48
L__Calcular191:
;ADC_DAC.c,341 :: 		Velocidad();
	CALL	_Velocidad
;ADC_DAC.c,342 :: 		Temperatura = (unsigned int)(DSTemp);    //Tranforma el dato de Temperatura de float a entero sin signo
	MOV	_DSTemp, W0
	MOV	_DSTemp+2, W1
	CALL	__Float2Longint
	MOV	W0, _Temperatura
;ADC_DAC.c,343 :: 		chTemp = (unsigned char *) & Temperatura;//Asocia el valor calculado de Temperatura al puntero chTemp
	MOV	#lo_addr(_Temperatura), W0
	MOV	W0, _chTemp
;ADC_DAC.c,345 :: 		} else {
	GOTO	L_Calcular49
L_Calcular48:
;ADC_DAC.c,347 :: 		for (vi=0;vi<nd;vi++){
	MOV	#lo_addr(_vi), W1
	CLR	W0
	MOV.B	W0, [W1]
L_Calcular50:
	MOV	#lo_addr(_vi), W0
	MOV.B	[W0], W0
	CP.B	W0, #10
	BRA LTU	L__Calcular192
	GOTO	L_Calcular51
L__Calcular192:
;ADC_DAC.c,348 :: 		Vdistancia[vi] = Distancia();        //Toma 10 lecturas de la distancia calculada y las almacena en un vector
	MOV	#lo_addr(_vi), W0
	ZE	[W0], W0
	SL	W0, #1, W1
	MOV	#lo_addr(_Vdistancia), W0
	ADD	W0, W1, W0
	MOV	W0, [W14+0]
	CALL	_Distancia
	MOV	[W14+0], W1
	MOV	W0, [W1]
;ADC_DAC.c,347 :: 		for (vi=0;vi<nd;vi++){
	MOV.B	#1, W1
	MOV	#lo_addr(_vi), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,349 :: 		}
	GOTO	L_Calcular50
L_Calcular51:
;ADC_DAC.c,351 :: 		Cdistancia = Moda(Vdistancia);           //Calcula la Moda del vector de distancias
	MOV	#lo_addr(_Vdistancia), W10
	CALL	_Moda
	MOV	W0, _Cdistancia
;ADC_DAC.c,354 :: 		if ((Cdistancia>=268)&&(Cdistancia<=283)){
	MOV	#268, W1
	CP	W0, W1
	BRA GEU	L__Calcular193
	GOTO	L__Calcular145
L__Calcular193:
	MOV	_Cdistancia, W1
	MOV	#283, W0
	CP	W1, W0
	BRA LEU	L__Calcular194
	GOTO	L__Calcular144
L__Calcular194:
L__Calcular143:
;ADC_DAC.c,355 :: 		Cdistancia = Cdistancia - 3;
	MOV	#3, W1
	MOV	#lo_addr(_Cdistancia), W0
	SUBR	W1, [W0], [W0]
;ADC_DAC.c,356 :: 		} else {
	GOTO	L_Calcular56
;ADC_DAC.c,354 :: 		if ((Cdistancia>=268)&&(Cdistancia<=283)){
L__Calcular145:
L__Calcular144:
;ADC_DAC.c,357 :: 		Cdistancia = Cdistancia + 1;
	MOV	#1, W1
	MOV	#lo_addr(_Cdistancia), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,358 :: 		}
L_Calcular56:
;ADC_DAC.c,360 :: 		Cdistancia = Cdistancia + (float)(Kadj); //Ajusta el valor de la Distancia calculada segun el factor de calibracion Kadj
	MOV	_Kadj, W0
	ASR	W0, #15, W1
	SETM	W2
	CALL	__Long2Float
	MOV	W0, [W14+0]
	MOV	W1, [W14+2]
	MOV	_Cdistancia, W0
	CLR	W1
	CALL	__Long2Float
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	CALL	__Float2Longint
	MOV	W0, _Cdistancia
;ADC_DAC.c,361 :: 		Nivel = Altura - Cdistancia;             //Calcula el Nivel en mm
	MOV	#lo_addr(_Altura), W1
	SUBR	W0, [W1], W0
	MOV	W0, _Nivel
;ADC_DAC.c,362 :: 		FNivel = Nivel/1000.0;                   //Calcula el Nivel de liquido en metros
	CLR	W1
	CALL	__Long2Float
	MOV	#0, W2
	MOV	#17530, W3
	CALL	__Div_FP
	MOV	W0, _FNivel
	MOV	W1, _FNivel+2
;ADC_DAC.c,363 :: 		FCaudal = 4960440*pow(FNivel,2.5);       //Calcula el Caudal en litros/hora
	MOV	#0, W12
	MOV	#16416, W13
	MOV.D	W0, W10
	CALL	_pow
	MOV	#24944, W2
	MOV	#19095, W3
	CALL	__Mul_FP
	MOV	W0, _FCaudal
	MOV	W1, _FCaudal+2
;ADC_DAC.c,365 :: 		IDst = (unsigned int)(Cdistancia);       //Tranforma el dato de distancia de float a entero sin signo
	MOV	_Cdistancia, W2
	MOV	W2, _IDst
;ADC_DAC.c,366 :: 		Caudal = (unsigned int)(FCaudal);        //Tranforma el dato de Caudal de float a entero sin signo
	CALL	__Float2Longint
	MOV	W0, _Caudal
;ADC_DAC.c,367 :: 		ITOF = (unsigned int)(TOF*1.0e6);        //Tranforma el dato de TOF en us de float a entero sin signo
	MOV	_TOF, W0
	MOV	_TOF+2, W1
	MOV	#9216, W2
	MOV	#18804, W3
	CALL	__Mul_FP
	CALL	__Float2Longint
	MOV	W0, _ITOF
;ADC_DAC.c,369 :: 		chIDst = (unsigned char *) & IDst;       //Asocia el valor calculado de IDst al puntero chDst
	MOV	#lo_addr(_IDst), W0
	MOV	W0, _chIDst
;ADC_DAC.c,370 :: 		chNivel = (unsigned char *) & Nivel;     //Asocia el valor calculado de Nivel al puntero chNivel
	MOV	#lo_addr(_Nivel), W0
	MOV	W0, _chNivel
;ADC_DAC.c,371 :: 		chCaudal = (unsigned char *) & Caudal;   //Asocia el valor calculado de Caudal al puntero chCaudal
	MOV	#lo_addr(_Caudal), W0
	MOV	W0, _chCaudal
;ADC_DAC.c,372 :: 		chTOF = (unsigned char *) & ITOF;        //Asocia el valor calculado de TOF al puntero chTOF
	MOV	#lo_addr(_ITOF), W0
	MOV	W0, _chTOF
;ADC_DAC.c,373 :: 		chAltura = (unsigned char *) & Altura;   //Asocia el valor de la variable Altura al puntero chAltura
	MOV	#lo_addr(_Altura), W0
	MOV	W0, _chAltura
;ADC_DAC.c,375 :: 		}
L_Calcular49:
;ADC_DAC.c,376 :: 		}
L_end_Calcular:
	POP	W13
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _Calcular

_Responder:

;ADC_DAC.c,379 :: 		void Responder(unsigned int Reg){
;ADC_DAC.c,381 :: 		switch(Reg){
	GOTO	L_Responder57
;ADC_DAC.c,382 :: 		case 1:    //Respuesta de Nivel
L_Responder59:
;ADC_DAC.c,383 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder60:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder196
	GOTO	L_Responder61
L__Responder196:
;ADC_DAC.c,384 :: 		Rspt[ir]=(*chNivel++);             //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del Nivel calculado
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chNivel, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chNivel), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,383 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,385 :: 		}
	GOTO	L_Responder60
L_Responder61:
;ADC_DAC.c,386 :: 		Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOV	#lo_addr(_Rspt+2), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,387 :: 		break;
	GOTO	L_Responder58
;ADC_DAC.c,389 :: 		case 2:    //Respuesta de Distancia
L_Responder63:
;ADC_DAC.c,390 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder64:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder197
	GOTO	L_Responder65
L__Responder197:
;ADC_DAC.c,391 :: 		Rspt[ir]=(*chIDst++);              //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del Distancia calculada
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chIDst, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chIDst), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,390 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,392 :: 		}
	GOTO	L_Responder64
L_Responder65:
;ADC_DAC.c,393 :: 		Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOV	#lo_addr(_Rspt+2), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,394 :: 		break;
	GOTO	L_Responder58
;ADC_DAC.c,396 :: 		case 3:    //Respuesta de TOF
L_Responder67:
;ADC_DAC.c,397 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder68:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder198
	GOTO	L_Responder69
L__Responder198:
;ADC_DAC.c,398 :: 		Rspt[ir]=(*chTOF++);               //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del TOF calculado
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chTOF, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chTOF), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,397 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,399 :: 		}
	GOTO	L_Responder68
L_Responder69:
;ADC_DAC.c,400 :: 		Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOV	#lo_addr(_Rspt+2), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,401 :: 		break;
	GOTO	L_Responder58
;ADC_DAC.c,403 :: 		case 4:    //Respuesta de Temperatura
L_Responder71:
;ADC_DAC.c,404 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder72:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder199
	GOTO	L_Responder73
L__Responder199:
;ADC_DAC.c,405 :: 		Rspt[ir]=(*chTemp++);              //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Temperatura calculada
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chTemp, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chTemp), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,404 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,406 :: 		}
	GOTO	L_Responder72
L_Responder73:
;ADC_DAC.c,407 :: 		break;
	GOTO	L_Responder58
;ADC_DAC.c,409 :: 		case 5:    //Respuesta de Caudal
L_Responder75:
;ADC_DAC.c,410 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder76:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder200
	GOTO	L_Responder77
L__Responder200:
;ADC_DAC.c,411 :: 		Rspt[ir]=(*chCaudal++);            //Rellena los bytes 3 y 4 de la trama de respuesta con el dato del Caudal calculado
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chCaudal, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chCaudal), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,410 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,412 :: 		}
	GOTO	L_Responder76
L_Responder77:
;ADC_DAC.c,413 :: 		Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOV	#lo_addr(_Rspt+2), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,414 :: 		break;
	GOTO	L_Responder58
;ADC_DAC.c,416 :: 		case 6:    //Respuesta de Altura de instalacion
L_Responder79:
;ADC_DAC.c,417 :: 		for (ir=4;ir>=3;ir--){
	MOV	#lo_addr(_ir), W1
	MOV.B	#4, W0
	MOV.B	W0, [W1]
L_Responder80:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA GEU	L__Responder201
	GOTO	L_Responder81
L__Responder201:
;ADC_DAC.c,418 :: 		Rspt[ir]=(*chAltura++);            //Rellena los bytes 3 y 4 de la trama de respuesta con el dato de la Altura de instalacion
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	MOV	_chAltura, W0
	MOV.B	[W0], [W1]
	MOV	#1, W1
	MOV	#lo_addr(_chAltura), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,417 :: 		for (ir=4;ir>=3;ir--){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	SUBR.B	W1, [W0], [W0]
;ADC_DAC.c,419 :: 		}
	GOTO	L_Responder80
L_Responder81:
;ADC_DAC.c,420 :: 		Rspt[2]=Ptcn[2];                       //Rellena el byte 2 con el tipo de funcion de la trama de peticion
	MOV	#lo_addr(_Rspt+2), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,421 :: 		break;
	GOTO	L_Responder58
;ADC_DAC.c,423 :: 		default:   Rspt[3]=0x00;                          //Rellena el campo de datos con el mensaje de error 0x00E2: Registro no disponible
L_Responder83:
	MOV	#lo_addr(_Rspt+3), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,424 :: 		Rspt[4]=0xE2;
	MOV	#lo_addr(_Rspt+4), W1
	MOV.B	#226, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,425 :: 		Rspt[2]=0xEE;                          //Rellena el byre 2 con el aviso de error 0xEE
	MOV	#lo_addr(_Rspt+2), W1
	MOV.B	#238, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,426 :: 		break;
	GOTO	L_Responder58
;ADC_DAC.c,427 :: 		}
L_Responder57:
	CP	W10, #1
	BRA NZ	L__Responder202
	GOTO	L_Responder59
L__Responder202:
	CP	W10, #2
	BRA NZ	L__Responder203
	GOTO	L_Responder63
L__Responder203:
	CP	W10, #3
	BRA NZ	L__Responder204
	GOTO	L_Responder67
L__Responder204:
	CP	W10, #4
	BRA NZ	L__Responder205
	GOTO	L_Responder71
L__Responder205:
	CP	W10, #5
	BRA NZ	L__Responder206
	GOTO	L_Responder75
L__Responder206:
	CP	W10, #6
	BRA NZ	L__Responder207
	GOTO	L_Responder79
L__Responder207:
	GOTO	L_Responder83
L_Responder58:
;ADC_DAC.c,429 :: 		RB5_bit = 1;                             //Establece el Max485 en modo de escritura
	BSET	RB5_bit, BitPos(RB5_bit+0)
;ADC_DAC.c,430 :: 		for (ir=0;ir<Rsize;ir++){
	MOV	#lo_addr(_ir), W1
	CLR	W0
	MOV.B	W0, [W1]
L_Responder84:
	MOV	#lo_addr(_ir), W0
	MOV.B	[W0], W0
	CP.B	W0, #6
	BRA LTU	L__Responder208
	GOTO	L_Responder85
L__Responder208:
;ADC_DAC.c,431 :: 		UART1_Write(Rspt[ir]);               //Envia la trama de respuesta
	MOV	#lo_addr(_ir), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W0
	PUSH	W10
	ZE	[W0], W10
	CALL	_UART1_Write
	POP	W10
;ADC_DAC.c,430 :: 		for (ir=0;ir<Rsize;ir++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ir), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,432 :: 		}
	GOTO	L_Responder84
L_Responder85:
;ADC_DAC.c,433 :: 		while(UART1_Tx_Idle()==0);               //Espera hasta que se haya terminado de enviar todo el dato por UART antes de continuar
L_Responder87:
	CALL	_UART1_Tx_Idle
	CP	W0, #0
	BRA Z	L__Responder209
	GOTO	L_Responder88
L__Responder209:
	GOTO	L_Responder87
L_Responder88:
;ADC_DAC.c,434 :: 		RB5_bit = 0;                             //Establece el Max485 en modo de lectura;
	BCLR	RB5_bit, BitPos(RB5_bit+0)
;ADC_DAC.c,436 :: 		for (ipp=3;ipp<5;ipp++){
	MOV	#lo_addr(_ipp), W1
	MOV.B	#3, W0
	MOV.B	W0, [W1]
L_Responder89:
	MOV	#lo_addr(_ipp), W0
	MOV.B	[W0], W0
	CP.B	W0, #5
	BRA LTU	L__Responder210
	GOTO	L_Responder90
L__Responder210:
;ADC_DAC.c,437 :: 		Rspt[ipp]=0;;                        //Limpia la trama de respuesta
	MOV	#lo_addr(_ipp), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Rspt), W0
	ADD	W0, W1, W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,436 :: 		for (ipp=3;ipp<5;ipp++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ipp), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,438 :: 		}
	GOTO	L_Responder89
L_Responder90:
;ADC_DAC.c,440 :: 		}
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

;ADC_DAC.c,444 :: 		void UART1Interrupt() iv IVT_ADDR_U1RXINTERRUPT {
;ADC_DAC.c,446 :: 		if (UART1_Data_Ready()==1){
	CALL	_UART1_Data_Ready
	CP	W0, #1
	BRA Z	L__UART1Interrupt212
	GOTO	L_UART1Interrupt92
L__UART1Interrupt212:
;ADC_DAC.c,447 :: 		Dato = UART1_Read();
	CALL	_UART1_Read
	MOV	#lo_addr(_Dato), W1
	MOV.B	W0, [W1]
;ADC_DAC.c,448 :: 		}
L_UART1Interrupt92:
;ADC_DAC.c,449 :: 		if ((Dato==Hdr)&&(ip==0)){                    //Verifica que el primer dato en llegar sea el identificador de inicio de trama
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], W1
	MOV.B	#58, W0
	CP.B	W1, W0
	BRA Z	L__UART1Interrupt213
	GOTO	L__UART1Interrupt150
L__UART1Interrupt213:
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__UART1Interrupt214
	GOTO	L__UART1Interrupt149
L__UART1Interrupt214:
L__UART1Interrupt148:
;ADC_DAC.c,450 :: 		BanT = 1;                                 //Activa la bandera de trama
	MOV	#lo_addr(_BanT), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,451 :: 		Ptcn[ip] = Dato;                          //Almacena el Dato en la trama de peticion
	MOV	#lo_addr(_ip), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,449 :: 		if ((Dato==Hdr)&&(ip==0)){                    //Verifica que el primer dato en llegar sea el identificador de inicio de trama
L__UART1Interrupt150:
L__UART1Interrupt149:
;ADC_DAC.c,453 :: 		if ((Dato!=Hdr)&&(ip==0)){                    //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], W1
	MOV.B	#58, W0
	CP.B	W1, W0
	BRA NZ	L__UART1Interrupt215
	GOTO	L__UART1Interrupt152
L__UART1Interrupt215:
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA Z	L__UART1Interrupt216
	GOTO	L__UART1Interrupt151
L__UART1Interrupt216:
L__UART1Interrupt147:
;ADC_DAC.c,454 :: 		ip=-1;                                    //Si es asi: reduce el subindice en una unidad
	MOV	#lo_addr(_ip), W1
	MOV.B	#255, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,453 :: 		if ((Dato!=Hdr)&&(ip==0)){                    //Verifica si el primer dato en llegar es diferente al identificador del inicio de trama
L__UART1Interrupt152:
L__UART1Interrupt151:
;ADC_DAC.c,456 :: 		if ((BanT==1)&&(ip!=0)){
	MOV	#lo_addr(_BanT), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__UART1Interrupt217
	GOTO	L__UART1Interrupt154
L__UART1Interrupt217:
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #0
	BRA NZ	L__UART1Interrupt218
	GOTO	L__UART1Interrupt153
L__UART1Interrupt218:
L__UART1Interrupt146:
;ADC_DAC.c,457 :: 		Ptcn[ip] = Dato;                          //Almacena el resto de datos en la trama de peticion si la bandera de trama esta activada
	MOV	#lo_addr(_ip), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	MOV	#lo_addr(_Dato), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,456 :: 		if ((BanT==1)&&(ip!=0)){
L__UART1Interrupt154:
L__UART1Interrupt153:
;ADC_DAC.c,460 :: 		ip++;                                         //Aumenta el subindice una unidad
	MOV.B	#1, W1
	MOV	#lo_addr(_ip), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,461 :: 		if (ip==Psize){                               //Verifica que se haya terminado de llenar la trama de datos
	MOV	#lo_addr(_ip), W0
	MOV.B	[W0], W0
	CP.B	W0, #6
	BRA Z	L__UART1Interrupt219
	GOTO	L_UART1Interrupt102
L__UART1Interrupt219:
;ADC_DAC.c,462 :: 		BanP = 1;                                 //Habilita la bandera de lectura de datos
	MOV	#lo_addr(_BanP), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,463 :: 		BanT = 0;
	MOV	#lo_addr(_BanT), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,464 :: 		ip=0;                                     //Limpia el subindice de la trama de peticion para permitir una nueva secuencia de recepcion de datos
	MOV	#lo_addr(_ip), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,465 :: 		}
L_UART1Interrupt102:
;ADC_DAC.c,467 :: 		U1RXIF_bit = 0;                               //Limpia la bandera de interrupcion de UARTRX
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;ADC_DAC.c,469 :: 		}
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

;ADC_DAC.c,472 :: 		void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
;ADC_DAC.c,474 :: 		SAMP_bit = 0;                                 //Limpia el bit SAMP para iniciar la conversion del ADC
	BCLR	SAMP_bit, BitPos(SAMP_bit+0)
;ADC_DAC.c,475 :: 		while (!AD1CON1bits.DONE);                    //Espera hasta que se complete la conversion
L_Timer1Interrupt103:
	BTSC	AD1CON1bits, #0
	GOTO	L_Timer1Interrupt104
	GOTO	L_Timer1Interrupt103
L_Timer1Interrupt104:
;ADC_DAC.c,476 :: 		if (i<nm){
	MOV	_i, W1
	MOV	#350, W0
	CP	W1, W0
	BRA LTU	L__Timer1Interrupt221
	GOTO	L_Timer1Interrupt105
L__Timer1Interrupt221:
;ADC_DAC.c,477 :: 		M[i] = ADC1BUF0;                           //Almacena el valor actual de la conversion del ADC en el vector M
	MOV	_i, W0
	SL	W0, #1, W1
	MOV	#lo_addr(_M), W0
	ADD	W0, W1, W1
	MOV	ADC1BUF0, WREG
	MOV	W0, [W1]
;ADC_DAC.c,478 :: 		i++;                                       //Aumenta en 1 el subindice del vector de Muestras
	MOV	#1, W1
	MOV	#lo_addr(_i), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,479 :: 		} else {
	GOTO	L_Timer1Interrupt106
L_Timer1Interrupt105:
;ADC_DAC.c,480 :: 		bm = 1;                                    //Cambia el valor de la bandera bm para terminar con el muestreo y dar comienzo al procesamiento de la señal
	MOV	#lo_addr(_bm), W1
	MOV.B	#1, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,481 :: 		T1CON.TON = 0;                             //Apaga el TMR1
	BCLR	T1CON, #15
;ADC_DAC.c,482 :: 		IEC0.T1IE = 0;                             //Desabilita la interrupcion por desborde del TMR1
	BCLR	IEC0, #3
;ADC_DAC.c,483 :: 		}
L_Timer1Interrupt106:
;ADC_DAC.c,484 :: 		T1IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,485 :: 		}
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

;ADC_DAC.c,488 :: 		void Timer2Interrupt() iv IVT_ADDR_T2INTERRUPT{
;ADC_DAC.c,489 :: 		if (contp<10){                                //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (
	MOV	_contp, W0
	CP	W0, #10
	BRA LTU	L__Timer2Interrupt223
	GOTO	L_Timer2Interrupt107
L__Timer2Interrupt223:
;ADC_DAC.c,490 :: 		RB2_bit = ~RB2_bit;                      //Conmuta el valor del pin RB14
	BTG	RB2_bit, BitPos(RB2_bit+0)
;ADC_DAC.c,491 :: 		}else {
	GOTO	L_Timer2Interrupt108
L_Timer2Interrupt107:
;ADC_DAC.c,492 :: 		RB2_bit = 0;                            //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCLR	RB2_bit, BitPos(RB2_bit+0)
;ADC_DAC.c,494 :: 		if (contp==110){
	MOV	#110, W1
	MOV	#lo_addr(_contp), W0
	CP	W1, [W0]
	BRA Z	L__Timer2Interrupt224
	GOTO	L_Timer2Interrupt109
L__Timer2Interrupt224:
;ADC_DAC.c,495 :: 		IEC0.T2IE = 0;                       //Desabilita la interrupcion por desborde del TMR2 para no interferir con las interrupciones por desborde de TMR1
	BCLR	IEC0, #7
;ADC_DAC.c,496 :: 		T2CON.TON = 0;                       //Apaga el TMR2
	BCLR	T2CON, #15
;ADC_DAC.c,497 :: 		IEC0.T1IE = 1;                       //Habilita la interrupcion por desborde del TMR1 para dar inicio al muestreo del ADC
	BSET	IEC0, #3
;ADC_DAC.c,498 :: 		TMR1 = 0;                            //Encera el TMR1
	CLR	TMR1
;ADC_DAC.c,499 :: 		T1IF_bit = 0;                        //Limpia la bandera de interrupcion por desbordamiento del TMR1
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,500 :: 		T1CON.TON = 1;                       //Enciende el TMR1
	BSET	T1CON, #15
;ADC_DAC.c,501 :: 		bm=0;
	MOV	#lo_addr(_bm), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,502 :: 		}
L_Timer2Interrupt109:
;ADC_DAC.c,504 :: 		}
L_Timer2Interrupt108:
;ADC_DAC.c,505 :: 		contp++;                                      //Aumenta el contador en una unidad.
	MOV	#1, W1
	MOV	#lo_addr(_contp), W0
	ADD	W1, [W0], [W0]
;ADC_DAC.c,506 :: 		T2IF_bit = 0;                                 //Limpia la bandera de interrupcion por desbordamiento del TMR2
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,507 :: 		}
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

;ADC_DAC.c,511 :: 		void Configuracion(){
;ADC_DAC.c,514 :: 		CLKDIVbits.PLLPRE = 0;                      //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,515 :: 		PLLFBD = 38;                                //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
	MOV	#38, W0
	MOV	WREG, PLLFBD
;ADC_DAC.c,516 :: 		CLKDIVbits.PLLPOST = 0;                     //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,519 :: 		AD1PCFGL = 0xFFFD;                          //Configura el puerto AN1 como entrada analogica y todas las demas como digitales
	MOV	#65533, W0
	MOV	WREG, AD1PCFGL
;ADC_DAC.c,520 :: 		TRISA1_bit = 1;                             //Establece el pin RA1 como entrada
	BSET	TRISA1_bit, BitPos(TRISA1_bit+0)
;ADC_DAC.c,521 :: 		TRISB = 0xFF40;                             //TRISB = 11111111 01000000
	MOV	#65344, W0
	MOV	WREG, TRISB
;ADC_DAC.c,524 :: 		AD1CON1.AD12B = 0;                          //Configura el ADC en modo de 10 bits
	BCLR	AD1CON1, #10
;ADC_DAC.c,525 :: 		AD1CON1bits.FORM = 0x00;                    //Formato de la canversion: 00->(0_1023)|01->(-512_511)|02->(0_0.999)|03->(-1_0.999)
	MOV	AD1CON1bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON1bits
;ADC_DAC.c,526 :: 		AD1CON1.SIMSAM = 0;                         //0 -> Muestrea múltiples canales individualmente en secuencia
	BCLR	AD1CON1, #3
;ADC_DAC.c,527 :: 		AD1CON1.ADSIDL = 0;                         //Continua con la operacion del modulo durante el modo desocupado
	BCLR	AD1CON1, #13
;ADC_DAC.c,528 :: 		AD1CON1.ASAM = 1;                           //Muestreo automatico
	BSET	AD1CON1, #2
;ADC_DAC.c,529 :: 		AD1CON1bits.SSRC = 0x00;                    //Conversion manual
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	[W0], W1
	MOV.B	#31, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(AD1CON1bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,531 :: 		AD1CON2bits.VCFG = 0;                       //Selecciona AVDD y AVSS como fuentes de voltaje de referencia
	MOV	AD1CON2bits, W1
	MOV	#8191, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,532 :: 		AD1CON2bits.CHPS = 0;                       //Selecciona unicamente el canal CH0
	MOV	AD1CON2bits, W1
	MOV	#64767, W0
	AND	W1, W0, W0
	MOV	WREG, AD1CON2bits
;ADC_DAC.c,533 :: 		AD1CON2.CSCNA = 0;                          //No escanea las entradas de CH0 durante la Muestra A
	BCLR	AD1CON2, #10
;ADC_DAC.c,534 :: 		AD1CON2.BUFM = 0;                           //Bit de selección del modo de relleno del búfer, 0 -> Siempre comienza a llenar el buffer desde el principio
	BCLR	AD1CON2, #1
;ADC_DAC.c,535 :: 		AD1CON2.ALTS = 0x00;                        //Utiliza siempre la selección de entrada de canal para la muestra A
	BCLR	AD1CON2, #0
;ADC_DAC.c,537 :: 		AD1CON3.ADRC = 0;                           //Selecciona el reloj de conversion del ADC derivado del reloj del sistema
	BCLR	AD1CON3, #15
;ADC_DAC.c,538 :: 		AD1CON3bits.ADCS = 0x02;                    //Configura el periodo del reloj del ADC fijando el valor de los bits ADCS segun la formula: TAD = TCY*(ADCS+1) = 75ns  -> ADCS = 2
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
;ADC_DAC.c,539 :: 		AD1CON3bits.SAMC = 0x02;                    //Auto Sample Time bits, 2 -> 2*TAD (minimo periodo de muestreo para 10 bits)
	MOV	#512, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CON3bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CON3bits
;ADC_DAC.c,541 :: 		AD1CHS0.CH0NB = 0;                          //Channel 0 negative input is VREF-
	BCLR	AD1CHS0, #15
;ADC_DAC.c,542 :: 		AD1CHS0bits.CH0SB = 0x01;                   //Channel 0 positive input is AN1
	MOV	#256, W0
	MOV	W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, AD1CHS0bits
;ADC_DAC.c,543 :: 		AD1CHS0.CH0NA = 0;                          //Channel 0 negative input is VREF-
	BCLR	AD1CHS0, #7
;ADC_DAC.c,544 :: 		AD1CHS0bits.CH0SA = 0x01;                   //Channel 0 positive input is AN1
	MOV.B	#1, W0
	MOV.B	W0, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(AD1CHS0bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(AD1CHS0bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,546 :: 		AD1CHS123 = 0;                              //AD1CHS123: ADC1 INPUT CHANNEL 1, 2, 3 SELECT REGISTER
	CLR	AD1CHS123
;ADC_DAC.c,548 :: 		AD1CSSL = 0x00;                             //Se salta todos los puertos ANx para los escaneos de entrada
	CLR	AD1CSSL
;ADC_DAC.c,550 :: 		AD1CON1.ADON = 1;                           //Enciende el modulo ADC
	BSET	AD1CON1, #15
;ADC_DAC.c,553 :: 		T1CON = 0x8000;                             //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T1CON
;ADC_DAC.c,554 :: 		IEC0.T1IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR1 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #3
;ADC_DAC.c,555 :: 		T1IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;ADC_DAC.c,556 :: 		PR1 = 200;                                  //Genera una interrupcion cada 5us (Fs=200KHz)
	MOV	#200, W0
	MOV	WREG, PR1
;ADC_DAC.c,559 :: 		T2CON = 0x8000;                             //Habilita el TMR2, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T2CON
;ADC_DAC.c,560 :: 		IEC0.T2IE = 0;                              //Inicializa el programa con la interrupcion por desborde de TMR2 desabilitada para no interferir con la lectura del sensor de temperatura
	BCLR	IEC0, #7
;ADC_DAC.c,561 :: 		T2IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T2IF_bit, BitPos(T2IF_bit+0)
;ADC_DAC.c,562 :: 		PR2 = 500;                                  //Genera una interrupcion cada 12.5us
	MOV	#500, W0
	MOV	WREG, PR2
;ADC_DAC.c,565 :: 		RPINR18bits.U1RXR = 0x06;                   //Asisgna Rx a RP6
	MOV.B	#6, W0
	MOV.B	W0, W1
	MOV	#lo_addr(RPINR18bits), W0
	XOR.B	W1, [W0], W1
	AND.B	W1, #31, W1
	MOV	#lo_addr(RPINR18bits), W0
	XOR.B	W1, [W0], W1
	MOV	#lo_addr(RPINR18bits), W0
	MOV.B	W1, [W0]
;ADC_DAC.c,566 :: 		RPOR3bits.RP7R = 0x03;                      //Asigna Tx a RP7
	MOV	#768, W0
	MOV	W0, W1
	MOV	#lo_addr(RPOR3bits), W0
	XOR	W1, [W0], W1
	MOV	#7936, W0
	AND	W1, W0, W1
	MOV	#lo_addr(RPOR3bits), W0
	XOR	W1, [W0], W1
	MOV	W1, RPOR3bits
;ADC_DAC.c,567 :: 		IEC0.U1RXIE = 1;                            //Habilita la interrupcion por recepcion de dato por UART
	BSET	IEC0, #11
;ADC_DAC.c,568 :: 		U1RXIF_bit = 0;                             //Limpia la bandera de interrupcion de UARTRX
	BCLR	U1RXIF_bit, BitPos(U1RXIF_bit+0)
;ADC_DAC.c,571 :: 		IPC0bits.T1IP = 0x06;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR1
	MOV	#24576, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC0bits
;ADC_DAC.c,572 :: 		IPC1bits.T2IP = 0x05;                       //Nivel de prioridad de la interrupcion por desbordamiento del TMR2
	MOV	#20480, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC1bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC1bits
;ADC_DAC.c,573 :: 		IPC2bits.U1RXIP = 0x07;                     //Nivel de prioridad de la interrupcion UARTRX
	MOV	IPC2bits, W1
	MOV	#28672, W0
	IOR	W1, W0, W0
	MOV	WREG, IPC2bits
;ADC_DAC.c,577 :: 		}
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

;ADC_DAC.c,581 :: 		void main() {
;ADC_DAC.c,583 :: 		Configuracion();
	PUSH	W10
	PUSH	W11
	CALL	_Configuracion
;ADC_DAC.c,585 :: 		UART1_Init(9600);                                        //Inicializa el modulo UART a 9600 bps
	MOV	#9600, W10
	MOV	#0, W11
	CALL	_UART1_Init
;ADC_DAC.c,586 :: 		Delay_ms(100);                                           //Espera hata que el modulo UART se estabilice
	MOV	#21, W8
	MOV	#22619, W7
L_main110:
	DEC	W7
	BRA NZ	L_main110
	DEC	W8
	BRA NZ	L_main110
;ADC_DAC.c,587 :: 		RB5_bit = 0;                                             //Establece el Max485 en modo de lectura
	BCLR	RB5_bit, BitPos(RB5_bit+0)
;ADC_DAC.c,589 :: 		Id = (PORTB&0xFF00)>>8;                                  //Lee el Id de esclavo establecido por el dipswitch
	MOV	PORTB, W1
	MOV	#65280, W0
	AND	W1, W0, W0
	LSR	W0, #8, W2
	MOV	W2, _Id
;ADC_DAC.c,590 :: 		T2adj = 460.0;                                           //Factor de calibracion de T2: Con Temp=20 y Vsnd=343.2, reduce la medida 1mm por cada 3 unidades que se aumente a este factor
	MOV	#0, W0
	MOV	#17382, W1
	MOV	W0, _T2adj
	MOV	W1, _T2adj+2
;ADC_DAC.c,592 :: 		Altura = 275;                                            //Fija la altura de instalacion del sensor en 275mm
	MOV	#275, W0
	MOV	W0, _Altura
;ADC_DAC.c,593 :: 		Kadj = 0;                                                //Fija la constante de ajuste en 0
	CLR	W0
	MOV	W0, _Kadj
;ADC_DAC.c,595 :: 		chDP = &DatoPtcn;                                        //Asocia el valor de DatoPtcn al puntero chDP
	MOV	#lo_addr(_DatoPtcn), W0
	MOV	W0, _chDP
;ADC_DAC.c,596 :: 		ip=0;
	MOV	#lo_addr(_ip), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,598 :: 		Rspt[0] = Hdr;                                           //Se rellena el primer byte de la trama de respuesta con el delimitador de inicio de trama
	MOV	#lo_addr(_Rspt), W1
	MOV.B	#58, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,599 :: 		Rspt[1] = Id;                                            //Se rellena el segundo byte de la trama de repuesta con el Id del tipo de sensor
	MOV	#lo_addr(_Rspt+1), W0
	MOV.B	W2, [W0]
;ADC_DAC.c,600 :: 		Rspt[Rsize-1] = End;                                     //Se rellena el ultimo byte de la trama de repuesta con el delimitador de final de trama
	MOV	#lo_addr(_Rspt+5), W1
	MOV.B	#13, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,602 :: 		while(1){
L_main112:
;ADC_DAC.c,613 :: 		if (BanP==1){                                   //Verifica si se realizo una peticion
	MOV	#lo_addr(_BanP), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA Z	L__main227
	GOTO	L_main114
L__main227:
;ADC_DAC.c,615 :: 		if ((Ptcn[1]==Id)&&(Ptcn[Psize-1]==End)){    //Verifica el identificador de esclavo y el byte de final de trama
	MOV	#lo_addr(_Ptcn+1), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Id), W0
	CP	W1, [W0]
	BRA Z	L__main228
	GOTO	L__main157
L__main228:
	MOV	#lo_addr(_Ptcn+5), W0
	MOV.B	[W0], W0
	CP.B	W0, #13
	BRA Z	L__main229
	GOTO	L__main156
L__main229:
L__main155:
;ADC_DAC.c,617 :: 		Fcn = Ptcn[2];                            //Almacena el tipo de funcion requerida
	MOV	#lo_addr(_Fcn), W1
	MOV	#lo_addr(_Ptcn+2), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,618 :: 		DatoPtcn = 0;                             //Limpia la variable DatoPtcn
	CLR	W0
	MOV	W0, _DatoPtcn
;ADC_DAC.c,620 :: 		switch(Fcn){
	GOTO	L_main118
;ADC_DAC.c,621 :: 		case 1:    //01: Lee el registro principal (05:Caudal)
L_main120:
;ADC_DAC.c,622 :: 		Calcular();                //Realiza una secuencia de calculo
	CALL	_Calcular
;ADC_DAC.c,623 :: 		Responder(0x05);           //Envia la trama de repuesta con el valor del registro principal
	MOV	#5, W10
	CALL	_Responder
;ADC_DAC.c,624 :: 		break;
	GOTO	L_main119
;ADC_DAC.c,626 :: 		case 2:    //02: Lee el registro especifico (01:Nivel, 02:Distancia, 03:TOF, 04:Temperatura)
L_main121:
;ADC_DAC.c,627 :: 		Calcular();                //Realiza una secuencia de calculo
	CALL	_Calcular
;ADC_DAC.c,628 :: 		*chDP = Ptcn[4];           //Almacena el byte 4 de la trama de peticion en el LSB de la variable DatoPtcn
	MOV	#lo_addr(_Ptcn+4), W1
	MOV	_chDP, W0
	MOV.B	[W1], [W0]
;ADC_DAC.c,629 :: 		*(chDP+1) = Ptcn[3];       //Almacena el byte 3 de la trama de peticion en el MSB de la variable DatoPtcn
	MOV	_chDP, W0
	ADD	W0, #1, W1
	MOV	#lo_addr(_Ptcn+3), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,630 :: 		Responder(DatoPtcn);       //Envia la trama de repuesta con el valor del registro requerido
	MOV	_DatoPtcn, W10
	CALL	_Responder
;ADC_DAC.c,631 :: 		break;
	GOTO	L_main119
;ADC_DAC.c,633 :: 		case 3:    //03: Establece la altura de instalacion
L_main122:
;ADC_DAC.c,634 :: 		*chDP = Ptcn[4];           //Almacena el byte 4 de la trama de peticion en el LSB de la variable DatoPtcn
	MOV	#lo_addr(_Ptcn+4), W1
	MOV	_chDP, W0
	MOV.B	[W1], [W0]
;ADC_DAC.c,635 :: 		*(chDP+1) = Ptcn[3];       //Almacena el byte 3 de la trama de peticion en el MSB de la variable DatoPtcn
	MOV	_chDP, W0
	ADD	W0, #1, W1
	MOV	#lo_addr(_Ptcn+3), W0
	MOV.B	[W0], [W1]
;ADC_DAC.c,636 :: 		Altura =  DatoPtcn;        //Almacena el valor de DatoPtcn en la variable Altura
	MOV	_DatoPtcn, W0
	MOV	W0, _Altura
;ADC_DAC.c,637 :: 		Calcular();                //Realiza una secuencia de calculo
	CALL	_Calcular
;ADC_DAC.c,638 :: 		Responder(0x06);           //Envia la trama de repuesta con el valor de la Altura de instalacion
	MOV	#6, W10
	CALL	_Responder
;ADC_DAC.c,639 :: 		break;
	GOTO	L_main119
;ADC_DAC.c,641 :: 		case 4:    //04: Establece el factor de calibracion
L_main123:
;ADC_DAC.c,642 :: 		*chDP = Ptcn[4];           //Almacena el byte 4 de la trama de peticion en el LSB de la variable DatoPtcn
	MOV	#lo_addr(_Ptcn+4), W1
	MOV	_chDP, W0
	MOV.B	[W1], [W0]
;ADC_DAC.c,644 :: 		Kadj = DatoPtcn;           //Almacena el valor de DatoPtcn en la variable Kadj
	MOV	_DatoPtcn, W0
	MOV	W0, _Kadj
;ADC_DAC.c,645 :: 		if (Ptcn[3]==0x11){        //Verifica si el byte 3 es igual a 0x11, de ser asi cambia el signo de la variable Kadj
	MOV	#lo_addr(_Ptcn+3), W0
	MOV.B	[W0], W0
	CP.B	W0, #17
	BRA Z	L__main230
	GOTO	L_main124
L__main230:
;ADC_DAC.c,646 :: 		Kadj = -Kadj;
	MOV	_Kadj, W1
	MOV	#lo_addr(_Kadj), W0
	SUBR	W1, #0, [W0]
;ADC_DAC.c,647 :: 		}
L_main124:
;ADC_DAC.c,648 :: 		Calcular();                //Realiza una secuencia de calculo
	CALL	_Calcular
;ADC_DAC.c,649 :: 		Responder(0x01);           //Envia la trama de repuesta con el valor del Nivel calculado
	MOV	#1, W10
	CALL	_Responder
;ADC_DAC.c,650 :: 		break;
	GOTO	L_main119
;ADC_DAC.c,652 :: 		default:   Rspt[3]=0x00;              //Rellena el campo de datos con el mensaje de error 0x00E1: Funcion no disponible
L_main125:
	MOV	#lo_addr(_Rspt+3), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,653 :: 		Rspt[4]=0xE1;
	MOV	#lo_addr(_Rspt+4), W1
	MOV.B	#225, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,654 :: 		Rspt[2]=0xEE;              //Rellena el byte 2 con el aviso de error 0xEE
	MOV	#lo_addr(_Rspt+2), W1
	MOV.B	#238, W0
	MOV.B	W0, [W1]
;ADC_DAC.c,655 :: 		break;
	GOTO	L_main119
;ADC_DAC.c,656 :: 		}
L_main118:
	MOV	#lo_addr(_Fcn), W0
	MOV.B	[W0], W0
	CP.B	W0, #1
	BRA NZ	L__main231
	GOTO	L_main120
L__main231:
	MOV	#lo_addr(_Fcn), W0
	MOV.B	[W0], W0
	CP.B	W0, #2
	BRA NZ	L__main232
	GOTO	L_main121
L__main232:
	MOV	#lo_addr(_Fcn), W0
	MOV.B	[W0], W0
	CP.B	W0, #3
	BRA NZ	L__main233
	GOTO	L_main122
L__main233:
	MOV	#lo_addr(_Fcn), W0
	MOV.B	[W0], W0
	CP.B	W0, #4
	BRA NZ	L__main234
	GOTO	L_main123
L__main234:
	GOTO	L_main125
L_main119:
;ADC_DAC.c,660 :: 		for (ipp=0;ipp<Psize;ipp++){
	MOV	#lo_addr(_ipp), W1
	CLR	W0
	MOV.B	W0, [W1]
L_main126:
	MOV	#lo_addr(_ipp), W0
	MOV.B	[W0], W0
	CP.B	W0, #6
	BRA LTU	L__main235
	GOTO	L_main127
L__main235:
;ADC_DAC.c,661 :: 		Ptcn[ipp]=0;                          //Limpia la trama de peticion
	MOV	#lo_addr(_ipp), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,660 :: 		for (ipp=0;ipp<Psize;ipp++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ipp), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,662 :: 		}
	GOTO	L_main126
L_main127:
;ADC_DAC.c,664 :: 		BanP = 0;                                 //Limpia la bandera de lectura de datos
	MOV	#lo_addr(_BanP), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,666 :: 		}else{
	GOTO	L_main129
;ADC_DAC.c,615 :: 		if ((Ptcn[1]==Id)&&(Ptcn[Psize-1]==End)){    //Verifica el identificador de esclavo y el byte de final de trama
L__main157:
L__main156:
;ADC_DAC.c,667 :: 		for (ipp=0;ipp<Psize;ipp++){
	MOV	#lo_addr(_ipp), W1
	CLR	W0
	MOV.B	W0, [W1]
L_main130:
	MOV	#lo_addr(_ipp), W0
	MOV.B	[W0], W0
	CP.B	W0, #6
	BRA LTU	L__main236
	GOTO	L_main131
L__main236:
;ADC_DAC.c,668 :: 		Ptcn[ipp]=0;                       //Limpia la trama de peticion
	MOV	#lo_addr(_ipp), W0
	ZE	[W0], W1
	MOV	#lo_addr(_Ptcn), W0
	ADD	W0, W1, W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,667 :: 		for (ipp=0;ipp<Psize;ipp++){
	MOV.B	#1, W1
	MOV	#lo_addr(_ipp), W0
	ADD.B	W1, [W0], [W0]
;ADC_DAC.c,669 :: 		}
	GOTO	L_main130
L_main131:
;ADC_DAC.c,670 :: 		BanP = 0;                              //Limpia la bandera de lectura de datos
	MOV	#lo_addr(_BanP), W1
	CLR	W0
	MOV.B	W0, [W1]
;ADC_DAC.c,671 :: 		}
L_main129:
;ADC_DAC.c,672 :: 		}
L_main114:
;ADC_DAC.c,674 :: 		}
	GOTO	L_main112
;ADC_DAC.c,676 :: 		}
L_end_main:
	POP	W11
	POP	W10
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
