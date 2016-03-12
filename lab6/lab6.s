/* Push a register*/
.macro  push reg
sw      \reg, ($sp)
addi    $sp, $sp, -4
.endm

/* Pop a register*/
.macro  pop reg
addi    $sp, $sp, 4
lw      \reg, ($sp)
.endm
	
#include <WProgram.h>

/* Jump to our customized routine by placing a jump at the vector 4 interrupt vector offset */
.section .vector_4,"xaw"
	j T1_ISR

/* The .global will export the symbols so that the subroutines are callable from main.cpp */
.global PlayNote
.global SetupPort
.global SetupTimer 

/* This starts the program code */
.text
/* We do not allow instruction reordering in our lab assignments. */
.set noreorder

	

/*********************************************************************
 * myprog()
 * This is where the PIC32 start-up code will jump to after initial
 * set-up.
 ********************************************************************/
.ent myprog

/* This should set up Port D pin 9 (bit 3) for digital output */
SetupPort:
	li		$t1, 0b1000				/* load bit mask for bit3 of TRISD */
	li		$t0, 0xbf8860c0			/* load address of TRISD */
	sw		$t1, 4($t8)				/* clear TRISD bit3 */
	
	jr $ra
	nop

/* This should configure Timer 1 and the corresponding interrupts,
 * but it should not enable the timer.
 */
SetupTimer:	
	
	li		$t0, 0xbf800600			/* load T1 address */
	li		$t1, 0b110000			/* load bitmask for writing to TCKPS1 */
	sw		$t1, 8($t0)				/* write bitmask to T1CON[5:4] (TCKPS[1:0]) sets max prescalar (256) */
	
	/* load bitmask and address for writing to interrupt priority register */
	li		$t0, 0xbf8810a0
	li		$t1, 0b10000
	sw		$t1, 8($t0)				/* write bitmask to IPC1[4:2] (T1IP[2:0]) */
	
	/* load bitmask and address for writing to interrupt enable register */
	li		$t0, 0xbf881060
	li		$t1, 0b10000
	sw		$t1, 8($t0)				/* write bitmask to interrupt enable bit of T1IE */
	
	jr $ra
	nop

	
/* This should take the following arguments:
*  $a0 = tone frequency
*  $a1 = tone duration
*  $a2 = full note duration ($a2 - $a1 is the amount of silence after the tone)
*/
PlayNote:
	
	push $ra
	push $s0
	push $s1

	/* calculates length of silence after note */
	sub		$s0, $a2, $a1
	
	/* check for a 0 frequency (can't divide by 0) */
	beq		$a0, $zero, skip
	
	/* load unsigned 1000 to t0 */
	li		$t0, 0b001111101000
	
	/* get period (divide 1 by freq) in ms */
	divu	$t0, $a0
	
	/* puts result in t1 */
	mflo	$t1
	
	/* load unsigned 156,250 into $t0 (curr value: 118) */
	li		$t0, 0b01110110
	
	/* get cycles per period (mult by 156,250) -- 156,250 is opt clock speed (80 mhz) */
	/* divided by prescalar (256), then divided by 2 */
	multu	$t0, $t1
	
	/* puts result in t1 */
	mflo	$t1
	
	/* load address of PR1 & write t0 (ms/period) to PR1 */
	li		$t0, 0xbf800620
	sw		$t1, 8($t0)
	
	/* turn on timer1, interrupts will occur and call T1_ISR */
	jal		EnableTimer
	nop
	
skip:
	/* put note duration in a0 (allowed to do this b/c we don't need to save freq anymore) */
	add		$a0, $a1, $zero
	
	/* delay for note duration (timer and interrupts still function while delaying) */
	jal		delay
	nop
	
	/* turn off timer */
	jal		DisableTimer
	nop
	
	/* load remaining duration to a0 */
	add		$a0, $s0, $zero
	
	/* more delay!!! */
	jal		delay
	nop	
	
	pop $s1
	pop $s0
	pop $ra
	
	jr $ra
	nop

/* This procedure is not required, but I found it easier this way. It is not called from main.cpp. */
/* This turns on the timer to start counting */	
EnableTimer:
	li		$t0, 0xbf800600			/* load T1CON address */
	li		$t1, 0b1000000000000000	/* load mask to write to ON */
	sw		$t1, 8($t0)				/* write mask to ON */
	
	jr $ra
	nop
	
/* This procedure is not required, but I found it easier this way. It is not called from main.cpp. */
/* This turns off the timer from counting */
DisableTimer:
	li		$t0, 0xbf800600			/* load T1CON address */
	li		$t1, 0b1000000000000000	/* load mask to write to ON */
	sw		$t1, 4($t0)				/* write mask to ON */
	
	li		$t0, 0xbf800620			/* load PR1 address */
	li		$t1, 0b1111111111111111	/* load mask to write to PR1 */
	sw		$t1, 4($t0)				/* write to PR1clr (clears every bit) */
	
	jr $ra
	nop
	
/* The ISR should toggle the speaker output value and then clear and re-enable the interrupts. */
T1_ISR:
	li		$t0, 0xbf8860d0			/* load PORTD address */
	li		$t1, 0b1000				/* load bit mask for bit3 */
	sw		$t1, 12($t0)			/* write to PORTD inv reg */
	
	li		$t0, 0xbf881030			/* load T1IF address */
	li		$t1, 0b10000			/* load bit mask for T1IF */
	sw		$t1, 4($t0)				/* clear T1IF */
	
	eret
	nop
	
.end myprog /* directive that marks end of 'myprog' function and registers
           * size in ELF output
           */
