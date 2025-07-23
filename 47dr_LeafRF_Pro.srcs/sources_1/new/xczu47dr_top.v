`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/05 10:41:58
// Design Name: 
// Module Name: xczu47dr_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module xczu47dr_top(
    //CLK IN
    input   OSC_300M_P,
    input   OSC_300M_N,
    input   MGT_CLK_156M25_P,
    input   MGT_CLK_156M25_N,
    input   PL_SYSREF_P,
    input   PL_SYSREF_N,
    input   PL_CLK_P,
    input   PL_CLK_N,

    //GTY PHY
    input   QSFP_RX_P,
    input   QSFP_RX_N,
    output  QSFP_TX_P,
    output  QSFP_TX_N,

    //CLOCK SPI
    output  LMX2594_cs,
    output  LMX2594_sclk,
    output  LMX2594_sdata,
    input   LMX2594_mux,
    output  LMK01020_cs,
    output  LMK01020_sclk,
    output  LMK01020_sdata,
    output  LMK010201_cs,
    output  LMK010201_sclk,
    output  LMK010201_sdata,

    //LED SIGN
    output  CLK_led,

    //RF DAC OUT
    output  RFMC_DAC0_P,
    output  RFMC_DAC0_N,
    output  RFMC_DAC1_P,
    output  RFMC_DAC1_N,
    input   DAC0_CLK_P,
    input   DAC0_CLK_N,
    input   SYSREF_N,
    input   SYSREF_P,

    //RF ADC IN
    input   ADC0_CLK_P,
    input   ADC0_CLK_N,
    input   RFMC_ADC0_P,
    input   RFMC_ADC0_N,
    input   RFMC_ADC1_P,
    input   RFMC_ADC1_N,


    //ddr
    output wire [16 : 0] c0_ddr4_adr,
    output wire [1 : 0]  c0_ddr4_ba,
    output wire [0 : 0]  c0_ddr4_cke,
    output wire [0 : 0]  c0_ddr4_cs_n,
    inout wire [3 : 0]   c0_ddr4_dm_dbi_n,
    inout wire [31 : 0]  c0_ddr4_dq,
    inout wire [3 : 0]   c0_ddr4_dqs_c,//
    inout wire [3 : 0]   c0_ddr4_dqs_t,//
    output wire [0 : 0]  c0_ddr4_odt,
    output wire [0 : 0]  c0_ddr4_bg,
    output wire c0_ddr4_reset_n,
    output wire c0_ddr4_act_n,
    output wire [0 : 0] c0_ddr4_ck_c,//
    output wire [0 : 0] c0_ddr4_ck_t //

    );

//wire & regs


wire clk_50M,clk_100M,clk_150M,clk_300M,rst_0p1s_50mhz,rst_0p5s_50mhz,rst_1s_50mhz;
wire clk_eth;
wire [31:0]       cmd_word_wr;
wire [63:0]		  feedback_data_wr;
wire [7:0]		  feedback_data_length_wr,mux_data_out_length;
wire 		      tx_en_wr,adc_eth_tx_en,mux_sw;
wire [7:0]		  state;
wire [15:0]		  pulse_num_wr;
wire [15:0]		  pulse_repeat_wr;
wire [15:0]		  pulse_width_wr;
wire [63:0] 	  udp_data_out,mux_data_out;
wire  			  udp_data_out_valid;
wire              locked;
wire [127:0] rddata; //读fifo数据(转位宽后)
wire [28:0] wr_length;
wire   ddr_state_trig;
wire rd_fifo_empty,rd_en,rdfifo_data_valid,rd_fifo_progfull;
wire clk_sys_ddr4;
wire clk_adc,clk_dac,pl_clkin;
wire [127:0]    adc0_data_out,adc1_data_out;
wire   adc0_data_valid,adc1_data_valid;
wire LMX2594_cfg_end;
wire [63:0]     adc_eth_data;
wire [7:0]      adc_eth_data_length;
//Global Clock


IBUFDS u_ibufds_osc300 (
  .I(OSC_300M_P),
  .IB(OSC_300M_N),
  .O(clk_osc300_ibuf)
);


BUFG u_ddr4_sysclk_bufg (
  .I(clk_osc300_ibuf),
  .O(clk_sys_ddr4)
);

BUFG u_sysclk_for_pl_bufg (
  .I(clk_osc300_ibuf),
  .O(clk_sys)
);

MTS_CLK u_mts_clk(
	.PL_CLK_N(PL_CLK_N),
    .PL_CLK_P(PL_CLK_P),
    .PL_SYSREF_N(PL_SYSREF_N),
    .PL_SYSREF_P(PL_SYSREF_P),
    .clk_adc(clk_adc),
    .clk_dac(clk_dac),
	.user_sysref_adc(),
	.user_sysref_dac(),
	.PL_CLK(pl_clkin)
);

clk_wiz_0 u_pl_clkwiz
(
    // Clock out ports
    .clk_out1(clk_adc),     // output clk_out1
    .clk_out2(clk_dac),     // output clk_out2
    .clk_out3(CLK_led),     // output clk_out3
   // Clock in ports
    .clk_in1(pl_clkin));      // input clk_in1


//INST




rfsoc_top u_rfsoc_top(
    .dac0_data_in(rddata),
    //.dac1_data_in(rddata),
    .dac0_data_valid(rdfifo_data_valid),
    //.dac1_data_valid(rdfifo_data_valid),
    .adc0_data_out(adc0_data_out),
    .adc0_data_valid(adc0_data_valid),
    .adc1_data_out(adc1_data_out),
    .adc1_data_valid(adc1_data_valid),
    .DAC0_CLK_N(DAC0_CLK_N),
    .DAC0_CLK_P(DAC0_CLK_P),
    .ADC0_CLK_N(ADC0_CLK_N),
    .ADC0_CLK_P(ADC0_CLK_P),
    .SYSREF_N(SYSREF_N),
    .SYSREF_P(SYSREF_P),
    .clk_100M(clk_100M),
    .clk_492M(clk_dac),


    .dac_clk(),
    .DAC0_OUT_N(RFMC_DAC0_N),
    .DAC0_OUT_P(RFMC_DAC0_P),
    .DAC1_OUT_N(RFMC_DAC1_N),
    .DAC1_OUT_P(RFMC_DAC1_P),

    .ADC0_IN_N(RFMC_ADC0_N),
    .ADC0_IN_P(RFMC_ADC0_P),
    .ADC1_IN_N(RFMC_ADC1_N),
    .ADC1_IN_P(RFMC_ADC1_P)

);



clk_manage u_clk_manage (
    // 300MHz差分时钟输入
    .clk_sys(clk_sys),    // input
    
    .osc_locked(locked),

    // 全局复位
    .global_rst(global_rst),     // input
    
    // 时钟输出
    .clk_50M(clk_50M),          // output
    .clk_100M(clk_100M),        // output
    .clk_150M(clk_150M),        // output
    .clk_300M(clk_300M),        // output
    
    // 定时复位信号
    .rst_0p1s_50mhz(rst_0p1s_50mhz),  // output reg
    .rst_0p5s_50mhz(rst_0p5s_50mhz),  // output reg
    .rst_1s_50mhz(rst_1s_50mhz)       // output reg
);

m_RFSoC_01020 u_m_RFSoC_01020(
    .clk_in(clk_100M),
    .rst_n(locked),
    .LMX01020_cs(LMK01020_cs), 
    .LMX01020_sclk(LMK01020_sclk), 
    .LMX01020_sdata(LMK01020_sdata),
    .LMX01020_cfg_end()
);

m_RFSoC_010201 u_m_RFSoC_010201(
    .clk_in(clk_100M),
    .rst_n(locked),
    .LMX010201_cs(LMK010201_cs), 
    .LMX010201_sclk(LMK010201_sclk), 
    .LMX010201_sdata(LMK010201_sdata),
    .LMX010201_cfg_end()
);



m_RFSoC_2594 u_m_RFSoC_2594(
    .clk_in(clk_100M),
    .rst_n(locked),
    .LMX2594_cs(LMX2594_cs), 
    .LMX2594_sclk(LMX2594_sclk), 
    .LMX2594_sdata(LMX2594_sdata),
    .LMX2594_cfg_end(LMX2594_cfg_end)
);



ila_4 u_ila_LMX2594(
    .clk(clk_100M),
    .probe0(locked),
    .probe1(LMX2594_cs),
    .probe2(LMX2594_sclk),
    .probe3(LMX2594_sdata),
    .probe4(LMX2594_cfg_end),
    .probe5(LMX2594_mux)
);




vio_global_rst u_vio_global_rst (
  .clk(clk_50M),                // input wire clk
  .probe_out0(global_rst)  // output wire [0 : 0] probe_out0
);


data_mux u_mux (
    .feedback_data(feedback_data_wr),
    .feedback_data_length(feedback_data_length_wr),
    .ddr_data(adc_eth_data),
    .ddr_data_length(adc_eth_data_length),
	.ddr_en(adc_eth_tx_en),
	.feedback_en(feedback_en_wr),
    .data_switch(mux_sw),
    .data_out(mux_data_out),
    .data_out_length(mux_data_out_length),
	.tx_en(tx_en_wr)
);


ethernet_top u_eth_top(
	.clk_50m				( clk_50M					),
	.rst_1s_50mhz			( rst_1s_50mhz				),
	//输入数据			
	.clk_in					( clk_150m					),
	.data_in				( mux_data_out			),
	.data_in_length		    ( mux_data_out_length   ),
	.tx_en				    ( tx_en_wr 				    ),
	//输出数据			
	.clk_out				( clk_eth					),
	.data_out				( udp_data_out				),
	.data_out_valid			( udp_data_out_valid		),	
	.cmd_word				( cmd_word_wr				),
    // GTX Reference Clock Interface		
	.GTYREFCLK_P			( MGT_CLK_156M25_P				),
	.GTYREFCLK_N			( MGT_CLK_156M25_N				),
    // GTX Serial I/O		
	.RXP					( QSFP_RX_P				),
	.RXN					( QSFP_RX_N				),
	.TXP					( QSFP_TX_P				),
	.TXN					( QSFP_TX_N				) 
    );

wire [14:0]  rd_start_addr,rd_end_addr;
wire out_trig;

dac_ram u_dac_ram(
    .rst(1'b0),
    .clk_in(clk_eth),
    .udp_data(udp_data_out),
    .udp_valid(udp_data_out_valid),
    .dac_data(rddata),
    .dac_valid(rdfifo_data_valid),
    .ram_full(),
    .rd_start_addr(rd_start_addr),
    .rd_end_addr(rd_end_addr),
    .clk_out(clk_dac),
    .state_rd(state_rd),
    .out_trig(out_trig)
    );




vio_0 u_vio_rd(
    .clk(clk_dac),
    .probe_out0(rd_en)
);

wire [63:0] frame_gen_in;
wire ddr_rdfifo_data_valid;

adc_frame_gen u_adc_frame_gen(
    .clk(clk_eth),
    .data_in(frame_gen_in),
    .rd_fifo_empty(rd_fifo_empty),
    .rd_fifo_progfull(rd_fifo_progfull),
    .total_length(),
    .rdfifo_data_valid(ddr_rdfifo_data_valid),
    .ddr_state_trig(ddr_state_trig),
    .frame_data(adc_eth_data),
    .frame_data_length(adc_eth_data_length),
    .rd_en(),
    .tx_en(adc_eth_tx_en),
    .mux_sw(mux_sw),
    .state(),
    .total_length_reg(),
    .total_length_cnt(),
    .start_flag()
    );


ddr4_top u_ddr4_top(
	.c0_sys_clk_i      (clk_sys_ddr4    ),
	//MIG IP核接口
	.c0_ddr4_adr       (c0_ddr4_adr     ),
	.c0_ddr4_ba        (c0_ddr4_ba      ),
	.c0_ddr4_cke       (c0_ddr4_cke     ),
	.c0_ddr4_cs_n      (c0_ddr4_cs_n    ),
	.c0_ddr4_dm_dbi_n  (c0_ddr4_dm_dbi_n),
	.c0_ddr4_dq        (c0_ddr4_dq      ),
	.c0_ddr4_dqs_c     (c0_ddr4_dqs_c   ),//
	.c0_ddr4_dqs_t     (c0_ddr4_dqs_t   ),//
	.c0_ddr4_odt       (c0_ddr4_odt     ),
	.c0_ddr4_bg        (c0_ddr4_bg      ),
	.c0_ddr4_reset_n   (c0_ddr4_reset_n ),
	.c0_ddr4_act_n     (c0_ddr4_act_n   ),
	.c0_ddr4_ck_c      (c0_ddr4_ck_c    ),//
	.c0_ddr4_ck_t      (c0_ddr4_ck_t    ), //
	.app_addr_wr 	   (wr_length),
	.rd_en			   (),
	.rst_n             (1'b1)  ,  //复位信号 
	.wr_clk            (clk_adc)  ,  //写fifo写时钟
	.rd_clk            (clk_eth)  ,  //读fifo读时钟
	.rd_req            ()  ,  //读数据请求使能，从rfifo里读出来                                                                    
	.wr_en             ()  ,  //写数据使能信号，表示data_gen模块的输出数据有效即写入wrfifo里
	.wrdata            ({adc0_data_out,adc1_data_out})  ,  //写有效数据 
	.rddata            (frame_gen_in),    //读有效数据 
	.rd_fifo_empty	   (rd_fifo_empty),
	.rdfifo_data_valid (ddr_rdfifo_data_valid),
	.rd_fifo_progfull  (rd_fifo_progfull),
	.ddr_state_trig    (ddr_state_trig)
);


reg [15:0]  freq_index_reg;
wire freq_fifo_rd,prt_fifo_rd;

vio_serial_rd u_vio_serial_rd (
  .clk(clk_dac),                // input wire clk
  .probe_out0(),  // output wire [0 : 0] probe_out0
  .probe_out1()  // output wire [0 : 0] probe_out1
);

wire    [15:0]  prt_serial_out,addr_serial_out;
wire    prt_serial_out_valid,addr_serial_out_valid;

cmd_mgmt u_cmd_mgmt(
    .clk(clk_eth),
    .clk_out(clk_dac),
    .cmd_word(cmd_word_wr),
	
    .feedback_data(feedback_data_wr),
    .feedback_data_length(feedback_data_length_wr),
    .feedback_en(feedback_en_wr),
	
	.pulse_width_reg(pulse_width_wr),
	.pulse_repeat_reg(pulse_repeat_wr),
	.pulse_num_reg(pulse_num_wr),
	.state(state),

    .prt_serial_out(prt_serial_out),
    .prt_serial_out_valid(prt_serial_out_valid),
    .addr_serial_out(addr_serial_out),
    .addr_serial_out_valid(addr_serial_out_valid),
    .freq_fifo_rd(freq_fifo_rd),
    .prt_fifo_rd(prt_fifo_rd),
    .freq_index_reg()
);

wire [3:0]  state_rd;
leaf_mem_ctrl u_leaf_mem_ctrl(
    .clk(clk_dac),
    .rst(1'b0),
    .pwidth(pulse_width_wr),
    .prt(prt_serial_out),
    .prt_valid(prt_serial_out_valid),
    .paddr(addr_serial_out[14:0]),
    .paddr_valid(addr_serial_out_valid),
    .pnum(pulse_num_wr),
    .global_trig(rd_en),
    .out_trig(out_trig),
    .rd_start_addr(rd_start_addr),
    .rd_end_addr(rd_end_addr),
    .rd_paddr(freq_fifo_rd),
    .rd_prt(prt_fifo_rd),
    .rddata(rddata),
    .state_rd(state_rd),
    .adc_flag()
    );








endmodule
