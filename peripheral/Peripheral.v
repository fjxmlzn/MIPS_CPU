`timescale 1ns/1ns
module Peripheral (reset,sysclk,clk,rd,wr,addr,wdata,rdata,RX,TX,led,switch,digi,irqout);
input reset,clk,sysclk; //sysclk=V10 ->URAT
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
output reg[31:0] rdata;
input RX; //UART input and output
output TX;
output reg[7:0] led;
input [7:0] switch;
output reg[11:0] digi;
output reg[1:0]irqout; //irqout 2bit to judge the type of interrupt

reg [31:0] TH,TL;
reg [2:0] TCON;

//IRQ
always@*
begin
if (UART_CON[0]&&UART_CON[2]) irqout<=2'b10;
else if (UART_CON[1]&&UART_CON[3]) irqout<=2'b11;
else if (TCON[0]&&TCON[2]) irqout<=2'b01;
else irqout<=2'b00;
end
//UART variables:
reg [7:0]UART_RXD;
reg [7:0]UART_TXD;
reg [4:0]UART_CON = 0;
reg [7:0]RX_buffer[15:0];
reg [3:0]RX_buf_in_tag = 0;
reg [3:0]RX_buf_out_tag = 0;
reg [3:0]RX_buf_num=0;
reg [7:0]TX_buffer[15:0];
reg [3:0]TX_buf_in_tag = 0;
reg [3:0]TX_buf_out_tag = 0;
reg [3:0]TX_buf_num=0;
reg TX_complete=0;
wire en_9600, clkfa;
wire [7:0] RXda;
wire RXsta;
wire TXsta;
reg TXen;
reg [7:0] TXda;


always@(*) begin
	if(rd) begin
		case(addr)
			32'h40000000: rdata <= TH;			
			32'h40000004: rdata <= TL;			
			32'h40000008: rdata <= {29'b0,TCON};				
			32'h4000000C: rdata <= {24'b0,led};			
			32'h40000010: rdata <= {24'b0,switch};
			32'h40000014: rdata <= {20'b0,digi};
			32'h40000018: rdata <= {24'b0,UART_TXD};
			32'h4000001C: rdata <= {24'b0,UART_RXD}; 
			default: rdata <= 32'b0;
		endcase
	end
end

always@(posedge reset or posedge clk) begin
	if(reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;	
		RX_buf_out_tag <= 0;
		UART_CON[3] <= 0;
		UART_RXD <= 0;
		UART_CON[2] <= 0;
		UART_TXD <= 0;
		TX_buf_in_tag <= 0;
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			end
			else TL <= TL + 1;
		end
		
		if(wr&&addr!=32'h40000018) begin
			case(addr)
				32'h40000000: TH <= wdata;
				32'h40000004: TL <= wdata;
				32'h40000008: TCON <= wdata[2:0];		
				32'h4000000C: led <= wdata[7:0];			
				32'h40000014: digi <= wdata[11:0];
				32'h40000020: UART_CON[1:0] <= wdata[1:0]; //only write control bits
				default: ;
			endcase
		end

		//UART_TXD->TX_buffer
		if(wr&&addr==32'h40000018)
			begin 
			UART_TXD <= wdata[7:0]; 
			TX_buffer[TX_buf_in_tag] <= wdata[7:0];
			TX_buf_in_tag <= TX_buf_in_tag + 1;
			end
		else if (rd&&addr==32'h40000018)
			begin
			UART_CON[2] <= 0;
			end
		else if (TX_complete)
			UART_CON[2] <= 1;
			

		//RX_buffer->UART_RXD
		if (rd&&addr==32'h4000001C&&UART_CON[3])
			UART_CON[3] <= 0;
		else if (UART_CON[3]==0&&RX_buf_num!=0)
			begin
			UART_RXD <= RX_buffer[RX_buf_out_tag];
			RX_buf_out_tag <= RX_buf_out_tag + 1;
			UART_CON[3] <= 1;
			end

	end
end

//UART:
UARTBRGenerator brg1(sysclk, reset,  clkfa);
UARTReciever r1(sysclk, reset, RX, clkfa, RXda, RXsta);
UARTSender s1(clkfa ,sysclk, reset, TXda, TXen, TXsta, TX);

reg [1:0]flag=2'b11;
//Receiver->RX_buffer + TX_buffer->Sender
always@(posedge sysclk or posedge reset)
begin
if (reset) begin RX_buf_in_tag<=0;flag<=2'b11; end
else if (RXsta)	//Receiver->RX_buffer
	begin 
	RX_buffer[RX_buf_in_tag] <= RXda;
	RX_buf_in_tag <= RX_buf_in_tag + 1;
	end

if (reset) begin TX_buf_out_tag<=0; TXen<=0;TX_complete<=0;end
else 
	begin
	if (TX_buf_num!=0&&TXsta)	//TX_buffer->Sender
		begin
			TXda <= TX_buffer[TX_buf_out_tag];
			TX_buf_out_tag <= TX_buf_out_tag + 1;
			TXen <= 1;
		end
	else if (TXen&&TXsta) TXen <= 0;
	
	flag[0]<=TXsta; flag[1]<=flag[0];
	if (flag==2'b01) TX_complete <= 1;
	else if (flag==2'b00&&UART_CON[2]==0) TX_complete<=0;
	end
	
end 

always @*
begin
UART_CON[4]<=~TXsta;
RX_buf_num<=RX_buf_in_tag - RX_buf_out_tag;
TX_buf_num<=TX_buf_in_tag - TX_buf_out_tag;
end

endmodule