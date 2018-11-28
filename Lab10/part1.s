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

.data
#
#Put any static memory you need here
#

.text
main:
	#Fill in your code here
    li      $t4,0x8000          #enable interrupts
    or      $t4,$t4,0x1000      #timer interrupt enable bit
    or      $t4,$t4,1           #bonk interrupt bit
    mtc0    $t4,$12             #set interrupt mask
    ################################################
    li      $t2,0                           #set previous state
 judge:
    # sw      $zero,VELOCITY($zero)
    lw      $t1,RIGHT_WALL_SENSOR($zero)   #walls on the right
    not     $t3,$t1                        #current is 0
    and     $t3,$t3,$t2                    #previous is 1
    move    $t2,$t1                        #move the current state to previous

    beq     $t3,1,turn
going_straight:

    li      $t0,10                          #drive again
    sw      $t0,VELOCITY($zero)            #
     j       judge
    #############################################
 turn:

     li      $t0,90                      #rotato 90 degrees
     sw      $t0,ANGLE($zero)       #rotate to right
     sw      $zero,ANGLE_CONTROL($zero)     #set to relative
     #li      $t0,1                          #drive again

     j       judge
endmaze:
    jr      $ra                         #ret

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

    li        $v0, PRINT_STRING    # Unhandled interrupt types
    la        $a0, unhandled_str
    syscall
    j    done

bonk_interrupt:
    #Fill in your code here
    sub     $sp,$sp,8                   #stack space
    sw      $t0,0($sp)                  #save t0
    sw      $v0,4($sp)
    sw      $a1, BONK_ACK($zero)      #acknowledge interrupt


    li      $t0,180                     #rotato 180 degrees
    sw      $t0,ANGLE($zero)            #rotate 180 degrees
    sw      $zero,ANGLE_CONTROL($zero)    #rotate relative ANGLE
    sw      $zero,VELOCITY($zero)        #set speed to zero


    lw      $t0,0($sp)                  #load t0 back\
    lw      $v0,4($sp)

    addi    $sp,$sp,8                   #add stack space back
    j       interrupt_dispatch    # see if other interrupts are waiting

timer_interrupt:
    #Fill in your code here
    sw       $a1,TIMER_ACK($zero)    #acknowledge interrupt
    j        interrupt_dispatch


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
