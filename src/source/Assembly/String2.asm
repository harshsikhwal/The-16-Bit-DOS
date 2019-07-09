%define String(var,string) var db string, 0
%macro ns 2+
	%1 db %2, 0
%endmacro

NL db 10, 13, 0

%macro String.equals 3
	pusha
	mov si, %2
	mov cx, 0
	call strlen
	mov si, %2
	mov di, %3
	call strcmp
	mov [%1], cx
	popa
%endmacro

%macro String.length 2
	pusha
	mov si, %2
	call len
	mov [%1], cx
	popa
%endmacro

strlen:
	.sl_loop:
		lodsb
		cmp al, 0
			je .sl_done
		inc cx
		jmp .sl_loop
	.sl_done:
		ret

strcmp:
	cld
	rep cmpsb
	ret
	