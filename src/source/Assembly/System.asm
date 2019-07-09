%include "C:/Users/Harsh/Desktop/boot test/Assembly/Interrupt.asm"

%define System.reboot call reboot
%define System.halt	  hlt

reboot:
	mov ax, 0
	Interrupt.REBOOT