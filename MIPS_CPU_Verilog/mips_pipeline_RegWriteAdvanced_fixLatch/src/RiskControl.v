`timescale 1ns / 1ps

module RiskControl(MemRead_ex, Write_register, Rs, Rt, PCWrite, IFIDWrite, PCSrc, PCSrc_ex, IFIDMux, IDEXMux, ALU_out0);
	input MemRead_ex, ALU_out0;
	input [4:0] Write_register, Rs, Rt;
	input [2:0] PCSrc, PCSrc_ex;
	
	output reg PCWrite, IFIDWrite, IFIDMux, IDEXMux;
	
	always@(*)
		begin
			if (MemRead_ex && (Write_register == Rs || Write_register == Rt)) // load use
				begin
					//flush id
					IDEXMux = 1'b0;
					IFIDWrite = 1'b0;
					IFIDMux = 1'b1;
					PCWrite = 1'b0;
				end
			else if (PCSrc_ex == 3'b001 && ALU_out0)									// branch
				begin
					//flush if id
					IDEXMux = 1'b0;
					IFIDWrite = 1'b0; //*
					IFIDMux = 1'b0;
					PCWrite = 1'b1;
				end
			else if (PCSrc == 3'b010 || PCSrc == 3'b011)								//jump
				begin
					//flush if
					IDEXMux = 1'b1;
					IFIDWrite = 1'b0;	//*
					IFIDMux = 1'b0;
					PCWrite = 1'b1;			
				end
			else if (PCSrc == 3'b100 || PCSrc == 3'b101 || PCSrc == 3'b110 || PCSrc == 3'b111)	//exception & interrupt
				begin
					//flush if
					IDEXMux = 1'b1;
					IFIDWrite = 1'b0;	//*
					IFIDMux = 1'b0;
					PCWrite = 1'b1;
				end
			else
				begin
					IDEXMux = 1'b1;
					IFIDWrite = 1'b1;
					IFIDMux = 1'b1;
					PCWrite = 1'b1;
				end
		end
endmodule
