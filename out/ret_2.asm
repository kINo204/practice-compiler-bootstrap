.include "../lib/lib.asm"
ENTRY

.text
.globl main
main:
	PSR($ra)
	PSR($fp)
	move	$fp, $sp
	addi	$sp, $sp, -4
	addi	$sp, $sp, -4
	li	$v0, 4
	sw	$v0, -0x00000004($fp)
	li	$v0, 2
	sw	$v0, -0x00000008($fp)
	li	$v0, 1
	PSR($v0)
	lw	$v0, -0x00000008($fp)
	lw	$v1, ($sp)
	PPR
	addu	$v0, $v1, $v0
	PSR($v0)
	li	$v0, 4
	lw	$v1, ($sp)
	PPR
	mul	$v0, $v1, $v0
	move	$sp, $fp
	lw	$fp, ($sp)
	PPR
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

.text
.globl func
func:
	PSR($ra)
	PSR($fp)
	move	$fp, $sp
	addi	$sp, $sp, -4
	li	$v0, 3
	sw	$v0, -0x00000004($fp)
	li	$v0, 4
	move	$sp, $fp
	lw	$fp, ($sp)
	PPR
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

