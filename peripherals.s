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
update_peripherals
	STMFD SP!,{lr, a1, v1,ip}

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
	LDRB v1, [v1]
	CMP v1, #1
	MOVEQ a1, #4 ; blue
	BLEQ illuminate_RGB_LED
	BNE check_for_shots
check_for_shots
	;todo
	;LDR v1, =PUMP_SPRITE
	;LDR ip, [v1,#LIVES]
	
	B exit
check_game_over
	LDR v1, =GAME_OVER
	LDRB v1, [v1]
	CMP v1, #1
	MOVEQ a1, #5   ;purple
	BLEQ illuminate_RGB_LED
	
	BNE exit

exit
	LDMFD SP!, {lr, a1, v1,ip}
	BX LR
	END