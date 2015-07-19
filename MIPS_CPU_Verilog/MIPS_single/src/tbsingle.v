`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:02:40 07/09/2015
// Design Name:   CPU
// Module Name:   E:/CPU/cpu/single/single/tbsingle.v
// Project Name:  single
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CPU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tbsingle;

	// Inputs
	reg reset;
	reg clk;
	
	reg [7:0] switch;
	reg RX;

	// Outputs
	wire [7:0] bcd;
	wire [3:0] an;
	wire TX;
	wire [7:0] led;
	// Instantiate the Unit Under Test (UUT)
	CPU uut (
		.reset(reset), 
		.clk(clk), 
		.switch(switch), 
		.bcd(bcd), 
		.an(an), 
		.RX(RX), 
		.TX(TX),
		.led(led)
	);

	initial begin
		// Initialize Inputs
		reset = 0;
		clk = 0;
		switch = 0;
		RX = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		fork 
		forever #5 clk=~clk;
		#10 reset=1;
		#50 reset=0;
		join
	end
	
   initial 
	begin
	#104167 RX=0;
	#104167 RX=0;
	#104167 RX=1;
	#104167 RX=0;
	#104167 RX=0;
	#104167 RX=1;
	#104167 RX=0;
	#104167 RX=1;
	#104167 RX=1;
	#104167 RX=1;
	
	#104167 RX=0;
	#104167 RX=1;
	#104167 RX=1;
	#104167 RX=1;
	#104167 RX=1;
	#104167 RX=0;
	#104167 RX=1;
	#104167 RX=0;
	#104167 RX=1;
	
	#200000 RX=0;
	#104167 RX=0;
	#104167 RX=1;
	#104167 RX=0;
	#104167 RX=0;
	#104167 RX=1;
	#104167 RX=0;
	#104167 RX=0;
	#104167 RX=0;
	#104167 RX=1;
	#500
	#104167 RX=0;
	#104167 RX=0;
	#104167 RX=0;
	#104167 RX=0;
	#104167 RX=0;
	#104167 RX=1;
	#104167 RX=1;
	#104167 RX=0;
	#104167 RX=0;
	#104167 RX=1;

	end

      
endmodule

