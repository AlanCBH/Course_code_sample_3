// mips_decode: a decoder for MIPS arithmetic instructions
//
// alu_op      (output) - control signal to be sent to the ALU
// writeenable (output) - should a new value be captured by the register file
// rd_src      (output) - should the destination register be rd (0) or rt (1)
// alu_src2    (output) - should the 2nd ALU source be a register (0) or an immediate (1)
// except      (output) - set to 1 when the opcode/funct combination is unrecognized
// opcode      (input)  - the opcode field from the instruction
// funct       (input)  - the function field from the instruction

module mips_decode(alu_op, writeenable, rd_src, alu_src2, except, opcode, funct);
    output [2:0] alu_op;
    output       writeenable, rd_src, alu_src2, except;
    input  [5:0] opcode, funct;
	
	
	wire isAdd = ((funct == `OP0_ADD) & (opcode == `OP_OTHER0));
	wire isAddi = (opcode == `OP_ADDI);
	wire isSub = (funct == `OP0_SUB) & (opcode == `OP_OTHER0);
	wire isAnd = (funct == `OP0_AND) & (opcode == `OP_OTHER0);
	wire isAndi = (opcode == `OP_ANDI);
	wire isOr = (funct == `OP0_OR) & (opcode == `OP_OTHER0);
	wire isOri = (opcode == `OP_ORI);
	wire isNor = (funct == `OP0_NOR) & (opcode == `OP_OTHER0);
	wire isXor = (funct == `OP0_XOR) & (opcode == `OP_OTHER0);
	wire isXori = (opcode == `OP_XORI);
	

	wire w1,w2,w3,w4;
	or o1(w1,isAdd,isAddi,isSub,isAnd,isAndi,isOr,isOri,isNor,isXor,isXori);	
	assign writeenable = w1;
	assign except = ~w1;
	or o2(w2,isOr,isNor,isAnd,isXor,isAndi,isOri,isXori);
	assign alu_op[2] = w2;
	or o3(w3,isAdd,isSub,isNor,isXor,isAddi,isXori);
	assign alu_op[1] = w3;
	or o4(w4,isSub,isOr,isXor,isOri,isXori);
	assign alu_op[0] = w4;

	wire r1;
	or o5(r1,isAddi,isAndi,isOri,isXori);
	assign rd_src = r1;
	wire alus2;
	or o6(alus2,isAddi,isAndi,isOri,isXori);
	assign alu_src2 = alus2;
	
	
endmodule // mips_decode
