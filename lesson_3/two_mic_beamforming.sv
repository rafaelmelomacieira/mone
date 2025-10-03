module two_mic_beamforming #(parameter WINDOW_SIZE = 16'd256)
(input s_clk, input n_rst, input mic_clk, input mic_data, output logic signed [34:0] energy, output logic left, output logic right);

logic [4:0] counter;
logic last_m_clk, ready, pdm_ready;

logic [3:0] fir_sample_counter;

logic signed [31:0] energy_0, energy_1, energy_2, energy_3, energy_4, energy_5, energy_6, energy_7;
logic signed [34:0] energy_;

logic sound_data_ready, sound_data_buffer_ready;
logic signed [15:0] l_sound_data, r_sound_data;
logic signed [15:0] l_sound_data_buffer [0:13];
logic signed [15:0] r_sound_data_buffer [0:13];

localparam DELAY = 5'd2;

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
		left <= 1'b0;
		right <= 1'b0;
		counter <= 5'd0;
		last_m_clk <= 1'b0;
		pdm_ready <= 1'b0;
	end else begin
		if (mic_clk == last_m_clk) begin
			left <= left;
			right <= right;
			counter <= 5'd0;
			last_m_clk <= last_m_clk;
			pdm_ready <= 1'b0;
		end else begin
			if (counter >= DELAY) begin
				left <= mic_clk ?  mic_data : left;
				right <= !mic_clk ?  mic_data : right;
				counter <= 5'd0;
				last_m_clk <= ~last_m_clk;
				pdm_ready <= 1'b1;
			end else begin
				left <= left;
				right <= right;
				counter <= counter + 5'd1;
				last_m_clk <= last_m_clk;
				pdm_ready <= 1'b0;
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

//FILTER FIR SAMPLE 17 WINDOW 64. 
signed_fir_17_64 fir17_64 (.s_clk(s_clk),
    		  .n_rst(n_rst),
     		 .mic_clk(mic_clk),
    		.left_pdm_data(left),
    		.right_pdm_data(right),
    		.pdm_data_ready(pdm_ready),
    		.sound_data_ready(sound_data_ready),
    		.l_sound_data(l_sound_data),
    		.r_sound_data(r_sound_data)
    );
   
always_ff @ (negedge n_rst or posedge sound_data_ready) begin
	if (!n_rst) begin
		fir_sample_counter <= 4'd0;
		sound_data_buffer_ready <= 1'd1;
		for (int i = 0; i<14; i++) begin
			l_sound_data_buffer[i] <= 1'd0;
			r_sound_data_buffer[i] <= 1'd0;	
		end
	end else begin
		if (fir_sample_counter < 4'd14) begin
			l_sound_data_buffer[fir_sample_counter] <= l_sound_data;
			r_sound_data_buffer[fir_sample_counter] <= r_sound_data;
			fir_sample_counter <= fir_sample_counter + 4'd1;
			sound_data_buffer_ready <= 1'd0;
		end else begin
			fir_sample_counter <= 4'd0;
			sound_data_buffer_ready <= 1'd1;
			for (int i = 0; i<14; i++) begin
				l_sound_data_buffer[i] <= l_sound_data_buffer[i];
				r_sound_data_buffer[i] <= r_sound_data_buffer[i];	
			end
		end
	end
end

delay_sum ang_0 (.s_clk(sound_data_buffer_ready),.n_rst(n_rst),
		   .pos_1(l_sound_data_buffer[12]),
		   .pos_2(r_sound_data_buffer[0]),
		   .energy(energy_0), .ready(ready));

delay_sum ang_1 (.s_clk(sound_data_buffer_ready),.n_rst(n_rst),
		   .pos_1(l_sound_data_buffer[9]),
		   .pos_2(r_sound_data_buffer[0]),
		   .energy(energy_1));

delay_sum ang_2 (.s_clk(sound_data_buffer_ready),.n_rst(n_rst),
		   .pos_1(l_sound_data_buffer[6]),
		   .pos_2(r_sound_data_buffer[0]),
		   .energy(energy_2));

delay_sum ang_3 (.s_clk(sound_data_buffer_ready),.n_rst(n_rst),
		   .pos_1(l_sound_data_buffer[2]),
		   .pos_2(r_sound_data_buffer[0]),
		   .energy(energy_3));

delay_sum ang_4 (.s_clk(sound_data_buffer_ready),.n_rst(n_rst),
		   .pos_1(l_sound_data_buffer[0]),
		   .pos_2(r_sound_data_buffer[2]),
		   .energy(energy_4));

delay_sum ang_5 (.s_clk(sound_data_buffer_ready),.n_rst(n_rst),
		   .pos_1(l_sound_data_buffer[0]),
		   .pos_2(r_sound_data_buffer[6]),
		   .energy(energy_5));

delay_sum ang_6 (.s_clk(sound_data_buffer_ready),.n_rst(n_rst),
		   .pos_1(l_sound_data_buffer[0]),
		   .pos_2(r_sound_data_buffer[9]),
		   .energy(energy_6));

delay_sum ang_7 (.s_clk(sound_data_buffer_ready),.n_rst(n_rst),
		   .pos_1(l_sound_data_buffer[0]),
		   .pos_2(r_sound_data_buffer[12]),
		   .energy(energy_7));
	
endmodule

