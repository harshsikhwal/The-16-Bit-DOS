[ORG 0X7C00]

[BITS 16]

JMP BEGIN
	STRING TIMES 100 DB 0
	STRING1 TIMES 100 DB 0
	STRING2 TIMES 100 DB 0
	MSG1 DB 13,10,"ENTER FISRT STRING:",0
	MSG2 DB 13,10,"ENTER SECOND STRING:",0
	MSG3 DB 13,10,"FIRST STRING:",0
	MSG4 DB 13,10,"SECOND STRING:",0

%MACRO READ.STRING 1
	MOV DI,%1
	PUSHA
	CALL READS
	POPA
%ENDMACRO
	
%MACRO PRINT.STRING 1
		MOV SI,%1
		PUSHA
		CALL PRINTS
		POPA
%ENDMACRO

READS:
READS_LOOP:
		MOV AX,0
		INT 0X16
		CMP AL,0DH
		JE READS_END
		MOV AH,0X0E
		INT 0X10
		STOSB
		JMP READS_LOOP
READS_END:	
		RET
		
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

BEGIN:
	PRINT.STRING MSG1
	READ.STRING STRING1
	PRINT.STRING MSG2
	READ.STRING STRING2
	PRINT.STRING MSG3
	PRINT.STRING STRING1
	PRINT.STRING MSG4
	PRINT.STRING STRING2
	HLT
	
TIMES 510-($-$$)DB 0
DW 0XAA55