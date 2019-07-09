[org 0]
[bits 16]

jmp 0x7c0:start

%include "D:/Computer test-Files/Programming/Sparrows OS/Assembly/IO.asm"
%include "D:/Computer test-Files/Programming/Sparrows OS/Assembly/System.asm"
%include "D:/Computer test-Files/Programming/Sparrows OS/Assembly/String.asm"

loadsector:
	mov bx, [begin]
	mov dl, 0		; drive
	mov dh, 0 		; head
	mov ch, 0		; track
	mov ah, 2
	Interrupt.READ
	jc err
	ret

err:
	Console.println errMsg
	ret

start:
	
	Console.clrscr
	
	mov ax,cs		;Clear registers
	mov ds,ax
	mov es,ax
	
	mov bp, 0xffff	; Setup stack
	mov sp, bp
	
	mov ax, 0x1000
	mov es, ax
	mov cl, 3		; sector
	mov al, 1		; number of sectors
	
	call loadsector
	
	jmp 100:0		; jump to os
	jmp $
	
String(errMsg,"Error loading sector!")

times 1509949-($-$$) db 0
dw 0xaa55

begin:

comp equ 0

	Console.clrscr
	Console.println msg
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
	mov cx, 32
	rep stosb
	ret

String(msg,"Booting Successful.")
String(exit,"exit")
String(off,"System halted.")
String(ent,"Input: ")

inp times 32 db 0
ns prompt, CRETURN,">> "