`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/17 14:03:34
// Design Name: 
// Module Name: m_fmcboard_302
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


module m_RFSoC_010201(
input				clk_in                  ,
//reset ,active low
input				rst_n                   ,
//LMX2594 spi cfg
output  wire         LMX010201_cs, 
output  wire         LMX010201_sclk, 
output  wire         LMX010201_sdata,
output  wire         LMX010201_cfg_end
    );
reg     [ 7:0]  cnt_0           ;
wire         LMX01020_cfg_end;
reg            trig_LMX010201     ;
reg            LMX010201_cs_t   ;
reg            LMX010201_sclk_t  ;
reg            LMX010201_sdata_t  ;
reg     [ 7:0]     cnt_1    ;


always @(posedge clk_in)   
begin
	if(!rst_n)
		cnt_0 <= 8'd0;
	else if(cnt_0 == 8'hFF)
		cnt_0 <= cnt_0;
    else
        cnt_0 <= cnt_0 + 1'b1;
end

//trig_ad9516
always @(posedge clk_in)
begin
	if(!rst_n)
		trig_LMX010201 <= 1'd0;
	else if(cnt_0 == 8'h80)           // cnt_0=128
		trig_LMX010201 <= 1'd1;
    else
        trig_LMX010201 <= 1'd0;
end

always @(posedge clk_in)
begin
  LMX010201_cs_t <=    LMX010201_cs;
  LMX010201_sclk_t <=  LMX010201_sclk;
  LMX010201_sdata_t <= LMX010201_sdata;
end

m_010201_controller i_m_010201_controller(
//input clk
	.clk_in				        (clk_in			        ),
//reset ,active low         
	.rst_n            	        (rst_n	                ),
//trig start singal         
	.trig_in			        (trig_LMX010201	        ),
//spi_control           
    .LMX2594_cs_out              (LMX010201_cs            ),
    .LMX2594_sclk_out            (LMX010201_sclk            ),
    .LMX2594_sdata_out           (LMX010201_sdata           ),
//constant          
    .LMX2594_refsel_out          (),
    .LMX2594_pdwn_out            (),
    .LMX2594_rstn_out            (),
//serial data out           
    .LMX2594_syn_n_out           (),
    .LMX2594_cfg_end_out         (LMX010201_cfg_end         )
//
);
wire vio_trig;
endmodule