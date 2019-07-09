[BITS 16]
[ORG 0X7C00]

JMP BEGIN
	
	STACK_SEGMENT 		 DW 1000H
	PRINT_SEGMENT 		 DW 2000H
	BOOT_LOADER_SEGMENT  DW 0000H
	
	
	SECTORSPERTRACK DW 18
	NUMBEROFHEADS DW 2
	DRIVENUMBER DB 0
	SECTOR_TO_READ DW 2
	
	
	MSG_LBA DB 13,10,"CONVERTING LBA TO CHS!",0
	MSG_READ_SECTOR DB 13,10,"READING SECTOR 1!",0
	MSG_RESET_FLOPPY DB 13,10,"RESET FLOPPY!",0
	MSG_FLOPPY_FAIL DB 13,10,"FLOPPY DISK FAILURE!",0
	MSG_FLOPPY_SUCC DB 13,10,"FLOPPY DISK SUCCESS!",0
	MSG_SS DB 13,10,"SETTING UP STACK.",0
	MSG_BLS DB 13,10,"SETTING BOOTLOADER SEGMENT.",0
	MSG_PAK DB 13,10,"PRESS ANY KEY TO EXIT....",0
	MSG_GOOD DB 13,10,"SUCCESSFUL! JUMPING TO PRINT_SEGMENT!!!!!! YIPPIE!!!!",0
	
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
	
	
;--------------------------------------------------------------------
;LBA TO CHS
;--------------------------------------------------------------------
		
LBA_TO_CHS:
		
	PRINT.STRING MSG_LBA
	PUSH AX
	MOV DX,0
	
	DIV WORD[SECTORSPERTRACK]
	INC DL
	MOV CL,DL														;ABSOLUTE SECTOR
	POP AX					
	MOV DX,0
	DIV WORD[SECTORSPERTRACK]
	MOV DX,0
	DIV WORD[NUMBEROFHEADS]
	MOV CH,AL														;ABSOLUTE CYLINDER
	MOV DH,DL														;ABSOLUTE HEAD
		
	MOV DL,BYTE[DRIVENUMBER]
	MOV AH,0X02
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
	PRINT.STRING MSG_PAK
	MOV AX,0
	INT 0X16
	CLI 
	HLT
	
FLOPPY_SUCC:
	PRINT.STRING MSG_FLOPPY_SUCC
	POP CX
	RET

	
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
											
	
	PUSH WORD[PRINT_SEGMENT]				;SETTING UP EXTRA SEGMENT
	POP ES
	MOV BX,0
	
	STI 									;RESTORE INTERRUPTS
	
	MOV AX,WORD[SECTOR_TO_READ]				;READ SECTOR 1
	
	;PRINT.STRING MSG_SS							
	
;--------------------------------------------------------------------
;READ SECTOR
;--------------------------------------------------------------------
		
	
READ_SECTOR:
	
	PRINT.STRING MSG_READ_SECTOR
	CALL LBA_TO_CHS
	;CLC										;CLEAR CARRY FLAG
	INT 0X13
	
	JNC LOAD_PS
	JC RESET_FLOPPY
	JMP READ_SECTOR

;--------------------------------------------------------------------
;LOAD PRINT SEGMENT
;--------------------------------------------------------------------
	
LOAD_PS:
	PRINT.STRING MSG_GOOD
	JMP PRINT_SEGMENT:0000
	
TIMES 510-($-$$) DB 0
DW 0XAA55