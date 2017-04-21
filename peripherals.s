	AREA peripherals, CODE, READWRITE
	IMPORT LIVES
	IMPORT LEVEL
	IMPORT display_digit_on_7_seg
	EXPORT set_level_disp
	IMPORT DUG_SPRITE
	IMPORT illuminateLEDs
	EXPORT update_peripherals

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
	
	LDMFD SP!, {lr, a1, v1,ip}
	BX LR
	END