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
	IMPORT	DUG_SPRITE
	IMPORT	FYGAR_SPRITE_1
	IMPORT	POOKA_SPRITE_1
	IMPORT	POOKA_SPRITE_2

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
; 1. Check if bullet is on the wall or next move is on the wall
; 2. If yes, kill bullet
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
	BL kill_sprite
bullet_not_on_wall_sand
	LDMFD sp!, {lr, v1-v4}
	BX lr 

; Detect fatal collisions (easy case) where the attacker and victim are on the same spot
; A _ V --> _ A/V _
; Attacker:     Bullet always
; Victim:       Enemy sprite (input)
; INPUT:        v1 = SPRITE
;
; XXX:
; New way to detect if coordinates are equal:
;	1. Load X coordinate into UPPER half of register.
;	2. Load Y coordinate into LOWER half of register.
;	3. Repeat for second sprite
;	4. Compare values
;
;
; Rationale:
;	Since the value of a coordinate along a single dimension cannot exceed 20 (worst case),
;	all the information for a single coordinate can be stored in less than 1 byte. 
;	So a coordinate pair can easily fit in one word (pfttt).

	EXPORT	fatal_collision1_enemy

fatal_collision1_enemy
	STMFD sp!, {lr, v1-v8}

	; Load coordinates of inputed sprite in a1
	LDR a1, [v1, #X_POS]    ; Load X coordinate
	LSL a1, a1, #16         ; Shift the coordinate to the upper 16 bits
	LDR ip, [v1, #Y_POS]    ; load Y coordinate into ip
	; WHY ip?: Because LDR will erase the contents of a1
	ORR a1, a1, ip          ; ORR the Y coordinates into a1
	; Now we have one coordinate pair ready. Onto the next

	LDR v2, =PUMP_SPRITE
	LDR a2, [v2, #Y_POS]    ; Load Y Coordinate
	LDR ip, [v2, #X_POS]    ; Load X Coordinate into ip
	ORR a2, a2, ip, LSL #16 ; Load X coordinate into upper 16 bits of a2
	; Now our compare values are ready
	; Compare them and check for 2 things:
	; 1. If they are equal, its fatal
	; 2. Else, nothing

	CMP a1, a2              ; Compare a1 a2
	BNE enemy_type1_collision_end ; If the coordinates are not equal, end
	; else, fatal to both the bullet and the enemy

; For fatal collisions.
; 1. Kill the current sprite (v1)
	BL kill_sprite
; 2. Kill the bullet (v2)
	MOV v1, v2              ; Pass v2 as argument in v1
	BL kill_sprite

enemy_type1_collision_end
	LDMFD sp!, {lr, v1-v8}
        BX lr

; Detect fatal collisions (hard case)
; where the attacker and victim are not on the same spot 
; head on collision but they are not on the same spot due to pixels	(ugh)
; _ A V _ --> _ V A _
;
; Since this is for the enemy sprites,
;	Attacker:	Bullet
;	Victim:		Given sprite
;
; Distance = Manhattan Distance = (x1 - x2) + (y1 - y2)
;
;
; Steps:
;	1. Check if the A and V are within 1 of each other ( distance = -1 or 1 )
;	2. Check if old position of A == current position of V
;	3. Check if current position of A == old position of V
;	4. If all of the above are equal, fatal

	EXPORT	fatal_collision2_enemy

fatal_collision2_enemy
	STMFD sp!, {lr, v1-v8}

	LDR v2, =PUMP_SPRITE

; 1. Check if A and V are within 1 of each other
	LDR a1, [v1, #X_POS]	; Load X Position of v1
	LDR ip, [v2, #X_POS]	; Load X Position of v2
	SUB a1, a1, ip		; x_ = x(v1) - x(v2)

	LDR a2, [v1, #Y_POS]	; Load Y Position of v1
	LDR ip, [v2, #Y_POS]	; Load Y Position of v2
	SUB a2, a2, ip		; y_ = y(v1) - y(v2)

	ADD a1, a1, a2		; a1 = x_ + y_
	CMP a1, #1		; check if distance == 1
	CMPNE a1, #-1		; OR, check if distance == -1
	BNE enemy_type2_collision_end	; If neither, end

; 2. Check if old position of v2 == current position of v1
	LDR a1, [v1, #Y_POS]		; Load y(v1)
	LDR ip, [v1, #X_POS]		; Load x(v1)
	ORR a1, a1, ip, LSL #16		; Load x(v1) into upper 16 bits of a1

	LDR a2, [v2, #OLD_Y_POS]	; Load old_y(v2)
	LDR ip, [v2, #OLD_X_POS]	; Load old_x(v2)
	ORR a2, a2, ip, LSL #16		; Load old_x(v2) into upper 16 bits of a2

	CMP a1, a2			; Compare coordinates
	BNE enemy_type2_collision_end	; If not equal, end

; 3. Check if pos(v2) == old_pos(v1)
	LDR a1, [v1, #OLD_Y_POS]	; Load old_y(v1)
	LDR ip, [v1, #OLD_X_POS]	; Load old_x(v1)
	ORR a1, a1, ip, LSL #16		; Load old_x(v1) into upper 16 bits of a1

	LDR a2, [v2, #Y_POS]		; Load y(v2)
	LDR ip, [v2, #X_POS]		; Load x(v2)
	ORR a2, a2, ip, LSL #16		; Load x(v2) into upper 16 bits of a2

	CMP a1, a2			; Compare coordinates
	BNE enemy_type2_collision_end	; If not equal, end

; 4. If all pass, kill current sprite and bullet
	BL kill_sprite			; Kill current sprite
	MOV v1, v2			; Load PUMP_SPRITE as argument
	BL kill_sprit			; Kill the PUMP spritee

enemy_type2_collision_end
	LDMFD sp!, {lr, v1-v8}
	BX lr

; Detect fatal collisions (easy case) where the attacker and victim are on the same spot
; A _ V --> _ A/V _
;
; To check for TYPE1 fatal collision for DUG, the attacker can be either FYGAR, POOKA1 or POOKA2.
; So we need to see if any one of them have the same coordinates as DUG.
;
; NO INPUTS
;
fatal_collision1_dug
	STMFD sp!, {lr, v1-v8}

;	DEV RULES:
;	v1 = DUG
;	a1 = DUG coordinates
;	v2 = Other sprite
;	a2 = coordinates of other sprite
;	ip = intermediate values (dont use for anything signigicant)

; 0.	Load DUG into v1 and his coordinates into a1
	LDR v1, =DUG_SPRITE
	LDR a1, [v1, #Y_POS]		; Load Y into a1
	LDR ip, [v1, #X_POS]		; Load X into ip
	ORR a1, a1, ip, LSL #16		; Load X into upper half of a1

; 1.	Check if collision with FYGAR
; 1.1.	Load FYGAR and his coordinates
	LDR v2, =FYGAR_SPRITE_1
	LDR a2, [v2, #Y_POS]		; Load Y into a2
	LDR ip, [v2, #X_POS]		; Load X into ip
	ORR a2, a2, ip, LSL #16		; Load X into upper half of a2
; 1.2.	Compare a1 and a2. If equal, the thing is fatal
	CMP a1, a2
	BEQ dug_type1_collision_fatal	; EQ => fatal

; 2.	Check if collision with POOKA1
; 2.1.	Load POOKA1 and its coordinates
	LDR v2, =POOKA_SPRITE_1
	LDR a2, [v2, #Y_POS]		; Load Y into a2
	LDR ip, [v2, #X_POS]		; Load X into ip
	ORR a2, a2, ip, LSL #16		; Load X into upper half of a2
; 2.2.	Compare a1 and a2. If equal, the thing is fatal
	CMP a1, a2
	BEQ dug_type1_collision_fatal	; EQ => fatal

; 3.	Check if collision with POOKA2
; 3.1.	Load POOKA2 and his coordinates
	LDR v2, =POOKA_SPRITE_2
	LDR a2, [v2, #Y_POS]		; Load Y into a2
	LDR ip, [v2, #X_POS]		; Load X into ip
	ORR a2, a2, ip, LSL #16		; Load X into upper half of a2
; 3.2.	Compare a1 and a2. If equal, the thing is fatal
	CMP a1, a2
	BEQ dug_type1_collision_fatal	; EQ => fatal

; If nothing is colliding, just end
	BAL dug_type1_collision_end
; ELSE: FATAL!!!!
dug_type1_collision_fatal
; If fatal, do the following:
; 1. Kill DUG
; 2. respawn DUG and other sprites
; 3. Check if Game Over: Trigger Game Over

	BL kill_sprite
	BL respawn_game_sprites
	LDR ip, [v1, #LIVES]
	CMP ip, #0
	BLEQ model_game_over
dug_type1_collision_end
	LDMFD sp!, {lr, v1-v8}
	BX lr

; Detect fatal collisions (hard case)
; where the attacker and victim are not on the same spot 
; head on collision but they are not on the same spot due to pixels	(ugh)
; _ A V _ --> _ V A _
; For each enemy:
; 1. Check if old_pos(A) == cur_pos(V)
; 2. && Check if old_pos(V) == cur_pos(A)
; 3. If so, fatal
; 4. Else, do nothing
;
;
; NO INPUT
fatal_collision2_dug
	STMFD sp!, {lr, v1-v8}

; DEV RULES:
;	v1 = DUG SPRITE
;	a1 = DUG's current position
;	a2 = DUG's old position
;
;	v2 = Other Sprites
;	a3 = Current position
;	a4 = Old Position

; 0.	Load DUG into v1 and coordinates into a1
	LDR v1, =DUG_SPRITE

	LDR a1, [v1, #Y_POS]
	LDR ip, [v1, #X_POS]
	ORR a1, a1, ip, LSL #16		; Load DUG's coordinates into a1

	LDR a2, [v1, #OLD_Y_POS]
	LDR ip, [v1, #OLD_X_POS]
	ORR a2, a2, ip, LSL #16		; Load DUG's old coordinates into a2

; 1.	Check for collision with FYGAR
; 1.1.	Load FYGAR's coordinates, old and current
	LDR v2, =FYGAR_SPRITE_1

	LDR a3, [v2, #Y_POS]
	LDR ip, [v2, #X_POS]
	ORR a3, a3, ip, LSL #16		; Load current coordinates into a3

	LDR a4, [v2, #OLD_Y_POS]
	LDR ip, [v2, #OLD_X_POS]
	ORR a4, a4, ip, LSL #16		; Load old coordinates into a4

; 1.2.	Compare coordinates
	CMP a1, a4			; Compare cur_pos(v1) & old_pos(v2)
	CMPEQ a2, a3			; If equal, compare old_pos(v1) & cur_pos(v2)
	BEQ dug_type2_collision_fatal	; If both are equal, fatal
	; Else check the next sprite
; 2.	Check for collision with POOKA1
; 2.1.	Load POOKA1's coordinates, old and current
	LDR v2, =POOKA_SPRITE_1

	LDR a3, [v2, #Y_POS]
	LDR ip, [v2, #X_POS]
	ORR a3, a3, ip, LSL #16		; Load current coordinates into a3

	LDR a4, [v2, #OLD_Y_POS]
	LDR ip, [v2, #OLD_X_POS]
	ORR a4, a4, ip, LSL #16		; Load old coordinates into a4

; 2.2.	Compare coordinates
	CMP a1, a4			; Compare cur_pos(v1) & old_pos(v2)
	CMPEQ a2, a3			; If equal, compare old_pos(v1) & cur_pos(v2)
	BEQ dug_type2_collision_fatal	; If both are equal, fatal
	; Else check the next sprite
; 3.	Check for collision with POOKA2
; 3.1.	Load POOKA2's coordinates, old and current
	LDR v2, =POOKA_SPRITE_2

	LDR a3, [v2, #Y_POS]
	LDR ip, [v2, #X_POS]
	ORR a3, a3, ip, LSL #16		; Load current coordinates into a3

	LDR a4, [v2, #OLD_Y_POS]
	LDR ip, [v2, #OLD_X_POS]
	ORR a4, a4, ip, LSL #16		; Load old coordinates into a4

; 3.2.	Compare coordinates
	CMP a1, a4			; Compare cur_pos(v1) & old_pos(v2)
	CMPEQ a2, a3			; If equal, compare old_pos(v1) & cur_pos(v2)
	BEQ dug_type2_collision_fatal	; If both are equal, fatal
	; Else end (coz no more sprites)
	BAL dug_type2_collision_end 

dug_type2_collision_fatal
; So, collision was fatal. What are we going to do?
; 1. Kill DUG.
; 2. Respawn dug
; 3. Check if game over: trigger game over
	BL kill_sprite
	BL respawn_game_sprites
	LDR ip, [v1, #LIVES]
	CMP ip, #0
	BLEQ model_game_over
dug_type2_collision_end
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
; OBSTACLE MAP: 
;0x     00      00      00      00      (LITTLE ENDIAN)
;       UP      DOWN    LEFT    RIGHT
;       0       1       2       3
; INPUT:        a1 = x
;               a2 = y
get_a_free_direction
	STMFD sp!, {lr, v1-v8}
	
	MOV v2, a1	; hold my x
	MOV v3, a2	; hold my y
	MOV v1, #0	; cleared map
	MOV v4, #1	; hold 1 for storage

; 1. Check for sand around (x,y)

; 1.1 Check to the RIGHT
	MOV ip, #DIR_RIGHT
	LSL ip, ip, #3			; use ip as byte offset
	ADD a1, v2, #1	; x + 1
	MOV a2, v3		; y
	BL get_sand_at_xy	; get sand at (x + 1, y)
	ORR v1, v1, a1, LSL ip	; set 3rd byte to value of sand
; 1.1 Check to the LEFT
	MOV ip, #DIR_LEFT
	LSL ip, ip, #3			; use ip as byte offset
	SUB a1, v2, #1	; x - 1
	MOV a2, v3		; y
	BL get_sand_at_xy	; get sand at (x - 1, y)
	ORR v1, v1, a1, LSL ip	; set 3rd byte to value of sand
; 1.1 Check to the UP
	MOV ip, #DIR_UP
	LSL ip, ip, #3			; use ip as byte offset
	MOV a1, v2		; x
	SUB a2, v3, #1	; y - 1
	BL get_sand_at_xy	; get sand at (x, y - 1)
	ORR v1, v1, a1, LSL ip	; set 3rd byte to value of sand
; 1.1 Check to the DOWN
	MOV ip, #DIR_DOWN
	LSL ip, ip, #3			; use ip as byte offset	MOV a1, v2		; x
	ADD a2, v3, #1	; y + 1
	BL get_sand_at_xy	; get sand at (x, y + 1)
	ORR v1, v1, a1, LSL ip	; set 3rd byte to value of sand

; 2. 	Check for walls around sprite
	MOV a1, #1
; 2.1	Check for wall at (x + 1, y) RIGHT
	MOV ip, #DIR_RIGHT
	LSL ip, ip, #3
	CMP v2, #18
	ORREQ v1, v1, a1, LSL ip	; set 3rd bit to 1 for wall
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

; Return a OK direction to go based on map	(randomly may do it	?)
	MOV a1, #0
obstacle_map_loop
	LSR ip, v1, a1		; set random byte in map as 0th byte
	AND ip, ip, #0xF	; isolate the first byte
	ADD a1, a1, #1
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
