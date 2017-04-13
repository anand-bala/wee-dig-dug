	AREA GUI, CODE, READWRITE
	
	IMPORT	DUG_LEFT
	
	IMPORT	BOARD_WIDTH
	IMPORT	BOARD_HEIGHT
	IMPORT	X_POS
	IMPORT	Y_POS	
	IMPORT	LIVES	
	IMPORT	DIRECTION
	IMPORT	OLD_X_POS
	IMPORT	OLD_Y_POS
	
	IMPORT	GAME_BOARD
	IMPORT	HIGH_SCORE
	IMPORT	LEVEL
	
	IMPORT	DUG_SPRITE
	IMPORT	FYGAR_SPRITE_1
	IMPORT	POOKA_SPRITE_1
	IMPORT	POOKA_SPRITE_2

	IMPORT	num_to_dec_str
	IMPORT	output_string

	EXPORT	update_board


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
ESC_cursor_pos_cmd	= "f"
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

	LDR v1, =DUG_SPRITE		; move dug sprite
	BL output_string

	LDMFD sp!, {lr, v1-v8}
	BX lr

	END