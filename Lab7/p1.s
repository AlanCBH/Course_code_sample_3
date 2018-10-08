.text

## bool has_single_bit_set(unsigned value) {  // returns 1 if a single bit is set
##   if (value == 0) {  
##     return 0;   // has no bits set
##   }
##   if (value & (value - 1)) {
##     return 0;   // has more than one bit set
##   }
##   return 1;
## }

.globl has_single_bit_set
has_single_bit_set:
	jr	$ra


## unsigned get_lowest_set_bit(unsigned value) {
##   for (int i = 0 ; i < 16 ; ++ i) {
##     if (value & (1 << i)) {          # test if the i'th bit position is set
##       return i;                      # if so, return i
##     }
##   }
##   return 0;
## }

.globl get_lowest_set_bit
get_lowest_set_bit:
	jr	$ra
