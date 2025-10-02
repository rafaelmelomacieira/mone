module two_mic_beamforming #(parameter WINDOW_SIZE = 16'd256)
(input s_clk, input n_rst, input mic_clk, input mic_data, output logic signed [34:0] energy, output logic left, output logic right);

logic [4:0] counter;
logic last_m_clk, ready;

logic [WINDOW_SIZE-1:0] left_rolling_buffer;
logic [WINDOW_SIZE-1:0] right_rolling_buffer;
logic signed [31:0] energy_0, energy_1, energy_2, energy_3, energy_4, energy_5, energy_6, energy_7;
logic signed [34:0] energy_;

localparam DELAY = 5'd2;

/*assign left = left_rolling_buffer[0];
assign right = right_rolling_buffer[0];*/

logic [34:0] energy_l11, energy_l12, energy_l13, energy_l14, energy_l21, energy_l22;    
logic signed [31:0] energy_l11_s, energy_l12_s, energy_l13_s, energy_l14_s, energy_l21_s, energy_l22_s;   
assign energy_l11_s = energy_l11[31:0];
assign energy_l12_s = energy_l12[31:0];
assign energy_l13_s = energy_l13[31:0];
assign energy_l14_s = energy_l14[31:0];
assign energy_l21_s = energy_l21[31:0];
assign energy_l22_s = energy_l22[31:0];

assign energy = ready ? energy_ : energy;

always_ff @ (negedge n_rst or posedge s_clk) begin
	if (!n_rst) begin
		left_rolling_buffer <= 1'b0;
		right_rolling_buffer <= 1'b0;
		left <= 1'b0;
		right <= 1'b0;
		counter <= 5'd0;
		last_m_clk <= 1'b0;
	end else begin
		if (mic_clk == last_m_clk) begin
			left_rolling_buffer <= left_rolling_buffer;
			right_rolling_buffer <= right_rolling_buffer;
			left <= left;
			right <= right;
			counter <= 5'd0;
			last_m_clk <= last_m_clk;
		end else begin
			if (counter >= DELAY) begin
				left_rolling_buffer <= mic_clk ? (left_rolling_buffer << 1) + mic_data : left_rolling_buffer;
				left <= mic_clk ?  mic_data : left;
				right_rolling_buffer <= !mic_clk ? (right_rolling_buffer << 1) + mic_data : right_rolling_buffer;
				right <= mic_clk ?  mic_data : right;
				counter <= 5'd0;
				last_m_clk <= ~last_m_clk;
			end else begin
				left_rolling_buffer <= left_rolling_buffer;
				right_rolling_buffer <= right_rolling_buffer;
				left <= left;
				right <= right;
				counter <= counter + 5'd1;
				last_m_clk <= last_m_clk;
			end			
		end
		
	end
end

always_comb begin
	energy_l11 = energy_0 > energy_1 ? {3'b000,energy_0} : {3'b001,energy_1};
	energy_l12 = energy_2 > energy_3 ? {3'b010,energy_2} : {3'b011,energy_3};  
	energy_l13 = energy_4 > energy_5 ? {3'b100,energy_4} : {3'b101,energy_5};  
	energy_l14 = energy_6 > energy_7 ? {3'b110,energy_6} : {3'b111,energy_7};
	energy_l21 = energy_l11_s > energy_l12_s ? energy_l11 : energy_l12;
	energy_l22 = energy_l13_s > energy_l14_s ? energy_l13 : energy_l14; 
	energy_ = energy_l21_s > energy_l22_s ? energy_l21 : energy_l22;
end

delay_sum ang_0 (.s_clk(mic_clk),.n_rst(n_rst),
		   .pos_1(left_rolling_buffer[0]),
		   .pos_2(right_rolling_buffer[230]),
		   .energy(energy_0), .ready(ready));

delay_sum ang_1 (.s_clk(mic_clk),.n_rst(n_rst),
		   .pos_1(left_rolling_buffer[0]),
		   .pos_2(right_rolling_buffer[196]),
		   .energy(energy_1));

delay_sum ang_2 (.s_clk(mic_clk),.n_rst(n_rst),
		   .pos_1(left_rolling_buffer[0]),
		   .pos_2(right_rolling_buffer[132]),
		   .energy(energy_2));

delay_sum ang_3 (.s_clk(mic_clk),.n_rst(n_rst),
		   .pos_1(left_rolling_buffer[0]),
		   .pos_2(right_rolling_buffer[46]),
		   .energy(energy_3));

delay_sum ang_4 (.s_clk(mic_clk),.n_rst(n_rst),
		   .pos_1(left_rolling_buffer[46]),
		   .pos_2(right_rolling_buffer[0]),
		   .energy(energy_4));

delay_sum ang_5 (.s_clk(mic_clk),.n_rst(n_rst),
		   .pos_1(left_rolling_buffer[132]),
		   .pos_2(right_rolling_buffer[0]),
		   .energy(energy_5));

delay_sum ang_6 (.s_clk(mic_clk),.n_rst(n_rst),
		   .pos_1(left_rolling_buffer[196]),
		   .pos_2(right_rolling_buffer[0]),
		   .energy(energy_6));

delay_sum ang_7 (.s_clk(mic_clk),.n_rst(n_rst),
		   .pos_1(left_rolling_buffer[230]),
		   .pos_2(right_rolling_buffer[0]),
		   .energy(energy_7));
	
endmodule

