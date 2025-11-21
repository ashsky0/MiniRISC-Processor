/******************************* adder_testbench.sv *******************************
 
	Ashley Guillard and Gene Mary Cheruvathur
	EE 469 Sp 24: Professor Hussein
	April 5, 2024
	Lab 1: Adder Module Testbench

*/

//This is the testbench module for the adder module in Lab 1 Task 2.
//This testbench tests various 4-bit input values to ensure that the 
//module reacts correctly with and without a carry in bit, overflow,
//and other scenarios. 
module adder_testbench();
	
	parameter N = 4;
	logic [N-1:0] a, b, result;
	logic cin, cout0;
	
	// Instantiate DUT (Device Under Test)
	adder #(.N(N)) dut (.a, .b, .cin, .result, .cout0);
	
	initial begin
		
		// Without carry in
		cin <= 0; 
		a <= 10; b = 10; #10; // 10 + 10 = 20 (overflow)
		a <= 6; b = 2; #10;   // 6 + 2 = 8 
		a <= 7; b = 9; #10;   // 7 + 9 = 16 (overflow)
		a <= 12; b = 0; #10;  // 12 + 0 = 12 
		
		// With carry in
		cin <= 1;
		a <= 10; b = 10; #10; // 1 + 10 + 10 = 21 (overflow)
		a <= 6; b = 2; #10;   // 1 + 6 + 2 = 9 
		a <= 7; b = 9; #10;   // 1 + 7 + 9 = 17 (overflow)
		a <= 12; b = 0; #10;  // 1 + 12 + 0 = 13 
		
	end

endmodule 