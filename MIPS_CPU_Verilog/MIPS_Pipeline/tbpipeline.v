`timescale 1ns / 1ps

module tbpipeline;

	// Inputs
	reg resetk;
	reg clk;
	reg button;
	reg [7:0] switch;
	reg RX;

	// Outputs
	wire [7:0] led;
	wire [7:0] bcd;
	wire [3:0] an;
	wire TX;

	// Instantiate the Unit Under Test (UUT)
	CPU_Pipeline uut (
		.resetk(resetk), 
		.clk(clk), 
		.button(button), 
		.led(led), 
		.switch(switch), 
		.bcd(bcd), 
		.an(an), 
		.RX(RX), 
		.TX(TX)
	);

	initial begin
		// Initialize Inputs
		resetk = 0;
		clk = 0;
		switch = 0;
		RX = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		fork 
			forever #5 clk=~clk;
			#10 resetk=1;
			#50 resetk=0;
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

