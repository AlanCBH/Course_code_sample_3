.globl get_square_begin
get_square_begin:
	# round down to the nearest multiple of 4
	and	$a0, $a0, 0xfffffffc
	jr	$ra


# UNTIL THE SOLUTIONS ARE RELEASED, YOU SHOULD COPY OVER YOUR VERSION FROM LAB 7
# (feel free to copy over the solution afterwards)
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


# UNTIL THE SOLUTIONS ARE RELEASED, YOU SHOULD COPY OVER YOUR VERSION FROM LAB 7
# (feel free to copy over the solution afterwards)
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


# UNTIL THE SOLUTIONS ARE RELEASED, YOU SHOULD COPY OVER YOUR VERSION FROM LAB 7
# (feel free to copy over the solution afterwards)
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
	lw	$s0,4($sp)	#save
	lw	$s1,8($sp)	#save
	lw	$s2,12($sp)	#save
	lw	$s3,16($sp)	#save
	lw	$s4,20($sp)	#save
	lw	$s5,24($sp)	#save
	addi	$sp,$sp,28		#return the space
	jr	$ra			#finish
