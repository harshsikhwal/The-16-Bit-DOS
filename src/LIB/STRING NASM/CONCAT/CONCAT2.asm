[ORG 0X7C00]

[BITS 16]

JMP BEGIN
	STRING TIMES 100 DB 0
	STRING1 TIMES 100 DB 0
	STRING2 TIMES 100 DB 0
	MSG1 DB 13,10,"ENTER FISRT STRING:",0
	MSG2 DB 13,10,"ENTER SECOND STRING:",0
	MSG3 DB 13,10,"CONCATENATED STRING:",0

%MACRO PRINT.STRING 1
		MOV SI,%1
		PUSHA
		CALL PRINTS
		POPA
%ENDMACRO

PRINTS:
LOOPP:
		MOV AH,0X0E
		LODSB
		CMP AL,0
		JE LOOP_DONE
		INT 0X10
		JMP LOOPP
LOOP_DONE:
		RET
BEGIN:
		MOV DI,STRING1
		PRINT.STRING MSG1
	
READ1:
		MOV AX,0
		INT 0X16
		CMP AL,0DH
		JE NEXT1
		STOSB
		MOV AH,0X0E
		INT 0X10
		JMP READ1

NEXT1:	MOV AL,0
		STOSB
		MOV DI,STRING2
		PRINT.STRING MSG2
		
READ2:	MOV AX,0
		INT 0X16
		CMP AL,0DH
		JE NEXT2
		STOSB
		MOV AH,0X0E
		INT 0X10
		JMP READ2
		
NEXT2:	MOV AL,0
		STOSB
		MOV SI,STRING1
		MOV DI,STRING
		
TRAVERSE1:
		LODSB
		CMP AL,0
		JE NEXT3
		STOSB
		JMP TRAVERSE1
		
NEXT3:	MOV AL,32
		STOSB
		MOV SI,STRING2
		
TRAVERSE2:
		LODSB
		CMP AL,0
		JE NEXT4
		STOSB
		JMP TRAVERSE2
		
NEXT4:	PRINT.STRING MSG3
		PRINT.STRING STRING 
		HLT
		
TIMES 510-($-$$)DB 0
DW 0XAA55