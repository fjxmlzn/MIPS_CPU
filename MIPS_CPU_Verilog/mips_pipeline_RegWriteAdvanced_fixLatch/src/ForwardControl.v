`timescale 1ns / 1ps

module ForwardControl(RegWrite_ex, RegWrite_mem, RegWrite_wb,
				Write_register, Write_register_mem, Write_register_wb,
				ALUSrc1_ex, ALUSrc2_ex, Rs_ex, Rt_ex,
				Rs_mem, Rt_mem, PCSrc, Rs, MemWrite_mem,
				ForwardA, ForwardB, ForwardJr, ForwardSW);
	
	input RegWrite_ex, RegWrite_mem, RegWrite_wb, ALUSrc1_ex, ALUSrc2_ex, MemWrite_mem;
	input [4:0] Write_register, Write_register_mem, Write_register_wb, Rs_ex, Rs_mem, Rt_ex, Rt_mem, Rs;
	input [2:0] PCSrc;
	
	output reg [1:0] ForwardA, ForwardB;
	output reg ForwardJr, ForwardSW;
		
	always@(*)	//alu input
		begin
			if (RegWrite_mem && Write_register_mem != 0 && Write_register_mem == Rs_ex && ~ALUSrc1_ex)
				ForwardA = 2'b10;
			else if (RegWrite_wb && Write_register_wb != 5'b0 && Write_register_wb == Rs_ex && ~ALUSrc1_ex)
				ForwardA = 2'b01;
			else 
				ForwardA = 2'b00;
				
			if (RegWrite_mem && Write_register_mem != 0 && Write_register_mem == Rt_ex && ~ALUSrc2_ex)
				ForwardB = 2'b10;
			else if (RegWrite_wb && Write_register_wb != 5'b0 && Write_register_wb == Rt_ex && ~ALUSrc2_ex)
				ForwardB = 2'b01;
			else
				ForwardB = 2'b00;
		end
		
	always@(*)	//jr
		begin
			if (PCSrc == 3'b011 && RegWrite_ex && Write_register == Rs)
				ForwardJr = 1'b1;
			else
				ForwardJr = 1'b0;
		end
	
	always@(*)	//sw
		begin
			if (RegWrite_wb && Write_register_wb == Rt_mem && MemWrite_mem)
				ForwardSW = 1'b1;
			else
				ForwardSW = 1'b0;
		end
endmodule
