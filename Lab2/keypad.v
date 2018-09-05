module keypad(valid, number, a, b, c, d, e, f, g);
   output 	valid;
   output [3:0] number;
   input 	a, b, c, d, e, f, g;
	wire w1,w2,w3,w4,w5,w6,w7,w8,w9,w0,wn0,wn1,wn2,wn3,wn4,wn5,cv,cv0,cv1,cv2,cv3,cv4,cv5,cv6;
	// valid
	or vo0(cv,w0,w9);
	or vo1(cv0,w1,w2);
	or vo2(cv1,w3,w4);
	or vo3(cv2,w5,w6);
	or vo4(cv3,w7,w8);
	
	or vo5(cv4,cv1,cv0);
	or vo6(cv5,cv2,cv3);
	or vo7(cv6,cv4,cv5);
	or vo8(valid,cv6,cv);
	
	and a0(w0,b,g);
	
	//number	
		
	//number[3]
	and a1(w8,b,f);
	and a2(w9,c,f);
	or o1(number[3],w8,w9);
	
	//number[2]
	and a3(w4,a,e);
	and a4(w5,b,e);
	and a5(w6,c,e);
	and a6(w7,a,f);
	or o2(wn0,w4,w5);
	or o3(wn1,w6,w7);
	or o4(number[2],wn0,wn1);
	
	//number[1]
	and a7(w2,b,d);
	and a8(w3,c,d);
	or o5(wn2,w2,w3);
	or o6(number[1],wn1,wn2);
	
	//number[0]
	and a9(w1,a,d);
	or o7(wn3,w1,w3);
	or o8(wn4,w5,w7);
	or o9(wn5,wn4,wn3);
	or o0(number[0],wn5,w9);

	

	




endmodule // keypad
