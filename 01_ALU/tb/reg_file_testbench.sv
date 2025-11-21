/******************************* reg_file_testbench.sv *******************************
 
	Ashley Guillard and Gene Mary Cheruvathur
	EE 469 Sp 24: Professor Hussein
	April 5, 2024
	Lab 1: 16x32 Register File Testbench

*/

//This is the testbench module for the reg_file for Lab 1 Task 2.
//This testbench tests out the 3 specified test cases, which is if
//the writing to the reg file is synchronous, reading from 2 address
//is asynchronous, and if the read data updates immediately when the 
//data at the next clock-cycle-for-writing is updated.
module reg_file_testbench();
	logic clk, wr_en;
	logic [31:0] write_data;
	logic [3:0] write_addr; 
	logic [3:0]	read_addr1, read_addr2;
	logic [31:0] read_data1, read_data2;
	
	//instantiates reg_file
	reg_file dut(.clk, .wr_en, .write_data, .write_addr, .read_addr1,
							.read_addr2, .read_data1, .read_data2);
	
	//clock
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period/2) clk <= ~clk;
	end
	
	//starts testing the 3 important cases
	initial begin
		//testing if the write only happens in on posedge of clock while wr_en = 1 (synch)
		write_data <= 32'd56; write_addr <= 4'd8; wr_en <= 0; @(posedge clk); 
											#20; //add a delay to enable write during a clock cycle
																wr_en <= 1; @(posedge clk);
																				@(posedge clk);
																
		//testing read address at the same clock cycle write (asynch)
		//read port 1
		write_data <= 32'd9; write_addr <= 4'd10;					@(posedge clk);
											#20; //add a delay to read data during a clock cycle
		read_addr1 <= 4'd10; 
		//read port 2
		write_data <= 32'd2; write_addr <= 4'd14;					@(posedge clk);
											#20; //add a delay to read data during a clock cycle
		read_addr2 <= 4'd14; 
																				@(posedge clk);
		
		//testing the the read addresses immediate updates when data written
		read_addr1 <= 4'd3; read_addr2 <= 4'd8; 					@(posedge clk);
		write_data <= 32'd5; write_addr <= 4'd3;					@(posedge clk);
		write_data <= 32'd15; write_addr <= 4'd8;					@(posedge clk);
																				@(posedge clk); 				
		$stop;
	end
endmodule
