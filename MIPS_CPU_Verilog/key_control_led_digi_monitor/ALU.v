`timescale 1ns / 1ns
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

ALUADD adder(A,B,ALUFun[0],Sign,outcome0,Z,V,N);
ALULogic logicer(A,B,ALUFun[3:0],outcome1);
ALUShift shifter(A[4:0],B,ALUFun[1:0],outcome2);
ALUCMP cmper(Z,N,A,ALUFun[3:1],outcome3);
ALUMUX muxer(outcome0,outcome1,outcome2,outcome3,ALUFun[5:4],result);
endmodule