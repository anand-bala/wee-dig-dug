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

	; GUI routines (EXPORT)
	EXPORT	update_board	


;;;;;;;;;;;;;;;;;;;;;
;	SPRITES		;
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

	ALIGN


;;;;;;;;;;;;;;;;;;;;;
;	CONSTANTS		;
;;;;;;;;;;;;;;;;;;;;;

DIR_UP		EQU	0
DIR_DOWN	EQU	1
DIR_LEFT	EQU	2
DIR_RIGHT	EQU	3

PIXEL_SIZE	EQU	4	; each pixel = 4x4

;;;;;;;;;;;;;;;;;;;;;;;;;
;	GUI MANIPULATION	;
;;;;;;;;;;;;;;;;;;;;;;;;;

ESC_cursor_position	= 27,"["
ESC_cursor_pos_line	= "000"
ESC_cursor_pos_sep	= ";"
ESC_cursor_pos_col	= "000"
ESC_cursor_pos_cmd	= "f",0
	ALIGN
;;;;;;;;;;;;;;;;;;;;;
;	SUBROUTINES		;
;;;;;;;;;;;;;;;;;;;;;

update_board
	STMFD sp!, {lr, v1-v8}

	LDR v2, =DUG_SPRITE
	
	; TODO: Write a clear block routine
	; Load X position and draw at position
	LDR v3, [v2, #X_POS]
	LSL a1, v3, #PIXEL_SIZE		; Adjust sprite to pixel size, a1 = argument to convert to string
	MOV	a2, #3					; 3 char wide string
	LDR v1, =ESC_cursor_pos_col
	BL num_to_dec_str

	; Load Y position and draw at position
	LDR v3, [v2, #Y_POS]
	LSL a1, v3, #PIXEL_SIZE		; Adjust sprite to pixel size, a1 = argument to convert to string
	MOV	a2, #3					; 3 char wide string
	LDR v1, =ESC_cursor_pos_line
	BL num_to_dec_str

	LDR v1, =ESC_cursor_position
	BL output_string

	LDR v1, =DUG_LEFT		; move dug sprite
	BL output_string

	LDMFD sp!, {lr, v1-v8}
	BX lr

	END
