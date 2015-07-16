`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:45:03 07/08/2015 
// Design Name: 
// Module Name:    top 
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
module CPU(resetk, clk , button, led, switch, bcd, an, RX, TX);
	input resetk, clk, button, RX;
	input [7:0] switch;
	output TX;
	output [3:0] an;
	output [7:0] bcd;
	output [7:0] led;
	
	wire reset;
	debounce d1 (.clk(clk),.key_i(resetk),.key_o(reset));
	
	
	//wire btp;
	//debounce d2 (.clk(clk),.key_i(button),.key_o(myclk));
	//always @(posedge btp or posedge reset)
	//if (reset) myclk<=0;
	//else myclk<=~myclk;
	
	reg myclk;
	reg [31:0] cnt_clk;
	always @(posedge clk or posedge reset)
	if (reset) begin cnt_clk<=0; myclk<=0; end
	else if (cnt_clk==32'd50_000) 			// frequency = 1kHz
		begin 
		myclk<=~myclk;
		cnt_clk<=0;
		end
	else
		begin
		cnt_clk<=cnt_clk+1'b1;
		end
	
	reg [31:0] PC;
	wire [31:0] PC_next;
	always @(posedge reset or posedge myclk)
		if (reset)
			PC <= 32'h80000000;
		else
			PC <= PC_next;
			
	
	
	wire [31:0] PC_plus_4;
	assign PC_plus_4 ={PC[31], (PC[30:0] + 31'd4)};//+4 won't change PC[31]
	
	wire [31:0] Instruction;//instruc fetch
	ROM rom1(.addr(PC), .data(Instruction));
	//assign led=Instruction[7:0];//test
	
	wire [1:0] RegDst;
	wire [2:0] PCSrc;
	wire MemRead;
	wire [1:0] MemtoReg;
	wire ExtOp;
	wire LuOp;
	wire MemWrite;
	wire ALUSrc1;
	wire ALUSrc2;
	wire [5:0] ALUFun;
	wire Sign;
	wire RegWrite;
	
	wire [31:0] ALU_out;
	
	wire [31:0] Databus1, Databus2, Databus3;
	wire [4:0] Write_register;
	
	wire [31:0] Ext_out;
	wire [31:0] LU_out;
	
	wire [31:0] ALU_in1;
	wire [31:0] ALU_in2;
	
	wire [31:0] Read_data;
	wire [31:0] Jump_target;
	wire [31:0] Branch_target;
	
	wire [31:0] ILLOP;
	wire [31:0] XADR;
	wire [31:0] ILLTX;
	wire [31:0] ILLRX;
	assign ILLOP=32'h8000_0004;
	assign XADR=32'h8000_0008;
	assign ILLTX=32'h8000_000c;
	assign ILLRX=32'h8000_0010;
	
	wire data_read;
	wire peri_read;
	wire [31:0] data_rda;
	wire [31:0] peri_rda;
	assign data_read=(MemRead)? ((ALU_out<32'h4000_0000)? 1:0):0;
	assign peri_read=(MemRead)? ((ALU_out>=32'h4000_0000)? 1:0):0;
	assign Read_data=
		data_read? data_rda:
		peri_read? peri_rda: 0;
	
	wire data_wr;
	wire peri_wr;
	assign data_wr=(MemWrite)? ((ALU_out<32'h4000_0000)? 1:0):0;
	assign peri_wr=(MemWrite)? ((ALU_out>=32'h4000_0000)? 1:0):0;

	wire [11:0] digi;
	assign an=digi[11:8];
	assign bcd=~digi[7:0];
	wire [1:0] IRQ;
	wire [7:0] test_1;
	Peripheral peri1(.reset(reset),.sysclk(clk),.clk(myclk),.rd(peri_read),.wr(peri_wr),.addr(ALU_out),.wdata(Databus2),
	.rdata(peri_rda),.RX(RX),.TX(TX),.led(test_1),.switch(switch),.digi(digi),.irqout(IRQ));

	reg [1:0] IRQs;
	always @(posedge myclk or posedge reset)
	if (reset) IRQs<=0;
	else IRQs<=IRQ;
	
	assign led[1:0] =IRQs;
	assign led[7:2] =PC[7:2];
	
	Control control1(.monin(PC[31]),
		.Ins(Instruction),
		.PCSrc(PCSrc), .RegWrite(RegWrite), .RegDst(RegDst), 
		.MemRead(MemRead),	.MemWrite(MemWrite), .MemtoReg(MemtoReg),
		.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ExtOp(ExtOp), .LuOp(LuOp),	.ALUFun(ALUFun),
		.Sign(Sign), .IRQ(IRQs));
	
	
	assign Write_register = (RegDst == 2'b00)? Instruction[20:16]:
									(RegDst == 2'b01)? Instruction[15:11]:
									(RegDst==2'b10)? 32'd31: 32'd26;
	
	RegFile register_file1(.reset(reset), .clk(myclk), .wr(RegWrite), 
		.addr1(Instruction[25:21]), .addr2(Instruction[20:16]), .addr3(Write_register),
		. data3(Databus3), .data1(Databus1), .data2(Databus2));
	
	assign Ext_out = {ExtOp? {16{Instruction[15]}}: 16'h0000, Instruction[15:0]};
	
	
	assign LU_out = LuOp? {Instruction[15:0], 16'h0000}: Ext_out;
	
	
	
	assign ALU_in1 = ALUSrc1? {17'h00000, Instruction[10:6]}: Databus1;
	assign ALU_in2 = ALUSrc2? LU_out: Databus2;
	ALU alu1(.A(ALU_in1), .B(ALU_in2), .ALUFun(ALUFun), .Sign(Sign), .result(ALU_out));
	
	
	
	DataMem data_memory1(.reset(reset), .clk(myclk), .addr(ALU_out), .wdata(Databus2), .rdata(data_rda), .rd(data_read), .wr(data_wr));
	assign Databus3 = (MemtoReg == 2'b00)? ALU_out: 
							(MemtoReg == 2'b01)? Read_data: PC_plus_4;

	
	assign Jump_target = {PC_plus_4[31:28], Instruction[25:0], 2'b00};
	
	
	assign Branch_target = (ALU_out[0])? PC_plus_4 + {LU_out[29:0], 2'b00}: PC_plus_4;
	
	
	assign PC_next = (PCSrc == 3'b000)? PC_plus_4: 
							(PCSrc == 3'b001)? Branch_target: 
							{PCSrc==3'b010}? Jump_target:
							{PCSrc==3'b011}? Databus1:
							{PCSrc==3'b100}? ILLOP:
							{PCSrc==3'b101}? XADR:
							{PCSrc==3'b110}? ILLTX:
							{PCSrc==3'b111}? ILLRX:32'h0000_0000;
	
endmodule
	
