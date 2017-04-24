	AREA GUI, CODE, READWRITE
	
	EXPORT Game_over_gui
	; Information about board	
	IMPORT	BOARD_WIDTH
	IMPORT	BOARD_HEIGHT

	; Constants to access Sprite Structure
	IMPORT	X_POS
	IMPORT	Y_POS	
	IMPORT	LIVES	
	IMPORT	DIRECTION
	IMPORT	OLD_X_POS
	IMPORT	OLD_Y_POS

	; Other Constants
	IMPORT	DIR_UP
	IMPORT	DIR_DOWN
	IMPORT	DIR_LEFT
	IMPORT	DIR_RIGHT

	IMPORT	ONE_SEC	
	IMPORT	HALF_SEC	
	IMPORT	TIMER_100ms	
	IMPORT	TIME_120s

	; Board data
	IMPORT	GAME_BOARD
	IMPORT	HIGH_SCORE
	IMPORT	LEVEL
	IMPORT	CURRENT_SCORE
	IMPORT	CURRENT_TIME

	IMPORT	BEGIN_GAME
	IMPORT	PAUSE_GAME
	IMPORT	GAME_OVER
	IMPORT	RUNNING_P
	
	; Sprite Structures
	IMPORT	DUG_SPRITE
	IMPORT	FYGAR_SPRITE_1
	IMPORT	POOKA_SPRITE_1
	IMPORT	POOKA_SPRITE_2
	IMPORT	PUMP_SPRITE

	; Library subroutines
	IMPORT	num_to_dec_str
	IMPORT	output_string
	IMPORT	output_character
	IMPORT	div_and_mod

	; GUI routines (EXPORT)
	EXPORT	update_board
	EXPORT	draw_empty_board
	EXPORT	populate_board
	EXPORT	clear_sprite

	; GUI Data (EXPORT to model)
	EXPORT	PUMP_GUI
	EXPORT	DUG_GUI
	EXPORT	FYGAR_GUI
	EXPORT	POOKA_GUI
	EXPORT	GAME_BEGIN_GUI
	EXPORT	GAME_END_GUI
	
	; Model routines
	IMPORT	get_sand_at_xy
	
	EXPORT	debug_print1
	EXPORT	debug_print2	


;;;;;;;;;;;;;;;;;;;;;
;	GUI ELEMENTS	;
;;;;;;;;;;;;;;;;;;;;;

PUMP_GUI
	DCB	"|"	; UP
	DCB	"|"	; DOWN
	DCB	"-"	; LEFT
	DCB	"-"	; RIGHT

DUG_GUI
	DCB	"^"	; Face UP
	DCB	"v"	; Face DOWN
	DCB	"<"	; Face LEFT
	DCB	">"	; Face RIGHT

FYGAR_GUI
	DCB	"X"

POOKA_GUI
	DCB	"O"

SAND_GUI
	DCB	"#"

TIME_str	= 27,"[6;25fTIME: "
TIME_val	= "000",10,13,0

LEVEL_str	= 27,"[7;25fLEVEL:"
LEVEL_val	= "000",10,13,0

LIVES_str	= 27,"[8;25fLIVES:"
LIVES_val	= "0",10,13,0

BOARD_GUI
	DCB "ZZZZZZZZZZZZZZZZZZZZZ",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "Z                   Z",13,10
	DCB "ZZZZZZZZZZZZZZZZZZZZZ",13,10,0

HIGH_SCORE_str	=	27,"[20;0fHIGH SCORE: "
HIGH_SCORE_val	=	"000000",10,13,0

CURRENT_SCORE_str	=	27,"[19;6fSCORE: "
CURRENT_SCORE_val	=	"000000",10,13,0

DEBUG1_str	=	27,"[21;0fDEBUG1: "
DEBUG1_val	=	"000000",10,13,0

DEBUG2_str	=	27,"[22;0fDEBUG2: "
DEBUG2_val1	=	"000000, "
DEBUG2_val2	=	"000000",10,13,0

GAME_BEGIN_GUI
	DCB "|------------------------------------------------------------------|",13,10
	DCB "|Welcome to Wee Dig Dug.                                           |",13,10
	DCB "|Written by Ananad Bal and Amrit Pal Singh                         |",13,10
	DCB "|You have 4 lives. Use em wisely!!                                 |",13,10
	DCB "|You will start in the center.                                     |",13,10
	DCB "|Game level increases once all enemies are eleminated.             |",13,10
	DCB "|Press spacebar to shoot bullets. They CANNOT travel through dirt!.|",13,10
	DCB "|Z: Unbreakable Walls                                              |",13,10
	DCB "|#: dirt                                                           |",13,10
	DCB "|>: Player (facing right)                                          |",13,10
	DCB "|x: Small Enemy                                                    |",13,10
	DCB "|B: Big Enemy                                                      |",13,10
	DCB "|Press any key to Begin.                                           |",13,10
	DCB "|------------------------------------------------------------------|",13,10,0

GAME_END_GUI
	DCB "|-----------------------------------------|",13,10
	DCB "|You have DIED!                           |",13,10
	DCB "|Press R to retry.                        |",13,10
	DCB "|Press Q to quit and go back to your life.|",13,10
	DCB "|-----------------------------------------|",13,10,0

	ALIGN

;;;;;;;;;;;;;;;;;;;;;
;	CONSTANTS		;
;;;;;;;;;;;;;;;;;;;;;

PIXEL_SIZE	EQU	1
GUI_Y_ORIGIN	EQU	2
GUI_X_ORIGIN	EQU	2

;;;;;;;;;;;;;;;;;;;;;;;;;
;	GUI MANIPULATION	;
;;;;;;;;;;;;;;;;;;;;;;;;;

ESC_cursor_origin	= 27,"[0;0f",0
ESC_cursor_position	= 27,"["
ESC_cursor_pos_line	= "000"
ESC_cursor_pos_sep	= ";"
ESC_cursor_pos_col	= "000"
ESC_cursor_pos_cmd	= "f",0
ESC_hide_cursor		= 27,"[?25l",0
ESC_show_cursor		= 27,"[?25h",0
	ALIGN
;;;;;;;;;;;;;;;;;;;;;
;	SUBROUTINES		;
;;;;;;;;;;;;;;;;;;;;;

draw_empty_board
	STMFD sp!, {lr, v1-v8}
	MOV r0, #12
	BL output_character
	LDR v1, =ESC_hide_cursor
	BL output_string
	LDR v1, =ESC_cursor_origin
	BL output_string
	LDR v1, =BOARD_GUI
	BL output_string
	LDR v1, =CURRENT_SCORE_str
	BL output_string
	LDR v1, =HIGH_SCORE_str
	BL output_string
	LDR v1, =TIME_str
	BL output_string
	LDR v1, =LEVEL_str
	BL output_string

	LDMFD sp!, {lr, v1-v8}
	BX lr

populate_board
	STMFD sp!, {lr, v1-v8}

; loop through game board model and populate board with sand
	LDR v1, =SAND_GUI
	LDRB a3, [v1]	; Load sand character on a3
	MOV a1, #18	; a1 = max x coordinate
	MOV a2, #14	; a1 = max y coordinate

populate_loop_x
populate_loop_y
	STMFD sp!, {a1, a2}		; save x coord
	BL get_sand_at_xy
	MOV ip, a1		; hold sand in ip
	LDMFD sp!, {a1, a2}		; save y coord

	CMP ip, #1		; check if sand
	BNE skip_populate	; skip populate if no sand

	STMFD sp!, {a1-a3}
	BL draw_char_at_xy
	LDMFD sp!, {a1-a3}
skip_populate
	SUBS a2, a2, #1		; decrement y coordinate
	MOVEQ a2, #14		; reset y to 14 for inner loop
	BGT populate_loop_y	; if > 0, do inner loop
	; end inner loop
	SUBS a1, a1, #1		; decrement x coordinate
	BGE populate_loop_x	; loop while x > 0
	; end outer loop
populate_end_loop


; Now draw FYGAR and POOKAs
	; Drawing FYGAR
	LDR v1, =FYGAR_GUI
	LDRB a1, [v1]		; Load FYGAR GUI Character
	LDR v1, =FYGAR_SPRITE_1	; Load Fygar data
	BL draw_sprite		; draw FYGAR

	LDR v1, =POOKA_GUI
	LDRB a1, [v1]		; load Pooka GUI
	LDR v1, =POOKA_SPRITE_1	; Load POOKA1 data
	BL draw_sprite		; draw POOKA1

	LDR v1, =POOKA_GUI
	LDRB a1, [v1]		; load Pooka GUI
	LDR v1, =POOKA_SPRITE_2	; Load POOKA2 data
	BL draw_sprite		; draw POOKA2

; Now draw DUG

	LDR v1, =DUG_SPRITE	; Load DUG Sprite
	LDR ip, [v1, #DIRECTION]
	LDR v2, =DUG_GUI
	LDRB a1, [v2, ip]		; Load DUG GUI Character
	BL draw_sprite		; draw DUG

populate_end
	LDMFD sp!, {lr, v1-v8}
	BX lr


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Update board GUI
; Does the following, in the following order:
;	1. Draw Enemies
;	2. Draw Bullets
;	3. Draw Dug
;	4. Show highscore and score
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
update_board
	STMFD sp!, {lr, v1-v8}

	LDR v1, =GAME_OVER
	LDRB v2, [v1]
	CMP v2, #0
	BLNE Game_over_gui
	CMP v2, #0
	BNE gui_update_end

; 1. Draw Enemies
; -- 1.1. Draw Fygar
	LDR v1, =FYGAR_GUI
	LDRB a1, [v1]
	LDR v1, =FYGAR_SPRITE_1
	BL draw_sprite
; -- 1.2. Draw Pooka 1
	LDR v1, =POOKA_GUI
	LDRB a1, [v1]
	LDR v1, =POOKA_SPRITE_1
	BL draw_sprite
; -- 1.3. Draw Pooka 2
	LDR v1, =POOKA_GUI
	LDRB a1, [v1]
	LDR v1, =POOKA_SPRITE_2
	BL draw_sprite

; 2. Draw Bullet
	LDR v1, =PUMP_SPRITE
	LDR v2, =PUMP_GUI
	LDR ip, [v1, #DIRECTION]
	LDR a1, [v2, ip]
	BL draw_sprite
; 3. Draw Dug
	LDR v1, =DUG_SPRITE
	LDR v2, =DUG_GUI
	LDR ip, [v1, #DIRECTION]
	LDR a1, [v2, ip]
	BL draw_sprite

; 4. Show Scores
	LDR v1, =CURRENT_SCORE
	LDR a1, [v1]
	MOV a2, #6
	LDR v1, =CURRENT_SCORE_val
	BL num_to_dec_str

	LDR v1, =CURRENT_SCORE_str
	BL output_string

	LDR v1, =HIGH_SCORE
	LDR a1, [v1]
	MOV a2, #6
	LDR v1, =HIGH_SCORE_val
	BL num_to_dec_str

	LDR v1, =HIGH_SCORE_str
	BL output_string
; Show time and level
	LDR v1, =LEVEL
	LDR a1, [v1]
	MOV a2, #3
	LDR v1, =LEVEL_val
	BL num_to_dec_str

	LDR v1, =LEVEL_str
	BL output_string

	LDR v1, =DUG_SPRITE
	LDR a1, [v1, #LIVES]
	MOV a2, #1
	LDR v1, =LIVES_val
	BL num_to_dec_str

	LDR v1, =LIVES_str
	BL output_string

	LDR v1, =CURRENT_TIME
	LDR a1, [v1]
	LDR a2, =ONE_SEC
	BL div_and_mod
	MOV a2, #3
	LDR v1, =TIME_val
	BL num_to_dec_str

	LDR v1, =TIME_str
	BL output_string
gui_update_end	
	LDMFD sp!, {lr, v1-v8}
	BX lr

; Draw character at xy
; Draw any character on the GUI Board
; input:
;	a1 = x
;	a2 = y
;	a3 = character
draw_char_at_xy
	STMFD sp!, {lr, v1-v4}

	ADD v2, a1, #GUI_X_ORIGIN	; v2 = x + GUI Offset
	ADD v3, a2, #GUI_Y_ORIGIN	; v3 = y + GUI Offset
	MOV v4, a3			; v4 = character

	; Convert x
	MOV a1, v2
	MOV a2, #3
	LDR v1, =ESC_cursor_pos_col
	BL num_to_dec_str

	; Convert y
	MOV a1, v3
	MOV a2, #3
	LDR v1, =ESC_cursor_pos_line
	BL num_to_dec_str

	LDR v1, =ESC_cursor_position
	BL output_string

	; print character
	MOV a1, v4
	BL output_character

	LDMFD sp!, {lr, v1-v4}
	BX lr


; Draw a sprite
; This routine draws a sprite based on it's data
; input:
;	v1 = Address to Sprite structure
;	a1 = Character to represent sprite
draw_sprite
	STMFD sp!, {lr, v1, v8}

	LDR ip, [v1, #LIVES]
	CMP ip, #0			; check if sprite is dead (why would you draw a zombie?????)
	BEQ draw_sprite_end
	
	MOV ip, a1		; store character in ip
	MOV v8, v1		; store sprite address in v8

	; Load Old X position and clear at position
	LDR a1, [v8, #OLD_X_POS]
	ADD a1, a1, #GUI_X_ORIGIN
	MOV a2, #3			; 3 char wide string
	LDR v1, =ESC_cursor_pos_col
	BL num_to_dec_str

	; Load Old Y position and clear at position
	LDR a1, [v8, #OLD_Y_POS]
	ADD a1, a1, #GUI_Y_ORIGIN
	MOV a2, #3			; 3 char wide string
	LDR v1, =ESC_cursor_pos_line
	BL num_to_dec_str

	LDR v1, =ESC_cursor_position
	BL output_string
	
	MOV a1, #' '
	BL output_character
	
	; Load X position and draw at position
	LDR a1, [v8, #X_POS]
	ADD a1, a1, #GUI_X_ORIGIN
	MOV a2, #3			; 3 char wide string
	LDR v1, =ESC_cursor_pos_col
	BL num_to_dec_str

	; Load Y position and draw at position
	LDR a1, [v8, #Y_POS]
	ADD a1, a1, #GUI_Y_ORIGIN
	MOV a2, #3			; 3 char wide string
	LDR v1, =ESC_cursor_pos_line
	BL num_to_dec_str

	LDR v1, =ESC_cursor_position
	BL output_string
	
	MOV a1, ip		; Move character back to a1
	BL output_character
draw_sprite_end
	LDMFD sp!, {lr, v1, v8}
	BX lr

;;;;;;;;;;;;;;;;;;;;;;;;
; CLEAR SPRITE
;;;;;;;;;;;;;;;;;;;;;;;;
clear_sprite
	STMFD sp!, {lr, v1}
	; v1 = sprite to clear
	;LDR a1, [v1, #X_POS]
	;LDR a2, [v1, #Y_POS]
	;MOV a3, #' '
	;BL draw_char_at_xy

	LDR a1, [v1, #OLD_X_POS]
	LDR a2, [v1, #OLD_Y_POS]
	MOV a3, #' '
	BL draw_char_at_xy

	LDMFD sp!, {lr, v1}
	BX lr

debug_print1
	STMFD sp!, {lr, v1}
	LDR v1, =DEBUG1_val
	MOV a2, #6
	BL num_to_dec_str

	LDR v1, =DEBUG1_str
	BL output_string
	LDMFD sp!, {lr, v1}
	BX lr
debug_print2
	STMFD sp!, {lr, v1}
	MOV ip, a2
	LDR v1, =DEBUG2_val1
	MOV a2, #6
	BL num_to_dec_str

	LDR v1, =DEBUG2_val2
	MOV a1, ip
	MOV a2, #6
	BL num_to_dec_str

	LDR v1, =DEBUG2_str
	BL output_string
	LDMFD sp!, {lr, v1}
	BX lr

Game_over_gui
	STMFD sp!, {lr, v1,a1}
	MOV a1, #12
	BL output_character
	LDR v1, =GAME_END_GUI
	BL output_string
	LDMFD sp!, {lr, v1,a1}
	BX lr

	END
