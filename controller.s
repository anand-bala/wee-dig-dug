	AREA controller, CODE, READWRITE
	EXPORT	weedigdug
	EXPORT	FIQ_Handler

	IMPORT	pin_connect_block_setup
	IMPORT	uart_init
	IMPORT	timer_init
	IMPORT	interrupt_init
	IMPORT	interrupt_disable

	IMPORT	read_timer0
	IMPORT	set_match0
	IMPORT	set_match1
	IMPORT	set_match2
	IMPORT	set_match3
	IMPORT	get_match0
	IMPORT	get_match1
	IMPORT	reset_timer0
	IMPORT	disable_timer0

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
	IMPORT	spawn_bullet
	IMPORT	just_update_bullet
	IMPORT	just_fygar_update
	IMPORT	toggle_pause_game
	IMPORT	init_model

	IMPORT	DUG_SPRITE
	IMPORT	FYGAR_SPRITE_1
	IMPORT	POOKA_SPRITE_1
	IMPORT	POOKA_SPRITE_2
	IMPORT	PUMP_SPRITE
	IMPORT	CURRENT_TIME

	IMPORT	BEGIN_GAME
	IMPORT	PAUSE_GAME
	IMPORT	GAME_OVER
	IMPORT	RUNNING_P

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

	EXPORT	ONE_SEC	
	EXPORT	HALF_SEC	
	EXPORT	TIMER_100ms	
	EXPORT	TIME_120s

	IMPORT	GAME_BEGIN_GUI
	IMPORT	GAME_CONTROLS_GUI
	
	IMPORT	set_level_disp
	IMPORT	div_and_mod
	IMPORT	disable_timer_interrupts
	IMPORT	set_random_seed

	EXPORT	RUN_P

	IMPORT	enemy_collision_with_sand_wall
	IMPORT	fatal_collision1_enemy
	IMPORT	fatal_collision2_enemy
	IMPORT	fatal_collision1_dug
	IMPORT	fatal_collision2_dug
	IMPORT	bullet_collision_with_sand_wall
	IMPORT	move_sprite_given_dir
	IMPORT	sand_collision_dug
	IMPORT	wall_collision_dug
	IMPORT	get_a_free_direction
	IMPORT	model_game_over

ONE_SEC		EQU 0x1194000
HALF_SEC	EQU	0x08CA000
TIMER_100ms	EQU	0x1C2000
TIME_120s	EQU	0x83D60000

begin_str	=	"Press any key to begin",12,13,0
RUN_P		=	0,0
EXIT_P		=	0,0
UPDATE_P	=	0,0
	ALIGN

weedigdug
	STMFD sp!, {lr}
	BL pin_connect_block_setup
	BL uart_init
	LDR a1, =0x83D60
	LDR a2, =0x1194
	BL div_and_mod
; Begin GAME
begin_game
	MOV a1, #12
	BL output_character
	LDR v1, =GAME_BEGIN_GUI
	BL output_string
	LDR v1, =GAME_CONTROLS_GUI
	BL output_string

 	BL interrupt_init
	BL timer_init
	BL read_character

	BL read_timer0
	BL set_random_seed
	BL init_model
	; Set MR1 to half sec and reset it
	LDR a1, =HALF_SEC
	MOV a2, #1
	BL set_match1

	; Set MR0 to update bullet and fygar every quarter sec
	LDR a1, =HALF_SEC
	LSR a1, a1, #1
	MOV a2, #0
	BL set_match0

	BL reset_timer0

	
	LDR v1, =RUNNING_P
	MOV a1, #1
	STRB a1, [v1]
game_run
	LDR v1, =GAME_OVER
game_loop
	LDRB a1, [v1]	; load GAME_OVER
	CMP a1, #0
	BEQ game_loop	; if GAME_OVER = 0: loop

	; Wait for user to restart game
	BL disable_timer0
	BL disable_timer_interrupts
	LDR v1, =BEGIN_GAME
game_over_end_loop
	LDRB ip, [v1]
	CMP ip, #0
	BEQ game_over_end_loop	; if game hasnt begun yet, wait

	BAL begin_game

	LDMFD sp!, {lr}
	BX lr

restart_game
	STMFD sp!, {lr, v1, v2}
	
	LDR v1, =GAME_OVER
	MOV v2, #0
	STRB v2, [v1]

	LDR v1, =BEGIN_GAME
	MOV v2, #1
	STRB v2, [v1]
	
	LDMFD sp!, {lr, v1, v2}
	BX lr


FIQ_Handler
		STMFD SP!, {r0-r12, lr}  	; Save registers r0-r12, lr
MR0_Interrupt
		LDR r0, =0xE0004000
		LDR r1, [r0]
		TST r1, #0x1	
		BEQ MR1_Interrupt

		STMFD SP!, {r0-r12, lr}   	; Save registers r0-r12, lr
		; MR1 interrupt

		LDR v1, =RUNNING_P
		LDRB ip, [v1]
		CMP ip, #0
		BEQ MR0_end
		BL just_fygar_update
		;BL just_update_bullet

		; Detect and handle collisions
		LDR v1, =FYGAR_SPRITE_1
		BL fatal_collision1_enemy
		BL fatal_collision2_enemy
 ;
;		LDR v1, =POOKA_SPRITE_1
;		BL fatal_collision1_enemy
;		BL fatal_collision2_enemy
 ;
;		LDR v1, =POOKA_SPRITE_2
;		BL fatal_collision1_enemy
;		BL fatal_collision2_enemy
 ;
		LDR v1, =PUMP_SPRITE
		BL bullet_collision_with_sand_wall

		LDR v1, =DUG_SPRITE
		BL fatal_collision1_dug
		BL fatal_collision2_dug
		BL update_board
MR0_end
		LDMFD SP!, {r0-r12, lr}   ; Restore registers r0-r12, lr

		ORR r1, r1, #1		; Clear Interrupt by OR-ing value from 0xE0004000 (r1) with #1
		STR r1, [r0]	   	; store clear value (r1) into 0xE0004000 (r0)

MR1_Interrupt
		LDR r0, =0xE0004000
		LDR r1, [r0]
		TST r1, #0x2	; test MR1 TODO: TEST MR0
		BEQ EINT1_interrupt

		STMFD SP!, {r0-r12, lr}   	; Save registers r0-r12, lr
		; MR1 interrupt

		LDR v1, =RUNNING_P
		LDRB ip, [v1]
		CMP ip, #0
		BEQ MR1_end
		BL update_model

		LDR v1, =CURRENT_TIME
		LDR v2, [v1]
		LSR v2, v2, #1
		BL get_match1
		SUB a1, v2, a1, LSR #1
		CMP a1, #0
		MOVLE a1, #0

		LSL a1, a1, #1
		STR a1, [v1]
		
		
MR1_end
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
		BL toggle_pause_game
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
		
		BL read_character
		MOV ip, a1			; hold character in ip

		LDR v1, =GAME_OVER
		LDRB a1, [v1]
		CMP a1, #0
		BEQ U0RDA_game_running

		CMP ip, #'R'
		CMPNE ip, #'r'
		BLEQ restart_game
		CMP ip, #'R'
		CMPNE ip, #'r'
		BEQ U0RDA_end

U0RDA_game_running
		LDR v1, =DUG_SPRITE
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

		CMP ip, #' '
		BEQ SPACEBAR_PRESS

		CMP ip, #10
		CMPNE ip, #13
		BEQ ENTER_PRESS

		BAL U0RDA_end
		; TODO: check for collisions
KEY_UP
		MOV a1, #0
		BAL	U0RDA_update

KEY_DOWN
		MOV a1, #1
		BAL	U0RDA_update

KEY_LEFT
		MOV a1, #2
		BAL	U0RDA_update

KEY_RIGHT
		MOV a1, #3
		BAL	U0RDA_update

ENTER_PRESS
	;	BL toggle_pause_game
		BAL U0RDA_end
SPACEBAR_PRESS
		BL spawn_bullet
		BAL U0RDA_end
U0RDA_update
		BL queue_movement_DUG
U0RDA_end
		LDMFD SP!, {r0-r12, lr}   	; Restore registers r0-r12, lr

FIQ_Exit
		LDMFD SP!, {r0-r12, lr}	  	; Restore registers r0-r12, lr
		SUBS pc, lr, #4				; pc = lr - 4


	END
