	AREA	library, CODE, READWRITE	
	EXPORT	uart_init
	EXPORT	timer_init
	EXPORT	pin_connect_block_setup
	EXPORT	interrupt_init
	EXPORT	interrupt_disable
	EXPORT	read_timer0
	EXPORT	set_match0
	EXPORT	set_match1
	EXPORT	set_match2
	EXPORT	set_match3
	EXPORT	reset_timer0


	EXPORT	clear_7_seg
	EXPORT	initial_7_seg
	EXPORT	display_digit_on_7_seg
	EXPORT	read_from_push_btns
	EXPORT	illuminateLEDs
	EXPORT	illuminate_RGB_LED
	
	EXPORT	char_to_hex
	EXPORT	hex_to_char

	EXPORT	output_character
	EXPORT	output_string
	EXPORT	read_character
	EXPORT	read_string
	EXPORT	num_to_dec_str
		
	EXPORT	get_nbit_rand

	EXPORT	U0IER	
	EXPORT	U0IIR
	EXPORT	EXTINT
	EXPORT	INTBASE
	EXPORT	INT_CR
	EXPORT	INT_ER
	EXPORT	INT_SR

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
; CONSTANTS AND DATA
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

PIODATA		EQU 0x8 ; Offset to parallel I/O data register

; -----------------------------------------------------------------------------
; Common GPIO addresses and offsets
; -----------------------------------------------------------------------------
PINSEL0		EQU 0xE002C000; pinselect 0 address
PINSEL1		EQU 0xE002C004; pinselect 1 address

P0BASE		EQU 0xE0028000; GPIO Port 0 base address
P1BASE		EQU 0xE0028010; GPIO Port 0 base address

IO_0_DIR	EQU 0xE0028008;
IO_1_DIR	EQU 0xE0028018;

IODIR			EQU 0x08; 
IOSET			EQU 0x04;
IOCLR			EQU 0x0C;
IOPIN			EQU 0x00;

; -----------------------------------------------------------------------------
; Register addresses for Interrupts
; -----------------------------------------------------------------------------

TIMER0	EQU	0xE0004000
T_IR	EQU	0x00
T_MCR	EQU	0x14
T_MR0	EQU 0x18
T_MR1	EQU	0x1C
T_MR2	EQU 0x20
T_MR3	EQU 0x24
T_TCR	EQU	0x04
T_TC	EQU	0x08

T1MCR	EQU	0xE0004814


U0IER	EQU	0xE000C004
U0IIR	EQU	0xE000C008

EXTINT	EQU	0xE01FC140

INTBASE	EQU	0xFFFFF000
INT_CR	EQU	0x14
INT_ER	EQU	0x10
INT_SR	EQU	0x0C

; -----------------------------------------------------------------------------
; Constants UART0 baud rate
; -----------------------------------------------------------------------------

U0DL_UPPER	EQU	0x00
U0DL_LOWER	EQU	0x0A

; -----------------------------------------------------------------------------
; Constants for IO manipulation
; -----------------------------------------------------------------------------

IO0DIR_CONF		EQU 0x00263F80;
IO0DIR_7SEG0	EQU	0x80;
IO0DIR_7SEG1	EQU	0x3F;
IO0DIR_RGB		EQU 0x26;

IO1DIR_BTN		EQU 0xFF0FFFFF;
IO1DIR_LED		EQU 0x000F0000;
BTNSMASK		EQU 0x00F00000;

RGB_WHITE		EQU 0x1;

RGB_RED			EQU 0x2;
RGB_GREEN		EQU 0x3;
RGB_BLUE		EQU 0x4;

RGB_PURPLE	EQU 0x5;
RGB_YELLOW	EQU 0x6;
RGB_LBLUE		EQU 0x7;

RGB_SET
		DCD 0x00260000	; BLACK			0
		DCD 0x00260000	; WHITE			1
		DCD 0x00020000	; RED			2
		DCD 0x00200000	; GREEN	   		3
		DCD 0x00040000	; BLUE	   		4
		DCD 0x00060000	; PURPLE   		5
		DCD 0x00220000	; YELLOW		6
		DCD 0x00240000	; LIGHT BLUE	7
	ALIGN

digits_SET
		DCD 0x00001F80	; 0
		DCD 0x00000300	; 1
		DCD 0x00002D80	; 2
		DCD 0x00002780	; 3;
		DCD 0X00003300	; 4
		DCD 0x00003680	; 5
		DCD 0x00003E80	; 6
		DCD 0x00000380	; 7
		DCD 0x00003F80	; 8
		DCD 0x00003380	; 9
		DCD 0x00003B80	; A
		DCD 0x00003E00	; b
		DCD 0x00001C80	; C
		DCD 0x00002F00	; d
		DCD 0x00003C80	; E
		DCD 0x00003880	; F
	ALIGN
LED_SET
		;0 is on and x is off
		DCD 0x00; xxxx
		DCD 0x01; 0xxx
		DCD 0x02; x0xx
		DCD 0x03; 00xx
		DCD 0x04; xx0x
		DCD 0x05; 0x0x
		DCD 0x06; x00x
		DCD 0x07; 000x
		DCD 0x08; xxx0
		DCD 0x09; 0xx0
		DCD 0x0A; x0x0
		DCD 0x0B; 00x0
		DCD 0x0C; xx00
		DCD 0x0D; 0x00
		DCD 0x0E; x000
		DCD 0x0F; 0000 
	ALIGN
REV_4BITS
		;0 is on and x is off
		DCD 0x00; 0000	0
		DCD 0x08; 1000	1
		DCD 0x04; 0100	2
		DCD 0x0C; 1100	3
		DCD 0x02; 0010	4
		DCD 0x0A; 1010	5
		DCD 0x06; 0110	6
		DCD 0x0E; 1110	7
		DCD 0x01; 0001	8
		DCD 0x09; 1001	9
		DCD 0x05; 0101	a
		DCD 0x0D; 1101	b
		DCD 0x03; 0011	c
		DCD 0x0B; 1011	d
		DCD 0x07; 0111	e
		DCD 0x0F; 1111 	f
	ALIGN

POW_OF_10
		DCD 1					; 0
		DCD 10				; 1
		DCD 100				; 2
		DCD 1000			; 3
		DCD 10000			; 4
		DCD 100000		; 5
		DCD 1000000		; 6

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
; SUBROUTINES
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; Init routines: pin connect block and uart init
; -----------------------------------------------------------------------------

pin_connect_block_setup
	STMFD sp!, {r0, r1, r2, r3, lr}
	; PINSEL0
	LDR r0, =PINSEL0  			
	LDR r1, [r0]				; 
	ORR r1, r1, #5				; Sets UART Rx and Tx and GPIO otherwise
	BIC r1, r1, #0xA			;
	STR r1, [r0]
	
	; PINSEL1
	LDR r0, =PINSEL1
	LDR r1, [r0]
	ORR r1, #0x00000000
	STR r1, [r0]				; store 32 o's in PINSEL1 to select all GPIO Pins in Port 0
	
	; IO direction; setting pins as inputs or outputs
	LDR r0, =IO_0_DIR
	LDR r1, [r0]
	MOV r3, #IO0DIR_RGB			
	MOV r2, r3, LSL #16			; r2 = 0x00260000
	MOV r3, #IO0DIR_7SEG1		
	ORR r2, r2, r3, LSL #8		; r2 = 0x00263F00
	MOV r3, #IO0DIR_7SEG0
	ORR r2, r2, r3				; r2 = 0x00263F80
	ORR r1, r1, r2 				; IODIR_CONF holds data not address
	STR r1, [r0]
	
	LDR r0, =IO_1_DIR
	LDR r1, [r0]
	AND r1, r1, #IO1DIR_BTN 	; ANDing and setting 23:20 to 0
	ORR r1, r1, #IO1DIR_LED		; ORing and setting 19:16 to 1	
	STR r1, [r0]
	
	LDMFD sp!, {r0, r1, r2, r3, lr}
	BX lr

; UART Init routine
uart_init
	STMFD SP!,{lr, r3, r4}	; Store register lr on stack
	
	LDR r3, =0xE000C000		; Load UART0 Base address
	MOV r4, #131			; Byte to enable divisor latch access
	STRB r4, [r3, #0x0C]		; Enable divisor latch access
	MOV r4, #U0DL_LOWER			; Lower Latch Baud Rate
	; make it FAAAASSSSSTTTT
	;LSL r4, r4, #8
	STRB r4, [r3]			; Set lower divisor latch for 115200 baud
	MOV r4, #U0DL_UPPER			; Upper latch  Baud Rate
	STRB r4, [r3, #0x04]		; Set upper divisor latch for 115200 baud
	MOV r4, #3			; Disable break control value
	STRB r4, [r3, #0x0c]			; disable divisor latch access

	LDMFD sp!, {lr, r3, r4}
	BX lr

; Takes in 1 input, interrupt time
timer_init
	STMFD SP!,{lr, r3, r4}	; Store register lr on stack
	
	LDR r3, =TIMER0		; Load TIMER0 Base address
	MOV r4, #1				; Enable timer
	STR r4, [r3, #T_TCR]		;

	LDMFD sp!, {lr, r3, r4}
	BX lr

reset_timer0
	STMFD SP!,{lr}	; Store register lr on stack
	
	LDR a1, =TIMER0		; Load TIMER0 Base address
	MOV a2, #0x2
	STR a2, [a1, #T_TCR]		;
	MOV a2, #0x1
	STR a2, [a1, #T_TCR]		;
	LDMFD sp!, {lr}
	BX lr

; Set match register 0
; input:	a1	=	Timer match value
;			a2	=	Reset
set_match0
	STMFD SP!,{lr, v1}	; Store register lr on stack
	
	LDR v1, =TIMER0		; Load TIMER0 Base address
	STR a1, [v1, #T_MR0]	; set MR0
	
	; Get correct bit for MCR (bit x*3)
	; I R S
	; 0 1 2
	MOV a1, #0
	ORR a1, a1, #1			; Set Bit 0 = 1 for interrupt
	ORR a1, a1, a2, LSL #1	; Set bit 1 = x for reset
	STR a1, [v1, #T_MCR]

	LDMFD sp!, {lr, v1}
	BX lr

; Set match register 1
; input:	a1	=	Timer match value
;			a2	=	Reset
set_match1
	STMFD SP!,{lr, v1}	; Store register lr on stack
	
	LDR v1, =TIMER0		; Load TIMER0 Base address
	STR a1, [v1, #T_MR1]	; set MR0
	
	; Get correct bit for MCR (bit x*3)
	; I R S
	; 0 1 2
	MOV a1, #1
	LSL a1, a1, #3			; Set Bit 3 = 1 for interrupt
	ORR a1, a1, a2, LSL #4	; Set bit 4 = x for reset
	STR a1, [v1, #T_MCR]

	LDMFD sp!, {lr, v1}
	BX lr

; Set match register 2
; input:	a1	=	Timer match value
;			a2	=	Reset
set_match2
	STMFD SP!,{lr, v1}	; Store register lr on stack
	
	LDR v1, =TIMER0		; Load TIMER0 Base address
	STR a1, [v1, #T_MR2]	; set MR2
	
	; Get correct bit for MCR (bit x*3)
	; I R S
	; 0 1 2
	MOV a1, #1
	LSL a1, a1, #6			; Set Bit 6 = 1 for interrupt
	ORR a1, a1, a2, LSL #7	; Set bit 7 = x for reset
	STR a1, [v1, #T_MCR]

	LDMFD sp!, {lr, v1}
	BX lr

; Set match register 3
; input:	a1	=	Timer match value
;			a2	=	Reset
set_match3
	STMFD SP!,{lr, v1}	; Store register lr on stack
	
	LDR v1, =TIMER0		; Load TIMER0 Base address
	STR a1, [v1, #T_MR3]	; set MR3
	
	; Get correct bit for MCR (bit x*3)
	; I R S
	; 0 1 2
	MOV a1, #1
	LSL a1, a1, #9			; Set Bit 9 = 1 for interrupt
	ORR a1, a1, a2, LSL #10	; Set bit 10 = x for reset
	STR a1, [v1, #T_MCR]

	LDMFD sp!, {lr, v1}
	BX lr
	
read_timer0
	STMFD SP!,{lr, r3}	; Store register lr on stack
	
	LDR r3, =TIMER0		; Load TIMER0 Base address
	LDR r0, [r3, #T_TC]	;

	LDMFD sp!, {lr, r3}
	BX lr


interrupt_init       
		STMFD SP!, {r0-r1, lr}		; Save registers 
		
		; Push button setup		 
		LDR r0, =0xE002C000			; Load PINSEL0 = 0xE002C000		
		LDR r1, [r0]				; Load value from PINSEL0
		ORR r1, r1, #0x20000000		; Set bit 29 = 1 (OR	0x20000000)
		BIC r1, r1, #0x10000000		; Set bit 28 = 0 (CLEAR	0x10000000)
		STR r1, [r0]  ; PINSEL0 bits 29:28 = 10

		; Classify sources as IRQ or FIQ
		; Interrupt Reg Base 				= 0xFFFFF000
		; Interrupt Enable Register (IER) 	= 0xFFFFF010
		; Interrupt Select Register (ISR) 	= 0xFFFFF00C
		LDR r0, =INTBASE			; Load Interrupt Reg Base 
		LDR r1, [r0, #INT_SR]		; Load [ISR]
		ORR r1, r1, #0x8000 		; ORR External Interrupt 1 (Pin 15 = 1 --> 0x8000)
		ORR r1, r1, #0x0040			; Enable UART0 interrupt (Pin 6 = 1 --> 0x0020)
		ORR r1, r1, #0x0010			; Timer 0 = Pin 4 -- Enable as FIQ (1)
		STR r1, [r0, #INT_SR]		; Store EINT1 enabled in ISR

		; Enable Interrupts
		; Store [IER] || 0x8000 in IER	---> EINT1
		; Store [IER] || 0x0040 in IER	---> UART0 Int
		LDR r0, =INTBASE
		LDR r1, [r0, #INT_ER] 
		ORR r1, r1, #0x8000 ; External Interrupt 1
		ORR r1, r1, #0x0040 ; UART0 Interrupt
		ORR r1, r1, #0x0010			; Timer 0 
		STR r1, [r0, #INT_ER]

		; External Interrupt 1 setup for edge sensitive
		LDR r0, =0xE01FC148
		LDR r1, [r0]
		ORR r1, r1, #2  ; EINT1 = Edge Sensitive
		STR r1, [r0]

		; Enable Interrupt for UART0
		LDR r0, =U0IER			   
		LDR r1, [r0]
		ORR r1, r1, #0x1	; Set bit 0 = 1
		STR r1, [r0]

		; Enable Interrupt for Timer 0
;		LDR r0, =TIMER0
;		;LDR r1, [r0, #T_MCR]
;		MOV r1, #0
;		ORR r1, r1, #0x08	; set bit 3 to 1 for interrupt
;		ORR r1, r1, #0x10	; set bit 4 to 1 for reset
;		;ORR r1, r2, #0x20	; set but 5 to 1 for stop
;		STR r1, [r0, #T_MCR]


		; Enable FIQ's, Disable IRQ's
		MRS r0, CPSR
		BIC r0, r0, #0x40
		ORR r0, r0, #0x80
		MSR CPSR_c, r0

		LDMFD SP!, {r0-r1, lr} ; Restore registers
		BX lr             	   ; Return

interrupt_disable
		STMFD sp!, {lr, r0, r1}
		; Disable Interrupts
		; Store [Interrupt Clear Reg] || 0x8000 in IC
		; Store [Interrupt Clear Reg] || 0x0040 in ICR
		LDR r0, =INTBASE
		LDR r1, [r0, #INT_CR] 
		ORR r1, r1, #0x8000 ; External Interrupt 1
		ORR r1, r1, #0x0040 ; UART0 Interrupt 
		STR r1, [r0, #INT_CR]
		LDMFD sp!, {lr, r0, r1}
		BX lr

; -----------------------------------------------------------------------------
; Pseudorandom number generator
; -----------------------------------------------------------------------------

; N-bit random number generator
; input		r0 (a1) = N
; output	r0 (a1) = N-bit random number
get_nbit_rand
	STMFD sp!, {lr, v1, v2}
	; get LSB from timer0 as a random bit
	; construct N-bit number
	MOV v1, r0		; v1 holds bit count
	RSB v1, v1, #32	; places to shift left
	BL read_timer0	; timer value in r0
	LSL r0, r0, v1	;
	LSR r0, r0, v1	; 
	LDMFD sp!, {lr, v1, v2}
	BX lr

; -----------------------------------------------------------------------------
; Lab 4 routines: device IO & manipulation
; -----------------------------------------------------------------------------

; Subroutine:	Display digit on 7-segment display
; Input:			r0	=	hex number to show
display_digit_on_7_seg
	STMFD sp!, {lr, r2-r12}
	
	LDR r2, =P0BASE;   LOAd P0Base adreess int r2
	MOV r3, #0x00003F80	; move 7 seg pattern into r3
	STR r3, [r2, #IOCLR]; store value from r3 to r2+ 0xc (clears the 7 seg)

	LDR r3, =digits_SET	 ; LOAD digit_SET adress to r3
	MOV r4, r0; 		move r0 to r4
	MOV r4, r4, LSL #2; LOGically left shift r4 2 places and move to r4
	LDR r5, [r3, r4];  load [r3+r4]	to r5
	STR	r5, [r2, #IOSET];  store value in r5 to r2+4
	LDMFD sp!, {lr, r2-r12}
	BX lr

clear_7_seg
	STMFD sp!, {lr, r2-r12}
	
	LDR r2, =P0BASE;   LOAd P0Base adreess int r2
	MOV r3, #0x00003F80	; move 7 seg pattern into r3
	STR r3, [r2, #IOCLR]; store value from r3 to r2+ 0xc (clears the 7 seg)

	LDMFD sp!, {lr, r2-r12}
	BX lr

initial_7_seg
	STMFD sp!, {lr, r2-r12}
	
	LDR r2, =P0BASE;   LOAd P0Base adreess int r2
	MOV r3, #0x00003F80	; move 7 seg pattern into r3
	STR r3, [r2, #IOCLR]; store value from r3 to r2+ 0xc (clears the 7 seg)

	MOV r3, #0x00002000
	STR r3, [r2, #IOSET]
	LDMFD sp!, {lr, r2-r12}
	BX lr

; Subroutine:	Read values from push button
; Output:			r0	= 1 byte in the form xxxx. the bit is 1 if the button is pushed
read_from_push_btns
	STMFD	sp!, {lr, r2-r12}
	
	LDR		r2, =P1BASE					;	Load Port 1 base address
	LDR		r0, [r2]		;	Load the values from GPIO in port 1
	AND		r0, r0, #BTNSMASK		;	Isolate values from buttons
	MVN		r0, r0, LSR #20
	AND		r0, r0, #0xF
	LDMFD	sp!, {lr, r2-r12}
	BX lr


; Subroutine:	Manipulate LEDs
; Input:
illuminateLEDs
	STMFD sp!, {lr, r2-r12}
	
	; Clear the LEDs
	LDR r2, =P1BASE				;Load Port 1 Base address
	MOV r3, #0xF;				;move 15 to r3
	MOV r3, r3 , LSL #16	                ;MOVE 0xf to r2 logically left shifted 16 position
	STR r3, [r2, #IOSET]			;STORE r3 into [r2+IOSET]
	
	; Set pattern into LEDs
	;MOV r4, r0, LSL #16			; MOVE r0 logically left shifted #16 position to r4
	LDR r3, =REV_4BITS
	;MOV r5, r0, LSL #2
	LDR r4, [r3, r0, LSL #2]
	LSL r4, r4, #16
	STR r4, [r2, #IOCLR] 			; STORE r4 to [r2+IOCLR]

	LDMFD sp!, {lr, r2-r12}			;store and load lr, r2-12
	BX lr


; Subroutine:	Manipulate RGB LEDs
; Input:			r0 = enum option as below
; 
; |----------------------------	|
; | ENUM	| COLOR			|	|
; |----------------------------	|
; | 0			| BLACK			|
; | 1			| WHITE			|
; | 2			| RED			|
; | 3			| GREEN			|
; | 4			| BLUE			|
; | 5			| PURPLE		|
; | 6			| YELLOW		|
; | 7			| LIGHT BLUE	|
; |----------------------------	|
illuminate_RGB_LED
	STMFD	sp!, {lr, r2-r12}
	
	LDR		r2, =P0BASE					; Load Port 0 Base address
	LDR		r4, =RGB_SET				; Load address for RGB Colors
	MOV		r5, #RGB_WHITE
	LDR		r6, [r4, r5, LSR #2]
	STR		r6, [r2, #IOSET]			; Switch off LED (black)

	LDR		r3, [r2]					; Load all values from GPIO in Port 0
	CMP		r0, #0						; check if black
	BEQ		rgb_done

	; MOV		r5, r0, LSL #2			; Convert enum into word offset
	LDR		r6, [r4, r0, LSL #2]		; Load color IOSET configuration
	STR		r6, [r2, #IOCLR]			; set IOCLR
rgb_done	
	LDMFD sp!, {lr, r2-r12}
	BX lr

; -----------------------------------------------------------------------------
; Lab 3 routines: UART IO
; -----------------------------------------------------------------------------
; Output character routine   
; Input: One character
; Output: None
; output character    
output_character			; r0 = inputed character
	STMFD SP!,{lr, r3, r4, r5}	; Store register lr on stack	
	LDR r3, =0xE000C014		; r3 = Address to UART0 Line Starus Reg
o_loop
	LDRB r4, [r3]			; load byte from LSR
	LSR r4, r4, #5			; Make THRE the LSB
	AND r4, r4, #1			; Isolate THRE
	CMP r4, #0				; check if THRE is 0
	BEQ o_loop
	LDR r5, =0xE000C000		; r5 = THR 

	STRB r0, [r5]			; store inputed byte in UART THR	 	
	LDMFD sp!, {lr, r3, r4, r5}
	BX lr

;read character
read_character			  	; r0 = return val
	STMFD SP! ,{lr, r3, r4, r5}
	LDR r3, =0xE000C014	 ; load LIne status register adress into r3

r_loop
	LDRB r4, [r3]; LOAD byte to r4
	AND r4, r4, #1;	CLEAr ALL bits but rdr by ANDING
	CMP r4, #0 ;	compare if r4 is 0
	BEQ	r_loop;		 if so, go back to r_loop
	LDR r5, =0xE000C000	;  load recieve holding register add. to r5

	LDRB r0, [r5]; load byte from r5 to r0
	LDMFD sp!, {lr, r3, r4, r5}	 
	BX lr


; Output String routine
; Input: Address to string in r4
;
output_string
	STMFD sp! ,{lr, r0, r4, r5}
	MOV r5, #0				; Initialize str offset to 0
ostr_loop
	LDRB r0, [r4, r5]		; Load byte from address+offset
	CMP r0, #0				; check if NULL
	BEQ ostr_end
	BL output_character		; r0 = char
	ADD r5, r5, #1			; offsett++
	BAL ostr_loop			; continue outputting characters
ostr_end
	LDMFD sp!, {lr, r0, r4, r5}			; restore stack and return address
	BX lr

; Read String routine
; Input: Address to string  destination in r4

read_string
	STMFD sp! ,{lr, r0, r4, r5}
	MOV r5, #0				; Initialize str offset to 0
rstr_loop
	BL read_character		; r0 = char
	CMP r0, #10				; check if NEW LINE
	BEQ rstr_end
	CMP r0, #13				; check if carriage return
	BEQ rstr_end
	BL output_character		; print the character
	STRB r0, [r4, r5]		; store at str base address + offset
	ADD r5, r5, #1			; offsett++
	BAL rstr_loop			; continue outputting characters
rstr_end
	MOV r0, #10				; load newline
	BL output_character
	MOV r0, #13				; load CR
	BL output_character
	MOV r0, #0				; load null
	STRB r0, [r4, r5]		; store at last address
	LDMFD sp!, {lr, r0, r4, r5}			; restore stack and return address
	BX lr

; HELPER FUNCTIONS

; Multiply by 10
; input:	r0 = integer
; output:	r0 = integer * 10
multiply_by_ten
	STMFD sp! ,{lr, r2-r12}
	LSL r2, r0, #3
	ADD r0, r2, r0, LSL #1	
	LDMFD sp!, {lr, r2-r12}			; restore stack and return address
	BX lr

; char to decimal int
; input:	r0 = char
; output:	r0 = int
char_to_int
	STMFD sp! ,{lr, r2-r12}
	SUB	r0, r0, #48
	LDMFD sp!, {lr, r2-r12}			; restore stack and return address
	BX lr

; char to hex digit
; input:	r0 = char
; output:	r0 = hex number
char_to_hex
	STMFD sp!, {lr, r2-r12}
	; char 	48 = '0'
	; 		65 = 'A'
	;		97 = 'a'

;; Check 0-9 range	
	; Check if char is < '0'
	CMP r0, #48
	BLT c2hex_err
	; Check if char is <= '9'
	CMP r0, #57
	BGT c2hex_cap
	SUB r0, r0, #48
	B c2hex_end

;; Check A-F range
c2hex_cap
	; check if char is >= 'A'
	CMP r0, #65
	BLT c2hex_err
	; check if char is <= 'F'
	CMP r0, #70	
	BGT c2hex_low
	SUB r0, r0, #55
	B c2hex_end

;; Check a-f range
c2hex_low
	; check if char is >= 'a'
	CMP r0, #97
	BLT	c2hex_err
	; check if char is <= 'f'
	CMP r0, #102
	BGT c2hex_err
	SUB r0, r0, #87
	B c2hex_end

c2hex_err
	MOV r0, #-1
c2hex_end
	LDMFD sp!, {lr, r2-r12}
	BX lr

; hex digit to char
; input:	r0 = hex digit
; output: 	r0 = char
hex_to_char
	STMFD sp!, {lr, r2-r12}
	; char 	48 = '0'
	; 		65 = 'A'
	;		97 = 'a'

;; Check 0-9 range	
	; Check if char is >= 0
	CMP r0, #0
	BLT h2c_err
	; Check if char is <= 9
	CMP r0, #9
	BGT h2c_alphabet
	ADD r0, r0, #48
	B h2c_end


;; Check A-F range
h2c_alphabet
	; check if char is <= F
	CMP r0, #0xF
	BGT h2c_err
	ADD r0, r0, #55
	B h2c_end

h2c_err
	MOV r0, #-1
h2c_end
	LDMFD sp!, {lr, r2-r12}
	BX lr


; Convert string to integer
; input:	r4 = address to string
; output:	r0 = integer
convert_to_string
	STMFD sp! ,{lr, r2, r3, r5-r12}
	
	; r2 = is positive flag	  0 = positive
	; r3 = temp int store
	; r5 = counter/pointer
	
	; Initialize regs
	MOV r2, #0		; default: number is positive
	MOV	r3, #0		; begin at identity 0
	MOV r5, #0		; begin pointer at start

convstr_loop
	LDRB r0, [r4, r5]	; load character


	LDMFD sp!, {lr, r2, r3, r5-r12}			; restore stack and return address
	BX lr

; Convert number to decimal string
; input	r4(v1) = address to string
;				r0 = value
;				r1 = width of string in bytes
num_to_dec_str
	STMFD sp!, {lr, v1-v8}
	SUB r1, r1, #1
	MOV v4, #0				; Store for digit
	LDR v2, =POW_OF_10
num2dec_loop
	CMP r1, #0				; compare r1 to 0
	BLT num2dec_end		; end if < 0
	LDR v3, [v2, r1, LSL #2]	; load power of 10
	CMP r0, v3				; compare power of 10 and value
	SUBGE r0, r0, v3	; if value >= closest pow of 10, Subtract pow10 from val
	ADDGE v4, v4, #1	; and increment digit
	BGE num2dec_loop	; and loop back
	SUB r1, r1, #1		; else decrement width
	ADD v4, v4, #'0'	; get digit as char
	STRB v4, [r4], #1	; store byte in highest digit not set and increment address by 1
	MOV v4, #0				; reset digit to 0
	BAL num2dec_loop	; loop back
num2dec_end

	LDMFD sp!, {lr, v1-v8}
	BX lr

; -----------------------------------------------------------------------------
; Lab 2 routines: Division
; -----------------------------------------------------------------------------

; Division routine
; input:	r0 = dividend
;			r1 = divisor
; output:	r0 = quotient
;			r1 = remainder
div_and_mod
	STMFD r13!, {r2-r12, r14}	
	; Your code for the signed division/mod routine goes here.  
	; The dividend is passed in r0 and the divisor in r1.
	; The quotient is returned in r0 and the remainder in r1.

	; r7 = Final negation, i.e.,
	; if dividend and divisor or positive or negative	=> r7 = 0
	; else if only one is negative				=> r7 = 1
	LSR r7, r0, #31	; isolate MSB of dividend
	ORR r7, r7, r1, LSR #31	; OR the MSBs of dividend and divisor
	
	; Initialize div routine
	MOV r2, #16	; r2 := 16		--> counter (will subtract at beginning itself)
	MOV r3, r1	; r3 --> Divisor
	MOV r4, #0	; r4 --> quotient
	MOV r5, r0	; r5 --> R / Dividend
	
check_dividend
	CMP r0, #0	; check if dividend is negative
	BGT check_divisor	; check divisor if not
	; Two's complement the remainder/dividend
	MVN r5, r0	; 1's complement of dividend
	ADD r5, r5, #1	; 2's complement of divident
check_divisor
	CMP r1, #0	; check if divisor is negative
	BGT div_start ; start div is not
	; Two's complement the divisor
	MVN r3, r1	; 1's complement of divisor
	ADD r3, r3, #1	; 2's complement of divisor

div_start
	; Continue initialization
	LSL r3, r3, #15	; r3 = divisor << 15 

div_loop
	SUB r2, r2, #1	; decrement counter (r2)
	SUB r5, r5, r3	; remainder = remainder - divisor
	CMP r5, #0	; compare remainder and 0
	MOV r6, #1	; value to add to quotient (default 1 if restoration skipped)
	BGE skip_restore; skip restoration of remainder if remainder > 0
	ADD r5, r5, r3	; restore remainder
	MOV r6, #0	; value to add to quotient (set to 0 as remainder is restored)
skip_restore
	ADD r4, r6, r4, LSL #1	; shift Q(r4) and add value to be added (r6 0/1)
	LSR r3, r3, #1	; Logical right shift divisor (r3)

	CMP r2, #0	; Compare counter
	BGT div_loop	; and branch if > 0
	
	; Choose to convert to 2s complement based on value stored in r7
	CMP r7, #0
	BEQ is_positive	; is_positive iff r7 = 0
			; else negative => 2's complement
	MVN r4, r4	; 1's complement of quotient
	ADD r4, r4, #1	; 2's complement of quotient
is_positive
	MOV r0, r4	; Copy quotient to r0
	MOV r1, r5	; Copy remainder to r1
	LDMFD r13!, {r2-r12, r14}
	BX lr		; Return to the C program

multiply_end
	LDMFD sp!, {lr, v1-v8}
	BX lr

	END
