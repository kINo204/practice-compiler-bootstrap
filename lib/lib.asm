.include "tokens.asm"

.macro EXIT(%i_val)
        li      $a0, %i_val
        li      $v0, 17
        syscall
.end_macro

#####
# Stack definitions.
#####

# Push register to stack.
.macro PSR(%r_src)
        addi    $sp, $sp, -4
        sw      %r_src, ($sp)
.end_macro

# Pop register from stack.
.macro PPR
        addi    $sp, $sp, 4
.end_macro


#####
# Heap definitions
#####

.macro SBRK(%i_nbyte)
        li      $a0, %i_nbyte
        li      $v0, 9
        syscall
.end_macro


#####
# File ops
#####

.macro OPEN(%a_fname, %i_flag, %i_mode)
        la      $a0, %a_fname
        li      $a1, %i_flag
        li      $a2, %i_mode
        li      $v0, 13
        syscall
.end_macro

.macro READ(%r_fd, %r_buf, %i_nchar)
        move    $a0, %r_fd
        move    $a1, %r_buf
        li      $a2, %i_nchar
        li      $v0, 14
        syscall
.end_macro

.macro WRITE(%r_fd, %r_buf, %r_nchar)
        move    $a0, %r_fd
        move    $a1, %r_buf
        move    $a2, %r_nchar
        li      $v0, 15
        syscall
.end_macro

.macro CLOSE(%r_fd)
        move    $a0, %r_fd
        li      $v0, 16
        syscall
.end_macro


#####
# System I/O
#####

.macro  ENTRY
        PRINTLN_STR(STR_ENTRY, "Running program ...")
        jal     main
        nop
        move    $v1, $v0
        PRINT_STR(STR_END, "Program exits with value ")
        PRINT_INT($v1)
        EXIT(0)
.end_macro

.data
STR_ENDL: .asciiz "\n"

.macro PRINT_CH(%r_char)
        move    $a0, %r_char
        li      $v0, 11
        syscall
.end_macro

.macro PRINT_INT(%r_int)
        move    $a0, %r_int
        li      $v0, 1
        syscall
.end_macro

.macro PRINT_STR(%t_label, %a_str)
.data
%t_label: .asciiz %a_str
.text
        la      $a0, %t_label
        li      $v0, 4
        syscall
.end_macro

.macro ENDL
        la      $a0, STR_ENDL
        li      $v0, 4
        syscall
.end_macro

.macro PRINTLN_STR(%t_label, %a_str)
.data
%t_label: .asciiz %a_str
.text
        la      $a0, %t_label
        li      $v0, 4
        syscall
        ENDL
.end_macro
