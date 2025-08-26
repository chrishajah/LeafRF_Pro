module rfsoc_top(
    input   [127:0]     dac0_data_in,
    //input   [127:0]     dac1_data_in,
    input               dac0_data_valid,
    //input               dac1_data_valid,
    output  [127:0]     adc0_data_out,
    output  [127:0]     adc1_data_out,

    output              adc0_I_data_valid,
    output              adc0_Q_data_valid,
    output              adc1_I_data_valid,
    output              adc1_Q_data_valid,

    input               DAC0_CLK_N,
    input               DAC0_CLK_P,
    input               ADC0_CLK_N,
    input               ADC0_CLK_P,
    input               SYSREF_N,
    input               SYSREF_P,
    input               clk_100M,
    input               clk_492M,


    output              dac_clk,
    output              adc_clk,
    output              DAC0_OUT_N,
    output              DAC0_OUT_P,
    output              DAC1_OUT_N,
    output              DAC1_OUT_P,

    input               ADC0_IN_N,
    input               ADC0_IN_P,
    input               ADC1_IN_N,
    input               ADC1_IN_P

);

wire [127:0]        reversed_dac0_data_in;
wire [63:0]        adc0_I_data_out,adc0_Q_data_out,adc1_I_data_out,adc1_Q_data_out;   

assign reversed_dac0_data_in = {dac0_data_in[15:0],dac0_data_in[31:16],dac0_data_in[47:32],dac0_data_in[63:48],
        dac0_data_in[79:64],dac0_data_in[95:80],dac0_data_in[111:96],dac0_data_in[127:112]};

assign adc0_data_out = {adc0_I_data_out,adc0_Q_data_out};
assign adc1_data_out = {adc1_I_data_out,adc1_Q_data_out};


ila_5 u_rf_dac(
    .clk(clk_492M),
    .probe0(dac0_data_in),
    .probe1(reversed_dac0_data_in),
    .probe2(dac0_data_valid),
    .probe3(s0_tready)
);

wire s0_tready,s2_tready;

usp_rf_data_converter_0 u_rf_data_converter (
    .adc0_clk_n(ADC0_CLK_N),
    .adc0_clk_p(ADC0_CLK_P),
    .dac0_clk_p(DAC0_CLK_P),            // input wire dac0_clk_p
    .dac0_clk_n(DAC0_CLK_N),            // input wire dac0_clk_n

    .clk_dac0(dac_clk),                // output wire clk_dac0
    .clk_adc0(adc_clk),
    .s_axi_aclk(clk_100M),            // input wire s_axi_aclk
    .s_axi_aresetn(1'b1),      // input wire s_axi_aresetn
    .s_axi_awaddr(18'd0),        // input wire [17 : 0] s_axi_awaddr
    .s_axi_awvalid(1'b0),      // input wire s_axi_awvalid
    .s_axi_awready(),      // output wire s_axi_awready
    .s_axi_wdata(32'd0),          // input wire [31 : 0] s_axi_wdata
    .s_axi_wstrb(4'b1111),          // input wire [3 : 0] s_axi_wstrb
    .s_axi_wvalid(1'b0),        // input wire s_axi_wvalid
    .s_axi_wready(),        // output wire s_axi_wready
    .s_axi_bresp(),          // output wire [1 : 0] s_axi_bresp
    .s_axi_bvalid(),        // output wire s_axi_bvalid
    .s_axi_bready(1'b0),        // input wire s_axi_bready
    .s_axi_araddr(18'd0),        // input wire [17 : 0] s_axi_araddr
    .s_axi_arvalid(1'b0),      // input wire s_axi_arvalid
    .s_axi_arready(),      // output wire s_axi_arready
    .s_axi_rdata(),          // output wire [31 : 0] s_axi_rdata
    .s_axi_rresp(),          // output wire [1 : 0] s_axi_rresp
    .s_axi_rvalid(),        // output wire s_axi_rvalid
    .s_axi_rready(1'b0),        // input wire s_axi_rready
    .irq(),                          // output wire irq


    .m0_axis_aresetn(1'b1),
    .m0_axis_aclk(adc_clk),
    .sysref_in_p(SYSREF_P),          // input wire sysref_in_p
    .sysref_in_n(SYSREF_N),          // input wire sysref_in_n
    .vout00_p(DAC0_OUT_P),                // output wire vout00_p
    .vout00_n(DAC0_OUT_N),                // output wire vout00_n
    .vout02_p(DAC1_OUT_P),                // output wire vout02_p
    .vout02_n(DAC1_OUT_N),                // output wire vout02_n
    .vin0_01_n(ADC0_IN_N),
    .vin0_01_p(ADC0_IN_P),
    .vin0_23_n(ADC1_IN_N),
    .vin0_23_p(ADC1_IN_P),
    .s0_axis_aresetn(1'b1),  // input wire s0_axis_aresetn
    .s0_axis_aclk(clk_492M),        // input wire s0_axis_aclk
    .s00_axis_tdata(reversed_dac0_data_in),    // input wire [127 : 0] s00_axis_tdata
    .s00_axis_tvalid(dac0_data_valid),  // input wire s00_axis_tvalid
    .s00_axis_tready(s0_tready),  // output wire s00_axis_tready
    .s02_axis_tdata(reversed_dac0_data_in),    // input wire [127 : 0] s02_axis_tdata
    .s02_axis_tvalid(dac0_data_valid),  // input wire s02_axis_tvalid
    .s02_axis_tready(s2_tready),  // output wire s02_axis_tready

    .m00_axis_tdata(adc0_I_data_out),    // output wire [63 : 0] m00_axis_tdata
    .m00_axis_tvalid(adc0_I_data_valid),  // output wire m00_axis_tvalid
    .m00_axis_tready(1'b1),  // input wire m00_axis_tready

    .m01_axis_tdata(adc0_Q_data_out),    // output wire [63 : 0] m00_axis_tdata
    .m01_axis_tvalid(adc0_Q_data_valid),  // output wire m00_axis_tvalid
    .m01_axis_tready(1'b1),  // input wire m00_axis_tready

    .m02_axis_tdata(adc1_I_data_out),    // output wire [63 : 0] m00_axis_tdata
    .m02_axis_tvalid(adc1_I_data_valid),  // output wire m00_axis_tvalid
    .m02_axis_tready(1'b1),  // input wire m00_axis_tready.m01_axis_tdata(adc0_Q_data_out),

    .m03_axis_tdata(adc1_Q_data_out),    // output wire [63 : 0] m02_axis_tdata
    .m03_axis_tvalid(adc1_Q_data_valid),  // output wire m02_axis_tvalid
    .m03_axis_tready(1'b1)  // input wire m02_axis_tready

);


endmodule
