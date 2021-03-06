	AREA MODEL, CODE, READWRITE


	IMPORT	ONE_SEC		
	IMPORT	HALF_SEC	
	IMPORT	TIMER_100ms	
	IMPORT	TIME_120s	

	IMPORT	get_nbit_rand
	IMPORT	disable_timer0
	IMPORT	reset_timer0
	IMPORT	get_match0
	IMPORT	get_match1
	IMPORT	set_match0
	IMPORT	set_match1

	IMPORT	draw_empty_board
	IMPORT	populate_board
	IMPORT	update_board
	IMPORT	clear_sprite
	IMPORT Game_over_gui

	IMPORT update_peripherals

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

	IMPORT	pause_game_gui

;;;;;;;;;;;;;;;;;;;;;
;	CONSTANTS		;
;;;;;;;;;;;;;;;;;;;;;

	EXPORT	BOARD_WIDTH
	EXPORT	BOARD_HEIGHT
	EXPORT	X_POS
	EXPORT	Y_POS	
	EXPORT	LIVES	
	EXPORT	DIRECTION
	EXPORT	OLD_X_POS
	EXPORT	OLD_Y_POS
	EXPORT	SPRITE_TYPE
	
	EXPORT	DIR_UP
	EXPORT	DIR_DOWN
	EXPORT	DIR_LEFT
	EXPORT	DIR_RIGHT

	EXPORT	DUG_TYPE	
	EXPORT	POOKA_TYPE	
	EXPORT	FYGAR_TYPE	
	EXPORT	BULLET_TYPE

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
SPRITE_TYPE	EQU 8*4

DIR_UP		EQU 0
DIR_DOWN	EQU 1
DIR_LEFT	EQU 2
DIR_RIGHT	EQU 3

DUG_TYPE	EQU	0
POOKA_TYPE	EQU	1
FYGAR_TYPE	EQU	2
BULLET_TYPE	EQU	3

;;;;;;;;;;;;;;;;;;;;;
;	GAME STATE		;
;;;;;;;;;;;;;;;;;;;;;

	EXPORT	BEGIN_GAME
	EXPORT	PAUSE_GAME
	EXPORT	GAME_OVER
	EXPORT	RUNNING_P
 
	EXPORT	DUG_SPRITE
	EXPORT	FYGAR_SPRITE_1
	EXPORT	POOKA_SPRITE_1
	EXPORT	POOKA_SPRITE_2
	EXPORT	PUMP_SPRITE

	EXPORT	GAME_BOARD
	EXPORT	HIGH_SCORE
	EXPORT	LEVEL
	EXPORT	CURRENT_SCORE
	EXPORT	CURRENT_TIME
	EXPORT	NUMBER_OF_ENEMIES

DUG_SPRITE		; State of the Dug sprite
	DCD 10			; x position
	DCD 7			; y position
	DCD 4			; lives
	DCD DIR_LEFT	   	; direction
	DCD 32			; Old X
	DCD 20			; Old Y
	DCD 9			; Original X
	DCD 7			; Original Y
	DCD	DUG_TYPE	; Type = DUG

FYGAR_SPRITE_1		; State of 1st Fygar sprite
	DCD 1			; x position
	DCD 1			; y position
	DCD 1			; lives
	DCD DIR_RIGHT		; direction
	DCD 1			; Old X
	DCD 1			; Old Y
	DCD 9			; Original X
	DCD 7			; Original Y
	DCD	FYGAR_TYPE	; Type = DUG

POOKA_SPRITE_1		; State of 1st Pooka sprite
	DCD 10			; x position
	DCD 1			; y position
	DCD 1			; lives
	DCD DIR_UP		; direction
	DCD 10			; Old X
	DCD 1			; Old Y
	DCD 9			; Original X
	DCD 7			; Original Y
	DCD	POOKA_TYPE	; Type = DUG

POOKA_SPRITE_2		; State of 2nd Pooka sprite
	DCD 15			; x position
	DCD 15			; y position
	DCD 1			; lives
	DCD DIR_DOWN		; direction
	DCD 15			; Old X
	DCD 15			; Old Y
	DCD 9			; Original X
	DCD 7			; Original Y
	DCD	POOKA_TYPE	; Type = DUG

PUMP_SPRITE		; State of the Pump sprite
	DCD 100			; x position
	DCD 100			; y position
	DCD 0			; lives
	DCD DIR_LEFT	   	; direction
	DCD 100			; Old X
	DCD 100			; Old Y
	DCD 100			; Original X
	DCD 100			; Original Y
	DCD	BULLET_TYPE	; Type = DUG


HIGH_SCORE	DCD 0
LEVEL		DCD 1
CURRENT_SCORE	DCD 0
CURRENT_TIME	DCD TIME_120s
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


; Initialize model.
; This routine has to do the following:
; 1. Set current score to 0 and level to 1
; 2. Reset the sprites on the board
	
	EXPORT	init_model

init_model
	STMFD sp!, {lr, v1}
	MOV a1, #0
	LDR v1, =CURRENT_SCORE
	STR a1, [v1]
	LDR v1, =LEVEL
	MOV a1, #1
	STR a1, [v1]
	BL reset_model
	LDMFD sp!, {lr, v1}
	BX lr
	

; Reset Model has to:
; 1. Reset variables on board.
; 2. Set sprites to random positions on the board
; 3. Update GUI appropriately
; NOTE: Reset model is called by game over handling routine, so we must reset and display game over.

	EXPORT	reset_model

reset_model
	STMFD sp!, {lr, v1-v8}

	; Reset the board to initial state
	LDR v1, =GAME_BOARD	; load Game Board address
	ADD v1, v1, #38		; Dont fill first two rows, so adjust offset by 38
	LDR v2, =BOARD_SIZE	; Load board size into v2
	SUB v2, v2, #38		; dont count first two rows, so reduce count by 38
	MOV ip, #1		; ip = sand

	; Loop to reinitialize the board.
; 1. Fill board with sand
reset_board_loop
	STRB ip, [v1], #1	; Store 1 byte at current index on board and increment index (sand by default)
	SUBS v2, #1			; Decrement residual index (and set CPSR)
	BGT reset_board_loop ; Loop while index > 0

; 2.	Initialize DUG
; 2.1	Set Dug sprite to center with 4 lives and looking left
	LDR v1, =DUG_SPRITE		; Load DUG
	MOV a1, #BOARD_CENTER_X		; Load X center
	STR a1, [v1, #ORIGINAL_X]	; Set Original X position to X center
	STR a1, [v1, #OLD_X_POS]	; Set Old X
	STR a1, [v1, #X_POS]		; Set Current X
	MOV a2, #BOARD_CENTER_Y		; Load Y center
	STR a2, [v1, #ORIGINAL_Y]	; Set Original Y
	STR a2, [v1, #OLD_Y_POS]	; Set Old Y
	STR a2, [v1, #Y_POS]		; Set Current Y
	MOV a3, #4			; Load in 4 lives
	STR a3, [v1, #LIVES]		; Set number of lives = 4
	MOV a4, #DIR_LEFT		;
	STR a4, [v1, #DIRECTION]	; Set initial direction to LEFT
; 2.2	Clear sand around Dug (8,7),(9,7),(10,7)
	MOV a1, #8			; x = 8
	MOV a2, #7			; y = 7
	BL clear_at_x_y			; clear
	MOV a1, #9			; x = 9
	MOV a2, #7			; x = 7
	BL clear_at_x_y			; clear
	MOV a1, #10			; x = 10
	MOV a2, #7			; x = 7
	BL clear_at_x_y			; clear
	
; 3.1	Initialize FYGAR
	LDR v1, =FYGAR_SPRITE_1
	
; Set random dir
	MOV a1, #2			; get random 2 bit number for direction [0-3]
	BL get_nbit_rand
	STR a1, [v1, #DIRECTION]	; update direction
; Set Number of lives = 1
	MOV a1, #1
	STR a1, [v1, #LIVES]		; update lives
; set random Y in range [2-14]	 (4 bit)
	MOV a1, #4			; get 4 bit rand [0-15]
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
; 3.2	Clear sand for Fygar1 movement  
;	(x-2,y)(x-1,y)(x,y)(x+1,y)(x+2,y)

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
	LDR v1, =GAME_OVER
	LDRB ip, [v1]
	CMP ip, #0		; check if not game over
	BNE model_normal_update	; if game over, GAME OVER GUI 

	BL Game_over_gui
model_normal_update
	BL draw_empty_board
	BL populate_board

	LDMFD sp!, {lr, v1-v8}
	BX lr

; Game over trigger for model
;
; TODO: Explaination

	EXPORT	model_game_over

model_game_over
	STMFD sp!, {lr, v1-v8}

	LDR v1, =RUNNING_P
	MOV ip, #0
	STRB ip, [v1]

	LDR v1, =PAUSE_GAME
	MOV ip, #0
	STRB ip, [v1]

	LDR v1, =BEGIN_GAME
	MOV ip, #0
	STRB ip, [v1]

	LDR v1, =CURRENT_TIME
	LDR ip, =TIME_120s
	STR ip, [v1]

	LDR v1, =GAME_OVER
	MOV ip, #1
	STRB ip, [v1]

	BL reset_timer0
	BL disable_timer0

	BL reset_model

	LDMFD sp!, {lr, v1-v8}
	BX lr

; Respawn Game Sprites (if they are not completely dead)
; TODO: Explaination
;

	EXPORT	respawn_game_sprites

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

; UPDATE MODEL 
; Does the following
; 1. Move the enemy sprites
; 2. Move bullet, if there is one
; 3. Move Dug
; 4. Detect & Handle Collisions
; 5. Trigger GUI Update
; 6. Trigger Peripheral Update

	EXPORT	update_model

update_model
	STMFD sp!, {lr, v1-v8}

	LDR v1, =RUNNING_P
	LDRB ip, [v1]
	CMP ip, #0
	BEQ end_model_update

	LDR v1, =DUG_SPRITE
	LDRB v2, [v1, #LIVES]
	CMP v2, #0
	BLEQ model_game_over
	CMP v2, #0
	BEQ end_model_update

	LDR v1, =NUMBER_OF_ENEMIES
	LDRB v2, [v1]
	CMP v2, #0
	BLEQ level_up_dug
	CMP v2, #0
	BEQ end_model_update

; 1. Move the enemy sprites
; -- 1.1 Move FYGAR1
update_fygar
	; Load FYGAR 1
	LDR v1, =FYGAR_SPRITE_1
	; Get current stats
	LDR a1, [v1, #DIRECTION]
	LDR a2, [v1, #LIVES]
	; Check if LIVES != 0
	CMP a2, #0
	BEQ update_pooka1
;	MOV a1, #2
;	BL get_nbit_rand 	
;	LDR a1, [v1, #X_POS]
;	LDR a2, [v2, #Y_POS]
;	BL get_a_free_direction
	MOV a1, #2
	BL get_nbit_rand
	BL move_sprite_given_dir ; Update X and Y based on Direction
	BL enemy_collision_with_sand_wall

; -- 1.2 Move POOKA1
	; Load POOKA1
update_pooka1
	LDR v1, =POOKA_SPRITE_1
	; Get current stats
	LDR a1, [v1, #DIRECTION]
	LDR a2, [v1, #LIVES]
	; Check if LIVES != 0
	CMP a2, #0
	BEQ update_pooka2
;	MOV a1, #2
;	BL get_nbit_rand	
	MOV a1, #2
	BL get_nbit_rand 
	BL move_sprite_given_dir ; Update X and Y based on Direction
	BL enemy_collision_with_sand_wall

; -- 1.3 Move POOKA2
	; Load POOKA2
update_pooka2
	LDR v1, =POOKA_SPRITE_2
	; Get current stats
	LDR a1, [v1, #DIRECTION]
	LDR a2, [v1, #LIVES]
	; Check if LIVES != 0
	CMP a2, #0
	BEQ update_bullet
;	MOV a1, #2
;	BL get_nbit_rand 
	BL move_sprite_given_dir ; Update X and Y based on Direction
	BL enemy_collision_with_sand_wall

; 2. Move bullet, if there exists one
update_bullet
	; Load PUMP stats
	LDR v1, =PUMP_SPRITE
	LDR a2, [v1, #LIVES]
	LDR a1, [v1, #DIRECTION]

	; Check if LIVES != 0
	CMP a2, #0
	BEQ update_dug	; if LIVES == 0, finish
	; else, update position
	BL move_sprite_given_dir ; Update X and Y based on Direction
	BL bullet_collision_with_sand_wall

; 3. Move Dug
update_dug

	; check if user asked dug to move

	LDR v1, =UPDATE_DUG_P
	LDRB ip, [v1]
	CMP ip, #1				; check if update flag is raised
	BNE post_movement_update			; if not, dont change anything
	; else, load new direction and move
	LDR v1, =DIR_TO_MOVE_DUG
	LDR a1, [v1]			; change Dug's direction
	LDR v1, =DUG_SPRITE		; Load DUG
	BL move_sprite_given_dir 
	BL wall_collision_dug
	BL sand_collision_dug
	; BL update_sprite
	LDR v1, =UPDATE_DUG_P
	MOV ip, #0
	STRB ip, [v1]

post_movement_update
; Detect and handle collisions
	LDR v1, =FYGAR_SPRITE_1
	BL fatal_collision1_enemy
	BL fatal_collision2_enemy

	LDR v1, =POOKA_SPRITE_1
	BL fatal_collision1_enemy
	BL fatal_collision2_enemy

	LDR v1, =POOKA_SPRITE_2
	BL fatal_collision1_enemy
	BL fatal_collision2_enemy

	LDR v1, =PUMP_SPRITE
	BL bullet_collision_with_sand_wall

	LDR v1, =DUG_SPRITE
	BL fatal_collision1_dug
	BL fatal_collision2_dug
   	
	LDR v1, =CURRENT_TIME
	LDR a1, [v1]
	LSR a1, a1, #1
	CMP a1, #0			; if timer reached 0
	BGT end_model_update
	BL model_game_over

end_model_update
; Trigger GUI updates
	BL update_board
; Trigger peripheral updates
	BL update_peripherals
end_dont_update
	LDMFD sp!, {lr, v1-v8}
	BX lr

; queue movement for DUG
; Called from UART0 interrupt
; Prevents Dug from moving 2 spaces if baud rate > timer rate
; input:	a1 = DIRECTION

	EXPORT	queue_movement_DUG

queue_movement_DUG
	STMFD sp!, {lr, v1}
	
	LDR v1, =RUNNING_P
	LDRB ip, [v1]
	CMP ip, #0
	BEQ qm_dug_end
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

	EXPORT	update_sprite

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
; coordinate on array = x + (width*y)

	EXPORT	 clear_at_x_y

clear_at_x_y  
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

	EXPORT	 get_sand_at_xy

get_sand_at_xy
	STMFD sp!, {lr, v1-v8}

	; If out of bounds, return 0

	CMP a1, #0	; check
	MOVLT a1, #0
	BLT get_xy_end	; end if x < 0
	CMP a1, #18 ; check
	MOVGT a1, #0
	BGT get_xy_end	; end if x > 18

	CMP a2, #1	; check
	MOVLT a1, #0
	BLT get_xy_end	; end if y < 1
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

; Update FYGAR
; TODO: Explaination

	EXPORT	just_fygar_update

just_fygar_update
	STMFD sp!, {lr, v1}

	LDR v1, =RUNNING_P
	LDRB ip, [v1]
	CMP ip, #0
	BEQ end_fygar_update
	
	; Load FYGAR 1
	LDR v1, =FYGAR_SPRITE_1
	; Get current stats
	LDR a1, [v1, #DIRECTION]
	LDR a2, [v1, #LIVES]
	; Check if LIVES != 0
	CMP a2, #0
	BEQ end_fygar_update
	MOV a1, #2
	BL get_nbit_rand
	BL move_sprite_given_dir ; Update X and Y based on Direction
	BL enemy_collision_with_sand_wall
end_fygar_update
	LDMFD sp!, {lr, v1}
	BX lr

; Spawn Bullet
; TODO: Explaination

	EXPORT	spawn_bullet

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

; Update Bullet
; TODO: Explaination

	EXPORT	just_update_bullet

just_update_bullet
	STMFD sp!, {lr, v1}

	LDR v1, =RUNNING_P
	LDRB ip, [v1]
	CMP ip, #0
	BEQ end_pump_update

	; Load PUMP stats
	LDR v1, =PUMP_SPRITE
	LDR a2, [v1, #LIVES]
	LDR a1, [v1, #DIRECTION]

	; Check if LIVES != 0
	CMP a2, #0
	BEQ update_dug	; if LIVES == 0, finish
	; else, update position
	BL move_sprite_given_dir ; Update X and Y based on Direction
	BL bullet_collision_with_sand_wall
end_pump_update
	LDMFD sp!, {lr, v1}
	BX lr	

	
; toggle_pause_game
; TODO: doc

	EXPORT	toggle_pause_game

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

	; trigger gui
	BL pause_game_gui
	LDMFD sp!, {lr, v1}
	BX lr

; Kill Sprite

	EXPORT	kill_sprite

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
	BGT killing_spree_end

	LDR ip, [v1, #SPRITE_TYPE]
	CMP ip, #FYGAR_TYPE
	CMPNE ip, #POOKA_TYPE
	MOVEQ v2, #100
	MOVNE v2, #50
	STR v2, [v1, #X_POS]
	STR v2, [v1, #Y_POS]
killing_spree_end
	LDMFD sp!, {lr, v1, v2}
	BX lr

; input:	a1 	-> 0 = 10 points
;				-> 1 = 50 points
;				-> 2 = 100 points

	EXPORT	modify_score

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

; Level up trigger

	EXPORT	level_up_dug

level_up_dug
	STMFD sp!, {lr, v1}

	LDR v1, =LEVEL
	LDR ip, [v1]
	ADD ip, ip, #1
	STR ip, [v1]

	LDR v1, =DUG_SPRITE
	LDR v2, [v1, #LIVES]
	BL reset_model
	STR v2, [v1, #LIVES]

	BL disable_timer0

	BL get_match1
	LDR v1, =TIMER_100ms
	SUB a1, a1, v1
	CMP a1, #0
	MOVEQ a1, v1
	MOV a2, #1
	BL set_match1
	BL get_match0
	LSR a1, a1, #1
	MOV a2, #0
	BL set_match0

	BL reset_timer0

	LDMFD sp!, {lr, v1}
	BX lr


	END
