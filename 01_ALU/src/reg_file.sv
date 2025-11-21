/******************************* reg_file.sv *******************************
 
	Ashley Guillard and Gene Mary Cheruvathur
	EE 469 Sp 24: Professor Hussein
	April 5, 2024
	Lab 1: 16x32 Register File

*/

//This module is created for Lab 1 Task 2, where we design a 16x32
//register file with 2 asynchronous read ports and 1 synchronous 
//write port. The inputs are the write and two read addresses,
//the write data and if write is enabled. The outputs are the data
//at the specified read addresses.
//
//Inputs: clk, wr_en, write_data, write_addr, read_addr1, read_addr2
//Outputs: read_data1, read_data2
module reg_file(clk, wr_en, write_data, write_addr, read_addr1,
							read_addr2, read_data1, read_data2);
	input logic clk, wr_en;
	input logic [31:0] write_data;
	input logic [3:0] write_addr; 
	input logic [3:0]	read_addr1, read_addr2;
	output logic [31:0] read_data1, read_data2;
	
	//16x32 registers holding data as memory
	logic [15:0][31:0] memory;
	
	//writes data to specified address on memory at positive edge of
	//clock cycles (synchronous)
	always_ff @(posedge clk) begin
		//only write if wr_en is true
		if (wr_en) begin
			memory[write_addr] <= write_data;
		end
	end
	
	//gives the data immediately when both read data is specified (asynch)
	assign read_data1 = memory[read_addr1];
	assign read_data2 = memory[read_addr2];
endmodule
