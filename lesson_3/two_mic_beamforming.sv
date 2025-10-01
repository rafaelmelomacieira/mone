module two_mic_beamforming #(parameter WINDOW_SIZE = 16'd256)
(input s_clk, input n_rst, input mic_clk, input mic_data)//, output logic left_mic_data, output logic right_mic_data);

logic [4:0] counter;
logic last_m_clk;

logic [WINDOW_SIZE-1:0} left_rolling_buffer;
logic [WINDOW_SIZE-1:0} right_rolling_buffer;

localparam DELAY = 5'd2;

always_ff @ (negedge n_rst or posedge s_clk) begin
	if (!n_rst) begin
		left_rolling_buffer <= 1'b0;
		right_rolling_buffer <= 1'b0;
		counter <= 5'd0;
		last_m_clk <= 1'b0;
	end else begin
		if (mic_clk == last_m_clk) begin
			left_rolling_buffer <= left_rolling_buffer;
			right_rolling_buffer <= right_rolling_buffer;
			counter <= 5'd0;
			last_m_clk <= last_m_clk;
		end else begin
			if (counter >= DELAY) begin
				left_rolling_buffer <= mic_clk ? (left_rolling_buffer << 1) + mic_data : left_rolling_buffer;
				right_rolling_buffer <= !mic_clk ? (right_rolling_buffer << 1) + mic_data : right_rolling_buffer;
				counter <= 5'd0;
				last_m_clk <= ~last_m_clk;
			end else begin
				left_rolling_buffer <= left_rolling_buffer;
				right_rolling_buffer <= right_rolling_buffer;
				counter <= counter + 5'd1;
				last_m_clk <= last_m_clk;
			end			
		end
		
	end
end

delay_sum #(.POS_1(10), .POS_2(20)) ang_0 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy());

delay_sum #(.POS_1(10), .POS_2(20)) ang_1 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy());

delay_sum #(.POS_1(10), .POS_2(20)) ang_2 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy());

delay_sum #(.POS_1(10), .POS_2(20)) ang_3 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy());

delay_sum #(.POS_1(10), .POS_2(20)) ang_4 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy());

delay_sum #(.POS_1(10), .POS_2(20)) ang_5 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy());

delay_sum #(.POS_1(10), .POS_2(20)) ang_6 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy());

delay_sum #(.POS_1(10), .POS_2(20)) ang_7 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffers),
					   .energy());
	
endmodule

