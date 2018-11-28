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
PUZZLE_ADDR:    .space 512
MAP_ADDR:       .word 101

FLAGP:          .word 1
FLAGR:          .word 1
#Insert whatever static memory you need here

######################
la      $t0,MAP_ADDR               #this is PUZZLE_ADDR
sw      $t0,TREASURE_MAP($zero)    #put puzzle_ADDR into
#this is for loading treasure-map address
#######################
la      $t0,MAP_ADDR               #get the address of TREASURE_MAP
lw      $t1,0($t0)                 #get the number of treasures
move    $t2,$zero                  #for loop
loop_start:
blt     $t2,$t1,loop_end
mul     $t3,$t2,8                  #size of treasure*t2
add     $t3,$t0,$t3                #get the current location
lw      $t4,4($t3)                 #get the treasure's row
lw      $t5,BOT_Y($zero)           #get the bot's Y position
div     $t5,$t5,10                 #transform that into comparable Y
beq     $t5,$t4,next_com
addi    $t2,$t2,1
j       loop_start
next_com:
lw      $t4,8($t3)                 #get the treasure's col
lw      $t5,BOT_X($zero)           #get the bot's X position
div     $t5,$t5,10                 #transform that into comparable X
beq     $t5,$t4,on_pos             #treasure or not
addi    $t2,$t2,1
j       loop_start
on_pos:
la      $t0,FLAGP
sw      $zero,0($t0)               #make flag to pick to 0
loop_end:
######################

.text

        .globl dfsf
        dfsf:
                sub	$sp, $sp, 16		# STACK STORE
        	sw 	$ra, 0($sp)		# Store ra
        	sw	$s0, 4($sp)		# s0 = tree
                sw	$s1, 8($sp)		# s1 = i
        	sw	$s2, 12($sp)	       # s2 = input
        	move 	$s0, $a0
        	move 	$s1, $a1
                move	$s2, $a2


                ##	if (i >= 127) {
                ##		return -1;
                ##	}

        _dfs_base_case_one:
                blt     $s1, 127, _dfs_base_case_two
                li      $v0, -1
                j _dfs_return


                ##	if (input == tree[i]) {
                ##		return 0;
                ##	}

        _dfs_base_case_two:
        	mul	$t1, $s1, 4
                add	$t2, $s0, $t1
                lw      $t1, 0($t2)  			# tree[i]

                bne     $t1, $s2, _dfs_ret_one
                li      $v0, 0
                j _dfs_return

                ##	int ret = DFS(tree, 2 * i, input);
                ##	if (ret >= 0) {
                ##		return ret + 1;
                ##	}
        _dfs_ret_one:
                mul	$a1, $s1, 2
                jal 	dfsf				##	int ret = DFS(tree, 2 * i, input);


                blt	$v0, 0, _dfs_ret_two	##	if (ret >= 0)

                addi	$v0, 1					##	return ret + 1
                j _dfs_return

                ##	ret = DFS(tree, 2 * i + 1, input);
                ##	if (ret >= 0) {
                ##		return ret + 1;
                ##	}
        _dfs_ret_two:
                mul	$a1, $s1, 2
                addi	$a1, 1
                jal 	dfsf				##	int ret = DFS(tree, 2 * i + 1, input);


                blt	$v0, 0, _dfs_return		##	if (ret >= 0)

                addi	$v0, 1					##	return ret + 1
                j _dfs_return

                ##	return ret;
        _dfs_return:
                lw 	$ra, 0($sp)
                lw	$s0, 4($sp)
                lw	$s1, 8($sp)
        	lw	$s2, 12($sp)
                add	$sp, $sp, 16
                jal     $ra





main:
        li      $t4, 0x8000                     # timer interrupt enable bit
        or      $t4, $t4, 0x1000                # bonk interrupt bit
        or      $t4, $t4, 1                     # global interrupt enable
        mtc0    $t4, $12                        # set interrupt mask (Status register)

        j       loop
	# Insert code here
        loop:
                # is there a right wall?
                move    $t6, $t7                        # store prev wall check

                lw      $t7, RIGHT_WALL_SENSOR($zero)
                bne     $t7, 0, forward                 # if there is right wall, continue forward
                beq     $t7, $t6, forward               # if current sensor is the same as old sensor, continue forward

                # turn
                li      $t5, 90                         # turn 90 degrees
                sw      $t5, ANGLE($zero)
                sw      $zero, ANGLE_CONTROL($zero)

                j       loop
        forward:
                li      $t6, 10                         # set velocity to 10
                sw      $t6, VELOCITY($zero)
                j       loop


                jr      $ra                         #ret


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
        j       interrupt_dispatch    # see if other interrupts are waiting

request_puzzle_interrupt:
	#sw	$v0, REQUEST_PUZZLE_ACK 	#acknowledge interrupt

        sub     $sp,$sp,4
        sw      $t7,0($sp)
        sw      $zero,REQUEST_PUZZLE_ACK($zero)   #acknowledge interrupt

        la      $t7,FLAGP                           #flag for solve
        sw      $zero,0($t7)
        lw      $t7,0($sp)

        addi    $sp,$sp,4
	j	interrupt_dispatch

	j	interrupt_dispatch	 # see if other interrupts are waiting

timer_interrupt:
        #sw       $v0, TIMER_ACK        # acknowledge interrupt

        sub     $sp,$sp,4
        sw      $t7,0($sp)
        sw      $zero,TIMER_ACK($zero)    #acknowledge interrupt
        la      $t7,FLAGR
        sw      $zero,0($t7)
        lw      $t7,0($sp)
        addi    $sp,$sp,4
    # pick:
    #     li      $t0,1
    #     sw      $t0,PICK_TREASURE($zero)     #pick up treasure
    #j        interrupt_dispatch    # see if other interrupts are waiting



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
