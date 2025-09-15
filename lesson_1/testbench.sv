`timescale 100 ms / 1 ms
`define CLKPERIOD 2

module led_tb;

logic s_clk;
logic n_rst;
logic led;

initial
begin
	s_clk = 1'b1;	
	forever s_clk = #(`CLKPERIOD/2) !s_clk;
end

initial 
begin
	n_rst = 1'b0;
	#(`CLKPERIOD*2)
	n_rst = 1'b1;
end

blink_led led_0(.n_rst(n_rst),
	   	.clk(s_clk),
		.led_status(led)
		);
   
endmodule
