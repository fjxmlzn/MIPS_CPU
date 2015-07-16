`timescale 1ns / 1ns
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
