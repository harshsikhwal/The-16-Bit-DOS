;-----------------------------------------------------------------------
;
;
; THIS IS THE 16-BIT OS KERNEL
; VERSION 0.2
; 
; WRITTEN BY:
; HARSH SIKHWAL
; 
;
;------------------------------------------------------------------------


ORG 0X5000
BITS 16

jmp main
 
 
 
%include "C:/LIB/IO.asm" 
%INCLUDE "C:/LIB/CONVERSION.asm"
%include "C:/LIB/SCLI/IO.asm"
%include "C:/LIB/SCLI/System.asm"
%include "C:/LIB/SCLI/String.asm"
%INCLUDE "C:/LIB/TIME.asm"
%INCLUDE "C:/LIB/FLP.asm"

%INCLUDE "C:/LIB/DATE.asm"

comp db 0




;----------------------------------------------------------------
;ADDITIONAL VARIABLES 
;----------------------------------------------------------------

	CLUSTER    DW 0
	DATASECTOR DW 0
		
	
	
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

	MSG_ROOT          DB 13,10,"DISPLAYING DIRECTORY A: ENTRIES!",0

	MSG_SUCC          DB 13,10,"SUCCESS!",0

	MSG_VERSION DB 13,10,"THE 16-BIT DOS. VERSION 0.2",13,10,"(C)COPYRIGHT 2016-2017",13,10,0

	MSG_AUTHOR        DB 13,10,"THE 16-BIT DOS.",13,10,"WRITTEN BY:-",13,10,"HARSH SIKHWAL",13,10,"harsh.astro1996@gmail.com",0
	
	MSG_AUTHOR1        DB 13,10,"THE 16-BIT DOS.",13,10,"WRITTEN BY:-",13,10,"BOOTLOADER AND KERNEL : HARSH SIKHWAL",13,10,"COMMAND LINE INTERFACE: SWARNAVA MUKHERJEE",0

	MSG_HELP    DB 13,10,"THIS IS THE HELP MENU OF THE 16-BIT DOS",13,10,13,10,"  LIST OF COMMANDS                    ABOUT THEM",13,10,13,10,"  cls                                CLEAR SCREEN",13,10,"  dir                                DISPLAY FLOPPY CONTENTS",13,10,"  time                               GET SYSTEM TIME",13,10,"  set_time                           SET SYSTEM TIME",13,10,"  version                            GET VERSION NUMBER",13,10,"  help                               HELP MENU",13,10,"  reboot                             SYSTEM REBOOT",13,10,"  shutdown                           SYSTEM SHUTDOWN",13,10,"  date                               GET SYSTEM DATE",13,10,0

				   
				   
;--------------------------------------------------------------------------
;BEGIN METHOD
;--------------------------------------------------------------------------	
	
main:
	CLI
	
	MOV AX,0
	MOV SS,AX
	MOV SP,0XFFFF
	
	STI
	
	CLI
	
	PUSH CS
	POP DS
	STI
	
	CLI
	
	MOV AX,0X1000
	MOV DS,AX
	MOV ES,AX
	MOV FS,AX
	MOV GS,AX
	
	STI
	
	Console.clrscr
	;Console.println msg,NL,un
	;mov bh,0
	;mov bl, 0x15
	
	Console.print MSG_LOADOS
	CALL LOAD_ROOT
	
	
	CALL LOAD_FAT
	
	
	
	Console.print NL,un
	Console.read inp
	Console.print NL,pk
	Console.readPassword inp
	Console.clrscr
	
	
	Console.print MSG_LOADOS

	trmnl:
		Console.print NL,prompt
		call clear_inp
		Console.read inp
		
		
		String.equals comp,inp,cls
		MOV CX,[comp]
		CMP CX,0
		JE CLEAR_SCREEN
		
		String.equals comp,inp,reboot
		MOV CX,[comp]
		CMP CX,0
		JE system_reboot
		
		String.equals comp,inp,dir
		MOV CX,[comp]
		CMP CX,0
		JE DISPLAY_ROOT
		
		
		String.equals comp,inp,time
		MOV CX,[comp]
		CMP CX,0
		JE GET_TIME
		;JMP trmnl
		
		String.equals comp,inp,ver
		MOV CX,[comp]
		CMP CX,0
		JE VERSION
		
		String.equals comp,inp,auth
		MOV CX,[comp]
		CMP CX,0
		JE AUTHOR	
		
		String.equals comp,inp,auth1
		MOV CX,[comp]
		CMP CX,0
		JE AUTHOR1
		
		
		
		String.equals comp,inp,hlp
		MOV CX,[comp]
		CMP CX,0
		JE HELP
		
		String.equals comp,inp,date
		MOV CX,[comp]
		CMP CX,0
		JE GET_DATE
		
		
		
		String.equals comp,inp,settime
		MOV CX,[comp]
		CMP CX,0
		JE SET_TIME	
		
		String.equals comp, inp, exit
		mov cx, [comp]
		cmp cx, 0
			je halt		
		Console.println NL, ent, inp
	jmp trmnl

;-------------------------------------------------------------------------
;CLI SUBROUTINES
;-------------------------------------------------------------------------
	
halt:
	Console.print NL, off
	System.halt

clear_inp:
	mov di, inp
	mov al, 0
	mov cx, 10
	rep stosb
	ret
	
CLEAR_SCREEN:
		Console.clrscr
		Console.print MSG_LOADOS
		JMP trmnl

VERSION:
		Console.print MSG_VERSION
		JMP trmnl

AUTHOR:
		Console.print MSG_AUTHOR
		JMP trmnl
		
AUTHOR1:
		Console.print MSG_AUTHOR1
		JMP trmnl		
		
HELP:  Console.print MSG_HELP
		JMP trmnl

String(date,"date")		
String(settime,"set_time")		
String(reboot,"reboot")
String(time,"time")
String(dir,"dir")
String(cls,"cls")
String(hlp,"help")	
String(exit,"shutdown")
String(ver,"version")
String(auth1,"author1")

String(auth,"author")
String(un,"Username: ")
String(pk,"Passkey : ")
;String(msg,"Booting Successful.")

String(off,"System halted.")
String(ent,"Input: ")

inp times 32 db 0
ns prompt, CRETURN,"A>> "
