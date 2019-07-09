%MACRO READ.STRING 1
	MOV DI,%1
	PUSHA
	CALL READS
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
	
	
;-----------------------------------------------------------------------
;PRINT STRING
;-----------------------------------------------------------------------	
	
	
%MACRO PRINT.STRING 1
		MOV SI,%1
		PUSHA
		CALL PRINTS
		POPA
%ENDMACRO


		
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

		
		
;-----------------------------------------------------------------------------
;PRINT SINGLE CHARACTER
;----------------------------------------------------------------------------
		
PRINT_SC:

	MOV AH,0X0E
	INT 0X10
	RET
	
	
	
;-----------------------------------------------------------------------------
;BCD PRINT
;-----------------------------------------------------------------------------

%MACRO BCD.PRINT 1
	;HOUR
	MOV AL,0
	MOV [TEMP],%1
	AND %1,11110000B
	SHR %1,4
	MOV AL,%1
	ADD AL,48
	CALL PRINT_SC
	
	MOV AL,0
	MOV %1,[TEMP]
	AND %1,00001111B
	MOV AL,%1
	ADD AL,48
	CALL PRINT_SC
%ENDMACRO
	
		