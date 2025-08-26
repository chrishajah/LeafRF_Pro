`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/08 18:58:37
// Design Name: 
// Module Name: ethernet_top
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

module ethernet_top(
    //clk
	input				    clk_50m,
	input				    rst_1s_50mhz, 
	input				    GTYREFCLK_P,
	input				    GTYREFCLK_N,
    // PHY GTY Serial I/O 
	input				    RXP,
	input				    RXN,
	output				    TXP,
	output				    TXN,

    //INSIDE I/O
    input				    clk_in,
    input                   mux_sw,
	input	[63:0]		    data_in,
    input   [7:0]           data_in_length,
    input                   tx_en,
    output				    clk_out,
	output	[63:0]	        data_out,
	output				    data_out_valid,	 
    output  [31:0]          cmd_word
    );


parameter       P_MIN_LENGTH = 8'd64    ;
parameter       P_MAX_LENGTH = 15'd9600;
    
wire gt_rxp_in_0        =    RXP                               ;
wire gt_rxn_in_0        =    RXN                               ;
wire gt_txp_out_0      =    TXP                                ;
wire gt_txn_out_0      =    TXN                                ;
wire rx_core_clk_0                                             ;
wire [2 : 0] txoutclksel_in_0                                  ;
wire [2 : 0] rxoutclksel_in_0                                  ;
wire gtwiz_reset_tx_datapath_0                                 ;
wire gtwiz_reset_rx_datapath_0                                 ;
wire rxrecclkout_0                                            ;
wire sys_reset                                                 ;
wire dclk                                                      ;
wire tx_clk_out_0                                             ;
wire rx_clk_out_0                                             ;
wire tx_mii_clk_0;
wire gt_refclk_p     =     GTYREFCLK_P                        ;
wire gt_refclk_n     =     GTYREFCLK_N                        ;
wire gt_refclk_out                                            ;
wire gtpowergood_out_0                                        ;
wire rx_reset_0                                               ;
wire user_rx_reset_0                                          ;
wire rx_axis_tvalid_0                                         ;
wire [63 : 0] rx_axis_tdata_0                                 ;
wire rx_axis_tlast_0                                          ;
wire [7 : 0] rx_axis_tkeep_0                                  ;
wire rx_axis_tuser_0                                          ;
wire ctl_rx_enable_0                                           ;
wire ctl_rx_check_preamble_0                                   ;
wire ctl_rx_check_sfd_0                                        ;
wire ctl_rx_force_resync_0                                     ;
wire ctl_rx_delete_fcs_0                                       ;
wire ctl_rx_ignore_fcs_0                                       ;
wire [14 : 0] ctl_rx_max_packet_len_0                          ;
wire [7 : 0] ctl_rx_min_packet_len_0                           ;
wire ctl_rx_process_lfi_0                                      ;
wire ctl_rx_test_pattern_0                                     ;
wire ctl_rx_data_pattern_select_0                              ;
wire ctl_rx_test_pattern_enable_0                              ;
wire ctl_rx_custom_preamble_enable_0                           ;
wire ctl_rx_prbs31_test_pattern_enable_0;
wire ctl_tx_prbs31_test_pattern_enable_0;
wire stat_rx_framing_err_0                                    ;
wire stat_rx_framing_err_valid_0                              ;
wire stat_rx_local_fault_0                                    ;
wire stat_rx_block_lock_0                                     ;
wire stat_rx_valid_ctrl_code_0                                ;
wire stat_rx_status_0                                         ;
wire stat_rx_remote_fault_0                                   ;
wire [1 : 0] stat_rx_bad_fcs_0                                ;
wire [1 : 0] stat_rx_stomped_fcs_0                            ;
wire stat_rx_truncated_0                                      ;
wire stat_rx_internal_local_fault_0                           ;
wire stat_rx_received_local_fault_0                           ;
wire stat_rx_hi_ber_0                                         ;
wire stat_rx_got_signal_os_0                                  ;
wire stat_rx_test_pattern_mismatch_0                          ;
wire [3 : 0] stat_rx_total_bytes_0                            ;
wire [1 : 0] stat_rx_total_packets_0                          ;
wire [13 : 0] stat_rx_total_good_bytes_0                      ;
wire stat_rx_total_good_packets_0                             ;
wire stat_rx_packet_bad_fcs_0                                 ;
wire stat_rx_packet_64_bytes_0                                ;
wire stat_rx_packet_65_127_bytes_0                            ;
wire stat_rx_packet_128_255_bytes_0                           ;
wire stat_rx_packet_256_511_bytes_0                           ;
wire stat_rx_packet_512_1023_bytes_0                          ;
wire stat_rx_packet_1024_1518_bytes_0                         ;
wire stat_rx_packet_1519_1522_bytes_0                         ;
wire stat_rx_packet_1523_1548_bytes_0                         ;
wire stat_rx_packet_1549_2047_bytes_0                         ;
wire stat_rx_packet_2048_4095_bytes_0                         ;
wire stat_rx_packet_4096_8191_bytes_0                         ;
wire stat_rx_packet_8192_9215_bytes_0                         ;
wire stat_rx_packet_small_0                                   ;
wire stat_rx_packet_large_0                                   ;
wire stat_rx_unicast_0                                        ;
wire stat_rx_multicast_0                                      ;
wire stat_rx_broadcast_0                                      ;
wire stat_rx_oversize_0                                       ;
wire stat_rx_toolong_0                                        ;
wire stat_rx_undersize_0                                      ;
wire stat_rx_fragment_0                                       ;
wire stat_rx_vlan_0                                           ;
wire stat_rx_inrangeerr_0                                     ;
wire stat_rx_jabber_0                                         ;
wire stat_rx_bad_code_0                                       ;
wire stat_rx_bad_sfd_0                                        ;
wire stat_rx_bad_preamble_0                                   ;
wire tx_reset_0                                                ;
wire user_tx_reset_0                                          ;
wire tx_axis_tready_0                                         ;
wire tx_axis_tvalid_0                                          ;
wire [63 : 0] tx_axis_tdata_0                                  ;
wire tx_axis_tlast_0                                           ;
wire [7 : 0] tx_axis_tkeep_0                                   ;
wire tx_axis_tuser_0                                           ;
wire tx_unfout_0                                              ;
wire [55 : 0] tx_preamblein_0                                  ;
wire [55 : 0] rx_preambleout_0                                ;
wire stat_tx_local_fault_0                                    ;
wire [3 : 0] stat_tx_total_bytes_0                            ;
wire stat_tx_total_packets_0                                  ;
wire [13 : 0] stat_tx_total_good_bytes_0                      ;
wire stat_tx_total_good_packets_0                             ;
wire stat_tx_bad_fcs_0                                        ;
wire stat_tx_packet_64_bytes_0                                ;
wire stat_tx_packet_65_127_bytes_0                            ;
wire stat_tx_packet_128_255_bytes_0                           ;
wire stat_tx_packet_256_511_bytes_0                           ;
wire stat_tx_packet_512_1023_bytes_0                          ;
wire stat_tx_packet_1024_1518_bytes_0                         ;
wire stat_tx_packet_1519_1522_bytes_0                         ;
wire stat_tx_packet_1523_1548_bytes_0                         ;
wire stat_tx_packet_1549_2047_bytes_0                         ;
wire stat_tx_packet_2048_4095_bytes_0                         ;
wire stat_tx_packet_4096_8191_bytes_0                         ;
wire stat_tx_packet_8192_9215_bytes_0                         ;
wire stat_tx_packet_small_0                                   ;
wire stat_tx_packet_large_0                                   ;
wire stat_tx_unicast_0                                        ;
wire stat_tx_multicast_0                                      ;
wire stat_tx_broadcast_0                                      ;
wire stat_tx_vlan_0                                           ;
wire stat_tx_frame_error_0                                    ;
wire ctl_tx_enable_0                                           ;
wire ctl_tx_send_rfi_0                                         ;
wire ctl_tx_send_lfi_0                                         ;
wire ctl_tx_send_idle_0                                        ;
wire ctl_tx_fcs_ins_enable_0                                   ;
wire ctl_tx_ignore_fcs_0                                       ;
wire ctl_tx_test_pattern_0                                     ;
wire ctl_tx_test_pattern_enable_0                              ;
wire ctl_tx_test_pattern_select_0                              ;
wire ctl_tx_data_pattern_select_0                              ;
wire [57 : 0] ctl_tx_test_pattern_seed_a_0                     ;
wire [57 : 0] ctl_tx_test_pattern_seed_b_0                     ;
wire [3 : 0] ctl_tx_ipg_value_0                                ;
wire ctl_tx_custom_preamble_enable_0                           ;
wire [2 : 0] gt_loopback_in_0                                  ;
wire qpllreset_in_0                                            ;
wire stat_rx_bad_code_valid_0               ;     
wire [7 : 0] stat_rx_error_0                ;     
wire stat_rx_error_valid_0                  ;     
wire stat_rx_fifo_error_0                   ;     

wire [63 : 0] rx_mii_d_0,tx_mii_d_0;
wire [7:0] rx_mii_c_0,tx_mii_c_0;


xxv_ethernet_0 u_ethernet_PCSPMA (
  .gt_rxp_in_0(gt_rxp_in_0),                                                  // input wire gt_rxp_in_0
  .gt_rxn_in_0(gt_rxn_in_0),                                                  // input wire gt_rxn_in_0
  .gt_txp_out_0(gt_txp_out_0),                                                // output wire gt_txp_out_0
  .gt_txn_out_0(gt_txn_out_0),                                                // output wire gt_txn_out_0

  .rx_core_clk_0(rx_core_clk_0),                                              // input wire rx_core_clk_0
  .txoutclksel_in_0(txoutclksel_in_0),                                        // input wire [2 : 0] txoutclksel_in_0
  .rxoutclksel_in_0(rxoutclksel_in_0),                                        // input wire [2 : 0] rxoutclksel_in_0
  .gtwiz_reset_tx_datapath_0(gtwiz_reset_tx_datapath_0),                      // input wire gtwiz_reset_tx_datapath_0
  .gtwiz_reset_rx_datapath_0(gtwiz_reset_rx_datapath_0),                      // input wire gtwiz_reset_rx_datapath_0
  .rxrecclkout_0(rxrecclkout_0),                                              // output wire rxrecclkout_0

  .sys_reset(sys_reset),                                                      // input wire sys_reset
  .dclk(dclk),                                                                // input wire dclk
  .tx_mii_clk_0(tx_mii_clk_0),                                                // output wire tx_mii_clk_0
  .rx_clk_out_0(rx_clk_out_0),                                                // output wire rx_clk_out_0

  .gt_refclk_p(gt_refclk_p),                                                  // input wire gt_refclk_p
  .gt_refclk_n(gt_refclk_n),                                                  // input wire gt_refclk_n
  .gt_refclk_out(gt_refclk_out),                                              // output wire gt_refclk_out
  .gtpowergood_out_0(gtpowergood_out_0),                                      // output wire gtpowergood_out_0

  .rx_reset_0(rx_reset_0),                                                    // input wire rx_reset_0
  .user_rx_reset_0(user_rx_reset_0),                                          // output wire user_rx_reset_0

  .rx_mii_d_0(rx_mii_d_0),                                                    // output wire [63 : 0] rx_mii_d_0
  .rx_mii_c_0(rx_mii_c_0),                                                    // output wire [7 : 0] rx_mii_c_0  

  .ctl_rx_test_pattern_0(ctl_rx_test_pattern_0),                              // input wire ctl_rx_test_pattern_0
  .ctl_rx_data_pattern_select_0(ctl_rx_data_pattern_select_0),                // input wire ctl_rx_data_pattern_select_0
  .ctl_rx_test_pattern_enable_0(ctl_rx_test_pattern_enable_0),                // input wire ctl_rx_test_pattern_enable_0
  .ctl_rx_prbs31_test_pattern_enable_0(ctl_rx_prbs31_test_pattern_enable_0),  // input wire ctl_rx_prbs31_test_pattern_enable_0

  .stat_rx_framing_err_0(stat_rx_framing_err_0),                              // output wire stat_rx_framing_err_0
  .stat_rx_framing_err_valid_0(stat_rx_framing_err_valid_0),                  // output wire stat_rx_framing_err_valid_0
  .stat_rx_local_fault_0(stat_rx_local_fault_0),                              // output wire stat_rx_local_fault_0
  .stat_rx_block_lock_0(stat_rx_block_lock_0),                                // output wire stat_rx_block_lock_0
  .stat_rx_valid_ctrl_code_0(stat_rx_valid_ctrl_code_0),                      // output wire stat_rx_valid_ctrl_code_0
  .stat_rx_status_0(stat_rx_status_0),                                        // output wire stat_rx_status_0
  .stat_rx_hi_ber_0(stat_rx_hi_ber_0),                                        // output wire stat_rx_hi_ber_0
  .stat_rx_bad_code_0(stat_rx_bad_code_0),                                    // output wire stat_rx_bad_code_0
  .stat_rx_bad_code_valid_0(stat_rx_bad_code_valid_0),                        // output wire stat_rx_bad_code_valid_0
  .stat_rx_error_0(stat_rx_error_0),                                          // output wire [7 : 0] stat_rx_error_0
  .stat_rx_error_valid_0(stat_rx_error_valid_0),                              // output wire stat_rx_error_valid_0
  .stat_rx_fifo_error_0(stat_rx_fifo_error_0),                                // output wire stat_rx_fifo_error_0

  .tx_reset_0(tx_reset_0),                                                    // input wire tx_reset_0
  .user_tx_reset_0(user_tx_reset_0),                                          // output wire user_tx_reset_0

  .tx_mii_d_0(tx_mii_d_0),                                                    // input wire [63 : 0] tx_mii_d_0
  .tx_mii_c_0(tx_mii_c_0),                                                    // input wire [7 : 0] tx_mii_c_0

  .stat_tx_local_fault_0(stat_tx_local_fault_0),                              // output wire stat_tx_local_fault_0
  .ctl_tx_test_pattern_0(ctl_tx_test_pattern_0),                              // input wire ctl_tx_test_pattern_0
  .ctl_tx_test_pattern_enable_0(ctl_tx_test_pattern_enable_0),                // input wire ctl_tx_test_pattern_enable_0
  .ctl_tx_test_pattern_select_0(ctl_tx_test_pattern_select_0),                // input wire ctl_tx_test_pattern_select_0
  .ctl_tx_data_pattern_select_0(ctl_tx_data_pattern_select_0),                // input wire ctl_tx_data_pattern_select_0
  .ctl_tx_test_pattern_seed_a_0(ctl_tx_test_pattern_seed_a_0),                // input wire [57 : 0] ctl_tx_test_pattern_seed_a_0
  .ctl_tx_test_pattern_seed_b_0(ctl_tx_test_pattern_seed_b_0),                // input wire [57 : 0] ctl_tx_test_pattern_seed_b_0
  .ctl_tx_prbs31_test_pattern_enable_0(ctl_tx_prbs31_test_pattern_enable_0),  // input wire ctl_tx_prbs31_test_pattern_enable_0
  .gt_loopback_in_0(gt_loopback_in_0),                                        // input wire [2 : 0] gt_loopback_in_0
  .qpllreset_in_0(qpllreset_in_0)                                            // input wire qpllreset_in_0
);


wire    [7:0] rx_data_valid;

wire    [63:0]  rx_data;
wire rx_good_frame;
wire rx_bad_frame;
wire [63:0]    tx_data,filtered_data;
wire [7:0]     tx_valid,filtered_valid;
wire tx_start;




oc_mac u_mac(
    .res_n(1'b1),
    .clk(rx_core_clk_0),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_data_valid(tx_valid),
    .xgmii_rxd(rx_mii_d_0),
    .xgmii_rxc(rx_mii_c_0),
    .tx_ack(tx_ack),
    .rx_data(rx_data),
    .rx_bad_frame(rx_bad_frame),
    .rx_good_frame(rx_good_frame),
    .rx_data_valid(rx_data_valid),
    .xgmii_txc(tx_mii_c_0),
    .xgmii_txd(tx_mii_d_0)
);

udp_filter u_udp_ftr(
    // 时钟与复位
    .clk(rx_core_clk_0),            // input          
    .res_n(1'b1),                   // input
    
    // MAC 接收接口
    .rx_data(rx_data),          // input wire [63:0]
    .rx_data_valid(rx_data_valid), // input wire [7:0]
    .rx_good_frame(rx_good_frame), // input wire
    .rx_bad_frame(rx_bad_frame), // input wire
    
    // 过滤后数据接口
    .filtered_data(filtered_data),  // output reg [63:0]
    .filtered_valid(filtered_valid), // output reg

    // 命令字输出
    .cmd_word(cmd_word)         // output reg [31:0]
);


udp_frame_gen u_udpframegen(
    .clk(rx_core_clk_0),
    .en(tx_en),
    .mux_sw(mux_sw),
    .data_in(data_in),
    .data_in_length(data_in_length),
    .tx_data(tx_data),
    .tx_start(tx_start),
    .tx_data_valid(tx_valid)
);




/*======================= sfp0 =========================*/
/*----ctrl rx----*/ 
assign ctl_rx_enable_0                  = 1'b1          ;
assign ctl_rx_check_preamble_0          = 1'b1          ;
assign ctl_rx_check_sfd_0               = 1'b1          ;
assign ctl_rx_force_resync_0            = 1'b0          ;
assign ctl_rx_delete_fcs_0              = 1'b1          ;
assign ctl_rx_ignore_fcs_0              = 1'b0          ;
assign ctl_rx_max_packet_len_0          = P_MAX_LENGTH  ;
assign ctl_rx_min_packet_len_0          = P_MIN_LENGTH  ;
assign ctl_rx_process_lfi_0             = 1'b0          ;
assign ctl_rx_test_pattern_0            = 1'b0          ;
assign ctl_rx_test_pattern_enable_0     = 1'b0          ;
assign ctl_rx_prbs31_test_pattern_enable_0 = 1'b0;
assign ctl_rx_data_pattern_select_0     = 1'b0          ;
assign ctl_rx_custom_preamble_enable_0  = 1'b0          ;
/*----tx single----*/
assign tx_preamblein_0                  = 55'h55_55_55_55_55_55_55;
assign tx_reset_0                       = 1'b0          ;
assign ctl_tx_enable_0                  = 1'b1          ;
assign ctl_tx_send_rfi_0                = 1'b0          ;
assign ctl_tx_send_lfi_0                = 1'b0          ;
assign ctl_tx_send_idle_0               = 1'b0          ;
assign ctl_tx_fcs_ins_enable_0          = 1'b1          ;
assign ctl_tx_ignore_fcs_0              = 1'b0          ;
assign ctl_tx_test_pattern_0            = 'd0           ;
assign ctl_tx_test_pattern_enable_0     = 'd0           ;
assign ctl_tx_test_pattern_select_0     = 'd0           ;
assign ctl_tx_data_pattern_select_0     = 'd0           ;
assign ctl_tx_test_pattern_seed_a_0     = 'd0           ;
assign ctl_tx_test_pattern_seed_b_0     = 'd0           ;
assign ctl_tx_ipg_value_0               = 4'd12         ;
assign ctl_tx_custom_preamble_enable_0  = 1'b0          ;
assign ctl_tx_prbs31_test_pattern_enable_0 = 1'b0;

assign gt_loopback_in_0 = 3'b0;
assign txoutclksel_in_0 = 3'b101;    // this value should not be changed as per gtwizard 
assign rxoutclksel_in_0 = 3'b101;    // this value should not be changed as per gtwizard
assign qpllreset_in_0 = 1'b0;         // Changing qpllreset_in_0 value may impact or disturb other cores in case of multicore
// User should take care of this while changing.  
assign gtwiz_reset_tx_datapath_0 = 1'b0; 
assign gtwiz_reset_rx_datapath_0 = 1'b0; 

assign rx_reset_0 = 0;
assign tx_clk_out_0 = tx_mii_clk_0;
assign rx_core_clk_0 = tx_clk_out_0;
assign sys_reset = rst_1s_50mhz;
assign dclk = clk_50m;
//IO
assign data_out = filtered_data;
assign data_out_valid = filtered_valid;
assign clk_out = tx_mii_clk_0;

assign tx_axis_tdata_0 = 'b0;
assign tx_axis_tvalid_0 = 'b0;
assign tx_axis_tuser_0 = 'b0;
assign tx_axis_tkeep_0 = 'b0;
assign tx_axis_tlast_0 = 'b0;





//-----------------------------ILAS-------------------------------//
ila_0 ila_QSFP_fiber_1x (
	.clk		( tx_clk_out_0		), // input wire clk
	.probe0 	( {stat_rx_framing_err_0,stat_rx_framing_err_valid_0,stat_rx_error_valid_0,stat_rx_local_fault_0}), // input wire [3:0]  probe0  
	.probe1 	( 3'b0	), // input wire [2:0]  probe1 
	.probe2 	( stat_tx_local_fault_0		), // input wire [0:0]  probe2 
	.probe3 	( stat_rx_fifo_error_0			), // input wire [0:0]  probe3
	.probe4 	( stat_rx_status_0), // input wire [0:0]  probe4
	.probe5 	( tx_mii_d_0), // input wire [63:0]  probe5
	.probe6 	(gtpowergood_out_0), // input wire [0:0]  probe6
	.probe7 	( tx_mii_c_0), // input wire [7:0]  probe7
	.probe8 	( stat_rx_block_lock_0), // input wire [0:0]  probe8
	.probe9 	( 'b0), // input wire [0:0]  probe9
	.probe10	( rx_mii_d_0), // input wire [63:0]  probe10
	.probe11 	( 'b0), // input wire [0:0]  probe11
	.probe12 	( rx_mii_c_0), // input wire [7:0]  probe12
	.probe13 	( 'b0) // input wire [0:0]  probe13
);


ila_1 ila_oc_mac (
	.clk(rx_core_clk_0), // input wire clk
	.probe0(rx_bad_frame), // input wire [0:0]  probe0  
	.probe1(rx_data), // input wire [63:0]  probe1 
	.probe2(rx_data_valid), // input wire [7:0]  probe2 
	.probe3(rx_good_frame), // input wire [0:0]  probe3 
	.probe4(tx_ack), // input wire [0:0]  probe4 
	.probe5(tx_mii_c_0), // input wire [7:0]  probe5 
	.probe6(tx_mii_d_0) // input wire [63:0]  probe6
);

ila_1 ila_udp (
	.clk(rx_core_clk_0), // input wire clk
	.probe0(rx_bad_frame), // input wire [0:0]  probe0  
	.probe1({cmd_word,32'd0}), // input wire [63:0]  probe1 
	.probe2(rx_data_valid), // input wire [7:0]  probe2 
	.probe3(rx_good_frame), // input wire [0:0]  probe3 
	.probe4(filtered_valid), // input wire [0:0]  probe4 
	.probe5(8'd0), // input wire [7:0]  probe5 
	.probe6(filtered_data) // input wire [63:0]  probe6
);



endmodule
