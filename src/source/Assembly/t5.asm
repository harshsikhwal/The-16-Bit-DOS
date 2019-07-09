[org 0x7c00]
[bits 16]

jmp start

%include "D:/Computer test-Files/Programming/Sparrows OS/Assembly/IO.asm"
%include "D:/Computer test-Files/Programming/Sparrows OS/Assembly/Interrupt.asm"

disk_error:
	Console.println errMsg
	jmp $

disk_load :
	push dx 			; Store DX on stack so later we can recall how many sectors were request to be read, even if it is altered in the meantime
	mov ah , 0x02 		; BIOS read sector function
	mov al , dh 		; Read DH sectors
	mov ch , 0x00 		; Select cylinder 0
	mov dh , 0x00 		; Select head 0
	mov cl , 0x02 		; Start reading from second sector ( i.e. after the boot sector )
	int 0x13 			; BIOS interrupt
	jc disk_error 		; Jump if error ( i.e. carry flag set )
	pop dx 				; Restore DX from the stack
	cmp dh , al 		; if AL ( sectors read ) != DH ( sectors expected )
	jne disk_error 		; display error message
	ret

loadkernel:
	
	;mov ax, 0x1000
	;mov es, ax
	mov bx , [0x1000]	 	; Set -up parameters for our disk_load routine , so
	mov dh , 15				; that we load the first 15 sectors ( excluding
	mov dl , [ BOOT_DRIVE ] ; the boot sector ) from the boot disk ( i.e. our
	call disk_load			; kernel code ) to address KERNEL_OFFSET
	ret

start:
	
	Console.clrscr	
	
	mov ax,cs		;Clear registers
	mov ds,ax
	mov es,ax
	
	mov bp, 0xffff	; Setup stack
	mov sp, bp

	mov [ BOOT_DRIVE ], dl ; BIOS stores our boot drive in DL , so it 's best to remember this for later.
	
	;mov bx , 0x1000 ; Load 5 sectors to 0x0000 (ES ):0x1000 (BX)
	;mov dh , 5 ; from the boot disk.
	;mov dl , [ BOOT_DRIVE ]
	
	;call disk_load
	call loadkernel
	call hello
	
	;Console.printHex 0x9000+val
	;jmp 0x900:hello
	jmp $
errMsg db "Error loading sector!",0
;msg db "Hello!",0
BOOT_DRIVE : db 0


times 510-($-$$) db 0
dw 0xaa55

hello:
mov ax, 0xabab
Console.dumpRegister ax
Console.printHex val 

val dw 0x4fb6
;times 256 dw 0xdada
;times 256 dw 0xface