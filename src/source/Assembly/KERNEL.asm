[org 0]
[bits 16]

;mov bp, 0xffff	; Setup stack
;mov sp, bp

jmp begin

%include "C:/Users/Harsh/Desktop/boot test/Assembly/IO.asm"
%include "C:/Users/Harsh/Desktop/boot test/Assembly/System.asm"
%include "C:/Users/Harsh/Desktop/boot test/Assembly/String.asm"
comp equ 0
begin:
	CLI
	PUSH CS
	POP DS
	STI
	
	Console.clrscr
	;Console.println msg,NL,un
	mov bh,0
	mov bl, 0x15
	Console.print un
	Console.read inp
	Console.print NL,pk
	Console.readPassword inp
	Console.clrscr
	trmnl:
		Console.print NL,prompt
		call clear_inp
		Console.read inp
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

String(un,"Username: ")
String(pk,"Passkey : ")
;String(msg,"Booting Successful.")
String(exit,"exit")
String(off,"System halted.")
String(ent,"Input: ")

inp times 10 db 0
ns prompt, CRETURN,">> "
