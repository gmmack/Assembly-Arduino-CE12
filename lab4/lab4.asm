; CMPE12 - Fall 2014
; lab4.asm
; Gavin Mack gmmack
; This program encrypts/decrypts input strings.

	.ORIG x3000

START
; clear all registers
	AND	R0, R0, 0
	AND	R1, R1, 0
	AND	R2, R2, 0
	AND	R3, R3, 0
	AND	R4, R4, 0
	AND	R5, R5, 0
	AND	R6, R6, 0
	AND	R7, R7, 0

	LD	R3, CONVERT
; prompt E/D input
	LEA	R0, PROMPTED
	PUTS

;------------------------------------------------
; get E/D, error check & store
;------------------------------------------------
MAINCHK:
	GETC				;get input
	OUT				;display input
	ADD	R2, R2, R0		;store in R2
	LD	R3, CHKD
	ADD	R1, R0, R3		;R1==0 if char==D
	BRz	CHECK			;jmp to store if D
	ADD	R1, R1, #-1		;R1==0 if char==E
	BRz	CHECK			;jmp to store if E
	LEA	R0, ERR1
	PUTS				;print err msg
	BRnzp MAINCHK

	CHECK:
	STI	R2, STOREED		;store to memory

;------------------------------------------------
; get key, error check & store
;------------------------------------------------
CHKAGAIN:
	AND	R1, R1, 0		;initialize registers
	AND	R2, R2, 0
	AND	R3, R3, 0
	AND	R6, R6, 0
	LD	R2, CONVERT

	LEA	R0, PROMPTKEY		;print key prompt
	PUTS
	GETC				;first char in R0
	OUT
	ADD	R1, R0, R2		;string to decimal conversion
	GETC
	PUTC

	ADD	R5, R0, R2		;hold second decimal char in R5
	ADD	R0, R0, #-10		;check if ENTER
	BRz	ENTER			;skip err2 if ENTER
	JSR	MULTIPLY		;jmp to multiply
	ADD	R1, R1, R5		
	GETC				;get 3rd char
	ADD	R0, R0, #-10		;check if ENTER
	BRz	ENTER			;skips err2 if ENTER
	LEA	R0, ERR2
	PUTS				;print err2
	BR	CHKAGAIN		;loop back to top

ENTER:
	ADD	R6, R6, R1		;final value stored in R6
	AND	R1, R1, 0		;reset R1
	ADD	R3, R6, #0		;store in R3 for err checking
	LD	R1, CHKK1
	ADD	R3, R3, R1		;check for < 31
	BRnz	FINAL
	LEA	R0, ERR2
	PUTS				;print err2
	BR	CHKAGAIN

FINAL:
	STI	R6, STOREKEY		;store to memory

;******************************************************************
; variable declarations
	BR	SKIP
CONVERT		.FILL	#-48

CHKK1		.FILL	#-31
CHKSTR		.FILL	#-19

;string declarations

PROMPTED:	.STRINGZ "\n(E)ncrypt/(D)ecrypt: "
PROMPTKEY:	.STRINGZ "\nEncryption Key: "
PROMPTMSG:	.STRINGZ "\nInput Message: "
CHKD		.FILL	#-68
ERR1:		.STRINGZ "\nTHAT IS AN ILLEGAL CHARACTER. PLEASE TRY AGAIN. "
ERR2:		.STRINGZ "\nOUT OF RANGE ENCRYPTION KEY. PLEASE TRY AGAIN. "


ERR3:		.STRINGZ "\nMESSAGE EXCEDES 20 CHARACTERS. PLEASE TRY AGAIN. "
SKIP:
;******************************************************************

;------------------------------------------------
; get string & store
;------------------------------------------------
	AND	R0, R0, 0		;initialize registers
	AND	R1, R1, 0
	AND	R2, R2, 0
	AND	R3, R3, 0
	AND	R4, R4, 0
	AND	R5, R5, 0
	AND	R6, R6, 0

;******************************************************************
;variable declaration for storing
	BR SKIP2
STOREED:	.FILL	x3200
SKIP2:
;******************************************************************

	LD	R1, STORESTR		;storage address loaded into R1
	LD	R5, CHKSTR		;load length checker into R5
	LEA	R0, PROMPTMSG
	PUTS

STRING:
	AND	R2, R2, 0
	AND	R4, R4, 0
	GETC
	OUT
	ADD	R2, R2, R0		;save char to R2
	ADD	R4, R6, R5		;check str length
	BRzp	STRERR
	STR	R2, R1, 0		;store char
	ADD	R0, R0, #-10		;check if ENTER
	BRz	STREND
	ADD	R1, R1, #1		;++memory location
	ADD	R6, R6, #1
	BRnzp	STRING

STRERR:
	LD	R3, ERR3
	PUTS
	BR	STRING

STREND:

;******************************************************************
; variable declarations
	BR	SKIP3
STOREKEY:	.FILL	x3201
STORESTR:	.FILL	x3202
RES:		.STRINGZ "\nResult: "
SKIP3:
;******************************************************************

;------------------------------------------------
; E/D and output result
;------------------------------------------------
	AND	R0, R0, 0		;initialize registers
	AND	R1, R1, 0
	AND	R2, R2, 0
	AND	R3, R3, 0
	AND	R4, R4, 0
	AND	R5, R5, 0

	LDI	R1, STOREED		;load E/D into R1
	LD	R2, CHKD		;load ascii converter into R2
	ADD	R1, R1, R2		;if char==D, R1==0
	BRz	GOTO_D			;if D, skip E_LOOP
	LD	R5, STORESTR		;load string into R5

E_LOOP:
	LDR	R1, R5, #0		;loads value from R5
	ADD	R4, R1, #-10		;check if ENTER
	BRz	RESULT			;have our res, jmp to RESULT
	JSR	ENCRYPT			;jmp to ENCRYPT subroutine
	STR	R1, R5, #0		;store encrypted value back to same location
	ADD	R5, R5, #1		;++memory location
	BR	E_LOOP

GOTO_D:
	LD	R5, STORESTR

D_LOOP:
	LDR	R1, R5, #0		;loads value from R5
	ADD	R4, R1, #-10		;check if ENTER
	BRz	RESULT			;have our res, jmp to RESULT
	JSR	DECRYPT			;jmp to DECRYPT subroutine
	STR	R1, R5, #0		;store decrypted value back to same location
	ADD	R5, R5, #1		;++memory location
	BR	D_LOOP

RESULT:
	LEA	R0, RES
	PUTS
	LD	R5, STORESTR

PRINT:					;loop to print string result
	LDR	R0, R5, #0
	PUTC
	ADD	R0, R0, #-10
	BRz	ENDPRINT
	ADD	R5, R5, #1
	BR	PRINT
	ENDPRINT


;------------------------------------------------
; stop the processor
;------------------------------------------------
	HALT

;------------------------------------------------
; multiply subroutine
;------------------------------------------------
MULTIPLY:
	AND	R0, R0, 0
	AND	R3, R3, 0
	ADD	R4, R4, #9
	ADD	R3, R3, R1
WHILE:
	ADD	R1, R3, R1
	ADD	R4, R4, #-1
	BRp	WHILE
	RET

;------------------------------------------------
; encyrpt subroutine
;------------------------------------------------
ENCRYPT:
	ST	R0, R0TMP		;store R0 value in mem
	ADD	R0, R7, #0		;put RET location in R0
	JSR	PUSH			;push RET location to stack

	LDI	R0, STOREKEY
	AND	R2, R1, #1		;is first bit 1?
	BRz	IS_ONE
	ADD	R1, R1, #-1		;toggle first bit
	ADD	R1, R1, R0		;add key
	BR	E_DONE

IS_ONE:
	ADD	R1, R1, #1		;toggle first bit
	ADD	R1, R1, R0		;add key

E_DONE:
	JSR	POP
	ADD	R7, R0, #0		;RET location into R7
	LD	R0, R0TMP		;restore original R0
	RET

;------------------------------------------------
; decrypt subroutine
;------------------------------------------------
DECRYPT:
	ST	R0, R0TMP		;store R0 value in mem
	ADD	R0, R7, #0		;put RET location in R0
	JSR	PUSH			;push RET location to stack

	LDI	R0, STOREKEY		;load key to R0
	JSR	TWOCOMP			;2's comp key value

	ADD	R1, R1, R0		;subtract key
	AND	R2, R1, #1		;toggle first bit
	BRz	IS_BLAH

	LD	R2, MASK		;load mask into R2
	AND	R1, R1, R2		;force bit to zero
	BR	D_DONE

IS_BLAH:
	ADD	R1, R1, #1		;toggle first bit


D_DONE:
	JSR	POP
	ADD	R7, R0, #0		;RET location into R7
	LD	R0, R0TMP		;restore original R0
	RET

;------------------------------------------------
; 2's comp subroutine
;------------------------------------------------
TWOCOMP:
	NOT	R0, R0			;flip bits
	ADD	R0, R0, #1		;add 1
	RET

;------------------------------------------------
; stack operations
;------------------------------------------------
PUSH:
	ST	R6, R6TMP
	LD	R6, STACK		;STACK address loads into R6
	STR	R0, R6, #0		;R0 value stored in R6 location
	ADD	R6, R6, #1		;++stack location
	ST	R6, STACK		;incremented stack location into R6
	LD	R6, R6TMP		;loads R6TMP address into R6
	RET

POP:
	ST	R6, R6TMP
	LD	R6, STACK		;current STACK address loads into R6
	ADD	R6, R6, #-1		;--stack location
	ST	R6, STACK		;decremented stack location into R6
	LDR	R0, R6, #0		;value in R6 loads into R0
	LD	R6, R6TMP		;restores original R6 value
	RET

;******************************************************************
;variable declarations
KEY:		.FILL	4
MASK:		.FILL	XFFFE
R0TMP:		.FILL	0
R3TMP:		.FILL	0
R6TMP:		.FILL	0
R7TMP:		.FILL	0
STACK:		.FILL	x3100		;base address
;******************************************************************

	.END				;end of code