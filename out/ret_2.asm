.include "../lib/lib.asm"
ENTRY

.text
.globl main
main:
	PSR($ra)
	PSR($fp)
	move	$fp, $sp
	li	$v0, 2
	PSR($v0)
	li	$v0, 3
	sw	$v0, -0x00000004($fp)
	li	$v0, 4
	sw	$v0, -0x00000004($fp)
	li	$v0, 5
	sw	$v0, -0x00000004($fp)
	lw	$v0, -0x00000004($fp)
	move	$sp, $fp
	lw	$fp, ($sp)
	PPR
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

