	AREA controller, CODE, READWRITE
	EXPORT	weedigdug
	EXPORT	FIQ_Handler

	IMPORT	pin_connect_block_setup
	IMPORT	uart_init
	IMPORT	timer_init
	IMPORT	interrupt_init
	IMPORT	interrupt_disable

	IMPORT	read_timer0
	
	IMPORT	clear_7_seg
	IMPORT	display_digit_on_7_seg
	IMPORT	output_string
	IMPORT	output_character
	IMPORT	read_character
	IMPORT	num_to_dec_str
	
	IMPORT	get_nbit_rand

	IMPORT	U0IER	
	IMPORT	U0IIR
	IMPORT	EXTINT
	IMPORT	INTBASE
	IMPORT	INT_CR
	IMPORT	INT_ER
	IMPORT	INT_SR
	
	IMPORT	update_board
	IMPORT	update_sprite
	IMPORT	draw_empty_board	
	IMPORT	clear_at_x_y
	IMPORT	reset_model

	IMPORT	DUG_SPRITE
	IMPORT	X_POS
	IMPORT	Y_POS	
	IMPORT	LIVES	
	IMPORT	DIRECTION
	IMPORT	OLD_X_POS
	IMPORT	OLD_Y_POS
	IMPORT	DIR_UP
	IMPORT	DIR_DOWN
	IMPORT	DIR_LEFT
	IMPORT	DIR_RIGHT

HALF_SEC	DCD	0x8CA000
TIMER_100ms	DCD	0x1194000

EXIT_P	=	0,0
	ALIGN

weedigdug
	STMFD sp!, {lr}
	BL pin_connect_block_setup
	BL uart_init
	BL interrupt_init
	
	MOV r0, #12
	BL output_character

	BL reset_model
	BL draw_empty_board
	LDR v1, =EXIT_P

	LDR v1, =TIMER_100ms
	LDR r0, [v1]
	BL timer_init
game_loop
	LDRB a1, [v1]	; load exit_p
	CMP a1, #0
	BEQ game_loop	; if exit_p = 0: loop
	LDMFD sp!, {lr}
	BX lr

; Detect collision of sprite with
; 0 -> nothing
; 1 -> Sand
; 2 -> Wall
; 3 -> Enemy
; input
;		v1 = address to sprite
detect_sprite_collision

FIQ_Handler
		STMFD SP!, {r0-r12, lr}  	; Save registers r0-r12, lr

TIMER0_Interrupt
		LDR r0, =0xE0004000
		LDR r1, [r0]
		TST r1, #0x2
		BEQ EINT1_interrupt

		STMFD SP!, {r0-r12, lr}   	; Save registers r0-r12, lr
		; Timer0 interrupt
		BL update_board
		LDMFD SP!, {r0-r12, lr}   ; Restore registers r0-r12, lr
		
		ORR r1, r1, #2		; Clear Interrupt by OR-ing value from 0xE0004000 (r1) with #2
		STR r1, [r0]	   	; store clear value (r1) into 0xE0004000 (r0)

EINT1_interrupt	; Check for EINT1 interrupt
		LDR r0, =0xE01FC140			; load 0xE01FC140 as address
		LDR r1, [r0]			  	; load value from 0xE01FC140
		TST r1, #2				  	; test value with #2
		BEQ U0RDA				  	; branch if eq to handle UART0 instead
	
		STMFD SP!, {r0-r12, lr}   	; Save registers r0-r12, lr 
			
		; Push button EINT1 Handling Code

EINT1_end	

		LDMFD SP!, {r0-r12, lr}   ; Restore registers r0-r12, lr
		
		ORR r1, r1, #2		; Clear Interrupt by OR-ing value from 0xE01FC140 (r1) with #2
		STR r1, [r0]	   	; store clear value (r1) into 0xE01FC140 (r0)

U0RDA	; UART0 RDA interrupts
		LDR r0, =U0IIR			; Load U0IIR address
		LDR r1, [r0]		  	; Load values in U0IIR
		TST r1, #1			  	; Test values against #1
		BNE FIQ_Exit		  	; FIQ_Exit if not equal

		; UART interrupt handler
		STMFD SP!, {r0-r12, lr}   	; Save registers r0-12 & lr
		LDR v1, =DUG_SPRITE
		
		BL read_character
		
		CMP a1, #'w'
		CMPNE a1, #'W'
		BEQ	KEY_UP

		CMP a1, #'a'
		CMPNE a1, #'A'
		BEQ	KEY_LEFT
		
		CMP a1, #'s'
		CMPNE a1, #'S'
		BEQ	KEY_DOWN

		CMP a1, #'d'
		CMPNE a1, #'D'
		BEQ	KEY_RIGHT

		BAL U0RDA_end
		; TODO: check for collisions
KEY_UP
		MOV a1, #-1
		LDR a2, [v1, #Y_POS]
		SUB a2, a2, #1
		MOV a3, #-1
		MOV a4, #DIR_UP
		BAL	U0RDA_update

KEY_DOWN
		MOV a1, #-1
		LDR a2, [v1, #Y_POS]
		ADD a2, a2, #1
		MOV a3, #-1
		MOV a4, #DIR_DOWN	
		BAL	U0RDA_update

KEY_LEFT
		LDR a1, [v1, #X_POS]
		SUB a1, a1, #1
		MOV a2, #-1
		MOV a3, #-1
		MOV a4, #DIR_LEFT	
		BAL	U0RDA_update

KEY_RIGHT
		LDR a1, [v1, #X_POS]
		ADD a1, a1, #1
		MOV a2, #-1
		MOV a3, #-1
		MOV a4, #DIR_RIGHT	
		BAL	U0RDA_update


U0RDA_update
		BL update_sprite
U0RDA_end
		LDMFD SP!, {r0-r12, lr}   	; Restore registers r0-r12, lr	

FIQ_Exit
		LDMFD SP!, {r0-r12, lr}	  	; Restore registers r0-r12, lr	
		SUBS pc, lr, #4				; pc = lr - 4


	END