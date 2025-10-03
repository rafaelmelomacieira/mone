// ============================================================================
// Copyright (c) 2015 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Tue Mar  3 15:11:40 2015
// ============================================================================

//`define ENABLE_HPS

module DE10_Nano_golden_top(

      
      ///////// FPGA /////////
      input              FPGA_CLK1_50,
      input              FPGA_CLK2_50,
      input              FPGA_CLK3_50,

      ///////// GPIO /////////
      inout       [35:0] GPIO_0,
      inout       [35:0] GPIO_1,

      ///////// HDMI /////////
     

      ///////// KEY /////////
      input       [1:0]  KEY,

      ///////// LED /////////
      output      [7:0]  LED,

      ///////// SW /////////
      input       [3:0]  SW
);

wire us_clk, std_clk;
wire [34:0] energy;

reg [7:0] LED_t;

assign GPIO_1[1] = std_clk;
assign GPIO_1[3] = std_clk;
assign GPIO_1[2] = GPIO_1[0];

assign LED = LED_t;

mic_pll pll_0 (
					.s_clk(FPGA_CLK1_50), //system clock input
					.n_rst(KEY[1]), //reset input
					.us_clk(us_clk), //ultrasonic mode clock output
					.std_clk(std_clk) //standard mode clock output
					);
					
two_mic_beamforming #(.WINDOW_SIZE(16'd256)) bf_0
					 (.s_clk(FPGA_CLK1_50),
					  .n_rst(KEY[1]),
					  .mic_clk(std_clk),
					  .mic_data(GPIO_1[0]),
					  .energy(energy),
					  .left(GPIO_1[4]),
					  .right(GPIO_1[5]));
					  
always @* begin
	case(energy[34:32])
		3'b000: LED_t = 8'b00000001;
		3'b001: LED_t = 8'b00000010;
		3'b010: LED_t = 8'b00000100;
		3'b011: LED_t = 8'b00001000;
		3'b100: LED_t = 8'b00010000;
		3'b101: LED_t = 8'b00100000;
		3'b110: LED_t = 8'b01000000;
		3'b111: LED_t = 8'b10000000;
	endcase
end
/*	
					
mic_codec codec_0 (
					  .s_clk(FPGA_CLK1_50),
					  .n_rst(KEY[1]),
					  .mic_clk(std_clk),
					  .mic_data(GPIO_1[0]),
					  .left_mic_data(GPIO_1[5]),
					  .right_mic_data(GPIO_1[4]));*/

endmodule

