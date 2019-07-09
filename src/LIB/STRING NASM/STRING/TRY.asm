;PROGRAM TO PRINT A STRING

[ORG 0x7C00]

[BITS 16]

JMP BEGIN

BEGIN:
		MOV AH,0X0E
		MOV SI,STRING
	
LOOP:	
		LODSB
		CMP AL,0
		JE EXIT
		INT 0X10
		JMP SHORT LOOP
		
EXIT:	
		HLT
		
STRING DB "HELLO",13," WORLD",0

TIMES 510-($-$$) DB 0

DW 0XAA55