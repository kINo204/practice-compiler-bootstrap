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
	PSR($k0)
	move	$k0, $sp
	li	$v0, 0
	PSR($v0)
_0x00000003:
	lw	$v0, -0x0000000c($fp)
	PSR($v0)
	li	$v0, 2
	lw	$v1, ($sp)
	PPR
	bge	$v1, $v0,_0x00000004
	li	$v0, 0
	li	$v0, 1
_0x00000004:
	beqz	$v0, _0x00000001
	nop
	j	_0x00000002
	nop
_0x00000000:
	lw	$v0, -0x0000000c($fp)
	PSR($v0)
	li	$v0, 1
	lw	$v1, ($sp)
	PPR
	addu	$v0, $v1, $v0
	sw	$v0, -0x0000000c($fp)
	j	_0x00000003
	nop
_0x00000002:
	PSR($k0)
	move	$k0, $sp
	PSR($k0)
	move	$k0, $sp
	li	$v0, 0
	PSR($v0)
_0x00000008:
	lw	$v0, -0x00000018($fp)
	PSR($v0)
	li	$v0, 3
	lw	$v1, ($sp)
	PPR
	bge	$v1, $v0,_0x00000009
	li	$v0, 0
	li	$v0, 1
_0x00000009:
	beqz	$v0, _0x00000006
	nop
	j	_0x00000007
	nop
_0x00000005:
	lw	$v0, -0x00000018($fp)
	PSR($v0)
	li	$v0, 1
	lw	$v1, ($sp)
	PPR
	addu	$v0, $v1, $v0
	sw	$v0, -0x00000018($fp)
	j	_0x00000008
	nop
_0x00000007:
	PSR($k0)
	move	$k0, $sp
	lw	$v0, -0x00000004($fp)
	PSR($v0)
	li	$v0, 1
	lw	$v1, ($sp)
	PPR
	addu	$v0, $v1, $v0
	sw	$v0, -0x00000004($fp)
	move	$sp, $k0
	lw	$k0, ($sp)
	PPR
	j	_0x00000005
	nop
_0x00000006:
	move	$sp, $k0
	lw	$k0, ($sp)
	PPR
	move	$sp, $k0
	lw	$k0, ($sp)
	PPR
	j	_0x00000000
	nop
_0x00000001:
	move	$sp, $k0
	lw	$k0, ($sp)
	PPR
	lw	$v0, -0x00000004($fp)
	move	$sp, $fp
	lw	$fp, ($sp)
	PPR
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

