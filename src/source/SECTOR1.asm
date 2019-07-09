;CODE FOR SECTOR 1
;WILL BE LOADED BY OUR BOOTLOADER

;LOAD AT 0X0000

[BITS 16]
[ORG 0]

JMP MAIN

	MSG_HW DB 13,10,"HELLO WORLD!",0
	MSG_PS DB 13,10,"PRESS ANY KEY TO EXIT.....",0


;--------------------------------------------------------------------
;PRINT STRING MACRO
;--------------------------------------------------------------------
		
	
%MACRO PRINT.STRING 1
		MOV SI,%1
		PUSHA
		CALL PRINTS
		POPA
%ENDMACRO


		
;--------------------------------------------------------------------
;PRINT STRING ROUTINE
;--------------------------------------------------------------------
	
		
PRINTS:
PRINTS_LOOP:
		MOV AH,0X0E
		LODSB
		CMP AL,0
		JE PRINTS_END
		INT 0X10
		JMP PRINTS_LOOP
PRINTS_END:
		RET


MAIN:
		CLI
		;MOV AX,0X2000
		;MOV CS,AX
		PUSH CS
		POP DS
		STI
		
		PRINT.STRING MSG_HW
		PRINT.STRING MSG_PS
		
		MOV AX,0
		INT 0X16
		CMP AX,0
		JNZ SHUT_DOWN
		
SHUT_DOWN:
		
		CLI
		HLT