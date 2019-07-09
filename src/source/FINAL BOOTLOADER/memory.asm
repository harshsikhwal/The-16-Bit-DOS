;MEMORY MANAGER

;--------------------------------------------------------
;VARIABLES
;--------------------------------------------------------

ALLOCATED_SEGMENT	DW 0
;LAST_SEGMENT	DW 0
SEGMENT_ALLOCATION_TABLE DB 1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1
SEGMENT_ALLOCATION_TABLE_SIZE DW 16

;--------------------------------------------------------
;INITIALIZE
;--------------------------------------------------------

MEMORY_INITIALIZE:
	
	PUSH DS
	PUSH CS
	POP DS
	PUSHA
	MOV SI,SEGMENT_ALLOCATION_TABLE
	MOV CX,SEGMENT_ALLOCATION_TABLE_SIZE

CHECK_FREE_MEMORY:
	
	XOR BX,BX
	MOV AL,BYTE[DS:SI+BX]
	CMP AL,0
	JE ALLOCATE_MEMORY
	INC BX
	LOOP CHECK_FREE_MEMORY
	PRINT.STRING MSG_MEM_NFREE
	RET
	
ALLOCATE_MEMORY:
	
	MOV BYTE[DS:SI+BX],1
	SHL BX,12
	MOV WORD[ALLOCATED_SEGMENT],BX
	POPA
	POP DS
	RET
	
DEALLOCATE_MEMORY:

	PUSHA
	PUSH DS
	PUSH CS
	POP DS
	MOV BX,WORD[ALLOCATED_SEGMENT]
	SHR BX,12
	MOV SI,SEGMENT_ALLOCATION_TABLE
	MOV BYTE[DS:SI+BX],0
	;MAKE MEMORY NULL FACTOR
	POP DS
	POPA
	RET