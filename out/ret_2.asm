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
_0x00000000:
	lw	$v0, -0x00000004($fp)
	PSR($v0)
	li	$v0, 5
	lw	$v1, ($sp)
	PPR
	bge	$v1, $v0,_0x00000002
	li	$v0, 0
	li	$v0, 1
_0x00000002:
	beqz	$v0, _0x00000001
	nop
	lw	$v0, -0x00000004($fp)
	PSR($v0)
	li	$v0, 1
	lw	$v1, ($sp)
	PPR
	addu	$v0, $v1, $v0
	sw	$v0, -0x00000004($fp)
	j	_0x00000000
	nop
_0x00000001:
	lw	$v0, -0x00000004($fp)
	move	$sp, $fp
	lw	$fp, ($sp)
	PPR
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

