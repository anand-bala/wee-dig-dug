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

BOARD_WIDTH		EQU	19
BOARD_HEIGHT	EQU 15
BOARD_SIZE		EQU	19*15
BOARD_CENTER_X	EQU BOARD_WIDTH/2
BOARD_CENTER_Y	EQU BOARD_HEIGHT/2


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
	DCD	10			; x position
	DCD	7			; y position
	DCD	4			; lives
	DCD	DIR_LEFT   	; direction
	DCD	32			; Old X
	DCD 20			; Old Y

FYGAR_SPRITE_1		; State of 1st Fygar sprite
	DCD 1			; x position
	DCD 1			; y position
	DCD 1			; lives
	DCD	DIR_RIGHT	; direction
	DCD	32			; Old X
	DCD 20			; Old Y

POOKA_SPRITE_1		; State of 1st Pooka sprite
	DCD 10			; x position
	DCD 1			; y position
	DCD 1			; lives
	DCD	DIR_UP		; direction
	DCD	60			; Old X
	DCD 16			; Old Y

POOKA_SPRITE_2		; State of 2nd Pooka sprite
	DCD 15			; x position
	DCD 15			; y position
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


reset_model
	STMFD sp!, {lr, v1-v8}

	; Reset the board to initial state
	LDR v1, =GAME_BOARD
	MOV v2, #BOARD_SIZE
	MOV ip, #1
reset_board_loop
	STRB ip, [v1], #1	; Store 1 byte at current index on board and increment index (sand by default)
	SUBS v2, #1			; Decrement residual index (and set CPSR)
	BGT reset_board_loop ; Loop while index > 0

; Set Dug sprite to center with 4 lives	and looking left
	LDR v1, =DUG_SPRITE
	MOV a1, #BOARD_CENTER_X
	MOV a2, #BOARD_CENTER_Y
	MOV a3, #4
	MOV a4, #DIR_LEFT
	BL update_sprite

	
; Set Fygar1 to random position
	LDR v1, =FYGAR_SPRITE_1
	; Set random dir
	MOV a1, #2			; get random 4bit number for direction [0-3]
	BL get_nbit_rand
	MOV a4, a1			; move returned random number to a4
	; Set Number of lives = 1
	MOV a3, #1
	; set random Y in range [0-15]	 (4 bit)
	MOV a1, #4
	BL get_nbit_rand
	MOV a2, a1
	; set random X in range [0-19]	(5 bit with check)
	MOV a1, #5
	BL get_nbit_rand
	CMP a1, #20
	MOVGE a1, #19	
	; update sprite
	STMFD sp!, {a1, a2}	; save and restore x and y position
	BL update_sprite
	LDMFD sp!, {a1, a2}
	; Clear sand for Fygar1 movement
	LDR v1, =GAME_BOARD


; Set Pooka1 to random position
	LDR v1, =POOKA_SPRITE_1
	; Set random dir
	MOV a1, #2			; get random 4bit number for direction [0-3]
	BL get_nbit_rand
	MOV a4, a1			; move returned random number to a4
	; Set Number of lives = 1
	MOV a3, #1
	; set random Y in range [0-15]	 (4 bit)
	MOV a1, #4
	BL get_nbit_rand
	MOV a2, a1
	; set random X in range [0-19]	(5 bit with check)
	MOV a1, #5
	BL get_nbit_rand
	CMP a1, #20
	MOVGE a1, #19	
	; update sprite	
	STMFD sp!, {a1, a2}	; save and restore x and y position
	BL update_sprite
	LDMFD sp!, {a1, a2}

; Set Pooka2 to random position
	LDR v1, =POOKA_SPRITE_2
	; Set random dir
	MOV a1, #2			; get random 4bit number for direction [0-3]
	BL get_nbit_rand
	MOV a4, a1			; move returned random number to a4
	; Set Number of lives = 1
	MOV a3, #1
	; set random Y in range [0-15]	 (4 bit)
	MOV a1, #4
	BL get_nbit_rand
	MOV a2, a1
	; set random X in range [0-19]	(5 bit with check)
	MOV a1, #5
	BL get_nbit_rand
	CMP a1, #20
	MOVGE a1, #19	
	; update sprite
	STMFD sp!, {a1, a2}	; save and restore x and y position
	BL update_sprite
	LDMFD sp!, {a1, a2}
; Clear sand for sprite movement


	LDMFD sp!, {lr, v1-v8}
	BX lr


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

;
clear_sand_at_x_y  ; coordinate on array = y + (width*x)
	STMFD sp!, {lr, v1-v8}
	LDR v1, =GAME_BOARD
	MOV ip, #0
	ADD a2, a2, a1, LSL #BOARD_WIDTH
   	LDMFD	sp!, {lr, v1-v8}
	BX lr

	END