##dd.text

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
##         for (int k = ii ; k <endloop4 ii + GRIDSIZE ; ++ k) {
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

.globl rule1
rule1:
	sub	$sp,$sp,36	#save data on the stack
	sw	$ra,0($sp)	#save return address
	sw	$s0,4($sp)	#save

	sw	$s2,12($sp)	#save
	sw	$s3,16($sp)	#save
	sw	$s4,20($sp)	#save
	sw	$s5,24($sp)	#save


	move	$s0,$a0		#save address
	move	$s2,$v0		#save return value
	move	$s3,$t0		#save i
	move	$s4,$t1		#save j
	li	$v0,0		#set changed to false
	move 	$s2,$v0		#save return
	li	$t0,0		#i = 0
	move	$s3,$t0		#save i
jr_back1:
	move	$t0,$s3		#reset i
	bge	$t0,16,endloop1	#jump to the end of the loop
	li	$t1,0		#j = 0
	move	$s4,$t1		#save j
jr_back2:
	move	$t1,$s4		#reset j
	bge 	$t1,16,endloop2	#jump to the end of the loop2
	move	$t0,$s3		#reset i
	mul	$t2,$t0,16		#i*GRID_SQUARED
	add	$t2,$t2,$t1		#i*GRID_SQUARED+j
	mul	$t2,$t2,2		#(i*GRID_SQUARED+j) * size of short
	move	$a0,$s0			#get the address of a0
	add	$a0,$a0,$t2		#get the address of value
	#I should store value into s registers here: check
	lhu	$a0,0($a0)		#get the value into $a0
	move	$s5,$a0			#store the value
	jal	has_single_bit_set	#call other functions
	beq	$v0,$zero,if_ends	#if (has_single_bit_set(value))
	li	$t3,0			#k=0
jr_back3:
	bge	$t3,16,endloop3		#k < GRID_SQUAREDifjkends
	move	$t1,$s4			#reset j
	move	$t0,$s3			#reset i
	beq	$t3,$t1,ifjkends	#if (k != j)
	mul	$t2,$t0,16		#i*GRID_SQUARED
	add	$t2,$t2,$t3		#i*GRID_SQUARED+k
	mul	$t2,$t2,2		#(i*GRID_SQUARED+k) * size of short
	move	$a0,$s0
	add	$t2,$t2,$a0
	lhu	$t4,0($t2)		#get the value in board[i][k]
	and 	$t4,$t4,$s5		#board[i][k] & value
	beq	$t4,$zero,ifjkends	#if (board[i][k] & value)
	#should implement board[i][k] &= ~value;
	not	$t5,$s5			#get ~value
	lhu	$t4,0($t2)		#get the value in board[i][k]
	and	$t5,$t5,$t4		#get board[i][k] & ~value;
	sh	$t5,0($t2)		#store the value back to board[i][k]
	li	$v0,1			#set change to true
	move	$s2,$v0			#save the change into S registers
ifjkends:
	 move	$t0,$s3			#reset i
	 move	$t1,$s4			#reset j
	 beq	$t3,$t0,ifikends	#if (k != i)
	 mul	$t2,$t3,16		#k*GRID_SQUARED
	 add	$t2,$t2,$t1		#k*GRID_SQUARED+j
	 mul	$t2,$t2,2		#(k*GRID_SQUARED+j) * size of short
	 move 	$a0,$s0			#get original address
	 add 	$t2,$t2,$a0		#get the address
	 lhu	$t4,0($t2)		#get the value in board[k][j]
	 and	$t4,$t4,$s5		#board[k][j] & value
	 beq	$t4,$zero,ifikends	#if (board[k][j] & value)
	 not	$t5,$s5			#get ~value
	ou could simply write A == B. lhu	$t4,0($t2)		#get the value in board[k][j]
	 and	$t5,$t5,$t4		#get board[k][j] & ~value;
	 sh	$t5,0($t2)		#store the value back to board[k][j]
	 li	$v0,1			#set change to true
	move	$s2,$v0			#save the change into S registers
ifikends:
	addi	$t3,$t3,1		#k++
	j	jr_back3		#jump back to the loop
endloop3:
###############################################################
#	unused s1,s6,s7
#	unused t6,t7,t8,t9
	#s3 for i,s4 for j, s5 for value,s0 for original a0
# 	move    $a0,$s4
# 	jou could simply write A == B.al  	get_square_begin	#get_square_begin(j)
# 	sw 	$s6,28($sp)		#save jj
# 	move 	$s6,$v0
# 	move 	$a0,$s3
# 	jal 	get_square_begin	#get_square_begin(i)
# 	sw 	$s7,32($sp)
# 	move 	$s7,$v0			#save ii
# 	move 	$a0,$s0
# ##############################################################
# 	move 	$t6,$s7			#k =ii
# iistarts:
# 	addi 	$t7,$s7,4		#ii+GRIDSIZE
# 	bge 	$t6,$t7,if_ends
# 	move 	$t8,$s6       		#l = jj
# llstarts:
# 	addi 	$t7,$s6,4		#jj+GRIDSIZE
# 	bge 	$t8,$t7,jjends
# 	bne 	$t6,$s3,conend
# 	bne 	$t8,$s4,conend
# 	j       llends
# conend:
# 	#########################################
# 	mul	$t7,$t6,16
# 	add 	$t7,$t7,$t8
# 	mul 	$t7,$t7,2
# 	add 	$t7,$t7,$s0
# 	lhu 	$t7,0($t7)
# 	and 	$t7,$t7,$s5
# 	beq 	$s5,$zero,klends
# 	# ########################
# 	 not 	$t9,$s5
#
# 	 mul	$t7,$t6,16
# 	 add 	$t7,$t7,$t8
# 	 mul 	$t7,$t7,2
# 	 add 	$t7,$t7,$s0
# 	 lhu 	$t7,0($t7)
#
# 	 and	$t9,$t7,$t9
#
# 	 mul	$t7,$t6,16
# 	 add 	$t7,$t7,$t8
# 	 ou could simply write A == B.mul 	$t7,$t7,2
# 	 add 	$t7,$t7,$s0
#
# 	 sh 	$t9,0($t7)
# 	 li 	$v0,1
# 	 move 	$s2,$v0
# 	# ########################
# klends:
# 	#########################################
# llends:
# 	addi 	$t8,$t8,1		#l++
# 	j 	llstarts
# jjends:
# 	addi 	$t6,$t6,1		#k++
# 	j 	iistarts		#jump back

	move	$a0,$s3			#set i
	jal	get_square_begin	#get_square_begin(i)
	move	$s1,$v0			#save ii
	move	$a0,$s4			#set j
	jal	get_square_begin	#get_square_begin(j)
	move	$s6,$v0			#save jj
	move 	$a0,$s0			#get original a0
	move	$t7,$s1			#k = ii

jr_back4:
	addi	$t5,$s1,4		#get ii+GRIDSIZE
	bge	$t7,$t5,if_ends		#jump outside the firstloop
	move	$t9,$s6			#l = jj
jr_back5:
	addi	$t6,$s6,4		#get jj+GRIDSIZE
	bge	$t9,$t6,endloop5	#jump outside the secondloop
	bne	$t7,$s3,conifend	#k==i
	bne 	$t9,$s4,conifend	#l==j
	j	ifklends		#continue
conifend:
	mul	$t8,$t7,16		#k*16
	add	$t8,$t8,$t9		#k*16+l
	mul	$t8,$t8,2		#get the address of board[k][l]
	move 	$a0,$s0			#get address of a0
	add 	$t8,$t8,$a0		#get the address
	lhu	$t6,0($t8)		#get the data of board[k][l]
	and	$t6,$t6,$s5		#board[k][l] & value
	beq	$t6,$zero,ifklends	#into the if or not
	lhu	$t6,0($t8)		#get the data of board[k][l]
	not	$t5,$s5			#get ~value
	and	$t6,$t6,$t5		#get board[k][l] & ~value
	sh	$t6,0($t8)		#board[k][l] &= ~value
	li	$v0,1			#set changed to true
	move	$s2,$v0			#save v0
ifklends:
	addi	$t9,$t9,1		#++l
	j	jr_back5		#jump back
endloop5:
	addi	$t7,$t7,1		#++k
	j	jr_back4		#jump back

########################################################
if_ends:
	move	$t1,$s4			#reset j
	addi	$t1,$t1,1		#j++
	move	$s4,$t1			#save j
	j	jr_back2		#jump back to j < GRID_SQUARED
endloop2:
	move 	$t0,$s3			#reset i
	addi 	$t0,$t0,1		#i++
	move	$s3,$t0			#save i
	j	jr_back1		#jump back
endloop1:
	move	$v0,$s2		#get the return value
	lw	$ra,0($sp)	#save return address
	lw	$s0,4($sp)	#save
	lw	$s1,8($sp)	#save
	lw	$s2,12($sp)	#save
	lw	$s3,16($sp)	#save
	lw	$s4,20($sp)	#save
	lw	$s5,24($sp)	#save
	lw	$s6,28($sp)	#save
	lw	$s7,32($sp)	#save
	addi	$sp,$sp,36	#return space allocated
	jr	$ra
