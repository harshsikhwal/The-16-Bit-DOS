;*************************************************************************
;LOAD ROOT AND FAT
;THIS CODE LOADS ROOT DIRECTORY AND FAT FILESYSTEM 

;ROOT IS LOADED AT 1000:0000

;FAT1 IS LOADED AT 1000:1D00
;*************************************************************************



;----------------------------------------------------------------
;FLOPPY CONFIG
;----------------------------------------------------------------
	
	BYTESPERSECTOR     DW 512
	ROOTENTRIES        DW 224
	SECTORSPERFAT      DW 9
	NUMBEROFFATS       DW 2
	RESERVEDSECTORS    DW 1
	SECTORSPERTRACK    DW 18
	NUMBEROFHEADS      DW 2
	DRIVENUMBER        DB 0
	SECTORSPERCLUSTER  DW 1
	NUMBEROFFAT        DW 2
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
		


;--------------------------------------------------------------------
;CLUSTER TO LBA
;
;LBA=(CLUSTER-2)*SECTORS_PER_CLUSTER
;--------------------------------------------------------------------
	
CLUSTER_TO_LBA:
	
	SUB AX,0X0002
	
	MUL WORD[SECTORSPERCLUSTER]
	
	ADD AX,WORD[DATASECTOR]
	RET

;--------------------------------------------------------------------
;FIND STAGE 2 FAILURE
;--------------------------------------------------------------------

FIND_S2_FAILURE:
	CALL FAILURE

;--------------------------------------------------------------------
;FAILURE
;--------------------------------------------------------------------
		
FAILURE:
	PRINT.STRING MSG_PAK
	MOV AX,0
	INT 0X16
	CLI 
	HLT


;----------------------------------------------------------------
;LOAD ROOT DIRECTORY 
;----------------------------------------------------------------

	PRINT.STRING MSG_LOAD_ROOT
;SIZE OF ROOT

	XOR CX,CX
	XOR DX,DX
	MOV AX,0X0020
	MUL WORD[ROOTENTRIES]
	DIV WORD[BYTESPERSECTOR]
	XCHG AX,CX
	
;START OF ROOT

	MOV AX,WORD[NUMBEROFFAT]
	MUL WORD[SECTORSPERFAT]
	ADD AX,WORD[RESERVEDSECTORS]
	MOV WORD[DATASECTOR],AX
	ADD WORD[DATASECTOR],CX
	
;LOAD AT 1000:0000

	MOV AX,1000
	MOV ES,AX
	MOV BX,0
	CALL READ_SECTOR
	

	
;--------------------------------------------------------------------
;FIND STAGE 2
;--------------------------------------------------------------------
	
	
	MOV CX,WORD[ROOTENTRIES]
	MOV DI,0X0000
	
FIND_STAGE2_LOOP:
	PUSH CX
	MOV SI,IMAGENAME
    MOV CX,11
	PUSH DI
	REP CMPSB
	POP DI
	JE LOAD_FAT
	ADD DI,0X0020
	POP CX
	LOOP FIND_STAGE2_LOOP
	JMP FIND_S2_FAILURE

	
;--------------------------------------------------------------------
;LOAD FAT
;--------------------------------------------------------------------

LOAD_FAT:
;GET FIRST CLUSTER
	
	MOV DX,WORD[DI+0X001A]
	MOV WORD[CLUSTER],DX
	
	PRINT.STRING MSG_LOAD_FAT
;GET SIZE OF FAT

	XOR AX,AX
	MOV AX,WORD[NUMBEROFFATS]
	MUL WORD[SECTORSPERFAT]
	XCHG AX,CX
	
;GET START OF FAT

	MOV AX,WORD[RESERVEDSECTORS]
	
;LOAD FAT AT 1000:1D00
	
	MOV AX,1000
	MOV ES,AX
	MOV BX,0X1D00
	CALL READ_SECTOR
	

