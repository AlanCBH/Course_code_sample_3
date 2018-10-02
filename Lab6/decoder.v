// mips_decode: a decoder for MIPS arithmetic instructions
//
// alu_op       (output) - control signal to be sent to the ALU
// writeenable  (output) - should a new value be captured by the register file
// rd_src       (output) - should the destination register be rd (0) or rt (1)
// alu_src2     (output) - should the 2nd ALU source be a register (0) or an immediate (1)
// except       (output) - set to 1 when we don't recognize an opdcode & funct combination
// control_type (output) - 00 = fallthrough, 01 = branch_target, 10 = jump_target, 11 = jump_register
// mem_read     (output) - the register value written is coming from the memory
// word_we      (output) - we're writing a word's worth of data
// byte_we      (output) - we're only writing a byte's worth of data
// byte_load    (output) - we're doing a byte load
// lui          (output) - the instruction is a lui
// slt          (output) - the instruction is an slt
// addm         (output) - the instruction is an addm
// opcode        (input) - the opcode field from the instruction
// funct         (input) - the function field from the instruction
// zero          (input) - from the ALU
//

module mips_decode(alu_op, writeenable, rd_src, alu_src2, except, control_type,
                   mem_read, word_we, byte_we, byte_load, lui, slt, addm,
                   opcode, funct, zero);
    output [2:0] alu_op;
    output       writeenable, rd_src, alu_src2, except;
    output [1:0] control_type;
    output       mem_read, word_we, byte_we, byte_load, lui, slt, addm;
    input  [5:0] opcode, funct;
    input        zero;


    //copy from lab5
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

	//added functions
	wire isBeq = (opcode == `OP_BEQ);
	wire isBne = (opcode == `OP_BNE);
	wire isJ = (opcode == `OP_J);
	wire isJr = (funct == `OP0_JR) & (opcode == `OP_OTHER0);
	wire isLui = (opcode == `OP_LUI);
	wire isSlt = (funct == `OP0_SLT) & (opcode == `OP_OTHER0);
	wire isLw = (opcode == `OP_LW);
	wire isLbu = (opcode == `OP_LBU);
	wire isSw = (opcode == `OP_SW);
	wire isSb = (opcode ==`OP_SB);

  wire isAddm = (funct == 6'h2c) & (opcode == `OP_OTHER0);

  wire w1,ww,w2,w3,w4;
	or o1(w1,isAdd,isAddi,isSub,isAnd,isAndi,isOr,isOri,isNor,isXor,isXori,isBeq,isBne,isJr,isJ,isLui,isSlt,isLw,isLbu,isSw,isSb,isAddm);
	assign except = ~w1;
  or o1(ww,isAdd,isAddi,isSub,isAnd,isAndi,isOr,isOri,isNor,isXor,isXori,isLui,isSlt,isLw,isLbu,isAddm);
  assign writeenable = ww;
	//assign except = ~w1;
	or o2(w2,isOr,isNor,isAnd,isXor,isAndi,isOri,isXori);
	assign alu_op[2] = w2;
	or o3(w3,isAdd,isSub,isNor,isXor,isAddi,isXori,isLw,isLbu,isSb,isSw,isBeq,isBne,isSlt,isAddm);
	assign alu_op[1] = w3;
	or o4(w4,isSub,isOr,isXor,isOri,isXori,isBeq,isBne,isSlt);
	assign alu_op[0] = w4;

	wire r1;
	or o5(r1,isAddi,isAndi,isOri,isXori,isBeq,isBne,isLui,isLw,isLbu,isSw,isSb);
	assign rd_src = r1;
	wire alus2;
	or o6(alus2,isAddi,isAndi,isOri,isXori,isBeq,isBne,isLui,isLw,isLbu,isSw,isSb,isAddm);
	assign alu_src2 = alus2;

  wire ctype0,c1,c2,c3;
  and o7(c1,isBeq,zero);
  assign c2 = isBne&~zero;
  or (ctype0,c1,c2,isJr);
  assign control_type[0] = ctype0;

  wire ctype1;
  or o8(ctype1,isJ,isJr);
  assign control_type[1] = ctype1;


  wire mem;
  or o9(mem,isLw,isLbu,isAddm);
  assign mem_read = mem;

  assign word_we = isSw;

  assign byte_we = isSb;

  assign byte_load = isLbu;

  assign lui = isLui;

  assign slt = isSlt;

  assign addm = isAddm;





















endmodule // mips_decode
