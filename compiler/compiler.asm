.include "../lib/lib.asm"

.data
fname_src: .asciiz "samples/ret_2.c"
fname_dst: .asciiz "out/ret_2.asm"
str_include_lib: .asciiz ".include \"../lib/lib.asm\"\n" # 26
str_sysent: .asciiz "ENTRY\n\n"

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
        bne     $t0, $t1, bit_compl
        nop
        lb      $t0, ($s0) # Check next byte
        bne     $t0, $t1, ta_true_assign
        nop
# equality:
        PRINTLN_STR(str_lexer_equal, "EQUAL")
        addi    $s0, $s0, 1
        j       ta_finish
        li      $t1, EQUAL
ta_true_assign:
        PRINTLN_STR(str_lexer_assignment, "ASSIGN")
        j       ta_finish
        li      $t1, ASSIGN
ta_finish:
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

bit_compl:
        li      $t1, '~'
        bne     $t0, $t1, plus
        li      $t1, BIT_COMPL

        PRINTLN_STR(str_lexer_bit_compl, "BIT_COMPL")
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

plus:
        li      $t1, '+'
        bne     $t0, $t1, minus
        li      $t1, PLUS

        PRINTLN_STR(str_lexer_plus, "PLUS")
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

minus:
        li      $t1, '-'
        bne     $t0, $t1, tmult
        li      $t1, MINUS

        PRINTLN_STR(str_lexer_minus, "MINUS")
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

tmult: # 't' stands for token.
        li      $t1, '*'
        bne     $t0, $t1, tdiv
        li      $t1, TMULT

        PRINTLN_STR(str_lexer_mult, "MULT")
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

tdiv: # 't' stands for token.
        li      $t1, '/'
        bne     $t0, $t1, negation
        li      $t1, TDIV

        PRINTLN_STR(str_lexer_div, "DIV")
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

negation:
        li      $t1, '!'
        bne     $t0, $t1, tand
        nop
# Check next byte:
        li      $t1, '='
        lb      $t0, ($s0)
        bne     $t0, $t1, tn_true_neg
        nop
# not equal
        PRINTLN_STR(str_lexer_not_equal, "NOT_EQUAL")
        addi    $s0, $s0, 1
        j       tn_finish
        li      $t1, NOT_EQUAL
        tn_true_neg:
        PRINTLN_STR(str_lexer_negation, "NEGATION")
        j       tn_finish
        li      $t1, NEGATION
tn_finish:
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

tand:
        li      $t1, '&'
        bne     $t0, $t1, tor
        nop
        lb      $t0, ($s0) # Check next byte
        bne     $t0, $t1, tand_bit_and
        nop
# logical and:
        PRINTLN_STR(str_lexer_and, "AND")
        addi    $s0, $s0, 1
        j       tand_finish
        li      $t1, TAND
tand_bit_and:
        PRINTLN_STR(str_lexer_bit_and, "BIT_AND")
        j       tand_finish
        li      $t1, BIT_AND
tand_finish:
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

tor:
        li      $t1, '|'
        bne     $t0, $t1, less
        nop
        lb      $t0, ($s0) # Check next byte
        bne     $t0, $t1, tor_bit_or
        nop
# equality:
        PRINTLN_STR(str_lexer_or, "OR")
        addi    $s0, $s0, 1
        j       tor_finish
        li      $t1, TOR
tor_bit_or:
        PRINTLN_STR(str_lexer_bit_or, "BIT_OR")
        j       tor_finish
        li      $t1, BIT_OR
tor_finish:
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

less:
        li      $t1, '<'
        bne     $t0, $t1, greater
        nop
        li      $t1, '='
        lb      $t0, ($s0) # Check next byte
        bne     $t0, $t1, tl_true_less
        nop
# less equal:
        PRINTLN_STR(str_lexer_less_equal, "LESS_EQUAL")
        addi    $s0, $s0, 1
        j       tl_finish
        li      $t1, LESS_EQUAL
tl_true_less:
        PRINTLN_STR(str_lexer_less, "LESS_THAN")
        j       tl_finish
        li      $t1, LESS_THAN
tl_finish:
        sb      $t1, ($s1)
        j       tokenize_start
        addi    $s1, $s1, 1

greater:
        li      $t1, '>'
        bne     $t0, $t1, literal_hex
        nop
        li      $t1, '='
        lb      $t0, ($s0) # Check next byte
        bne     $t0, $t1, tg_true_great
        nop
# greater equal:
        PRINTLN_STR(str_lexer_greater_equal, "GREATER_EQUAL")
        addi    $s0, $s0, 1
        j       tg_finish
        li      $t1, GREATER_EQUAL
tg_true_great:
        PRINTLN_STR(str_lexer_greater, "GREATER_THAN")
        j       tg_finish
        li      $t1, GREATER_THAN
tg_finish:
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
        li      $t1, '`'
        sltu    $t4, $t1, $t0
        li      $t1, 'g'
        sltu    $t5, $t0, $t1
        and     $t1, $t2, $t3
        and     $t4, $t4, $t5
        or      $t1, $t1, $t4
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

.macro BUF_TAG(%i_inc)
        srl     $t1, $s2, 24
        andi    $t1, $t1, 0xff
        addi    $t1, $t1, 65
        sb      $t1, 0($s1)

        srl     $t1, $s2, 16
        andi    $t1, $t1, 0xff
        addi    $t1, $t1, 65
        sb      $t1, 1($s1)

        srl     $t1, $s2, 8
        andi    $t1, $t1, 0xff
        addi    $t1, $t1, 65
        sb      $t1, 2($s1)

        andi    $t1, $s2, 0xff
        addi    $t1, $t1, 65
        sb      $t1, 3($s1)

        addi    $s1, $s1, 4

        addi    $s2, $s2, %i_inc
.end_macro

.eqv    LOUTBUF 500
        SBRK(LOUTBUF)
        PSR($v0) # output_buffer_base

        lw      $s0, 4($sp)  # $s0: token_list_index
        lw      $s1, 0($sp)  # $s1: output_buffer_index
        li      $s2, 0       # $s2: tag_cnt (auto, don't occupy!)

        BUF_APPEND(str_include_lib, 26) # Add include statement.
        BUF_APPEND(str_sysent, 7) # Add system entry.
        j       parse_program
        nop

write_buf: # $a0: addr_str, $a1: strlen
        .data
        str_comma: .asciiz ":"
        str_endl:  .asciiz "\n"
        str_space: .asciiz " "
        str_nop:   .asciiz "\tnop\n" # 5
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

parse_func_def:
        .data
        str_textseg: .asciiz ".text\n" # 6
        str_globl: .asciiz ".globl " # 7
        str_psra:  .asciiz "\tPSR($ra)\n" # 10
        str_ppra:  .asciiz "\tlw\t$ra, ($sp)\n\tPPR\n" # 20
        .text

        PSR($ra)

        # Print function head infos:
        # """
        # .text
        # .globl func_name
        # func_name:
        #       PSR($ra)
        # """
        BUF_APPEND(str_textseg, 6)
        BUF_APPEND(str_globl, 7)
        addi    $s0, $s0, 2
        lb      $s3, ($s0) # $s3: ident_length
        addi    $s0, $s0, 1
        move    $s4, $s0   # $s4 addr_ident

        # Print ident.
        move    $a0, $s4
        move    $a1, $s3
        jal     write_buf
        nop
        BUF_APPEND(str_endl, 1)
        # Print ident.
        move    $a0, $s4
        move    $a1, $s3
        jal     write_buf
        nop
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_endl, 1)
        BUF_APPEND(str_psra, 10)

        addu    $s0, $s0, $s3 # $s0 on "open_par"
        addi    $s0, $s0, 3

pfd_loop:
        lb      $t0, ($s0)
        li      $t1, CLOSE_BRAC
        beq     $t0, $t1, pfd_finish
        nop

        jal     parse_statement
        nop
        j       pfd_loop
        nop

pfd_finish:
        addi    $s0, $s0, 1 # Jump the "close_brac"
        BUF_APPEND(str_endl, 1)

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
        jal     parse_exp
        addi    $s0, $s0, 1 # jump keyword_return (before )parse_exp
        addi    $s0, $s0, 1 # jump semicolon
        BUF_APPEND(str_ppra, 20)
        BUF_APPEND(str_jr, 13)

        lw      $ra, ($sp)
        PPR
        jr      $ra
        nop

        .data
        str_pre_li_v0: .asciiz "\tli\t$v0, " # 9
        str_pre_li_v1: .asciiz "\tli\t$v1, " # 9
        str_psr_v0: .asciiz "\tPSR($v0)\n" # 10
        str_lw_v0_sp: .asciiz "\tlw\t$v0, ($sp)\n" # 15
        .text
parse_exp:
        .data
        str_pre_bnez_v0: .asciiz "\tbnez\t$v0, " # 11
        .text
        PSR($ra)
        jal     parse_and_exp   # Parse first and exp;
        nop

        li      $t1, TOR        # Check for "||" token;
        lb      $t0, ($s0)
        bne     $t0, $t1, pe_finish
        nop
# Contains token "||":
        PSR($s2) # tags: f1, f
        addi    $s2, $s2, 2

        BUF_APPEND(str_pre_bnez_v0, 11) # bnez $v0, f1
        move    $s3, $s2
        lw      $s2, ($sp)
        BUF_TAG(0)
        move    $s2, $s3
        BUF_APPEND(str_endl, 1)
        BUF_APPEND(str_nop, 5) # nop
pe_loop:
        jal     parse_and_exp   # Parse next and exp;
        addi    $s0, $s0, 1
        BUF_APPEND(str_pre_bnez_v0, 11) # bnez $v0, f1
        move    $s3, $s2
        lw      $s2, ($sp)
        BUF_TAG(0)
        move    $s2, $s3
        BUF_APPEND(str_endl, 1)
        BUF_APPEND(str_nop, 5) # nop
        li      $t1, TOR        # Check for "||" token;
        lb      $t0, ($s0)
        bne     $t0, $t1, pe_gen
        nop
        j       pe_loop         # Loop back.
        nop
pe_gen:
        .data
        str_pre_jump: .asciiz "\tj\t" # 3
        .text
        # j f
        BUF_APPEND(str_pre_jump, 3)
        move    $s3, $s2
        lw      $s2, ($sp)
        addi    $s2, $s2, 1
        BUF_TAG(0)
        BUF_APPEND(str_endl, 1)
        # li $v0, 0
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_0, 1)
        BUF_APPEND(str_endl, 1)
        # f1: li $v0, 1
        addi    $s2, $s2, -1
        BUF_TAG(0)
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_1, 1)
        BUF_APPEND(str_endl, 1)
        # f:
        addi    $s2, $s2, 1
        BUF_TAG(0)
        move    $s2, $s3
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_endl, 1)

        # PPR $s2 after use.
        PPR
pe_finish:
        lw      $ra, ($sp)
        PPR
        jr      $ra
        nop

parse_and_exp:
        PSR($ra)
        jal     parse_eql_exp   # Parse first eql exp;
        nop

        li      $t1, TAND       # Check for "&& token;
        lb      $t0, ($s0)
        bne     $t0, $t1, pa_finish
        nop
# Contains token "&&"
        PSR($s2) # tags: f0, f
        addi    $s2, $s2, 2

        BUF_APPEND(str_pre_beqz_v0, 11) # beqz $v0, f0
        move    $s3, $s2
        lw      $s2, ($sp)
        BUF_TAG(0)
        move    $s2, $s3
        BUF_APPEND(str_endl, 1)
        BUF_APPEND(str_nop, 5) # nop
pa_loop:
        jal     parse_eql_exp   # Parse next eql exp;
        addi    $s0, $s0, 1
        BUF_APPEND(str_pre_beqz_v0, 11) # beqz $v0, f0
        move    $s3, $s2
        lw      $s2, ($sp)
        BUF_TAG(0)
        move    $s2, $s3
        BUF_APPEND(str_endl, 1)
        BUF_APPEND(str_nop, 5) # nop
        li      $t1, TAND       # Check for "&& token;
        lb      $t0, ($s0)
        bne     $t0, $t1, pa_gen
        nop
        j       pa_loop         # Loop back.
        nop
pa_gen:
        # j f
        BUF_APPEND(str_pre_jump, 3)
        move    $s3, $s2
        lw      $s2, ($sp)
        addi    $s2, $s2, 1
        BUF_TAG(0)
        BUF_APPEND(str_endl, 1)
        # li $v0, 1
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_1, 1)
        BUF_APPEND(str_endl, 1)
        # f1: li $v0, 0
        addi    $s2, $s2, -1
        BUF_TAG(0)
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_0, 1)
        BUF_APPEND(str_endl, 1)
        # f:
        addi    $s2, $s2, 1
        BUF_TAG(0)
        move    $s2, $s3
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_endl, 1)
        # Reset $s2 after use.
        PPR
pa_finish:
        lw      $ra, ($sp)
        PPR
        jr      $ra
        nop

parse_eql_exp:
        .data
        str_bne_v0_v1: .asciiz "\tbne\t$v0, $v1, " # 15
        str_beq_v0_v1: .asciiz "\tbeq\t$v0, $v1, " # 15
        .text
        PSR($ra)

        jal     parse_rel_exp
        nop

        lb      $t0, ($s0)
        li      $t1, EQUAL
        beq     $t0, $t1, peql_eql
        li      $t1, NOT_EQUAL
        beq     $t0, $t1, peql_neq
        nop
        j       peql_finish
        nop

peql_eql:
        BUF_APPEND(str_psr_v0, 10)
        jal     parse_rel_exp
        addi    $s0, $s0, 1
        BUF_APPEND(str_lw_v1_sp, 15)
        BUF_APPEND(str_ppr, 5)
        # bne $v0, $v1
        BUF_APPEND(str_bne_v0_v1, 14)
        BUF_TAG(0)
        BUF_APPEND(str_endl, 1)
        # li $v0, 0
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_0, 1)
        BUF_APPEND(str_endl, 1)
        # li $v0, 1
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_1, 1)
        BUF_APPEND(str_endl, 1)
        # f:
        BUF_TAG(1)
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_endl, 1)
        j       peql_finish
        nop

peql_neq:
        BUF_APPEND(str_psr_v0, 10)
        jal     parse_rel_exp
        addi    $s0, $s0, 1
        BUF_APPEND(str_lw_v1_sp, 15)
        BUF_APPEND(str_ppr, 5)
        # beq $v0, $v1
        BUF_APPEND(str_beq_v0_v1, 14)
        BUF_TAG(0)
        BUF_APPEND(str_endl, 1)
        # li $v0, 0
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_0, 1)
        BUF_APPEND(str_endl, 1)
        # li $v0, 1
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_1, 1)
        BUF_APPEND(str_endl, 1)
        # f:
        BUF_TAG(1)
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_endl, 1)
        j       peql_finish
        nop

peql_finish:
        lw      $ra, ($sp)
        PPR
        jr      $ra
        nop

parse_rel_exp:
        .data
        str_blt_v1_v0: .asciiz "\tblt\t$v1, $v0, " # 15
        str_ble_v1_v0: .asciiz "\tble\t$v1, $v0, " # 15
        str_bgt_v1_v0: .asciiz "\tbgt\t$v1, $v0, " # 15
        str_bge_v1_v0: .asciiz "\tbge\t$v1, $v0, " # 15
        .text
        PSR($ra)

        jal     parse_additive_exp
        nop

        lb      $t0, ($s0)
        li      $t1, LESS_THAN
        beq     $t0, $t1, prel_l
        li      $t1, LESS_EQUAL
        beq     $t0, $t1, prel_le
        li      $t1, GREATER_THAN
        beq     $t0, $t1, prel_g
        li      $t1, GREATER_EQUAL
        beq     $t0, $t1, prel_ge
        nop
        j       prel_finish
        nop

prel_l:
        BUF_APPEND(str_psr_v0, 10)
        jal     parse_additive_exp
        addi    $s0, $s0, 1
        BUF_APPEND(str_lw_v1_sp, 15)
        BUF_APPEND(str_ppr, 5)
        # bge $v1, $v0
        BUF_APPEND(str_bge_v1_v0, 14)
        BUF_TAG(0)
        BUF_APPEND(str_endl, 1)
        # li $v0, 0
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_0, 1)
        BUF_APPEND(str_endl, 1)
        # li $v0, 1
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_1, 1)
        BUF_APPEND(str_endl, 1)
        # f:
        BUF_TAG(1)
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_endl, 1)
        j       prel_finish
        nop

prel_le:
        BUF_APPEND(str_psr_v0, 10)
        jal     parse_additive_exp
        addi    $s0, $s0, 1
        BUF_APPEND(str_lw_v1_sp, 15)
        BUF_APPEND(str_ppr, 5)
        # bgt $v1, $v0
        BUF_APPEND(str_bgt_v1_v0, 14)
        BUF_TAG(0)
        BUF_APPEND(str_endl, 1)
        # li $v0, 0
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_0, 1)
        BUF_APPEND(str_endl, 1)
        # li $v0, 1
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_1, 1)
        BUF_APPEND(str_endl, 1)
        # f:
        BUF_TAG(1)
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_endl, 1)
        j       prel_finish
        nop

prel_g:
        BUF_APPEND(str_psr_v0, 10)
        jal     parse_additive_exp
        addi    $s0, $s0, 1
        BUF_APPEND(str_lw_v1_sp, 15)
        BUF_APPEND(str_ppr, 5)
        # ble $v1, $v0
        BUF_APPEND(str_ble_v1_v0, 14)
        BUF_TAG(0)
        BUF_APPEND(str_endl, 1)
        # li $v0, 0
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_0, 1)
        BUF_APPEND(str_endl, 1)
        # li $v0, 1
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_1, 1)
        BUF_APPEND(str_endl, 1)
        # f:
        BUF_TAG(1)
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_endl, 1)
        j       prel_finish
        nop

prel_ge:
        BUF_APPEND(str_psr_v0, 10)
        jal     parse_additive_exp
        addi    $s0, $s0, 1
        BUF_APPEND(str_lw_v1_sp, 15)
        BUF_APPEND(str_ppr, 5)
        # blt $v1, $v0
        BUF_APPEND(str_blt_v1_v0, 14)
        BUF_TAG(0)
        BUF_APPEND(str_endl, 1)
        # li $v0, 0
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_0, 1)
        BUF_APPEND(str_endl, 1)
        # li $v0, 1
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_char_1, 1)
        BUF_APPEND(str_endl, 1)
        # f:
        BUF_TAG(1)
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_endl, 1)
        j       prel_finish
        nop

prel_finish:
        lw      $ra, ($sp)
        PPR
        jr      $ra
        nop

parse_additive_exp: # always get expr's value into $v0
        PSR($ra)

        jal     parse_term
        nop
pae_loop_term:
        lb      $t0, ($s0)
        li      $t1, PLUS
        beq     $t0, $t1, pae_plus_term
        li      $t2, MINUS
        beq     $t0, $t2, pae_minus_term
        nop
        j       pae_loop_term_finish
        nop
pae_plus_term:
        # PSR($v0)
        BUF_APPEND(str_psr_v0, 10)
        jal     parse_term
        addi    $s0, $s0, 1
        .data
        str_lw_v1_sp: .asciiz "\tlw\t$v1, ($sp)\n" # 15
        str_addu_v0_v1: .asciiz "\taddu\t$v0, $v1, $v0\n" # 20
        str_subu_v1_v0: .asciiz "\tsubu\t$v0, $v1, $v0\n" # 20
        str_ppr: .asciiz "\tPPR\n" # 5
        .text
        # lw $v1, ($sp)
        BUF_APPEND(str_lw_v1_sp, 15)
        # PPR
        BUF_APPEND(str_ppr, 5)
        # addu $v0, $v1, $v0
        BUF_APPEND(str_addu_v0_v1, 20)
        j       pae_loop_term 
        nop
pae_minus_term:
        # PSR($v0)
        BUF_APPEND(str_psr_v0, 10)
        jal     parse_term
        addi    $s0, $s0, 1
        # lw $v1, ($sp)
        BUF_APPEND(str_lw_v1_sp, 15)
        # PPR
        BUF_APPEND(str_ppr, 5)
        # subu $v0, $v1, $v0
        BUF_APPEND(str_subu_v1_v0, 20)
        j       pae_loop_term 
        nop
pae_loop_term_finish:
        lw      $ra, ($sp)
        PPR
        jr      $ra
        nop

parse_term:
        PSR($ra)

        jal     parse_fact
        nop
pt_loop_fact:
        lb      $t0, ($s0)
        li      $t1, TMULT
        beq     $t0, $t1, pt_mult_fact
        li      $t2, TDIV
        beq     $t0, $t2, pt_div_fact
        nop
        j       pt_loop_fact_finish
        nop
pt_mult_fact:
        .data
        str_mul_v0_v1: .asciiz "\tmul\t$v0, $v1, $v0\n" # 19
        .text
        # PSR($v0)
        BUF_APPEND(str_psr_v0, 10)
        jal     parse_fact
        addi    $s0, $s0, 1
        # lw $v1, ($sp)
        BUF_APPEND(str_lw_v1_sp, 15)
        # PPR
        BUF_APPEND(str_ppr, 5)
        # mul $v0, $v1, $v0
        BUF_APPEND(str_mul_v0_v1, 19)
        j       pt_loop_fact
        nop
pt_div_fact:
        .data
        str_div_v1_v0: .asciiz "\tdiv\t$v0, $v1, $v0\n" # 19
        .text
        # PSR($v0)
        BUF_APPEND(str_psr_v0, 10)
        jal     parse_fact
        addi    $s0, $s0, 1
        # lw $v1, ($sp)
        BUF_APPEND(str_lw_v1_sp, 15)
        # PPR
        BUF_APPEND(str_ppr, 5)
        # div $v0, $v1, $v0
        BUF_APPEND(str_div_v1_v0, 19)
        j       pt_loop_fact
        nop
pt_loop_fact_finish:
        lw      $ra, ($sp)
        PPR
        jr      $ra
        nop

parse_fact:
        PSR($ra)
        lb      $t0, ($s0)
        li      $t1, OPEN_PAR
        beq     $t0, $t1, pf_more_expr
        li      $t1, LITERAL_INT
        beq     $t0, $t1, pf_literal_int
        li      $t1, LITERAL_HEX
        beq     $t0, $t1, pf_literal_hex
        li      $t1, BIT_COMPL
        beq     $t0, $t1, pf_bit_compl
        li      $t1, MINUS
        beq     $t0, $t1, pf_minus
        li      $t1, NEGATION
        beq     $t0, $t1, pf_negation
        nop

pf_more_expr:
        jal     parse_exp
        addi    $s0, $s0, 1

        addi    $s0, $s0, 1
        j       pf_finish
        nop

pf_literal_int:
        BUF_APPEND(str_pre_li_v0, 9)
        addi    $s0, $s0, 1
        lb      $a1, ($s0)
        addi    $s0, $s0, 1
        move    $a0, $s0
        jal     write_buf
        addu    $s0, $s0, $a1
        BUF_APPEND(str_endl, 1)
        j       pf_finish
        nop

pf_literal_hex:
        .data
        str_hex_pre: .asciiz "0x"
        .text
        BUF_APPEND(str_pre_li_v0, 9)
        BUF_APPEND(str_hex_pre, 2)
        addi    $s0, $s0, 1
        lb      $a1, ($s0)
        addi    $s0, $s0, 1
        move    $a0, $s0
        jal     write_buf
        addu    $s0, $s0, $a1
        BUF_APPEND(str_endl, 1)
        j       pf_finish
        nop

pf_bit_compl:
        .data
        str_xori_f: .asciiz "\txori\t$v0, $v0, 0xffffffff\n" # 27
        .text
        jal      parse_fact      # Get sub-expr's value in $v0
        addi    $s0, $s0, 1
        BUF_APPEND(str_xori_f, 27)
        j       pf_finish
        nop

pf_minus:
        .data
        str_subu_v0: .asciiz "\tsubu\t$v0, $0, $v0\n" # 19
        .text
        jal      parse_fact # Get sub-expr's value in $v0
        addi    $s0, $s0, 1
        BUF_APPEND(str_subu_v0, 19)
        j       pf_finish
        nop

pf_negation:
        .data
        str_pre_beqz_v0: .asciiz "\tbeqz\t$v0, "  # 11
        str_char_0:  .asciiz "0"
        str_char_1:  .asciiz "1"
        str_move_v0_v1: .asciiz "\tmove\t$v0, $v1\n" # 15
        .text
        jal      parse_fact # Get sub-expr's value in $v0
        addi    $s0, $s0, 1
        # li   $v1, 1
        BUF_APPEND(str_pre_li_v1, 9)
        BUF_APPEND(str_char_1, 1)
        BUF_APPEND(str_endl, 1)
        # beqz $v0, eqz
        BUF_APPEND(str_pre_beqz_v0, 11)
        BUF_TAG(0)
        BUF_APPEND(str_endl, 1)
        # nop
        BUF_APPEND(str_nop, 5)
        # li   $v1, 0
        BUF_APPEND(str_pre_li_v1, 9)
        BUF_APPEND(str_char_0, 1)
        BUF_APPEND(str_endl, 1)
        # eqz:
        BUF_TAG(1)
        BUF_APPEND(str_comma, 1)
        BUF_APPEND(str_endl, 1)
        # move $v0, $v1
        BUF_APPEND(str_move_v0_v1, 15)

        j       pf_finish
        nop

pf_finish:
        lw      $ra, ($sp)
        PPR
        jr      $ra
        nop

parse_program:
        lb      $t0, ($s0) # Get next token id.

        li      $t1, TOKEN_END # Quit on finishing the tokens.
        beq     $t0, $t1, parse_finish
        nop

        jal     parse_func_def
        nop

        j       parse_program # Forever loop.
        nop

parse_finish:
        PRINTLN_STR(str_parser_finish, "Parsing finished.")

        OPEN(fname_dst, 1, 0) # Write output file.
        lw      $t0, ($sp) # output_buf_base
        subu    $t1, $s1, $t0 # output_buf_len
        WRITE($v0, $t0, $t1)

