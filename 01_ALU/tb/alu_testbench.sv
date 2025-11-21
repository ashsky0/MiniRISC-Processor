/******************************* alu._testbenchsv *******************************
 
	Ashley Guillard and Gene Mary Cheruvathur
	EE 469 Sp 24: Professor Hussein
	April 5, 2024
	Lab 1: ALU (Arithmetic Logic Unit) Testbench

*/

// This is the testbench module for the ALU module in Lab 1 Task 3. 
// This testbench uses the file "alu.tv" (test vector file). Please
// change the file path to your file path if you wish to test it. A
// text version has been provided under the name "alu_text.pdf" for
// easier viewing. The test vectors covers various inputs of the flags, 
// ALUControl, and inputs. 
module alu_testbench();
	
	logic [31:0] a, b, Result, Result_tv;
	logic [1:0] ALUControl;
	logic [3:0] ALUFlags, ALUFlags_tv;
	logic clk;
	logic [103:0] testvectors [1000:0];
	
	// Instantiate DUT (Device Under Test)
	alu dut (.a, .b, .ALUControl, .Result, .ALUFlags);
	
	// Clock Setup
	parameter clk_period = 10;
		
	initial begin
		clk <= 0;
		forever #(clk_period) clk <= ~clk;			
	end //initial
	
	// Tests the truth table from the lab specifiations
	initial begin
		
		// Read file data
		$readmemh("U:/Projects for EE 469/Lab 1/alu.tv", testvectors);
		
		for(int i = 0; i < 16; i = i + 1) begin
		
			// Sort the information from the file to the corresponding variables
			{ALUControl, a, b, Result_tv, ALUFlags_tv} <= testvectors[i];
			
			// Check that the results match
			assert(Result == Result_tv) $display ("Result is correct");
			else $error ("Incorrect results");
			
			// Check that the ALUFlags match
			assert(ALUFlags == ALUFlags_tv) $display ("ALUFlags are correct");
			else $error ("Incorrect ALUFlags");
			
			@(posedge clk); // Wait 1 clock cycle before repeating
		
		end //for loop
		
		$stop; // End waveform
		
	end //initial

endmodule //alu_testbench