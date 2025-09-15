module blink_led(input n_rst,
	   	input clk,
		output logic led_status);

logic [31:0] counter;

always_ff @ (negedge n_rst or posedge clk)
begin
	if (!n_rst) begin
		led_status <= 1'b0;
		counter <= 32'd0;
	end else begin
		if (counter >= 32'd50000000) begin
			led_status <= !led_status;
			counter <= 32'd0;
		end else begin
			led_status <= led_status;
			counter <= counter + 32'd1;
		end
	end
end

endmodule
