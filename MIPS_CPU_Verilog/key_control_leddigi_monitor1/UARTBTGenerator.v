`timescale 1ns / 1ns
module UARTBRGenerator(sysclk, reset,  clkfa );
	 input sysclk, reset;
	 output reg clkfa;
	
	reg [8:0] cntfa=0;
	 always @(posedge reset or posedge sysclk)
		begin
		if (reset) begin cntfa<=0;clkfa<=0; end
		else if (cntfa!=325) cntfa<=cntfa+1'b1;//actual
		//else if (cntfa!=1) cntfa<=cntfa+1'b1; //test
		else begin cntfa<=0;clkfa<=~clkfa; end
		end
	
endmodule
