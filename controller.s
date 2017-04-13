	AREA controller, CODE, READWRITE
	EXPORT	weedigdug
	EXPORT	FIQ_Handler

	IMPORT	pin_connect_block_setup
	IMPORT	uart_init
	IMPORT	timer_init
	IMPORT	interrupt_init
	IMPORT	interrupt_disable

	IMPORT	read_timer0
	
	IMPORT	clear_7_seg
	IMPORT	display_digit_on_7_seg
	IMPORT	output_string
	IMPORT	output_character
	IMPORT	read_character
	IMPORT	num_to_dec_str
	
	IMPORT	get_nbit_rand

	IMPORT	U0IER	
	IMPORT	U0IIR
	IMPORT	EXTINT
	IMPORT	INTBASE
	IMPORT	INT_CR
	IMPORT	INT_ER
	IMPORT	INT_SR
	
	IMPORT	update_board	


HALF_SEC	DCD	0x8CA000

weedigdug
	STMFD sp!, {lr}
	BL pin_connect_block_setup
	BL uart_init
	BL interrupt_init
	
	LDR v1, =HALF_SEC
	LDR r0, [v1]
	BL timer_init
	MOV r0, #12
	BL output_character

	BL update_board

	LDMFD sp!, {lr}
	BX lr

FIQ_Handler
		STMFD SP!, {r0-r12, lr}  	; Save registers r0-r12, lr

TIMER0_Interrupt
		LDR r0, =0xE0004000
		LDR r1, [r0]
		TST r1, #0x2
		BEQ EINT1_interrupt

		STMFD SP!, {r0-r12, lr}   	; Save registers r0-r12, lr
		; Timer0 interrupt

		LDMFD SP!, {r0-r12, lr}   ; Restore registers r0-r12, lr
		
		ORR r1, r1, #2		; Clear Interrupt by OR-ing value from 0xE0004000 (r1) with #2
		STR r1, [r0]	   	; store clear value (r1) into 0xE0004000 (r0)

EINT1_interrupt	; Check for EINT1 interrupt
		LDR r0, =0xE01FC140			; load 0xE01FC140 as address
		LDR r1, [r0]			  	; load value from 0xE01FC140
		TST r1, #2				  	; test value with #2
		BEQ U0RDA				  	; branch if eq to handle UART0 instead
	
		STMFD SP!, {r0-r12, lr}   	; Save registers r0-r12, lr 
			
		; Push button EINT1 Handling Code

EINT1_end	

		LDMFD SP!, {r0-r12, lr}   ; Restore registers r0-r12, lr
		
		ORR r1, r1, #2		; Clear Interrupt by OR-ing value from 0xE01FC140 (r1) with #2
		STR r1, [r0]	   	; store clear value (r1) into 0xE01FC140 (r0)

U0RDA	; UART0 RDA interrupts
		LDR r0, =U0IIR			; Load U0IIR address
		LDR r1, [r0]		  	; Load values in U0IIR
		TST r1, #1			  	; Test values against #1
		BNE FIQ_Exit		  	; FIQ_Exit if not equal

		; UART interrupt handler
		



		STMFD SP!, {r0-r12, lr}   	; Save registers r0-12 & lr

U0RDA_end
		LDMFD SP!, {r0-r12, lr}   	; Restore registers r0-r12, lr	

FIQ_Exit
		LDMFD SP!, {r0-r12, lr}	  	; Restore registers r0-r12, lr	
		SUBS pc, lr, #4				; pc = lr - 4


	END