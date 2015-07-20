`timescale 1ns / 1ps
module IDEXReg(clk, reset, IDEXMux, 
				   Instruction, PC_plus_4, MemWrite, MemRead, RegWrite, RegDst, 
					PCSrc, MemtoReg, ALUSrc1, ALUSrc2,
					Sign, LU_out, ALUFun, Rs, Rd, Rt, Databus1, Databus2,
					Instruction_n, PC_plus_4_n, MemWrite_n, MemRead_n, RegWrite_n, RegDst_n, 
					PCSrc_n, LuOp_n, MemtoReg_n, ALUSrc1_n, ALUSrc2_n,
					Sign_n,  LU_out_n, ALUFun_n, Rs_n, Rd_n, Rt_n, Databus1_n, Databus2_n);
	input clk, reset, IDEXMux;
	input [31:0] Instruction, PC_plus_4, LU_out,
				Databus1, Databus2;
	input MemWrite, MemRead, RegWrite, 
				ALUSrc1, ALUSrc2, Sign;
	input [1:0] RegDst, MemtoReg;
	input [2:0] PCSrc;	
	input [5:0] ALUFun;
	input [4:0] Rs, Rd, Rt;
	
	output reg [31:0] Instruction_n, PC_plus_4_n, LU_out_n,
				Databus1_n, Databus2_n;
	output reg MemWrite_n, MemRead_n, RegWrite_n, 
				LuOp_n, ALUSrc1_n, ALUSrc2_n, Sign_n;
	output reg [1:0] RegDst_n,  MemtoReg_n;
	output reg [2:0] PCSrc_n;
	output reg [5:0] ALUFun_n;
	output reg [4:0] Rs_n, Rd_n, Rt_n;
	
	always@(posedge clk or posedge reset)
		begin
			if (reset)
				begin
					Instruction_n <= 32'b0;
					PC_plus_4_n <= 32'b0;
					LU_out_n <= 32'b0;
					Rs_n <= 5'b0;
					Rd_n <= 5'b0;
					Rt_n <= 5'b0;
					Databus1_n <= 32'b0;
					Databus2_n <= 32'b0;
					MemWrite_n <= 1'b0;
					MemRead_n <= 1'b0;
					RegWrite_n <= 1'b0;
					RegDst_n <= 2'b0;
					PCSrc_n <= 3'b0;
					MemtoReg_n <= 2'b0;
					ALUSrc1_n <= 1'b0;
					ALUSrc2_n <= 1'b0;
					Sign_n <= 1'b0;
					ALUFun_n <= 6'b0;
				end
			else if (~IDEXMux)
				begin
					Instruction_n <= Instruction;
					PC_plus_4_n <= PC_plus_4;
					LU_out_n <= LU_out;
					Rs_n <= Rs;
					Rd_n <= Rd;
					Rt_n <= Rt;
					Databus1_n <= Databus1;
					Databus2_n <= Databus2;
					MemWrite_n <= 1'b0;
					MemRead_n <= 1'b0;
					RegWrite_n <= 1'b0;
					RegDst_n <= 2'b0;
					PCSrc_n <= 3'b0;
					MemtoReg_n <= 2'b0;
					ALUSrc1_n <= 1'b0;
					ALUSrc2_n <= 1'b0;
					Sign_n <= 1'b0;
					ALUFun_n <= 6'b0;
				end
			else
				begin
					Instruction_n <= Instruction;
					PC_plus_4_n <= PC_plus_4;
					LU_out_n <= LU_out;
					Rs_n <= Rs;
					Rd_n <= Rd;
					Rt_n <= Rt;
					Databus1_n <= Databus1;
					Databus2_n <= Databus2;
					MemWrite_n <= MemWrite;
					MemRead_n <= MemRead;
					RegWrite_n <= RegWrite;
					RegDst_n <= RegDst;
					PCSrc_n <= PCSrc;
					MemtoReg_n <= MemtoReg;
					ALUSrc1_n <= ALUSrc1;
					ALUSrc2_n <= ALUSrc2;
					Sign_n <= Sign;
					ALUFun_n <= ALUFun;
				end
		end

endmodule
