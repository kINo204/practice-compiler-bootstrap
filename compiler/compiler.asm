.include "../lib/lib.asm"

.data
fname_src: .asciiz "samples/ret_2.c"
fname_dst: .asciiz "out/ret_2.asm"
str_include_lib: .asciiz ".include \"../lib/lib.asm\"\n\n"

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
        

        #############
        ##  Lexer  ##
        #############

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
        nop

token_err:
        PRINTLN_STR(str_lexer_err, "Lexer encountered an error.")
        EXIT(-1)
        
tokenize_finish:
        PRINTLN_STR(str_lexer_finish, "Lexing finished.")
        li      $t0, TOKEN_END
        sb      $t0, ($s1)


        ############
        ## Parser ##
        ############

        # Init:
.macro BUF_APPEND(%a_str, %i_len)
        la      $a0, %a_str
        li      $a1, %i_len
        jal     write_buf
        nop
.end_macro
.eqv    LOUTBUF 500
        SBRK(LOUTBUF)
        PSR($v0) # output_buffer_base

        lw      $s0, 4($sp)  # $s0: token_list_index
        move    $s1, $v0     # $s1: output_buffer_index

        BUF_APPEND(str_include_lib, 27) # Add include statement
        j       parse_program
        nop

write_buf: # $a0: addr_str, $a1: strlen
        .data
        str_comma: .asciiz ":"
        str_endl:  .asciiz "\n"
        str_space: .asciiz " "
        .text

        PSR($ra)
loop_wb:
        # Copy a byte:
        lb      $t0, ($a0)
        sb      $t0, ($s1)
        addi    $a0, $a0, 1

        addi    $a1, $a1, -1
        bnez    $a1, loop_wb
        addi    $s1, $s1, 1
# loop end

        lw      $ra, ($sp)
        PPR
        jr      $ra
        nop

parse_function:
        .data
        str_globl: .asciiz ".globl "
        str_psra:  .asciiz "\tPSR($ra)\n"
        str_ppra:  .asciiz "\tlw\t$ra, ($sp)\n\tPPR\n"
        .text

        PSR($ra)

        # Print function head infos:
        # """
        # .globl func_name
        # func_name:
        #       PSR($ra)
        # """
        addi    $s0, $s0, 2
        lb      $s2, ($s0) # $s2: ident_length
        addi    $s0, $s0, 1
        move    $s3, $s0   # $s3: addr_ident
        BUF_APPEND(str_globl, 7)
        # Print ident.
        move    $a0, $s3
        move    $a1, $s2
        jal     write_buf
        nop
        BUF_APPEND(str_endl, 1)
        # Print ident.
        move    $a0, $s3
        move    $a1, $s2
        jal     write_buf
        nop
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_endl, 1)
        BUF_APPEND(str_psra, 10)

        addu    $s0, $s0, $s2 # $s0 on "open_par"
        addi    $s0, $s0, 3
        jal     parse_statement
        nop

        addi    $s0, $s0, 1 # Jump the "close_brac"

        lw      $ra, ($sp)
        PPR
        jr      $ra
        nop

parse_type:

parse_statement:
        .data
        str_jr: .asciiz "\tjr\t$ra\n\tnop\n" # 13
        .text
        PSR($ra)

        # Return statement:
        jal     parse_expr
        addi    $s0, $s0, 1 # jump keyword_return (before parse_expr)
        addi    $s0, $s0, 1 # jump semicolon
        BUF_APPEND(str_ppra, 20)
        BUF_APPEND(str_jr, 13)

        lw      $ra, ($sp)
        PPR
        jr      $ra
        nop

parse_expr: # always get expr's value into $v0
        PSR($ra)

        # literal_int:
        .data
        str_pre_li_v0: .asciiz "\tli\t$v0, " # 9
        .text
        BUF_APPEND(str_pre_li_v0, 9)
        addi    $s0, $s0, 1
        lb      $a1, ($s0)
        addi    $s0, $s0, 1
        move    $a0, $s0
        jal     write_buf
        addu    $s0, $s0, $a1
        BUF_APPEND(str_endl, 1)

        lw      $ra, ($sp)
        PPR
        jr      $ra
        nop

parse_program:
        lb      $t0, ($s0) # Get next token id.

        li      $t1, TOKEN_END # Quit on finishing the tokens.
        beq     $t0, $t1, parse_finish
        nop

        jal     parse_function
        nop

        j       parse_program # Forever loop.
        nop

parse_finish:
        PRINTLN_STR(str_parser_finish, "Parsing finished.")

        OPEN(fname_dst, 1, 0) # Write output file.
        lw      $t0, ($sp) # output_buf_base
        subu    $t1, $s1, $t0 # output_buf_len
        WRITE($v0, $t0, $t1)

