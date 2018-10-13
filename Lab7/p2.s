.text

## bool
## board_done(unsigned short board[16][16]) {
##   for (int i = 0 ; i < 16 ; ++ i) {
##     for (int j = 0 ; j < 16 ; ++ j) {
##       if (!has_single_bit_set(board[i][j])) {
##         return false;
##       }
##     }
##   }
##   return true;
## }

.globl board_done
board_done:
	sub	$sp,$sp,16
	sw	$ra,0($sp)	#save board
	li	$t0,0		#make i = 0
	sw	$s0,4($sp)	#save
	sw	$s1,8($sp)	#save
	sw	$s2,12($sp)	#save
	move	$s0,$a0		#save original address
	move	$s1,$t0		#save t0
first_forstart:
	li	$t1,0		#make j = 0
	move	$s2,$t1		#save t1
second_forstart:
	move	$t0,$s1
	mul	$t3,$t0,16	#i*N
	move	$t1,$s2
	add	$t3,$t3,$t1	#i*N+j
	mul	$t3,$t3,2	#(i*N+j)*sizeof short
	add	$a0,$t3,$a0	#a0+address

	lhu	$a0,0($a0)
	jal	has_single_bit_set		#calling function

	move	$a0,$s0		#re-write the board

	bne	$v0,$zero,second_forend		#go in to if or not
	li	$v0,0		#return false
	lw	$ra,0($sp)	#get the original return address
	addi	$sp,$sp,16	#return the space
	jr	$ra
second_forend:
	move	$t1,$s2		#read original j
	addi	$t1,$t1,1	#++j
	move	$s2,$t1		#save j again
	blt     $t1,16,second_forstart		#j<16
	move	$t0,$s1		#read original i
	addi    $t0,$t0,1	#++i
	move	$s1,$t0		#save i again
	blt	$t0,16,first_forstart		#i<16
	move	$v0,$zero
	addi	$v0,$v0,1	#make true
	lw	$ra,0($sp)	#get the original return address
	addi	$sp,$sp,16	#return the space
	jr	$ra


## void
## print_board(unsigned short board[16][16]) {
##   for (int i = 0 ; i < 16 ; ++ i) {
##     for (int j = 0 ; j < 16 ; ++ j) {
##       int value = board[i][j];
##       char c = '*';
##       if (has_single_bit_set(value)) {
##         int num = get_lowest_set_bit(value) + 1;
##         c = symbollist[num];
##       }
##       putchar(c);
##     }
##     putchar('\n');
##   }
## }

.globl print_board
print_board:
	sub	$sp,$sp,28
	sw	$ra,0($sp)	#save return address
	sw	$s0,4($sp)	#save
	sw	$s1,8($sp)	#save
	sw	$s2,12($sp)	#save
	sw	$s3,16($sp)	#save
	sw	$s4,20($sp)	#save
	sw	$s5,24($sp)	#save
	la	$t2,symbollist	#get the address of symbollist
	li	$t0,0		#i = 0
	move	$s0,$a0		#save original address
	move	$s1,$t0		#save i
	move 	$s3,$t2		#save symbollist address
first_first:
	li	$t1,0		#j = 0
	move	$s2,$t1		#save j
sec_first:
	move	$t0,$s1			#get i
	mul	$t3,$t0,16		#i*N
	move 	$t1,$s2			#get j
	add	$t3,$t3,$t1		#i*N+j
	mul	$t3,$t3,2		#(i*N+j)*sizeof short
	add	$a0,$t3,$a0		#a0+address
	li	$t5,'*'			#char c = '*'
	move	$s4,$t5			#save c
	lhu	$a0,0($a0)		#get the value in $a0
	move	$s5,$a0			#save value
	jal	has_single_bit_set	#call function
	bne	$v0,1,if_end		#go into if or not
	move	$a0,$s5			#get value
	jal	get_lowest_set_bit	#call other function
	addi	$t6,$v0,1		#num = get_lowest_set_bit+1
	move	$t2,$s3			#get the address of symbollist
	add	$t6,$t6,$t2		#get the address of symbollist[num]
	lb	$t5,0($t6)		#c = symbollist[num]
	move	$s4,$t5			#save c again
if_end:
	move	$a0,$s4			#putchar('c')
	li	$v0,11			#putchar('c')
	syscall				#putchar('c')
	move	$a0,$s0			#rewrite the address to a0
	move	$t1,$s2			#get original j
	addi	$t1,$t1,1		#++j
	move	$s2,$t1			#save j again
	blt	$t1,16,sec_first	#jump to the second loop
	li	$a0,'\n'		#putchar('\n')
	li	$v0,11			#putchar('\n')
	syscall				#putchar('\n')
	move	$a0,$s0			#rewrite the address to a0
	move 	$t0,$s1			#get original i
	addi	$t0,$t0,1		#++i
	move	$s1,$t0			#save i again
	blt	$t0,16,first_first	#jump to the first loop
	lw	$ra,0($sp)		#get the return address
	addi	$sp,$sp,28		#return the space
	jr	$ra			#finish
