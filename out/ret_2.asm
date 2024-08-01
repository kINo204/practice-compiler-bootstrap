.include "../lib/lib.asm"

.globl main
main:
	PSR($ra)
	li	$v0, 2
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop
