/******************************* adder.sv *******************************
 
	Ashley Guillard and Gene Mary Cheruvathur
	EE 469 Sp 24: Professor Hussein
	April 5, 2024
	Lab 1: Adder Module

*/

// Adds two N-bit numbers and produces the output and carry out. 
// Generates an instantiations of the FullAdder module for each 
// of the N bits. The initial carry in is used for the first 
// Full Adder. 
//
// Inputs: a, b, cin (initial carry in)
// Outputs: result, cout0 (final carry out)
module adder #(parameter N = 3) (
	input logic [N-1:0] a, b, 
	input logic cin,
	output logic [N-1:0] result,
	output logic cout0
	);
	
	// cin and cout
	wire [N-1:0]cout;
	assign cout0 = cout[N-1];
	
	genvar i;
	generate 
		for(i=0; i<N; i++) begin : Adders
			if (i==0) FullAdder FA0 (.A(a[i]), .B(b[i]), .cin(cin), .sum(result[i]), .cout(cout[i]));
			else FullAdder FA (.A(a[i]), .B(b[i]), .cin(cout[i-1]), .sum(result[i]), .cout(cout[i]));
		end
	endgenerate
	
endmodule 