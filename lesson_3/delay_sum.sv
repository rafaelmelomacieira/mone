module delay_sum (input s_clk, input n_rst, input pos_1, input pos_2, output logic signed [31:0] energy, output logic ready);

logic [31:0] counter;
logic signed [31:0] energy_1, energy_2, energy_;

always_ff @ (negedge n_rst or posedge s_clk) begin
	if (!n_rst) begin
		energy_1 <= 32'sd0;
		energy_2 <= 32'sd0;
		energy_ <= 32'sd0;
		energy <= 32'sd0;
		counter <= 32'd0;
		ready <= 1'b0;
	end else begin
		if (counter < 32'd256) begin
			/*if (pdm_bits[0] == pdm_bits[1]) begin
				energy <= (energy < 32'sd500000) ? energy + 32'sd1 : energy;
				//energy <= energy + 32'sd1;
			end else begin
				energy <= (energy > -32'sd500000) ? energy - 32'sd1 : energy;
				//energy <= energy - 32'sd1;
			end*/
			//energy_ <= (pos_1 == pos_2) ? energy_ + 32'sd1 : energy_;
			energy_1 <= pos_1 ? energy_1 + 32'sd1 : energy_1 - 32'sd1;
			energy_2 <= pos_2 ? energy_2 + 32'sd1 : energy_2 - 32'sd1;
			counter <= counter + 32'sd1;
			ready <= 1'b0;
			energy <= 32'sd0;
		end else begin
			ready <= 1'b1;
			counter <= 32'd0;
			energy_ <= 32'sd0;
			energy_1 <= 32'sd0;
			energy_2 <= 32'sd0;
			energy <= (energy_1 > energy_2) ? (energy_1 - energy_2) : (energy_2 - energy_1);  
		end
	end
end			
	
endmodule

