`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/06 10:35:02
// Design Name: 
// Module Name: ddr4_fifo_ctrl
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


module ddr4_fifo_ctrl(
    input  rst_n,
    //读写fifo信号
    input  wr_clk,      //写fifo写数据
    input  rd_clk,      //读fifo读数据
    input  ui_clk,      //MIG IP核时钟，也是读fifo写时钟和写fifo读时钟
    input  wr_fifo_wren,
    input  wr_fifo_rden,
    input  rd_fifo_wren,    
    
    input  [255:0]  wr_data,     //写fifo数据
    input  [255:0] rd_fifo_din,//读fifo的输入数据
    output [255:0] wr_fifo_dout,//转时钟域后wrfifo的输出
    output [9:0]   wfifo_rcount,
    output [9:0]   rfifo_wcount,
    
    output [63:0]  data_out,     //读fifo数据(转位宽后)
    output         wr_fifo_full,                  //写fifo满信号
    output         wr_fifo_empty,                 //写fifo空信号
    output         rd_fifo_full,                  //读fifo满信号
    output         rd_fifo_empty,                 //读fifo空信号
    output         prog_full,                     //读fifo半满信号
    input         rd_en,
    output        rdfifo_data_valid
    );
    
    
    
    wire          wrfifo_data_valid;              //数据有效信号
    //wire          rdfifo_data_valid;              //数据有效信号
    
    
    wrfifo1 wr_fifo1_inst (
      .rst(~rst_n),                      // input wire rst
      .wr_clk(wr_clk),                // input wire wr_clk
      .rd_clk(ui_clk),                // input wire rd_clk
      .din(wr_data),                      // input wire [255 : 0] din
      .wr_en(wr_fifo_wren),                  // input wire wr_en
      .rd_en(wr_fifo_rden),                  // input wire rd_en
      .dout(wr_fifo_dout),                    // output wire [255 : 0] dout
      .full(wr_fifo_full),                    // output wire full
      .empty(wr_fifo_empty),                  // output wire empty
      .valid(wrfifo_data_valid),                  // output wire valid
      .rd_data_count(wfifo_rcount),  // output wire [9 : 0] rd_data_count
      .wr_rst_busy(),      // output wire wr_rst_busy
      .rd_rst_busy()      // output wire rd_rst_busy
    );
    
    wire [63:0] data_out_o; //读fifo数据(转位宽后)
    
    rfifo1 rd_fifo_1_inst (
      .rst(~rst_n),                      // input wire rst
      .wr_clk(ui_clk),                // input wire wr_clk
      .rd_clk(rd_clk),                // input wire rd_clk
      .din(rd_fifo_din),                      // input wire [255 : 0] din
      .wr_en(rd_fifo_wren),                  // input wire wr_en
      .rd_en(rd_en),                  // input wire rd_en
      .dout(data_out_o),                    // output wire [63 : 0] dout
      .full(rd_fifo_full),                    // output wire full
      .empty(rd_fifo_empty),                  // output wire empty
      .valid(rdfifo_data_valid),                  // output wire valid
      .wr_data_count(rfifo_wcount),  // output wire [9 : 0] wr_data_count
      .prog_full(prog_full),                // output wire prog_full
      .wr_rst_busy(),      // output wire wr_rst_busy
      .rd_rst_busy()      // output wire rd_rst_busy
    );
    
    
    
    assign data_out = (rd_fifo_empty)? 63'd0:data_out_o;


    ila_3 ila_rd (
        .clk(rd_clk), // input wire clk
    
    
        .probe0(data_out), // input wire [63:0]  probe0  
        .probe1(rdfifo_data_valid), // input wire [0:0]  probe1 
        .probe2(rd_fifo_wren), // input wire [0:0]  probe2
        .probe3(data_out_o), // input wire [63:0]  probe3 
        .probe4(rd_fifo_empty) // input wire [0:0]  probe4 
        
    );
    endmodule
