/******************************* alu.sv *******************************
 
	Ashley Guillard and Gene Mary Cheruvathur
	EE 469 Sp 24: Professor Hussein
	April 5, 2024
	Lab 1: alu (Arithmetic Logic Unit)

*/

// This module holds the ALU for lab 1 Task 3 which operates on two 32-bit inputs. 
// This ALU is able to change operations based on the 2-bit "ALUControl" input. The 
// possible operations are: Addition (00), Subtraction (01), AND (10), as well as 
// OR (11). Based on the given input, this module will output the correct result of 
// the selected operation. This module additionally outputs flags (within the "ALUFlags"
// variable) when the result is negative (ALUFlags[3]) and result is zero ([2]). When 
// adding or subtracting, the ALUFlags[1] and ALUFlags[0] will show whether the adder
// produced a carry out or experianced an overflow, respectivly. 
//
// Inputs: a, b, ALUControl
// Outputs: Result, ALUFlags
module alu (

	// Inputs a and b (32-bit)
	input logic [31:0] a, b,
	
	// Controls the operation
	input logic [1:0] ALUControl,
	
	// Output result from operation
	output logic [31:0] Result,
	
	// ALU flags: 
	// [0] = Adder results in overflow
	// [1] = Adder produced a carry out
	// [2] = Result is 0
	// [3] = Result is negative
	output logic [3:0] ALUFlags
	);
	
	// Results from each operation
	logic [31:0] sum, AND, OR, b_new;
	
	// Cout for adder
	logic cout;
	
	// add/sub b value MUX
	always_comb begin
		if (ALUControl[0]) b_new = ~b; // If subtracting, use ~b
		else b_new = b;                // If adding, use b
	end
	
	// Instantiate add module
	// Uses Full Adders to add each individual bits together. Produces a Cout value. 
	adder #(.N(32)) adding (.a, .b(b_new), .cin(ALUControl[0]), .result(sum), .cout0(cout));
	
	// Store result of ANDing
	assign AND = a & b;
	
	// Store result from ORing
	assign OR = a | b;
	
	// Ending result MUX
	always_comb begin
		case(ALUControl)
			2'b10: Result = AND;
			2'b11: Result = OR;
			default: Result = sum;
		endcase
	end
	
	// ALU Flags output circuit
	assign ALUFlags[0] = ~( (ALUControl[0]) ^ (a[31]) ^ (b[31]) ) & ( (a[31]) ^ (sum[31]) ) & ~( ALUControl[1] );
	assign ALUFlags[1] = ~ALUControl[1] & cout;
	assign ALUFlags[2] = (Result == 0);
	assign ALUFlags[3] = Result[31];
	
endmodule 