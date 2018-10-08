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
	bne 	$a0,$zero,sec_if    	#first if value == 0
	move 	$v0,$zero		#set return value to 0
	jr 	$ra			#return
sec_if:
	addi 	$t0,$a0,-1		#get value-1
	and	$t1,$a0,$t0		#compare if
	beq 	$t1,0,end		#into the if or not
	move	$v0,$zero		#set return to 0 and return
	jr	$ra
end:
	li	$v0,1			#set return to 1
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
	li	$t0,0			#load 0 to i
	li	$t1,1			#have an one
for_loop_start:
	sllv	$t2,$t1,$t0		#get 1<<i
	and	$t3,$t2,$a0		#compare value and 1<<i
	beq	$t3,$zero,for_loop_end	#jump or not
	move	$v0,$t0			#set return value
	jr	$ra
for_loop_end:
	addi 	$t0,$t0,1		#i++
	blt	$t0,16,for_loop_start	#i < 16
	move	$v0,$zero		#set return value to 0
	jr	$ra
