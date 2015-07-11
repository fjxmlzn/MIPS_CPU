`timescale 1ns / 1ns
module UARTSender(baudclk,sysclk,reset,TX_DATA,TX_EN,TX_STATUS,TX);
input baudclk;
input sysclk;
input reset;
input [7:0]TX_DATA;
input TX_EN;
output TX_STATUS;
output reg TX;

reg [7:0]data;
reg work=0;	//sender is working
assign TX_STATUS = !work;
reg [3:0]num=0;	//data[num]
reg [4:0]count=0;	//find middle of wave
reg first=1;
always@(posedge baudclk or posedge reset)
begin
if (reset) begin count<=0;TX<=1;num<=0; end
else if (work == 0) 
begin
	TX <= 1;
	num <= 0;
	count <= 0;
end
else
	begin
	if (first) begin num<=0;count<=0; TX <= 0;end
	else if (num == 0 && count < 16) 
		begin
		count <= count + 1;
		TX <= 0;
		end
	else if (num == 0 && count == 16)
		begin
		TX <= data[num];
		num <= num + 1;
		count <= 0;
		end
	else if (num > 0 && num < 8 && count == 15)
		begin
		TX <= data[num];
		num <= num + 1;
		count <= 0;
		end
	else if ( num == 8 && count == 15)
		begin
		TX <= 1;
		num <= num + 1;
		count <= 0;
		end
	else if (num == 9 && count < 15)
		begin 
		TX <= 1;
		count <= count + 1;
		end
	else if (num == 9 && count == 15)
		begin
		num <= 0;
		count <= 0;
		end
	else if (count < 15)
		count <= count + 1;
	end
end

integer cnt=0;
always@ (posedge sysclk or posedge reset)
begin
if (reset) begin work<=0; data<=0; cnt<=0;first<=1;end
else if (TX_EN && work == 0)
	begin
	work <= 1;
	data <= TX_DATA;
	cnt <= 0;
	end
else if (cnt == 640) work <= 0; //cnt=10*baudclk*16
else cnt <= cnt + 1;

if (cnt<4) first<=1;	//first=baudclk;
else first<=0;
end

endmodule