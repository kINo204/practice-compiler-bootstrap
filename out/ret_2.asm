.include "../lib/lib.asm"
ENTRY

.text
.globl main
main:
	PSR($ra)
	li	$v0, 0
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

.text
.globl fun
fun:
	PSR($ra)
	li	$v0, 1
	subu	$v0, $0, $v0
	lw	$ra, ($sp)
	PPR
	jr	$ra
	nop

