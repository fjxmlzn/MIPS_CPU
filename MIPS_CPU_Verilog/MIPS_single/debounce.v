`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:17:42 04/17/2015 
// Design Name: 
// Module Name:    debounce 
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
module debounce(clk,key_i,key_o);
    input clk;
    input key_i;
    output key_o;

    parameter NUMBER = 24'd10_00;  //delay 0.1s
    parameter NBITS = 24;

    reg [NBITS-1:0] count;
    reg key_o_temp;

    reg key_m;
	reg key_i_t1,key_i_t2;

    assign key_o = key_o_temp;
	
	always @ (posedge clk) begin
		key_i_t1 <= key_i;
		key_i_t2 <= key_i_t1;
	end

    always @ (posedge clk) begin
        if (key_m!=key_i_t2) begin
            key_m <= key_i_t2;
            count <= 0;
        end
        else if (count == NUMBER) begin
            key_o_temp <= key_m;
        end
        else count <= count+1;
    end
endmodule

