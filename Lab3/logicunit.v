// 00 -> AND, 01 -> OR, 10 -> NOR, 11 -> XOR
module logicunit(out, A, B, control);
    output      out;
    input       A, B;
    input [1:0] control;
	wire aw, ow,nw,xw;
	and a1(aw,A,B);
	or o1(ow,A,B);
	nor no1(nw,A,B);
	xor xo1(xw,A,B);
	
	mux4 mu4(out,aw,ow,nw,xw,control);	
	
endmodule // logicunit
