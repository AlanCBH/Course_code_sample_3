// output is A (when control == 0) or B (when control == 1)
module mux2(out, A, B, control);
    output out;
    input  A, B;
    input  control;
    wire   wA, wB, not_control;
         
    not n1(not_control, control);
    and a1(wA, A, not_control);
    and a2(wB, B, control);
    or  o1(out, wA, wB);
endmodule // mux2

// output is A (when control == 00) or B (when control == 01) or
//           C (when control == 10) or D (when control == 11)
module mux4(out, A, B, C, D, control);
    output      out;
    input       A, B, C, D;
    input [1:0] control;
	wire not_control1, not_control0,wa,wb,wc,wd,up,below,upout,belowout;
	not n1(not_control1,control[1]);
	not n2(not_control0,control[0]);
	and a1(wa,A,not_control0);
	and a2(wb,B,control[0]);
	and a3(wc,C,not_control0);
	and a4(wd,D,control[0]);
	or o1(up,wa,wb);
	or o2(below,wc,wd);
	and a5(upout,up,not_control1);
	and a6(belowout,below,control[1]);
	or o3(out,upout,belowout);

endmodule // mux4
