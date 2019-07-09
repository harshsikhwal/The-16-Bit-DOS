;---------------------------------------------------------------------------
;STRING TO NUMBER
;---------------------------------------------------------------------------



%MACRO STRING.TO.NUMBER 1
	PUSHA
	MOV SI,%1
	MOV CX,10
	MOV DX,0
	MOV AH,0
	CALL CONVERTN
	MOV AX,DX
	MOV DI,%1
	STOSB
	MOV AL,0
	STOSB
%ENDMACRO

CONVERTN:

CONVERTN_LOOP:
	LODSB
	CMP AL,0
	JE CONVERTN_END
	SUB AL,48
	MOV BX,AX
	MOV AX,DX
	MUL CX
	ADD AX,BX
	MOV DX,AX
	JMP CONVERTN_LOOP
	
CONVERTN_END:
	RET


;---------------------------------------------------------------------------
;NUMBER TO STRING
;---------------------------------------------------------------------------

%MACRO NUMBER.TO.STRING 1
	MOV SI,%1
	PUSHA
	XOR AX,AX
	LODSB
	MOV CX,10
	MOV BH,0
	MOV DI,%1
	
	MOV DX,0
	CALL CONVERTS
	POPA
%ENDMACRO

CONVERTS:

CONVERTS_LOOP1:
	DIV CX
	PUSH DX
	CMP AX,10
	JL CONVERTS_LOOPM
	
	INC BH
	JMP CONVERTS_LOOP1
	
CONVERTS_LOOPM:
	PUSH AX
	INC BH
	INC BH
CONVERTS_LOOP2:
	CMP BH,0
	JE CONVERTS_DONE
	POP AX
	ADD AX,48
	STOSB
	DEC BH
	JMP CONVERTS_LOOP2
	
CONVERTS_DONE:
	MOV AL,0
	STOSB
	RET

	
;---------------------------------------------------------------------------
;STRING TO BCD (8-BITS)
;---------------------------------------------------------------------------

%MACRO STRING.TO.BCD8 1

	MOV SI,%1
	CALL STRINGBCD
%ENDMACRO

STRINGBCD:

	LODSB
	SUB AL,48
	SHL AL,4
	MOV DL,AL
	LODSB
	SUB AL,48
	ADD DL,AL
	XCHG DL,AL
	RET
