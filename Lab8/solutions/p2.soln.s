.text

## bool
## rule1(unsigned short board[GRID_SQUARED][GRID_SQUARED]) {
##   bool changed = false;
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
##     for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
##       unsigned value = board[i][j];
##       if (has_single_bit_set(value)) {
##         for (int k = 0 ; k < GRID_SQUARED ; ++ k) {
##           // eliminate from row
##           if (k != j) {
##             if (board[i][k] & value) {
##               board[i][k] &= ~value;
##               changed = true;
##             }
##           }
##           // eliminate from column
##           if (k != i) {
##             if (board[k][j] & value) {
##               board[k][j] &= ~value;
##               changed = true;
##             }
##           }
##         }
##
##         // elimnate from square
##         int ii = get_square_begin(i);
##         int jj = get_square_begin(j);
##         for (int k = ii ; k < ii + GRIDSIZE ; ++ k) {
##           for (int l = jj ; l < jj + GRIDSIZE ; ++ l) {
##             if ((k == i) && (l == j)) {
##               continue;
##             }
##             if (board[k][l] & value) {
##               board[k][l] &= ~value;
##               changed = true;
##             }
##           }
##         }
##       }
##     }
##   }
##   return changed;
## }

## I chose to make a helper function to compute board addresses.
.data
GRID_SQUARED = 16
GRIDSIZE = 4
ALL_VALUES = (1 << GRID_SQUARED)-1

board_address:
	mul	$v0, $a1, 16		# i*16
	add	$v0, $v0, $a2		# (i*16)+j
	sll	$v0, $v0, 1		# ((i*9)+j)*2
	add	$v0, $a0, $v0
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
	# #include <stdbool.h>
	# #define GRID_SQUARED 16
	# #define GRIDSIZE 4
	# const int ALL_VALUES = (1 << GRID_SQUARED) - 1;
	# bool rule2(unsigned short board[GRID_SQUARED][GRID_SQUARED]) {
	#     bool changed = false;
	#     for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
	#         for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
	#             unsigned value = board[i][j];
	#             // if every cell that does not have a guaranteed value
	#             if (has_single_bit_set(value)) {
	#                 continue;
	#             }
	#
	#             // Find the possible values all the other cells
	#             // in the row and column could take
	#             int jsum = 0, isum = 0;
	#             for (int k = 0 ; k < GRID_SQUARED ; ++ k) {
	#                 if (k != j) {
	#                     jsum |= board[i][k]; // summarize row
	#                 }
	#                 if (k != i) {
	#                     isum |= board[k][j]; // summarize column
	#                 }
	#             }
	#
	#             // If there is at least one missing value
	#             // that the other cells can't cover,
	#             // then clearly the ith, jth cell must
	#             // cover those values (property of Sudoku)
	#             // For a valid sudoku puzzle, can you have
	#             // more than one missing value? If so, why?
	#             // What advatange does this have?
	#             if (ALL_VALUES != jsum) {
	#                 // Set it to the values not covered
	#                 board[i][j] = ALL_VALUES & ~jsum;
	#                 changed = true;
	#                 continue;
	#             } else if (ALL_VALUES != isum) {
	#                 board[i][j] = ALL_VALUES & ~isum;
	#                 changed = true;
	#                 continue;
	#             }
	#             // eliminate from square
	#             int ii = get_square_begin(i);
	#             int jj = get_square_begin(j);
	#             unsigned sum = 0;
	#             // Now we do a similar summary of the square ignoring the current cell
	#             for (int k = ii ; k < ii + GRIDSIZE ; ++ k) {
	#                 for (int l = jj ; l < jj + GRIDSIZE ; ++ l) {
	#                     if ((k == i) && (l == j)) {
	#                         continue;
	#                     }
	#                     sum |= board[k][l];
	#                 }
	#             }
	#             // Similar setting
	#             if (ALL_VALUES != sum) {
	#                 board[i][j] = ALL_VALUES & ~sum;
	#                 changed = true;
	#             }
	#         }
	#     }
	#     return changed;
	# }


	.globl rule2
	rule2:
	                sub  $sp,$sp,36         #space for register
	                sw   $ra,0($sp)

	                sw   $s0,4($sp)
	                sw   $s1,8($sp)
	                sw   $s2,12($sp)
	                sw   $s3,16($sp)
	                sw   $s4,20($sp)

	                sw   $s5,24($sp)        #later used for ii
	                sw   $s6,28($sp)        #later used for jj
	                sw   $s7,32($sp)        #later used for sum
	                move $s3,$a0
	                move $s4,$0             #changed = false
	                move $s0,$0             #int i = 0;
	i_loop_start:
	                bge  $s0,16,end_func    #
	                move $s1,$0             #int j = 0;
	j_loop_start:
	                bge  $s1,16,j_loop_end
	                mul  $t0,$s0,16         #i*16
	                add  $t0,$t0,$s1        #i*16+j
	                mul  $t0,$t0,2          #(i*16+j)*size of short
	                add  $s2,$s3,$t0        #add the original address
	                lw   $s2,0($s2)         #get the value in that address
	                move $a0,$s2
	                jal  has_single_bit_set
	                beq  $v0,1,j_loop_incre   #if (has_single_bit_set) continue
	                move $t6,0              #jsum = 0
	                move $t7,0              #isum = 0
	                move $t8,0              #k = 0
	k_loop_start:
	                bge  $t8,16,k_loop_end
	                beq  $t8,$s1,next_if
	                mul  $t0,$s0,16         #i*16
	                add  $t0,$t0,$t8        #i*16+k
	                mul  $t0,$t0,2          #(i*16+k)*size of short
	                add  $t0,$s3,$t0        #add the original address
	                lw   $t0,0($t0)         #get the value in that address
	                or   $t6,$t6,$t0        #jsum |= board[i][k];
	next_if:
	                beq  $t8,$s1,kif_end
	                mul  $t0,$t8,16         #k*16
	                add  $t0,$t0,$s1        #k*16+j
	                mul  $t0,$t0,2          #(k*16+j)*size of short
	                add  $t0,$s3,$t0        #add the original address
	                lw   $t0,0($t0)         #get the value in that address
	                or   $t7,$t7,$t0        #isum |= board[k][j];
	kif_end:
	                addi $t8,$t8,1
	                j    k_loop_start
	k_loop_end:
	                beq  $t6,ALL_VALUES,else_if
	                mul  $t0,$s0,16         #i*16
	                add  $t0,$t0,$s1        #i*16+j
	                mul  $t0,$t0,2          #(i*16+j)*size of short
	                add  $t0,$s3,$t0        #add the original address
	                not  $t1,$t6
	                and  $t1,$t1,ALL_VALUES
	                sw   $t1,0($t0)
	                li   $s4,1
	                j    j_loop_incre
	else_if:
	                beq  $t6,ALL_VALUES,next_k_loop
	                mul  $t0,$s0,16         #i*16
	                add  $t0,$t0,$s1        #i*16+j
	                mul  $t0,$t0,2          #(i*16+j)*size of short
	                add  $t0,$s3,$t0        #add the original address
	                not  $t1,$t7
	                and  $t1,$t1,ALL_VALUES
	                sw   $t1,0($t0)
	                li   $s4,1
	                j    j_loop_incre
	next_k_loop:
	                move    $a0,$s0
	                jal     get_square_begin
	                move    $s5,$v0         #ii = get_square_begin(i)
	                move    $a0,$s1
	                jal     get_square_begin
	                move    $s6,$v0         #jj = get_square_begin(j)
	                move    $s7,$0          #sum = 0
	                move    $t8,$s5         #k = ii
	k_start:
	                addi    $t0,$s5,GRIDSIZE        #ii+GRIDSIZE
	                bge     $t8,$t0,next_k_end
	                move    $t5,$s6         #l = jj
	                addi    $t0,$t6,GRIDSIZE        #jj+GRIDSIZE
	l_start:
	                bge     $t5,$t0,l_end
	                bne     $t8,$s0,out_if
	                bne     $t5,$s1,out_if
	                j       l_incre
	out_if:
	                mul     $t0,$t8,16      #k*16
	                addi    $t0,$t0,$t5     #k*16+l
	                mul     $t0,$t0,2       #*size
	                addi    $t0,$t0,$s3     #add the original address
	                lw      $t0,0($t0)      #get the value
	                or      $s7,$s7,$t0     #sum |= board[k][l]
	l_incre:
	                addi    $t5,$t5,1
	                j       l_start
	l_end:
	                addi    $t8,$t8,1
	                j       k_start
	next_k_end:

	                beq     $s7,ALL_VALUES,j_loop_incre
	                mul     $t0,$s0,16      #i*16
	                addi    $t0,$t0,$s1     #i*16+j
	                mul     $t0,$t0,2       #*size
	                addi    $t0,$t0,$s3     #add the original address
	                not     $t1,$s7         #~sum
	                and     $t1,$t1,ALL_VALUES
	                sw      $t1,0($t0)      #board[i][j] = ALL_VALUES & ~sum;
	                li      $s4,1           #changed = true
	j_loop_incre:
	                addi    $s1,$s1,1
	                j       j_loop_start
	j_loop_end:
	                addi    $s0,$s0,1
	                j       i_loop_start
	end_func:
	                move    $v0,$s4
	                lw      $ra,0($sp)
	                lw      $s0,4($sp)
	                lw      $s1,8($sp)
	                lw      $s2,12($sp)
	                lw      $s3,16($sp)
	                lw      $s4,20($sp)

	                lw      $s5,24($sp)        #later used for ii
	                lw      $s6,28($sp)        #later used for jj
	                lw      $s7,32($sp)        #later used for sum
	                addi    $sp,$sp,36
	                jr      $ra
