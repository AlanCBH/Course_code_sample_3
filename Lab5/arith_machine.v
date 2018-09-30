// arith_machine: execute a series of arithmetic instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock  (input)  - the clock signal
// reset  (input)  - set to 1 to set all registers to zero, set to 0 for normal execution.

module arith_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire [31:0] inst;
    wire [31:0] PC;

    // DO NOT comment out or rename this module
    // or the test bench will break
    //q, d, clock, enable, reset
    wire useless1,useless2,useless3;
    wire [31:0] input1;
    register #(32) PC_reg(PC,input1,clock,1'b1,reset);
    alu32 alu1(input1, useless1, useless2, useless3,32'h04,PC, 3'b010);
    wire [29:0] addr = PC[31:2];


    // DO NOT comment out or rename this module
    // or the test bench will break
    instruction_memory im(inst,addr);
    //this is mux2v for choosing input for R,I
    wire [4:0] Rs;
    wire [4:0] Rt;
    wire [4:0] Rd;
    assign Rs = inst[25:21];
    assign Rt = inst[20:16];
    assign Rd = inst[15:11];
    wire [4:0] Rdest;
    wire rd_src;
    mux2v  #(5) m1(Rdest, Rd, Rt, rd_src);

    // DO NOT comment out or rename this module
    // or the test bench will break
    //module regfile (rsData, rtData,rsNum, rtNum, rdNum, rdData, rdWriteEnable, clock, reset);
    wire [31:0] rsData;
      wire [31:0] rtData;
        wire [31:0] rdData;
    wire  alu_src2, writeenable;
    regfile rf (rsData,rtData,Rs,Rt,Rdest,rdData,writeenable,clock,reset);
    // mux2v for R,I
    wire [31:0] B;
    wire [31:0] outSign;
    assign outSign[15:0] = inst[15:0];
    assign outSign[31:16] = {16{inst[15]}};
    mux2v  #(32) m2(B,rtData,outSign,alu_src2);
    //assign A = rsData[31:0];
    //alu2 that compute the data
    wire zero,overflow,negative;
    wire [2:0] alu_op;
    alu32 alu2(rdData, overflow, zero, negative,rsData,B, alu_op);
    /* add other modules */

    // this is mips decoder


    wire [5:0] funct;
    assign funct[5:0] = inst[5:0];
    wire [5:0] opcode;
    assign opcode[5:0] = inst[31:26];
    mips_decode md1(alu_op, writeenable, rd_src, alu_src2, except, opcode, funct);







endmodule // arith_machine
