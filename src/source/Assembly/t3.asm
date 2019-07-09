[org 0]
[bits 16]

jmp 0x7c0:start

%include "D:/Computer test-Files/Programming/Sparrows OS/Assembly/IO.asm"
%include "D:/Computer test-Files/Programming/Sparrows OS/Assembly/System.asm"
%include "D:/Computer test-Files/Programming/Sparrows OS/Assembly/String.asm"

err:
	Console.println errMsg
	jmp $

read:
	push dx
	mov ah , 0x02 		; BIOS read sector function
	mov al , dh 		; Read DH sectors
	mov ch , 0x00 		; Select cylinder 0
	mov dh , 0x00 		; Select head 0
	mov cl , 0x02 		; Start reading from second sector ( i.e. after the boot sector )
	Interrupt.READ		; BIOS interrupt
	jc err 				; Jump if error ( i.e. carry flag set )
	pop dx 				; Restore DX from the stack
	cmp dh , al 		; if AL ( sectors read ) != DH ( sectors expected )
	jne err 			; display error message
	ret

start:	
	Console.clrscr	
	
	mov ax,cs		;Clear registers
	mov ds,ax
	mov es,ax
	
	mov bp, 0xffff	; Setup stack
	mov sp, bp
	
	Console.println msg
	
	mov [BOOT_DRIVE], dl
	mov ax, 0x1000
	mov es, ax
	mov bx, 0
	mov dh, 5
	mov dl, [BOOT_DRIVE]
	call read
	
	jmp new
	
String(errMsg,"Error loading sector!")
String(msg,"Hello!")

BOOT_DRIVE : db 0

times 510-($-$$) db 0
dw 0xaa55

new:

Console.print msg
jmp $