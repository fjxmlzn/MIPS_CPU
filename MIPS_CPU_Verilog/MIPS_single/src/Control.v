`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:46:57 07/08/2015 
// Design Name: 
// Module Name:    Control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Control(monin, Ins, PCSrc, RegWrite, RegDst, 
		MemRead,	MemWrite, MemtoReg,
		ALUSrc1, ALUSrc2, ExtOp, LuOp,	ALUFun,
		Sign, IRQ);
	input [31:0] Ins;
	input [1:0] IRQ;
	input monin;
	output [2:0] PCSrc;
	output RegWrite, MemRead, MemWrite, ALUSrc1, ALUSrc2, ExtOp, LuOp, Sign;
	output [1:0] RegDst;
	output [1:0] MemtoReg;
	output [5:0] ALUFun;
	
	//exception
	wire excp;
	assign excp =
		(monin)? 1'b0:
		(~|Ins||Ins[31:26]==6'b100011||Ins[31:26]==6'b101011||
		Ins[31:26]==6'b001111||(Ins[31:26]==0&&(Ins[5:0]==0||Ins[5:0]==6'h2||
		Ins[5:0]==6'h3||Ins[5:0]==6'h8||Ins[5:0]==6'h9||(Ins[5:0]>=6'h20&&Ins[5:0]<=6'h27)||
		Ins[5:0]==6'h2a||Ins[5:0]==6'h2b))||(Ins[31:26]>=6'h2&&Ins[31:26]<=6'h12)||
		(Ins[31:26]==6'b1&&Ins[20:16]==5'b1))? 1'b0 : 1'b1;
	
	assign PCSrc =
		(~monin&&IRQ==2'b01)? 3'b100:
		(~monin&&IRQ==2'b10)? 3'b110:
		(~monin&&IRQ==2'b11)? 3'b111:
		((Ins[31:26]>=6'h4&&Ins[31:26]<=6'h7)||
		(Ins[31:26]==6'b000001&&Ins[20:16]==5'b00001))? 3'b001:
		(Ins[31:26]==6'b000010||Ins[31:26]==6'b000011)? 3'b010:
		(Ins[31:26]==0&&(Ins[5:0]==6'b001000||Ins[5:0]==6'b001001))?3'b011:
		(excp)? 3'b101 : 3'b000;
		
	wire ex_inter;
	assign ex_inter = (~monin&&(IRQ!=0||excp));
	
	assign RegWrite=
		(~ex_inter&&(~|Ins||Ins[31:26]==6'h2b||(Ins[31:26]>=6'h4&&Ins[31:26]<=6'h7)||
		(Ins[31:26]==6'b000001&&Ins[20:16]==5'b00001)||Ins[31:26]==6'h2||
		(Ins[31:26]==0&&Ins[5:0]==6'h8)))? 1'b0 : 1'b1;
	
	assign RegDst=
		(ex_inter)? 2'b11:
		(Ins[31:26]==6'h23||Ins[31:26]==6'hf||Ins[31:26]==6'h8||
		Ins[31:26]==6'h9||(Ins[31:26]<=6'hc&&Ins[31:26]>=6'ha))?2'b0:
		(Ins[31:26]==6'h3)? 2'b10: 2'b01;
		
	assign MemRead=
		(~ex_inter&&Ins[31:26]==6'h23)? 1'b1 : 1'b0;
		
	assign MemWrite=
		(~ex_inter&&Ins[31:26]==6'h2b)? 1'b1 : 1'b0;
		
	assign MemtoReg=
		(ex_inter||Ins[31:26]==6'h3||(Ins[31:26]==6'h0&&Ins[5:0]==6'h9))? 2'b10:
		(Ins[31:26]==6'h23)? 2'b01 : 2'b00;
		
	assign ALUSrc1=
		(Ins[31:26]==0&&(Ins[5:0]==0||Ins[5:0]==6'h2||
		Ins[5:0]==6'h3))? 1'b1 : 1'b0;
		
	assign ALUSrc2=
		((Ins[31:26]>=6'h8&&Ins[31:26]<=6'hc)||Ins[31:26]==6'h23||
		Ins[31:26]==6'h2b||Ins[31:26]==6'hf)? 1'b1 : 1'b0;
		
	assign ALUFun=
		(Ins[31:26]==0&&(Ins[5:0]==6'h23||Ins[5:0]==6'h22))? 6'b1:
		(Ins[31:26]==6'hc||(Ins[31:26]==6'h0&&Ins[5:0]==6'h24))?6'b11000:
		(Ins[31:26]==6'h0&&Ins[5:0]==6'h25)? 6'b11110:
		(Ins[31:26]==6'h0&&Ins[5:0]==6'h26)? 6'b10110:
		(Ins[31:26]==6'h0&&Ins[5:0]==6'h27)? 6'b10001:
		(Ins[31:26]==6'h0&&Ins[5:0]==6'h0)? 6'b100000:
		(Ins[31:26]==6'h0&&Ins[5:0]==6'h2)? 6'b100001:
		(Ins[31:26]==6'h0&&Ins[5:0]==6'h3)? 6'b100011:
		(Ins[31:26]==6'h0&&(Ins[5:0]==6'h2a||Ins[5:0]==6'h2b)||
		Ins[31:26]==6'ha||Ins[31:26]==6'hb)? 6'b110101:
		(Ins[31:26]==6'h4)? 6'b110011:
		(Ins[31:26]==6'h5)? 6'b110001:
		(Ins[31:26]==6'h6)? 6'b111101:
		(Ins[31:26]==6'h7)? 6'b111111:
		((Ins[31:26]==6'b000001&&Ins[20:16]==5'b00001))? 6'b111001 : 6'b0;
		
	assign Sign =
		(Ins[31:26]==6'h0&&(Ins[5:0]==6'h21||Ins[5:0]==6'h23||
		Ins[5:0]==6'h2b)||Ins[31:26]==6'h9||Ins[31:26]==6'hb)? 1'b0 : 1'b1;
	
	assign ExtOp=
		(Ins[31:26]==6'hc)? 1'b0 : 1'b1;
	
	assign LuOp=
		(Ins[31:26]==6'hf)? 1'b1 : 1'b0;
endmodule
