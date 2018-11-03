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
#



.data
#REQUEST_PUZZLE returns an int array of length 128
PUZZLE_ADDR:    .space 512
MAP_ADDR:       .word 101
#0 puzzle_solve 1=n 2=s 3=w 4=e 5=p
INST_ARR:       .word 0 0 0 0 0 0 0 0 5 3 2 4 5 2 4 1 5 4 1 3 5 4 1 1 1 1 4 4 4 4 4 5 1 4 2 5 4 2 3 5 2 3 1 5
FLAGP:          .word 1
FLAGR:          .word 1
SOL:            .word 0
INDEX:          .word 0
.align 4
dfs:      .word 128

#
#Put any other static memory you need here
#


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



.globl main
main:
	#Fill in your code here
        sub     $sp,$sp,8
        sw      $ra,0($sp)          #save return addr
        sw      $a1,4($sp)          #save t0
        sw      $zero,VELOCITY($zero)
        li      $t4,0x8000          #enable interrupts
        or      $t4,$t4,0x1000      #timer interrupt enable bit
        or      $t4,$t4,0x800       #PUZZLE_enable bit
        or      $t4,$t4,1           #PUZZLE_enable bit
        mtc0    $t4,$12             #set interrupt mask
##############################################################
        #li      $t8,0
next_state:
        la      $t0,INST_ARR
        la      $t8,INDEX
        lw      $t6,0($t8)
        add     $t0,$t0,$t6
        addi    $t6,$t6,4
        sw      $t6,0($t8)
        lw      $t1,0($t0)

        li      $t2,1
        la      $t0,FLAGP
        sw      $t2,0($t0)
        la      $t0,FLAGR
        sw      $t2,0($t0)

        lw      $v0,TIMER($zero)
        add     $v0,$v0,10000
        sw      $v0,TIMER($zero)


        beq     $t1,0,puzzle
        beq     $t1,1,move_n
        beq     $t1,2,move_s
        beq     $t1,3,move_w
        beq     $t1,4,move_e
        beq     $t1,5,pick



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
         li      $a1,1
         li      $a2,1
         jal     dfsf
         la      $t5,SOL
         sw      $v0,0($t5)
         sw      $t5,SUBMIT_SOLUTION($zero)
         #sw      $v0,SUBMIT_SOLUTION($zero)              #
         j       next_state

move_w:
    li      $t0,10
    sw      $t0,VELOCITY($zero)
    li      $t0,180                      #rotato 180 degrees
    sw      $t0,ANGLE($zero)        #rotate to left
    li      $t0,1
    sw      $t0,ANGLE_CONTROL($zero)
    #request a interrupt
    # lw      $v0,TIMER($zero)              #stop every 10000 cycles
    # add     $v0,$v0,10000
    # sw      $v0,TIMER($zero)

    la     $t6,FLAGR
    lw     $t6,0($t6)
    beq    $t6,1,move_w
    j      next_state
    #j        interrupt_dispatch    # see if other interrupts are waiting


move_n:
        li      $t0,10
        sw      $t0,VELOCITY($zero)
        li      $t0,270                      #rotato 180 degrees
        sw      $t0,ANGLE($zero)        #rotate to left
        li      $t0,1
        sw      $t0,ANGLE_CONTROL($zero)

        # lw      $v0,TIMER($zero)              #stop every 10000 cycles
        # add     $v0,$v0,10000
        # sw      $v0,TIMER($zero)

        la     $t6,FLAGR
        lw     $t6,0($t6)
        beq    $t6,1,move_n
        j      next_state
        #j        interrupt_dispatch    # see if other interrupts are waiting

move_e:
        li      $t0,10
        sw      $t0,VELOCITY($zero)
        li      $t0,0                      #rotato 180 degrees
        sw      $t0,ANGLE($zero)        #rotate to left
        li      $t0,1
        sw      $t0,ANGLE_CONTROL($zero)

        # lw      $v0,TIMER($zero)              #stop every 10000 cycles
        # add     $v0,$v0,10000
        # sw      $v0,TIMER($zero)

        la     $t6,FLAGR
        lw     $t6,0($t6)
        beq    $t6,1,move_e
        j      next_state
        #j        interrupt_dispatch    # see if other interrupts are waiting
move_s:
        li      $t0,10
        sw      $t0,VELOCITY($zero)
        li      $t0,90                      #rotato 180 degrees
        sw      $t0,ANGLE($zero)        #rotate to left
        li      $t0,1
        sw      $t0,ANGLE_CONTROL($zero)

        # lw      $v0,TIMER($zero)              #stop every 10000 cycles
        # add     $v0,$v0,10000
        # sw      $v0,TIMER($zero)

        la     $t6,FLAGR
        lw     $t6,0($t6)
        bne    $t6,$zero,move_s
        j      next_state

pick:
        li      $t0,0
        sw      $t0,VELOCITY($zero)

        li      $t0,1
        sw      $t0,PICK_TREASURE($zero)

        # lw      $v0,TIMER($zero)              #stop every 10000 cycles
        # add     $v0,$v0,10000
        # sw      $v0,TIMER($zero)

        la     $t6,FLAGR
        lw     $t6,0($t6)
        bne    $t6,$zero,pick
        j      next_state
################################################


        lw      $ra,0($sp)                  #get the correct return addr
        addi    $sp,$sp,4                   #return the addr allocated
        jr  $ra







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
        bne $a0, 0, non_intrpt


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
    #Fill in your code here
################################
    sw      $zero, BONK_ACK($zero)      #acknowledge interrupt
    sub     $sp,$sp,8                   #stack space
    sw      $t0,0($sp)                  #save t0
    sw      $v0,4($sp)



    li      $t0,180                     #rotato 180 degrees
    sw      $t0,ANGLE($zero)            #rotate 180 degrees
    sw      $zero,ANGLE_CONTROL($zero)    #rotate relative ANGLE
    sw      $zero,VELOCITY($zero)        #set speed to zero


    lw      $t0,0($sp)                  #load t0 back\
    lw      $v0,4($sp)

    addi    $sp,$sp,8                   #add stack space back
    j       interrupt_dispatch    # see if other interrupts are waiting
################################
request_puzzle_interrupt:
	#Fill in your code here
        sub     $sp,$sp,4
        sw      $t7,0($sp)
        sw      $zero,REQUEST_PUZZLE_ACK($zero)   #acknowledge interrupt

        la      $t7,FLAGP                           #flag for solve
        sw      $zero,0($t7)
        lw      $t7,0($sp)

        addi    $sp,$sp,4
	j	interrupt_dispatch

timer_interrupt:
    #Fill in your code here
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
