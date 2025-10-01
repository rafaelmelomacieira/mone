module mic_pll (s_clk, n_rst, us_clk, std_clk);

parameter US_RATIO = 6;
parameter STD_RATIO = 1;

input  s_clk;     
input  n_rst;     
output logic us_clk;
output logic std_clk;

logic [3:0]  counter_us; 
logic [10:0] counter_std;

always_ff @ (negedge n_rst or posedge s_clk) begin
    if (!n_rst) begin
        counter_us <= 4'b0;
        us_clk <= 1'b0;
    end else begin
        if (counter_us == US_RATIO - 1) begin
                counter_us <= 4'b0;
                us_clk <= ~us_clk; 
        end else begin
                counter_us <= counter_us + 4'b1;
        end
    end
end

always_ff @ (negedge n_rst or posedge us_clk) begin
    if (!n_rst) begin
        counter_std <= 4'b0;
        std_clk <= 1'b0;
    end else begin
        if (counter_std == STD_RATIO - 1) begin
                counter_std <= 4'b0;
                std_clk <= ~std_clk; 
        end else begin
                counter_std <= counter_std + 4'b1;
        end
    end
end

endmodule
