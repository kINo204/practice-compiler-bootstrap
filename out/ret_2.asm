.include "../lib/lib.asm"
ENTRY

.text
.globl main
main:
	PSR($ra)
	PSR($fp)
	move	$fp, $sp
	li	$v0, 1
	PSR($v0)
	li	$v0, 0
	beqz	$v0, _0x00000000
	nop
	li	$v0, 2
	sw	$v0, -0x00000004($fp)
	j	_0x00000001
	nop
_0x00000000:
	li	$v0, 1
	beqz	$v0, _0x00000002
	nop
	li	$v0, 3
	sw	$v0, -0x00000004($fp)
	j	_0x00000003
	nop
_0x00000002:
	li	$v0, 4
	sw	$v0, -0x00000004($fp)
_0x00000003:
_0x00000001:
	lw	$v0, -0x00000004($fp)
	move	$sp, $fp
	lw	$fp, ($sp)
	PPR
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

