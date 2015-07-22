module Peripheral (reset,sysclk,clk,rd,wr,addr,wdata,rdata,RX,TX,led,switch,digi,irqout);
	input reset, clk, sysclk; //sysclk=V10 ->URAT
	input rd, wr;
	input [31:0] addr;
	input [31:0] wdata;
	output reg[31:0] rdata;
	input RX; //UART input and output
	output TX;
	output reg [7:0] led;
	input [7:0] switch;
	output reg [11:0] digi;
	output reg [1:0]irqout; //irqout 2bit to judge the type of interrupt

	///////////////////////////////////////////////////////////////////
	reg [31:0] TH,TL;
	reg [2:0] TCON;


	//UART variables:
	reg [7:0] UART_RXD;
	reg [7:0] UART_TXD;
	reg [4:0] UART_CON = 0;
	reg [7:0] RX_buffer[15:0];
	reg [3:0] RX_buf_in_tag = 0;
	reg [3:0] RX_buf_out_tag = 0;
	reg [3:0] RX_buf_num = 0;
	reg [7:0] TX_buffer[15:0];
	reg [3:0] TX_buf_in_tag;
	reg [3:0] TX_buf_out_tag;
	reg [3:0] TX_buf_num = 0;
	reg TX_complete=0;
	wire RX_STATUS;
	wire TX_STATUS;
	
	wire TX_WORK;
	reg TX_EN;
	reg [7:0] TX_DATA;
	reg TX_LAST_WORK;
	
	wire RX_FLAG;
	wire [7:0] RX_DATA;

	//IRQ
	always@*
		begin
			if (UART_CON[0]&&UART_CON[2]) irqout = 2'b10;
			else if (UART_CON[1]&&UART_CON[3]) irqout = 2'b11;
			else if (TCON[0]&&TCON[2]) irqout = 2'b01;
			else irqout = 2'b00;
		end
		
	//read
	always@(*) begin
		if(rd) 
			begin
				case(addr)
					32'h40000000: rdata = TH;			
					32'h40000004: rdata = TL;			
					32'h40000008: rdata = {29'b0,TCON};				
					32'h4000000C: rdata = {24'b0,led};			
					32'h40000010: rdata = {24'b0,switch};
					32'h40000014: rdata = {20'b0,digi};
					32'h40000018: rdata = {24'b0,UART_TXD};
					32'h4000001C: rdata = {24'b0,UART_RXD}; 
					default: rdata = 32'b0;
				endcase
			end
		else
			rdata = 32'b0;
	end
	
	//timer
	always@(posedge reset or posedge clk)
		begin
			if (reset)
				begin
					TH <= 32'b0;
					TL <= 32'b0;
					TCON <= 3'b0;
				end
			else
				begin
					if (wr)
						begin
							if (addr == 32'h40000000)
								TH <= wdata;
							else if (addr == 32'h40000004)
								TL <= wdata;
							else if (addr == 32'h40000008)
								TCON <= wdata[2:0];
						end
					else if(TCON[0]) 
						begin	//timer is enabled
							if(TL == 32'hffffffff) 
								begin
									TL <= TH;
									if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
								end
							else TL <= TL + 1;
						end
				end
		end
	
	//led & digit
	always@(posedge reset or posedge clk)
		begin
			if (reset)
				begin
					led <= 8'b0;
					digi <= 12'b0;
				end
			else if (wr)
				begin
					if (addr == 32'h4000000C)
						led <= wdata[7:0];
					else if (addr == 32'h40000014)
						digi <= wdata[11:0];				
				end
		end
	
	//UART_CON[0] & UART_CON[1]	
	always@(posedge reset or posedge clk)
		begin
			if (reset)
				begin
					UART_CON[0] <= 1'b0;
					UART_CON[1] <= 1'b0;
				end
			else if (wr)
				begin
					if (addr == 32'h40000020)
						UART_CON[1:0] <= wdata[1:0]; //only write control bits
				end
		end
	
	//Receiver -> RX_buffer
	always@(posedge reset or posedge RX_FLAG)
		begin
			if (reset)
				begin
					RX_buf_in_tag <= 4'b0;
				end
			else
				begin
					if (RX_buf_in_tag + 4'b1 != RX_buf_out_tag) //check if buffer has available space
						begin
							RX_buffer[RX_buf_in_tag] <= RX_DATA;
							RX_buf_in_tag <= RX_buf_in_tag + 4'b1;
						end					
				end
		end
		
	//RX_buffer -> UART_RXD (UART_CON[3])
	always@(posedge reset or posedge clk)
		begin
			if (reset)
				begin
					UART_CON[3] <= 1'b0;
					RX_buf_out_tag <= 0;
					UART_RXD <= 8'b0;
				end
			else if (rd)
				begin
					if (addr == 32'h4000001C)
						UART_CON[3] <= 1'b0;
				end
			else if (UART_CON[3] == 0 && RX_buf_in_tag != RX_buf_out_tag)
				begin
					UART_RXD <= RX_buffer[RX_buf_out_tag];
					RX_buf_out_tag <= RX_buf_out_tag + 4'b1;
					UART_CON[3] <= 1'b1;
				end
		end
	
	//UART_TXD -> TX_buffer
	always@(posedge reset or posedge clk)
		begin
			if (reset)
				begin
					UART_TXD <= 8'b0;
					TX_buf_in_tag <= 0;
				end
			else if (wr)
				begin
					if (addr == 32'h40000018)
						begin
							if (TX_buf_in_tag + 4'b1 != TX_buf_out_tag) //check if buffer has available space
								begin
									UART_TXD <= wdata[7:0]; 
									TX_buffer[TX_buf_in_tag] <= wdata[7:0];
									TX_buf_in_tag <= TX_buf_in_tag + 4'b1;
								end
						end
				end		
		end
	
	//TX_buffer -> Sender && UART_CON[2]
	always@(posedge reset or posedge clk)
		begin
			if (reset)
				begin
					TX_buf_out_tag <= 4'b0;
					TX_EN <= 0;
					TX_DATA <= 8'b0;
					UART_CON[2] <= 1'b0;
					TX_LAST_WORK <= 1'b0;
				end
			else if (TX_WORK)
				begin
					if (TX_EN) TX_EN <= 1'b0;
					TX_LAST_WORK <= 1'b1;
				end
			else if (~TX_WORK)
				begin
					if (!TX_EN && TX_buf_in_tag != TX_buf_out_tag)
						begin
							TX_EN <= 1'b1;
							TX_DATA <= TX_buffer[TX_buf_out_tag];
							TX_buf_out_tag <= TX_buf_out_tag + 4'b1;
						end
					if (rd && addr == 32'h40000018)
						UART_CON[2] <= 1'b0;
					else if (TX_LAST_WORK)
						UART_CON[2] <= 1'b1;
					TX_LAST_WORK <= 1'b0;
				end
		end
	
	//UART:
	UARTReceiver uartReceiver(reset, sysclk, RX, RX_FLAG, RX_DATA);
	UARTSender uartSender(reset, sysclk, TX, TX_WORK, TX_EN, TX_DATA);
endmodule

////////////////////////////////////////////////////////////////////////////////
module UARTReceiver(reset, sysclk, RX, RX_FLAG, RX_DATA);
	input reset, sysclk, RX;
	
	output reg RX_FLAG;
	output reg [7:0] RX_DATA;
	
	reg [16:0] count = 0;
	
	always@(posedge reset or posedge sysclk)
		begin
			if (reset)
				begin
					RX_FLAG <= 1'b0;
					RX_DATA <= 1'b0;
					count <= 17'b0;
				end
			else
				begin
					if (count == 0)
						begin
							if (RX == 1'b0)
								count <= 17'b1;
							else 
								count <= 17'b0;
							RX_FLAG <= 1'b0;
						end
					else if (count <= (17'd16 * 17'd8 + 17'd8) * 17'd651)
						begin
							if (count == 15624)//(8+16)*651 = 15624
								RX_DATA[0] <= RX;
							else if (count==26040)
								RX_DATA[1] <= RX;
							else if (count==36456)
								RX_DATA[2] <= RX;
							else if (count==46872)
								RX_DATA[3] <= RX;
							else if (count==57288)
								RX_DATA[4] <= RX;
							else if (count==67704)
								RX_DATA[5] <= RX;
							else if (count==78120)
								RX_DATA[6] <= RX;
							else if (count==88536)
								RX_DATA[7] <= RX;
							count <= count + 17'b1;
							RX_FLAG <= 1'b0;
						end
					else if (count <= (17'd16 * 17'd9 + 17'd8) * 17'd651)
						begin
							if (count == (17'd16 * 17'd9 + 17'd8) * 17'd651 && RX != 1'b1) 	//check bit
								count <= 17'b0; 
							count <= count + 17'b1;
							RX_FLAG <= 1'b0;
						end
					else if (count <= (17'd16 * 17'd9 + 17'd8) * 17'd651 + 17'd100)
						begin
							count <= count + 17'b1;
							RX_FLAG <= 1'b1;
						end
					else 
						count <= 1'b0;
				end
		end
endmodule

////////////////////////////////////////////////////////////////////////////////
module UARTSender(reset, sysclk, TX, TX_WORK, TX_EN, TX_DATA);
	input reset, sysclk, TX_EN;
	input [7:0] TX_DATA;
	
	output reg TX, TX_WORK;
	
	reg [17:0] count = 0;
	
	always@(posedge reset or posedge sysclk)
		begin
			if (reset)
				begin
					TX <= 1'b1;
					TX_WORK <= 1'b0;
					count <= 18'b0;
				end
			else
				begin
					if (count == 18'b0)
						begin
							if (TX_EN)
								count <= 18'b1;
							else
								count <= 18'b0;
							TX_WORK <= 1'b0;
						end
					else if (count <= 18'd1 * 18'd16 * 18'd651)
						begin
							TX <= 1'b0;
							count <= count + 18'b1;
							TX_WORK <= 1'b1;
						end
					else if (count <= 18'd9 * 18'd16 * 18'd651)
						begin
							if (count <= 18'd20832) //2*16*651
								TX <= TX_DATA[0];
							else if (count <= 18'd31248)
								TX <= TX_DATA[1];
							else if (count <= 18'd41664)
								TX <= TX_DATA[2];
							else if (count <= 18'd52080)
								TX <= TX_DATA[3];
							else if (count <= 18'd62496)
								TX <= TX_DATA[4];
							else if (count <= 18'd72912)
								TX <= TX_DATA[5];
							else if (count <= 18'd83328)
								TX <= TX_DATA[6];
							else if (count <= 18'd93744)
								TX <= TX_DATA[7];
							count <= count + 18'b1;
							TX_WORK <= 1'b1;
						end
					else if (count <= 18'd10 * 18'd16 * 18'd651)
						begin
							TX <= 1'b1;
							count <= count + 18'b1;
							TX_WORK <= 1'b1;
						end
					else 
						count <= 18'b0;
				end
		end
endmodule