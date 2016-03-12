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
    la      $a1,msg             
    jal     _ZN5Print7printlnEPKc
    nop 

/* reverse the letters in the words of a string */
    la      $s2, msg        /* $s2 input char ptr */
    li      $s4, 32         /* $s4 ascii whitespace */
rev_start:
    li      $s3, 0          /* $s3 stack counter */
    la      $s1, tmp        /* $s1 output buffer */
    jal     initTmp         /* initialize temp array 0 */
    nop
rev_loop:
    lb      $s5, 0($s2)     /* load a char */
    nop
    addi    $s2, $s2, 1     /* inc input ptr */
    beqz    $s5, rev_flush
    nop
    beq     $s5, $s4, rev_flush
    nop
    addi    $s0, $s5, 0
    jal     push            /* push the char */
    addi    $s3, $s3, 1     /* inc stack counter */
    j       rev_loop
    nop
rev_flush:
    beqz    $s3, rev_print
    nop
    jal     pop             /* pop a char */
    addi    $s3, $s3, -1    /* dec stack counter */
    sb      $s0, 0($s1)     /* store the char */
    addi    $s1, $s1, 1     /* increment out buf ptr */
    j       rev_flush
    nop
rev_print:
    la      $a0, Serial     /* call print */
    la      $a1, tmp
    jal     _ZN5Print7printlnEPKc
    nop
    beqz    $s5, rev_done   /* exit loop on null */
    nop
    j       rev_start       /* else continue */
    nop
rev_done:

/* delay 3 sec before printing again */
    addi    $a0, $0, 3000
    jal     delay_n
    nop

/* loop forever and ever */
    j       myprog
    nop

/* push
 *   stack subroutine
 *
 *   @param - s0 value to push
 */
push:
    addi    $sp, $sp, -4
    sw      $s0, 0($sp)
    jr      $ra
    nop

/* pop
 *   stack subroutine
 *
 *   @return - $s0 poped value
 */
 pop:
    lw      $s0, 0($sp)
    nop
    addi    $sp, $sp, 4
    jr      $ra
    nop

 /* delay_n
 *   delays for a number of milliseconds
 *
 *   @param - $a0 number of ms
 */
 delay_n:
    addi    $t0, $a0, 0         /* init $t0 to n */
 delay_n_loop:
    beqz    $t0, delay_n_done   /* return when $t0 == 0 */
    nop
    addi    $t0, $t0, -1        /* $t0 -= 1 */
    li      $t1, 16000          /* busy wait for 20000 cycles (1 ms) */
delay_ms:
    beqz    $t1, delay_ms_done  /* break loop when $t1 == 0 */
    nop
    addi    $t1, $t1, -1        /* $t1 -= 1 */
    j       delay_ms
    nop
delay_ms_done:
    j       delay_n_loop
    nop
delay_n_done:
    jr      $ra
    nop

/********************************************************/
/* Function: Initialize temp array with zeros */
/********************************************************/
initTmp:
    addi    $t7, $0, 10
    la      $t9, tmp
    nop
    lb      $t8, zChar
    nop
inloop:
    sb      $t8, 0($t9)
    addi    $t9, $t9, 1
    addi    $t7, $t7, -1
    beq     $t7, $0, indone
    nop
    j       inloop
    nop

indone:
    jr      $ra
    nop

/* return to main */    
.end myprog 
/* directive that marks end of 'main' function and registers    
 * size in ELF output
 */

.data
zChar:  .byte   0                   /* Used to clear the temporary array */
msg:    .ascii  "Hello, World!\0"    /* will contain message to be reversed */   
tmp:    .space  10                  /* temporary array to contain reversed word */
