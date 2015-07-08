`timescale 1ns / 1ns
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
		end	end
	endcaseend
endmodule
