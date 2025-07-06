`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/04/2018 12:01:48 PM
// Design Name: 
// Module Name: diff_single_g
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


module diff_single_g(
clk_in_p,
clk_in_n,
clk);

input clk_in_p;
input clk_in_n;
output clk;

wire clk_ibuf_s;

IBUFGDS
	#(
	.DIFF_TERM("TRUE"),
	.IBUF_LOW_PWR("TRUE"),
	.IOSTANDARD ("LVDS_18"))
		i_rx_clk_ibuf(
		.I(clk_in_p),
		.IB(clk_in_n),
		.O (clk_ibuf_s));
		
BUFG i_clk_gbuf (
.I(clk_ibuf_s),
.O(clk));

endmodule
