
_Timer1Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;DSP.c,35 :: 		void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
;DSP.c,36 :: 		if (contp<20){                              //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (42)
	MOV	_contp, W0
	CP	W0, #20
	BRA LTU	L__Timer1Interrupt13
	GOTO	L_Timer1Interrupt0
L__Timer1Interrupt13:
;DSP.c,37 :: 		BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
	MOV	#lo_addr(_BS), W0
	MOV.B	[W0], W0
	COM.B	W0, W1
	MOV	#lo_addr(_BS), W0
	MOV.B	W1, [W0]
;DSP.c,38 :: 		RB0_bit = BS;
	BTSS	W1, #0
	BCLR	RB0_bit, BitPos(RB0_bit+0)
	BTSC	W1, #0
	BSET	RB0_bit, BitPos(RB0_bit+0)
;DSP.c,39 :: 		}else {
	GOTO	L_Timer1Interrupt1
L_Timer1Interrupt0:
;DSP.c,40 :: 		RB0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCLR	RB0_bit, BitPos(RB0_bit+0)
;DSP.c,41 :: 		T1CON.TON = 0;
	BCLR	T1CON, #15
;DSP.c,42 :: 		}
L_Timer1Interrupt1:
;DSP.c,44 :: 		contp++;                                    //Aumenta el contador en una unidad.
	MOV	#1, W1
	MOV	#lo_addr(_contp), W0
	ADD	W1, [W0], [W0]
;DSP.c,45 :: 		T1IF_bit = 0;                               //Limpia la bandera de interrupcion de Timer2
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;DSP.c,46 :: 		}
L_end_Timer1Interrupt:
	MOV	#26, W0
	REPEAT	#12
	POP	[W0--]
	POP	W0
	POP	RCOUNT
	POP	52
	RETFIE
; end of _Timer1Interrupt

_Velocidad:
	LNK	#4

;DSP.c,50 :: 		void Velocidad(){
;DSP.c,55 :: 		Ow_Reset(&PORTB, 4);                        //Onewire reset signal
	PUSH	W10
	PUSH	W11
	PUSH	W12
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Reset
;DSP.c,56 :: 		Ow_Write(&PORTB, 4, 0xCC);                  //Issue command SKIP_ROM
	MOV.B	#204, W12
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;DSP.c,57 :: 		Ow_Write(&PORTB, 4, 0x44);                  //Issue command CONVERT_T
	MOV.B	#68, W12
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;DSP.c,58 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad2:
	DEC	W7
	BRA NZ	L_Velocidad2
	NOP
;DSP.c,60 :: 		Ow_Reset(&PORTB, 4);
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Reset
;DSP.c,61 :: 		Ow_Write(&PORTB, 4, 0xCC);                  //Issue command SKIP_ROM
	MOV.B	#204, W12
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;DSP.c,62 :: 		Ow_Write(&PORTB, 4, 0xBE);                  //Issue command READ_SCRATCHPAD
	MOV.B	#190, W12
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;DSP.c,63 :: 		Delay_us(100);
	MOV	#1333, W7
L_Velocidad4:
	DEC	W7
	BRA NZ	L_Velocidad4
	NOP
;DSP.c,65 :: 		Temp =  Ow_Read(&PORTB, 4);
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Read
; Temp start address is: 10 (W5)
	ZE	W0, W5
;DSP.c,66 :: 		Temp = (Ow_Read(&PORTB, 4) << 8) + Temp;
	MOV	#4, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Read
	ZE	W0, W0
	SL	W0, #8, W0
	ADD	W0, W5, W0
; Temp end address is: 10 (W5)
; Temp start address is: 4 (W2)
	MOV	W0, W2
;DSP.c,68 :: 		if (Temp & 0x8000) {
	BTSS	W0, #15
	GOTO	L__Velocidad11
;DSP.c,69 :: 		Temp = 0;                                //Si la temperatura es negativa la establece como cero.
	CLR	W2
; Temp end address is: 4 (W2)
;DSP.c,70 :: 		}
	GOTO	L_Velocidad6
L__Velocidad11:
;DSP.c,68 :: 		if (Temp & 0x8000) {
;DSP.c,70 :: 		}
L_Velocidad6:
;DSP.c,72 :: 		Rint = Temp >> 4;                           //Extrae la parte entera de la respuesta del sensor
; Temp start address is: 4 (W2)
	LSR	W2, #4, W0
; Rint start address is: 6 (W3)
	MOV	W0, W3
;DSP.c,73 :: 		Rfrac = ((Temp & 0x000F) * 625) / 10000.;   //Extrae la parte decimal de la respuesta del sensor
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
;DSP.c,74 :: 		DSTemp = Rint + Rfrac;
	MOV	W3, W0
	CLR	W1
	CALL	__Long2Float
; Rint end address is: 6 (W3)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	MOV	W0, _DSTemp
	MOV	W1, _DSTemp+2
;DSP.c,76 :: 		VSnd = 331.45 * sqrt(1+(DsTemp/273));       //Expresa la temperatura en punto flotante
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
;DSP.c,77 :: 		}
L_end_Velocidad:
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _Velocidad

_MainInit:

;DSP.c,81 :: 		void MainInit(){
;DSP.c,84 :: 		CLKDIVbits.PLLPRE = 0;                      //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
	PUSH	W10
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;DSP.c,85 :: 		PLLFBD = 41;                                //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
	MOV	#41, W0
	MOV	WREG, PLLFBD
;DSP.c,86 :: 		CLKDIVbits.PLLPOST = 0;                     //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;DSP.c,89 :: 		TRISB0_bit = 0;                             //Establece el pin A3 como salida
	BCLR	TRISB0_bit, BitPos(TRISB0_bit+0)
;DSP.c,90 :: 		LATB0_bit = 0;                              //Limpia el pin A3
	BCLR	LATB0_bit, BitPos(LATB0_bit+0)
;DSP.c,93 :: 		T1CON = 0x8000;                             //Habilita el TMR1, selecciona el reloj interno, desabilita el modo Gated Timer, selecciona el preescalador 1:1,
	MOV	#32768, W0
	MOV	WREG, T1CON
;DSP.c,94 :: 		T1IE_bit = 1;                               //Habilita la interrupcion por desborde de TMR1
	BSET	T1IE_bit, BitPos(T1IE_bit+0)
;DSP.c,95 :: 		T1IF_bit = 0;                               //Limpia la bandera de interrupcion
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;DSP.c,96 :: 		IPC0bits.T1IP = 0x01;                       //Establece el nivel de prioridad de la interrupcion
	MOV	#4096, W0
	MOV	W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	#28672, W0
	AND	W1, W0, W1
	MOV	#lo_addr(IPC0bits), W0
	XOR	W1, [W0], W1
	MOV	W1, IPC0bits
;DSP.c,97 :: 		PR1 = 495;                                  //Precarga del TMR1
	MOV	#495, W0
	MOV	WREG, PR1
;DSP.c,100 :: 		BS = 0;
	MOV	#lo_addr(_BS), W1
	CLR	W0
	MOV.B	W0, [W1]
;DSP.c,101 :: 		contp = 0;
	CLR	W0
	MOV	W0, _contp
;DSP.c,104 :: 		Lcd_init();                                 //Inicializa el LCD
	CALL	_Lcd_Init
;DSP.c,105 :: 		Lcd_Cmd(_LCD_CLEAR);                        //Limpia el LCD
	MOV.B	#1, W10
	CALL	_Lcd_Cmd
;DSP.c,106 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);                   //Apaga el cursor del LCD
	MOV.B	#12, W10
	CALL	_Lcd_Cmd
;DSP.c,108 :: 		}
L_end_MainInit:
	POP	W10
	RETURN
; end of _MainInit

_main:
	MOV	#2048, W15
	MOV	#6142, W0
	MOV	WREG, 32
	MOV	#1, W0
	MOV	WREG, 52
	MOV	#4, W0
	IOR	68

;DSP.c,111 :: 		void main(){
;DSP.c,113 :: 		MainInit();
	PUSH	W10
	PUSH	W11
	PUSH	W12
	CALL	_MainInit
;DSP.c,115 :: 		while (1){
L_main7:
;DSP.c,117 :: 		Velocidad();
	CALL	_Velocidad
;DSP.c,119 :: 		T1CON.TON = 1;
	BSET	T1CON, #15
;DSP.c,120 :: 		contp = 0;
	CLR	W0
	MOV	W0, _contp
;DSP.c,121 :: 		BS = 0;
	MOV	#lo_addr(_BS), W1
	CLR	W0
	MOV.B	W0, [W1]
;DSP.c,123 :: 		FloatToStr(DSTemp, txt1);
	MOV	#lo_addr(_txt1), W12
	MOV	_DSTemp, W10
	MOV	_DSTemp+2, W11
	CALL	_FloatToStr
;DSP.c,124 :: 		FloatToStr(VSnd, txt2);
	MOV	#lo_addr(_txt2), W12
	MOV	_VSnd, W10
	MOV	_VSnd+2, W11
	CALL	_FloatToStr
;DSP.c,126 :: 		Lcd_Out(1,1,"Tmp: ");
	MOV	#lo_addr(?lstr1_DSP), W12
	MOV	#1, W11
	MOV	#1, W10
	CALL	_Lcd_Out
;DSP.c,127 :: 		Lcd_Out_Cp(txt1);
	MOV	#lo_addr(_txt1), W10
	CALL	_Lcd_Out_CP
;DSP.c,128 :: 		Lcd_Out(2,1,"Vel: ");
	MOV	#lo_addr(?lstr2_DSP), W12
	MOV	#1, W11
	MOV	#2, W10
	CALL	_Lcd_Out
;DSP.c,129 :: 		Lcd_Out_Cp(txt2);
	MOV	#lo_addr(_txt2), W10
	CALL	_Lcd_Out_CP
;DSP.c,132 :: 		Delay_ms(15);
	MOV	#4, W8
	MOV	#3392, W7
L_main9:
	DEC	W7
	BRA NZ	L_main9
	DEC	W8
	BRA NZ	L_main9
;DSP.c,134 :: 		}
	GOTO	L_main7
;DSP.c,136 :: 		}
L_end_main:
	POP	W12
	POP	W11
	POP	W10
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
