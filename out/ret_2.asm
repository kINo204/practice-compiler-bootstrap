.include "../lib/lib.asm"

.text
.globl main
main:
	PSR($ra)
	li	$v0, 1
	subu	$v0, $0, $v0
	xori	$v0, $v0, 0xffffffff
	li	$v1, 1
	beqz	$v0, AAAA
	nop
	li	$v1, 0
AAAA:
	move	$v0, $v1
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop
