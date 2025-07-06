`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/22 18:07:23
// Design Name: 
// Module Name: data_mux
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


module data_mux(
    input [63:0] feedback_data,
    input [7:0] feedback_data_length,
    input [63:0] ddr_data,
    input [7:0] ddr_data_length,
    input data_switch,
    input feedback_en,
    input ddr_en,
    output tx_en,
    output [63:0] data_out,
    output [7:0] data_out_length
    );

    assign data_out = data_switch?ddr_data:feedback_data;
    assign data_out_length = data_switch?ddr_data_length:feedback_data_length;
    assign tx_en = data_switch?ddr_en:feedback_en;
    
endmodule
