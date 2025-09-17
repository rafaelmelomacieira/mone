`timescale 20ns / 10ps

module testbench();

logic s_clk;
logic s_n_rst; 
logic led_out;

blink_led led_0(.clk(s_clk),
		.n_rst(s_n_rst),
		.led_out(led_out)
		);

initial begin
	s_clk = 1'b1;
	forever s_clk = #1 !s_clk;
end

initial begin
	s_n_rst = 1'b0;
	#4
	s_n_rst = 1'b1;
end

endmodule
