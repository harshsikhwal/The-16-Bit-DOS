;----------------------------------------------------------------
;READ SECTOR 
;----------------------------------------------------------------

READ_SECTOR:

	MAIN:
		MOV DI,0X0005
	READ_SECTOR_LOOP:
	
		PUSHA
		CALL LBA_TO_CHS
		INT 0X13
		JNC READ_SECTOR_SUCC
		MOV AX,0
		INT 0X13
		DEC DI
		POPA
		JNZ READ_SECTOR_LOOP
		INT 0X18
		
READ_SECTOR_SUCC:
		POPA
		ADD BX,WORD[BYTESPERSECTOR]
		INC AX
		LOOP MAIN
		RET
		
		
;--------------------------------------------------------------------
;LBA TO CHS
;
;ABSOLUTE SECTOR = (LOGICAL TRACK NUMBER/SECTORS PER TRACK) + 1
;ABSOLUTE TRACK  = (LOGICAL TRACK NUMBER/SECTORS PER TRACK) % NUMBER OF HEADS
;ABSOLUTE HEAD   = (LOGICAL TRACK NUMBER/SECTORS PER TRACK) / NUMBER OF HEADS
;
;--------------------------------------------------------------------
		
LBA_TO_CHS:
		
	;Console.print MSG_LBA

	MOV DX,0
	
	DIV WORD[SECTORSPERTRACK]
	INC DL

	MOV CL,DL														;ABSOLUTE SECTOR

	XOR DX,DX
	
	DIV WORD[NUMBEROFHEADS]

	MOV CH,AL														;ABSOLUTE CYLINDER
	MOV DH,DL														;ABSOLUTE HEAD
		
	MOV DL,BYTE[DRIVENUMBER]

	MOV AH,02H
	MOV AL,01H
	
	RET
		

	
LOAD_ROOT:
;----------------------------------------------------------------
;LOAD ROOT DIRECTORY 
;----------------------------------------------------------------

	Console.print MSG_LOAD_ROOT
;SIZE OF ROOT

	XOR CX,CX
	MOV AX,32
	MUL WORD[ROOTENTRIES]
	DIV WORD[BYTESPERSECTOR]
	XCHG AX,CX
	
;START OF ROOT

	MOV AX,WORD[NUMBEROFFAT]
	MUL WORD[SECTORSPERFAT]
	ADD AX,WORD[RESERVEDSECTORS]
	MOV WORD[DATASECTOR],CX
	ADD WORD[DATASECTOR],AX
	
;LOAD AT 1000:0000


	MOV BX,0
	CALL READ_SECTOR
	RET
	
;--------------------------------------------------------------------
;LOAD FAT
;--------------------------------------------------------------------

LOAD_FAT:
	
	Console.print MSG_LOAD_FAT

;GET SIZE OF FAT

	XOR CX,CX
	XOR AX,AX
	MOV AX,WORD[NUMBEROFFATS]
	MUL WORD[SECTORSPERFAT]
	XCHG CX,AX
	
;GET START OF FAT

	XOR AX,AX
	MOV AX,WORD[RESERVEDSECTORS]
	
;LOAD FAT AT 1000:2000
	
	
	
	
	MOV BX,0X2000
	CALL READ_SECTOR
	
	
	
	
	
	
	RET
	
;--------------------------------------------------------------------
;DISPLAY ROOT
;--------------------------------------------------------------------


DISPLAY_ROOT:

	Console.print MSG_ROOT
	
	
	XOR SI,SI
	
	MOV AL,13
	MOV AH,0X0E
	INT 0X10
	MOV AL,10
	INT 0X10
	
	;Console.print MSG_ROOT
	MOV CX,[ROOTENTRIES]
	;MOV AH,0X0E
	

DISPLAY_ROOT_INITIALZE:	

	PUSH CX
	PUSH SI
	MOV CX,11
	
DISPLAY_ROOT_LOOP:
	
	LODSB
	
	CMP CX,0
	JE PRINT_NL
	
	CMP AL,0
	JE DISPLAY_ROOT_DONE
	
	CMP CX,3
	JNE CONTD0
	JE WAIT_FOR_DOT
	
WAIT_FOR_DOT:
		CALL PRINT_EXT
	
CONTD0:	
	
	CMP AL,32
	JE SKIP_SPACE
	JNE CONTD1
	
SKIP_SPACE:	
	
	LOOP DISPLAY_ROOT_LOOP
	
CONTD1:	
	
	
	INT 0X10
	
	LOOP DISPLAY_ROOT_LOOP


PRINT_EXT:
		PUSHA
		MOV AL,46
		INT 0X10
		POPA 
		RET
				
	
DISPLAY_ROOT_DONE:
		;POP DS
		;POPA
		JMP trmnl
	
PRINT_NL:
		
		MOV AL,13
		INT 0X10
		MOV AL,10
		INT 0X10
		
		POP SI
		POP CX
		DEC CX
		CMP CX,0
		JE DISPLAY_ROOT_DONE
		ADD SI,32
		JMP DISPLAY_ROOT_INITIALZE
