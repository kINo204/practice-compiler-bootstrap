.include "../lib/lib.asm"
ENTRY

.text
.globl main
main:
	PSR($ra)
	li	$v0, 0xa
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

