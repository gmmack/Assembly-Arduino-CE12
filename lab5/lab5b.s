/* http://tigcc.ticalc.org/doc/gnuasm.html */
	
	
#include <WProgram.h>
/* define all global symbols here */
.global myprog	
.text	
.set noreorder

.ent myprog 
/* directive that marks symbol 'main' as function in ELF   
 * output
           */
myprog:
	
	/* Print original message */
	la      $a0,Serial 			
	la 		$a1,msg 			
	jal     _ZN5Print7printlnEPKc
	nop
	
	la      $s2, msg		/* input char ptr into s2 */
	li      $s4, 32			/* ascii space into s4 */
	
/* string reversal */
start:
	li      $s3, 0			/* init stack pointer */
	la      $s1, tmp		/* output buffer into s1 */
	jal		initTmp			/* initialize temp array 0*/
	nop
	
loop:
	lb      $s5, 0($s2)		/* load char into s5 */
	nop
	addi    $s2, $s2, 1		/* ++input ptr */
	beqz    $s5, flush
	nop
	beq     $s5, $s4, flush
	nop
	addi    $s0, $s5, 0		/* char into s0 */
	jal		push			/* push char */
	addi	$s3, $s3, 1		/* ++stack counter */
	j		loop
	nop

flush:
	beqz	$s3, print		/* if stack counter==0 print */
	nop
	jal		pop				/* pop char */
	addi	$s3, $s3, -1	/* --stack counter */
	sb		$s0, 0($s1)		/* store char */
	addi	$s1, $s1, 1		/* ++output buf ptr */
	j		flush
	nop

print:
	la      $a0, Serial     /* call print */
	la		$a1, tmp
	jal     _ZN5Print7printlnEPKc
	nop
	beqz	$s5, done		/* exit loop if null */
	nop
	j		start			/* if !=null continue */
	nop

done:

/* 5000 ms delay for printing */
	addi    $a0, $0, 5000
    jal     delay
    nop

/* loop back to top */	
	j       myprog
    nop

/********************************************************/
/* Push and Pop subroutines */
/********************************************************/
Push:
	addi	$sp, $sp, -4		/* decrement stack pointer */
	sw		$s0, 0($sp)			/* save s0 to stack */
	jr		$ra					/* return */
	nop
	
Pop:
	lw		$s0, 0($sp)			/* copy from stack to s0 */
	nop
	addi	$sp, $sp, 4			/* increment stack pointer */
	jr		$ra
	nop

/* delays for a certain number of ms */
delay:
	addi    $t0, $a0, 0			/* init t0 to input in line 69*/

delayLoop:
	beqz	$t0, delayEnd		/* end if t0==0 */
	nop
	addi	$t0, $t0, -1		/* t0-- */
	li		$t1, 16000			/* wait 20000 cycles (1 ms)
	
delayMs:
	beqz	$t1, delayMsEnd		/* if t1==0 exit loop */
	nop
	addi	$t1, $t1, -1		/* t1-- */
	j		delayMs
	nop
	
delayMsEnd:
	j		delayLoop
	nop
	
delayEnd:
	jr		$ra
	nop

/********************************************************/
/* Function: Initialize temp array with zeros */
/********************************************************/
initTmp:
	addi	$t7, $0, 10
	la		$t9, tmp
	nop
	lb		$t8, zChar
	nop
inloop:
	sb		$t8, 0($t9)
	addi	$t9, $t9, 1
	addi	$t7, $t7, -1
	beq		$t7, $0, indone
	nop
	j		inloop
	nop

indone:
	jr		$ra
	nop

	/* return to main */
	
.end myprog 
/* directive that marks end of 'main' function and registers
           
 * size in ELF output
           */
	

.data
zChar:	.byte	0					/* Used to clear the temporary array */
msg:	.ascii	"hello world\0"		/* will contain message to be reversed */ 	
tmp:	.space 	10					/* temporary array to contain reversed word */