.include "../lib/lib.asm"
ENTRY

.text
.globl main
main:
	PSR($ra)
	PSR($fp)
	move	$fp, $sp
	addi	$sp, $sp, -4
	li	$v0, 2
	sw	$v0, -0x00000004($fp)
	addi	$sp, $sp, -4
	li	$v0, 66
	sw	$v0, -0x00000008($fp)
	addi	$sp, $sp, -4
	li	$v0, 4
	sw	$v0, -0x0000000c($fp)
	lw	$v0, -0x00000004($fp)
	PSR($v0)
	lw	$v0, -0x0000000c($fp)
	lw	$v1, ($sp)
	PPR
	addu	$v0, $v1, $v0
	move	$sp, $fp
	lw	$fp, ($sp)
	PPR
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

