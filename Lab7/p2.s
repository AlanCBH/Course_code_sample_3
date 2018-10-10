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
	sub	$sp,$sp,2
	sw	$a0,0($sp)	#save board
	li	$t0,0		#make i = 0
first_forstart:
	li	$t1,0		#make j = 0
second_forstart:
	mul	$t3,$t0,16	#i*N
	add	$t3,$t3,t1	#i*N+j
	mul	$t3,$t3,2	#(i*N+j)*sizeof short
	add	$t3,$t3,$a0	#a0+address
	lw	$a0,0($t3)	#get the board[i][j]
	jal	has_single_bit_set		#calling function
	lw	$a0,0($sp)	#re-write the board
	bne	$v0,$zero,second_forend		#go in to if or not
	move	$v0,$zero	#return false
	jr	$ra
second_forend:
	addi	$t1,$t1,1	#++j
	blt     $t1,16,second_forstart		#j<16
	addi    $t0,$t0,1	#++i
	blt	$t0,16,first_forstart		#i<16
	move	$v0,$zero
	addi	$v0,$v0,1	#make true
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
	jr	$ra
