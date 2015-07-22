module CPU_Pipeline(resetk, clk , button, led, switch, bcd, an, RX, TX);
	input resetk, clk, button, RX;
	input [7:0] switch;
	output TX;
	output [3:0] an;
	output [7:0] bcd;
	output [7:0] led;
	
	//variables
	
	//reset
	wire reset;	
	
	//clock
	wire myclk;
	reg [31:0] cnt_clk;
	
	//PC
	reg [31:0] PC;
	wire [31:0] PC_id, PC_ex, PC_mem;
	wire [31:0] PC_next, PC_normal_next;
	
	wire [31:0] Jump_target;	//id
	wire [31:0] Branch_target;	//ex
	wire [31:0] PC_plus_4, PC_plus_4_id, PC_plus_4_ex, PC_plus_4_mem, PC_plus_4_wb;
		
	wire [31:0] ILLOP;
	wire [31:0] XADR;
	wire [31:0] ILLTX;
	wire [31:0] ILLRX;
	
	wire ForwardJr;
	wire [31:0] Jr_target;
	
	//instruction-if
	wire [31:0] Instruction, Instruction_id, Instruction_ex;//instruc fetch
	
	//extend-id
	wire [31:0] Ext_out;
	wire [31:0] LU_out, LU_out_ex;
	
	//control-id
	wire [2:0] PCSrc, PCSrc_ex;
	wire RegWrite, RegWrite_ex, RegWrite_mem, RegWrite_wb;
	wire [1:0] RegDst, RegDst_ex;
	wire MemRead, MemRead_ex, MemRead_mem;
	wire MemWrite, MemWrite_ex, MemWrite_mem;
	wire [1:0] MemtoReg, MemtoReg_ex, MemtoReg_mem, MemtoReg_wb;
	wire ALUSrc1, ALUSrc1_ex;
	wire ALUSrc2, ALUSrc2_ex;
	wire ExtOp;
	wire LuOp;
	wire [5:0] ALUFun, ALUFun_ex;
	wire Sign, Sign_ex;
	reg [1:0] IRQs;
	
	//rs, rt, rd-id
	wire [4:0] Rs, Rs_ex, Rs_mem;
	wire [4:0] Rt, Rt_ex, Rt_mem;   
	wire [4:0] Rd, Rd_ex;
	
	//regfile-id
	wire [4:0] Write_register, Write_register_mem, Write_register_wb;
	wire [31:0] Databus1, Databus1_ex;
	wire [31:0] Databus2, Databus2_ex, Databus2_mem;
	wire [31:0] Databus3, Databus3_ADVANCE;
	
	//alu-ex
	wire [31:0] ALU_in1, ALU_inf1;
	wire [31:0] ALU_in2, ALU_inf2;
	wire [31:0] ALU_out, ALU_out_mem, ALU_out_wb;
	
	//memory
	wire ForwardSW;
	wire [31:0] Memory_write_data;
	//data memory-mem
	wire [31:0] data_rda;
	wire data_read;
	wire data_wr;
	
	//peripheral memory-mem
	wire [31:0] peri_rda;
	
	wire peri_read;
	wire peri_wr;
	
	wire [11:0] digi;
	wire [1:0] IRQ;
	
	//memory
	wire [31:0] Read_data, Read_data_wb;		
			
	//forward control
	wire [1:0] ForwardA, ForwardB;
	
	//risk control
	wire PCWrite, IFIDWrite, IDEXMux, IFIDMux;	
	
	//connection
	
	//reset
	debounce d1 (.clk(clk),.key_i(resetk),.key_o(reset));
	//assign reset = resetk;
	//clock
	/*
	always @(posedge clk or posedge reset)
		if (reset) 
			begin 
				cnt_clk<=0; 
				myclk<=0; 
			end
		else if (cnt_clk==32'd1) 			// frequency = 100MHz
			begin 
				myclk<=~myclk;
				cnt_clk<=1;
			end
		else
			begin
				cnt_clk<=cnt_clk+1'b1;
			end
	*/
	assign myclk = clk;

	//PC
	always @(posedge reset or posedge myclk)
		begin
			if (reset)
				PC <= 32'h80000000;
			else 
				if (PCWrite)			//risk control
					PC <= PC_next;
		end
	

	assign Jump_target = {PC_plus_4_id[31:28], Instruction_id[25:0], 2'b00};	//id
	
	assign Branch_target = (ALU_out[0])? PC_plus_4_ex + {LU_out_ex[29:0], 2'b00}: PC_plus_4_ex;	//ex
	

	assign PC_plus_4 = {PC[31], (PC[30:0] + 31'd4)};//+4 won't change PC[31]
	
	assign ILLOP = 32'h8000_0004;
	assign XADR = 32'h8000_0008;
	assign ILLTX = 32'h8000_000c;
	assign ILLRX = 32'h8000_0010;
	
	assign Jr_target = ForwardJr ? ALU_out : Databus1;
	
	assign PC_normal_next = 								//storing in $26 if interrupt | exception comes
		(PCSrc_ex == 3'b001 && ALU_out[0])? Branch_target:	 		//priority 2: branch
		{PCSrc == 3'b010}? Jump_target:					//priority 3: j & jr
		{PCSrc == 3'b011}? Jr_target:
		(PCSrc == 3'b000)? PC_plus_4: 					//priority 4: PC+4
		PC_plus_4;

	assign PC_next = 
		{PCSrc == 3'b100}? ILLOP:							//priority 1: interrupt & exception
		{PCSrc == 3'b101}? XADR:
		{PCSrc == 3'b110}? ILLTX:
		{PCSrc == 3'b111}? ILLRX:
		PC_normal_next;
				
	//instruction-if
	ROM rom1(.addr(PC), .data(Instruction));
	
	//control-id
	Control control1(.monin(PC[31]),
		.Ins(Instruction_id),
		.PCSrc(PCSrc), .RegWrite(RegWrite), .RegDst(RegDst), 
		.MemRead(MemRead), .MemWrite(MemWrite), .MemtoReg(MemtoReg),
		.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ExtOp(ExtOp), .LuOp(LuOp),	.ALUFun(ALUFun),
		.Sign(Sign), .IRQ(IRQs));
	
	//rs, rt, rd-id
	assign Rs = Instruction_id[25:21];
	assign Rt = Instruction_id[20:16];
	assign Rd = Instruction_id[15:11];
	
	//regfile-id
	assign Write_register = (RegDst_ex == 2'b00)? Rt_ex:
									(RegDst_ex == 2'b01)? Rd_ex:
									(RegDst_ex == 2'b10)? 5'd31: 5'd26;
									
	assign Databus3 = (MemtoReg_wb == 2'b00)? ALU_out_wb: 
							(MemtoReg_wb == 2'b01)? Read_data_wb: 
							(MemtoReg_wb == 2'b11)? PC_mem: 
							PC_plus_4_mem;
	
	assign Databus3_ADVANCE = 
							(MemtoReg_mem == 2'b00)? ALU_out_mem: 
							(MemtoReg_mem == 2'b01)? Read_data: 
							(MemtoReg_mem == 2'b11)? PC_ex: 
							PC_plus_4_ex;
	
	
	RegFile register_file1(.reset(reset), .clk(myclk), .wr(RegWrite_mem), 
		.addr1(Rs), .addr2(Rt), .addr3(Write_register_mem),
		.data3(Databus3_ADVANCE), .data1(Databus1), .data2(Databus2));
	
	//extend-id
	assign Ext_out = {ExtOp? {16{Instruction_id[15]}} : 16'h0000, Instruction_id[15:0]};
	assign LU_out = LuOp? {Instruction_id[15:0], 16'h0000} : Ext_out;
	
	//alu-ex
		//forwarding
	assign ALU_in1 = ALUSrc1_ex? {17'h00000, Instruction_ex[10:6]} : Databus1_ex;
	assign ALU_in2 = ALUSrc2_ex? LU_out_ex : Databus2_ex;
	
	assign ALU_inf1 = (ForwardA == 2'b10)? ALU_out_mem:
							(ForwardA == 2'b01)? Databus3 : ALU_in1;
	assign ALU_inf2 = (ForwardB == 2'b10)? ALU_out_mem:
							(ForwardB == 2'b01)? Databus3 : ALU_in2;
	
	ALU alu1(.A(ALU_inf1), .B(ALU_inf2), .ALUFun(ALUFun_ex), .Sign(Sign_ex), .result(ALU_out));
	
	//memory
	assign Memory_write_data = (ForwardSW)? Databus3 : Databus2_mem;
	//data memory-mem
	assign data_read = (MemRead_mem)? ((ALU_out_mem<32'h4000_0000)? 1'b1 : 1'b0) : 1'b0;
	
	assign data_wr = (MemWrite_mem)? ((ALU_out_mem<32'h4000_0000)? 1'b1 : 1'b0) : 1'b0;
	
	DataMem data_memory1(.reset(reset), .clk(myclk), .addr(ALU_out_mem), .wdata(Memory_write_data), .rdata(data_rda), .rd(data_read), .wr(data_wr));
	

	//peripheral memory-mem
	assign peri_read = (MemRead_mem)? ((ALU_out_mem>=32'h4000_0000)? 1'b1 : 1'b0) : 1'b0;
	
	assign peri_wr = (MemWrite_mem)? ((ALU_out_mem>=32'h4000_0000)? 1'b1 : 1'b0) : 1'b0;
	
	assign an = digi[11:8];
	assign bcd = ~digi[7:0];

	always @(posedge myclk or posedge reset)
		if (reset) IRQs<=0;
		else IRQs<=IRQ;
	Peripheral peri1(.reset(reset),.sysclk(clk),.clk(myclk),.rd(peri_read),.wr(peri_wr),.addr(ALU_out_mem),.wdata(Memory_write_data),
		.rdata(peri_rda),.RX(RX),.TX(TX),.led(led),.switch(switch),.digi(digi),.irqout(IRQ));
	//assign led = {TX_buf_in_tag, TX_buf_out_tag};
	//memory
	assign Read_data=
		data_read? data_rda:
		peri_read? peri_rda: 0;	

	//forward control
	ForwardControl forwardControl1(.RegWrite_ex(RegWrite_ex), .RegWrite_mem(RegWrite_mem), .RegWrite_wb(RegWrite_wb),
							.Write_register(Write_register), .Write_register_mem(Write_register_mem), .Write_register_wb(Write_register_wb),
							.ALUSrc1_ex(ALUSrc1_ex), .ALUSrc2_ex(ALUSrc2_ex), .Rs_ex(Rs_ex), .Rt_ex(Rt_ex),
							.Rs_mem(Rs_mem), .Rt_mem(Rt_mem), .PCSrc(PCSrc), .Rs(Rs), .MemWrite_mem(MemWrite_mem), 
							.ForwardA(ForwardA), .ForwardB(ForwardB), .ForwardJr(ForwardJr), .ForwardSW(ForwardSW));
	//risk control
	RiskControl riskControl1(MemRead_ex, Write_register, Rs, Rt, PCWrite, IFIDWrite, PCSrc, PCSrc_ex, IFIDMux, IDEXMux, ALU_out[0]);
	
	//IF/ID
	IFIDReg IFIDReg1(.clk(myclk), .reset(reset), .enable(IFIDWrite), .IFIDMux(IFIDMux),
			  .Instruction(Instruction), .PC(PC), .PC_plus_4(PC_plus_4), 
			  .Instruction_n(Instruction_id), .PC_n(PC_id), .PC_plus_4_n(PC_plus_4_id));
	//ID/EX
	IDEXReg IDEXReg1(.clk(myclk), .reset(reset), .IDEXMux(IDEXMux),
			  .Instruction(Instruction_id), .PC_plus_4(PC_plus_4_id), .PC(PC_id),
			  .MemWrite(MemWrite), .MemRead(MemRead), .RegWrite(RegWrite), .RegDst(RegDst), 
			  .PCSrc(PCSrc), .MemtoReg(MemtoReg), .ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2),
			  .Sign(Sign), .LU_out(LU_out), .ALUFun(ALUFun), .Rs(Rs), .Rd(Rd), .Rt(Rt), 
			  .Databus1(Databus1), .Databus2(Databus2),
			  .Instruction_n(Instruction_ex), .PC_plus_4_n(PC_plus_4_ex), .PC_n(PC_ex),
			  .MemWrite_n(MemWrite_ex), .MemRead_n(MemRead_ex), .RegWrite_n(RegWrite_ex), .RegDst_n(RegDst_ex),
			  .PCSrc_n(PCSrc_ex), .MemtoReg_n(MemtoReg_ex),
			  .ALUSrc1_n(ALUSrc1_ex), .ALUSrc2_n(ALUSrc2_ex),
			  .Sign_n(Sign_ex), .LU_out_n(LU_out_ex), .ALUFun_n(ALUFun_ex), 
			  .Rs_n(Rs_ex), .Rd_n(Rd_ex), .Rt_n(Rt_ex), .Databus1_n(Databus1_ex), .Databus2_n(Databus2_ex));
	//EX/MEM
	EXMEMReg EXMEMReg1(.clk(myclk), .reset(reset),
				.RegWrite(RegWrite_ex), .MemRead(MemRead_ex), .MemWrite(MemWrite_ex), .MemtoReg(MemtoReg_ex),
				.Write_register(Write_register), .Databus2(Databus2_ex), .ALU_out(ALU_out), .PC_plus_4(PC_plus_4_ex), .PC(PC_ex),
				.Rs(Rs_ex), .Rt(Rt_ex),
				.RegWrite_n(RegWrite_mem), .MemRead_n(MemRead_mem), .MemWrite_n(MemWrite_mem), .MemtoReg_n(MemtoReg_mem),
				.Write_register_n(Write_register_mem), .Databus2_n(Databus2_mem), .ALU_out_n(ALU_out_mem), .PC_plus_4_n(PC_plus_4_mem), .PC_n(PC_mem),
				.Rs_n(Rs_mem), .Rt_n(Rt_mem));
	//MEM/WB
	MEMWBReg MEMWBReg1(.clk(myclk), .reset(reset),
				.PC_plus_4(PC_plus_4_mem), .RegWrite(RegWrite_mem), .MemtoReg(MemtoReg_mem), .Write_register(Write_register_mem),
				.ALU_out(ALU_out_mem), .Read_data(Read_data),
				.PC_plus_4_n(PC_plus_4_wb), .RegWrite_n(RegWrite_wb), .MemtoReg_n(MemtoReg_wb), .Write_register_n(Write_register_wb),
				.ALU_out_n(ALU_out_wb), .Read_data_n(Read_data_wb));
endmodule