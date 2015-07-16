`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:36:31 05/20/2015 
// Design Name: 
// Module Name:    BCD 
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