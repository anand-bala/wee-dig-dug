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
	EXPORT	PUMP_SPRITE

	EXPORT	update_sprite
	EXPORT	clear_at_x_y
	EXPORT	reset_model

	IMPORT	get_nbit_rand

;;;;;;;;;;;;;;;;;;;;;
;	CONSTANTS		;
;;;;;;;;;;;;;;;;;;;;;

BOARD_WIDTH		EQU	19
BOARD_HEIGHT	EQU 15
BOARD_SIZE		EQU	19*15
BOARD_CENTER_X	EQU 9
BOARD_CENTER_Y	EQU 7


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

DUG_SPRITE		; State of the Dug sprite
	DCD 10			; x position
	DCD 7			; y position
	DCD 4			; lives
	DCD DIR_LEFT	   	; direction
	DCD 32			; Old X
	DCD 20			; Old Y

FYGAR_SPRITE_1		; State of 1st Fygar sprite
	DCD 1			; x position
	DCD 1			; y position
	DCD 1			; lives
	DCD DIR_RIGHT		; direction
	DCD 1			; Old X
	DCD 1			; Old Y

POOKA_SPRITE_1		; State of 1st Pooka sprite
	DCD 10			; x position
	DCD 1			; y position
	DCD 1			; lives
	DCD DIR_UP		; direction
	DCD 10			; Old X
	DCD 1			; Old Y

POOKA_SPRITE_2		; State of 2nd Pooka sprite
	DCD 15			; x position
	DCD 15			; y position
	DCD 1			; lives
	DCD DIR_DOWN		; direction
	DCD 15			; Old X
	DCD 15			; Old Y

PUMP_SPRITE		; State of the Pump sprite
	DCD 9			; x position
	DCD 7			; y position
	DCD 4			; lives
	DCD DIR_LEFT	   	; direction
	DCD 8			; Old X
	DCD 7			; Old Y


HIGH_SCORE	DCD 0
LEVEL		DCD 1

GAME_BOARD	FILL BOARD_SIZE, 0x01, 1	; Define a 2560 byte array with 1 byte 1s signifying sand
	ALIGN


;;;;;;;;;;;;;;;;;;;;;
;	SUBROUTINES		;
;;;;;;;;;;;;;;;;;;;;;


reset_model
	STMFD sp!, {lr, v1-v8}

	; Reset the board to initial state
	LDR v1, =GAME_BOARD
	LDR v2, =BOARD_SIZE
	MOV ip, #1

	; Loop to reinitialize the board.
	; Fill board with sand
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
	; Clear sand around Dug	(8,7),(9,7),(10,7)
	MOV a1, #8
	MOV a2, #7
	BL clear_at_x_y
	MOV a1, #9
	MOV a2, #7
	BL clear_at_x_y
	MOV a1, #10
	MOV a2, #7
	BL clear_at_x_y

	
; Set Fygar1 to random position
	LDR v1, =FYGAR_SPRITE_1
	
	; Set random dir
	MOV a1, #2			; get random 4bit number for direction [0-3]
	BL get_nbit_rand
	MOV a4, a1			; move returned random number to a4
	
	; Set Number of lives = 1
	MOV a3, #1
	
	; set random Y in range [0-14]	 (4 bit)
	MOV a1, #4
	BL get_nbit_rand
	CMP a1, #15
	MOVGE a1, #14
	MOV a2, a1
	
	; set random X in range [0-18]	(5 bit with check)
	MOV a1, #5
	BL get_nbit_rand
	CMP a1, #19
	MOVGE a1, #18
		
	; update sprite
	STMFD sp!, {a1, a2}	; save and restore x and y position
	BL update_sprite
	LDMFD sp!, {a1, a2}
	; Clear sand for Fygar1 movement  (x-1,y) (x,y) (x+1,y)

	; clear_at_x_y changes a1 and a2. Hence, saving x and y in v2, v3
	MOV v2, a1	; temporarily hold x
	MOV v3, a2	; temporarily hold y 
	
	SUB a1, v2, #1	; x-1
	MOV	a2, v3		; y
	BL clear_at_x_y
	MOV a1, v2 	   	; x
	MOV	a2, v3	   	; y
	BL clear_at_x_y
	ADD a1, v2, #1	; x+1
	MOV	a2, v3	   	; y
	BL clear_at_x_y


; Set Pooka1 to random position
	LDR v1, =POOKA_SPRITE_1
	; Set random dir
	MOV a1, #2			; get random 4bit number for direction [0-3]
	BL get_nbit_rand
	MOV a4, a1			; move returned random number to a4
	
	; Set Number of lives = 1
	MOV a3, #1
	
	; set random Y in range [0-14]	 (4 bit)
	MOV a1, #4
	BL get_nbit_rand
	CMP a1, #15
	MOVGE a1, #14
	MOV a2, a1
	
	; set random X in range [0-18]	(5 bit with check)
	MOV a1, #5
	BL get_nbit_rand
	CMP a1, #19
	MOVGE a1, #18
		
	; update sprite
	STMFD sp!, {a1, a2}	; save and restore x and y position
	BL update_sprite
	LDMFD sp!, {a1, a2}
	; Clear sand for Pooka1 movement  (x-1,y) (x,y) (x+1,y)

	; clear_at_x_y changes a1 and a2. Hence, saving x and y in v2, v3
	MOV v2, a1	; temporarily hold x
	MOV v3, a2	; temporarily hold y 
	
	SUB a1, v2, #1	; x-1
	MOV	a2, v3		; y
	BL clear_at_x_y
	MOV a1, v2 	   	; x
	MOV	a2, v3	   	; y
	BL clear_at_x_y
	ADD a1, v2, #1	; x+1
	MOV	a2, v3	   	; y
	BL clear_at_x_y


; Set Pooka2 to random position
	LDR v1, =POOKA_SPRITE_2
	; Set random dir
	MOV a1, #2			; get random 4bit number for direction [0-3]
	BL get_nbit_rand
	MOV a4, a1			; move returned random number to a4
	
	; Set Number of lives = 1
	MOV a3, #1
	
	; set random Y in range [0-14]	 (4 bit)
	MOV a1, #4
	BL get_nbit_rand
	CMP a1, #15
	MOVGE a1, #14
	MOV a2, a1
	
	; set random X in range [0-18]	(5 bit with check)
	MOV a1, #5
	BL get_nbit_rand
	CMP a1, #19
	MOVGE a1, #18
		
	; update sprite
	STMFD sp!, {a1, a2}	; save and restore x and y position
	BL update_sprite
	LDMFD sp!, {a1, a2}
	; Clear sand for Pooka2 movement  (x-1,y) (x,y) (x+1,y)

	; clear_at_x_y changes a1 and a2. Hence, saving x and y in v2, v3
	MOV v2, a1	; temporarily hold x
	MOV v3, a2	; temporarily hold y 
	
	SUB a1, v2, #1	; x-1
	MOV	a2, v3		; y
	BL clear_at_x_y
	MOV a1, v2 	   	; x
	MOV	a2, v3	   	; y
	BL clear_at_x_y
	ADD a1, v2, #1	; x+1
	MOV	a2, v3	   	; y
	BL clear_at_x_y

	LDMFD sp!, {lr, v1-v8}
	BX lr


; Update data for a sprite
; Inputs:
;			a1 = x position
;			a2 = y position
;			a3 = lives
;			a4 = direction
;			v1 = Address to sprite
; to not update direction and lives, set
update_sprite
	STMFD	sp!, {lr, v1-v2}


update_x
	CMP a1, #0
	BLT update_y
	CMP a1, #18
	BGT update_y
	CMP a1, #-1	; check whether to update x position or not
	; if != -1 (update = true):
	LDR v2, [v1, #X_POS]	; temporarily hold old x_pos
	STR v2, [v1, #OLD_X_POS]	; store old x position
   	STRNE a1, [v1, #X_POS]	; update X_POS value for given sprite

update_y
	CMP a2, #0
	BLT update_lives
	CMP a2, #14
	BGT update_lives
	CMP a2, #-1	; check whether to update y position or not
	; if != -1 (update = true):
	LDR v2, [v1, #Y_POS]	; temporarily hold old y_pos
	STR v2, [v1, #OLD_Y_POS]	; store old y position
   	STRNE a2, [v1, #Y_POS]	; update Y_POS value for given sprite

update_lives
	CMP a3, #-1	; check whether to update LIVES or not
	; if != -1 (update = true):
   	STRNE a3, [v1, #LIVES]	; update LIVES value for given sprite
update_dir
	CMP a4, #-1	; check whether to update DIRECTION or not
	; if != -1 (update = true):
   	STRNE a4, [v1, #DIRECTION]	; update DIRECTION value for given sprite

	LDMFD	sp!, {lr, v1-v2}
	BX lr

; Clear sand from model at x,y
; a1 = x
; a2 = y
clear_at_x_y  ; coordinate on array = x + (width*y)
	STMFD sp!, {lr, v1}
	
	CMP a1, #0	; check
	BLT cxy_end	; end if x < 0
	CMP a1, #18 ; check
	BGT cxy_end	; end if x > 18

	CMP a2, #0	; check
	BLT cxy_end	; end if y < 0
	CMP a2, #14 ; check
	BGT cxy_end	; end if y > 14

	LDR v1, =GAME_BOARD

	; Multiply y by width = 19
	; y = y*16 + y*2 + y
	ADD ip, a2, a2, LSL #1	; ip = y + 2*y
	ADD a2, ip, a2, LSL #4	; y = 16*y + ip
	
	; coordinate on array = x + y (y is new y)
	ADD ip, a1, a2 	; use ip as offset into gameboard array
	MOV a1, #0		; use a1 to hold 0 = no sand
	STRB a1, [v1, ip]	; store 0 at x+(width*y)
cxy_end
	LDMFD	sp!, {lr, v1}
	BX lr


; Check if sand is present at xy
; Input:
;	a1 = x
;	a2 = y
; Output
;	a1 = 0 or 1 (true or false)
get_sand_at_xy
	STMFD sp!, {lr, v1-v8}

	; If out of bounds, return 0

	CMP a1, #0	; check
	MOVLT a1, #0
	BLT get_xy_end	; end if x < 0
	CMP a1, #18 ; check
	MOVGT a1, #0
	BGT get_xy_end	; end if x > 18

	CMP a2, #0	; check
	MOVLT a1, #0
	BLT get_xy_end	; end if y < 0
	CMP a2, #14 ; check
	MOVGT a1, #0
	BGT get_xy_end	; end if y > 14

	LDR v1, =GAME_BOARD

	; Offset into board = x + (y * width)

	; Multiply y by width = 19
	; y = y*16 + y*2 + y
	ADD ip, a2, a2, LSL #1	; ip = y + 2*y
	ADD a2, ip, a2, LSL #4	; y = 16*y + ip
	
	; coordinate on array = x + y (y is new y)
	ADD ip, a1, a2 	; use ip as offset into gameboard array
	LDRB a1, [v1, ip]	; store 0 at x+(width*y)
get_xy_end	
	LDMFD sp!, {lr, v1-v8}
	BX lr

	END
