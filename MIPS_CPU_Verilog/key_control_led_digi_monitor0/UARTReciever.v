`timescale 1ns / 1ns
module UARTReciever (sysclk, reset, RX, clkfa, RXda, RXsta);
input sysclk, reset, RX, clkfa;
output reg RXsta;
output reg [7:0] RXda;


reg [7:0] cnt;
always @(posedge reset or posedge clkfa)
begin
if (reset) cnt<=0;
else if (cnt==8'd0)
			begin
			if (RX==0) cnt<=cnt+1'b1;
			else cnt<=0;
			end
else if (cnt<8'd160)
			begin
			if (cnt==8'd24) 
				begin RXda[0]<=RX;
						cnt<=cnt+1'b1; end
			else if (cnt==8'd40) 
				begin RXda[1]<=RX;
						cnt<=cnt+1'b1; end
			else if (cnt==8'd56) 
				begin RXda[2]<=RX;
						cnt<=cnt+1'b1; end
			else if (cnt==8'd72) 
				begin RXda[3]<=RX;
						cnt<=cnt+1'b1; end
			else if (cnt==8'd88) 
				begin RXda[4]<=RX;
						cnt<=cnt+1'b1; end
			else if (cnt==8'd104) 
				begin RXda[5]<=RX;
						cnt<=cnt+1'b1; end
			else if (cnt==8'd120) 
				begin RXda[6]<=RX;
						cnt<=cnt+1'b1; end
			else if (cnt==8'd136) 
				begin RXda[7]<=RX;
						cnt<=cnt+1'b1; end
			else cnt<=cnt+1'b1; 
			end
else if (cnt==8'd160)
			cnt<=0;
end

reg [1:0] cnth;			
always @(posedge reset or negedge sysclk)
if (reset) begin RXsta<=0; cnth<=0; end
else begin
		cnth[1]<=cnth[0];
		cnth[0]<=cnt[7];
		if (cnth==2'b10) RXsta<=1;
		else RXsta<=0;
		end



endmodule
