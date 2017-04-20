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
	BL read_character 

	BL reset_model
	LDR a1, =TIMER_100ms
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
; 3 -> Fatal Collision
; input
;	v1 = address to sprite
;	a1 = Type of sprite
;		0 = DUG
;		1 = POOKA
;		2 = FYGAR
;		3 = PUMP/BULLET
; output
;	a1 = output
detect_sprite_collision
	; TODO: Just update the actual GUI
	STMFD sp!, {lr, v1-v8}
	; v8 = addresses

	; a2 = X POS
	; a3 = Y POS

	LDR a2, [v1, #X_POS]
	LDR a3, [v1, #Y_POS]

	CMP a1, #3
	BEQ is_pump_check
	CMP a1, #2
	BEQ is_fygar_check
	CMP a1, #1
	BEQ is_pooka_check
	CMP a1, #0
	BEQ is_dug_check

	BAL collision_end

is_dug_check
; Sprite is Dug. 
; 1. Check for fatal collision (with fygar or pooka)
	LDR v8, =FYGAR_SPRITE_1		; Load FYGAR
	; Check if X Positions are equal
	LDR ip, [v8, #X_POS]		; Load its X POSITION
	CMP ip, a2			; Compare the X positions
	MOVEQ a1, #3			; set return value to 3 (FATAL) 
	BEQ collision_end

	; Check if Y Positions are equal
	LDR ip, [v8, #Y_POS]		; Load its Y POSITION
	CMP ip, a3			; Compare the Y positions
	MOVEQ a1, #3			; set return value to 3 (FATAL) 
	BEQ collision_end

	LDR v8, =POOKA_SPRITE_1		; Load POOKA
	; Check if X Positions are equal
	LDR ip, [v8, #X_POS]		; Load its X POSITION
	CMP ip, a2			; Compare the X positions
	MOVEQ a1, #3			; set return value to 3 (FATAL) 
	BEQ collision_end

	; Check if Y Positions are equal
	LDR ip, [v8, #Y_POS]		; Load its Y POSITION
	CMP ip, a3			; Compare the Y positions
	MOVEQ a1, #3			; set return value to 3 (FATAL) 
	BEQ collision_end

	LDR v8, =POOKA_SPRITE_2		; Load POOKA1
	; Check if X Positions are equal
	LDR ip, [v8, #X_POS]		; Load its X POSITION
	CMP ip, a2			; Compare the X positions
	MOVEQ a1, #3			; set return value to 3 (FATAL) 
	BEQ collision_end

	; Check if Y Positions are equal
	LDR ip, [v8, #Y_POS]		; Load its Y POSITION
	CMP ip, a3			; Compare the Y positions
	MOVEQ a1, #3			; set return value to 3 (FATAL) 
	BEQ collision_end

; 2. check for wall collision
	CMP a2, #0	; check
	MOVLT a1, #2
	BLT collision_end	; end if x < 0
	CMP a2, #18 ; check
	MOVGT a1, #2
	BGT collision_end	; end if x > 18

	CMP a3, #0	; check
	MOVLT a1, #2
	BLT collision_end	; end if y < 0
	CMP a3, #14 ; check
	MOVGT a1, #2
	BGT collision_end	; end if y > 14

; 3. check for sand collision
; Check for sand on board model at xy, and if collision, increment score
	MOV a1, a2			; Move x into a1
	MOV a2, a3			; Move y into a2
	BL get_sand_at_xy		; Get sand at current position
	; 1 if sand, 0 if nothing
	; so just return
	BAL collision_end

is_pooka_check
is_fygar_check
; Sprite is either Pooka or Fygar. Treat them same. #EQUALITY
; 1. Check for fatal collisions with pump
	LDR v8, =PUMP_SPRITE
	; Check if X Positions are equal
	LDR ip, [v8, #X_POS]		; Load its X POSITION
	CMP ip, a2			; Compare the X positions
	MOVEQ a1, #3			; set return value to 3 (FATAL) 
	BEQ collision_end

	; Check if Y Positions are equal
	LDR ip, [v8, #Y_POS]		; Load its Y POSITION
	CMP ip, a3			; Compare the Y positions
	MOVEQ a1, #3			; set return value to 3 (FATAL) 
	BEQ collision_end

; 2. Check for wall collision
	CMP a2, #0	; check
	MOVLT a1, #2
	BLT collision_end	; end if x < 0
	CMP a2, #18 ; check
	MOVGT a1, #2
	BGT collision_end	; end if x > 18

	CMP a3, #0	; check
	MOVLT a1, #2
	BLT collision_end	; end if y < 0
	CMP a3, #14 ; check
	MOVGT a1, #2
	BGT collision_end	; end if y > 14

; 3. check for sand collision
; Check for sand on board model at xy, and if collision, increment score
	MOV a1, a2			; Move x into a1
	MOV a2, a3			; Move y into a2
	BL get_sand_at_xy		; Get sand at current position
	; 1 if sand, 0 if nothing
	; so just return
	BAL collision_end

is_pump_check
; Sprite is pump. Only significant collision is with wall or sand
; 1. Check for fatal collisions
; 2. Check for wall collision
	CMP a2, #0	; check
	MOVLT a1, #2
	BLT collision_end	; end if x < 0
	CMP a2, #18 ; check
	MOVGT a1, #2
	BGT collision_end	; end if x > 18

	CMP a3, #0	; check
	MOVLT a1, #2
	BLT collision_end	; end if y < 0
	CMP a3, #14 ; check
	MOVGT a1, #2
	BGT collision_end	; end if y > 14

; 3. check for sand collision
	MOV a1, a2			; Move x into a1
	MOV a2, a3			; Move y into a2
	BL get_sand_at_xy		; Get sand at current position
	; 1 if sand, 0 if nothing
	; so just return
	BAL collision_end


collision_end
	LDMFD sp!, {lr, v1-v8}
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
		BL update_board
		LDR v1, =UPDATE_P
		MOV ip, #0
		STR ip, [v1]				; reset update flag
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
		LDR a2, [v1, #Y_POS]
		SUB a2, a2, #1
		MOV a4, #DIR_UP
		BAL	U0RDA_update

KEY_DOWN
		LDR a2, [v1, #Y_POS]
		ADD a2, a2, #1
		MOV a4, #DIR_DOWN	
		BAL	U0RDA_update

KEY_LEFT
		LDR a1, [v1, #X_POS]
		SUB a1, a1, #1
		MOV a4, #DIR_LEFT	
		BAL	U0RDA_update

KEY_RIGHT
		LDR a1, [v1, #X_POS]
		ADD a1, a1, #1
		MOV a4, #DIR_RIGHT	
		BAL	U0RDA_update
U0RDA_update
		LDR v2, =UPDATE_P
		LDRB ip, [v2]		
		CMP ip, #0		; if update board has not happened	 (update != 0)
		BNE U0RDA_end 	; skip current update
		BL update_sprite
		MOV ip, #1
		STRB ip, [v2]	; set update flag
U0RDA_end
		LDMFD SP!, {r0-r12, lr}   	; Restore registers r0-r12, lr	

FIQ_Exit
		LDMFD SP!, {r0-r12, lr}	  	; Restore registers r0-r12, lr	
		SUBS pc, lr, #4				; pc = lr - 4


	END
