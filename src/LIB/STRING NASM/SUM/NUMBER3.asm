;SUM OF A NUMBER 

[ORG 0X7C00]

[BITS 16]

JMP BEGIN
	NUMBER1 TIMES 20 DB 0
	NUMBER2 TIMES 20 DB 0
	NUMBER TIMES 20 DB 0
	MSG1 DB "ENTER NUMBER 1:",0
	MSG2 DB 13,10,"ENTER NUMBER 2:",0
	MSG3 DB 13,10,"SUM:",0
	
%INCLUDE "C:/LIB/IO.asm"
%INCLUDE "C:/LIB/CNS.asm"

	MOV BP,400
	MOV SP,BP

BEGIN:
	
	PRINT.STRING MSG1
	READ.STRING NUMBER1
	PRINT.STRING MSG2
	READ.STRING NUMBER2
	CONVERT.TO.NUMBER NUMBER1
	CONVERT.TO.NUMBER NUMBER2
	MOV SI,NUMBER1
	LODSB
	MOV BX,AX
	MOV SI,NUMBER2
	LODSB
	ADD AX,BX
	MOV DI,NUMBER
	STOSB
	CONVERT.TO.STRING NUMBER
	PRINT.STRING MSG3
	PRINT.STRING NUMBER
	HLT
	
TIMES 510-($-$$)DB 0
DW 0XAA55