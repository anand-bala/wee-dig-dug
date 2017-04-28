	AREA peripherals, CODE, READWRITE
	IMPORT LIVES
	IMPORT LEVEL
	IMPORT display_digit_on_7_seg
	EXPORT set_level_disp
	IMPORT DUG_SPRITE
	IMPORT illuminateLEDs
	EXPORT update_peripherals
	IMPORT	illuminate_RGB_LED
	IMPORT PUMP_SPRITE

	IMPORT BEGIN_GAME
	IMPORT PAUSE_GAME
	IMPORT GAME_OVER
	IMPORT RUNNING_P

FLAG
	DCD 0
update_peripherals
	STMFD SP!,{lr, v1,v2}

set_lives_LED
		LDR v1 , =DUG_SPRITE
		LDR ip, [v1,#LIVES]

		RSB ip, ip, #4
		MOV a1, #15
		LSR a1, a1, ip
		BL illuminateLEDs


set_level_disp
	   
	   LDR v1, =LEVEL
	   LDR a1, [v1]
	   BL display_digit_on_7_seg
	  	  
set_rgb_state
; Subroutine:	Manipulate RGB LEDs
; Input:			r0 = enum option as below
; 
; |----------------------------	|
; | ENUM	| COLOR			|	|
; |----------------------------	|
; | 0			| BLACK			|
; | 1			| WHITE			|
; | 2			| RED			|
; | 3			| GREEN			|
; | 4			| BLUE			|
; | 5			| PURPLE		|
; | 6			| YELLOW		|
; | 7			| LIGHT BLUE	|
; |----------------------------	|		
	LDR	 v1, =RUNNING_P
	LDRB v1,[v1]
	CMP v1, #0
	BEQ white
	BNE green
white
	MOV a1, #1	;white
	BL illuminate_RGB_LED
	B check_game_over
green
	MOV a1, #3
	BL illuminate_RGB_LED ;green
 	 ;check for pause
	LDR v1, =PAUSE_GAME
	LDRB v2, [v1]
	CMP v2, #0
	BEQ check_for_shots
	
	MOV a1, #4 ; blue
	BL illuminate_RGB_LED
	BAL	exit

check_for_shots	
	LDR v1, =PUMP_SPRITE
	LDR ip, [v1,#LIVES]
	CMP ip, #1
	BEQ red_or_green
	BNE here
red_or_green	
	LDR v1, =FLAG
	LDRB ip, [v1]
	CMP ip, #0
	BEQ red
	BGT green1
green1
  	MOV a1, #3
	BL illuminate_RGB_LED
	LDR v1, =FLAG
	LDRB ip, [v1]
	MOV ip, #0
	STRB ip, [v1]
	B here	
	
red
	MOV a1, #2
	BL illuminate_RGB_LED
	LDR v1, =FLAG
	LDRB ip, [v1]
	MOV ip, #1
	STRB ip, [v1]
	B here	

here	
	B exit
check_game_over
	LDR v1, =GAME_OVER
	LDRB v1, [v1]
	CMP v1, #1
	MOVEQ a1, #5   ;purple
	BLEQ illuminate_RGB_LED
	
	BNE exit

exit
	LDMFD SP!, {lr, v1,v2}
	BX LR
	END