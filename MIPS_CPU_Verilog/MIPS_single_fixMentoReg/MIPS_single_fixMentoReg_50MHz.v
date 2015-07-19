`timescale 1ns / 1ps
module CPU(resetk, clk , button, led, switch, bcd, an, RX, TX);
	input resetk, clk, button, RX;
	input [7:0] switch;
	output TX;
	output [3:0] an;
	output [7:0] bcd;
	output [7:0] led;
	
	wire reset;
	debounce d1 (.clk(clk),.key_i(resetk),.key_o(reset));
	
	//wire myclk;
	//wire btp;
	//debounce d2 (.clk(clk),.key_i(button),.key_o(myclk));
	//always @(posedge btp or posedge reset)
	//if (reset) myclk<=0;
	//else myclk<=~myclk;
	
	reg myclk;
	reg [31:0] cnt_clk;
	always @(posedge clk or posedge reset)
	if (reset) begin cnt_clk<=0; myclk<=0; end
	else if (cnt_clk==32'd1) 			// frequency = 50MHz
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
	//wire [7:0] test_1;
	Peripheral peri1(.reset(reset),.sysclk(clk),.clk(myclk),.rd(peri_read),.wr(peri_wr),.addr(ALU_out),.wdata(Databus2),
	.rdata(peri_rda),.RX(RX),.TX(TX),.led(led),.switch(switch),.digi(digi),.irqout(IRQ));

	reg [1:0] IRQs;
	always @(posedge myclk or posedge reset)
	if (reset) IRQs<=0;
	else IRQs<=IRQ;
	
	//assign led[1:0] =IRQs;
	//assign led[7:2] =PC[7:2];
	
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
							(MemtoReg == 2'b01)? Read_data: 
							(MemtoReg==2'b10)?PC_plus_4:
							(MemtoReg==2'b11)? PC:0;

	
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
	

	
module ALU(A,B,ALUFun,Sign,result);
input [31:0]A;
input [31:0]B;
input [5:0]ALUFun;
input Sign;
output [31:0]result;

wire Z,N,V;
wire [31:0]outcome0;
wire [31:0]outcome1;
wire [31:0]outcome2;
wire [31:0]outcome3;

ALUADD adder(A,B,ALUFun[0],Sign,outcome0,Z,V,N);
ALULogic logicer(A,B,ALUFun[3:0],outcome1);
ALUShift shifter(A[4:0],B,ALUFun[1:0],outcome2);
ALUCMP cmper(Z,N,A,ALUFun[3:1],outcome3);
ALUMUX muxer(outcome0,outcome1,outcome2,outcome3,ALUFun[5:4],result);
endmodule

module ALUShift(A,B,ctrl,result);
input [4:0]A;
input [31:0]B;
input [1:0]ctrl;
output reg[31:0]result;

reg [31:0]layer1;
reg [31:0]layer2;
reg [31:0]layer3;
reg [31:0]layer4;

always @*
begin
	case(ctrl)
	2'b00:
	begin
		layer4[31:16]<=(A[4]==1)?B[15:0]:B[31:16];
		layer4[15:0]<=(A[4]==1)?0:B[15:0];
		layer3[31:8]<=(A[3]==1)?layer4[23:0]:layer4[31:8];
		layer3[7:0]<=(A[3]==1)?0:layer4[7:0];
		layer2[31:4]<=(A[2]==1)?layer3[27:0]:layer3[31:4];
		layer2[3:0]<=(A[2]==1)?0:layer3[3:0];
		layer1[31:2]<=(A[1]==1)?layer2[29:0]:layer2[31:2];
		layer1[1:0]<=(A[1]==1)?0:layer2[1:0];
		result[31:1]<=(A[0]==1)?layer1[30:0]:layer1[31:1];
		result[0]<=(A[0]==1)?0:layer1[0];
	end
	2'b01:
	begin
		layer4[31:16]<=(A[4]==1)?0:B[31:16];
		layer4[15:0]<=(A[4]==1)?B[31:16]:B[15:0];
		layer3[31:24]<=(A[3]==1)?0:layer4[31:24];
		layer3[23:0]<=(A[3]==1)?layer4[31:8]:layer4[23:0];
		layer2[31:28]<=(A[2]==1)?0:layer3[31:28];
		layer2[27:0]<=(A[2]==1)?layer3[31:4]:layer3[27:0];
		layer1[31:30]<=(A[1]==1)?0:layer2[31:30];
		layer1[29:0]<=(A[1]==1)?layer2[31:2]:layer2[29:0];
		result[31]<=(A[0]==1)?0:layer1[31];
		result[30:0]<=(A[0]==1)?layer1[31:1]:layer1[30:0];
	end
	2'b11:
	begin
		if(B[31]==0)
		begin
		layer4[31:16]<=(A[4]==1)?0:B[31:16];
		layer4[15:0]<=(A[4]==1)?B[31:16]:B[15:0];
		layer3[31:24]<=(A[3]==1)?0:layer4[31:24];
		layer3[23:0]<=(A[3]==1)?layer4[31:8]:layer4[23:0];
		layer2[31:28]<=(A[2]==1)?0:layer3[31:28];
		layer2[27:0]<=(A[2]==1)?layer3[31:4]:layer3[27:0];
		layer1[31:30]<=(A[1]==1)?0:layer2[31:30];
		layer1[29:0]<=(A[1]==1)?layer2[31:2]:layer2[29:0];
		result[31]<=(A[0]==1)?0:layer1[31];
		result[30:0]<=(A[0]==1)?layer1[31:1]:layer1[30:0];
		end
		else
		begin
		layer4[31:16]<=(A[4]==1)?16'b1111_1111_1111_1111:B[31:16];
		layer4[15:0]<=(A[4]==1)?B[31:16]:B[15:0];
		layer3[31:24]<=(A[3]==1)?8'b1111_1111:layer4[31:24];
		layer3[23:0]<=(A[3]==1)?layer4[31:8]:layer4[23:0];
		layer2[31:28]<=(A[2]==1)?4'b1111:layer3[31:28];
		layer2[27:0]<=(A[2]==1)?layer3[31:4]:layer3[27:0];
		layer1[31:30]<=(A[1]==1)?2'b11:layer2[31:30];
		layer1[29:0]<=(A[1]==1)?layer2[31:2]:layer2[29:0];
		result[31]<=(A[0]==1)?1:layer1[31];
		result[30:0]<=(A[0]==1)?layer1[31:1]:layer1[30:0];
		end
	end
	endcase
end
endmodule


module ALUMUX(in0,in1,in2,in3,ctrl,out);
input [31:0]in0;
input [31:0]in1;
input [31:0]in2;
input [31:0]in3;
input [1:0]ctrl;
output reg[31:0]out;

always @*
begin
	case(ctrl)
	2'b00:out<=in0;
	2'b01:out<=in1;
	2'b10:out<=in2;
	2'b11:out<=in3;
	endcase
end

endmodule


module ALULogic(A,B,ctrl,result);
input [31:0]A;
input [31:0]B;
input [3:0]ctrl;
output reg[31:0]result;

always @*
begin
	case(ctrl)
	4'b1000:result<=A&B;
	4'b1110:result<=A|B;
	4'b0110:result<=A^B;
	4'b0001:result<=~(A|B);
	4'b1010:result<=A;
	endcase
end
endmodule

module ALUCMP(Z,N,A,ctrl,result);
input Z;
input N;
input [31:0]A;
input [2:0]ctrl;
output reg[31:0]result;

always @*
begin
	case(ctrl)
	3'b001:result<=(Z==1)?1:0;
	3'b000:result<=(Z==0)?1:0;
	3'b010:result<=(N==1)?1:0;
	3'b110:result<=(A[31]==1||A==0)?1:0;
	3'b100:result<=(A[31]==0)?1:0;
	3'b111:result<=(A[31]==0&&A!=0)?1:0;
	endcase
end

endmodule

module ALUADD(A,B,ctrl,Sign,result,Z,V,N);
input [31:0]A;
input [31:0]B;
input ctrl;
input Sign;
output reg[31:0]result;
output Z;
output V;
output reg N;

assign Z = (result==0)?1:0;
always @*
begin
if (Sign==1 || (Sign==0 && (
	(A[31]==1&&B[31]==1) || 
	(A[31]==0&&B[31]==0) ))) N<=result[31];
else if (A[31]==0&&B[31]==1) N<=1;
else N<=0;
end

reg [31:0]C;
reg [31:0]D;
always @*
begin
	D<=~B;
	C<=D+1;
end

always @*
begin
	if (ctrl == 0) result<=A+B;
	else result<=A+C;
end

wire carry1;
wire carry0;
assign carry1 = ((A[31]==1&&B[31]==1)||(A[31]==1&&B[31]==0&&result[31]==0)
		||(A[31]==0&&B[31]==1&&result[31]==0)
		||A[31]==0&&B[31]==0&&result[31]==1)?1:0;
assign carry0 = ((A[30]==1&&B[31]==1)||(A[30]==1&&B[30]==0&&result[30]==0)
		||(A[30]==0&&B[30]==1&&result[30]==0)
		||A[30]==0&&B[30]==0&&result[30]==1)?1:0;
assign V = (Sign==1)?(carry1^carry0):carry1;
endmodule

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
	assign excp=
	(monin)? 0:
	(~|Ins||Ins[31:26]==6'b100011||Ins[31:26]==6'b101011||
	Ins[31:26]==6'b001111||(Ins[31:26]==0&&(Ins[5:0]==0||Ins[5:0]==6'h2||
	Ins[5:0]==6'h3||Ins[5:0]==6'h8||Ins[5:0]==6'h9||(Ins[5:0]>=6'h20&&Ins[5:0]<=6'h27)||
	Ins[5:0]==6'h2a||Ins[5:0]==6'h2b))||(Ins[31:26]>=6'h2&&Ins[31:26]<=6'h12)||
	(Ins[31:26]==6'b1&&Ins[20:16]==5'b1))? 0:1;
	
	assign PCSrc =
		(~monin&&IRQ==2'b01)? 3'b100:
		(~monin&&IRQ==2'b10)? 3'b110:
		(~monin&&IRQ==2'b11)? 3'b111:
		((Ins[31:26]>=6'h4&&Ins[31:26]<=6'h7)||
		(Ins[31:26]==6'b000001&&Ins[20:16]==5'b00001))? 3'b001:
		(Ins[31:26]==6'b000010||Ins[31:26]==6'b000011)? 3'b010:
		(Ins[31:26]==0&&(Ins[5:0]==6'b001000||Ins[5:0]==6'b001001))?3'b011:
		(excp)?3'b101:3'b000;
		
	wire ex_inter;
	assign ex_inter=(~monin&&(IRQ!=0||excp));
	
	assign RegWrite=
		(~ex_inter&&(~|Ins||Ins[31:26]==6'h2b||(Ins[31:26]>=6'h4&&Ins[31:26]<=6'h7)||
		(Ins[31:26]==6'b000001&&Ins[20:16]==5'b00001)||Ins[31:26]==6'h2||
		(Ins[31:26]==0&&Ins[5:0]==6'h8)))? 0:1;
	
	assign RegDst=
		(ex_inter)? 2'b11:
		(Ins[31:26]==6'h23||Ins[31:26]==6'hf||Ins[31:26]==6'h8||
		Ins[31:26]==6'h9||(Ins[31:26]<=6'hc&&Ins[31:26]>=6'ha))?0:
		(Ins[31:26]==6'h3)?2'b10: 2'b01;
		
	assign MemRead=
		(~ex_inter&&Ins[31:26]==6'h23)? 1:0;
		
	assign MemWrite=
		(~ex_inter&&Ins[31:26]==6'h2b)? 1:0;
		
	assign MemtoReg=
		(~monin&&IRQ!=0)? 2'b11:
		((~monin&&excp)||Ins[31:26]==6'h3||(Ins[31:26]==6'h0&&Ins[5:0]==6'h9))? 2'b10:
		(Ins[31:26]==6'h23)? 2'b01: 2'b00;
		
	assign ALUSrc1=
		(Ins[31:26]==0&&(Ins[5:0]==0||Ins[5:0]==6'h2||
		Ins[5:0]==6'h3))? 1:0;
		
	assign ALUSrc2=
		((Ins[31:26]>=6'h8&&Ins[31:26]<=6'hc)||Ins[31:26]==6'h23||
		Ins[31:26]==6'h2b||Ins[31:26]==6'hf)? 1:0;
		
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
		((Ins[31:26]==6'b000001&&Ins[20:16]==5'b00001))? 6'b111001:0;
		
	assign Sign =
		(Ins[31:26]==6'h0&&(Ins[5:0]==6'h21||Ins[5:0]==6'h23||
		Ins[5:0]==6'h2b)||Ins[31:26]==6'h9||Ins[31:26]==6'hb)?0:1;
	
	assign ExtOp=
		(Ins[31:26]==6'hc)? 0:1;
	
	assign LuOp=
		(Ins[31:26]==6'hf)? 1:0;
		

endmodule


module DataMem (reset,clk,rd,wr,addr,wdata,rdata);
input reset,clk;
input rd,wr;
input [31:0] addr;	//Address Must be Word Aligned
output [31:0] rdata;
input [31:0] wdata;

parameter RAM_SIZE = 256;
reg [31:0] RAMDATA [RAM_SIZE-1:0];

wire [31:0] rda=RAMDATA[addr[31:2]];
assign rdata=(rd && (addr < RAM_SIZE))?rda:32'b0;
wire [29:0] add=addr[31:2];
wire rd1=rd && (addr < RAM_SIZE);

integer i;
always@(posedge clk or posedge reset) begin
	if (reset) begin
		for(i=1;i<RAM_SIZE;i=i+1) RAMDATA[i]<=32'b0;
	end
	else if(wr && (addr < RAM_SIZE)) RAMDATA[addr[31:2]]<=wdata;
end

endmodule


module Peripheral (reset,sysclk,clk,rd,wr,addr,wdata,rdata,RX,TX,led,switch,digi,irqout);
input reset,clk,sysclk; //sysclk=V10 ->URAT
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
output reg[31:0] rdata;
input RX; //UART input and output
output TX;
output reg[7:0] led;
input [7:0] switch;
output reg[11:0] digi;
output reg[1:0]irqout; //irqout 2bit to judge the type of interrupt

///////////////////////////////////////////////////////////////////
reg [31:0] TH,TL;
reg [2:0] TCON;


//UART variables:
reg [7:0]UART_RXD;
reg [7:0]UART_TXD;
reg [4:0]UART_CON = 0;
reg [7:0]RX_buffer[15:0];
reg [3:0]RX_buf_in_tag = 0;
reg [3:0]RX_buf_out_tag = 0;
reg [3:0]RX_buf_num=0;
reg [7:0]TX_buffer[15:0];
reg [3:0]TX_buf_in_tag = 0;
reg [3:0]TX_buf_out_tag = 0;
reg [3:0]TX_buf_num=0;
reg TX_complete=0;
wire [7:0] RX_DATA;
wire RX_STATUS;
wire TX_STATUS;
reg TX_EN;
reg [7:0] TX_DATA;

//IRQ
always@*
begin
if (UART_CON[0]&&UART_CON[2]) irqout<=2'b10;
else if (UART_CON[1]&&UART_CON[3]) irqout<=2'b11;
else if (TCON[0]&&TCON[2]) irqout<=2'b01;
else irqout<=2'b00;
end
/*
//digi test 
	integer i=0;
reg clk2=0;
always @(posedge sysclk)
begin
	if (i==99) begin i<=0; clk2<=~clk2; end
	else i<=i+1;
end

reg [1:0] sta=2'b00;
always @(posedge clk2)
begin
sta<=sta+1'b1;
end

wire [7:0] c3;
wire [7:0] c2;
wire [7:0] c1;
wire [7:0] c0;
BCD B3(TX_buf_out_tag, c3);
BCD B2(UART_TXD[3:0], c2);
BCD B1(RX_buf_in_tag, c1);
BCD B0(UART_RXD[3:0], c0);

always @(sta)
begin
	case (sta)
	2'b00: begin digi[11:8]<=4'b1110; digi[7:0]<=c0; end
	2'b01: begin digi[11:8]<=4'b1101; digi[7:0]<=c1; end
	2'b10: begin digi[11:8]<=4'b1011; digi[7:0]<=c2; end
	2'b11: begin digi[11:8]<=4'b0111; digi[7:0]<=c3; end
	endcase
end

//digi test end
*/
always@(*) begin
	if(rd) begin
		case(addr)
			32'h40000000: rdata <= TH;			
			32'h40000004: rdata <= TL;			
			32'h40000008: rdata <= {29'b0,TCON};				
			32'h4000000C: rdata <= {24'b0,led};			
			32'h40000010: rdata <= {24'b0,switch};
			32'h40000014: rdata <= {20'b0,digi};
			32'h40000018: rdata <= {24'b0,UART_TXD};
			32'h4000001C: rdata <= {24'b0,UART_RXD}; 
			default: rdata <= 32'b0;
		endcase
	end
end

always@(posedge reset or posedge clk) begin
	if(reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;	
		RX_buf_out_tag <= 0;
		UART_CON[3] <= 0;
		UART_RXD <= 0;
		UART_CON[2] <= 0;
		UART_TXD <= 0;
		TX_buf_in_tag <= 0;
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			end
			else TL <= TL + 1;
		end
		
		if(wr&&addr!=32'h40000018) begin
			case(addr)
				32'h40000000: TH <= wdata;
				32'h40000004: TL <= wdata;
				32'h40000008: TCON <= wdata[2:0];		
				32'h4000000C: led <= wdata[7:0];			
				32'h40000014: digi <= wdata[11:0];
				32'h40000020: UART_CON[1:0] <= wdata[1:0]; //only write control bits
				default: ;
			endcase
		end

		//UART_TXD->TX_buffer
		if(wr&&addr==32'h40000018)
			begin 
			UART_TXD <= wdata[7:0]; 
			TX_buffer[TX_buf_in_tag] <= wdata[7:0];
			TX_buf_in_tag <= TX_buf_in_tag + 1;
			end
		else if (rd&&addr==32'h40000018)
			begin
			UART_CON[2] <= 0;
			end
		else if (TX_complete)
			UART_CON[2] <= 1;
			

		//RX_buffer->UART_RXD
		if (rd&&addr==32'h4000001C&&UART_CON[3])
			UART_CON[3] <= 0;
		else if (UART_CON[3]==0&&RX_buf_num!=0)
			begin
			UART_RXD <= RX_buffer[RX_buf_out_tag];
			RX_buf_out_tag <= RX_buf_out_tag + 1;
			UART_CON[3] <= 1;
			end

	end
end

//UART:
UARTReciever re(reset, sysclk, RX, RX_STATUS, RX_DATA);
UARTSender se(reset,sysclk,TX_EN,TX_DATA,TX_STATUS,TX);

reg [1:0]flag=2'b11;
//Receiver->RX_buffer + TX_buffer->Sender
always@(negedge sysclk or posedge reset)
begin
if (reset) begin RX_buf_in_tag<=0;flag<=2'b11; end
else if (RX_STATUS)	//Receiver->RX_buffer
	begin 
	RX_buffer[RX_buf_in_tag] <= RX_DATA;
	RX_buf_in_tag <= RX_buf_in_tag + 1;
	end

if (reset) begin TX_buf_out_tag<=0; TX_EN<=0;TX_complete<=0;end
else 
	begin
	if (TX_buf_num!=0&&TX_STATUS)	//TX_buffer->Sender
		begin
			TX_DATA <= TX_buffer[TX_buf_out_tag];
			TX_buf_out_tag <= TX_buf_out_tag + 1;
			TX_EN <= 1;
		end
	else if (TX_EN&&TX_STATUS) TX_EN <= 0;
	
	flag[0]<=TX_STATUS; flag[1]<=flag[0];
	if (flag==2'b01) TX_complete <= 1;
	else if (flag==2'b00&&UART_CON[2]==0) TX_complete<=0;
	end
	
end 

always @*
begin
UART_CON[4]<=~TX_STATUS;
RX_buf_num<=RX_buf_in_tag - RX_buf_out_tag;
TX_buf_num<=TX_buf_in_tag - TX_buf_out_tag;
end


endmodule


////////////////////////////////////////////////////////////////////////////////
module UARTReciever (reset, sysclk, RX, RX_STATUS, RX_DATA);
input reset, sysclk, RX;
output reg RX_STATUS;
output reg [7:0] RX_DATA;

reg enable = 0;
reg [16:0] count = 1;
//if peroid = T * sysclk, then when count=T, let count=1

always @(posedge reset or posedge sysclk)
begin
if (reset)
	begin 
		RX_STATUS <= 0;
		RX_DATA <= 0;
		enable <= 0;
		count <= 1;
	end
else
	begin
		if (enable==0)
			begin 
			if (RX)
				begin
				RX_STATUS <= 0;
				enable <= 0;
				count <= 1;
				end
			else
				begin
				enable <= 1;
				count <= 1;
				end
			end
		else
			begin
				if (count==15624)//(8+16)*651 = 15624
					begin
					RX_DATA[0] <= RX;
					count <= count + 1;
					end
				else if (count==26040)
					begin
					RX_DATA[1] <= RX;
					count <= count + 1;
					end
				else if (count==36456)
					begin
					RX_DATA[2] <= RX;
					count <= count + 1;
					end
				else if (count==46872)
					begin
					RX_DATA[3] <= RX;
					count <= count + 1;
					end
				else if (count==57288)
					begin
					RX_DATA[4] <= RX;
					count <= count + 1;
					end
				else if (count==67704)
					begin
					RX_DATA[5] <= RX;
					count <= count + 1;
					end
				else if (count==78120)
					begin
					RX_DATA[6] <= RX;
					count <= count + 1;
					end
				else if (count==88536)
					begin
					RX_DATA[7] <= RX;
					count <= count + 1;
					end
				else if (count==98952)//(16*9+8)*651 = 98952
					begin
					RX_STATUS <= 1;
					count <= count + 1;
					end
				else if (count==98953)
					begin
					RX_STATUS <= 0;
					enable <= 0;
					count <= 1;
					end
				else count <= count + 1;
			end
	end
end
endmodule



////////////////////////////////////////////////////////////////////////////////

module UARTSender(reset,sysclk,TX_EN,TX_DATA,TX_STATUS,TX);
input reset,sysclk,TX_EN;
input [7:0]TX_DATA;
output TX_STATUS;
output reg TX;

reg [7:0]data = 0;
reg enable = 0;	//sender is working
assign TX_STATUS = !enable;
reg [17:0] count = 1;
//if peroid = T * sysclk, then when count=T, let count=1
always@(posedge reset or posedge sysclk)
begin
if (reset)
	begin
		TX <= 1;
		enable <= 0;
		data <= 0;
		count <= 1;
	end
else
	begin
		if (enable==0)
			begin
				if (TX_EN)
					begin
						TX <= 0;
						enable <= 1;
						count <= 1;
						data <= TX_DATA;
					end
				else
					begin
						TX <= 1;
						enable <= 0;
						data <= 0;
						count <= 1;
					end
			end
		else
			begin
				if (count==10416)//1*16*651=10416
					begin
						TX <= data[0];
						count <= count+1;
					end
				else if (count==20832)
					begin
						TX <= data[1];
						count <= count+1;
					end
				else if (count==31248)
					begin
						TX <= data[2];
						count <= count+1;
					end
				else if (count==41664)
					begin
						TX <= data[3];
						count <= count+1;
					end
				else if (count==52080)
					begin
						TX <= data[4];
						count <= count+1;
					end
				else if (count==62496)
					begin
						TX <= data[5];
						count <= count+1;
					end
				else if (count==72912)
					begin
						TX <= data[6];
						count <= count+1;
					end
				else if (count==83328)
					begin
						TX <= data[7];
						count <= count+1;
					end
				else if (count==93744)//9*16*651=93744
					begin
						TX <= 1;
						count <= count+1;
					end
				else if (count==104160)//10*16*651=104160
					begin
						TX <= 1;
						count <= 1;
						enable <= 0;
					end
				else count <= count+1;
			end
	end
end

endmodule

module RegFile (reset,clk,addr1,data1,addr2,data2,wr,addr3,data3);
input reset,clk;
input wr;
input [4:0] addr1,addr2,addr3;
output [31:0] data1,data2;
input [31:0] data3;

reg [31:0] RF_DATA[31:1];
integer i;

assign data1=(addr1==5'b0)?32'b0:RF_DATA[addr1];	//$0 MUST be all zeros
assign data2=(addr2==5'b0)?32'b0:RF_DATA[addr2];

always@(posedge reset or posedge clk) begin
	if(reset) begin
		for(i=1;i<32;i=i+1) RF_DATA[i]<=32'b0;
	end
	else begin
		if(wr && addr3) RF_DATA[addr3] <= data3;
	end
end
endmodule


module ROM (addr,data);
input [31:0] addr;
output [31:0] data;
reg [31:0] data;
localparam ROM_SIZE = 32;
reg [31:0] ROM_DATA[ROM_SIZE-1:0];

always@(*)
	case(addr[9:2])	//Address Must Be Word Aligned.
/*0: data <= 32'h08000087;
1: data <= 32'h08000005;
2: data <= 32'h0800005e;
3: data <= 32'h08000063;
4: data <= 32'h08000067;
5: data <= 32'h3c084000;
6: data <= 32'h21080008;
7: data <= 32'h8d090000;
8: data <= 32'h3129fff9;
9: data <= 32'had090000;
10: data <= 32'h200f00fc;
11: data <= 32'h8dea0000;
12: data <= 32'h8d0b000c;
13: data <= 32'h000b5a02;
14: data <= 32'h316c0001;
15: data <= 32'h000c60c0;
16: data <= 32'h000b5842;
17: data <= 32'h016c5825;
18: data <= 32'h01606020;
19: data <= 32'h318d0008;
20: data <= 32'h11a00004;
21: data <= 32'h000d6842;
22: data <= 32'h000a5102;
23: data <= 32'h01ac6824;
24: data <= 32'h08000014;
25: data <= 32'h314a000f;
26: data <= 32'h000b5a00;
27: data <= 32'h200e0000;
28: data <= 32'h114e001d;
29: data <= 32'h200e0001;
30: data <= 32'h114e001d;
31: data <= 32'h200e0002;
32: data <= 32'h114e001d;
33: data <= 32'h200e0003;
34: data <= 32'h114e001d;
35: data <= 32'h200e0004;
36: data <= 32'h114e001d;
37: data <= 32'h200e0005;
38: data <= 32'h114e001d;
39: data <= 32'h200e0006;
40: data <= 32'h114e001d;
41: data <= 32'h200e0007;
42: data <= 32'h114e001d;
43: data <= 32'h200e0008;
44: data <= 32'h114e001d;
45: data <= 32'h200e0009;
46: data <= 32'h114e001d;
47: data <= 32'h200e000a;
48: data <= 32'h114e001d;
49: data <= 32'h200e000b;
50: data <= 32'h114e001d;
51: data <= 32'h200e000c;
52: data <= 32'h114e001d;
53: data <= 32'h200e000d;
54: data <= 32'h114e001d;
55: data <= 32'h200e000e;
56: data <= 32'h114e001d;
57: data <= 32'h08000058;
58: data <= 32'h216b00fc;
59: data <= 32'h0800005a;
60: data <= 32'h216b0060;
61: data <= 32'h0800005a;
62: data <= 32'h216b00da;
63: data <= 32'h0800005a;
64: data <= 32'h216b00f2;
65: data <= 32'h0800005a;
66: data <= 32'h216b0066;
67: data <= 32'h0800005a;
68: data <= 32'h216b00b6;
69: data <= 32'h0800005a;
70: data <= 32'h216b00be;
71: data <= 32'h0800005a;
72: data <= 32'h216b00e0;
73: data <= 32'h0800005a;
74: data <= 32'h216b00fe;
75: data <= 32'h0800005a;
76: data <= 32'h216b00f6;
77: data <= 32'h0800005a;
78: data <= 32'h216b00ee;
79: data <= 32'h0800005a;
80: data <= 32'h216b00ff;
81: data <= 32'h0800005a;
82: data <= 32'h216b009c;
83: data <= 32'h0800005a;
84: data <= 32'h216b00fd;
85: data <= 32'h0800005a;
86: data <= 32'h216b009e;
87: data <= 32'h0800005a;
88: data <= 32'h216b008e;
89: data <= 32'h0800005a;
90: data <= 32'had0b000c;
91: data <= 32'h21290002;
92: data <= 32'had090000;
93: data <= 32'h03400008;
94: data <= 32'h3c084000;
95: data <= 32'h21080018;
96: data <= 32'h2009005a;
97: data <= 32'had090000;
98: data <= 32'h03400008;
99: data <= 32'h3c084000;
100: data <= 32'h21080018;
101: data <= 32'h8d090000;
102: data <= 32'h03400008;
103: data <= 32'h3c084000;
104: data <= 32'h2108001c;
105: data <= 32'h8d090000;
106: data <= 32'h200a00fc;
107: data <= 32'h8d4b0000;
108: data <= 32'h000b6402;
109: data <= 32'h15800004;
110: data <= 32'h3c0b0001;
111: data <= 32'h01695820;
112: data <= 32'had4b0000;
113: data <= 32'h03400008;
114: data <= 32'h00094a00;
115: data <= 32'h01695820;
116: data <= 32'h000b5c00;
117: data <= 32'h000b5c02;
118: data <= 32'had4b0000;
119: data <= 32'h316e00ff;
120: data <= 32'h316fff00;
121: data <= 32'h000f7a02;
122: data <= 32'h11e00007;
123: data <= 32'h01ee6822;
124: data <= 32'h1da00001;
125: data <= 32'h01cf7022;
126: data <= 32'h000e6820;
127: data <= 32'h000f7020;
128: data <= 32'h000d7820;
129: data <= 32'h0800007a;
130: data <= 32'h3c084000;
131: data <= 32'h2108000c;
132: data <= 32'had0e0000;
133: data <= 32'had0e000c;
134: data <= 32'h03400008;
135: data <= 32'h3c084000;
136: data <= 32'h200907ff;
137: data <= 32'had090014;
138: data <= 32'had00000c;
139: data <= 32'h3c09fffe;
140: data <= 32'h2129795f;
141: data <= 32'had090000;
142: data <= 32'h00004827;
143: data <= 32'had090004;
144: data <= 32'h20090003;
145: data <= 32'had090008;
146: data <= 32'h20090002;
147: data <= 32'had090020;
148: data <= 32'h200a0254;
149: data <= 32'h01400008;
150: data <= 32'hfac23e4e;
151: data <= 32'h08000097;*/
8'd0: data <= 32'h08000087;	// j	 entry_main
8'd1: data <= 32'h08000005;	// j	 timer_interrupt_main
8'd2: data <= 32'h0800005e;	// j	 exception_main
8'd3: data <= 32'h08000063;	// j	 uart_send_interrupt_main
8'd4: data <= 32'h08000067;	// j	 uart_recv_interrupt_main
8'd5: data <= 32'h3c084000;	// lui	 $t0, 0x4000
8'd6: data <= 32'h21080008;	// addi	 $t0, $t0, 0x0008
8'd7: data <= 32'h8d090000;	// lw	 $t1, 0, $t0
8'd8: data <= 32'h3129fff9;	// andi	 $t1, $t1, 0xfff9
8'd9: data <= 32'had090000;	// sw	 $t1, 0, $t0
8'd10: data <= 32'h200f00fc;	// addi	 $t7, $zero, 0x00fc
8'd11: data <= 32'h8dea0000;	// lw	 $t2, 0, $t7
8'd12: data <= 32'h8d0b000c;	// lw	 $t3, 12, $t0
8'd13: data <= 32'h000b5a02;	// srl	 $t3, $t3, 8
8'd14: data <= 32'h316c0001;	// andi	 $t4, $t3, 0x0001
8'd15: data <= 32'h000c60c0;	// sll	 $t4, $t4, 3
8'd16: data <= 32'h000b5842;	// srl	 $t3, $t3, 1
8'd17: data <= 32'h016c5825;	// or	 $t3, $t3, $t4
8'd18: data <= 32'h01606020;	// add	 $t4, $t3, $zero
8'd19: data <= 32'h318d0008;	// andi	 $t5, $t4, 0x0008
8'd20: data <= 32'h11a00004;	// beq	 $t5, $zero, ti_getnum
8'd21: data <= 32'h000d6842;	// srl	 $t5, $t5, 1
8'd22: data <= 32'h000a5102;	// srl	 $t2, $t2, 4
8'd23: data <= 32'h01ac6824;	// and	 $t5, $t5, $t4
8'd24: data <= 32'h08000014;	// j	 ti_right_shift_loop
8'd25: data <= 32'h314a000f;	// andi	 $t2, $t2, 0x000f
8'd26: data <= 32'h000b5a00;	// sll	 $t3, $t3, 8
8'd27: data <= 32'h200e0000;	// addi	 $t6, $zero, 0x0
8'd28: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_n0
8'd29: data <= 32'h200e0001;	// addi	 $t6, $zero, 0x1
8'd30: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_n1
8'd31: data <= 32'h200e0002;	// addi	 $t6, $zero, 0x2
8'd32: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_n2
8'd33: data <= 32'h200e0003;	// addi	 $t6, $zero, 0x3
8'd34: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_n3
8'd35: data <= 32'h200e0004;	// addi	 $t6, $zero, 0x4
8'd36: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_n4
8'd37: data <= 32'h200e0005;	// addi	 $t6, $zero, 0x5
8'd38: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_n5
8'd39: data <= 32'h200e0006;	// addi	 $t6, $zero, 0x6
8'd40: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_n6
8'd41: data <= 32'h200e0007;	// addi	 $t6, $zero, 0x7
8'd42: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_n7
8'd43: data <= 32'h200e0008;	// addi	 $t6, $zero, 0x8
8'd44: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_n8
8'd45: data <= 32'h200e0009;	// addi	 $t6, $zero, 0x9
8'd46: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_n9
8'd47: data <= 32'h200e000a;	// addi	 $t6, $zero, 0xa
8'd48: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_na
8'd49: data <= 32'h200e000b;	// addi	 $t6, $zero, 0xb
8'd50: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_nb
8'd51: data <= 32'h200e000c;	// addi	 $t6, $zero, 0xc
8'd52: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_nc
8'd53: data <= 32'h200e000d;	// addi	 $t6, $zero, 0xd
8'd54: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_nd
8'd55: data <= 32'h200e000e;	// addi	 $t6, $zero, 0xe
8'd56: data <= 32'h114e001d;	// beq	 $t2, $t6, ti_ne
8'd57: data <= 32'h08000058;	// j	 ti_nf
8'd58: data <= 32'h216b00fc;	// addi	 $t3, $t3, 0x00fc
8'd59: data <= 32'h0800005a;	// j	 ti_display
8'd60: data <= 32'h216b0060;	// addi	 $t3, $t3, 0x0060
8'd61: data <= 32'h0800005a;	// j	 ti_display
8'd62: data <= 32'h216b00da;	// addi	 $t3, $t3, 0x00da
8'd63: data <= 32'h0800005a;	// j	 ti_display
8'd64: data <= 32'h216b00f2;	// addi	 $t3, $t3, 0x00f2
8'd65: data <= 32'h0800005a;	// j	 ti_display
8'd66: data <= 32'h216b0066;	// addi	 $t3, $t3, 0x0066
8'd67: data <= 32'h0800005a;	// j	 ti_display
8'd68: data <= 32'h216b00b6;	// addi	 $t3, $t3, 0x00b6
8'd69: data <= 32'h0800005a;	// j	 ti_display
8'd70: data <= 32'h216b00be;	// addi	 $t3, $t3, 0x00be
8'd71: data <= 32'h0800005a;	// j	 ti_display
8'd72: data <= 32'h216b00e0;	// addi	 $t3, $t3, 0x00e0
8'd73: data <= 32'h0800005a;	// j	 ti_display
8'd74: data <= 32'h216b00fe;	// addi	 $t3, $t3, 0x00fe
8'd75: data <= 32'h0800005a;	// j	 ti_display
8'd76: data <= 32'h216b00f6;	// addi	 $t3, $t3, 0x00f6
8'd77: data <= 32'h0800005a;	// j	 ti_display
8'd78: data <= 32'h216b00ee;	// addi	 $t3, $t3, 0x00ee
8'd79: data <= 32'h0800005a;	// j	 ti_display
8'd80: data <= 32'h216b00ff;	// addi	 $t3, $t3, 0x00ff
8'd81: data <= 32'h0800005a;	// j	 ti_display
8'd82: data <= 32'h216b009c;	// addi	 $t3, $t3, 0x009c
8'd83: data <= 32'h0800005a;	// j	 ti_display
8'd84: data <= 32'h216b00fd;	// addi	 $t3, $t3, 0x00fd
8'd85: data <= 32'h0800005a;	// j	 ti_display
8'd86: data <= 32'h216b009e;	// addi	 $t3, $t3, 0x009e
8'd87: data <= 32'h0800005a;	// j	 ti_display
8'd88: data <= 32'h216b008e;	// addi	 $t3, $t3, 0x008e
8'd89: data <= 32'h0800005a;	// j	 ti_display
8'd90: data <= 32'had0b000c;	// sw	 $t3, 12, $t0
8'd91: data <= 32'h21290002;	// addi	 $t1, $t1, 2
8'd92: data <= 32'had090000;	// sw	 $t1, 0, $t0
8'd93: data <= 32'h03400008;	// jr	 $26
8'd94: data <= 32'h3c084000;	// lui	 $t0, 0x4000
8'd95: data <= 32'h21080018;	// addi	 $t0, $t0, 0x0018
8'd96: data <= 32'h2009005a;	// addi	 $t1, $zero, 0x005a
8'd97: data <= 32'had090000;	// sw	 $t1, 0, $t0
8'd98: data <= 32'h03400008;	// jr	 $26
8'd99: data <= 32'h3c084000;	// lui	 $t0, 0x4000
8'd100: data <= 32'h21080018;	// addi	 $t0, $t0, 0x0018
8'd101: data <= 32'h8d090000;	// lw	 $t1, 0, $t0
8'd102: data <= 32'h03400008;	// jr	 $26
8'd103: data <= 32'h3c084000;	// lui	 $t0, 0x4000
8'd104: data <= 32'h2108001c;	// addi	 $t0, $t0, 0x001c
8'd105: data <= 32'h8d090000;	// lw	 $t1, 0, $t0
8'd106: data <= 32'h200a00fc;	// addi	 $t2, $zero, 0x00fc
8'd107: data <= 32'h8d4b0000;	// lw	 $t3, 0, $t2
8'd108: data <= 32'h000b6402;	// srl	 $t4, $t3, 16
8'd109: data <= 32'h15800004;	// bne	 $t4, $zero, ur_gcd_start
8'd110: data <= 32'h3c0b0001;	// lui	 $t3, 0x0001
8'd111: data <= 32'h01695820;	// add	 $t3, $t3, $t1
8'd112: data <= 32'had4b0000;	// sw	 $t3, 0, $t2
8'd113: data <= 32'h03400008;	// jr	 $26
8'd114: data <= 32'h00094a00;	// sll	 $t1, $t1, 8
8'd115: data <= 32'h01695820;	// add	 $t3, $t3, $t1
8'd116: data <= 32'h000b5c00;	// sll	 $t3, $t3, 16
8'd117: data <= 32'h000b5c02;	// srl	 $t3, $t3, 16
8'd118: data <= 32'had4b0000;	// sw	 $t3, 0, $t2
8'd119: data <= 32'h316e00ff;	// andi	 $t6, $t3, 0x00ff
8'd120: data <= 32'h316fff00;	// andi	 $t7, $t3, 0xff00
8'd121: data <= 32'h000f7a02;	// srl	 $t7, $t7, 8
8'd122: data <= 32'h11e00007;	// beq	 $t7, $zero, ur_gcd_end
8'd123: data <= 32'h01ee6822;	// sub	 $t5, $t7, $t6
8'd124: data <= 32'h1da00001;	// bgtz	 $t5, ur_gcd_main_swap
8'd125: data <= 32'h01cf7022;	// sub	 $t6, $t6, $t7
8'd126: data <= 32'h000e6820;	// add	 $t5, $zero, $t6
8'd127: data <= 32'h000f7020;	// add	 $t6, $zero, $t7
8'd128: data <= 32'h000d7820;	// add	 $t7, $zero, $t5
8'd129: data <= 32'h0800007a;	// j	 ur_gcd_main
8'd130: data <= 32'h3c084000;	// lui	 $t0, 0x4000
8'd131: data <= 32'h2108000c;	// addi	 $t0, $t0, 0x000c
8'd132: data <= 32'had0e0000;	// sw	 $t6, 0, $t0
8'd133: data <= 32'had0e000c;	// sw	 $t6, 12, $t0
8'd134: data <= 32'h03400008;	// jr	 $26
8'd135: data <= 32'h3c084000;	// lui	 $t0, 0x4000
8'd136: data <= 32'h200907ff;	// addi	 $t1, $zero, 0x07ff
8'd137: data <= 32'had090014;	// sw	 $t1, 0x14, $t0
8'd138: data <= 32'had00000c;	// sw	 $zero, 0x0c, $t0
8'd139: data <= 32'h3c09fffe;	// lui	 $t1, 0xfffe
8'd140: data <= 32'h2129795f;	// addi	 $t1, $t1, 0x795f
8'd141: data <= 32'had090000;	// sw	 $t1, 0, $t0
8'd142: data <= 32'h00004827;	// nor	 $t1, $0, $0
8'd143: data <= 32'had090004;	// sw	 $t1, 0x04, $t0
8'd144: data <= 32'h20090003;	// addi	 $t1, $zero, 0x0003
8'd145: data <= 32'had090008;	// sw	 $t1, 0x08, $t0
8'd146: data <= 32'h20090002;	// addi	 $t1, $zero, 0x0002
8'd147: data <= 32'had090020;	// sw	 $t1, 0x20, $t0
8'd148: data <= 32'h200a0258;	// addi	 $t2, $zero, 0x0258
8'd149: data <= 32'h01400008;	// jr	 $t2
8'd150: data <= 32'hfac23e4e;
8'd151: data <= 32'h08000097;	// j	 main_loop


		
		
	   default:	data <= 32'h08000097;
	endcase
endmodule


module BCD(din,dout
    );
input [3:0] din;
output [7:0] dout;

wire [7:0] dout1;

assign dout=dout1;

assign dout1=(din==0)?8'b1111_1100:
            (din==1)?8'b0110_0000:
            (din==2)?8'b110_11010:
            (din==3)?8'b111_10010:
            (din==4)?8'b011_00110:
            (din==5)?8'b101_10110:
            (din==6)?8'b101_11110:
            (din==7)?8'b111_00000:
            (din==8)?8'b111_11110:
            (din==9)?8'b111_10110:
				(din==10)?8'b1110_1110:
				(din==11)?8'b1111_1111:
				(din==12)?8'b1001_1100:
				(din==13)?8'b1111_1101:
				(din==14)?8'b1001_1110:
				(din==15)?8'b1000_1110:8'b0;

endmodule
