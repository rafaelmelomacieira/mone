module delay_sum #(parameter POS_1 = 16'd0, POS_2 = 16'd0, WINDOW_SIZE = 16'd256)(input s_clk, input n_rst, input [WINDOW_SIZE-1:0] left_rolling_buffer, input [WINDOW_SIZE-1:0] right_rolling_buffer, output logic [15:0] energy);

logic [1:0] pdm_bits;

assign pdm_bits = {left_rolling_buffer[POS_1],right_rolling_buffer[POS_2]};

always_ff @ (negedge n_rst or posedge s_clk) begin
	if (!n_rst) begin
		energy <= 16'd0;
	end else begin
		energy <= (pdm_bits[0] == pdm_bits[1]) ? energy + 16'd1 : energy - 16'd1;   
	end
end			
	
endmodule

