`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025年5月15日09:48:31
// Design Name: 
// Module Name: 
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


module ddr4_top(
input           c0_sys_clk_i,
//MIG IP核接口
output  [16 : 0] c0_ddr4_adr,
output  [1 : 0]  c0_ddr4_ba,
output  [0 : 0]  c0_ddr4_cke,
output  [0 : 0]  c0_ddr4_cs_n,
inout   [3 : 0]  c0_ddr4_dm_dbi_n,
inout   [31 : 0] c0_ddr4_dq,
inout   [3 : 0]  c0_ddr4_dqs_c,//
inout   [3 : 0]  c0_ddr4_dqs_t,//
output  [0 : 0]  c0_ddr4_odt,
output  [0 : 0]  c0_ddr4_bg,
output  c0_ddr4_reset_n,
output  c0_ddr4_act_n,
output  [0 : 0] c0_ddr4_ck_c,//
output  [0 : 0] c0_ddr4_ck_t, //
output  [28:0] app_addr_wr,
input               rst_n            ,  //复位信号 

//ddr3_rw模块接口    
input               wr_clk           ,  //写fifo写时钟
input               rd_clk           ,  //读fifo读时钟
input               rd_req           ,  //读数据请求使能                                                                    
input               wr_en            ,  //写数据使能信号，
input  [255:0]      wrdata           ,  //写有效数据 
output [63:0]       rddata           ,  //读有效数据 
input               rd_en            ,
output              rd_fifo_empty    ,
output              rdfifo_data_valid,
output              rd_fifo_progfull ,
output              ddr_state_trig  
);

//wire define  
wire                  app_rdy              ;   //MIG IP核空闲
wire                  app_wdf_rdy          ;   //MIG写数据空闲
wire                  app_rd_data_valid    ;   //读数据有效
wire [28:0]           app_addr             ;   //ddr3 地址
wire [2:0]            app_cmd              ;   //用户读写命令
wire                  app_en               ;   //MIG IP核使能
wire [255:0]          app_rd_data          ;   //用户读数据
wire                  app_rd_data_end      ;   //突发读当前时钟最后一个数据 
wire [255:0]          app_wdf_data         ;   //用户写数据 
wire                  app_wdf_wren         ;   //用户写使能，对接wfifo的rden信号
wire                  app_wdf_end          ;   //突发写当前时钟最后一个数据 
wire [31:0]           app_wdf_mask         ;   //写数据屏蔽                           
wire                  app_sr_active        ;   //保留                                 
wire                  app_ref_ack          ;   //刷新请求                             
wire                  app_zq_ack           ;   //ZQ 校准请求                                                
wire                  ui_clk               ;   //用户时钟                   
wire                  ui_clk_sync_rst      ;   //用户复位信号    
wire [9:0]            wfifo_rcount         ;   //wfifo写进数据计数                     
wire [9:0]            rfifo_wcount         ;   //rfifo剩余数据计数
wire                  rfifo_wren           ;   //从ddr3读出数据写进rfifo的有效使能
wire                  rd_end               ;   //读完成信号
wire                  init_calib_complete  ;   //DDR4初始化完成
wire                  wr_fifo_full         ;   //写fifo满信号
wire                  wr_fifo_empty        ;   //写fifo空信号
wire                  rd_fifo_full         ;   //读fifo满信号
//wire                  rd_fifo_empty_wr     ;   //读fifo空信号
wire                  prog_full            ;   //读fifo半满信号

assign prog_full = rd_fifo_progfull;

ddr4_rw u_ddr4_rw
(
.rst_n            (rst_n)                ,  //复位信号
.wr_clk           (wr_clk)               ,  //写fifo写时钟
.ui_clk           (ui_clk)               ,  //用户时钟
.wr_en            (wr_en)                ,  //写数据有效信号,对应wrfifo_wren
.init_calib_complete(init_calib_complete),  //DDR3初始化完成
.app_rdy          (app_rdy)              ,  //MIG IP核空闲
.app_wdf_rdy      (app_wdf_rdy)          ,  //MIG写数据空闲
.app_rd_data_valid(app_rd_data_valid)    ,  //读数据有效
.wfifo_rcount     (wfifo_rcount)         ,  //写端口FIFO中的数据量
.rfifo_wcount     (rfifo_wcount)         ,  //读端口FIFO中的数据量
.ddr_state_trig   (ddr_state_trig)       ,
.rd_req           (rd_req)               ,  //用来指示跳转到READ状态
.rd_end           (rd_end)               ,  //读完成信号
.app_en           (app_en)               ,  //MIG IP核操作使能
.app_addr         (app_addr)             ,  //DDR3地址
.app_addr_wr      (app_addr_wr)          ,
.app_wdf_wren     (app_wdf_wren)         ,  //用户写使能，对接wfifo_rden信号
.app_wdf_end      (app_wdf_end)          ,  //突发写当前时钟最后一个数据
.app_cmd          (app_cmd)              ,  //MIG IP核操作命令，读或者写
.rfifo_wren       (rfifo_wren)           ,  //从ddr3读出数据存进rfifo的有效使能
.wr_fifo_full     (wr_fifo_full)         ,  //写fifo满信号
.wr_fifo_empty    (wr_fifo_empty)        ,  //写fifo空信号
.rd_fifo_full     (rd_fifo_full)         ,  //读fifo满信号
.rd_fifo_empty    (rd_fifo_empty)     ,  //读fifo空信号
.prog_full        (prog_full)               //读fifo半满信号
);



ddr4_ip ddr4_ip_c0 (
  .c0_init_calib_complete		        ( init_calib_complete   	),	// output 初始化完成信号
  .dbg_clk						        ( 							),	// output wire dbg_clk
  .c0_sys_clk_i					        ( c0_sys_clk_i				),	// input
  .dbg_bus						        ( 							),	// output wire [511 : 0] dbg_bus
  .c0_ddr4_adr					        ( c0_ddr4_adr				    ),	// output wire [16 : 0] c0_ddr4_adr
  .c0_ddr4_ba					        ( c0_ddr4_ba				    ),	// output wire [1 : 0] c0_ddr4_ba
  .c0_ddr4_cke					        ( c0_ddr4_cke				    ),	// output wire [0 : 0] c0_ddr4_cke
  .c0_ddr4_cs_n					        ( c0_ddr4_cs_n				    ),	// output wire [0 : 0] c0_ddr4_cs_n
  .c0_ddr4_dm_dbi_n			            ( c0_ddr4_dm_dbi_n			    ),	// inout wire [3 : 0] c0_ddr4_dm_dbi_n 数据掩码物理管脚
  .c0_ddr4_dq					        ( c0_ddr4_dq				    ),	// inout wire [31 : 0] c0_ddr4_dq
  .c0_ddr4_dqs_c				        ( c0_ddr4_dqs_c				),	// inout wire [3 : 0] c0_ddr4_dqs_c
  .c0_ddr4_dqs_t				        ( c0_ddr4_dqs_t				),	// inout wire [3 : 0] c0_ddr4_dqs_t
  .c0_ddr4_odt					        ( c0_ddr4_odt				    ),	// output wire [0 : 0] c0_ddr4_odt
  .c0_ddr4_bg					        ( c0_ddr4_bg				    ),	// output wire [0 : 0] c0_ddr4_bg
  .c0_ddr4_reset_n			            ( c0_ddr4_reset_n			    ),	// output wire c0_ddr4_reset_n
  .c0_ddr4_act_n				        ( c0_ddr4_act_n				),	// output wire c0_ddr4_act_n
  .c0_ddr4_ck_c					        ( c0_ddr4_ck_c				    ),	// output wire [0 : 0] c0_ddr4_ck_c
  .c0_ddr4_ck_t					        ( c0_ddr4_ck_t				    ),	// output wire [0 : 0] c0_ddr4_ck_t
  //user interface  
  .c0_ddr4_ui_clk				        ( ui_clk			        ),	// output wire c0_ddr4_ui_clk 用户时钟  1333/3=333.25MHz
  .c0_ddr4_ui_clk_sync_rst	            ( ui_clk_sync_rst	        ),	// output wire c0_ddr4_ui_clk_sync_rst 用户复位
  .c0_ddr4_app_en				        ( app_en			        ),	// input wire c0_ddr4_app_en
  .c0_ddr4_app_hi_pri			        ( 1'b0						),	// input wire c0_ddr4_app_hi_pri
  .c0_ddr4_app_wdf_end			        ( app_wdf_end		        ),	// input wire c0_ddr4_app_wdf_end
  .c0_ddr4_app_wdf_wren			        ( app_wdf_wren		        ),	// input wire c0_ddr4_app_wdf_wren
  .c0_ddr4_app_rd_data_end		        ( app_rd_data_end	        ),	// output wire c0_ddr4_app_rd_data_end
  .c0_ddr4_app_rd_data_valid	        ( app_rd_data_valid	        ),  // output wire c0_ddr4_app_rd_data_valid
  .c0_ddr4_app_rdy				        ( app_rdy			        ),	// output wire c0_ddr4_app_rdy
  .c0_ddr4_app_wdf_rdy			        ( app_wdf_rdy		        ),	// output wire c0_ddr4_app_wdf_rdy
  .c0_ddr4_app_addr				        ( app_addr			        ),	// input wire [28 : 0] c0_ddr4_app_addr
  .c0_ddr4_app_cmd				        ( app_cmd			        ),	// input wire [2 : 0] c0_ddr4_app_cmd
  .c0_ddr4_app_wdf_data			        ( app_wdf_data		        ),	// input wire [255 : 0] c0_ddr4_app_wdf_data
  .c0_ddr4_app_wdf_mask			        ( 32'b0						),	// input wire [31 : 0] c0_ddr4_app_wdf_mask
  .c0_ddr4_app_rd_data			        ( app_rd_data		        ),	// output wire [255 : 0] c0_ddr4_app_rd_data
  .addn_ui_clkout1				        ( 					        ),	// output wire addn_ui_clkout1
  .sys_rst						        ( 1'b0						)	// input wire sys_rst
);

ddr4_fifo_ctrl u_dd4_fifo_ctrl(
.rst_n(rst_n),

.wr_clk                 (wr_clk)                ,
.rd_clk                 (rd_clk)                ,
.ui_clk                 (ui_clk)                ,
.wr_fifo_wren           (wr_en)                 ,
.wr_fifo_rden           (app_wdf_wren)          ,
.rd_fifo_wren           (rfifo_wren)            ,    
.wr_data                (wrdata)                ,//进入写fifo数据
.rd_fifo_din            (app_rd_data)           ,//读fifo的输入数据
.wr_fifo_dout           (app_wdf_data)          ,//转时钟域后wrfifo的输出
.wfifo_rcount           (wfifo_rcount)          ,
.rfifo_wcount           (rfifo_wcount)          ,
.data_out               (rddata)                , //读fifo数据(转位宽后)
.wr_fifo_full           (wr_fifo_full)          , //写fifo满信号
.wr_fifo_empty          (wr_fifo_empty)         , //写fifo空信号
.rd_fifo_full           (rd_fifo_full)          , //读fifo满信号
.rd_fifo_empty          (rd_fifo_empty)         , //读fifo空信号
.prog_full              (prog_full)             , //读fifo半满信号
.rd_en                  (rd_en)                 ,
.rdfifo_data_valid      (rdfifo_data_valid)
);


ila_00 ila_00(
	.clk(ui_clk), // input wire clk


	.probe0(app_wdf_data), // input wire [255:0]  probe0  
	.probe1(app_rd_data), // input wire [255:0]  probe1 
	.probe2(wr_fifo_empty), // input wire [0:0]  probe2 
	.probe3(rd_fifo_full), // input wire [0:0]  probe3 
	.probe4(wr_en), // input wire [0:0]  probe4 
	.probe5(app_wdf_wren), // input wire [0:0]  probe5 
	.probe6(app_en), // input wire [0:0]  probe6 
	.probe7(rd_end), // input wire [0:0]  probe7 
	.probe8(app_rd_data_valid), // input wire [0:0]  probe8 
	.probe9(app_addr), // input wire [28:0]  probe9 
	.probe10(wfifo_rcount), // input wire [9:0]  probe10 
	.probe11(rfifo_wcount), // input wire [9:0]  probe11
    .probe12(app_rdy), // input wire [0:0]  probe12 
	.probe13(app_wdf_rdy), // input wire [0:0]  probe13 
	.probe14(prog_full), // input wire [0:0]  probe14
    .probe15(rfifo_wren) // input wire [0:0]  probe15
);

endmodule
