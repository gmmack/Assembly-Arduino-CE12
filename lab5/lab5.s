/* http://tigcc.ticalc.org/doc/gnuasm.html */
	
	
#include <WProgram.h>

	

/* define all global symbols here */
	
.global myprog

	

/* define which section (for example "text")
     
 * does this portion of code resides in. Typically,
     
 * all your code will reside in .text section as
     
 * shown below.
    */
	
.text

	

/* This is important for an assembly programmer. This
     
 * directive tells the assembler that don't optimize
     
 * the order of the instructions as well as don't insert
     
 * 'nop' instructions after jumps and branches.
    */
	
.set noreorder



/*********************************************************************
 
 * main()
 
 * This is where the PIC32 start-up code will jump to after initial
 
 * set-up.
 
********************************************************************/



.ent myprog 
/* directive that marks symbol 'main' as function in ELF
           
 * output
           */



myprog:

jal		EnableLED
		nop

loop:
	
jal		LEDon
		nop
	
/* load register a0 with Serial object address */
	
la      $a0,Serial
	

/* load register a1 with string constant address */
	
la 	$a1,hello
	

/* call the C++ function to do Serial.println("Hello, world!") */
	
/* notice that the symbol name is "mangled" in C++ */
        
jal     _ZN5Print7printlnEPKc
nop

li		$a0, 0x0
jal		delayLoop
		nop

jal		LEDoff
		nop
		
j       loop
        nop
	
################################
## Subroutine to enable LED 5 ##
################################
EnableLED:
	li 		$t9, 0x1			# li = pseudo op to load an immediate value into a register, 1 => $t9 
	li 		$t8, 0xbf886140  	# load address of TRISF into $t8 
	sw 		$t9, 4($t8)			# store $t9 into address defined by $t8 plus an offset of 4
								# this clears TRISF, making LED5 an output
	jr 		$ra					# jr is the return instruction (like RET in LC3), 
								# $ra is the return address (like R7 in LC3)
	nop
	
###########################
# turn on led5 subroutine #
###########################
LEDon:
	li 		$t9, 0x1
	li 		$t8, 0xbf886150		# load address of PORTF into $t8 
	sw 		$t9, 8($t8)			# store $t9 into PORTF with an offset of 8 to turn on LED5
	jr		$ra
	nop
	
###########################
# turn off led5 subroutine #
###########################
LEDoff:
	li 		$t9, 0x1
	li 		$t8, 0xbf886150
	sw 		$t9, -4($t8)			# store $t9 into PORTF with an offset of 4 to turn off LED5	
	jr		$ra
	nop	

###########################
# delay subroutine #
###########################
delayLoop:
	li		$t0, 2000
	li		$t1, 9000
	loop1:
			beq		$a0, $t0, loopend
			nop
			addi	$a0, $a0, 1
			li		$a1, 0
	loop2:
			beq		$a1, $t1, loop1
			nop
			addi	$a1, $a1, 1
			j		loop2
			nop
	loopend:
	jr		$ra
	nop

/* return to main */
	


.end myprog 
/* directive that marks end of 'main' function and registers
           
 * size in ELF output
           */
	

	

.data
hello:	
	

.ascii "Hello, world!\0"

