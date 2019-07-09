[BITS 16]
[ORG 0]

START: JMP BEGIN
	

;----------------------------------------------------------------
;OEM PARAMETER BLOCK 
;----------------------------------------------------------------
	
	OEM                DB "MY   OS "
	
	
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

	TOTALSECTORS       DW 2880  			   
	EXTBOOTSIGNATURE   DB 0x29
	MEDIA       	   DB 0xF8  
	HIDDENSECTORS	   DD 0
	TOTALSECTORSBIG    DD 0
    UNUSED 	     	   DB 0
	SERIALNUMBER:	   DD 0xa0a1a2a3
	VOLUMELABEL 	   DB "MOS FLOPPY "
	FILESYSTEM 	       DB "FAT12   "
	
	
;----------------------------------------------------------------
;SEGMENTS 
;----------------------------------------------------------------

	STACK_SEGMENT 		 DW 1000H
	BOOT_LOADER_SEGMENT  DW 0000H
	


;----------------------------------------------------------------
;PRINT STRING 
;----------------------------------------------------------------
	
	MSG_LOAD_FAT      DB 13,10,"LDFAT12",0
	MSG_LOAD_ROOT     DB 13,10,"LDROOT",0
	MSG_RESET_FLOPPY  DB 13,10,"RST",0
	MSG_FLOPPY_FAIL   DB 13,10,"FLPFAIL",0
	MSG_FLOPPY_SUCC   DB 13,10,"FLPSUCC",0
	MSG_PAK 		  DB 13,10,"PRESS_KEY_EXIT",0
	MSG_GOOD 		  DB 13,10,"SUCCESS!",0
	
;----------------------------------------------------------------
;ADDITIONAL VARIABLES 
;----------------------------------------------------------------

	CLUSTER    DW 0
	DATASECTOR DW 0
	IMAGENAME  DB "KERNEL  SYS"
	
;--------------------------------------------------------------------
;PRINT STRING MACRO
;--------------------------------------------------------------------
		
%MACRO PRINT.STRING 1
		MOV SI,%1
		PUSHA
		CALL PRINTS
		POPA
%ENDMACRO


;--------------------------------------------------------------------
;PRINT STRING ROUTINE
;--------------------------------------------------------------------
		
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
	INT 0X19

;--------------------------------------------------------------------
;BEGIN METHOD
;--------------------------------------------------------------------
	
BEGIN:
	
	
	
	
	CLI										;CLEAR INTERRUPTS

	;PUSH WORD BOOT_LOADER_SEGMENT
	;POP DS									
	
	
	
    MOV AX,0X0000		;SETUP STACK
	MOV SS,AX
	MOV SP,0XFFFF
	
	MOV AX,0X07C0
	MOV DS,AX
	MOV ES,AX
	MOV FS,AX
	MOV GS,AX
											

	
	STI 									;RESTORE INTERRUPTS
	
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
	
;LOAD AT 7C00:0200

	MOV BX,0X0200
	CALL READ_SECTOR
	

	
;--------------------------------------------------------------------
;FIND STAGE 2
;--------------------------------------------------------------------
	
	
	MOV CX,WORD[ROOTENTRIES]
	MOV DI,0X0200
	
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
	
;LOAD FAT AT 7C00:0200

	MOV BX,0X0200
	CALL READ_SECTOR
	

;--------------------------------------------------------------------
;LOAD IMAGE AT 0050:0000
;--------------------------------------------------------------------

	MOV AX,0X0050
	MOV ES,AX
	MOV BX,0X0000
	PUSH BX

	
LOAD_IMAGE:

	MOV AX,WORD[CLUSTER]
	POP BX
	CALL CLUSTER_TO_LBA
	XOR CX,CX
	MOV CX,WORD[SECTORSPERCLUSTER]
	CALL READ_SECTOR
	PUSH BX
	
;COMPUTE NEXT CLUSTER

	MOV AX,WORD[CLUSTER]
	MOV CX,AX
	MOV DX,AX
	SHR DX,0X0001
	ADD CX,DX
	MOV BX,0X0200
	ADD BX,CX
	MOV DX,WORD[BX]
	TEST AX,0X0001
    JNZ ODD_CLUSTER
          
EVEN_CLUSTER:
     
    AND DX,0000111111111111B
    JMP LOAD_SUCCESS   
         
ODD_CLUSTER:
     
    SHR DX,0X0004 
	
	
LOAD_SUCCESS:
     
	MOV WORD[CLUSTER],DX
    CMP DX,0X0FF0                        
    JB LOAD_IMAGE

;--------------------------------------------------------------------
;LOAD KERNEL
;--------------------------------------------------------------------
	
LOAD_KRNL:
	PRINT.STRING MSG_GOOD
	PUSH WORD 0X0050
    PUSH WORD 0X0000
    RETF
	
TIMES 510-($-$$) DB 0
DW 0XAA55