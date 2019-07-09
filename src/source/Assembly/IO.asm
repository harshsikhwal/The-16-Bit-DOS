%include "C:/Users/Harsh/Desktop/boot test/Assembly/Interrupt.asm"

%define NULL	   0
%define BACKSPACE  8
%define TAB		   9
%define NEWLINE   10
%define FORMFEED  12
%define CRETURN   13
%define SPACE	  32

%define Console.clrscr call clrscr
%define Console.flush  call flush
%define Console.getch  call getCharacter
%define Console.getche call getCharacterEcho

%macro Console.print 1-*
	pusha
	%rep %0
		mov si, %1
		call printString
		%rotate 1
	%endrep
	popa
%endmacro

%macro Console.dumpRegister 1
	pusha
	mov dx, %1
	call printHex
	popa
%endmacro

%macro Console.println 0-*
	pusha
	%rep %0
		mov si, %1
		call printString
		%rotate 1
	%endrep
	call println
	popa
%endmacro

%macro Console.printChar 1
	mov al, %1
	call printChar
%endmacro

%macro Console.printHex 1
	pusha
	mov dx, [%1]
	call printHex
	popa
%endmacro

%macro Console.read 1
	push ax
	mov di, %1
	call readInput
	pop ax
%endmacro

%macro Console.readPassword 1
	push ax
	mov di, %1
	call readPassword
	pop ax
%endmacro

clrscr:
	pusha
	mov dx, 0
	mov bh, 0
	mov ah, 2
	Interrupt.PRINT
	mov ah, 6			; Scroll full-screen
	mov al, 0			; Normal white on black
	mov bh, 7
	mov cx, 0			; Top-left
	mov dh, 24			; Bottom-right
	mov dl, 79
	Interrupt.PRINT
	popa
	ret

flush:
	push di
	push cx
	mov di, c_buffer
	mov cx, 32
	rep stosb
	pop cx
	pop di
	ret

getCharacter:
	mov ax, 0
	Interrupt.WAIT_FOR_KEYSTROKE
	ret

getCharacterEcho:
	call getCharacter
	mov ah, 0x0e
	Interrupt.PRINT
	ret

println:
	mov ah, 0x0e
	mov al, NEWLINE
	Interrupt.PRINT
	mov al, CRETURN
	Interrupt.PRINT
	ret

printChar:
	mov ah, 0x0e
	Interrupt.PRINT
	ret

printHex:
	Console.printChar '0'
	Console.printChar 'x'
	cmp dx, 0
		je .ph_emitZeroAndDone
		jne .ph_begin
	.ph_emitZeroAndDone:
		Console.printChar '0'
		jmp short .ph_done
	.ph_begin:
		mov cx, 4
		mov bx, 0
		.ph_loop:
			rol dx, 4
			push dx
			and dx, 0xf			
			cmp dl, 9
				jle .ph_decimal
			add dl, 55
			jmp short .ph_common
			.ph_decimal:
				add dl, 48
			.ph_common:
				mov al, dl
			call printChar
			pop dx
			loop .ph_loop
	.ph_done:
		ret
	
printString:
	mov ah, 0x0e		; teletype output
	.ps_loop:
		lodsb
		cmp al, NULL		; check end-of-string
			je .ps_done
		Interrupt.PRINT			; else, print it.
		jmp short .ps_loop
	.ps_done:
		ret

readInput:
	push cx
	mov cx, 0
	.ri_strt:
		Console.getch
		cmp al, BACKSPACE
			je .ri_bksp
		cmp al, CRETURN
			je .ri_done
		cmp al, SPACE
			jl .ri_discard
		mov ah, 0x0e
		Interrupt.PRINT
		stosb
		inc cx
		cmp cx, 32
			je .ri_done
		jmp .ri_strt
		.ri_bksp:
			cmp cx, 0
				je .ri_strt
			mov ah, 0x0e
			Interrupt.PRINT
			mov al, SPACE
			Interrupt.PRINT
			mov al, BACKSPACE
			Interrupt.PRINT
			dec di
			mov al, 0
			stosb
			dec di
			dec cx
			jmp .ri_strt
		.ri_discard:
			jmp .ri_strt
	.ri_done:
		pop cx
		ret

readPassword:
	push cx
	mov cx, 0
	.rp_strt:
		Console.getch
		cmp al, BACKSPACE
			je .rp_bksp
		cmp al, CRETURN
			je .rp_done
		cmp al, SPACE
			jl .rp_discard
		stosb
		mov ah, 0x0e
		mov al, '*'
		Interrupt.PRINT
		inc cx
		cmp cx, 32
			je .rp_done
		jmp .rp_strt
		.rp_bksp:
			cmp cx, 0
				je .rp_strt
			mov ah, 0x0e
			Interrupt.PRINT
			mov al, SPACE
			Interrupt.PRINT
			mov al, BACKSPACE
			Interrupt.PRINT
			dec di
			mov al, 0
			stosb
			dec di
			dec cx
			jmp .rp_strt
		.rp_discard:
			jmp .rp_strt
	.rp_done:
		pop cx
		ret

c_buffer times 32 db 0