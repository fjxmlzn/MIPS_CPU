`timescale 1ns / 1ns
module tb;

	// Inputs
	reg reset,clk,sysclk,rd,wr;
	reg[31:0] addr;
	reg[31:0] wdata;
	reg RX;
	reg[7:0] switch;
	// Outputs
	wire[31:0] rdata;
	wire TX;
	wire[7:0] led;
	wire[11:0] digi;
	wire[1:0] irqout;
	// Instantiate the Unit Under Test (UUT)
	Peripheral p(reset,sysclk,clk,rd,wr,addr,wdata,rdata,RX,TX,led,switch,digi,irqout);
reg [10:0]clk_state;
reg [5:0]pc;
reg [7:0]data;
reg [4:0]datacnt;
reg [10:0]i;
	initial begin
		// Initialize Inputs
		sysclk = 0;reset = 1;clk = 0;
		rd = 0;wr = 0;addr = 32'h40000018;wdata = 0;
		RX = 0;switch = 0;
		clk_state = 0;pc = 0;
		data = 0;i =0;
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		forever #1 sysclk=~sysclk;
	end
always@(posedge sysclk)
begin
reset<=0;
if (clk_state<200) clk_state<=clk_state+1;
else begin clk_state<=0;clk<=!clk; end
end

always@(posedge clk)
begin
if (pc<1) begin pc<=pc+1; wr<=1;rd<=0;	//set send and receive enable
addr<=32'h40000020;wdata<=32'h40000003;end
else if (pc<2) 	//close timer
begin wr<=1;rd<=0;addr<=32'h40000008;wdata<=0;pc<=pc+1;end
else if (pc<5)	//nop to wait
begin wr<=0;rd<=0;pc<=pc+1;end
else if (pc<6)	//read a RX_data
begin wr<=0;rd<=1;addr<=32'h4000001C;pc<=pc+1;end
else if (pc<7)	//read a RX_data
begin wr<=0;rd<=1;addr<=32'h4000001C;pc<=pc+1;end
else if (pc<8)	//write a TX_data
begin wr<=1;rd<=0;addr<=32'h40000018;wdata<=32'h00000012;pc<=pc+1;end
else if (pc<9)	//read UART_TXD to cancel UART_CON[2]
begin wr<=0;rd<=1;addr<=32'h40000018;pc<=pc+1;end
else if (pc<10)	//read a RX_data
begin wr<=0;rd<=1;addr<=32'h4000001C;pc<=pc+1;end
else if (pc<11)	//read a RX_data
begin wr<=0;rd<=1;addr<=32'h4000001C;pc<=pc+1;end
else if (pc<12)	//read a RX_data
begin wr<=0;rd<=1;addr<=32'h4000001C;pc<=pc+1;end
else if (pc<13)	//write a TX_data
begin wr<=1;rd<=0;addr<=32'h40000018;wdata<=32'h00000034;pc<=pc+1;end
else if (pc<14)	//read UART_TXD to cancel UART_CON[2]
begin wr<=0;rd<=1;addr<=32'h40000018;pc<=pc+1;end
else if (pc<15)	//write a TX_data
begin wr<=1;rd<=0;addr<=32'h40000018;wdata<=32'h40000056;pc<=pc+1;end
else if (pc<16)	//write a TX_data
begin wr<=1;rd<=0;addr<=32'h40000018;wdata<=32'h40000078;pc<=pc+1;end
else if (pc<17)	//write a TX_data
begin wr<=1;rd<=0;addr<=32'h40000018;wdata<=32'h40000090;pc<=pc+1;end
else if (pc<18)	//read UART_TXD to cancel UART_CON[2]
begin wr<=0;rd<=1;addr<=32'h40000018;pc<=pc+1;end
else if (pc<20)	//nop to wait
begin wr<=0;rd<=0;pc<=pc+1;end
else begin pc<=0;reset<=1; end
end

always@(posedge sysclk)
begin
if (reset==1) i<=0;
else if (i<64) begin i<=i+1; datacnt<=0;end
else if (i<128) begin i<=i+1; datacnt<=1;end
else if (i<192) begin i<=i+1; datacnt<=2;end
else if (i<256) begin i<=i+1; datacnt<=3;end
else if (i<320) begin i<=i+1; datacnt<=4;end
else if (i<384) begin i<=i+1; datacnt<=5;end
else if (i<448) begin i<=i+1; datacnt<=6;end
else if (i<512) begin i<=i+1; datacnt<=7;end
else if (i<576) begin i<=i+1; datacnt<=8;end
else if (i<704) begin i<=i+1; datacnt<=9;end
else begin i<=0;datacnt<=0;end end

always@(posedge datacnt[0] or negedge datacnt[0])
begin
if (datacnt==0) begin RX<=0;data<=data+5; end
else if (datacnt==1) begin RX<=data[0];end
else if (datacnt==2) begin RX<=data[1];end
else if (datacnt==3) begin RX<=data[2];end
else if (datacnt==4) begin RX<=data[3];end
else if (datacnt==5) begin RX<=data[4];end
else if (datacnt==6) begin RX<=data[5];end
else if (datacnt==7) begin RX<=data[6];end
else if (datacnt==8) begin RX<=data[7];end
else  begin RX<=1;end
end
endmodule

