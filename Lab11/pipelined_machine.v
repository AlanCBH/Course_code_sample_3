module pipelined_machine(clk, reset);
    input        clk, reset;

    wire [31:0]  PC;
    wire [31:2]  next_PC, PC_plus4, PC_target;
    wire [31:0]  inst;

    wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
    wire [4:0]   rs = inst[25:21];
    wire [4:0]   rt = inst[20:16];
    wire [4:0]   rd = inst[15:11];
    wire [5:0]   opcode = inst[31:26];
    wire [5:0]   funct = inst[5:0];

    wire [4:0]   wr_regnum;
    wire [2:0]   ALUOp;

    wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst;
    wire         PCSrc, zero;
    wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;

    wire [31:0]  alu_out_data_MW;
    wire [31:0]  forward_rd1_data;
    wire [31:0]  forward_rd2_data;
    wire [31:0]  pre_inst;
    wire [31:2]  pre_PC_plus4;
    wire [31:0]  rd2_data_MW;
    wire ForwardA,ForwardB,RegWrite_MW,MemToReg_MW,MemRead_MW,MemWrite_MW;
    wire [4:0] wr_regnum_MW;
    wire stall;
    wire resetStall;
    wire enable;
    wire flush;
    //assign ForwardA = 0;
    //assign ForwardB = 0;
    // DO NOT comment out or rename this module
    // or the test bench will break
    register #(30, 30'h100000) PC_reg(PC[31:2], next_PC[31:2], clk, /* enable */enable, reset);

    assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
    adder30 next_PC_adder(pre_PC_plus4, PC[31:2], 30'h1);
    //
    register #(30) PC_p4_reg(PC_plus4,pre_PC_plus4, clk, enable,reset|flush);
    //
    adder30 target_PC_adder(PC_target, PC_plus4, imm[29:0]);
    mux2v #(30) branch_mux(next_PC, pre_PC_plus4, PC_target, PCSrc);
    assign PCSrc = BEQ & zero;

    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory imem(pre_inst, PC[31:2]);
    //
    register #(32) inst_reg(inst,pre_inst,clk,enable,reset|flush);
    //
    mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst,
                      opcode, funct);

    register #(1) RegWrite_reg(RegWrite_MW,RegWrite,clk,1'b1,reset|flush);
    register #(1) MemRead_reg(MemRead_MW,MemRead,clk,1'b1,reset|flush);
    register #(1) MemWrite_reg(MemWrite_MW,MemWrite,clk,1'b1,reset|flush);
    register #(1) MemToReg_reg(MemToReg_MW,MemToReg,clk,1'b1,reset|flush);
    //register MemRead_reg(MemRead_MW,MemRead,clk,1'b1,reset);
    // DO NOT comment out or rename this modzule
    // or the test bench will break
    regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum_MW, wr_data,
               RegWrite_MW, clk, reset);

    //mux2v #(32) ForwardA_mux(rd1_data,pre_rd1_data,alu_out_data_MW,ForwardA);
    //mux2v #(32) ForwardB_mux(rd2_data,pre_rd2_data,alu_out_data_MW,ForwardB);
    mux2v #(32) ForwardA_mux(forward_rd1_data,rd1_data,alu_out_data_MW,ForwardA);
    mux2v #(32) ForwardB_mux(forward_rd2_data,rd2_data,alu_out_data_MW,ForwardB);

    register #(32) rd2_data_reg(rd2_data_MW,forward_rd2_data,clk,1'b1,resetStall|flush);

    mux2v #(32) imm_mux(B_data, forward_rd2_data, imm, ALUSrc);

    alu32 alu(alu_out_data, zero, ALUOp, forward_rd1_data, B_data);
    register #(32) alu_reg_MW(alu_out_data_MW,alu_out_data,clk,1'b1,resetStall|flush);
    // DO NOT comment out or rename this module
    // or the test bench will break
    data_mem data_memory(load_data, alu_out_data_MW, rd2_data_MW, MemRead_MW, MemWrite_MW, clk, reset);

    mux2v #(32) wb_mux(wr_data, alu_out_data_MW, load_data, MemToReg_MW);

    mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);
    register #(5) wr_regnum_MW_reg(wr_regnum_MW,wr_regnum,clk,1'b1,resetStall|flush);
    //forward module
    wire w1 = rs == wr_regnum_MW;
    wire w2 = rt == wr_regnum_MW;
    wire w3 = rs == 0;
    wire w4 = rt == 0;
    assign ForwardA = w1 & RegWrite_MW & ~w3;
    assign ForwardB = w2 & RegWrite_MW & ~w4;
    //

    //stall module
    assign stall = (w1 & MemRead_MW & ~w3) | (w2 & MemRead_MW & ~w4);
    assign resetStall = reset | stall;
    assign enable = ~stall;
    //

    //flushing module
    assign flush = PCSrc;



    //



endmodule // pipelined_machine
