/******************************* FullAdder.sv *******************************
 
	Ashley Guillard and Gene Mary Cheruvathur
	EE 469 Sp 24: Professor Hussein
	April 5, 2024
	Lab 1: Full Adder

*/

// Adds three 1-bit inputs, A, B, and cin. Produces the sum and carry out.
//
// Inputs: A, B, cin (carry in)
// Outputs: sum, cout (carry out)
module FullAdder (A, B, cin, sum, cout);

	input logic A, B, cin;
	output logic sum, cout;
	
	assign sum = A ^ B ^ cin;
	assign cout = A&B | cin & (A^B);
	
endmodule 