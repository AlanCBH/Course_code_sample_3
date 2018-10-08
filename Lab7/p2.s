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
