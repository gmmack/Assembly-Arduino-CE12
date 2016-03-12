; CMPE12 - Fall 2014
; lab3.asm
;
; This program takes two digits as input and
; performs arithmetic operations on them



; The code will begin in memory at the address
; specified by .orig <number>.

	.ORIG   x3000


START:
; clear all registers that we may use
	AND	R0, R0, 0
	AND	R1, R0, 0
	AND	R2, R0, 0
	AND	R3, R0, 0
	AND	R4, R0, 0
	AND	R5, R0, 0
	AND	R6, R0, 0

; Set R5 to 48 and R6 to -48 to make converting
; easy. inefficient register use but I don't need
; those registers anyway
	LD	R5, POS48
	LD	R6, CONVERT

; prompt user input
	LEA	R0, PROMPT
	PUTS

; get a user-entered character (result in R0)
; echo it back right away (otherwise it isn't visible)
	GETC
	PUTC

; store input1 (otherwise it may be overwritten)
	ADD	R0, R0, R6
	ST	R0, INPUT1

; prompt user input again
	LEA	R0, PROMPT
	PUTS

; echo input
	GETC
	PUTC

; store input2
	ADD	R0, R0, R6
	ST	R0, INPUT2

; YAY SUBTRACTION!!!
; invert INPUT2 and add 1 to form 2's complement
; add this to INPUT1, then print result
	LD	R0, INPUT1
	LD	R1, INPUT2
	LD	R2, CLEAR
	LD	R3, CLEAR
; get two's complement
	NOT	R1, R1
	ADD	R1, R1, #1
; add to input1 and store register
	ADD	R0, R0, R1
	LD	R2, SUBDR
	STR	R0, R2, 0
; print result
	LEA	R0, SUBRES
	PUTS
	LDI	R0, SUBDR
	ADD	R0, R0, R5
	PUTC


; multiplication and loops and stuff
MUL:	LD	R0, INPUT1
	LD	R1, INPUT2
	LD	R2, CLEAR
	LD	R3, CLEAR
; each iteration of loop add INPUT1 to R2
; and subtract 1 from INPUT2 then check
; if INPUT2 > 0 keep looping
; else stop looping, R2 is product
	LOOP:
	ADD	R2, R2, R0
	ADD	R1, R1, #-1
	BRp	LOOP
	LD	R3, MULTDR
	STR	R2, R3, 0
; print result
	LEA	R0, MULTRES
	PUTS
	LDI	R0, MULTDR
; if value >= 10 call separate print fcn
	ADD	R3, R0, #-10
	BRzp	PRINT2
	ADD	R0, R0, R5
	PUTC
	BR	DIV

; 2 digit print fcn. subtract 10 from result until value < 10
; count number of times, the count is the 10's place value
; remaining value in R0 is 1's place
; must be called with the result in R0
PRINT2:	LD	R2, CLEAR
PLOOP:	ADD	R0, R0, #-10
	ADD	R2, R2, #1
	ADD	R3, R0, #-10
	BRzp	PLOOP
; save 1's place value to R1
	ADD	R1, R0, #0
; save 10's place value to R0
	ADD	R0, R2, #0
	ADD	R0, R0, R5
	PUTC
; put 1's place value in R0
	ADD	R0, R1, #0
	ADD	R0, R0, R5
	PUTC


; finally division
DIV:	LD	R0, INPUT1
	LD	R1, INPUT2
	LD	R2, CLEAR
	LD	R3, CLEAR
	LD	R4, CLEAR
	NOT	R1, R1
	ADD	R1, R1, #1
; each iteration, subtract INPUT2 from INPUT1 and
; increment R2, then check if result < INPUT2 stop loop,
; R2 is quotient and value in R0 is remainder
; else keep looping
	LOOP2:
	ADD	R2, R2, #1
	ADD	R0, R0, R1
	ADD	R4, R0, R1
	BRzp	LOOP2
; store results in memory at specific location
	LD	R3, DIVDR
	LD	R4, REMNDR
	STR	R2, R3, 0
	STR	R0, R4, 0
; print results
	LEA	R0, DIVRES
	PUTS
	LDI	R0, DIVDR
	ADD	R0, R0, R5
	PUTC

	LEA	R0, REMRES
	PUTS
	LDI	R0, REMNDR
	ADD	R0, R0, R5
	PUTC


; once everything finishes, jump back to start
	BR	START

; stop the processor
	HALT


; string declarations
PROMPT:		.STRINGZ	"\nPlease enter a one digit number: "
SUBRES:		.STRINGZ	"\n Subtraction Result: "
MULTRES:	.STRINGZ	"\n Multiplication Result: "
DIVRES:		.STRINGZ	"\n Division Result: "
REMRES:		.STRINGZ	"\n Division Remainder: "

; variable declarations
POS48:		.FILL	#48
CONVERT:	.FILL	#-48
INPUT1:		.FILL	0
INPUT2:		.FILL	0
SUBDR:		.FILL	x3100
MULTDR:		.FILL	x3101
DIVDR:		.FILL	x3102
REMNDR:		.FILL	x3103
CLEAR:		.FILL	x0000

; end of code
	.END
