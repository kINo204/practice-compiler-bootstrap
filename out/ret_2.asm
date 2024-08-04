.include "../lib/lib.asm"
ENTRY

.text
.globl main
main:
	PSR($ra)
	li	$v0, 1
	PSR($v0)
	li	$v0, 2
	lw	$v1, ($sp)
	PPR
	blt	$v1, $v0,AAAA
	li	$v0, 0
	li	$v0, 1
AAAA:
	beqz	$v0, AAAB
	nop
	li	$v0, 2
	PSR($v0)
	li	$v0, 5
	lw	$v1, ($sp)
	PPR
	beq	$v0, $v1,AAAD
	li	$v0, 0
	li	$v0, 1
AAAD:
	beqz	$v0, AAAB
	nop
	li	$v0, 4
	beqz	$v0, AAAB
	nop
	j	AAAC
	li	$v0, 1
AAAB:	li	$v0, 0
AAAC:
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

