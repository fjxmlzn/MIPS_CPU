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

	///////////////////////////////////////////////////////////////////
	reg [31:0] TH,TL;
	reg [2:0] TCON;


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
	wire [7:0] RX_DATA;
	wire RX_STATUS;
	wire TX_STATUS;
	reg TX_EN;
	reg [7:0] TX_DATA;

	//IRQ
	always@*
		begin
			if (UART_CON[0]&&UART_CON[2]) irqout<=2'b10;
			else if (UART_CON[1]&&UART_CON[3]) irqout<=2'b11;
			else if (TCON[0]&&TCON[2]) irqout<=2'b01;
			else irqout<=2'b00;
		end

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

	always@(posedge reset or posedge clk) 
		begin
			if(reset) 
				begin
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
			else 
				begin
					if(TCON[0]) 
						begin	//timer is enabled
							if(TL==32'hffffffff) 
								begin
									TL <= TH;
									if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
								end
							else TL <= TL + 1;
						end
					
					if(wr&&addr!=32'h40000018) 
						begin
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
							TX_buf_in_tag <= TX_buf_in_tag + 4'b1;
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
							RX_buf_out_tag <= RX_buf_out_tag + 4'b1;
							UART_CON[3] <= 1;
						end

				end
		end

	//UART:
	UARTReciever re(reset, sysclk, RX, RX_STATUS, RX_DATA);
	UARTSender se(reset,sysclk,TX_EN,TX_DATA,TX_STATUS,TX);

	reg [1:0]flag=2'b11;
	//Receiver->RX_buffer + TX_buffer->Sender
	always@(negedge sysclk or posedge reset)
		begin
			if (reset) begin RX_buf_in_tag<=0;end
			else if (RX_STATUS)	//Receiver->RX_buffer
				begin 
					RX_buffer[RX_buf_in_tag] <= RX_DATA;
					RX_buf_in_tag <= RX_buf_in_tag + 4'b1;
				end
				
			if (reset) 
				begin 
					TX_buf_out_tag<=0; 
					TX_EN<=0;TX_complete<=0;
					flag<=2'b11;
				end
			else 
				begin
					if (TX_buf_num!=0&&TX_STATUS)	//TX_buffer->Sender
						begin
							TX_DATA <= TX_buffer[TX_buf_out_tag];
							TX_buf_out_tag <= TX_buf_out_tag + 4'b1;
							TX_EN <= 1;
						end
					else if (TX_EN&&TX_STATUS) TX_EN <= 0;
					
					flag[0]<=TX_STATUS; flag[1]<=flag[0];
					if (flag==2'b01) TX_complete <= 1;
					else if (flag==2'b00&&UART_CON[2]==0) TX_complete<=0;
				end
			
		end 

	always @*
		begin
			UART_CON[4]<=~TX_STATUS;
			RX_buf_num<=RX_buf_in_tag - RX_buf_out_tag;
			TX_buf_num<=TX_buf_in_tag - TX_buf_out_tag;
		end
endmodule


////////////////////////////////////////////////////////////////////////////////
module UARTReciever (reset, sysclk, RX, RX_STATUS, RX_DATA);
input reset, sysclk, RX;
output reg RX_STATUS;
output reg [7:0] RX_DATA;

reg enable = 0;
reg [16:0] count = 1;
//if peroid = T * sysclk, then when count=T, let count=1

always @(posedge reset or posedge sysclk)
	begin
		if (reset)
			begin 
				RX_STATUS <= 0;
				RX_DATA <= 0;
				enable <= 0;
				count <= 1;
			end
		else
			begin
				if (enable==0)
					begin 
					if (RX)
						begin
						RX_STATUS <= 0;
						enable <= 0;
						count <= 1;
						end
					else
						begin
						enable <= 1;
						count <= 1;
						end
					end
				else
					begin
						if (count==15624)//(8+16)*651 = 15624
							begin
							RX_DATA[0] <= RX;
							count <= count + 17'b1;
							end
						else if (count==26040)
							begin
							RX_DATA[1] <= RX;
							count <= count + 17'b1;
							end
						else if (count==36456)
							begin
							RX_DATA[2] <= RX;
							count <= count + 17'b1;
							end
						else if (count==46872)
							begin
							RX_DATA[3] <= RX;
							count <= count + 17'b1;
							end
						else if (count==57288)
							begin
							RX_DATA[4] <= RX;
							count <= count + 17'b1;
							end
						else if (count==67704)
							begin
							RX_DATA[5] <= RX;
							count <= count + 17'b1;
							end
						else if (count==78120)
							begin
							RX_DATA[6] <= RX;
							count <= count + 17'b1;
							end
						else if (count==88536)
							begin
							RX_DATA[7] <= RX;
							count <= count + 17'b1;
							end
						else if (count==98952)//(16*9+8)*651 = 98952
							begin
							RX_STATUS <= 1;
							count <= count + 17'b1;
							end
						else if (count==98953)
							begin
							RX_STATUS <= 0;
							enable <= 0;
							count <= 17'b1;
							end
						else count <= count + 17'b1;
					end
			end
	end
endmodule



////////////////////////////////////////////////////////////////////////////////

module UARTSender(reset,sysclk,TX_EN,TX_DATA,TX_STATUS,TX);
input reset,sysclk,TX_EN;
input [7:0]TX_DATA;
output TX_STATUS;
output reg TX;

reg [7:0]data = 0;
reg enable = 0;	//sender is working
assign TX_STATUS = !enable;
reg [17:0] count = 1;
//if peroid = T * sysclk, then when count=T, let count=1
always@(posedge reset or posedge sysclk)
	begin
		if (reset)
			begin
				TX <= 1;
				enable <= 0;
				data <= 0;
				count <= 1;
			end
		else
			begin
				if (enable==0)
					begin
						if (TX_EN)
							begin
								TX <= 0;
								enable <= 1;
								count <= 1;
								data <= TX_DATA;
							end
						else
							begin
								TX <= 1;
								enable <= 0;
								data <= 0;
								count <= 1;
							end
					end
				else
					begin
						if (count==10416)//1*16*651=10416
							begin
								TX <= data[0];
								count <= count + 18'b1;
							end
						else if (count==20832)
							begin
								TX <= data[1];
								count <= count + 18'b1;
							end
						else if (count==31248)
							begin
								TX <= data[2];
								count <= count + 18'b1;
							end
						else if (count==41664)
							begin
								TX <= data[3];
								count <= count + 18'b1;
							end
						else if (count==52080)
							begin
								TX <= data[4];
								count <= count + 18'b1;
							end
						else if (count==62496)
							begin
								TX <= data[5];
								count <= count + 18'b1;
							end
						else if (count==72912)
							begin
								TX <= data[6];
								count <= count + 18'b1;
							end
						else if (count==83328)
							begin
								TX <= data[7];
								count <= count + 18'b1;
							end
						else if (count==93744)//9*16*651=93744
							begin
								TX <= 1;
								count <= count + 18'b1;
							end
						else if (count==104160)//10*16*651=104160
							begin
								TX <= 1;
								count <= 1;
								enable <= 0;
							end
						else count <= count + 18'b1;
					end
			end
	end
endmodule