`define STATUS_REGISTER 5'd12
`define CAUSE_REGISTER  5'd13
`define EPC_REGISTER    5'd14

module cp0(rd_data, EPC, TakenInterrupt,
           wr_data, regnum, next_pc,
           MTC0, ERET, TimerInterrupt, clock, reset);
    output [31:0] rd_data;
    output [29:0] EPC;
    output        TakenInterrupt;
    input  [31:0] wr_data;
    input   [4:0] regnum;
    input  [29:0] next_pc;
    input         MTC0, ERET, TimerInterrupt, clock, reset;

    // your Verilog for coprocessor 0 goes here
    wire [31:0] CAUSE_REGISTER,STATUS_REGISTER,USER_STATUS,decoderOut;
    wire [29:0] muxOut;
    wire exception_level;
    assign STATUS_REGISTER[31:16] = 16'b0;
    assign STATUS_REGISTER[15:8] = USER_STATUS[15:8];
    assign STATUS_REGISTER[7:2] = 6'b0;
    assign STATUS_REGISTER[1] = exception_level;
    assign STATUS_REGISTER[0] = USER_STATUS[0];
    assign CAUSE_REGISTER[31:16] = 16'b0;
    assign CAUSE_REGISTER[14:0] = 15'b0;
    assign CAUSE_REGISTER[15] = TimerInterrupt;
    wire w1,w2;
    assign w1 = CAUSE_REGISTER[15]& STATUS_REGISTER[15];
    assign w2 = STATUS_REGISTER[0] & ~(STATUS_REGISTER[1]);
    assign TakenInterrupt = w1 & w2;
    decoder32 d1(decoderOut,regnum,MTC0);
    register #(32) user_reg(USER_STATUS,wr_data,clock,decoderOut[12],reset);
    mux2v #(30) m1(muxOut,wr_data[31:2],next_pc,TakenInterrupt);
    register #(30) EPC_reg(EPC,muxOut,clock,decoderOut[14]|TakenInterrupt,reset);
    dffe dffe1(exception_level,1'b1,clock,TakenInterrupt,reset|ERET);
    mux32v mux32(rd_data, , , , , , , , , , , , , STATUS_REGISTER, CAUSE_REGISTER, {EPC,2'b00}, ,
                      , , , , , , , , , , , , , , , , regnum);






endmodule
