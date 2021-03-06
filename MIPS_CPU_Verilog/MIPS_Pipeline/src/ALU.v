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

	ALUADD adder(A, B, ALUFun[0], Sign, outcome0, Z, V, N);
	ALULogic logicer(A, B, ALUFun[3:0], outcome1);
	ALUShift shifter(A[4:0], B, ALUFun[1:0], outcome2);
	ALUCMP cmper(Z, N, A, ALUFun[3:1], outcome3);
	ALUMUX muxer(outcome0, outcome1, outcome2, outcome3, ALUFun[5:4], result);
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
					layer4[31:16] <= (A[4] == 1)? B[15:0] : B[31:16];
					layer4[15:0] <= (A[4] == 1)? 16'b0 : B[15:0];
					layer3[31:8] <= (A[3] == 1)? layer4[23:0] : layer4[31:8];
					layer3[7:0] <= (A[3] == 1)? 8'b0 : layer4[7:0];
					layer2[31:4] <= (A[2] == 1)? layer3[27:0] : layer3[31:4];
					layer2[3:0] <= (A[2] == 1)? 4'b0 : layer3[3:0];
					layer1[31:2] <= (A[1] == 1)? layer2[29:0] : layer2[31:2];
					layer1[1:0] <= (A[1] == 1)? 2'b0 : layer2[1:0];
					result[31:1] <= (A[0] == 1)? layer1[30:0] : layer1[31:1];
					result[0] <= (A[0] == 1)? 1'b0 : layer1[0];
				end
			2'b01:
				begin
					layer4[31:16] <= (A[4] == 1)? 16'b0 : B[31:16];
					layer4[15:0] <= (A[4] == 1)? B[31:16] : B[15:0];
					layer3[31:24] <= (A[3] == 1)? 8'b0 : layer4[31:24];
					layer3[23:0] <= (A[3] == 1)? layer4[31:8] : layer4[23:0];
					layer2[31:28] <= (A[2] == 1)? 4'b0 : layer3[31:28];
					layer2[27:0] <= (A[2] == 1)? layer3[31:4] : layer3[27:0];
					layer1[31:30] <= (A[1] == 1)? 2'b0 : layer2[31:30];
					layer1[29:0] <= (A[1] == 1)? layer2[31:2] : layer2[29:0];
					result[31] <= (A[0] == 1)? 1'b0 : layer1[31];
					result[30:0] <= (A[0] == 1)? layer1[31:1] : layer1[30:0];
				end
			2'b11:
				begin
					if(B[31]==0)
						begin
							layer4[31:16] <= (A[4] == 1)? 16'b0 : B[31:16];
							layer4[15:0] <= (A[4] == 1)? B[31:16] : B[15:0];
							layer3[31:24] <= (A[3] == 1)? 8'b0 : layer4[31:24];
							layer3[23:0] <= (A[3] == 1)? layer4[31:8] : layer4[23:0];
							layer2[31:28] <= (A[2] == 1)? 4'b0 : layer3[31:28];
							layer2[27:0] <= (A[2] == 1)? layer3[31:4] : layer3[27:0];
							layer1[31:30] <= (A[1] == 1)? 2'b0 : layer2[31:30];
							layer1[29:0] <= (A[1] == 1)? layer2[31:2] : layer2[29:0];
							result[31] <= (A[0] == 1)? 1'b0 : layer1[31];
							result[30:0] <= (A[0] == 1)? layer1[31:1] : layer1[30:0];
						end
					else
						begin
							layer4[31:16]  <= (A[4] == 1)? 16'b1111_1111_1111_1111 : B[31:16];
							layer4[15:0] <= (A[4] == 1)? B[31:16] : B[15:0];
							layer3[31:24] <= (A[3] == 1)? 8'b1111_1111 : layer4[31:24];
							layer3[23:0] <= (A[3] == 1)? layer4[31:8] : layer4[23:0];
							layer2[31:28] <= (A[2] == 1)? 4'b1111 : layer3[31:28];
							layer2[27:0] <= (A[2] == 1)? layer3[31:4] : layer3[27:0];
							layer1[31:30] <= (A[1] == 1)? 2'b11 : layer2[31:30];
							layer1[29:0] <= (A[1] == 1)? layer2[31:2] : layer2[29:0];
							result[31] <= (A[0] == 1)? 1'b1 : layer1[31];
							result[30:0] <= (A[0] == 1)? layer1[31:1] : layer1[30:0];
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
			2'b00:out <= in0;
			2'b01:out <= in1;
			2'b10:out <= in2;
			2'b11:out <= in3;
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
				4'b1000:result <= A&B;
				4'b1110:result <= A|B;
				4'b0110:result <= A^B;
				4'b0001:result <= ~(A|B);
				4'b1010:result <= A;
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
				3'b001:result <= (Z==1)? 1 : 0;
				3'b000:result <= (Z==0)? 1 : 0;
				3'b010:result <= (N==1)? 1 : 0;
				3'b110:result <= (A[31]==1||A==0)? 1 : 0;
				3'b100:result <= (A[31]==0)? 1 : 0;
				3'b111:result <= (A[31]==0&&A!=0)? 1 : 0;
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

	assign Z = (result==0)? 1'b1 : 1'b0;
	always @*
		begin
			if (Sign==1 || (Sign==0 && (
				(A[31]==1&&B[31]==1) || 
				(A[31]==0&&B[31]==0) ))) N <= result[31];
			else if (A[31]==0&&B[31]==1) N <= 1;
			else N <= 0;
		end

	reg [31:0]C;
	reg [31:0]D;
	always @*
		begin
			D <= ~B;
			C <= D+1;
		end

	always @*
		begin
			if (ctrl == 0) result <= A+B;
			else result <= A+C;
		end

	wire carry1;
	wire carry0;
	assign carry1 = ((A[31]==1&&B[31]==1)||(A[31]==1&&B[31]==0&&result[31]==0)
			||(A[31]==0&&B[31]==1&&result[31]==0)
			||A[31]==0&&B[31]==0&&result[31]==1)? 1'b1 : 1'b0;
	assign carry0 = ((A[30]==1&&B[31]==1)||(A[30]==1&&B[30]==0&&result[30]==0)
			||(A[30]==0&&B[30]==1&&result[30]==0)
			||A[30]==0&&B[30]==0&&result[30]==1)? 1'b1 : 1'b0;
	assign V = (Sign==1)? (carry1^carry0) : carry1;
endmodule
