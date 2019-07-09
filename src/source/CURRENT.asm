[BITS 16]
[ORG 0X7C00]

JMP BEGIN
	

;----------------------------------------------------------------
;OEM PARAMETER BLOCK 
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

;----------------------------------------------------------------
;SEGMENTS 
;----------------------------------------------------------------

	STACK_SEGMENT 		 DW 1000H
	BOOT_LOADER_SEGMENT  DW 0000H
	


;----------------------------------------------------------------
;PRINT STRING 
;----------------------------------------------------------------
	
	MSG_LOAD_IMG      DB 13,10,"LOADING IMAGE.",0
	MSG_LOAD_FAT      DB 13,10,"LOADING FAT12.",0
	MSG_GET_CLS       DB 13,10,"ACQUIRING FIRST CLUSTER.",0
	MSG_FS2           DB 13,10,"FINDING STAGE 2.",0
	MSG_LOAD_ROOT     DB 13,10,"LOADING ROOT DIRECTORY.",0
	MSG_LBA 		  DB 13,10,"CONVERTING LBA TO CHS.",0
	MSG_RESET_FLOPPY  DB 13,10,"RESET FLOPPY!",0
	MSG_FLOPPY_FAIL   DB 13,10,"FLOPPY DISK FAILURE!",0
	MSG_FS2_FAILURE   DB 13,10,"STAGE 2 NOT FOUND!",0
	MSG_FLOPPY_SUCC   DB 13,10,"FLOPPY DISK SUCCESS!",0
	MSG_SS 			  DB 13,10,"SETTING UP STACK.",0
	MSG_BLS 		  DB 13,10,"SETTING BOOTLOADER SEGMENT.",0
	MSG_PAK 		  DB 13,10,"PRESS ANY KEY TO EXIT....",0
	MSG_GOOD 		  DB 13,10,"SUCCESSFUL! JUMPING TO STAGE2!",0
	
;----------------------------------------------------------------
;ADDITIONAL VARIABLES 
;----------------------------------------------------------------

	CLUSTER    DW 0
	DATASECTOR DW 0
	IMAGENAME  DB "KERNEL  SYS"
	
;--------------------------------------------------------------------
;READ STRING MACRO
;--------------------------------------------------------------------
	
%MACRO READ.STRING 1
	MOV DI,%1
	PUSHA
	CALL READS
	POPA
%ENDMACRO
	
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
;READ STRING ROUTINE
;--------------------------------------------------------------------
	
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
		CALL LBA_TO_CHS
		INT 0X13
		JNC READ_SECTOR_SUCC
		JC RESET_FLOPPY
		JMP READ_SECTOR
	
READ_SECTOR_SUCC
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
		
	PRINT.STRING MSG_LBA

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
;RESET FLOPPY
;--------------------------------------------------------------------
	
RESET_FLOPPY:
	PUSH CX
	MOV CX,5
	
RESET_FLOPPY_LOOP:
	PRINT.STRING MSG_RESET_FLOPPY
	;CLC
	MOV DL,[DRIVENUMBER]
	MOV AH,0
	INT 0X13
	DEC CX
	JCXZ FLOPPY_FAIL
	JNC FLOPPY_SUCC
	JC RESET_FLOPPY_LOOP
	
FLOPPY_FAIL:
	PRINT.STRING MSG_FLOPPY_FAIL
	CALL FAILURE
	
FLOPPY_SUCC:
	PRINT.STRING MSG_FLOPPY_SUCC
	POP CX
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

FIND_STAGE2_FAILURE:
	PRINT.STRING MSG_FS2_FAILURE
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

;--------------------------------------------------------------------
;BEGIN METHOD
;--------------------------------------------------------------------
	
BEGIN:
	
	PRINT.STRING MSG_SS							;PRINT STACK SEGMENT
	
	
	
	CLI										;CLEAR INTERRUPTS

	;PUSH WORD BOOT_LOADER_SEGMENT
	;POP DS									
	
	
	
	PUSH WORD[STACK_SEGMENT]
	POP SS									;SETUP STACK
	MOV SP,0XFFFF
	
	PUSH WORD[BOOT_LOADER_SEGMENT]
	POP AX
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
	MOV AX,0X0020
	MUL WORD[ROOTENTRIES]
	DIV WORD[BYTESPERSECTOR]
	XCHG AX,CX
	
;START OF ROOT

	MOV AX,WORD[NUMBEROFFAT]
	MUL WORD[SECTORSPERFAT]
	ADD AX,WORD[RESERVEDSECTORS]
	MOV WORD[DATASECTOR],CX
	ADD WORD[DATASECTOR],AX
	
;LOAD AT 0000:0200

	MOV BX,0X0200
	CALL READ_SECTOR
	

	
;--------------------------------------------------------------------
;FIND STAGE 2
;--------------------------------------------------------------------
	
	PRINT.STRING MSG_FS2
	
	MOV CX,WORD[ROOTENTRIES]
	MOV DI,0X0200
	
FIND_STAGE2_LOOP:
	PUSH CX
	MOV SI,IMAGENAME
    MOV CX,0X000B	
	PUSH DI
	REP CMPSB
	POP DI
	JZ LOAD_FAT
	ADD DI,0X0020
	POP CX
	LOOP FIND_STAGE2_LOOP
	JMP FIND_S2_FAILURE

	
;--------------------------------------------------------------------
;LOAD FAT
;--------------------------------------------------------------------

;GET FIRST CLUSTER
	
	PRINT.STRING MSG_GET_CLS
	MOV DX,[DI+0X001A]
	MOV WORD[CLUSTER],DX
	
	PRINT.STRING MSG_LOAD_FAT
;GET SIZE OF FAT

	MOV AX,WORD[NUMBEROFFATS]
	MUL WORD[SECTORSPERFAT]
	XCHG AX,CX
	
;GET START OF FAT

	MOV AX,WORD[RESERVEDSECTOR]
	
;LOAD FAT AT 0000:1E00

	MOV BX,0X1E00
	CALL READ_SECTOR
	

;--------------------------------------------------------------------
;LOAD IMAGE AT 2000:0000
;--------------------------------------------------------------------

	MOV AX,0X2000
	MOV ES,AX
	MOV BX,0000H
	PUSH BX

	PRINT.STRING MSG_LOAD_IMG
	
LOAD_IMAGE:

	MOV AX,WORD[CLUSTER]
	POP BX
	CALL CLUSTER_TO_LBA
	CALL READ_SECTORS
	PUSH BX
	
;COMPUTE NEXT CLUSTER

	MOV AX,WORD[CLUSTER]
	MOV CX,AX
	MOV DX,AX
	SHR DX,0X0001
	ADD CX,DX
	MOV BX,0X1E00
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
    JNE LOAD_IMAGE

;--------------------------------------------------------------------
;LOAD KERNEL
;--------------------------------------------------------------------
	
LOAD_KRNL:
	PRINT.STRING MSG_GOOD
	PUSH WORD 0X2000
    PUSH WORD 0X0000
    RETF
	
TIMES 510-($-$$) DB 0
DW 0XAA55