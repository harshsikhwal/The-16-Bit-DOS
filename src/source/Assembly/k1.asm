[org 0]
[bits 16]

;mov bp, 0xffff	; Setup stack
;mov sp, bp

jmp begin
 
 
 
 
 
%include "C:/Users/Harsh/Desktop/boot test/Assembly/IO.asm"
%include "C:/Users/Harsh/Desktop/boot test/Assembly/System.asm"
%include "C:/Users/Harsh/Desktop/boot test/Assembly/String.asm"
comp equ 0




;----------------------------------------------------------------
;ADDITIONAL VARIABLES 
;----------------------------------------------------------------

	CLUSTER    DW 0
	DATASECTOR DW 0
	IMAGENAME  DB "KERNEL  SYS"
		
	
	
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
;PRINT STRING 
;----------------------------------------------------------------
	
	MSG_LOAD_FAT      DB 13,10,"LOADING FAT FILESYSTEM.",0
	MSG_LOAD_ROOT     DB 13,10,"LOADING ROOT DIRECTORY.",0
	MSG_LBA 		  DB 13,10,"CONVERTING LBA TO CHS.",0
	MSG_LOADOS db 13,10,"THE 16-BIT DOS",13,10,"VERSION 0.01 (C)COPYRIGHT 2016-2017",13,10,0

	



	
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
		

	
LOAD_ROOT_AND_FAT:
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

	PUSH AX
	MOV AX,0X1000
	MOV ES,AX
	POP AX
	MOV BX,0
	CALL READ_SECTOR
	
	
;--------------------------------------------------------------------
;LOAD FAT
;--------------------------------------------------------------------

LOAD_FAT:
	
	Console.print MSG_LOAD_FAT

;GET SIZE OF FAT

	MOV AX,WORD[NUMBEROFFATS]
	MUL WORD[SECTORSPERFAT]
	XCHG AX,CX
	
;GET START OF FAT

	MOV AX,WORD[RESERVEDSECTORS]
	
;LOAD FAT AT 1000:1D00
	
	PUSH AX
	MOV AX,0X1000
	MOV ES,AX
	POP AX
	MOV BX,0X1D00
	CALL READ_SECTOR
	
	RET
	
;--------------------------------------------------------------------
;DISPLAY ROOT
;--------------------------------------------------------------------


DISPLAY_ROOT:

	PUSHA
	PUSH DS
	MOV AX,0X1000
	MOV DS,AX
	XOR SI,SI
	
	MOV CX,224
	MOV AH,0X0E
	

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
	JNE CONTD
	JE WAIT_FOR_DOT
	
WAIT_FOR_DOT:
		CALL PRINT_EXT
	
CONTD:	
	
	CMP AL,32
	LOOP DISPLAY_ROOT_LOOP
	
	
	
	
	INT 0X10
	
	LOOP DISPLAY_ROOT_LOOP


PRINT_EXT:
		PUSHA
		MOV AL,46
		INT 0X10
		POPA 
		RET
				
	
DISPLAY_ROOT_DONE:
		POP DS
		POPA
		RET
	
PRINT_NL:
		PUSHA
		MOV AL,13
		INT 0X10
		MOV AL,10
		INT 0X10
		POPA
		POP SI
		POP CX
		DEC CX
		ADD SI,32
		JMP DISPLAY_ROOT_INITIALZE
	

begin:
	CLI
	PUSH CS
	POP DS
	STI
	
	Console.clrscr
	;Console.println msg,NL,un
	mov bh,0
	mov bl, 0x15
	
	Console.print MSG_LOADOS
	CALL LOAD_ROOT_AND_FAT
	
	Console.print un
	Console.read inp
	Console.print NL,pk
	Console.readPassword inp
	Console.clrscr
	
	Console.print MSG_LOADOS

	trmnl:
		Console.print NL,prompt
		call clear_inp
		Console.read inp
		
		String.equals comp,inp,dir
		MOV CX,[comp]
		CMP CX,0
		JE WAIT_FOR_ROOT
		JNE CONTD_R
		
		WAIT_FOR_ROOT:
			CALL DISPLAY_ROOT
		JMP trmnl
		
		CONTD_R:
			
		
		String.equals comp, inp, exit
		mov cx, [comp]
		cmp cx, 0
			je halt		
		Console.println NL, ent, inp
	jmp trmnl

	halt:
		Console.print NL, off
		System.halt

clear_inp:
	mov di, inp
	mov al, 0
	mov cx, 10
	rep stosb
	ret

String(dir,"dir")
String(un,"Username: ")
String(pk,"Passkey : ")
;String(msg,"Booting Successful.")
String(exit,"exit")
String(off,"System halted.")
String(ent,"Input: ")

inp times 10 db 0
ns prompt, CRETURN,"A>> "
