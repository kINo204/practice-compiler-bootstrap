.include "../lib/lib.asm"
ENTRY

.text
.globl func
func:
	PSR($ra)
	PSR($fp)
	move	$fp, $sp
	li	$v0, 0
	PSR($v0)
	lw	$v0, 0x00000010($sp)
	sw	$v0, ($sp)
	li	$v0, 0
	PSR($v0)
	lw	$v0, 0x00000010($sp)
	sw	$v0, ($sp)
	lw	$v0, -0x00000004($fp)
	PSR($v0)
	lw	$v0, -0x00000008($fp)
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

.text
.globl main
main:
	PSR($ra)
	PSR($fp)
	move	$fp, $sp
	li	$v0, 1
	PSR($v0)
	li	$v0, 2
	lw	$v1, ($sp)
	PPR
	addu	$v0, $v1, $v0
	PSR($v0)
	jal	func
	nop
	PPR
	move	$sp, $fp
	lw	$fp, ($sp)
	PPR
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

