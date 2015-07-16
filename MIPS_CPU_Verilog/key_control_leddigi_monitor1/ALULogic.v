`timescale 1ns / 1ns
module ALULogic(A,B,ctrl,result);
input [31:0]A;
input [31:0]B;
input [3:0]ctrl;
output reg[31:0]result;

always @*
begin
	case(ctrl)
	4'b1000:result<=A&B;
	4'b1110:result<=A|B;	4'b0110:result<=A^B;
	4'b0001:result<=~(A|B);
	4'b1010:result<=A;
	endcase
end
endmodule
