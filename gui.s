	AREA GUI, CODE, READWRITE
	
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

	; Board data
	IMPORT	GAME_BOARD
	IMPORT	HIGH_SCORE
	IMPORT	LEVEL
	
	; Sprite Structures
	IMPORT	DUG_SPRITE
	IMPORT	FYGAR_SPRITE_1
	IMPORT	POOKA_SPRITE_1
	IMPORT	POOKA_SPRITE_2

	; Library subroutines
	IMPORT	num_to_dec_str
	IMPORT	output_string
	IMPORT	output_character

	; GUI routines (EXPORT)
	EXPORT	update_board
	EXPORT	draw_empty_board	


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

HIGH_SCORE_str	=	"HIGH SCORE: "
HIGH_SCORE_val	=	"000000",10,13,0

CURRENT_SCORE_str	=	"SCORE: "
CURRENT_SCORE_val	=	"000000",10,13,0

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
	STMFD sp!, {a1}		; save x coord
	BL get_sand_at_xy
	MOV ip, a1		; hold sand in ip
	LDMFD sp!, {a1}		; save y coord

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
	BGT populate_loop_x	; loop while x > 0
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
	LDR v1, =DUG_GUI
	LDRB a1, [v1]		; Load DUG GUI Character
	LDR v1, =DUG_SPRITE	; Load DUG Sprite
	BL draw_sprite		; draw DUG

populate_end
	LDMFD sp!, {lr, v1-v8}
	BX lr

update_board
	STMFD sp!, {lr, v1-v8}

	; v8 = sprite addresses

	LDR v8, =DUG_SPRITE

	; Load Old X position and clear at position
	LDR a1, [v8, #OLD_X_POS]
	ADD a1, a1, #GUI_X_ORIGIN
	MOV	a2, #3					; 3 char wide string
	LDR v1, =ESC_cursor_pos_col
	BL num_to_dec_str

	; Load Old Y position and clear at position
	LDR a1, [v8, #OLD_Y_POS]
	ADD a1, a1, #GUI_Y_ORIGIN
	MOV	a2, #3					; 3 char wide string
	LDR v1, =ESC_cursor_pos_line
	BL num_to_dec_str

	LDR v1, =ESC_cursor_position
	BL output_string
	
	MOV a1, #' '
	BL output_character
	
	; Load X position and draw at position
	LDR a1, [v8, #X_POS]
	ADD a1, a1, #GUI_X_ORIGIN
	MOV	a2, #3					; 3 char wide string
	LDR v1, =ESC_cursor_pos_col
	BL num_to_dec_str

	; Load Y position and draw at position
	LDR a1, [v8, #Y_POS]
	ADD a1, a1, #GUI_Y_ORIGIN
	MOV	a2, #3					; 3 char wide string
	LDR v1, =ESC_cursor_pos_line
	BL num_to_dec_str

	LDR v1, =ESC_cursor_position
	BL output_string
	
	LDR ip, [v8, #DIRECTION]	; get current direction Dug is facing
	LDR v1, =DUG_GUI 			; load address for Dug GUI
	LDRB a1, [v1, ip]		   	; load character for direction
	BL output_character

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
	MOV v4, a			; v4 = character

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

	LDMFD sp!, {lr, v1, v8}
	BX lr

	END
