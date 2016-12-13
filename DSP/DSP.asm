
_MainInit:

;DSP.c,12 :: 		void MainInit(){
;DSP.c,15 :: 		CLKDIVbits.PLLPRE = 0;   //PLLPRE<4:0> = 0  ->  N1 = 2    8MHz / 2 = 4MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#224, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;DSP.c,16 :: 		PLLFBD = 38;             //PLLDIV<8:0> = 38 ->  M = 40    4MHz * 40 = 160MHz
	MOV	#38, W0
	MOV	WREG, PLLFBD
;DSP.c,17 :: 		CLKDIVbits.PLLPOST = 0;  //PLLPOST<1:0> = 0 ->  N2 = 2    160MHz / 2 = 80MHz
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	[W0], W1
	MOV.B	#63, W0
	AND.B	W1, W0, W1
	MOV	#lo_addr(CLKDIVbits), W0
	MOV.B	W1, [W0]
;DSP.c,20 :: 		TRISB = 0;             // Initialize PORTB as output
	CLR	TRISB
;DSP.c,21 :: 		LATB = 0;              // Set PORTB to zero
	CLR	LATB
;DSP.c,23 :: 		}
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

;DSP.c,25 :: 		void main()
;DSP.c,27 :: 		MainInit();
	CALL	_MainInit
;DSP.c,28 :: 		while (1)                      // Infinite loop
L_main0:
;DSP.c,30 :: 		LATB0_bit = ~LATB0_bit;        // Invert PORTB value
	BTG	LATB0_bit, BitPos(LATB0_bit+0)
;DSP.c,31 :: 		Delay_us(10);
	MOV	#133, W7
L_main2:
	DEC	W7
	BRA NZ	L_main2
	NOP
;DSP.c,33 :: 		}
	GOTO	L_main0
;DSP.c,35 :: 		}
L_end_main:
L__main_end_loop:
	BRA	L__main_end_loop
; end of _main
