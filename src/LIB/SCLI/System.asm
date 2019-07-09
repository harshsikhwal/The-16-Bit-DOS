%include "C:/LIB/SCLI/Interrupt.asm"

	MSG_REBOOT DB 13,10,"REBOOTING...",0

%define System.halt	  hlt

system_reboot:
	
	
	Console.clrscr
	
	Console.print MSG_REBOOT
	
	
	mov ax, 0
	
	
	Interrupt.REBOOT