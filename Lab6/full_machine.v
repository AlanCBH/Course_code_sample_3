// full_machine: execute a series of MIPS instructions from an instruction cache
//
// except (output) - set to 1 when an unrecognized instruction is to be executed.
// clock   (input) - the clock signal
// reset   (input) - set to 1 to set all registers to zero, set to 0 for normal execution.

module full_machine(except, clock, reset);
    output      except;
    input       clock, reset;

    wire [31:0] inst;
    wire [31:0] PC;

    // DO NOT comment out or rename this module
    // or the test bench will break
    //register #(32) PC_reg( /* connect signals */);

    // DO NOT comment out or rename this module
    // or the test bench will break
    //instruction_memory im( /* connect signals */ );

    // DO NOT comment out or rename this module
    // or the test bench will break
    //regfile rf ( /* connect signal wires */);
	wire [31:0] rsData;
    wire [31:0] rtData;
    wire [31:0] rdData;
	wire [31:0] branch;
	wire [1:0] control_type;
	wire byte_we,word_we,byte_load,lui,slt,addm,mem_read;
	wire [31:0] negslt;
  wire [31:0] data_out;
  wire [7:0] byte_out;
  wire [31:0] byteToWord;
  wire [31:0] luiData;
    //q, d, clock, enable, reset
  wire useless1,useless2,useless3,useless11,useless12,useless13;
  wire [31:0] input1;
  register #(32) PC_reg(PC,input1,clock,1'b1,reset);
	wire [31:0] alu1out,alu2out,jumpwire,jumpRWire;
  alu32 alu1(alu1out, useless1, useless2, useless3,32'h04,PC, 3'b010);
	alu32 alu2(alu2out,  useless11,useless12,useless13,branch,alu1out,3'b010);
	assign jumpwire = {PC[31:28], inst[25:0], 2'b00};
	assign jumpRWire = rsData;
	mux4v #(32) mux4(input1,alu1out,alu2out,jumpwire,jumpRWire,control_type);
    wire [29:0] addr = PC[31:2];


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

    //module regfile (rsData, rtData,rsNum, rtNum, rdNum, rdData, rdWriteEnable, clock, reset);

    wire  alu_src2, writeenable;
    regfile rf (rsData,rtData,Rs,Rt,Rdest,rdData,writeenable,clock,reset);
    // mux2v for R,I
    wire [31:0] B;
    wire [31:0] outSign;
    assign outSign[15:0] = inst[15:0];
    assign outSign[31:16] = {16{inst[15]}};
	  assign branch = {outSign[29:0],2'b00};
    assign luiData = {inst[15:0],16'h0000};
    mux2v  #(32) m2(B,rtData,outSign,alu_src2);
    //assign A = rsData[31:0];
    //alu2 that compute the data
    wire zero,overflow,negative;
    wire [2:0] alu_op;
    wire [31:0] mainAluOut;
    alu32 alu3(mainAluOut, overflow, zero, negative,rsData,B, alu_op);
    /* add other modules */
    wire processedNeg;
    xor xo1(processedNeg,negative,overflow);
	  assign negslt = {31'h00000000,processedNeg};
    wire [31:0] sltout;
    mux2v #(32) sltmux(sltout,mainAluOut,negslt,slt);


    // this is mips decoder
    data_mem mem(data_out, mainAluOut, rtData, word_we, byte_we, clock, reset);
    mux4v #(8) bytemux(byte_out,data_out[7:0],data_out[15:8],data_out[23:16],data_out[31:24],mainAluOut[1:0]);
    assign byteToWord = {24'b0,byte_out};
    wire [31:0] mem_out;
    mux2v #(32) muxmem1(mem_out,data_out,byteToWord,byte_load);
    wire [31:0] writeToAddm;
    mux2v #(32) muxmem2(writeToAddm,sltout,mem_out,mem_read);
    // wire for addm
    wire [31:0] writeToRd,RAddm;
    wire useless21,useless22,useless23;
    alu32 alu4(RAddm,useless21,useless22,useless23,rtData,writeToAddm,3'b010);
    mux2v #(32) muxmem3(writeToRd,writeToAddm,RAddm,addm);
    //
    mux2v #(32) muxRd(rdData,writeToRd,luiData,lui);
    wire [5:0] funct;
    assign funct[5:0] = inst[5:0];
    wire [5:0] opcode;
    assign opcode[5:0] = inst[31:26];
    mips_decode md(alu_op, writeenable, rd_src, alu_src2, except, control_type,mem_read,word_we,byte_we, byte_load,lui,slt,addm,opcode, funct,zero);




    /* add other modules */

endmodule // full_machine
