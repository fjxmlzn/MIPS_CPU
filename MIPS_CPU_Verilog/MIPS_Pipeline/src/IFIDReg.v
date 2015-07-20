`timescale 1ns / 1ps

module IFIDReg(clk, reset, enable, IFIDMux, Instruction, PC, PC_plus_4, Instruction_n, PC_n, PC_plus_4_n);
	input clk, reset, enable, IFIDMux;
	input [31:0] Instruction, PC, PC_plus_4;
	output reg [31:0] Instruction_n, PC_n, PC_plus_4_n;
	
	always @(posedge clk or posedge reset)
		begin
			if (reset || ~IFIDMux)
				begin
					Instruction_n <= 32'b0;
					PC_n <= PC;
					PC_plus_4_n <= PC_plus_4;
				end
			else if (enable)
				begin
					Instruction_n <= Instruction;
					PC_n <= PC;
					PC_plus_4_n <= PC_plus_4;
				end
			else 
				begin
					Instruction_n <= Instruction_n;
					PC_n <= PC_n;
					PC_plus_4_n <= PC_plus_4_n;
				end
		end
endmodule
