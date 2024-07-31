.include "../lib/lib.asm"

.data
fname_src: .asciiz "samples/ret_2.c"

.text
        # Alloc file input buffer.
.eqv    LINBUF  100 # max bytes
        SBRK(LINBUF)
        PSR($v0) # input_buffer_base

        # Read the source code file.
        OPEN(fname_src, 0, 0)
        move    $s0, $v0 # src_fd

        lw      $s1, ($sp) # input_buffer_base
        READ($s0, $s1, LINBUF)
        PSR($v0) # input_len

        CLOSE($s0)

        # Create token list.
.eqv    LTOKENS 50 # token list
        SBRK(LTOKENS)
        PSR($v0) # token_list_base
        
        # Tokenizing state machine.
        # $s0: input_buffer_index
        lw      $s0, 8($sp)
        # $s1: token_list_index
        lw      $s1, 0($sp)

        PRINTLN_STR(str_lexer_start, "Lexer starting:")
tokenize_start:
        # Read a byte in $t0.
        lb      $t0, ($s0)
        addi    $s0, $s0, 1

        # Break on '\0'(end of input).
        beqz    $t0, tokenize_finish
        nop

whitespace:
        li      $t1, ' '
        li      $t2, '\n'
        li      $t3, '\r'

        beq     $t0, $t1, tokenize_start
        nop
        beq     $t0, $t2, tokenize_start
        nop
        beq     $t0, $t3, tokenize_start
        nop

open_par:
        li      $t1, '('
        bne     $t0, $t1, close_par
        li      $t1, OPEN_PAR

        PRINTLN_STR(str_lexer_open_par, "OPEN_PAR")
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

close_par:
        li      $t1, ')'
        bne     $t0, $t1, open_brac
        li      $t1, CLOSE_PAR

        PRINTLN_STR(str_lexer_close_par, "CLOSE_PAR")
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

open_brac:
        li      $t1, '{'
        bne     $t0, $t1, close_brac
        li      $t1, OPEN_BRAC

        PRINTLN_STR(str_lexer_open_brac, "OPEN_BRAC")
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

close_brac:
        li      $t1, '}'
        bne     $t0, $t1, semicolon
        li      $t1, CLOSE_BRAC

        PRINTLN_STR(str_lexer_close_brac, "CLOSE_BRAC")
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1
        
semicolon:
        li      $t1, ';'
        bne     $t0, $t1, assignment
        li      $t1, SEMICOLON

        PRINTLN_STR(str_lexer_semicolon, "SEMICOLON")
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

assignment:
        li      $t1, '='
        bne     $t0, $t1, literal_hex
        li      $t1, ASSIGN

        PRINTLN_STR(str_lexer_assignment, "ASSIGN")
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

literal_hex:
        li      $t1, '0'
        li      $t2, 'x'
        bne     $t0, $t1, literal_int
        lb      $t3, ($s0) # check next byte
        bne     $t3, $t2, literal_int
        li      $t1, LITERAL_HEX

        PRINT_STR(str_lexer_literal_hex, "LITERAL_HEX: 0X")
        sb      $t1, ($s1)  # save token id
        addi    $s0, $s0, 1
        move    $s3, $s0    # token content start
        addi    $s2, $s1, 1 # token len pointer
        addi    $s1, $s2, 1 # token content pointer
loop_lh:
        lb      $t0, ($s0) # Read next byte.
        li      $t1, '/'
        sltu    $t2, $t1, $t0
        li      $t1, ':'
        sltu    $t3, $t0, $t1
        and     $t1, $t2, $t3
        beqz    $t1, finish_lh # Break if non-digit.
        nop
        sb      $t0, ($s1) # Save the token content byte.
        PRINT_CH($t0)
        addi    $s1, $s1, 1
        j       loop_lh
        addi    $s0, $s0, 1
finish_lh:
        ENDL
        sub     $t0, $s0, $s3
        sb      $t0, ($s2)

        j       tokenize_start
        nop

literal_int:
        li      $t1, '/'
        sltu    $t2, $t1, $t0
        li      $t1, ':'
        sltu    $t3, $t0, $t1
        and     $t1, $t2, $t3
        beqz    $t1, keyword_int
        li      $t1, LITERAL_INT

        PRINT_STR(str_lexer_literal_int, "LITERAL_INT: ")
        sb      $t1, ($s1)  # save token id
        addi    $s0, $s0, -1
        move    $s3, $s0    # token content start
        addi    $s2, $s1, 1 # token len pointer
        addi    $s1, $s2, 1 # token content pointer
loop_li:
        lb      $t0, ($s0) # Read next byte.
        li      $t1, '/'
        sltu    $t2, $t1, $t0
        li      $t1, ':'
        sltu    $t3, $t0, $t1
        and     $t1, $t2, $t3
        beqz    $t1, finish_li # Break if non-digit.
        nop
        sb      $t0, ($s1) # Save the token content byte.
        PRINT_CH($t0)
        addi    $s1, $s1, 1
        j       loop_li
        addi    $s0, $s0, 1
finish_li:
        ENDL
        sub     $t0, $s0, $s3
        sb      $t0, ($s2)

        j       tokenize_start
        nop

keyword_int:
        li      $t2, 'i'
        li      $t3, 'n'
        li      $t4, 't'

        bne     $t0, $t2, keyword_return
        lb      $t1, 0($s0)
        bne     $t1, $t3, keyword_return
        lb      $t1, 1($s0)
        bne     $t1, $t4, keyword_return
        nop

        PRINTLN_STR(str_lexer_keyword_int, "KEYWORD_INT")
        li      $t1, KEYWORD_INT
        sb      $t1, ($s1)
        addi    $s0, $s0, 2

        j       tokenize_start
        addi    $s1, $s1, 1
        
keyword_return:
        li      $t2, 'r'
        li      $t3, 'e'
        li      $t4, 't'
        li      $t5, 'u'
        li      $t6, 'r'
        li      $t7, 'n'

        bne     $t0, $t2, ident
        lb      $t1, 0($s0)
        bne     $t1, $t3, ident
        lb      $t1, 1($s0)
        bne     $t1, $t4, ident
        lb      $t1, 2($s0)
        bne     $t1, $t5, ident
        lb      $t1, 3($s0)
        bne     $t1, $t6, ident
        lb      $t1, 4($s0)
        bne     $t1, $t7, ident
        nop

        PRINTLN_STR(str_lexer_keyword_return, "KEYWORD_RETURN")
        li      $t1, KEYWORD_RETURN
        sb      $t1, ($s1)
        addi    $s0, $s0, 5

        j       tokenize_start
        addi    $s1, $s1, 1

ident:
        # Is alpha or '_':
        li      $t1, '@'
        sltu    $t2, $t1, $t0
        li      $t1, '['
        sltu    $t3, $t0, $t1
        li      $t1, '`'
        sltu    $t4, $t1, $t0
        li      $t1, '{'
        sltu    $t5, $t0, $t1
        li      $t1, 94
        sltu    $t6, $t1, $t0
        li      $t1, 96
        sltu    $t7, $t0, $t1

        and     $t2, $t2, $t3
        and     $t4, $t4, $t5
        and     $t6, $t6, $t7
        or      $t1, $t2, $t4
        or      $t1, $t1, $t6
        beqz    $t1, token_err
        li      $t1, IDENT

        PRINT_STR(str_lexer_identifier, "IDENT: ")
        sb      $t1, ($s1)  # save token id
        addi    $s0, $s0, -1
        move    $s3, $s0    # token content start
        addi    $s2, $s1, 1 # token len pointer
        addi    $s1, $s2, 1 # token content pointer
loop_id:
        lb      $t0, ($s0) # Read next byte.
        li      $t1, '@'
        sltu    $t2, $t1, $t0
        li      $t1, '['
        sltu    $t3, $t0, $t1
        li      $t1, '`'
        sltu    $t4, $t1, $t0
        li      $t1, '{'
        sltu    $t5, $t0, $t1
        li      $t1, 94
        sltu    $t6, $t1, $t0
        li      $t1, 96
        sltu    $t7, $t0, $t1

        and     $t2, $t2, $t3
        and     $t4, $t4, $t5
        and     $t6, $t6, $t7
        or      $t1, $t2, $t4
        or      $t1, $t1, $t6
        beqz    $t1, finish_id # Break if non-alphabetic.
        nop

        sb      $t0, ($s1) # Save the token content byte.
        PRINT_CH($t0)
        addi    $s1, $s1, 1
        j       loop_id
        addi    $s0, $s0, 1
finish_id:
        ENDL
        sub     $t0, $s0, $s3
        sb      $t0, ($s2)

        j       tokenize_start

token_err:
        PRINTLN_STR(str_lexer_err, "Lexer encountered an error.")
        
tokenize_finish:
        PRINTLN_STR(str_lexer_finish, "Lexing finished.")
