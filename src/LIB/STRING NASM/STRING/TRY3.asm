;PROGRAM TO ENTER A STRING AND PRINT IT

[ORG 0X7C00]

[BITS 16]

JMP BEGIN



BEGIN:	MOV DI,STRING
		MOV CX,0

READ:	MOV AX,0
		INT 0X16
		CMP AL,0DH
		JE NEXT
		MOV AH,0X0E
		INT 0X10
		STOSB
		INC CX
		CMP CX,32
		JE NEXT
		JMP READ
		
NEXT:	MOV AL,0
		STOSB
		MOV SI,STRING

WRITE:	MOV AH,0X0E
		LODSB
		CMP AL,0
		JE EXIT
		INT 0X10
		JMP WRITE
		
EXIT:	HLT

STRING TIMES 100 DB 0

TIMES 510-($-$$)DB 0

DW 0XAA55