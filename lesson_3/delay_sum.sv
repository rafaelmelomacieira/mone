module delay_sum (input s_clk, input n_rst, input signed [15:0] pos_1, input signed [15:0] pos_2, output logic signed [31:0] energy, output logic ready);

parameter STEPS = 100;//840;
logic [31:0] counter;
logic signed [31:0] energy_;

always_ff @ (negedge n_rst or posedge s_clk) begin
	if (!n_rst) begin
		energy_ <= 32'sd0;
		energy <= 32'sd0;
		counter <= 32'd0;
		ready <= 1'b0;
	end else begin
		if (counter < STEPS) begin
			energy_ <= ((pos_1 + pos_2) > 0) ? energy_ + (pos_1 + pos_2) : energy_ - (pos_1 + pos_2);
			counter <= counter + 32'd1;
			ready <= 1'b0;
			energy <= energy;
		end else begin
			ready <= 1'b1;
			counter <= 32'd0;
			energy_ <= 32'sd0;
			energy <= energy_;  
		end
	end
end			

endmodule

