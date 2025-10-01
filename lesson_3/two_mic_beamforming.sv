module two_mic_beamforming #(parameter WINDOW_SIZE = 16'd256)
(input s_clk, input n_rst, input mic_clk, input mic_data, output logic [15:0] energy);

logic [4:0] counter;
logic last_m_clk;

logic [WINDOW_SIZE-1:0] left_rolling_buffer;
logic [WINDOW_SIZE-1:0] right_rolling_buffer;
logic [15:0] energy_0, energy_1, energy_2, energy_3, energy_4, energy_5, energy_6, energy_7;

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

always_comb begin
	automatic logic [15:0] energy_l11 = energy_0 > energy_1 ? energy_0 : energy_1;
	automatic logic [15:0] energy_l12 = energy_2 > energy_3 ? energy_2 : energy_3;  
	automatic logic [15:0] energy_l13 = energy_4 > energy_5 ? energy_4 : energy_5;  
	automatic logic [15:0] energy_l14 = energy_6 > energy_7 ? energy_6 : energy_7;
	automatic logic [15:0] energy_l21 = energy_l11 > energy_l12 ? energy_l11 : energy_l12;
	automatic logic [15:0] energy_l22 = energy_l13 > energy_l14 ? energy_l13 : energy_l14; 
	energy = energy_l21 > energy_l22 ? energy_l21 : energy_l22;
end

delay_sum #(.POS_1(10), .POS_2(20), .WINDOW_SIZE(256)) ang_0 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy(energy_0));

delay_sum #(.POS_1(20), .POS_2(30), .WINDOW_SIZE(256)) ang_1 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy(energy_1));

delay_sum #(.POS_1(30), .POS_2(40), .WINDOW_SIZE(256)) ang_2 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy(energy_2));

delay_sum #(.POS_1(40), .POS_2(50), .WINDOW_SIZE(256)) ang_3 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy(energy_3));

delay_sum #(.POS_1(50), .POS_2(60), .WINDOW_SIZE(256)) ang_4 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy(energy_4));

delay_sum #(.POS_1(60), .POS_2(70), .WINDOW_SIZE(256)) ang_5 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy(energy_5));

delay_sum #(.POS_1(70), .POS_2(80), .WINDOW_SIZE(256)) ang_6 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy(energy_6));

delay_sum #(.POS_1(80), .POS_2(90), .WINDOW_SIZE(256)) ang_7 (.s_clk(s_clk),.n_rst(n_rst),
					   .left_rolling_buffer(left_rolling_buffer),
					   .right_rolling_buffer(right_rolling_buffer),
					   .energy(energy_7));
	
endmodule

