/******************************* arm.sv *******************************
 
	Ashley Guillard and Gene Mary Cheruvathur
	EE 469 Sp 24: Professor Hussein
	May 3, 2024
	Lab 3: arm (pipelined)

*/

/* arm is the spotlight of the show and contains the bulk of the datapath and control logic. This module is split into two parts, the datapath and control. 
*/

// clk - system clock
// rst - system reset
// Instr - incoming 32 bit instruction from imem, contains opcode, condition, addresses and or immediates
// ReadData - data read out of the dmem
// WriteData - data to be written to the dmem
// MemWrite - write enable to allowed WriteData to overwrite an existing dmem word
// PC - the current program count value, goes to imem to fetch instruciton
// ALUResult - result of the ALU operation, sent as address to the dmem

module arm (
    input  logic        clk, rst,
    input  logic [31:0] Instr,
    input  logic [31:0] ReadData,
    output logic [31:0] WriteData, 
    output logic [31:0] PC, ALUResult,
    output logic        MemWrite
);

    // datapath buses and signals
    logic [31:0] PCF, PCPrime, PCPlus4F, PCPlus8D; // pc signals
	 logic [31:0] InstrF, InstrD;                   // instructions
	 logic [ 3:0] CondE;                            // condition from instructions
    logic [ 3:0] RA1D, RA2D, RA1E, RA2E;           // regfile input addresses
    logic [31:0] RD1, RD2, RD1D, RD2D, RD1E, RD2E; // raw regfile outputs
	 logic [31:0] temp1, temp2;                     // intermediate between regfile and alu inputs
	 logic [31:0] ExtImmD, ExtImmE;                 // immediate values
	 logic [31:0] SrcAE, SrcBE;                     // alu inputs
    logic [ 3:0] ALUFlags;                         // alu combinational flag outputs
    logic [31:0] ALUResultE, ALUOutM, ALUOutW;     // alu result registers
	 logic [ 3:0] WA3E, WA3M, WA3W;                 // regfile write addresses
	 logic [31:0] WriteDataE, WriteDataM;           // data memory write data
	 logic [31:0] ReadDataM, ReadDataW;             // data memory read data
    logic [31:0] ResultW;                          // computed or fetched value to be written into regfile or pc
	 logic [ 3:0] FlagsPrime, FlagsRegE;            // stores the flags from the most recent SUBS command
	 
    // control signals
    logic       PCSrcD, PCSrcE, PCSrcM, PCSrcW;             // pc source control 
	 logic       MemtoRegD, MemtoRegE, MemtoRegM, MemtoRegW; // memory to register control 
	 logic       ALUSrcD, ALUSrcE;                           // alu source control 
	 logic       RegWriteD, RegWriteE, RegWriteM, RegWriteW; // register write control 
	 logic       CondExE;                                    // condition control
	 logic       MemWriteD, MemWriteE, MemWriteM;            // memory write control
	 logic [1:0] ALUControlD, ALUControlE;                   // alu control 
	 logic       BranchD, BranchE;                           // branch control
	 logic [1:0] FlagWD, FlagWE;                             // writing flags control
	 logic [1:0] FlagsWriteE;                                // writing flags control (after conditioning)
	 logic [1:0] RegSrcD;                                    // register source control
	 logic [1:0] ImmSrcD;                                    // immediate source control
	 
	 // hazard controls
	 logic       Match_1E_M, Match_2E_M;   // regfile read and next write addresses match
	 logic       Match_1E_W, Match_2E_W;   // regfile read and write addresses match
	 logic [1:0] ForwardAE, ForwardBE;     // where to forward data from
	 logic       Match_12D_E;              // regfile read and data memory write addresses match 
	 logic       Idrstall, StallF, StallD; // Stalls incoming instructions 
	 logic       FlushF, FlushD, FlushE;   // flush instructions
	 logic       BranchTakenE;             // ON when a branch is taken
	 
	 
	 
	 
	 /////////////////////
	 // Module Outputs  //
	 /////////////////////
	 
	 assign PC        = PCF;        // output pc for instructions memory 
	 assign ALUResult = ALUOutM;    // output alu result for data memory address
	 assign WriteData = WriteDataM; // output write data for data memory 
	 assign MemWrite  = MemWriteM;  // output enable for data memory write
	 
	 
	 
	 

    /* The datapath consists of a PC as well as a series of muxes to make decisions about which data words to pass forward and operate on. It is 
    ** noticeably missing the register file and alu, which you will fill in using the modules made in lab 1. To correctly match up signals to the 
    ** ports of the register file and alu take some time to study and understand the logic and flow of the datapath.
    */
    //-------------------------------------------------------------------------------
    //                                      DATAPATH
    //-------------------------------------------------------------------------------


	 
	 /////////////////////
	 //      Fetch      //
	 /////////////////////
	 
	 // priority mux, used to determine if a branch was taken, if not either default or newly computed value
	 always_comb begin
		if (BranchTakenE)  PCPrime = ALUResultE;
		else if (PCSrcW) PCPrime = ResultW;
		else               PCPrime = PCPlus4F;
	 end
    assign PCPlus4F = PCF + 'd4;                     // default value to access next instruction
    assign PCPlus8D = PCPlus4F;                      // value read when reading from reg[15]

    // update the PC (unless stalled), at rst initialize to 0
    always_ff @(posedge clk) begin
        if (rst) PCF <= '0; 
        else if (~StallF) PCF <= PCPrime;
    end
	
	 // fetch instructions unless reset
	 assign InstrF = (rst | FlushF) ? '0 : Instr;
	
	
	
	 /////////////////////
	 //     Decode      //
	 /////////////////////
	 
	 
	 // update instructions unless stalled/flushed
	 always_ff @(posedge clk) begin
		if (~StallD) InstrD <= InstrF; // Stall
		else if (FlushD) InstrD <= '0; // Flush
	 end
	 
	 // determine the register addresses based on control signals
    // RegSrc[0] is set if doing a branch instruction
    // RefSrc[1] is set when doing memory instructions
    assign RA1D = RegSrcD[0] ? 4'd15        : InstrD[19:16];
    assign RA2D = RegSrcD[1] ? InstrD[15:12] : InstrD[ 3: 0];
	 
	 // Register File (16x32)
    // Stores the data for registers 0 through 15. 
	 // 2 asynchronous read ports and 1 synchronous write port.
    reg_file u_reg_file (
        .clk       (~clk), 
        .wr_en     (RegWriteW),
        .write_data(ResultW),
        .write_addr(WA3W),
        .read_addr1(RA1D), 
        .read_addr2(RA2D),
        .read_data1(RD1),  
        .read_data2(RD2)   
    );
	 
	 // two muxes, put together into an always_comb for clarity
    // determines which set of instruction bits are used for the immediate
    always_comb begin
		  if (FlushD) ExtImmD = '0;
        else if      (ImmSrcD == 'b00) ExtImmD = {{24{InstrD[7]}},InstrD[7:0]};          // 8 bit immediate - reg operations
        else if (ImmSrcD == 'b01) ExtImmD = {20'b0, InstrD[11:0]};                 // 12 bit immediate - mem operations
        else                      ExtImmD = {{6{InstrD[23]}}, InstrD[23:0], 2'b00}; // 24 bit immediate - branch operation
    end
	 
	 // mux to determine if reading from r15 or regfile
	 always_comb begin
			RD1D = (FlushD) ? '0 : ((RA1D == 'd15) ? PCPlus8D : RD1);
			RD2D = (FlushD) ? '0 : ((RA2D == 'd15) ? PCPlus8D : RD2);
	 end
	 
	 
	 
	 /////////////////////
	 //     Execute     //
	 /////////////////////
	 
	 
	 // update execute instructions unless flushed
	 always_ff @(posedge clk) begin
		if(FlushE) begin // Flush
			RD1E <= '0;
			RD2E <= '0;
			WA3E <= '0;
			ExtImmE <= '0;
			RA1E <= '0;
			RA2E <= '0;
		end
		else begin // Update
			RD1E <= RD1D;
			RD2E <= RD2D;
			WA3E <= InstrD[15:12];
			ExtImmE <= ExtImmD;
			RA1E <= RA1D;
			RA2E <= RA2D;
		end
	 end
	 
	 // alu source values and write data
	 assign SrcAE = temp1;
	 assign SrcBE = (ALUSrcE) ? ExtImmE : temp2;
	 assign WriteDataE = temp2; 
	 
	 // muxes to determine forwarding data
	 always_comb begin
		
			case(ForwardAE)
				2'b00: temp1 = RD1E;
				2'b01: temp1 = ResultW;
				2'b10: temp1 = ALUOutM;
				default: temp1 = 'X;
			endcase
			
			case(ForwardBE)
				2'b00: temp2 = RD2E;
				2'b01: temp2 = ResultW;
				2'b10: temp2 = ALUOutM;
				default: temp2 = 'X;
			endcase
		
	 end
	 
	 
	 // ALU (Arethmatic Logic Unit)
    // Preforms addition, subtraction, ANDing, as well as ORing.
	 // Outputs result of the operation and flags (NZCV).
    alu u_alu (
        .a          (SrcAE), 
        .b          (SrcBE),
        .ALUControl (ALUControlE),
        .Result     (ALUResultE),
        .ALUFlags   (ALUFlags)
    );
	 
	 
	 // DFF for storing flags from SUBS command
	 assign FlagsWriteE = {2{CondExE}} & FlagWE;
	 assign FlagsPrime[3:2] = FlagsWriteE[1] ? ALUFlags[3:2] : FlagsRegE[3:2];
	 assign FlagsPrime[1:0] = FlagsWriteE[0] ? ALUFlags[1:0] : FlagsRegE[1:0]; 
	 always_ff @(posedge clk) begin
		if (rst) begin
			FlagsRegE <= '0;
		end
		else begin
			FlagsRegE <= FlagsPrime; 
		end
	 end
	 
	 
	 
	 
	 /////////////////////
	 //     Memory      //
	 /////////////////////
	 
	 
	 // update memory instructions
	 always_ff @(posedge clk) begin
		if (rst) begin 
			ALUOutM    <= '0;
			WriteDataM <= '0;
			WA3M       <= '0;
		end
		else begin
			ALUOutM    <= ALUResultE;
			WriteDataM <= WriteDataE;
			WA3M       <= WA3E;
		end
	 end
	 
	 // read data from dmem file 
	 assign ReadDataM = ReadData;
	 
	 
	 
	 /////////////////////
	 //    WriteBack    //
	 /////////////////////
	 
	 
	 // update writeback instructions
	 always_ff @(posedge clk) begin
		if (rst) begin
			ReadDataW <= '0;
			ALUOutW   <= '0;
			WA3W      <= '0;
		end
		else begin
			ReadDataW <= ReadDataM;
			ALUOutW   <= ALUOutM;
			WA3W      <= WA3M;
		end
	 end
	 
	 // determine the result to run back to PC or the register file based on whether we used a memory instruction
    assign ResultW = MemtoRegW ? ReadDataW : ALUOutW;    // determine whether final writeback result is from dmemory or alu
	 
    
	 

    /* The control conists of a large decoder, which evaluates the top bits of the instruction and produces the control bits 
    ** which become the select bits and write enables of the system. The write enables (RegWrite, MemWrite and PCSrc) are 
    ** especially important because they are representative of your processors current state. 
    */
    //-------------------------------------------------------------------------------
    //                                      CONTROL
    //-------------------------------------------------------------------------------
    
	 
	 
	 /////////////////////
	 //     Decode      //
	 /////////////////////
	 
	 
	 // decode instructions
    always_comb begin
		if (FlushD) begin // Flush
			PCSrcD    = 0; 
         MemtoRegD = 0; // doesn't matter
         MemWriteD = 0; 
         ALUSrcD   = 0;
         RegWriteD = 0;
			BranchD = 0;
			FlagWD = 2'b00;
         RegSrcD   = 'b00;
         ImmSrcD   = 'b00; 
         ALUControlD = 'b00;  // do an add
		
		end
		else begin
        casez (InstrD[27:20])

            // ADD (Imm or Reg)
            8'b00?_0100_? : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we add
                PCSrcD    = 0;
                MemtoRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = InstrD[25]; // may use immediate
                RegWriteD = 1;
					 BranchD = 0;
					 FlagWD = InstrD[20] ? 2'b11 : 2'b00;
                RegSrcD   = 'b00;
                ImmSrcD   = 'b00; 
                ALUControlD = 'b00;
            end

            // SUB (Imm or Reg) OR CMP
            8'b00?_0010_? : begin   // note that we use wildcard "?" in bit 25. That bit decides whether we use immediate or reg, but regardless we sub
                PCSrcD    = 0; 
                MemtoRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = InstrD[25]; // may use immediate
                RegWriteD = 1; 
					 BranchD = 0;
					 FlagWD = InstrD[20] ? 2'b11 : 2'b00; // keep flags (CMP), don't keep flags (SUB)
                RegSrcD   = 'b00;
                ImmSrcD   = 'b00; 
                ALUControlD = 'b01;
            end

            // AND
            8'b000_0000_? : begin
                PCSrcD    = 0; 
                MemtoRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = 0; 
                RegWriteD = 1;
					 BranchD = 0;
					 FlagWD = InstrD[20] ? 2'b10 : 2'b00;
                RegSrcD   = 'b00;
                ImmSrcD   = 'b00;    // doesn't matter
                ALUControlD = 'b10;  
            end

            // ORR
            8'b000_1100_? : begin
                PCSrcD    = 0; 
                MemtoRegD = 0; 
                MemWriteD = 0; 
                ALUSrcD   = 0; 
                RegWriteD = 1;
					 BranchD = 0;
					 FlagWD = InstrD[20] ? 2'b10 : 2'b00;
                RegSrcD   = 'b00;
                ImmSrcD   = 'b00;    // doesn't matter
                ALUControlD = 'b11;
            end

            // LDR
            8'b010_1100_1 : begin
                PCSrcD    = 0; 
                MemtoRegD = 1; 
                MemWriteD = 0; 
                ALUSrcD   = 1;
                RegWriteD = 1;
					 BranchD = 0;
					 FlagWD = 2'b00;
                RegSrcD   = 'b10;    // msb doesn't matter
                ImmSrcD   = 'b01; 
                ALUControlD = 'b00;  // do an add
            end

            // STR
            8'b010_1100_0 : begin
                PCSrcD    = 0; 
                MemtoRegD = 0; // doesn't matter
                MemWriteD = 1; 
                ALUSrcD   = 1;
                RegWriteD = 0;
					 BranchD = 0;
					 FlagWD = 2'b00;
                RegSrcD   = 'b10;    // msb doesn't matter
                ImmSrcD   = 'b01; 
                ALUControlD = 'b00;  // do an add
            end

            // B
            8'b1010_???? : begin
                    PCSrcD    = 0; // Used BranchD instead 
                    MemtoRegD = 0;
                    MemWriteD = 0; 
                    ALUSrcD   = 1;
                    RegWriteD = 0;
						  BranchD = 1;
						  FlagWD = 2'b00;
                    RegSrcD   = 'b01;
                    ImmSrcD   = 'b10; 
                    ALUControlD = 'b00;  // do an add
            end

			default: begin
					PCSrcD    = 0; 
               MemtoRegD = 0; // doesn't matter
               MemWriteD = 0; 
               ALUSrcD   = 0;
               RegWriteD = 0;
					BranchD = 0;
					FlagWD = 2'b00;
               RegSrcD   = 'b00;
               ImmSrcD   = 'b00; 
               ALUControlD = 'b00;  // do an add
			end
        endcase
		end
    end
	 
	 
	 
	 /////////////////////
	 //     Execute     //
	 /////////////////////
	 
	 
	 // update execute controls unless flushed
	 always_ff @(posedge clk) begin
		if(FlushE) begin // Flush
			PCSrcE <= '0;
			RegWriteE <= '0;
			MemtoRegE <= '0;
			MemWriteE <= '0;
			ALUControlE <= '0;
			BranchE <= '0;
			ALUSrcE <= '0;
			FlagWE <= '0;
			CondE <= '1; // Default: OFF
		end
		else begin // Update
			PCSrcE <= PCSrcD;
			RegWriteE <= RegWriteD;
			MemtoRegE <= MemtoRegD;
			MemWriteE <= MemWriteD;
			ALUControlE <= ALUControlD;
			BranchE <= BranchD;
			ALUSrcE <= ALUSrcD;
			FlagWE <= FlagWD;
			CondE <= InstrD[31:28];
		end
	 end
	 
	 
	 // Condition Check
	 always_comb begin
		 
			case (CondE) 
				4'b0000: CondExE = FlagsRegE[2];                                 // EQ (Equal)
				4'b0001: CondExE = ~FlagsRegE[2];                                // NE (Not equal)
				4'b0010: CondExE = FlagsRegE[1];                                 // CS / HS (Carry set / Unsigned higher or same)
				4'b0011: CondExE = ~FlagsRegE[1];                                // CC / LO (Carry clear / Unsigned lower)
				4'b0100: CondExE = FlagsRegE[3];                                 // MI (Minus / Negative)
				4'b0101: CondExE = ~FlagsRegE[3];                                // PL (Plus / Positive pf Zero)
				4'b0110: CondExE = FlagsRegE[0];                                 // VS (Overflow / Overflow set)
				4'b0111: CondExE = ~FlagsRegE[0];                                // VC (No overflow / Overflow clear)
				4'b1000: CondExE = ~FlagsRegE[2] & FlagsRegE[1];                  // HI (Unsigned higher)
				4'b1001: CondExE = FlagsRegE[2] | ~FlagsRegE[1];                  // LS (Unsigned lower or same)
				4'b1010: CondExE = ~(FlagsRegE[3] ^ FlagsRegE[0]);                // GE (Signed greater than or equal)
				4'b1011: CondExE = FlagsRegE[3] ^ FlagsRegE[0];                   // LT (Signed less than)
				4'b1100: CondExE = ~FlagsRegE[2] & ~(FlagsRegE[3] ^ FlagsRegE[0]); // GT (Signed greater than)
				4'b1101: CondExE = FlagsRegE[2] | (FlagsRegE[3] ^ FlagsRegE[0]);   // LE (Signed less than or equal)
				4'b1110: CondExE = 1;                                           // AL / none (Always / unconditional)
				default: CondExE = 0; 
			endcase
			
	 end
	 
	 assign BranchTakenE = (CondExE) ? BranchE : '0;
	 
	 
	 
	 /////////////////////
	 //     Memory      //
	 /////////////////////
	 
	 
	 // update memroy controls
	 always_ff @(posedge clk) begin
		if (rst) begin 
			PCSrcM    <= '0;
			RegWriteM <= '0;
			MemtoRegM <= '0;
			MemWriteM <= '0;
		end
		else begin
			PCSrcM    <= (PCSrcE & CondExE);// | (BranchE & CondExE);
			RegWriteM <= RegWriteE & CondExE;
			MemtoRegM <= MemtoRegE;
			MemWriteM <= MemWriteE & CondExE;
		end
	 end
	 
	 
	 
	 
	 /////////////////////
	 //    WriteBack    //
	 /////////////////////
	 
	 
	 
	 // update writeback controls
	 always_ff @(posedge clk) begin
		if (rst) begin
			PCSrcW    <= '0;
			RegWriteW <= '0;
			MemtoRegW <= '0;
		end
		else begin
			PCSrcW    <= PCSrcM;
			RegWriteW <= RegWriteM;
			MemtoRegW <= MemtoRegM;
		end
	 end

	 
	 
	 
	 
	  //-------------------------------------------------------------------------------
    //                                   HAZARD CONTROL
    //-------------------------------------------------------------------------------
	 
	 
	 
	 /////////////////////
	 //   Forwarding    //
	 /////////////////////
	 
	 // do the current execute and memory/writeback addresses match
	 assign Match_1E_M = (RA1E == WA3M);
	 assign Match_2E_M = (RA2E == WA3M);
	 assign Match_1E_W = (RA1E == WA3W);
	 assign Match_2E_W = (RA2E == WA3W);
	 
	 // muxes to determine forwarding procedure 
	 always_comb begin
			if (Match_1E_M * RegWriteM) ForwardAE = 2'b10;
			else if (Match_1E_W * RegWriteW) ForwardAE = 2'b01;
			else ForwardAE = 2'b00;
			
			if (Match_2E_M * RegWriteM) ForwardBE = 2'b10;
			else if (Match_2E_W * RegWriteW) ForwardBE = 2'b01;
			else ForwardBE = 2'b00; 
	 end
	 
	 
	 
	 /////////////////////
	 //    Branching    //
	 /////////////////////
	 
	 assign FlushF = (rst) ? '0 : (BranchD | BranchTakenE);  // Flush Fetched instrucitons
	 assign FlushD = (rst) ? '0 : BranchTakenE;              // Flush decode stage
	 assign FlushE = (rst) ? '0 : (Idrstall | BranchTakenE); // Flush execute stage
	 
	 
	 /////////////////////
	 //    Stalling     //
	 /////////////////////
	 
	 // do either decode and execute addresses match
	 assign Match_12D_E = (RA1D == WA3E) | (RA2D == WA3E);
	 
	 // stall when calling a register that has not been loaded yet
	 assign Idrstall = (MemtoRegE) ? Match_12D_E : '0;
	 assign StallF = (rst) ? '0 : (Idrstall | BranchD);
	 assign StallD = (rst) ? '0 : (Idrstall);
	 
	 
	 

endmodule 