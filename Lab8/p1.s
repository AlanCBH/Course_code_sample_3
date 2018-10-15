.text

##int
##dfs(int* tree, int i, int input) {
##	if (i >= 127) {
##		return -1;
##	}
##	if (input == tree[i]) {
##		return 0;
##	}
##
##	int ret = DFS(tree, 2 * i, input);int* tree, int i, int input)
##	if (ret >= 0) {
##		return ret + 1;
##	}
##	ret = DFS(tree, 2 * i + 1, input);
##	if (ret >= 0) {
##		return ret + 1;
##	}
##	return ret;
##}

.globl dfs
dfs:
	sub	$sp,$sp,20
 	sw	$ra,0($sp)	#save return address
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	move	$s0,$a0		#save address tree
	move	$s1,$a1		#save i
	move	$s2,$a2		#save input
	move	$s3,$v0		#save return value
	li	$t3,127		#load 127
	blt	$s1,$t3,pass1	#if i >= 127
	li	$v0,-1		#return -1
	lw	$ra,0($sp)	#save return address
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	addi	$sp,$sp,20
	jr	$ra		#return
pass1:
	mul	$t0,$s1,4	#get the address of i
	add	$t1,$s0,$t0	#add the address of i with a0
	lw	$t1,0($t1)	#load the data stored in tree[i]
	bne	$s2,$t1,pass0	#input == tree[i]
	li	$v0,0		#return 0
	lw	$ra,0($sp)	#save return address
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	addi	$sp,$sp,20
	jr 	$ra		#return
pass0:
	mul	$a1,$s1,2	#2*i
	jal	dfs
	blt	$v0,0,rightside	#check the left side of the node
	addi	$v0,$v0,1	#ret+1
	lw	$ra,0($sp)	#save return address
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	addi	$sp,$sp,20
	jr	$ra		#return
rightside:
	move	$a0,$s0		#reset treeptr
	move	$a2,$s2		#reset input
	mul	$a1,$s1,2	#2*i
	addi 	$a1,$a1,1	#2*i+1
	jal	dfs
	blt	$v0,0,currentlv	#check the right side of the node
	addi	$v0,$v0,1	#ret+1
	lw	$ra,0($sp)	#save return address
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	addi	$sp,$sp,20
	jr 	$ra		#return
currentlv:
	lw	$ra,0($sp)	#save return address
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	addi	$sp,$sp,20
	jr 	$ra		#return
