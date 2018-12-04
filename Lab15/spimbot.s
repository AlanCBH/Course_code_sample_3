# 1. Right wall traversal (DFS)
# 2. Solve puzzles and get points
# 3. Break walls

.data
# syscall constants
PRINT_STRING            = 4
PRINT_CHAR              = 11
PRINT_INT               = 1

# memory-mapped I/O
VELOCITY                = 0xffff0010
ANGLE                   = 0xffff0014
ANGLE_CONTROL           = 0xffff0018

BOT_X                   = 0xffff0020
BOT_Y                   = 0xffff0024

TIMER                   = 0xffff001c

RIGHT_WALL_SENSOR 		= 0xffff0054
PICK_TREASURE           = 0xffff00e0
TREASURE_MAP            = 0xffff0058
MAZE_MAP                = 0xffff0050

REQUEST_PUZZLE          = 0xffff00d0
SUBMIT_SOLUTION         = 0xffff00d4

BONK_INT_MASK           = 0x1000
BONK_ACK                = 0xffff0060

TIMER_INT_MASK          = 0x8000
TIMER_ACK               = 0xffff006c

REQUEST_PUZZLE_INT_MASK = 0x800
REQUEST_PUZZLE_ACK      = 0xffff00d8


GET_KEYS                = 0xffff00e4

# struct spim_treasure
#{
#    short x;
#    short y;
#    int points;
#};
#
#struct spim_treasure_map
#{
#    unsigned length;
#    struct spim_treasure treasures[50];
#};
.data
#######################################
PUZZLE_ADDR:    .space 512
MAP_ADDR:       .word 500
                             ######### this block is added by Alan Cheng
FLAGP:          .word 1
FLAGR:          .word 1
SOL:            .word 0
PREV:           .word 0
######################################
#Insert whatever static memory you need here

.text
main:
	# Insert code here

        li      $t4, 0x8000                     # timer interrupt enable bit
        or      $t4, $t4, 0x1000                # bonk interrupt bit
        or      $t4,$t4,0x800                   #PUZZLE_enable bit
        or      $t4, $t4, 1                     # global interrupt enable
        mtc0    $t4, $12                        # set interrupt mask (Status register)

        #la      $s0,MAP_ADDR                    #this is PUZZLE_ADDR              ##Created by Alan Cheng
        #sw      $s0,TREASURE_MAP($zero)         #put TREASURE_MAP in it           ##I permeantly assign s0 to hold the address of Map
                                                                                  ##since it will checked frequently
        j       loop

        jr      $ra                         #ret


# next_state:
#         li      $t2,1
#         la      $t0,FLAGP
#         sw      $t2,0($t0)
loop:
        # is there a right wall?
        #la      $t0,PREV
        #sw      $t7,0($t0)
        li      $t0,1
        la      $t5,FLAGP
        sw      $t0,0($t5)
        puzzle:
                 #li      $t7,0
                 la      $t0,PUZZLE_ADDR              #this is PUZZLE_ADDR
                 sw      $t0,REQUEST_PUZZLE($zero)    #put puzzle_ADDR into
        waiting:
                 la      $t5,FLAGP
                 lw      $t5,0($t5)
                 bne     $t5,$zero,waiting
        solve:
                 la      $a0,PUZZLE_ADDR
                 jal     rule1
                 la      $t5,SOL
                 sw      $v0,0($t5)
                 sw      $t5,SUBMIT_SOLUTION($zero)
                 #sw      $v0,SUBMIT_SOLUTION($zero)              #
                 j      loop


                 # looking_for_treasure:
                 #         li      $t0, 0                          # stop the bot
                 #         sw      $t0, VELOCITY($zero)
                 #
                 #         bge     $t2, $t1, searching_end         # i < num_Treasure
                 #         mul     $t3, $t2, 8                     # size of treasure*t2                 ### I believe there are ways to optimizie the code
                 #         add     $t3, $s0, $t3                   # get the current location            ### without looping through the entire map
                 #         lw      $t4, 4($t3)                     # get the treasure's row
                 #
                 #         lw      $t5, BOT_Y($zero)               # get the bot's Y position
                 #         div     $t5, $t5, 10                    # transform that into comparable Y
                 #
                 #         beq     $t5, $t4, X_cor
                 #         addi    $t2, $t2, 1
                 #         j       looking_for_treasure
                 # X_cor:
                 #         lw      $t4, 6($t3)                     # get the treasure's col
                 #
                 #         lw      $t5, BOT_X($zero)               # get the bot's X position
                 #         div     $t5, $t5, 10                    # transform that into comparable X
                 #
                 #         beq     $t5, $t4, find_it               # treasure or not
                 #         addi    $t2, $t2, 1
                 #         j       looking_for_treasure
                 #





# TAKEN FROM LAB 8 SOLUTIONS
board_address:
	mul	$v0, $a1, 16		# i*16
	add	$v0, $v0, $a2		# (i*16)+j
	sll	$v0, $v0, 1		# ((i*9)+j)*2
	add	$v0, $a0, $v0
	jr	$ra
        .globl get_square_begin
        get_square_begin:
        	div	$v0, $a0, 4
        	mul	$v0, $v0, 4
        	jr	$ra


        .globl has_single_bit_set
        has_single_bit_set:
        	beq	$a0, 0, hsbs_ret_zero	# return 0 if value == 0
        	sub	$a1, $a0, 1
        	and	$a1, $a0, $a1
        	bne	$a1, 0, hsbs_ret_zero	# return 0 if (value & (value - 1)) == 0
        	li	$v0, 1
        	jr	$ra
        hsbs_ret_zero:
        	li	$v0, 0
        	jr	$ra


        get_lowest_set_bit:
        	li	$v0, 0			# i
        	li	$t1, 1

        glsb_loop:
        	sll	$t2, $t1, $v0		# (1 << i)
        	and	$t2, $t2, $a0		# (value & (1 << i))
        	bne	$t2, $0, glsb_done
        	add	$v0, $v0, 1
        	blt	$v0, 16, glsb_loop	# repeat if (i < 16)

        	li	$v0, 0			# return 0
        glsb_done:
        	jr	$ra

.globl rule1
rule1:
	sub	$sp, $sp, 32
	sw	$ra, 0($sp)		# save $ra and free up 7 $s registers for
	sw	$s0, 4($sp)		# i
	sw	$s1, 8($sp)		# j
	sw	$s2, 12($sp)		# board
	sw	$s3, 16($sp)		# value
	sw	$s4, 20($sp)		# k
	sw	$s5, 24($sp)		# changed
	sw	$s6, 28($sp)		# temp
	move	$s2, $a0		# store the board base address
	li	$s5, 0			# changed = false

	li	$s0, 0			# i = 0
r1_loop1:
	li	$s1, 0			# j = 0
r1_loop2:
	move	$a0, $s2		# board
	move 	$a1, $s0		# i
	move	$a2, $s1		# j
	jal	board_address
	lhu	$s3, 0($v0)		# value = board[i][j]
	move	$a0, $s3
	jal	has_single_bit_set
	beq	$v0, 0, r1_loop2_bot	# if not a singleton, we can go onto the next iteration

	li	$s4, 0			# k = 0
r1_loop3:
	beq	$s4, $s1, r1_skip_row	# skip if (k == j)
	move	$a0, $s2		# board
	move 	$a1, $s0		# i
	move	$a2, $s4		# k
	jal	board_address
	lhu	$t0, 0($v0)		# board[i][k]
	and	$t1, $t0, $s3
	beq	$t1, 0, r1_skip_row
	not	$t1, $s3
	and	$t1, $t0, $t1
	sh	$t1, 0($v0)		# board[i][k] = board[i][k] & ~value
	li	$s5, 1			# changed = true

r1_skip_row:
	beq	$s4, $s0, r1_skip_col	# skip if (k == i)
	move	$a0, $s2		# board
	move 	$a1, $s4		# k
	move	$a2, $s1		# j
	jal	board_address
	lhu	$t0, 0($v0)		# board[k][j]
	and	$t1, $t0, $s3
	beq	$t1, 0, r1_skip_col
	not	$t1, $s3
	and	$t1, $t0, $t1
	sh	$t1, 0($v0)		# board[k][j] = board[k][j] & ~value
	li	$s5, 1			# changed = true

r1_skip_col:
	add	$s4, $s4, 1		# k ++
	blt	$s4, 16, r1_loop3

	## doubly nested loop
	move	$a0, $s0		# i
	jal	get_square_begin
	move	$s6, $v0		# ii
	move	$a0, $s1		# j
	jal	get_square_begin	# jj

	move 	$t0, $s6		# k = ii
	add	$t1, $t0, 4		# ii + GRIDSIZE
	add 	$s6, $v0, 4		# jj + GRIDSIZE

r1_loop4_outer:
	sub	$t2, $s6, 4		# l = jj  (= jj + GRIDSIZE - GRIDSIZE)

r1_loop4_inner:
	bne	$t0, $s0, r1_loop4_1
	beq	$t2, $s1, r1_loop4_bot

r1_loop4_1:
	mul	$v0, $t0, 16		# k*16
	add	$v0, $v0, $t2		# (k*16)+l
	sll	$v0, $v0, 1		# ((k*16)+l)*2
	add	$v0, $s2, $v0		# &board[k][l]
	lhu	$v1, 0($v0)		# board[k][l]
   	and	$t3, $v1, $s3		# board[k][l] & value
	beq	$t3, 0, r1_loop4_bot

	not	$t3, $s3
	and	$v1, $v1, $t3
	sh	$v1, 0($v0)		# board[k][l] = board[k][l] & ~value
	li	$s5, 1			# changed = true

r1_loop4_bot:
	add	$t2, $t2, 1		# l++
	blt	$t2, $s6, r1_loop4_inner

	add	$t0, $t0, 1		# k++
	blt	$t0, $t1, r1_loop4_outer


r1_loop2_bot:
	add	$s1, $s1, 1		# j ++
	blt	$s1, 16, r1_loop2

	add	$s0, $s0, 1		# i ++
	blt	$s0, 16, r1_loop1

	move	$v0, $s5		# return changed
	lw	$ra, 0($sp)		# restore registers and return
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	lw	$s4, 20($sp)
	lw	$s5, 24($sp)
	lw	$s6, 28($sp)
	add	$sp, $sp, 32
	jr	$ra
.globl dfs_funct
dfs_funct:
        sub	$sp, $sp, 16		# STACK STORE
        sw 	$ra, 0($sp)		# Store ra
        sw	$s0, 4($sp)		# s0 = tree
        sw	$s1, 8($sp)		# s1 = i
        sw	$s2, 12($sp)	        # s2 = input
        move 	$s0, $a0
        move 	$s1, $a1
        move	$s2, $a2
_dfs_base_case_one:
        blt     $s1, 127, _dfs_base_case_two
        li      $v0, -1
        j       _dfs_return
_dfs_base_case_two:
        mul	$t1, $s1, 4
        add	$t2, $s0, $t1
        lw      $t1, 0($t2)  		# tree[i]
        bne     $t1, $s2, _dfs_ret_one
        li      $v0, 0
        j      _dfs_return
_dfs_ret_one:
        mul	$a1, $s1, 2
        jal 	dfs_funct		##	int ret = DFS(tree, 2 * i, input);
        blt	$v0, 0, _dfs_ret_two	##	if (ret >= 0)
        addi	$v0, 1			##	return ret + 1
        j      _dfs_return
_dfs_ret_two:
        mul	$a1, $s1, 2
        addi	$a1, 1
        jal 	dfs_funct		##	int ret = DFS(tree, 2 * i + 1, input);
        blt	$v0, 0, _dfs_return	##	if (ret >= 0)
        addi	$v0, 1			##	return ret + 1
        j      _dfs_return
_dfs_return:
        lw 	$ra, 0($sp)
        lw	$s0, 4($sp)
        lw	$s1, 8($sp)
        lw	$s2, 12($sp)
        add	$sp, $sp, 16
        jal     $ra

# Kernel Text
.kdata
chunkIH:    .space 28
non_intrpt_str:    .asciiz "Non-interrupt exception\n"
unhandled_str:    .asciiz "Unhandled interrupt type\n"
.ktext 0x80000180
interrupt_handler:
.set noat
        move      $k1, $at        # Save $at
.set at
        la        $k0, chunkIH
        sw        $a0, 0($k0)        # Get some free registers
        sw        $v0, 4($k0)        # by storing them to a global variable
        sw        $t0, 8($k0)
        sw        $t1, 12($k0)
        sw        $t2, 16($k0)
        sw        $t3, 20($k0)

        mfc0      $k0, $13             # Get Cause register
        srl       $a0, $k0, 2
        and       $a0, $a0, 0xf        # ExcCode field
        bne       $a0, 0, non_intrpt



interrupt_dispatch:            # Interrupt:
        mfc0       $k0, $13        # Get Cause register, again
        beq        $k0, 0, done        # handled all outstanding interrupts

        and        $a0, $k0, BONK_INT_MASK    # is there a bonk interrupt?
        bne        $a0, 0, bonk_interrupt

        and        $a0, $k0, TIMER_INT_MASK    # is there a timer interrupt?
        bne        $a0, 0, timer_interrupt

        and 	$a0, $k0, REQUEST_PUZZLE_INT_MASK
        bne 	$a0, 0, request_puzzle_interrupt

        li        $v0, PRINT_STRING    # Unhandled interrupt types
        la        $a0, unhandled_str
        syscall
        j    done

bonk_interrupt:
        sw      $v0, BONK_ACK        # acknowledge interrupt

        li      $k0, 180
        sw      $k0, ANGLE($zero)
        sw      $zero, ANGLE_CONTROL($zero)         # relative angle

        j       interrupt_dispatch    # see if other interrupts are waiting

request_puzzle_interrupt:
        sub     $sp,$sp,4
        sw      $t7,0($sp)
        sw      $zero,REQUEST_PUZZLE_ACK($zero)   #acknowledge interrupt

        la      $t7,FLAGP                           #flag for solve
        sw      $zero,0($t7)
        lw      $t7,0($sp)

        addi    $sp,$sp,4
        j	interrupt_dispatch

timer_interrupt:
        sw       $v0, TIMER_ACK        # acknowledge interrupt
        j        interrupt_dispatch    # see if other interrupts are waiting

non_intrpt:                # was some non-interrupt
        li        $v0, PRINT_STRING
        la        $a0, non_intrpt_str
        syscall                # print out an error message
        # fall through to done

done:
        la      $k0, chunkIH
        lw      $a0, 0($k0)        # Restore saved registers
        lw      $v0, 4($k0)
	lw      $t0, 8($k0)
        lw      $t1, 12($k0)
        lw      $t2, 16($k0)
        lw      $t3, 20($k0)
.set noat
        move    $at, $k1        # Restore $at
.set at
        eret
