	AREA MODEL, CODE, READWRITE
	
	EXPORT	BOARD_WIDTH
	EXPORT	BOARD_HEIGHT
	EXPORT	X_POS
	EXPORT	Y_POS	
	EXPORT	LIVES	
	EXPORT	DIRECTION
	EXPORT	OLD_X_POS
	EXPORT	OLD_Y_POS
	EXPORT	DIR_UP
	EXPORT	DIR_DOWN
	EXPORT	DIR_LEFT
	EXPORT	DIR_RIGHT
	
	EXPORT	GAME_BOARD
	EXPORT	HIGH_SCORE
	EXPORT	LEVEL
	
	EXPORT	DUG_SPRITE
	EXPORT	FYGAR_SPRITE_1
	EXPORT	POOKA_SPRITE_1
	EXPORT	POOKA_SPRITE_2

	EXPORT	update_sprite

;;;;;;;;;;;;;;;;;;;;;
;	CONSTANTS		;
;;;;;;;;;;;;;;;;;;;;;

BOARD_WIDTH		EQU	64
BOARD_HEIGHT	EQU 64
BOARD_BYTE_SIZE	EQU	2560

X_POS		EQU	0*4
Y_POS		EQU	1*4
LIVES		EQU	2*4
DIRECTION	EQU 3*4
OLD_X_POS	EQU 4*4
OLD_Y_POS	EQU	5*4

DIR_UP		EQU	0
DIR_DOWN	EQU	1
DIR_LEFT	EQU	2
DIR_RIGHT	EQU	3

;;;;;;;;;;;;;;;;;;;;;
;	GAME STATE		;
;;;;;;;;;;;;;;;;;;;;;

DUG_SPRITE			; State of the Dug sprite
	DCD	32			; x position
	DCD	20			; y position
	DCD	4			; lives
	DCD	DIR_LEFT   	; direction
	DCD	32			; Old X
	DCD 20			; Old Y

FYGAR_SPRITE_1		; State of 1st Fygar sprite
	DCD 16			; x position
	DCD 16			; y position
	DCD 1			; lives
	DCD	DIR_RIGHT	; direction
	DCD	32			; Old X
	DCD 20			; Old Y

POOKA_SPRITE_1		; State of 1st Pooka sprite
	DCD 60			; x position
	DCD 16			; y position
	DCD 1			; lives
	DCD	DIR_UP		; direction
	DCD	60			; Old X
	DCD 16			; Old Y

POOKA_SPRITE_2		; State of 2nd Pooka sprite
	DCD 16			; x position
	DCD 36			; y position
	DCD 1			; lives
	DCD	DIR_DOWN	; direction
	DCD	16			; Old X
	DCD 36			; Old Y

HIGH_SCORE	DCD	0
LEVEL		DCD 1

GAME_BOARD	FILL	2560, 0x01, 1	; Define a 2560 byte array with 1 byte 1s signifying sand
	ALIGN


;;;;;;;;;;;;;;;;;;;;;
;	SUBROUTINES		;
;;;;;;;;;;;;;;;;;;;;;


; Update data for a sprite
; Inputs:
;			a1 = x position
;			a2 = y position
;			a3 = lives
;			a4 = direction
;			v1 = Address to sprite
; To not update at all, pass -1
update_sprite
	STMFD	sp!, {lr, v1-v8}

	CMP a1, #-1	; check whether to update x position or not
	; if != -1 (update = true):
	LDRNE v2, [v1, #X_POS]	; temporarily hold old x_pos
	STRNE v2, [v1, #OLD_X_POS]	; store old x position
   	STRNE a1, [v1, #X_POS]	; update X_POS value for given sprite

	CMP a2, #-1	; check whether to update y position or not
	; if != -1 (update = true):
	LDRNE v2, [v1, #Y_POS]	; temporarily hold old y_pos
	STRNE v2, [v1, #OLD_Y_POS]	; store old y position
   	STRNE a2, [v1, #Y_POS]	; update Y_POS value for given sprite


	CMP a3, #-1	; check whether to update LIVES or not
	; if != -1 (update = true):
   	STRNE a2, [v1, #LIVES]	; update LIVES value for given sprite
	
	CMP a4, #-1	; check whether to update DIRECTION or not
	; if != -1 (update = true):
   	STRNE a2, [v1, #DIRECTION]	; update DIRECTION value for given sprite

	LDMFD	sp!, {lr, v1-v8}
	BX lr

	END