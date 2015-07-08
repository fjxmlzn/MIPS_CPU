`timescale 1ns / 1ns
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
