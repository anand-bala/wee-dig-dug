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
	IMPORT	get_sand_at_xy
	IMPORT	update_model
	IMPORT	queue_movement_DUG

	IMPORT	DUG_SPRITE
	IMPORT	FYGAR_SPRITE_1
	IMPORT	POOKA_SPRITE_1
	IMPORT	POOKA_SPRITE_2
	IMPORT	PUMP_SPRITE

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

HALF_SEC	EQU	0x08CA000
TIMER_100ms	EQU	0x1C2000

RUN_P		=	0,0
EXIT_P		=	0,0
UPDATE_P	=	0,0
	ALIGN

weedigdug
	STMFD sp!, {lr}
	BL pin_connect_block_setup
	BL uart_init
	BL interrupt_init

	MOV a1, #12
	BL output_character

; Begin GAME
	LDR v1, =EXIT_P
	LDR v2, =RUN_P
game_begin
;	BL read_character

	LDR a1, =TIMER_100ms
	BL timer_init
	BL reset_model

	LDR v1, =RUN_P
	MOV ip, #1
	STRB ip, [v1]	; Raise runing flag 

game_loop
	LDRB a1, [v1]	; load exit_p
	CMP a1, #0
	BEQ game_loop	; if exit_p = 0: loop
	LDMFD sp!, {lr}
	BX lr



FIQ_Handler
		STMFD SP!, {r0-r12, lr}  	; Save registers r0-r12, lr

TIMER0_Interrupt
		LDR r0, =0xE0004000
		LDR r1, [r0]
		TST r1, #0x2
		BEQ EINT1_interrupt

		STMFD SP!, {r0-r12, lr}   	; Save registers r0-r12, lr
		; Timer0 interrupt

		LDR v1, =RUN_P
		LDRB ip, [v1]
		CMP ip, #0
		BEQ TIMER0_end
		BL update_model
TIMER0_end
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
		MOV ip, a1			; hold character in ip

		LDMIA v1, {a1-a2}	; load DUG_SPRITE coordinates
		MOV a3, #-1			; dont update lives

		CMP ip, #'w'
		CMPNE ip, #'W'
		BEQ	KEY_UP

		CMP ip, #'a'
		CMPNE ip, #'A'
		BEQ	KEY_LEFT

		CMP ip, #'s'
		CMPNE ip, #'S'
		BEQ	KEY_DOWN

		CMP ip, #'d'
		CMPNE ip, #'D'
		BEQ	KEY_RIGHT

		BAL U0RDA_end
		; TODO: check for collisions
KEY_UP
		MOV a1, #DIR_UP
		BAL	U0RDA_update

KEY_DOWN
		MOV a1, #DIR_DOWN
		BAL	U0RDA_update

KEY_LEFT
		MOV a1, #DIR_LEFT
		BAL	U0RDA_update

KEY_RIGHT
		MOV a1, #DIR_RIGHT
		BAL	U0RDA_update
U0RDA_update
		BL queue_movement_DUG
U0RDA_end
		LDMFD SP!, {r0-r12, lr}   	; Restore registers r0-r12, lr

FIQ_Exit
		LDMFD SP!, {r0-r12, lr}	  	; Restore registers r0-r12, lr
		SUBS pc, lr, #4				; pc = lr - 4


	END
