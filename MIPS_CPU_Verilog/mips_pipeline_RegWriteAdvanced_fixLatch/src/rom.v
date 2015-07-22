`timescale 1ns/1ps

module ROM (addr,data);
	input [31:0] addr;
	output [31:0] data;
	reg [31:0] data;
	localparam ROM_SIZE = 32;
	reg [31:0] ROM_DATA[ROM_SIZE-1:0];

	always@(*)
		case(addr[9:2])	//Address Must Be Word Aligned.
			8'd0: data <= 32'h08000087;	
			8'd1: data <= 32'h08000005;	
			8'd2: data <= 32'h0800005e;	
			8'd3: data <= 32'h08000063;	
			8'd4: data <= 32'h08000067;	
			8'd5: data <= 32'h3c084000;	
			8'd6: data <= 32'h21080008;	
			8'd7: data <= 32'h8d090000;	
			8'd8: data <= 32'h3129fff9;	
			8'd9: data <= 32'had090000;	
			8'd10: data <= 32'h200f00fc;	
			8'd11: data <= 32'h8dea0000;	
			8'd12: data <= 32'h8d0b000c;	
			8'd13: data <= 32'h000b5a02;	
			8'd14: data <= 32'h316c0001;	
			8'd15: data <= 32'h000c60c0;	
			8'd16: data <= 32'h000b5842;	
			8'd17: data <= 32'h016c5825;	
			8'd18: data <= 32'h01606020;	
			8'd19: data <= 32'h318d0008;	
			8'd20: data <= 32'h11a00004;	
			8'd21: data <= 32'h000d6842;	
			8'd22: data <= 32'h000a5102;	
			8'd23: data <= 32'h01ac6824;	
			8'd24: data <= 32'h08000014;	
			8'd25: data <= 32'h314a000f;	
			8'd26: data <= 32'h000b5a00;	
			8'd27: data <= 32'h200e0000;	
			8'd28: data <= 32'h114e001d;	
			8'd29: data <= 32'h200e0001;	
			8'd30: data <= 32'h114e001d;	
			8'd31: data <= 32'h200e0002;	
			8'd32: data <= 32'h114e001d;	
			8'd33: data <= 32'h200e0003;	
			8'd34: data <= 32'h114e001d;	
			8'd35: data <= 32'h200e0004;	
			8'd36: data <= 32'h114e001d;	
			8'd37: data <= 32'h200e0005;	
			8'd38: data <= 32'h114e001d;	
			8'd39: data <= 32'h200e0006;	
			8'd40: data <= 32'h114e001d;	
			8'd41: data <= 32'h200e0007;	
			8'd42: data <= 32'h114e001d;	
			8'd43: data <= 32'h200e0008;	
			8'd44: data <= 32'h114e001d;	
			8'd45: data <= 32'h200e0009;	
			8'd46: data <= 32'h114e001d;	
			8'd47: data <= 32'h200e000a;	
			8'd48: data <= 32'h114e001d;	
			8'd49: data <= 32'h200e000b;	
			8'd50: data <= 32'h114e001d;	
			8'd51: data <= 32'h200e000c;	
			8'd52: data <= 32'h114e001d;	
			8'd53: data <= 32'h200e000d;	
			8'd54: data <= 32'h114e001d;	
			8'd55: data <= 32'h200e000e;	
			8'd56: data <= 32'h114e001d;	
			8'd57: data <= 32'h08000058;	
			8'd58: data <= 32'h216b00fc;	
			8'd59: data <= 32'h0800005a;	
			8'd60: data <= 32'h216b0060;	
			8'd61: data <= 32'h0800005a;	
			8'd62: data <= 32'h216b00da;	
			8'd63: data <= 32'h0800005a;	
			8'd64: data <= 32'h216b00f2;	
			8'd65: data <= 32'h0800005a;	
			8'd66: data <= 32'h216b0066;	
			8'd67: data <= 32'h0800005a;	
			8'd68: data <= 32'h216b00b6;	
			8'd69: data <= 32'h0800005a;	
			8'd70: data <= 32'h216b00be;	
			8'd71: data <= 32'h0800005a;	
			8'd72: data <= 32'h216b00e0;	
			8'd73: data <= 32'h0800005a;	
			8'd74: data <= 32'h216b00fe;	
			8'd75: data <= 32'h0800005a;	
			8'd76: data <= 32'h216b00f6;	
			8'd77: data <= 32'h0800005a;	
			8'd78: data <= 32'h216b00ee;	
			8'd79: data <= 32'h0800005a;	
			8'd80: data <= 32'h216b00ff;	
			8'd81: data <= 32'h0800005a;	
			8'd82: data <= 32'h216b009c;	
			8'd83: data <= 32'h0800005a;	
			8'd84: data <= 32'h216b00fd;	
			8'd85: data <= 32'h0800005a;	
			8'd86: data <= 32'h216b009e;	
			8'd87: data <= 32'h0800005a;	
			8'd88: data <= 32'h216b008e;	
			8'd89: data <= 32'h0800005a;	
			8'd90: data <= 32'had0b000c;	
			8'd91: data <= 32'h21290002;	
			8'd92: data <= 32'had090000;	
			8'd93: data <= 32'h03400008;	
			8'd94: data <= 32'h3c084000;	
			8'd95: data <= 32'h21080018;	
			8'd96: data <= 32'h2009005a;	
			8'd97: data <= 32'had090000;	
			8'd98: data <= 32'h03400008;	
			8'd99: data <= 32'h3c084000;	
			8'd100: data <= 32'h21080018;	
			8'd101: data <= 32'h8d090000;	
			8'd102: data <= 32'h03400008;	
			8'd103: data <= 32'h3c084000;	
			8'd104: data <= 32'h2108001c;	
			8'd105: data <= 32'h8d090000;	
			8'd106: data <= 32'h200a00fc;	
			8'd107: data <= 32'h8d4b0000;	
			8'd108: data <= 32'h000b6402;	
			8'd109: data <= 32'h15800004;	
			8'd110: data <= 32'h3c0b0001;	
			8'd111: data <= 32'h01695820;	
			8'd112: data <= 32'had4b0000;	
			8'd113: data <= 32'h03400008;	
			8'd114: data <= 32'h00094a00;	
			8'd115: data <= 32'h01695820;	
			8'd116: data <= 32'h000b5c00;	
			8'd117: data <= 32'h000b5c02;	
			8'd118: data <= 32'had4b0000;	
			8'd119: data <= 32'h316e00ff;	
			8'd120: data <= 32'h316fff00;	
			8'd121: data <= 32'h000f7a02;	
			8'd122: data <= 32'h11e00007;	
			8'd123: data <= 32'h01ee6822;	
			8'd124: data <= 32'h1da00001;	
			8'd125: data <= 32'h01cf7022;	
			8'd126: data <= 32'h000e6820;	
			8'd127: data <= 32'h000f7020;	
			8'd128: data <= 32'h000d7820;	
			8'd129: data <= 32'h0800007a;	
			8'd130: data <= 32'h3c084000;	
			8'd131: data <= 32'h2108000c;	
			8'd132: data <= 32'had0e0000;	
			8'd133: data <= 32'had0e000c;	
			8'd134: data <= 32'h03400008;	
			8'd135: data <= 32'h3c084000;	
			8'd136: data <= 32'h200907ff;	
			8'd137: data <= 32'had090014;	
			8'd138: data <= 32'had00000c;	
			8'd139: data <= 32'h3c09ffff;	
			8'd140: data <= 32'h21293caf;	
			8'd141: data <= 32'had090000;	
			8'd142: data <= 32'h00004827;	
			//8'd142: data <= 32'had090000;	
			8'd143: data <= 32'had090004;	
			8'd144: data <= 32'h20090003;	
			8'd145: data <= 32'had090008;	
			8'd146: data <= 32'h20090002;	
			8'd147: data <= 32'had090020;	
			8'd148: data <= 32'h200a0258;	
			8'd149: data <= 32'h01400008;	
			8'd150: data <= 32'hfac23e4e;
			8'd151: data <= 32'h08000097;	
			default:	data <= 32'h08000097;
		endcase
endmodule