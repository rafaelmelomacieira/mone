module mic_codec(input s_clk, input n_rst, input mic_clk, input mic_data, output logic left_mic_data, output logic right_mic_data);

logic [4:0] counter;
logic last_m_clk;

localparam DELAY = 5'd2;

always_ff @ (negedge n_rst or posedge s_clk) begin
	if (!n_rst) begin
		left_mic_data <= 1'b0;
		right_mic_data <= 1'b0;
		counter <= 5'd0;
		last_m_clk <= 1'b0;
	end else begin
		if (mic_clk ^~ last_m_clk) begin
			left_mic_data <= left_mic_data;
			right_mic_data <= right_mic_data;
			counter <= 5'd0;
			last_m_clk <= last_m_clk;
		end else begin
			if (counter >= DELAY) begin
				left_mic_data <= mic_clk ? mic_data : left_mic_data;
				right_mic_data <= !mic_clk ? mic_data : right_mic_data;
				counter <= 5'd0;
				last_m_clk <= ~last_m_clk;
			end else begin
				left_mic_data <= left_mic_data;
				right_mic_data <= right_mic_data;
				counter <= counter + 5'd1;
				last_m_clk <= last_m_clk;
			end			
		end
		
	end
end

/*always_ff @ (negedge n_rst or posedge mic_clk) begin
	if (!n_rst) begin
		left_mic_data <= 1'b0;
	end else begin
		left_mic_data <= mic_data;
	end
end

always_ff @ (negedge n_rst or negedge mic_clk) begin
	if (!n_rst) begin
		right_mic_data <= 1'b0;
	end else begin
		right_mic_data <= mic_data;
	end
end*/
	
endmodule

