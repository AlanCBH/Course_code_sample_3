module logicunit_test;
    // exhaustively test your logic unit implementation by adapting mux4_tb.v
	//reg A = 0, B = 0; 
   	//reg out = 0;
 	reg A = 0;
    always #1 A = !A;
    reg B = 0;
    always #2 B = !B;
reg [1:0] control = 0;
	 initial begin

      $dumpfile("logicunit.vcd");  
      $dumpvars(0,logicunit_test);
	   # 10  
	/*A = 1; B = 1;	               // 1,1,and
      # 10
	A = 0; B = 1;                // 1,0,and
      # 10
	A = 0; B = 0;                // 0,0,and
      # 10
	A = 1; B = 1;                
	control = 1;                // 1,1 or
      # 10
	A = 1; B = 0;                // 1,0,or
      # 10
	A = 0; B = 0;                // 0,0,or
      # 10
	A = 0; B = 0;				//o,o,nor
	control = 2;
	  # 10
      $finish;  */            // end the simulation
	  # 4 control = 1; // wait 16 time units (why 16?) and then set it to 1
        # 4 control = 2; // wait 16 time units and then set it to 2
        # 4 control = 3; // wait 16 time units and then set it to 3
        # 4 $finish; // wait 16 time units and then end the simulation
   end                      
   wire       out;
	logicunit m4(out,A,B,control);
 initial
     $monitor("At time %t, out = %d",$time,out);
endmodule // logicunit_test
