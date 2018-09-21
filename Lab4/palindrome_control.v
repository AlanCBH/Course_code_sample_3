
module palindrome_control(palindrome, done, select, load, go, a_ne_b, front_ge_back, clock, reset);
	output load, select, palindrome, done;
	input go, a_ne_b, front_ge_back;
	input clock, reset;
	wire garbage,start,start_next,garbage_next,palindrome_next,done_next,process,process_next,Done;

	assign garbage_next = (garbage & ~go) | reset;
	assign start_next = (garbage & go) | (Done & go) | (start & go);
	assign process_next = (start & ~go) | (process & ~a_ne_b & ~front_ge_back);
	assign done_next = (process & a_ne_b) | (process & front_ge_back) | (Done & ~go);

	dffe fsGarbage(garbage, garbage_next, clock, 1'b1, 1'b0);
	dffe fsStart(start, start_next, clock, 1'b1, 1'b0);
	dffe fsProcess(process, process_next, clock, 1'b1, 1'b0);
	dffe fsDone(Done,done_next,clock,1'b1,1'b0);
	assign load = process;
	assign select = process;	
	assign palindrome = (front_ge_back);
	assign done = Done;
	
		

	

	
	//palindrome = ~a_ne_b & ~reset & clock;
	//done = (a_ne_b | front_ge_back) & ~reset & ~go & clock;
	
//	load = (reset | (go & ~done)) & clock;
//	select = ((go & ~done) | reset) & clock;
		
	/*not n1(w1,reset);
	not n2(w2,a_ne_b);
	and a1(w3,w1,w2);
	and a2(palindrome,w3,clock);	

	or o1(w3,a_ne_b,front_ge_back);
	and a3(w8,w1,w3);
	not n3(w9,go);
	and a4(done,w8,w9);

	not n4(w4,done);
	and a5(w5,go,clock);
	and a6(w6,w4,w5);
	or o2(load,reset,w6);
	
	and a6(w7,go,w4);
	or o3(select, reset,w7);
	or o3(select,w6,reset);*/
	
	
	 
	
	
	
endmodule // palindrome_control 
