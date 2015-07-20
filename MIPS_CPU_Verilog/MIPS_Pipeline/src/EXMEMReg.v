`timescale 1ns / 1ps
module EXMEMReg(clk, reset, 
					 RegWrite, MemRead, MemWrite, MemtoReg,
					 Write_register, Databus2, ALU_out, PC_plus_4,
					 Rs, Rt,
					 RegWrite_n, MemRead_n, MemWrite_n, MemtoReg_n, 
					 Write_register_n, Databus2_n, ALU_out_n, PC_plus_4_n,
					 Rs_n, Rt_n);
	input clk, reset;
	input RegWrite, MemRead, MemWrite;
	input [1:0] MemtoReg;
	input [4:0] Write_register, Rs, Rt;
	input [31:0] Databus2, ALU_out, PC_plus_4;
	
	output reg RegWrite_n, MemRead_n, MemWrite_n;
	output reg [1:0] MemtoReg_n;
	output reg [4:0] Write_register_n, Rs_n, Rt_n;
	output reg [31:0] Databus2_n, ALU_out_n, PC_plus_4_n;
	
	always@(posedge clk or posedge reset)
		begin
			if (reset)
				begin
					RegWrite_n <= 1'b0;
					MemRead_n <= 1'b0;
					MemWrite_n <= 1'b0;
					MemtoReg_n <= 2'b0;
					Write_register_n <= 5'b0;
					Databus2_n <= 32'b0;
					ALU_out_n <= 32'b0;
					PC_plus_4_n <= 32'b0;
					Rs_n <= 5'b0;
					Rt_n <= 5'b0;
				end
			else
				begin
					RegWrite_n <= RegWrite;
					MemRead_n <= MemRead;
					MemWrite_n <= MemWrite;
					MemtoReg_n <= MemtoReg;
					Write_register_n <= Write_register;
					Databus2_n <= Databus2;
					ALU_out_n <= ALU_out;
					PC_plus_4_n <= PC_plus_4;
					Rs_n <= Rs;
					Rt_n <= Rt;
				end
		end
endmodule
