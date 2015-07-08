`timescale 1ns / 1ns
module tb;
	//INPUTS
	reg [31:0]A;
	reg [31:0]B;
	reg [5:0]ALUFun;
	reg Sign;
	//OUTPUTS
	wire [31:0]result;
	//Instantiate the Unit Under Test(UUT)
	ALU a(A,B,ALUFun,Sign,result);

reg clk;
integer state;
reg clkcount;
reg[6:0] clkstate;
initial begin
	A=32'h0000_e129;B=32'hffff_1edf;ALUFun=0;Sign=1;clk=0;state=0;clkcount=0;clkstate=0;
	//Wait 100ns for global reset to finish
	#100;
	// Add stimulus here
	forever
	#1 clk = !clk;
end

always@(posedge clk)
begin
if (clkstate<50) clkstate<=clkstate+1;
else
	begin
	clkstate<=0;clkcount<=~clkcount;
	endend

always@(posedge clkcount)//
begin
if (state < 1)	//ADD
	begin
	ALUFun<=6'b000000;state<=state+1;
	end
else if (state < 2)	//SUB
	begin
	ALUFun<=6'b000001;state<=state+1;
	end
else if (state < 3)	//AND
	begin
	ALUFun<=6'b011000;state<=state+1;
	end
else if (state < 4)	//OR
	begin
	ALUFun<=6'b011110;state<=state+1;
	end
else if (state < 5)	//XOR
	begin
	ALUFun<=6'b010110;state<=state+1;
	end
else if (state < 6)	//NOR
	begin
	ALUFun<=6'b010001;state<=state+1;
	end
else if (state < 7)	//"A"
	begin
	ALUFun<=6'b011010;state<=state+1;
	end
else if (state < 8)	//SLL
	begin
	ALUFun<=6'b100000;state<=state+1;
	end
else if (state < 9)	//SRL
	begin
	ALUFun<=6'b100001;state<=state+1;
	end
else if (state < 10)	//SRA
	begin
	ALUFun<=6'b100011;state<=state+1;
	end
else if (state < 11)	//EQ
	begin
	ALUFun<=6'b110011;state<=state+1;
	end
else if (state < 12)	//NEQ
	begin
	ALUFun<=6'b110001;state<=state+1;
	end
else if (state < 13)	//LT
	begin
	ALUFun<=6'b110101;state<=state+1;
	end
else if (state < 14)	//LEZ
	begin
	ALUFun<=6'b111101;state<=state+1;
	end
else if (state < 15)	//GEZ
	begin
	ALUFun<=6'b111001;state<=state+1;
	end
else if (state < 16)	//GTZ
	begin
	ALUFun<=6'b111111;state<=state+1;
	end
else
	begin
	state<=0;Sign<=!Sign;
	end
end

endmodule




