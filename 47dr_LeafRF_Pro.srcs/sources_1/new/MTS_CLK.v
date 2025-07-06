module MTS_CLK(
    //input   aresetn,
	input   PL_CLK_N,
    input   PL_CLK_P,
    input   PL_SYSREF_N,
    input   PL_SYSREF_P,
    input   clk_adc,
    input   clk_dac,
    
	output reg user_sysref_adc,
	output reg user_sysref_dac,
	output     PL_CLK
);
	
	wire PL_SYSREF;
	reg  PL_SYSREF_SYNC;

    diff_single_g pl_clk_inst(
	   .clk_in_p(PL_CLK_P),
	   .clk_in_n(PL_CLK_N),
	   .clk(PL_CLK)
    );

    diff_single_g pl_sysref_inst(
	   .clk_in_p(PL_SYSREF_P),
	   .clk_in_n(PL_SYSREF_N),
	   .clk(PL_SYSREF)
    );

    always @(posedge PL_CLK) begin
        PL_SYSREF_SYNC <= PL_SYSREF;
    end

    always @(posedge clk_adc) begin
	   user_sysref_adc <= PL_SYSREF_SYNC;
    end

    always @(posedge clk_dac) begin
	   user_sysref_dac <= PL_SYSREF_SYNC;
    end

endmodule