`timescale 10ns / 10ps

module testbench();

logic s_clk;
logic std_clk;
logic m_data;


logic mic_pdm;
logic s_n_rst; 
localparam MEM_SIZE = 4096 * 2;
localparam MEM_FILE = "pdm_columns_2ch_2_083MHz_1s_4cm_2kHz_60deg.mem";
//localparam MEM_FILE = "pdm_columns_2ch_2_083MHz_1s_4cm_2kHz_0deg.mem";
logic [1:0] mem [0:MEM_SIZE-1];



initial begin
	s_clk = 1'b1;
	forever s_clk = #1 !s_clk;
end

initial begin
	s_n_rst = 1'b0;
	#4
	s_n_rst = 1'b1;
end

initial begin
    int index = -1;
    mic_pdm = 0;
    $readmemb(MEM_FILE, mem);
    @(posedge s_n_rst);
    for (int i = 0; i<MEM_SIZE; i++) begin
        @(posedge std_clk);
        #2
        mic_pdm = mem[i][0];
        @(negedge std_clk);
        #2
        mic_pdm = mem[i][1];
    end
    $finish;
end

mic_pll pll_0 (
	.s_clk(s_clk), //system clock input
	.n_rst(s_n_rst), //reset input
	//.us_clk(m_clk) //ultrasonic mode clock output
	.std_clk(std_clk) //standard mode clock output
	);

two_mic_beamforming #(.WINDOW_SIZE(16'd256))
	beamforming_0 (.s_clk(s_clk),
	.n_rst(s_n_rst), .mic_clk(std_clk), .mic_data(mic_pdm)
	);

endmodule


