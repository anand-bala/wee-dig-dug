	AREA collisions, CODE, READWRITE

	IMPORT	BOARD_WIDTH
	IMPORT	BOARD_HEIGHT
	IMPORT	X_POS
	IMPORT	Y_POS	
	IMPORT	LIVES	
	IMPORT	DIRECTION
	IMPORT	OLD_X_POS
	IMPORT	OLD_Y_POS
	IMPORT	SPRITE_TYPE

	IMPORT	DUG_TYPE	
	IMPORT	POOKA_TYPE	
	IMPORT	FYGAR_TYPE	
	IMPORT	BULLET_TYPE

	IMPORT	PUMP_SPRITE


	IMPORT	get_sand_at_xy

	IMPORT	get_nbit_rand

DIR_UP		EQU	0
DIR_DOWN	EQU 1
DIR_LEFT	EQU 2
DIR_RIGHT	EQU 3


; Detect collision of enemies with sand or wall
; Steps:
; 1. Check if enemy is on the wall or next move is on the wall
; 2. If so, create a map of place around it and pick a free spot
; 3. Else, don' actually care
; Input:	v1	=	Sprite

	EXPORT	enemy_collision_with_sand_wall

enemy_collision_with_sand_wall
	STMFD sp!, {lr, v1-v4}
	
; 1.1.1	Check if  sprite is on wall
	LDR ip, [v1, #X_POS]
	CMP ip, #-1	  				; Check if x == -1
	CMPNE ip, #BOARD_WIDTH	   	; || Check if x == 19
	BEQ enemy_on_wall_sand		; If either, enemy is sitting on the wall

	LDR ip, [v1, #Y_POS]
	CMP ip, #-1	  				; Check if y == -1
	CMPNE ip, #BOARD_HEIGHT	   	; || Check if y == BOARD_HEIGHT
	BEQ enemy_on_wall_sand		; If either, enemy is sitting on the wall

; 1.1.2	Check if sprite is on sand
	LDR a1, [v1, #X_POS]		; Get x coord
	LDR a2, [v1, #Y_POS]		; Get y coord
	BL get_sand_at_xy			; get sand at xy
	CMP a1, #1					; check if there is sand where the sprite is
	BEQ enemy_on_wall_sand		; if there is, enemy is sitting on sand

; 1.2.1 Check if next movement will put enemy on wall
	LDR a1, [v1, #X_POS]		; Get x coord
	LDR a2, [v1, #Y_POS]		; Get y coord
	LDR a3, [v1, #DIRECTION]	; Get direction
	BL get_next_coordinate		; Get the next coordinate (x', y')
	
	CMP a1, #-1	  				; Check if x' == -1
	CMPNE a1, #BOARD_WIDTH	   	; || Check if x' == 19
	BEQ enemy_will_be_on_wall_sand		; If either, enemy will be sitting on the wall

	CMP a2, #-1	  				; Check if y' == -1
	CMPNE a2, #BOARD_HEIGHT	   	; || Check if y' == BOARD_HEIGHT
	BEQ enemy_will_be_on_wall_sand		; If either, enemy will be sitting on the wall

; 1.2.2 Check if next movement will put enemy on sand
	LDR a1, [v1, #X_POS]		; Get x coord
	LDR a2, [v1, #Y_POS]		; Get y coord
	LDR a3, [v1, #DIRECTION]	; Get direction
	BL get_next_coordinate		; Get the next coordinate (x', y')
	BL get_sand_at_xy			; get sand at x' y'
	CMP a1, #1					; if there is sand
	BEQ enemy_will_be_on_wall_sand		; enemy will be there soon

	BAL enemy_not_on_wall_sand
enemy_on_wall_sand
	; Move to old position
	LDR a1, [v1, #OLD_X_POS]
	STR a1, [v1, #X_POS]
	LDR a2, [v1, #OLD_Y_POS]
	STR a2, [v1, #Y_POS]
enemy_will_be_on_wall_sand
	BL get_a_free_direction
	BL move_sprite_given_dir
enemy_not_on_wall_sand
	LDMFD sp!, {lr, v1-v4}
	BX lr

; Detect collision of bullet with sand or wall
; Steps:
; 1. Check if enemy is on the wall or next move is on the wall
; 2. If so, create a map of place around it and pick a free spot
; 3. Else, don' actually care
bullet_collision_with_sand_wall
	STMFD sp!, {lr, v1-v4}
	LDR v1, =PUMP_SPRITE
; 1.1.1	Check if  sprite is on wall
	LDR ip, [v1, #X_POS]
	CMP ip, #-1	  				; Check if x == -1
	CMPNE ip, #BOARD_WIDTH	   	; || Check if x == 19
	BEQ bullet_on_wall_sand		; If either, enemy is sitting on the wall

	LDR ip, [v1, #Y_POS]
	CMP ip, #-1	  				; Check if y == -1
	CMPNE ip, #BOARD_HEIGHT	   	; || Check if y == BOARD_HEIGHT
	BEQ bullet_on_wall_sand		; If either, enemy is sitting on the wall

; 1.1.2	Check if sprite is on sand
	LDR a1, [v1, #X_POS]		; Get x coord
	LDR a2, [v1, #Y_POS]		; Get y coord
	BL get_sand_at_xy			; get sand at xy
	CMP a1, #1					; check if there is sand where the sprite is
	BEQ bullet_on_wall_sand		; if there is, enemy is sitting on sand

bullet_on_wall_sand
	; KILL IT
	LDR a1, [v1, #X_POS]
	STR a1, [v1, #OLD_X_POS]
	LDR a2, [v1, #Y_POS]
	STR a2, [v1, #OLD_Y_POS]
	BL get_a_free_direction
	BL move_sprite_given_dir
bullet_not_on_wall_sand
	LDMFD sp!, {lr, v1-v4}
	BX lr 

; Detect fatal collisions (easy case) where the attacker and victim are on the same spot
; A _ V --> _ A/V _
; Attacker:	Bullet always
; Victim:	Enemy sprite
; INPUT:	v1 = SPRITE
;
;
; NOTE: Must be called after sprites are in new position
fatal_collision1_enemy
	STMFD sp!, {lr, v1-v8}
	
	

	LDMFD sp!, {lr, v1-v8}
	BX lr

; Detect fatal collisions (hard case)
; where the attacker and victim are not on the same spot 
; head on collision but they are not on the same spot due to pixels	(ugh)
; _ A V _ --> _ V A _
;
;
; NOTE: call it before sprites move
fatal_collision2_enemy
	STMFD sp!, {lr, v1-v8}
	
	

	LDMFD sp!, {lr, v1-v8}
	BX lr

; Detect fatal collisions (easy case) where the attacker and victim are on the same spot
; A _ V --> _ A/V _
fatal_collision1_dug
	STMFD sp!, {lr, v1-v8}
	
	

	LDMFD sp!, {lr, v1-v8}
	BX lr

; Detect fatal collisions (hard case)
; where the attacker and victim are not on the same spot 
; head on collision but they are not on the same spot due to pixels	(ugh)
; _ A V _ --> _ V A _
fatal_collision2_dug
	STMFD sp!, {lr, v1-v8}
	
	

	LDMFD sp!, {lr, v1-v8}
	BX lr

; Given x, y, and direction, get the next position a sprite will move to
; INPUT:	a1 = x
;			a2 = y
;			a3 = dir
; OUTPUT:	a1 = x
;			a2 = y
	EXPORT	get_next_coordinate
get_next_coordinate	; no need to save or restore if we arent using v1-v8 or BL

	CMP a3, #DIR_UP
	SUBEQ a2, a2, #1	;	If up, decrement y
	CMP a3, #DIR_DOWN
	ADDEQ a2, a2, #1	;	If down, increment y
	CMP a3, #DIR_LEFT
	SUBEQ a1, a1, #1	;	If left, decrement x
	CMP a3, #DIR_RIGHT
	ADDEQ a1, a1, #1	;	If right, increment x

	BX lr
	
	
; Given an x,y, build an obstacle map and get a free direction
; OBSTACLE MAP: 0x	00	00		00		00	 	(LITTLE ENDIAN)
;					UP	DOWN	LEFT	RIGHT
;					0	1		2		3
; INPUT:	a1 = x
;			a2 = y
get_a_free_direction
	STMFD sp!, {lr, v1-v8}
	
	MOV v2, a1	; hold my x
	MOV v3, a2	; hold my y
	MOV v1, #0	; cleared map
	MOV ip, #1	; hold 1 for storage

; 1. Check for sand	around (x,y)

; 1.1 Check to the RIGHT
	MOV ip, #DIR_RIGHT
	LSL ip, ip, #3			; use ip as byte offset
	ADD a1, v2, #1	; x + 1
	MOV a2, v3		; y
	BL get_sand_at_xy	; get sand at (x + 1, y)
	ORREQ v1, v1, a1, LSL ip	; set 3rd byte to value of sand
; 1.1 Check to the LEFT
	MOV ip, #DIR_LEFT
	LSL ip, ip, #3			; use ip as byte offset
	SUB a1, v2, #1	; x - 1
	MOV a2, v3		; y
	BL get_sand_at_xy	; get sand at (x - 1, y)
	ORREQ v1, v1, a1, LSL ip	; set 3rd byte to value of sand
; 1.1 Check to the UP
	MOV ip, #DIR_UP
	LSL ip, ip, #3			; use ip as byte offset
	MOV a1, v2		; x
	SUB a2, v3, #1	; y - 1
	BL get_sand_at_xy	; get sand at (x, y - 1)
	CMP a1, #1		; check if sand
	ORREQ v1, v1, a1, LSL ip	; set 3rd byte to value of sand
; 1.1 Check to the DOWN
	MOV ip, #DIR_DOWN
	LSL ip, ip, #3			; use ip as byte offset	MOV a1, v2		; x
	ADD a2, v3, #1	; y + 1
	BL get_sand_at_xy	; get sand at (x, y + 1)
	CMP a1, #1		; check if sand
	ORREQ v1, v1, a1, LSL ip	; set 3rd byte to value of sand

; 2. 	Check for walls around sprite
	MOV a1, #1
; 2.1	Check for wall at (x + 1, y) RIGHT
	MOV ip, #DIR_RIGHT
	LSL ip, ip, #3
	CMP v2, #18
	ORREQ v1, v1, a1, LSL #DIR_RIGHT	; set 3rd bit to 1 for wall
; 2.2	Check for wall at (x - 1, y) LEFT
	MOV ip, #DIR_LEFT
	LSL ip, ip, #3
	CMP v2, #0
	ORREQ v1, v1, a1, LSL ip		; set 2nd bit to 1 for wall
; 2.3	Check for wall at (x , y + 1) UP
	MOV ip, #DIR_UP
	LSL ip, ip, #3
	CMP v3, #0
	ORREQ v1, v1, a1, LSL ip		; set 0th bit to 1 for wall
; 2.4	Check for wall at (x, y - 1) DOWN
	MOV ip, #DIR_DOWN
	LSL ip, ip, #3
	CMP v3, #14
	ORREQ v1, v1, a1, LSL ip		; set 1st bit to 1 for wall

; As only enemies are gonna call this, I only care about collision with BULLET
; Annoying part of this is that I have to also check 2 spaces away
; Why? Refer to TYPE2 Collisions above or in docs
; 3. Check surrounding for bullet
	LDR v4, =PUMP_SPRITE
; 3.1 Check if pump is within 2 to up or down
; 3.1.1 Checking up
	MOV ip, #DIR_UP
	LSL ip, ip, #3
	LDR a1, [v4, #Y_POS]
	SUB a1, v3, a1			; distance = y - bullet_y	 ( if bullet above, y > bullet_y)
	CMP a1, #2				; check if distance == 2
	CMPNE a1, #1			; || distance == 1
	ORREQ v1, v1, a1, LSL #DIR_UP		; set 1st bit to 1 for bullet
; 3.1.2 Checking down
	MOV ip, #DIR_DOWN
	LSL ip, ip, #3
	LDR a1, [v4, #Y_POS]
	SUB a1, a1, v3			; distance = bullet_y - y	 ( if bullet below, y < bullet_y)
	CMP a1, #2				; check if distance == 2
	CMPNE a1, #1			; || distance == 1
	ORREQ v1, v1, a1, LSL #DIR_DOWN		; set 1st bit to 1 for bullet
; 3.1.2 Checking left
	MOV ip, #DIR_LEFT
	LSL ip, ip, #3
	LDR a1, [v4, #X_POS]
	SUB a1, v2, a1			; distance = x - bullet_x	 ( if bullet left, y > bullet_y)
	CMP a1, #2				; check if distance == 2
	CMPNE a1, #1			; || distance == 1
	ORREQ v1, v1, a1, LSL #DIR_LEFT		; set 1st bit to 1 for bullet
; 3.1.2 Checking right
	MOV ip, #DIR_RIGHT
	LSL ip, ip, #3
	LDR a1, [v4, #X_POS]
	SUB a1, a1, v2			; distance = bullet_x - x	 ( if bullet right, x < bullet_x)
	CMP a1, #2				; check if distance == 2
	CMPNE a1, #1			; || distance == 1
	ORREQ v1, v1, a1, LSL #DIR_RIGHT	; set 1st bit to 1 for bullet	

; Return a OK direction to go based on map	(randomly may do it
obstacle_map_loop
	MOV a1, #2
	BL get_nbit_rand	; get 2 bit random number
   	LSR ip, v1, a1		; set random byte in map as 0th byte
	AND ip, ip, #0xF	; isolate the random byte
	CMP ip, #0			; check if the direction is free
	BNE obstacle_map_loop	; if not free, check again
	; else return direction in a1
	LDMFD sp!, {lr, v1-v8}
	BX lr

; Move given sprite in given direction
; INPUT:	v1 = SPRITE
;			a1 = DIRECTION
	EXPORT	move_sprite_given_dir
move_sprite_given_dir
	STMFD sp!, {lr, v1}
	MOV a3, a1
	LDR a1, [v1, #X_POS]
	STR a1, [v1, #OLD_X_POS]
	LDR a2, [v1, #Y_POS]
	STR a2, [v1, #OLD_Y_POS]
	BL get_next_coordinate
	
	STR a1, [v1, #X_POS] 
	STR a2, [v1, #Y_POS] 
	STR a3, [v1, #DIRECTION] 

	LDMFD sp!, {lr, v1}
	BX lr
	
	
	END
