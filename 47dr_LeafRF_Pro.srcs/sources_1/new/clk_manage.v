`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/05 10:44:21
// Design Name: 
// Module Name: clk_manage
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

/*
LMK01020ISQ -> DACLK_1204 -> BANK 65 SYSREF_FPGA(configured by SPI)
DSC1103CE2 300M OSC OTETGLVTNF -> BANK65 AL16 AJ17 (LVDS)
*/


//example of inst
/*
clk_manage your_instance_name (
    // 300MHz差分时钟输入
    .OSC_300M_P(OSC_300M_P),    // input
    .OSC_300M_N(OSC_300M_N),    // input
    
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

*/

module clk_manage(
    //input             SYSREF_FPGA_P,
    //input             SYSREF_FPGA_N,
    input               clk_sys,
    input               global_rst,
    output              clk_50M,
    output              clk_100M,
    output              clk_150M,
    output              clk_300M,
    output              osc_locked,
    output	reg			rst_0p1s_50mhz,
	output	reg			rst_0p5s_50mhz,
	output	reg			rst_1s_50mhz
    );

//wire & regs
reg [27:0] cnt_rst_time;

clk_wiz u_clk_wiz
(
    // Clock out ports
    .clk_out_50M(clk_50M),     // output clk_out_50M
    .clk_out_100M(clk_100M),     // output clk_out2
    .clk_out_150M(clk_150M),     // output clk_out3
    .clk_out_300M(clk_300M),     // output clk_out4
    // Status and control signals
    .reset(1'b0), // input reset
    .locked(osc_locked),       // output locked
   // Clock in ports
    .clk_in1(clk_sys));    // input clk_in1_n

always@(posedge clk_50M or negedge osc_locked)   
begin
    if(osc_locked == 1'b0)
        cnt_rst_time <= 28'd0;
    else if(global_rst == 1'b1)    
        cnt_rst_time <= 28'd0;
    else if(cnt_rst_time >= 28'd50000_0000)       //10s for reset    
        cnt_rst_time <= 28'd50000_0000;
    else
        cnt_rst_time <= cnt_rst_time + 28'd1;  
end



always@(posedge clk_50M)   
begin
	if(osc_locked == 1'b0)
		rst_0p1s_50mhz <= 1'b0;
	else if(cnt_rst_time <= 28'd500_0000 -1)  //0.1s
		rst_0p1s_50mhz <= 1'b1;
	else
		rst_0p1s_50mhz <= 1'b0;	
end	


always@(posedge clk_50M)   
begin
	if(osc_locked == 1'b0)
		rst_0p5s_50mhz <= 1'b0;
	else if(cnt_rst_time <= 28'd2500_0000 -1)  //0.5s
		rst_0p5s_50mhz <= 1'b1;
	else
		rst_0p5s_50mhz <= 1'b0;	
end	


always@(posedge clk_50M)   
begin
	if(osc_locked == 1'b0)
		rst_1s_50mhz <= 1'b0;
	else if(cnt_rst_time <= 28'd5000_0000 - 1)  //1s
		rst_1s_50mhz <= 1'b1;
	else
		rst_1s_50mhz <= 1'b0;	
end	




endmodule




