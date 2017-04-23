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
	IMPORT update_peripherals
	EXPORT	GAME_BOARD
	EXPORT	HIGH_SCORE
	EXPORT	LEVEL
	EXPORT	CURRENT_SCORE
	EXPORT	CURRENT_TIME

	EXPORT	BEGIN_GAME
	EXPORT	PAUSE_GAME
	EXPORT	GAME_OVER
	EXPORT	RUNNING_P
 
	
	EXPORT	DUG_SPRITE
	EXPORT	FYGAR_SPRITE_1
	EXPORT	POOKA_SPRITE_1
	EXPORT	POOKA_SPRITE_2
	EXPORT	PUMP_SPRITE

	EXPORT	update_sprite
	EXPORT	clear_at_x_y
	EXPORT	reset_model
	EXPORT	get_sand_at_xy
	EXPORT	update_model
	EXPORT	queue_movement_DUG
	EXPORT	spawn_bullet
	EXPORT	just_update_bullet
	EXPORT	just_fygar_update
	EXPORT	toggle_pause_game
	EXPORT	init_model
	EXPORT	handle_and_detect_all

	IMPORT Game_over_gui
	IMPORT	get_nbit_rand

	IMPORT	draw_empty_board
	IMPORT	populate_board
	IMPORT	update_board
	IMPORT	clear_sprite

;;;;;;;;;;;;;;;;;;;;;
;	CONSTANTS		;
;;;;;;;;;;;;;;;;;;;;;

BOARD_WIDTH	EQU 19
BOARD_HEIGHT	EQU 15
BOARD_SIZE	EQU 19*15
BOARD_CENTER_X	EQU 9
BOARD_CENTER_Y	EQU 7


X_POS		EQU 0*4
Y_POS		EQU 1*4
LIVES		EQU 2*4
DIRECTION	EQU 3*4
OLD_X_POS	EQU 4*4
OLD_Y_POS	EQU 5*4
ORIGINAL_X	EQU 6*4
ORIGINAL_Y	EQU 7*4

DIR_UP		EQU 0
DIR_DOWN	EQU 1
DIR_LEFT	EQU 2
DIR_RIGHT	EQU 3

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
	DCD 9			; Original X
	DCD 7			; Original Y

FYGAR_SPRITE_1		; State of 1st Fygar sprite
	DCD 1			; x position
	DCD 1			; y position
	DCD 1			; lives
	DCD DIR_RIGHT		; direction
	DCD 1			; Old X
	DCD 1			; Old Y
	DCD 9			; Original X
	DCD 7			; Original Y

POOKA_SPRITE_1		; State of 1st Pooka sprite
	DCD 10			; x position
	DCD 1			; y position
	DCD 1			; lives
	DCD DIR_UP		; direction
	DCD 10			; Old X
	DCD 1			; Old Y
	DCD 9			; Original X
	DCD 7			; Original Y

POOKA_SPRITE_2		; State of 2nd Pooka sprite
	DCD 15			; x position
	DCD 15			; y position
	DCD 1			; lives
	DCD DIR_DOWN		; direction
	DCD 15			; Old X
	DCD 15			; Old Y
	DCD 9			; Original X
	DCD 7			; Original Y

PUMP_SPRITE		; State of the Pump sprite
	DCD 100			; x position
	DCD 100			; y position
	DCD 0			; lives
	DCD DIR_LEFT	   	; direction
	DCD 100			; Old X
	DCD 100			; Old Y
	DCD 100			; Original X
	DCD 100			; Original Y


HIGH_SCORE	DCD 0
LEVEL		DCD 1
CURRENT_SCORE	DCD 0
CURRENT_TIME	DCD 0
NUMBER_OF_ENEMIES	DCD 3


GAME_BOARD	FILL BOARD_SIZE, 0x00, 1	; Define a 2560 byte array with 1 byte 1s signifying sand
BEGIN_GAME	= 0,0	; Boolean to start game
PAUSE_GAME	= 0,0	; Boolean to pause game
GAME_OVER	= 0,0	; Boolean for game over
RUNNING_P	= 0,0	; Boolean to seee if game is running
	ALIGN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fields to help synchronization of movement ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UPDATE_DUG_P	DCB	0,0
	ALIGN
DIR_TO_MOVE_DUG	DCD	DIR_LEFT

;;;;;;;;;;;;;;;;;;;;;
;	SUBROUTINES		;
;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;
; INIT MODEL ;
;;;;;;;;;;;;;;

init_model
	STMFD sp!, {lr, v1-v8}
	MOV a1, #0
	LDR v1, =CURRENT_SCORE
	STR a1, [v1]
	LDR v1, =LEVEL
	MOV a1, #1
	STR a1, [v1]
	BL reset_model
	LDMFD sp!, {lr, v1-v8}
	BX lr
	

;;;;;;;;;;;;;;;
; RESET MODEL :
;;;;;;;;;;;;;;;
reset_model
	STMFD sp!, {lr, v1-v8}

	; Reset the board to initial state
	LDR v1, =GAME_BOARD	; load Game Board address
	ADD v1, v1, #38		; Dont fill first two rows
	LDR v2, =BOARD_SIZE	; Load board size into v2
	SUB v2, v2, #38		; dont count first two rows
	MOV ip, #1		; ip = sand

	; Loop to reinitialize the board.
	; Fill board with sand
reset_board_loop
	STRB ip, [v1], #1	; Store 1 byte at current index on board and increment index (sand by default)
	SUBS v2, #1			; Decrement residual index (and set CPSR)
	BGT reset_board_loop ; Loop while index > 0

; Set Dug sprite to center with 4 lives	and looking left
	LDR v1, =DUG_SPRITE
	MOV a1, #BOARD_CENTER_X
	STR a1, [v1, #ORIGINAL_X]
	STR a1, [v1, #OLD_X_POS]
	STR a1, [v1, #X_POS]
	MOV a2, #BOARD_CENTER_Y
	STR a2, [v1, #ORIGINAL_Y]
	STR a2, [v1, #OLD_Y_POS]
	STR a2, [v1, #Y_POS]
	MOV a3, #4
	STR a3, [v1, #LIVES]
	MOV a4, #DIR_LEFT
	STR a4, [v1, #DIRECTION]

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
	STR a1, [v1, #DIRECTION]	; update direction

	; Set Number of lives = 1
	MOV a1, #1
	STR a1, [v1, #LIVES]		; update lives

	; set random Y in range [0-14]	 (4 bit)
	MOV a1, #4
	BL get_nbit_rand
	CMP a1, #2
	MOVLT a1, #2
	CMP a1, #15
	MOVGE a1, #14
	STR a1, [v1, #Y_POS]		; update Y pos
	STR a1, [v1, #OLD_Y_POS]	; update old Y pos
	STR a1, [v1, #ORIGINAL_Y]	; set original Y
	MOV a2, a1
	
	; set random X in range [0-18]	(5 bit with check)
	MOV a1, #5
	BL get_nbit_rand
	CMP a1, #2
	MOVLT a1, #3
	CMP a1, #15
	MOVGT a1, #15
	STR a1, [v1, #X_POS]		; update X pos
	STR a1, [v1, #OLD_X_POS]	; update old X pos
	STR a1, [v1, #ORIGINAL_X]	; set original X

		
	; Clear sand for Fygar1 movement  
	;	(x-2,y)	(x-1,y)	(x,y)	(x+1,y)	(x+2,y)

	; clear_at_x_y changes a1 and a2. Hence, saving x and y in v2, v3
	MOV v2, a1	; temporarily hold x
	MOV v3, a2	; temporarily hold y 

	SUB a1, v2, #2	; x-2
	MOV	a2, v3		; y
	BL clear_at_x_y
	SUB a1, v2, #1	; x-1
	MOV	a2, v3		; y
	BL clear_at_x_y
	MOV a1, v2 	   	; x
	MOV	a2, v3	   	; y
	BL clear_at_x_y
	ADD a1, v2, #1	; x+1
	MOV	a2, v3	   	; y
	BL clear_at_x_y
	ADD a1, v2, #2	; x+2
	MOV	a2, v3	   	; y
	BL clear_at_x_y


; Set Pooka1 to random position
	LDR v1, =POOKA_SPRITE_1
	; Set random dir
	MOV a1, #2			; get random 4bit number for direction [0-3]
	BL get_nbit_rand
	STR a1, [v1, #DIRECTION]	; update direction

	; Set Number of lives = 1
	MOV a1, #1
	STR a1, [v1, #LIVES]		; update lives

	; set random Y in range [0-14]	 (4 bit)
	MOV a1, #4
	BL get_nbit_rand
	CMP a1, #15
	MOVGE a1, #14
	STR a1, [v1, #Y_POS]		; update Y pos
	STR a1, [v1, #OLD_Y_POS]	; update old Y pos
	STR a1, [v1, #ORIGINAL_Y]	; set original Y
	MOV a2, a1
	
	; set random X in range [0-18]	(5 bit with check)
	MOV a1, #5
	BL get_nbit_rand
	CMP a1, #19
	MOVGE a1, #18
	STR a1, [v1, #X_POS]		; update X pos
	STR a1, [v1, #OLD_X_POS]	; update old X pos
	STR a1, [v1, #ORIGINAL_X]	; set original X
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
	STR a1, [v1, #DIRECTION]	; update direction

	; Set Number of lives = 1
	MOV a1, #1
	STR a1, [v1, #LIVES]		; update lives

	; set random Y in range [0-14]	 (4 bit)
	MOV a1, #4
	BL get_nbit_rand
	CMP a1, #15
	MOVGE a1, #14
	STR a1, [v1, #Y_POS]		; update Y pos
	STR a1, [v1, #OLD_Y_POS]	; update old Y pos
	STR a1, [v1, #ORIGINAL_Y]	; set original Y
	MOV a2, a1
	
	; set random X in range [0-18]	(5 bit with check)
	MOV a1, #5
	BL get_nbit_rand
	CMP a1, #19
	MOVGE a1, #18
	STR a1, [v1, #X_POS]		; update X pos
	STR a1, [v1, #OLD_X_POS]	; update old X pos
	STR a1, [v1, #ORIGINAL_X]	; set original X
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

; Set number of enemies to 3
	LDR v1, =NUMBER_OF_ENEMIES
	MOV ip, #3
	STR ip, [v1]

; Make sure bullet is "dead", just set lives to 0.
	LDR v1, =PUMP_SPRITE
	BL kill_sprite

; Now update the GUI

	BL draw_empty_board
	BL populate_board

	LDMFD sp!, {lr, v1-v8}
	BX lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game over
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

model_game_over
	STMFD sp!, {lr, v1-v8}

	LDR v1, =RUNNING_P
	MOV ip, #0
	STRB ip, [v1]

	LDR v1, =GAME_OVER
	MOV ip, #1
	STRB ip, [v1]

	BL Game_over_gui
	; TODO: GUI Update
	; TODO: Peripheral Update

	LDMFD sp!, {lr, v1-v8}
	BX lr


;---------------------reset model--------------------------------------;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Respawn Game Sprites (if they are not completely dead)
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
respawn_game_sprites
	STMFD sp!, {lr, v1-v8}

respawn_dug
	; Reset Dug's position to original position
	LDR v1, =DUG_SPRITE
	LDR a1, [v1, #LIVES]
	CMP a1, #0
	BEQ respawn_fygar1
	BL clear_sprite
	LDR a1, [v1, #X_POS]
	STR a1, [v1, #OLD_X_POS]
	LDR a1, [v1, #ORIGINAL_X]
	STR a1, [v1, #X_POS]
	
	LDR a1, [v1, #Y_POS]
	STR a1, [v1, #OLD_Y_POS]
	LDR a1, [v1, #ORIGINAL_Y]
	STR a1, [v1, #Y_POS]
respawn_fygar1
	; Reset Fygar1's position to original position
	LDR v1, =FYGAR_SPRITE_1
	LDR a1, [v1, #LIVES]
	CMP a1, #0
	BEQ respawn_pooka1
	BL clear_sprite

	LDR a1, [v1, #X_POS]
	STR a1, [v1, #OLD_X_POS]
	LDR a1, [v1, #ORIGINAL_X]
	STR a1, [v1, #X_POS]
	
	LDR a1, [v1, #Y_POS]
	STR a1, [v1, #OLD_Y_POS]
	LDR a1, [v1, #ORIGINAL_Y]
	STR a1, [v1, #Y_POS]	

respawn_pooka1
	; Reset Pooka1's position to original position
	LDR v1, =POOKA_SPRITE_1
	LDR a1, [v1, #LIVES]
	CMP a1, #0
	BEQ respawn_pooka2
	BL clear_sprite

	LDR a1, [v1, #X_POS]
	STR a1, [v1, #OLD_X_POS]
	LDR a1, [v1, #ORIGINAL_X]
	STR a1, [v1, #X_POS]
	
	LDR a1, [v1, #Y_POS]
	STR a1, [v1, #OLD_Y_POS]
	LDR a1, [v1, #ORIGINAL_Y]
	STR a1, [v1, #Y_POS]

respawn_pooka2
; Reset Pooka2's position to original position
	LDR v1, =POOKA_SPRITE_2
	LDR a1, [v1, #LIVES]
	CMP a1, #0
	BEQ respawn_end
	BL clear_sprite

	LDR a1, [v1, #X_POS]
	STR a1, [v1, #OLD_X_POS]
	LDR a1, [v1, #ORIGINAL_X]
	STR a1, [v1, #X_POS]
	
	LDR a1, [v1, #Y_POS]
	STR a1, [v1, #OLD_Y_POS]
	LDR a1, [v1, #ORIGINAL_Y]
	STR a1, [v1, #Y_POS]

respawn_end
	
	LDMFD sp!, {lr, v1-v8}
	BX lr


;---------------------reset model--------------------------------------;

;;;;;;;;;;;;;;;;
; UPDATE MODEL ;
;;;;;;;;;;;;;;;;
; Does the following
; 1. Move the enemy sprites
; 2. Move bullet, if there is one
; 3. Move Dug
; 4. Detect & Handle Collisions
; 5. Trigger GUI Update
; 6. Trigger Peripheral Update
; NOTE: Order was not chosen arbitarily
update_model
	STMFD sp!, {lr, v1-v8}

	LDR v1, =RUNNING_P
	LDRB ip, [v1]
	CMP ip, #0
	BEQ end_model_update

; 1. Move the enemy sprites
; -- 1.1 Move FYGAR1
	; Load FYGAR 1
	LDR v1, =FYGAR_SPRITE_1
	; Get current stats
	LDR a1, [v1, #X_POS]
	LDR a2, [v1, #Y_POS]
	LDR a3, [v1, #LIVES]
	LDR a4, [v1, #DIRECTION]

	; Check if LIVES != 0
	CMP a3, #0
	BEQ update_fygar

	MOV ip, a1
	MOV a1, #2	; to get a 2 bit rand
	BL get_nbit_rand
	MOV a4, a1
	MOV a1, ip

	; Update X and Y based on Direction
	
	CMP a4, #DIR_UP		; Check if direction is UP
	SUBEQ a2, a2, #1	; Then decrement y (a2)
	BEQ update_fygar	; finish updating fygar
	
	CMP a4, #DIR_DOWN	; Check if dir is DOWN
	ADDEQ a2, a2, #1	; Then increment y (a2)
	BEQ update_fygar	; finish updating fygar

	CMP a4, #DIR_LEFT	; check if dir == LEFT
	SUBEQ a1, a1, #1	; then decrement x (a1)
	BEQ update_fygar	; finish updating fygar

	CMP a4, #DIR_RIGHT	; check if dir == RIGHT
	ADDEQ a1, a1, #1	; then increment x (a1)
	BEQ update_fygar	; finish updating fygar

update_fygar
	BL update_sprite	; update fygar sprite

; -- 1.2 Move POOKA1
	; Load POOKA1
	LDR v1, =POOKA_SPRITE_1
	; Get current stats
	LDR a1, [v1, #X_POS]
	LDR a2, [v1, #Y_POS]
	LDR a3, [v1, #LIVES]
	LDR a4, [v1, #DIRECTION]

	; Check if LIVES != 0
	CMP a3, #0
	BEQ update_pooka1

	; Update X and Y based on Direction
	
	CMP a4, #DIR_UP		; Check if direction is UP
	SUBEQ a2, a2, #1	; Then decrement y (a2)
	BEQ update_pooka1	; finish updating pooka1
	
	CMP a4, #DIR_DOWN	; Check if dir is DOWN
	ADDEQ a2, a2, #1	; Then increment y (a2)
	BEQ update_pooka1	; finish updating pooka1

	CMP a4, #DIR_LEFT	; check if dir == LEFT
	SUBEQ a1, a1, #1	; then decrement x (a1)
	BEQ update_pooka1	; finish updating pooka1

	CMP a4, #DIR_RIGHT	; check if dir == RIGHT
	ADDEQ a1, a1, #1	; then increment x (a1)
	BEQ update_pooka1	; finish updating pooka1

update_pooka1
	BL update_sprite	; update pooka1 sprite

; -- 1.3 Move POOKA2
	; Load POOKA2
	LDR v1, =POOKA_SPRITE_2
	; Get current stats
	LDR a1, [v1, #X_POS]
	LDR a2, [v1, #Y_POS]
	LDR a3, [v1, #LIVES]
	LDR a4, [v1, #DIRECTION]

	; Check if LIVES != 0
	CMP a3, #0
	BEQ update_pooka2

	; Update X and Y based on Direction
	
	CMP a4, #DIR_UP		; Check if direction is UP
	SUBEQ a2, a2, #1	; Then decrement y (a2)
	BEQ update_pooka2	; finish updating pooka2
	
	CMP a4, #DIR_DOWN	; Check if dir is DOWN
	ADDEQ a2, a2, #1	; Then increment y (a2)
	BEQ update_pooka2	; finish updating pooka2

	CMP a4, #DIR_LEFT	; check if dir == LEFT
	SUBEQ a1, a1, #1	; then decrement x (a1)
	BEQ update_pooka2	; finish updating pooka2

	CMP a4, #DIR_RIGHT	; check if dir == RIGHT
	ADDEQ a1, a1, #1	; then increment x (a1)
	BEQ update_pooka2	; finish updating pooka2

update_pooka2
	BL update_sprite	; update pooka2 sprite

; 2. Move bullet, if there exists one
	; Load PUMP stats
	LDR v1, =PUMP_SPRITE
	LDR a1, [v1, #X_POS]
	LDR a2, [v1, #Y_POS]
	LDR a3, [v1, #LIVES]
	LDR a4, [v1, #DIRECTION]

	; Check if LIVES != 0
	CMP a3, #0
	BEQ update_bullet	; if LIVES == 0, finish
	; else, update position

	CMP a4, #DIR_UP		; Check if direction is UP
	SUBEQ a2, a2, #1	; Then decrement y (a2)
	BEQ update_bullet	; finish updating bullet
	
	CMP a4, #DIR_DOWN	; Check if dir is DOWN
	ADDEQ a2, a2, #1	; Then increment y (a2)
	BEQ update_bullet	; finish updating bullet

	CMP a4, #DIR_LEFT	; check if dir == LEFT
	SUBEQ a1, a1, #1	; then decrement x (a1)
	BEQ update_bullet	; finish updating bullet

	CMP a4, #DIR_RIGHT	; check if dir == RIGHT
	ADDEQ a1, a1, #1	; then increment x (a1)
	BEQ update_bullet	; finish updating bullet

update_bullet
	BL update_sprite


; 3. Move Dug
	; Load DUG stats
	LDR v1, =DUG_SPRITE
	LDR a1, [v1, #X_POS]
	LDR a2, [v1, #Y_POS]
	LDR a3, [v1, #LIVES]
	LDR a4, [v1, #DIRECTION]

; TODO: What if Dug dies

	LDR v2, =UPDATE_DUG_P
	LDRB ip, [v2]
	CMP ip, #1	; check if update flag is raised
	BNE update_dug	; if not, dont change anything

	; else, load new direction and move
	LDR v2, =DIR_TO_MOVE_DUG
	LDR a4, [v2]	; change Dug's direction

	CMP a4, #DIR_UP		; Check if direction is UP
	SUBEQ a2, a2, #1	; Then decrement y (a2)
	BEQ update_dug	; finish updating dug
	
	CMP a4, #DIR_DOWN	; Check if dir is DOWN
	ADDEQ a2, a2, #1	; Then increment y (a2)
	BEQ update_dug	; finish updating dug

	CMP a4, #DIR_LEFT	; check if dir == LEFT
	SUBEQ a1, a1, #1	; then decrement x (a1)
	BEQ update_dug	; finish updating dug

	CMP a4, #DIR_RIGHT	; check if dir == RIGHT
	ADDEQ a1, a1, #1	; then increment x (a1)
	BEQ update_dug	; finish updating dug

update_dug
	BL update_sprite
	LDR v1, =UPDATE_DUG_P
	MOV ip, #0
	STRB ip, [v1]

; Detect and handle collisions
	BL handle_and_detect_all

end_model_update
; Trigger GUI updates
	BL update_board
; TODO: Trigger peripheral updates
	BL update_peripherals
	LDMFD sp!, {lr, v1-v8}
	BX lr

;--------------------update model--------------------------------------;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; queue movement for DUG
; Called from UART0 interrupt
; Prevents Dug from moving 2 spaces if baud rate > timer rate
; input:	a1 = DIRECTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
queue_movement_DUG
	STMFD sp!, {lr, v1}

	LDR v1, =UPDATE_DUG_P
	LDRB ip, [v1]
	CMP ip, #0		; Check if update flag is down (model has been updated)
	BNE qm_dug_end		; if not, end
	MOV ip, #1
	STRB ip, [v1]		; Raise update flag

	LDR v1, =DIR_TO_MOVE_DUG
	STR a1, [v1]		; store direction to move dug

qm_dug_end
	LDMFD sp!, {lr, v1}
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
;	CMP a1, #0
;	BLT update_y
;	CMP a1, #18
;	BGT update_y
;	CMP a1, #-1	; check whether to update x position or not
	; if != -1 (update = true):
	LDR v2, [v1, #X_POS]	; temporarily hold old x_pos
	STR v2, [v1, #OLD_X_POS]	; store old x position
   	STR a1, [v1, #X_POS]	; update X_POS value for given sprite

update_y
;	CMP a2, #0
;	BLT update_lives
;	CMP a2, #14
;	BGT update_lives
;	CMP a2, #-1	; check whether to update y position or not
	; if != -1 (update = true):
	LDR v2, [v1, #Y_POS]	; temporarily hold old y_pos
	STR v2, [v1, #OLD_Y_POS]	; store old y position
   	STR a2, [v1, #Y_POS]	; update Y_POS value for given sprite

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Detect collision of sprite
; input
;	v1 = address to sprite
;	a1 = Type of sprite
;		0 = DUG
;		1 = POOKA
;		2 = FYGAR
;		3 = PUMP/BULLET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

detect_sprite_collision
	STMFD sp!, {lr, v1-v8}
	; v8 = addresses

	; a2 = X POS
	; a3 = Y POS
	; a4 = Hit count if hitcount reached 2 ==> collision

	LDR a2, [v1, #X_POS]
	LDR a3, [v1, #Y_POS]
	MOV a4, #0
	LDR ip, [v1, #LIVES]
	CMP ip, #0
	BEQ collision_end

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
	MOVEQ a4, #1			; Increment hit count

	; Check if Y Positions are equal
	LDR ip, [v8, #Y_POS]		; Load its Y POSITION
	CMP ip, a3			; Compare the Y positions
	ADDEQ a4, #1			; Increment hit count
	CMP a4, #2
	BEQ is_dug_fatal

	MOV a4, #0

	LDR v8, =POOKA_SPRITE_1		; Load POOKA
		; Check if X Positions are equal
	LDR ip, [v8, #X_POS]		; Load its X POSITION
	CMP ip, a2			; Compare the X positions
	MOVEQ a4, #1			; Increment hit count

	; Check if Y Positions are equal
	LDR ip, [v8, #Y_POS]		; Load its Y POSITION
	CMP ip, a3			; Compare the Y positions
	ADDEQ a4, #1			; Increment hit count
	CMP a4, #2
	BEQ is_dug_fatal
	
	MOV a4, #0

	LDR v8, =POOKA_SPRITE_2		; Load POOKA1
		; Check if X Positions are equal
	LDR ip, [v8, #X_POS]		; Load its X POSITION
	CMP ip, a2			; Compare the X positions
	MOVEQ a4, #1			; Increment hit count

	; Check if Y Positions are equal
	LDR ip, [v8, #Y_POS]		; Load its Y POSITION
	CMP ip, a3			; Compare the Y positions
	ADDEQ a4, #1			; Increment hit count
	CMP a4, #2
	BEQ is_dug_fatal
	
	MOV a4, #0

; 2. check for wall collision
	CMP a2, #0	; check
	MOVLT a1, #2
	BLT is_dug_wall	; end if x < 0
	CMP a2, #18 ; check
	MOVGT a1, #2
	BGT is_dug_wall	; end if x > 18

	CMP a3, #0	; check
	MOVLT a1, #2
	BLT is_dug_wall	; end if y < 0
	CMP a3, #14 ; check
	MOVGT a1, #2
	BGT is_dug_wall	; end if y > 14

; 3. check for sand collision
; Check for sand on board model at xy, and if collision, increment score
	MOV a1, a2			; Move x into a1
	MOV a2, a3			; Move y into a2
	BL get_sand_at_xy		; Get sand at current position
	; 1 if sand, 0 if nothing
	CMP a1, #1
	BEQ is_dug_sand
	
	BAL collision_end

is_dug_fatal			; Handle fatal collisions
	LDR a1, [v1, #LIVES]
	SUB a1, a1, #1
	STR a1, [v1, #LIVES]
	LDR a1, [v1, #X_POS]
	LDR a2, [v1, #Y_POS]
	BL clear_sprite
	CMP a1, #0
	BLEQ model_game_over
	BLGT respawn_game_sprites
	BAL collision_end
is_dug_sand
	MOV a1, #0
	BL modify_score
	
	LDR v1, =DUG_SPRITE
	LDR a1, [v1, #X_POS]
	LDR a2, [v1, #Y_POS]
	BL clear_at_x_y

	BAL collision_end
is_dug_wall
	LDR v2, [v1, #OLD_X_POS]
	STR v2, [v1, #X_POS]
	LDR v3, [v1, #OLD_Y_POS]
	STR v3, [v1, #Y_POS]

	BAL collision_end
is_pooka_check
is_fygar_check
; Sprite is either Pooka or Fygar. Treat them same. #EQUALITY
; 1. Check for fatal collisions with pump
	MOV a4, #0
	LDR v8, =PUMP_SPRITE
		; Check if X Positions are equal
	LDR ip, [v8, #X_POS]		; Load its X POSITION
	CMP ip, a2			; Compare the X positions
	MOVEQ a4, #1			; Increment hit count

	; Check if Y Positions are equal
	LDR ip, [v8, #Y_POS]		; Load its Y POSITION
	CMP ip, a3			; Compare the Y positions
	ADDEQ a4, #1			; Increment hit count
	CMP a4, #2
	BEQ is_enemy_fatal

	; Check if Y Positions are equal
	LDR ip, [v8, #OLD_Y_POS]		; Load its Y POSITION
	CMP ip, a3			; Compare the Y positions
	ADDEQ a4, #1			; Increment hit count
	CMP a4, #2
	BEQ is_enemy_fatal

	MOV a4, #0
	LDR v8, =PUMP_SPRITE
		; Check if X Positions are equal
	LDR ip, [v8, #Y_POS]		; Load its X POSITION
	CMP ip, a2			; Compare the X positions
	MOVEQ a4, #1			; Increment hit count

	; Check if Y Positions are equal
	LDR ip, [v8, #X_POS]		; Load its Y POSITION
	CMP ip, a3			; Compare the Y positions
	ADDEQ a4, #1			; Increment hit count
	CMP a4, #2
	BEQ is_enemy_fatal

	; Check if Y Positions are equal
	LDR ip, [v8, #OLD_X_POS]		; Load its Y POSITION
	CMP ip, a3			; Compare the Y positions
	ADDEQ a4, #1			; Increment hit count
	CMP a4, #2
	BEQ is_enemy_fatal

	MOV a4, #0
; 2. Check for wall collision
	CMP a2, #0	; check
	BLT is_enemy_sand_wall	; end if x < 0
	CMP a2, #18 ; check
	BGT is_enemy_sand_wall	; end if x > 18

	CMP a3, #0	; check
	BLT is_enemy_sand_wall	; end if y < 0
	CMP a3, #14 ; check
	BGT is_enemy_sand_wall	; end if y > 14

; 3. check for sand collision
; Check for sand on board model at xy, and if collision, increment score
	MOV a1, a2			; Move x into a1
	MOV a2, a3			; Move y into a2
	BL get_sand_at_xy		; Get sand at current position
	; 1 if sand, 0 if nothing
	CMP a1, #1
	BEQ is_enemy_sand_wall
	BAL collision_end

is_enemy_fatal			; Handle fatal collisions
	LDR ip, =FYGAR_SPRITE_1
	CMP ip, v1		; check if current sprite if FYGAR
	MOVEQ a1, #2
	MOVNE a1, #1
	BL modify_score
	BL kill_sprite
	LDR v1, =PUMP_SPRITE
	BL kill_sprite
	LDR v1, =NUMBER_OF_ENEMIES
	LDR a1, [v1]
	SUBS a1, a1, #1
	STR a1, [v1]
	BLEQ level_up_dug
	BAL collision_end
is_enemy_sand_wall
	; First backtrack its movements by setting current position to old position
	LDR v2, [v1, #OLD_X_POS]
	STR v2, [v1, #X_POS]
	LDR v3, [v1, #OLD_Y_POS]
	STR v3, [v1, #Y_POS]

	; check if up is free
;	SUB a2, v3, #1
;	MOV a1, v2
;	BL get_sand_at_xy
;	CMP a1, #0
;	MOVEQ a1, #DIR_UP
;	BEQ is_enemy_end_collision
 ;
;	; check if down is free
;	ADD a2, v3, #1
;	MOV a1, v2
;	BL get_sand_at_xy
;	CMP a1, #0
;	MOVEQ a1, #DIR_DOWN
;	BEQ is_enemy_end_collision
 ;
;	; check if left is free
;	SUB a1, v2, #1
;	MOV a2, v3
;	BL get_sand_at_xy
;	CMP a1, #0
;	MOVEQ a1, #DIR_LEFT
;	BEQ is_enemy_end_collision
 ;
	; check if up is free
;	ADD a1, v2, #1
;	MOV a2, v3
;	BL get_sand_at_xy
;	CMP a1, #0
;	MOVEQ a1, #DIR_RIGHT
;	BEQ is_enemy_end_collision
 ;
	; Then set him off on a random direction (coz we dont care about the bad guy)
	MOV a1, #2		; 2 bit rand (0-3) = new direction
	BL get_nbit_rand
is_enemy_end_collision
	STR a1, [v1, #DIRECTION]

	BAL collision_end

is_pump_check
; Sprite is pump. Only significant collision is with wall or sand
; 1. Check for fatal collisions
;	MOV a4, #0
;	LDR v8, =FYGAR_SPRITE_1
;		; Check if X Positions are equal
;	LDR ip, [v8, #X_POS]		; Load its X POSITION
;	CMP ip, a2			; Compare the X positions
;	MOVEQ a4, #1			; Increment hit count
;;
;	; Check if Y Positions are equal
;	LDR ip, [v8, #Y_POS]		; Load its Y POSITION
;	CMP ip, a3			; Compare the Y positions
;	ADDEQ a4, #1			; Increment hit count
;	CMP a4, #2
;	MOV ip, v1
;	MOV v1, v8
;	BLEQ kill_sprite
;	MOV v1, ip
;	BEQ is_pump_fatal
 ;;
;	MOV a4, #0
;	LDR v8, =POOKA_SPRITE_1
;		; Check if X Positions are equal
;	LDR ip, [v8, #X_POS]		; Load its X POSITION
;	CMP ip, a2			; Compare the X positions
;	MOVEQ a4, #1			; Increment hit count
;;
;	; Check if Y Positions are equal
;	LDR ip, [v8, #Y_POS]		; Load its Y POSITION
;	CMP ip, a3			; Compare the Y positions
;	ADDEQ a4, #1			; Increment hit count
;	CMP a4, #2
;	MOV ip, v1
;	MOV v1, v8
;	BLEQ kill_sprite
;	MOV v1, ip
;	BEQ is_pump_fatal
 ;
;	MOV a4, #0
;	LDR v8, =POOKA_SPRITE_2
;		; Check if X Positions are equal
;	LDR ip, [v8, #X_POS]		; Load its X POSITION
;	CMP ip, a2			; Compare the X positions
;	MOVEQ a4, #1			; Increment hit count
;	LDRNE ip, [v8, #OLD_X_POS]		; Load its X POSITION
;	CMPNE ip, a2			; Compare the X positions
;	MOVEQ a4, #1			; Increment hit count
;
;	; Check if Y Positions are equal
;	LDR ip, [v8, #Y_POS]		; Load its Y POSITION
;	CMP ip, a3			; Compare the Y positions
;	ADDEQ a4, #1			; Increment hit count
;	LDR ip, [v8, #OLD_Y_POS]		; Load its Y POSITION
;	CMP ip, a3			; Compare the Y positions
;	ADDEQ a4, #1			; Increment hit count
;	CMP a4, #2
;	MOV ip, v1
;	MOV v1, v8
;	BLGE kill_sprite
;	MOV v1, ip
;	BGE is_pump_fatal

; 2. Check for wall collision
	CMP a2, #0	; check
	MOVLT a1, #2
	BLE is_pump_nokill	; end if x < 0
	CMP a2, #18 ; check
	MOVGE a1, #2
	BGT is_pump_nokill	; end if x > 18

	CMP a3, #0	; check
	MOVLT a1, #2
	BLT is_pump_nokill	; end if y < 0
	CMP a3, #14 ; check
	MOVGT a1, #2
	BGT is_pump_nokill	; end if y > 14

; 3. check for sand collision
	MOV a1, a2			; Move x into a1
	MOV a2, a3			; Move y into a2
	BL get_sand_at_xy		; Get sand at current position
	; 1 if sand, 0 if nothing
	CMP a1, #1
	BEQ is_pump_fatal
	BAL collision_end
is_pump_fatal
	LDR v1, =PUMP_SPRITE
	LDR ip, [v1, #OLD_X_POS]
	STR ip, [v1, #X_POS]
	LDR ip, [v1, #OLD_Y_POS]
	STR ip, [v1, #Y_POS]
	BL kill_sprite
	BAL collision_end
is_pump_nokill
	LDR v1, =PUMP_SPRITE
	LDR ip, [v1, #OLD_X_POS]
	STR ip, [v1, #X_POS]
	LDR ip, [v1, #OLD_Y_POS]
	STR ip, [v1, #Y_POS]
	BL kill_sprite
collision_end
	LDMFD sp!, {lr, v1-v8}
	BX lr
;--------------------detect collision--------------------------------------;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Update FYGAR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

just_fygar_update
	STMFD sp!, {lr, v1}

	LDR v1, =RUNNING_P
	LDRB ip, [v1]
	CMP ip, #0
	BEQ end_fygar_update
	
	; Load FYGAR 1
	LDR v1, =FYGAR_SPRITE_1
	; Get current stats
	LDR a1, [v1, #X_POS]
	LDR a2, [v1, #Y_POS]
	LDR a3, [v1, #LIVES]
	LDR a4, [v1, #DIRECTION]

	; Check if LIVES != 0
	CMP a3, #0
	BEQ finish_fygar_update

	MOV ip, a1
	MOV a1, #2	; to get a 2 bit rand
	BL get_nbit_rand
	MOV a4, a1
	MOV a1, ip

	; Update X and Y based on Direction
	
	CMP a4, #DIR_UP		; Check if direction is UP
	SUBEQ a2, a2, #1	; Then decrement y (a2)
	BEQ finish_fygar_update	; finish updating fygar
	
	CMP a4, #DIR_DOWN	; Check if dir is DOWN
	ADDEQ a2, a2, #1	; Then increment y (a2)
	BEQ finish_fygar_update	; finish updating fygar

	CMP a4, #DIR_LEFT	; check if dir == LEFT
	SUBEQ a1, a1, #1	; then decrement x (a1)
	BEQ finish_fygar_update	; finish updating fygar

	CMP a4, #DIR_RIGHT	; check if dir == RIGHT
	ADDEQ a1, a1, #1	; then increment x (a1)
	BEQ finish_fygar_update	; finish updating fygar

finish_fygar_update
	BL update_sprite	; update fygar sprite
end_fygar_update
	MOV a1,	#2
	LDMFD sp!, {lr, v1}
	BX lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spawn Bullet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spawn_bullet
	STMFD sp!, {lr, v1}
	
	LDR v1, =DUG_SPRITE
	LDR a1, [v1, #X_POS]
	LDR a2, [v1, #Y_POS]
	LDR a3, [v1, #DIRECTION]

;	CMP a3, #DIR_UP
;	SUBEQ a2, a2, #1

;	CMP a3, #DIR_DOWN
;	ADDEQ a2, a2, #1

;	CMP a3, #DIR_LEFT
;	SUBEQ a1, a1, #1

;	CMP a3, #DIR_RIGHT
;	ADDEQ a1, a1, #1

	LDR v1, =PUMP_SPRITE
	LDR ip, [v1, #LIVES]
	CMP ip,	#0
	BGT	bullet_spawn_end

	STR a1, [v1, #X_POS]
	STR a1, [v1, #OLD_X_POS]
	STR a2, [v1, #Y_POS]
	STR a2, [v1, #OLD_Y_POS]
	MOV a1, #1
	STR a1, [v1, #LIVES]
	STR a3, [v1, #DIRECTION] 
bullet_spawn_end	
	LDMFD sp!, {lr, v1}
	BX lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Update Bullet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
just_update_bullet
	STMFD sp!, {lr, v1}

	LDR v1, =RUNNING_P
	LDRB ip, [v1]
	CMP ip, #0
	BEQ end_pump_update

	; Load BULLET
	LDR v1, =PUMP_SPRITE
	; Get current stats
	LDR a1, [v1, #X_POS]
	LDR a2, [v1, #Y_POS]
	LDR a3, [v1, #LIVES]
	LDR a4, [v1, #DIRECTION]

	; Check if LIVES != 0
	CMP a3, #0
	BEQ finish_pump_update

	MOV ip, a1
	MOV a1, #2	; to get a 2 bit rand
	BL get_nbit_rand
	MOV a4, a1
	MOV a1, ip

	; Update X and Y based on Direction
	
	CMP a4, #DIR_UP		; Check if direction is UP
	SUBEQ a2, a2, #1	; Then decrement y (a2)
	BEQ finish_pump_update	; finish updating Bullet
	
	CMP a4, #DIR_DOWN	; Check if dir is DOWN
	ADDEQ a2, a2, #1	; Then increment y (a2)
	BEQ finish_pump_update	; finish updating Bullet

	CMP a4, #DIR_LEFT	; check if dir == LEFT
	SUBEQ a1, a1, #1	; then decrement x (a1)
	BEQ finish_pump_update	; finish updating Bullet

	CMP a4, #DIR_RIGHT	; check if dir == RIGHT
	ADDEQ a1, a1, #1	; then increment x (a1)
	BEQ finish_pump_update	; finish updating Bullet

finish_pump_update
	BL update_sprite	; update Bullet sprite
end_pump_update
	MOV a1,	#2
	LDMFD sp!, {lr, v1}
	BX lr	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Detect collision for all sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
handle_and_detect_all
	STMFD sp!, {lr, v1}
	LDR v1, =PUMP_SPRITE
	MOV a1, #3
	BL detect_sprite_collision
	LDR v1, =FYGAR_SPRITE_1
	MOV a1,	#2
	BL detect_sprite_collision
	LDR v1, =POOKA_SPRITE_1
	MOV a1,	#1
	BL detect_sprite_collision
	LDR v1, =POOKA_SPRITE_2
	MOV a1,	#1
	BL detect_sprite_collision
	LDR v1, =DUG_SPRITE
	MOV a1,	#0
	BL detect_sprite_collision

	LDMFD sp!, {lr, v1}
	BX lr
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; manipulate game states
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
toggle_pause_game
	STMFD sp!, {lr, v1}

	LDR v1, =PAUSE_GAME
	LDRB ip, [v1]
	CMP ip, #0
	MOVEQ ip, #1	; pause
	MOVEQ a1, #0	; not runnoing
	MOVNE ip, #0	; not paused
	MOVNE a1, #1	; running
	STRB ip, [v1]

	LDR v1, =RUNNING_P
	STRB a1, [v1]

	; TODO: trigger gui

	STMFD sp!, {lr, v1}
	BX lr

;;;;;;;;;;;;;;;;
; Kill Sprite
;;;;;;;;;;;;;;;;
kill_sprite
	; v1 = sprite to kill
	STMFD sp!, {lr, v1,v2}
	
	LDR v2, [v1, #LIVES]
	SUB v2, v2, #1
	CMP v2, #0
	MOVLE v2, #0
	STR v2, [v1, #LIVES]
	BL clear_sprite
	CMP v2, #0
	MOVEQ v2, #100
	STREQ v2, [v1, #X_POS]
	STREQ v2, [v1, #Y_POS]

	LDMFD sp!, {lr, v1, v2}
	BX lr

; input:	a1 	-> 0 = 10 points
;				-> 1 = 50 points
;				-> 2 = 100 points
modify_score
	STMFD sp!, {lr, v1}

	LDR v1, =CURRENT_SCORE
	LDR ip, [v1]
	CMP a1, #0
	ADDEQ ip, ip, #10
	CMP a1, #1
	ADDEQ ip, ip, #50
	CMP a1, #2
	ADDEQ ip, ip, #100
	
	STR ip, [v1]
	LDR v1, =HIGH_SCORE
	LDR a1, [v1]
	CMP a1, ip
	MOVLT a1, ip

	STR a1, [v1]

	LDMFD sp!, {lr, v1}
	BX lr

level_up_dug
	STMFD sp!, {lr, v1}

	LDR v1, =LEVEL
	LDR ip, [v1]
	ADD ip, ip, #1
	STR ip, [v1]



	BL reset_model

	LDMFD sp!, {lr, v1}
	BX lr
	END
