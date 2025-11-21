/******************************* FullAdder_testbench.sv *******************************
 
	Ashley Guillard and Gene Mary Cheruvathur
	EE 469 Sp 24: Professor Hussein
	April 5, 2024
	Lab 1: Full Adder Testbench

*/

// This module is the testbench for the Full Adder module. This 
// testbench tests all possible input values for the module. 
module FullAdder_testbench();

	logic A, B, cin, sum, cout;
	
	// Instantiate DUT (Device Under Test)
	FullAdder dut (.A, .B, .cin, .sum, .cout);
	
	// Tests all possible values
	initial begin
		
		A <= 0; B <= 0; cin <= 0; #10;
		A <= 0; B <= 0; cin <= 1; #10;
		A <= 0; B <= 1; cin <= 0; #10;
		A <= 0; B <= 1; cin <= 1; #10;
		A <= 1; B <= 0; cin <= 0; #10;
		A <= 1; B <= 0; cin <= 1; #10;
		A <= 1; B <= 1; cin <= 0; #10;
		A <= 1; B <= 1; cin <= 1; #10;
	
	end
	
endmodule 