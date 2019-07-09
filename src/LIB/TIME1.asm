
	;MSG_GMT DB 13,10,"GMT:",0
	MSG_TIME 	  DB 13,10,"CURRENT TIME IS:",13,10,0
	
	MSG_SET_TIME  DB 13,10,"ENTER NEW TIME (IN 24 HOUR FORMAT):",0
	MSG_SET_H 	  DB 13,10,"HOURS    (0-23):",0
	MSG_SET_M 	  DB 13,10,"MINUTES  (0-59):",0
	MSG_SET_S 	  DB 13,10,"SECONDS  (0-59):",0
	
	MSG_SETT_SUCC DB 13,10,"TIME SET!",13,10,0
	MSG_INV	      DB 13,10,"INVALID INPUT",13,10,0

	
	;UPPER DB 0
	;LOWER DB 0
	TEMP DB 0

	HOURS TIMES 10 DB 0
	MINUTES TIMES 10 DB 0
	SECONDS TIMES 10 DB 0
	
	DAYS DB 0
	

	


;-----------------------------------------------------------------------------
;FLUSH
;-----------------------------------------------------------------------------


%MACRO FLUSH 1
	MOV DI,%1
	CALL FLUSH_INP
%ENDMACRO
	
FLUSH_INP:

	MOV AL,0
	STOSB
	LOOP FLUSH_INP
	RET

;-----------------------------------------------------------------------------
;GET TIME
;-----------------------------------------------------------------------------


GET_TIME:

	MOV AH,02H
	INT 1AH
	Console.print MSG_TIME
	
	MOV [HOURS],CH
	MOV [MINUTES],CL
	MOV [SECONDS],DH

	BCD.PRINT CH
	MOV AL,':'
	CALL PRINT_SC
	
	BCD.PRINT CL
	MOV AL,':'
	CALL PRINT_SC
	
	BCD.PRINT DH
	JMP trmnl
	

;--------------------------------------------------------------------------------
;SET TIME
;--------------------------------------------------------------------------------

SET_TIME:


	MOV CX,10
	FLUSH HOURS
	
	MOV CX,10
	FLUSH MINUTES
	
	MOV CX,10
	FLUSH SECONDS
	





	Console.print MSG_SET_TIME
	
SET_HOURS:	
	
	
	Console.print MSG_SET_H
	Console.read HOURS
	
	STRING.TO.NUMBER HOURS
	
	;Console.print HOURS
	
	MOV AH,[HOURS]
	
	CMP AH,24
	JGE INVALIDH
	
	NUMBER.TO.STRING HOURS
	;Console.print HOURS	
		
		
SET_MINUTES:		
		
	Console.print MSG_SET_M
	Console.read MINUTES
	
	STRING.TO.NUMBER MINUTES
	
	;Console.print MINUTES
	
	MOV AH,[MINUTES]
	
	CMP AH,60
	JGE INVALIDM
	
	NUMBER.TO.STRING MINUTES
	;Console.print MINUTES	

SET_SECONDS:	
	
	Console.print MSG_SET_S
	Console.read SECONDS
	
	STRING.TO.NUMBER SECONDS
	
	;Console.print SECONDS
	
	MOV AH,[SECONDS]
	
	
	
	CMP AH,60
	JGE INVALIDS
	NUMBER.TO.STRING SECONDS
	;Console.print SECONDS
	
	
	JMP C2BCD

		
INVALIDH:

	Console.print MSG_INV
	JMP SET_HOURS
	
INVALIDM:

	Console.print MSG_INV
	JMP SET_MINUTES
	
INVALIDS:

	Console.print MSG_INV
	JMP SET_SECONDS	
	
C2BCD:

	STRING.TO.BCD8 HOURS
	MOV CH,AL
	
	STRING.TO.BCD8 MINUTES
	MOV CL,AL
	
	STRING.TO.BCD8 SECONDS
	MOV DH,AL
	
	MOV AH,03H
	INT 1AH
	
	Console.print MSG_SETT_SUCC
	
	JMP trmnl