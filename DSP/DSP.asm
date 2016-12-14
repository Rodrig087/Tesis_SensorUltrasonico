
_Timer1Interrupt:
	PUSH	52
	PUSH	RCOUNT
	PUSH	W0
	MOV	#2, W0
	REPEAT	#12
	PUSH	[W0++]

;DSP.c,19 :: 		void Timer1Interrupt() iv IVT_ADDR_T1INTERRUPT{
;DSP.c,20 :: 		if (contp<20){                             //Controla el numero total de pulsos de exitacion del transductor ultrasonico. (42)
	MOV	_contp, W0
	CP	W0, #20
	BRA LTU	L__Timer1Interrupt11
	GOTO	L_Timer1Interrupt0
L__Timer1Interrupt11:
;DSP.c,21 :: 		BS = ~BS;                              //Variable auxiliar para establecer el cambio de estado en el bit RD0.
	MOV	#lo_addr(_BS), W0
	MOV.B	[W0], W0
	COM.B	W0, W1
	MOV	#lo_addr(_BS), W0
	MOV.B	W1, [W0]
;DSP.c,22 :: 		RB0_bit = BS;
	BTSS	W1, #0
	BCLR	RB0_bit, BitPos(RB0_bit+0)
	BTSC	W1, #0
	BSET	RB0_bit, BitPos(RB0_bit+0)
;DSP.c,23 :: 		}else {
	GOTO	L_Timer1Interrupt1
L_Timer1Interrupt0:
;DSP.c,24 :: 		RB0_bit = 0;                           //Pone a cero despues de enviar todos los pulsos de exitacion.
	BCLR	RB0_bit, BitPos(RB0_bit+0)
;DSP.c,25 :: 		TON_bit = 0;
	BCLR	TON_bit, BitPos(TON_bit+0)
;DSP.c,26 :: 		}
L_Timer1Interrupt1:
;DSP.c,28 :: 		contp++;                                    //Aumenta el contador en una unidad.
	MOV	#1, W1
	MOV	#lo_addr(_contp), W0
	ADD	W1, [W0], [W0]
;DSP.c,29 :: 		T1IF_bit = 0;                               //Limpia la bandera de interrupcion de Timer2
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;DSP.c,30 :: 		}
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

;DSP.c,33 :: 		void Velocidad(){
;DSP.c,38 :: 		Ow_Reset(&PORTB, 1);                                 //Onewire reset signal
	PUSH	W10
	PUSH	W11
	PUSH	W12
	MOV	#1, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Reset
;DSP.c,39 :: 		Ow_Write(&PORTB, 1, 0xCC);                           //Issue command SKIP_ROM
	MOV.B	#204, W12
	MOV	#1, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;DSP.c,40 :: 		Ow_Write(&PORTB, 1, 0x44);                           //Issue command CONVERT_T
	MOV.B	#68, W12
	MOV	#1, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;DSP.c,41 :: 		Delay_us(120);
	MOV	#1600, W7
L_Velocidad2:
	DEC	W7
	BRA NZ	L_Velocidad2
;DSP.c,43 :: 		Ow_Reset(&PORTB, 1);
	MOV	#1, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Reset
;DSP.c,44 :: 		Ow_Write(&PORTB, 1, 0xCC);                           //Issue command SKIP_ROM
	MOV.B	#204, W12
	MOV	#1, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;DSP.c,45 :: 		Ow_Write(&PORTB, 1, 0xBE);                           //Issue command READ_SCRATCHPAD
	MOV.B	#190, W12
	MOV	#1, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Write
;DSP.c,47 :: 		Temp =  Ow_Read(&PORTB, 1);
	MOV	#1, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Read
; Temp start address is: 10 (W5)
	ZE	W0, W5
;DSP.c,48 :: 		Temp = (Ow_Read(&PORTB, 1) << 8) + Temp;
	MOV	#1, W11
	MOV	#lo_addr(PORTB), W10
	CALL	_Ow_Read
	ZE	W0, W0
	SL	W0, #8, W0
	ADD	W0, W5, W0
; Temp end address is: 10 (W5)
; Temp start address is: 4 (W2)
	MOV	W0, W2
;DSP.c,50 :: 		if (Temp & 0x8000) {
	BTSS	W0, #15
	GOTO	L__Velocidad9
;DSP.c,51 :: 		Temp = 0;                                         //Si la temperatura es negativa la establece como cero.
	CLR	W2
; Temp end address is: 4 (W2)
;DSP.c,52 :: 		}
	GOTO	L_Velocidad4
L__Velocidad9:
;DSP.c,50 :: 		if (Temp & 0x8000) {
;DSP.c,52 :: 		}
L_Velocidad4:
;DSP.c,54 :: 		Rint = Temp >> 4;                                    //Extrae la parte entera de la respuesta del sensor
; Temp start address is: 4 (W2)
	LSR	W2, #4, W0
; Rint start address is: 6 (W3)
	MOV	W0, W3
;DSP.c,55 :: 		Rfrac = ((Temp & 0x000F) * 625) / 10000.;            //Extrae la parte decimal de la respuesta del sensor
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
;DSP.c,56 :: 		DSTemp = Rint + Rfrac;
	MOV	W3, W0
	CLR	W1
	CALL	__Long2Float
; Rint end address is: 6 (W3)
	MOV	[W14+0], W2
	MOV	[W14+2], W3
	CALL	__AddSub_FP
	MOV	W0, _DSTemp
	MOV	W1, _DSTemp+2
;DSP.c,58 :: 		VSnd = 331.45 * sqrt(1+(DsTemp/273));                //Expresa la temperatura en punto flotante
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
;DSP.c,59 :: 		}
L_end_Velocidad:
	POP	W12
	POP	W11
	POP	W10
	ULNK
	RETURN
; end of _Velocidad

_MainInit:

;DSP.c,62 :: 		void MainInit(){
;DSP.c,65 :: 		CLKDIVbits.PLLPRE = 0;   //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;DSP.c,66 :: 		PLLFBD = 38;             //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
	MOV	#38, W0
	MOV	WREG, PLLFBD
;DSP.c,67 :: 		CLKDIVbits.PLLPOST = 0;  //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;DSP.c,70 :: 		TRISB = 0;               //Initialize PORTB as output
	CLR	TRISB
;DSP.c,71 :: 		LATB = 0;                //Set PORTB to zero
	CLR	LATB
;DSP.c,74 :: 		TON_bit = 1;
	BSET	TON_bit, BitPos(TON_bit+0)
;DSP.c,75 :: 		T1IE_bit = 1;
	BSET	T1IE_bit, BitPos(T1IE_bit+0)
;DSP.c,76 :: 		T1IF_bit = 0;
	BCLR	T1IF_bit, BitPos(T1IF_bit+0)
;DSP.c,77 :: 		IPC0 = IPC0 | 0x1000;
	MOV	#4096, W1
	MOV	#lo_addr(IPC0), W0
	IOR	W1, [W0], [W0]
;DSP.c,78 :: 		PR1 = 500;
	MOV	#500, W0
	MOV	WREG, PR1
;DSP.c,81 :: 		BS = 0;
	MOV	#lo_addr(_BS), W1
	CLR	W0
	MOV.B	W0, [W1]
;DSP.c,82 :: 		contp = 0;
	CLR	W0
	MOV	W0, _contp
;DSP.c,85 :: 		}
L_end_MainInit:
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

;DSP.c,87 :: 		void main(){
;DSP.c,89 :: 		MainInit();
	CALL	_MainInit
;DSP.c,91 :: 		while (1){
L_main5:
;DSP.c,93 :: 		Velocidad();
	CALL	_Velocidad
;DSP.c,95 :: 		TON_bit = 1;
	BSET	TON_bit, BitPos(TON_bit+0)
;DSP.c,96 :: 		contp = 0;
	CLR	W0
	MOV	W0, _contp
;DSP.c,97 :: 		BS = 0;
	MOV	#lo_addr(_BS), W1
	CLR	W0
	MOV.B	W0, [W1]
;DSP.c,98 :: 		Delay_ms(15);
	MOV	#4, W8
	MOV	#3392, W7
L_main7:
	DEC	W7
	BRA NZ	L_main7
	DEC	W8
	BRA NZ	L_main7
;DSP.c,100 :: 		}
	GOTO	L_main5
;DSP.c,102 :: 		}
L_end_main:
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
