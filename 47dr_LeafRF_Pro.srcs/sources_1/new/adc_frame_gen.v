`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/28 18:39:54
// Design Name: 
// Module Name: adc_frame_gen
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


module adc_frame_gen(
    input clk,
    input [63:0] data_in,
    input rd_fifo_empty,
    input rd_fifo_progfull,
    input [28:0] total_length,
    input rdfifo_data_valid,
    input  ddr_state_trig,
    output [63:0] frame_data,
    output reg [7:0] frame_data_length,
    output reg rd_en,
    output reg tx_en,
    output reg mux_sw,
    output reg [3:0] state,
    output reg [28:0] total_length_reg,
    output reg [28:0] total_length_cnt,
    output reg start_flag
    );


localparam IDLE  = 4'b0001,
           START_FRAMING  = 4'b0010,
           SENDING_HDR = 4'b0100,
           SENDING_DATA = 4'b1000,
           ENDING = 4'b1111;

    //reg [3:0] state;
    reg [3:0] send_cnt;
    //reg [28:0] total_length_reg;
    //reg [28:0] total_length_cnt;
    /*
        initial begin
        state = 0;          // 状态机初始状态
        send_cnt = 0;       // 计数器清零
        total_length_reg = 0;
        total_length_cnt = 0;
    end
    */

(* ASYNC_REG = "true" *) reg  ddr_state_trig_1,ddr_state_trig_2;

//对ddr state trig 进行打拍
    always@(posedge clk) begin
        ddr_state_trig_1 <= ddr_state_trig;
        ddr_state_trig_2 <= ddr_state_trig_1;
    end

    
/*
    always@(posedge clk) begin
        if((ddr_state_1 == 4'b0100) && (ddr_state == 4'b1000)) begin //ddr状态从wait 跳转到 read
            total_length_reg <= total_length >> 3;  //锁存total_length端口数据 (除以8)
        end
    end
*/
    always@(posedge clk) begin
        start_flag <= (total_length_reg >= 'd32) ? rd_fifo_progfull : ~rd_fifo_empty;
    end



    always @(posedge clk) begin
        case(state)
            IDLE: begin  //IDLE状态
                if(ddr_state_trig_2) begin //ddr状态从wait 跳转到 read
                    total_length_reg <= total_length >> 3;  //锁存total_length端口数据 (除以8)
                end
                if(start_flag) begin //起始标志代表开始一帧数据传输
                        mux_sw <= 1'b1;      //将数选器选择端口置高
                        state <= START_FRAMING;
                end else begin
                    state <= IDLE;
                end
            end
            START_FRAMING: begin  //开始组帧
                tx_en <= 1'b1;       //tx_en置高 指示eth模块开始发送udp头
                send_cnt <= 3'd7;    //打8拍计数器 参考eth_top文档
                state <= SENDING_HDR; 
            end
            SENDING_HDR: begin //发送帧头
                tx_en <= 1'b0;
                if(total_length_reg >= 'd32) begin      //若待组帧的数据总长大于1024，则发送一次1024B的数据包
                    total_length_cnt <= 'd128;
                    frame_data_length <= 8'd128; 
                end else begin
                    total_length_cnt <= total_length_reg << 2; 
                    frame_data_length <= total_length_reg << 2; 
                end
                if(send_cnt) begin
                    send_cnt <= send_cnt - 1; //实现打拍等待帧头发送
                end else begin
                    rd_en <= 1'b1;
                    state <= SENDING_DATA;
                end
            end
            SENDING_DATA: begin //发送数据包
                if(total_length_reg >= 'd32) begin  //发送1024B数据包
                    if(total_length_cnt - 'd1) begin
                            //frame_data <= data_in;
                            total_length_cnt <= total_length_cnt - 'd1;
                    end else begin
                        rd_en <= 1'b0;
                        total_length_reg <= total_length_reg - 'd32;
                        state <= IDLE; //发送完一帧1024B数据 回到状态0 继续组剩下的数据
                        mux_sw <= 1'b0;
                    end
                end else begin
                    if(total_length_cnt - 'd1) begin
                            //frame_data <= data_in;
                            total_length_cnt <= total_length_cnt - 'd1;
                    end else begin
                        rd_en <= 1'b0;
                        total_length_reg <= 'd0;
                        state <= ENDING; //发送完fifo所有数据 进入ending等待一拍
                        mux_sw <=1'b0;
                    end
                end
            end
            ENDING: begin
                state <= IDLE;
            end
            default: begin
                state <= IDLE;
                mux_sw <=1'b0;
                total_length_reg <= 'd0;
            end
        endcase
    end

assign frame_data = rd_en ? data_in : 64'hFFFFFFFFFFFFFFFF;



endmodule
