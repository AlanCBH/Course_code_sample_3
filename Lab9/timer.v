module timer(TimerInterrupt, cycle, TimerAddress,
             data, address, MemRead, MemWrite, clock, reset);
    output        TimerInterrupt;
    output [31:0] cycle;
    output        TimerAddress;
    input  [31:0] data, address;
    input         MemRead, MemWrite, clock, reset;

    // complete the timer circuit here

    // HINT: make your interrupt cycle register reset to 32'hffffffff
    //       (using the reset_value parameter)
    //       to prevent an interrupt being raised the very first cycle
    wire [31:0] ccout,ccinput,icout;
    wire useless1,useless2;
    wire TimerWrite,TimerRead,Acknowledge;
    wire Ilreset,Ilenable;
    wire w1,w2,w3,w4;
    register #(32,32'h0) cycleCounter(ccout,ccinput,clock,1'b1,reset);
    alu32 alu1(ccinput,useless1,useless2,`ALU_ADD,32'b1,ccout);
    register #(32,32'hffffffff) interruptCounter(icout,data,clock,TimerWrite,reset);
    tristate #(32) t1(cycle,ccout,TimerRead);
    assign Ilreset = reset | Acknowledge;
    assign Ilenable = (ccout == icout);
    dffe d1(TimerInterrupt,1'b1,clock,Ilenable,Ilreset);

    assign w1 = 32'hffff001c == address;
    assign w2 = 32'hffff006c == address;
    assign TimerAddress = w1 | w2;
    assign Acknowledge = w2 & MemWrite;
    assign TimerRead = w1 & MemRead;
    assign TimerWrite = w1 & MemWrite;















endmodule
