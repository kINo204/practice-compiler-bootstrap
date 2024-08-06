.include "../lib/lib.asm"
ENTRY

.text
.globl main
main:
	PSR($ra)
	PSR($fp)
	move	$fp, $sp
	li	$v0, 0
	PSR($v0)
	li	$v0, 1
	PSR($v0)
	li	$v0, 4
	PSR($v0)
	li	$v0, 5
	sw	$v0, -0x0000000c($fp)
	lw	$v0, -0x00000000($fp)
	move	$sp, $fp
	lw	$fp, ($sp)
	PPR
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

