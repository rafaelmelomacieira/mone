module signed_fir_17_64 (
    input s_clk,
    input n_rst,
    input mic_clk,
    input left_pdm_data,
    input right_pdm_data,
    input pdm_data_ready,
    output logic sound_data_ready,
    output logic signed [15:0] l_sound_data,
    output logic signed [15:0] r_sound_data
    );
parameter WINDOWSIZE = 64;
parameter SAMPLESIZE = 17;

logic [15:0] kernel [0:(WINDOWSIZE/2)-1] = '{1,2,4,8,13,21,31,45,63,85,112,145,
					     184,229,280,337,400,468,541,617,696,
					     776,855,933,1007,1076,1139,1194,1239,
					     1274,1298,1310};

logic [WINDOWSIZE-1:0] left_window;
logic [WINDOWSIZE-1:0] right_window;

logic signed [15:0] r_local_kernel_buffer [0:WINDOWSIZE-1];
logic signed [15:0] l_local_kernel_buffer [0:WINDOWSIZE-1];

logic [5:0] sample_counter, cycle_counter;

logic signed [15:0] l_sound_data_buffer;
logic signed [15:0] r_sound_data_buffer;

typedef enum logic [1:0] {IDLE, CONV, SUM} filter_state_t;

filter_state_t filter_state, filter_next_state;

assign start_conv = (sample_counter == 0);

always_comb begin
    case(filter_state)
	IDLE: filter_next_state = start_conv ? CONV : IDLE;
        CONV: filter_next_state = SUM;
        SUM: filter_next_state = (cycle_counter== 6'd16) ? IDLE : SUM;
	endcase
end

always_ff @ (negedge n_rst or posedge pdm_data_ready) begin
    if (!n_rst) begin
        left_window <= {WINDOWSIZE{1'b0}};
        right_window <= {WINDOWSIZE{1'b0}};
        sample_counter <= 6'd0;
    end else begin
        left_window <= mic_clk ? (left_window << 1) + left_pdm_data : left_window; 
        right_window <= !mic_clk ? (right_window << 1) + right_pdm_data : right_window;
        sample_counter <= (sample_counter > (SAMPLESIZE*2)) ? 6'd0 : sample_counter + 6'd1;
    end
end

always_ff @ (negedge n_rst or posedge s_clk) begin
    if (!n_rst) begin
        filter_state <= IDLE;
        sound_data_ready <= 1'b0;
        for (int i = 0; i < WINDOWSIZE; i++) begin
            l_local_kernel_buffer[i] <= 16'sd0;
            r_local_kernel_buffer[i] <= 16'sd0;
        end
        l_sound_data <= 16'sd0;
        r_sound_data <= 16'sd0;
        l_sound_data_buffer <= 16'sd0;
        r_sound_data_buffer <= 16'sd0;
        cycle_counter <= 6'd0;
    end else begin
        filter_state <= filter_next_state;
        case (filter_state)
            IDLE: begin
                l_sound_data <= l_sound_data;
                r_sound_data <= r_sound_data;
                l_sound_data_buffer <= 16'sd0;
                r_sound_data_buffer <= 16'sd0;
                sound_data_ready <= 1'b0;
                cycle_counter <= 6'd0;
            end
            CONV:begin
                for (int i = 0; i < WINDOWSIZE/2; i++) begin
                    l_local_kernel_buffer[i] <= left_window[i] ? kernel[i] : kernel[i] * -1;
                    l_local_kernel_buffer[WINDOWSIZE-1-i] <= left_window[WINDOWSIZE-1-i] ? kernel[i] : kernel[i] * -1;
                    r_local_kernel_buffer[i] <= right_window[i] ? kernel[i] : kernel[i] * -1;
                    r_local_kernel_buffer[WINDOWSIZE-1-i] <= right_window[WINDOWSIZE-1-i] ? kernel[i] : kernel[i] * -1;
                end
                sound_data_ready <= 1'b0;
                cycle_counter <= 6'd0;
                l_sound_data <= l_sound_data;
                r_sound_data <= r_sound_data;
                l_sound_data_buffer <= l_sound_data_buffer;
                r_sound_data_buffer <= r_sound_data_buffer;
            end
            SUM:
            begin
                if (cycle_counter < 6'd16) begin
                    l_sound_data_buffer <= l_sound_data_buffer +
		    l_local_kernel_buffer[cycle_counter] +
                    l_local_kernel_buffer[cycle_counter+16] +
		    l_local_kernel_buffer[cycle_counter+32] +
		    l_local_kernel_buffer[cycle_counter+48];
                    
                    r_sound_data_buffer <= r_sound_data_buffer +
		    r_local_kernel_buffer[cycle_counter] +
                    r_local_kernel_buffer[cycle_counter+16] +
		    r_local_kernel_buffer[cycle_counter+32] + 
		    r_local_kernel_buffer[cycle_counter+48];
                    cycle_counter <= cycle_counter + 6'd1;
                    sound_data_ready <= 1'b0;
                end else begin
                    cycle_counter <= 6'd0;
                    l_sound_data <= l_sound_data_buffer;
                    r_sound_data <= r_sound_data_buffer;
                    sound_data_ready <= 1'b1;
                    l_sound_data_buffer <= l_sound_data_buffer;
                    r_sound_data_buffer <= r_sound_data_buffer;
                end
            end
            default: begin
                l_sound_data <= l_sound_data;
                r_sound_data <= r_sound_data;
                l_sound_data_buffer <= l_sound_data_buffer;
                r_sound_data_buffer <= r_sound_data_buffer;
                sound_data_ready <= 1'b0;
                cycle_counter <= 6'd0;
            end
        endcase
    end
end

endmodule
