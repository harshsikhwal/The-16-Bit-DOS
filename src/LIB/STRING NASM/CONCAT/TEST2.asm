[ORG 0X7C00]

[BITS 16]

JMP BEGIN
	
%INCLUDE "C:/LIB/IO.asm"
%INCLUDE "C:/LIB/CONCAT.asm"

	STRING TIMES 20 DB 0
	STRING1 TIMES 20 DB 0
	STRING2 TIMES 20 DB 0
	STRING3 TIMES 20 DB 0
	STRING4 TIMES 20 DB 0
	MSG1 DB 13,10,"ENTER FISRT STRING:",0
	MSG2 DB 13,10,"ENTER SECOND STRING:",0
	
	MSG3 DB 13,10,"ENTER THIRD STRING:",0
	MSG4 DB 13,10,"ENTER FOURTH STRING:",0
	MSG5 DB 13,10,"FIRST STRING:",0
	MSG6 DB 13,10,"SECOND STRING:",0
	MSG7 DB 13,10,"THIRD STRING:",0
	MSG8 DB 13,10,"FOURTH STRING:",0
	MSG9 DB 13,10,"CONCATENATED STRING:",0
	
BEGIN:
	PRINT.STRING MSG1
	READ.STRING STRING1
	PRINT.STRING MSG2
	READ.STRING STRING2
	PRINT.STRING MSG3
	READ.STRING STRING3
	PRINT.STRING MSG4
	READ.STRING STRING4
	
	PRINT.STRING MSG5
	PRINT.STRING STRING1
	PRINT.STRING MSG6
	PRINT.STRING STRING2
	PRINT.STRING MSG7
	PRINT.STRING STRING3
	PRINT.STRING MSG8
	PRINT.STRING STRING4
	
	
	
	
	CONCAT STRING1,STRING2,STRING3,STRING4
	PRINT.STRING MSG9
	PRINT.STRING STRING1
	
	HLT
	
TIMES 510-($-$$)DB 0
DW 0XAA55