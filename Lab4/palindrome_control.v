
module palindrome_control(palindrome, done, select, load, go, a_ne_b, front_ge_back, clock, reset);
	output load, select, palindrome, done;
	input go, a_ne_b, front_ge_back;
	input clock, reset;
/*	wire garbage,start,start_next,garbage_next,palindrome_next,done_next,process,process_next,Done;

	assign garbage_next = (garbage & ~go)  | reset ;
	assign start_next = ((garbage & go) | (Done & go) | (start & go) )& ~reset;
	assign process_next = ((start & ~go) | (process & ~a_ne_b & ~front_ge_back) ) & ~Done;
	assign done_next = (process & a_ne_b)|(process & front_ge_back) | (Done & ~go) & ~reset & ~start;
	assign select_next = process & load & ~start_next &~Done ;
	assign load_next = (process|start_next)&~Done;
	dffe fsGarbage(garbage, garbage_next, clock, 1'b1, 1'b0);
	dffe fsStart(start, start_next, clock, 1'b1, 1'b0);
	dffe fsProcess(process, process_next, clock, 1'b1, 1'b0);
	dffe fsDone(Done,done_next,clock,1'b1,1'b0);
	dffe fsSelect(select,select_next,clock,1'b1,1'b0);
	dffe fsLoad(load,load_next,clock,1'b1,1'b0);
	assign palindrome = Done & ~a_ne_b & ~reset;
	assign done = Done & ~reset;*/
	
	

	
wire garbage,start,start_next,garbage_next,palindrome_next,rdone_next,process,process_next,rDone,pdone_next,pDone;
assign garbage_next = (garbage & ~go) | reset;
assign start_next = ((garbage & go) | (rDone & go) | (start & go) | (pDone & go) ) & ~reset;
assign process_next = ((start & ~go) | (process & ~front_ge_back & ~a_ne_b) ) & ~reset;
assign pdone_next = (process & a_ne_b) | (pDone & ~go) &~reset;
assign rdone_next = (process & front_ge_back & ~a_ne_b) | (rDone & ~go) & ~reset;
assign select = (process);
assign load = (process|start);
//assign palindrome_next = ~(pDone & ~rDone);	
	
dffe fsGarbage(garbage, garbage_next, clock, 1'b1, 1'b0);
	dffe fsStart(start, start_next, clock, 1'b1, 1'b0);
	dffe fsProcess(process, process_next, clock, 1'b1, 1'b0);
	dffe fsrDone(rDone,rdone_next,clock,1'b1,1'b0);
	dffe fspDone(pDone,pdone_next,clock,1'b1,1'b0);
	//dffe fsSelect(select,select_next,clock,1'b1,1'b0);
	//dffe fsLoad(load,load_next,clock,1'b1,1'b0);	
	//dffe fspalindrome(palindrome, palindrome_next,clock,1'b1,1'b0);	
	//assign palindrome = ~(rdone_next & pDone) & rDone;
	assign done = rDone | pDone;
	assign palindrome = rDone;

	

	
	
	 
	
	
	
endmodule // palindrome_control 
