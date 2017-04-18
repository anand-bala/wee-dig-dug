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
	DCB	"ZZZZZZZZZZZZZZZZZZZZZ",13,10
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
	DCB	"ZZZZZZZZZZZZZZZZZZZZZ",13,10,0

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

	END
