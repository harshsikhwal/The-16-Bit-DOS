;-----------------------------------------------------------------------------
;ROUTINE TO GET DATE
;-----------------------------------------------------------------------------
MSG_DATE DB 13,10,"CURRENT DATE:",0

;-------------------------------------------------------------------------------
;GET DATE
;--------------------------------------------------------------------------------	


GET_DATE:

	MOV AH,04H
	INT 1AH
	PRINT.STRING MSG_DATE
	

	
	
	BCD.PRINT DL
	MOV AL,'/'
	CALL PRINT_SC
	
	
	
	BCD.PRINT DH
	MOV AL,'/'
	CALL PRINT_SC
	
	
	MOV AL,'2'
	CALL PRINT_SC
	MOV AL,'0'
	CALL PRINT_SC
	BCD.PRINT CL

	JMP trmnl