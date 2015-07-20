`timescale 1ns / 1ps

module MEMWBReg(clk, reset, 
					PC_plus_4, RegWrite, MemtoReg, Write_register, ALU_out, Read_data,
					PC_plus_4_n, RegWrite_n, MemtoReg_n, Write_register_n, ALU_out_n, Read_data_n);
	input clk, reset;
	input [31:0] PC_plus_4, ALU_out, Read_data;
	input RegWrite;
	input [1:0] MemtoReg;
	input [4:0] Write_register;

	output reg [31:0] PC_plus_4_n, ALU_out_n, Read_data_n;
	output reg RegWrite_n;
	output reg [1:0] MemtoReg_n;
	output reg [4:0] Write_register_n;
	
	always@(posedge clk or posedge reset)
		begin
			if (reset)
				begin
					PC_plus_4_n <= 32'b0;
					ALU_out_n <= 32'b0;
					Read_data_n <= 32'b0;
					RegWrite_n <= 1'b0;
					MemtoReg_n <= 2'b0;
					Write_register_n <= 5'b0;
				end
			else
				begin
					PC_plus_4_n <= PC_plus_4;
					ALU_out_n <= ALU_out;
					Read_data_n <= Read_data;
					RegWrite_n <= RegWrite;
					MemtoReg_n <= MemtoReg;
					Write_register_n <= Write_register;					
				end
		end

endmodule
