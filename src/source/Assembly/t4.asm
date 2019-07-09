[org 0]
[bits 16]

jmp 0x7c0:start

%include "D:/Computer test-Files/Programming/Sparrows OS/Assembly/IO.asm"
%include "D:/Computer test-Files/Programming/Sparrows OS/Assembly/System.asm"
%include "D:/Computer test-Files/Programming/Sparrows OS/Assembly/String.asm"

err:
	Console.println errMsg
	jmp $

start:
	
	Console.clrscr	
	
	mov ax,cs		;Clear registers
	mov ds,ax
	mov es,ax
	
	mov bp, 0xffff	; Setup stack
	mov sp, bp
	
	Console.println msg
	;jmp read
	
reset:

	mov ax, 0
	mov dl, 0
	Interrupt.READ
	jc err
	
read:

	mov ax, 0x1000
	mov es, ax
	mov bx, 0
	
	mov ah, 2
	mov al, 5
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov dl, 0
	Interrupt.READ
	jc err

	mov dx, bx
	;mov word [es:bx], new
	;jmp 0x1000:0000		; jump to os
	jmp 0x7e0:new		; jump to os
	
String(errMsg,"Error loading sector!")
String(msg,"Hello!")

times 510-($-$$) db 0
dw 0xaa55

new:

;mov ah, 9
;mov al, '='
;mov bx, 7
;mov cx, 10
Console.println msg2
jmp $

String(msg2,"Hello!")