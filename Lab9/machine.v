module machine(clk, reset);
   input        clk, reset;

   wire [31:0]  PC;
   wire [31:2]  next_PC, PC_plus4, PC_target;
   wire [31:0]  inst;

   wire [31:0]  imm = {{ 16{inst[15]} }, inst[15:0] };  // sign-extended immediate
   wire [4:0]   rs = inst[25:21];
   wire [4:0]   rt = inst[20:16];
   wire [4:0]   rd = inst[15:11];

   wire [4:0]   wr_regnum;
   wire [2:0]   ALUOp;

   wire         RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET;
   wire         PCSrc, zero, negative;
   wire [31:0]  rd1_data, rd2_data, B_data, alu_out_data, load_data, wr_data;

   //new wires
   wire TimerInterrupt,TimerAddress;
   wire [31:0] c1_data,cycle;
   wire TakenInterrupt;
   wire [29:0] EPC;
   wire [31:2] INTER_des;
   //
   //register #(30, 30'h100000) PC_reg(PC[31:2], next_PC[31:2], clk, /* enable */1'b1, reset);
   register #(30, 30'h100000) PC_reg(PC[31:2], INTER_des[31:2], clk, /* enable */1'b1, reset);
   assign PC[1:0] = 2'b0;  // bottom bits hard coded to 00
   adder30 next_PC_adder(PC_plus4, PC[31:2], 30'h1);
   adder30 target_PC_adder(PC_target, PC_plus4, imm[29:0]);
   mux2v #(30) branch_mux(next_PC, PC_plus4, PC_target, PCSrc);
   //
   wire [29:0] branch_des;
   mux2v #(30) branch_mux2(branch_des,next_PC,EPC,ERET);
   mux2v #(30) branch_mux3(INTER_des,branch_des,30'h20000060,TakenInterrupt);
   //
   assign PCSrc = BEQ & zero;

   instruction_memory imem (inst, PC[31:2]);

   mips_decode decode(ALUOp, RegWrite, BEQ, ALUSrc, MemRead, MemWrite, MemToReg, RegDst, MFC0, MTC0, ERET,
                      inst);

   regfile rf (rd1_data, rd2_data,
               rs, rt, wr_regnum, wr_data,
               RegWrite, clk, reset);

   mux2v #(32) imm_mux(B_data, rd2_data, imm, ALUSrc);
   alu32 alu(alu_out_data, zero, negative, ALUOp, rd1_data, B_data);
   wire NOTIO = ~TimerAddress;
   wire RealMemRead = MemRead & NOTIO;
   wire RealMemWrite = MemWrite & NOTIO;
   data_mem data_memory(load_data, alu_out_data, rd2_data, RealMemRead, RealMemWrite, clk, reset);
   wire [31:0] WBIN,NON_INTER;
   assign WBIN = load_data;
   assign WBIN = cycle;
   mux2v #(32) wb_mux(NON_INTER, alu_out_data, WBIN, MemToReg);
   mux2v #(32) inter_mux(wr_data,NON_INTER,c1_data,MFC0);
   mux2v #(5) rd_mux(wr_regnum, rt, rd, RegDst);
   // my own modules

   timer t1(TimerInterrupt, cycle, TimerAddress,
                rd2_data, alu_out_data, MemRead, MemWrite, clk, reset);
   cp0   c1(c1_data, EPC, TakenInterrupt,
              rd2_data, wr_regnum, next_PC,
              MTC0, ERET, TimerInterrupt, clk, reset);


endmodule // machine
