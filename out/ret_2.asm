.include "../lib/lib.asm"
ENTRY

.text
.globl main
main:
	PSR($ra)
	li	$v0, 9
	PSR($v0)
	lw	$v0, ($sp)
	PPR
	PSR($v0)
	li	$v0, 8
	PSR($v0)
	li	$v0, 6
	lw	$v1, ($sp)
	PPR
	mul	$v0, $v1, $v0
	PSR($v0)
	li	$v0, 2
	lw	$v1, ($sp)
	PPR
	div	$v0, $v1, $v0
	PSR($v0)
	lw	$v0, ($sp)
	PPR
	lw	$v1, ($sp)
	PPR
	subu	$v0, $v1, $v0
	PSR($v0)
	lw	$v0, ($sp)
	PPR
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

