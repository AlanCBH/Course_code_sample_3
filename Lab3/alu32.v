//implement your 32-bit ALU
module alu32(out, overflow, zero, negative, A, B, control);
    output [31:0] out;
    output        overflow, zero, negative;
    input  [31:0] A, B;
    input   [2:0] control;
	wire cout0,cout1,cout2,cout3,cout4,cout5,cout6,cout7,cout8,cout9,cout10,cout11,cout12,cout13,cout14,cout15,cout16,cout17,cout18,cout19,cout20,cout21,cout22,cout23,cout24,cout25,cout26,cout27,cout28,cout29,cout30,cout31,z1;
	alu1 al0(out[0],cout0,A[0],B[0],control[0],control);
	alu1 al1(out[1],cout1,A[1],B[1],cout0,control);
    alu1 al2(out[2],cout2,A[2],B[2],cout1,control);
    alu1 al3(out[3],cout3,A[3],B[3],cout2,control);
    alu1 al4(out[4],cout4,A[4],B[4],cout3,control);
    alu1 al5(out[5],cout5,A[5],B[5],cout4,control);
    alu1 al6(out[6],cout6,A[6],B[6],cout5,control);
    alu1 al7(out[7],cout7,A[7],B[7],cout6,control);
    alu1 al8(out[8],cout8,A[8],B[8],cout7,control);
    alu1 al9(out[9],cout9,A[9],B[9],cout8,control);
    alu1 al10(out[10],cout10,A[10],B[10],cout9,control);
    alu1 al11(out[11],cout11,A[11],B[11],cout10,control);
    alu1 al12(out[12],cout12,A[12],B[12],cout11,control);
    alu1 al13(out[13],cout13,A[13],B[13],cout12,control);
    alu1 al14(out[14],cout14,A[14],B[14],cout13,control);
    alu1 al15(out[15],cout15,A[15],B[15],cout14,control);
    alu1 al16(out[16],cout16,A[16],B[16],cout15,control);
    alu1 al17(out[17],cout17,A[17],B[17],cout16,control);
    alu1 al18(out[18],cout18,A[18],B[18],cout17,control);
    alu1 al19(out[19],cout19,A[19],B[19],cout18,control);
    alu1 al20(out[20],cout20,A[20],B[20],cout19,control);
    alu1 al21(out[21],cout21,A[21],B[21],cout20,control);
    alu1 al22(out[22],cout22,A[22],B[22],cout21,control);
    alu1 al23(out[23],cout23,A[23],B[23],cout22,control);
    alu1 al24(out[24],cout24,A[24],B[24],cout23,control);
    alu1 al25(out[25],cout25,A[25],B[25],cout24,control);
    alu1 al26(out[26],cout26,A[26],B[26],cout25,control);
    alu1 al27(out[27],cout27,A[27],B[27],cout26,control);
    alu1 al28(out[28],cout28,A[28],B[28],cout27,control);
    alu1 al29(out[29],cout29,A[29],B[29],cout28,control);
    alu1 al30(out[30],cout30,A[30],B[30],cout29,control);
    alu1 al31(out[31],cout31,A[31],B[31],cout30,control);

	or o1(z1,out[0],out[1],out[2],out[3],out[4],out[5],out[6],out[7],out[8],out[9],out[10],out[11],out[12],out[13],out[14],out[15],out[16],out[17],out[18],out[19],out[20],out[21],out[22],out[23],out[24],out[25],out[26],out[27],out[28],out[29],out[30],out[31]);
	not n1(zero,z1);
	assign negative = out[31];
	xor x1(overflow,cout31,cout30);

endmodule // alu32
