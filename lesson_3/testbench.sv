`timescale 10ns / 10ps

module testbench();

logic s_clk;
logic m_clk;
logic m_data;
logic left_mic_data;
logic right_mic_data;

logic s_n_rst; 

initial begin
	s_clk = 1'b1;
	forever s_clk = #1 !s_clk;
end

initial begin
	s_n_rst = 1'b0;
	#4
	s_n_rst = 1'b1;
end

initial begin
	m_data = 1'b0;
	forever begin
		@(m_clk);
		m_data = #2 $random % 2;
	end
end

mic_pll pll_0 (
		.s_clk(s_clk), //system clock input
		.n_rst(s_n_rst), //reset input
		.us_clk(m_clk) //ultrasonic mode clock output
		//.std_clk(std_clk) //standard mode clock output
		);
					
mic_codec codec_0 (
		.s_clk(s_clk),
		.n_rst(s_n_rst),
		.mic_clk(m_clk),
		.mic_data(m_data),
		.left_mic_data(left_mic_data),
		.right_mic_data(right_mic_data)
		);

endmodule


