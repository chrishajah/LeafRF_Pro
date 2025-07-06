`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/09 15:16:59
// Design Name: 
// Module Name: cmd_mgmt
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


module cmd_mgmt(
    input wire clk,
    input wire [31:0] cmd_word,
    input wire transmit_done,
    input cmd_en,
    output reg transmit_flag,
    output reg [63:0] feedback_data,
    output reg [7:0]  feedback_data_length,
    output reg feedback_en,
    output reg [7:0]  state,
    output reg [7:0]  wave_read_slot,
    output reg [7:0]  wave_send_slot,
    output reg [31:0]  cmd_word_reg,
    output reg [15:0]  func_mode_reg,
    output reg [15:0]  pulse_width_reg,
    output reg [15:0]  pulse_repeat_reg,
    output reg [15:0]  pulse_num_reg
    );

    reg [3:0] send_cnt;
    //reg [31:0] cmd_word_reg;
    reg [31:0] cmd_word_prev;
    reg [7:0] length_cnt;
    reg [7:0] pack_cnt;
    reg fifo_prev;
    reg [27:0] cnt_1s;
    reg start_count_1s;

    always@(posedge clk) begin
        fifo_prev <= transmit_done;
    end

    always@(posedge clk) begin
        if(!(fifo_prev) && transmit_done)begin
            start_count_1s <= 1'b1;
        end else begin
            transmit_flag <= 1'b0;
            start_count_1s <= 1'b0;
        end
        if(start_count_1s) begin
            cnt_1s <= cnt_1s + 1'b1;
            if(cnt_1s >= 28'd156250000) begin
                transmit_flag <= 1'b1;
                start_count_1s <= 1'b0;
            end else begin
                cnt_1s <= 28'd0;
            end
        end
    end




    always @(posedge clk) begin
        cmd_word_prev <= cmd_word;  // 寄存前值
        case (state)
            0: begin
                feedback_data <= 64'h0;
                feedback_data_length <= 8'h0;
                feedback_en <= 1'b0;
                wave_read_slot <= 8'h0;
                wave_send_slot <= 8'h0;
                // 修改判断条件为检测上升沿变化
                if((cmd_word_prev == 32'hFFFFFFFF) && (cmd_word != 32'hFFFFFFFF)) begin
                    cmd_word_reg <= cmd_word;
                    state <= 1;
                end
            end
            1: begin
                // DEBUG测试字段
                if(cmd_word_reg == 32'h00000001) begin
                    feedback_en <= 1'b1;
                    feedback_data <= 64'hFFFFFFFFFFFFFFFF;
                    feedback_data_length <= 8'h1;
                    state <= 2; 
                end else
                if(cmd_word_reg == 32'h00000002) begin
                    feedback_en <= 1'b1;
                    feedback_data <= 64'h11223344AABBCCDD;
                    feedback_data_length <= 8'h80;
                    length_cnt <= 8'h80;
                    pack_cnt <= 8'd255;
                    state <= 2;
                end else
                // 控制字段——模式切换 wave_read 模式  wave_read_slot[7:0] 代表单个接收通道的标号  如wave_read_slot = 00000010 代表接收通道1的信号 wave_read_slot = 00000001 代表接收通道0的信号
                if(cmd_word_reg[31:4] == 28'h1100110) begin
                    
                    case (cmd_word_reg[3:0])
                        0: begin
                            wave_read_slot <= 8'b00000001;
                        end
                        1: begin
                            wave_read_slot <= 8'b00000010;
                        end
                        2: begin
                            wave_read_slot <= 8'b00000100;
                        end
                        3: begin
                            wave_read_slot <= 8'b00001000;
                        end
                        4: begin
                            wave_read_slot <= 8'b00010000;
                        end
                        5: begin
                            wave_read_slot <= 8'b00100000;
                        end
                        6: begin
                            wave_read_slot <= 8'b01000000;
                        end
                        7: begin
                            wave_read_slot <= 8'b10000000;
                        end
                        default: begin
                            wave_read_slot <= 8'b00000000;
                        end
                    endcase
                    feedback_en <= 1'b1;
                    feedback_data <= {32'h06040604,cmd_word_reg};
                    feedback_data_length <= 8'h1;
                    state <= 2; 
                end else
                // 控制字段——模式切换 wave_send 模式 wave_send_slot 代表多个接收通道
                if(cmd_word_reg[31:8] == 24'h220022) begin
                    wave_send_slot <= cmd_word_reg[7:0];
                    feedback_en <= 1'b1;
                    feedback_data <= {32'h06040604,cmd_word_reg};
                    feedback_data_length <= 8'h1;
                    state <= 2; 
                end else
                // 控制字段——参数设置
                // 3300 查询
                if(cmd_word_reg[31:0] == 32'h33000000) begin
                    feedback_en <= 1'b1;
                    feedback_data <= {func_mode_reg,pulse_width_reg,pulse_repeat_reg,pulse_num_reg};
                    feedback_data_length <= 8'h1;
                    state <= 2; 
                end else
                // 3301 模式更改
                if(cmd_word_reg[31:16] == 16'h3301) begin
                    func_mode_reg <= cmd_word_reg[15:0];
                    feedback_en <= 1'b1;
                    feedback_data <= {cmd_word_reg[15:0],pulse_width_reg,pulse_repeat_reg,pulse_num_reg};
                    feedback_data_length <= 8'h1;
                    state <= 2; 
                end else
                // 3302 脉宽更改
                if(cmd_word_reg[31:16] == 16'h3302) begin
                    pulse_width_reg <= cmd_word_reg[15:0];
                    feedback_en <= 1'b1;
                    feedback_data <= {func_mode_reg,cmd_word_reg[15:0],pulse_repeat_reg,pulse_num_reg};
                    feedback_data_length <= 8'h1;
                    state <= 2; 
                end else
                // 3303 重复周期更改
                if(cmd_word_reg[31:16] == 16'h3303) begin
                    pulse_repeat_reg <= cmd_word_reg[15:0];
                    feedback_en <= 1'b1;
                    feedback_data <= {func_mode_reg,pulse_width_reg,cmd_word_reg[15:0],pulse_num_reg};
                    feedback_data_length <= 8'h1;
                    state <= 2; 
                end else
                // 3304 脉冲数更改
                if(cmd_word_reg[31:16] == 16'h3304) begin
                    pulse_num_reg <= cmd_word_reg[15:0];
                    feedback_en <= 1'b1;
                    feedback_data <= {func_mode_reg,pulse_width_reg,pulse_repeat_reg,cmd_word_reg[15:0]};
                    feedback_data_length <= 8'h1;
                    state <= 2; 
                end else begin
                    state <= 0;
                end
            end
            2: begin
                send_cnt <= 3'd6;
                //回送1个frame数据的情况
                if(cmd_word_reg == 32'h00000001 || cmd_word_reg[31:4] == 28'h1100110 || cmd_word_reg[31:8] == 24'h220022 || cmd_word_reg[31:20] == 12'h330) begin
                    state <= 3;
                end else begin
                    //回送多个frame数据的情况
                    if(cmd_word_reg == 32'h00000002) begin
                        state <= 4;
                    end 
                end
            end
            3: begin
                feedback_en <= 1'b0;
                if(send_cnt) begin
                    send_cnt <= send_cnt - 1;
                end else begin
                    state <= 0;
                end
            end
            4: begin
                feedback_en <= 1'b0;
                if(send_cnt) begin
                    send_cnt <= send_cnt - 1;
                end else begin
                    state <= 5;
                end
            end
            5: begin
                if(length_cnt) begin
                    length_cnt <= length_cnt - 1;
                end else begin
                    state <= 6;
                end
            end
            6: begin
                length_cnt <= 8'h80;
                if(pack_cnt) begin
                    feedback_en <= 1'b1;
                    pack_cnt <= pack_cnt - 8'd1;
                    state <= 2;
                end else begin
                    pack_cnt <= 8'd255;
                    state <= 0;
                end
            end
        endcase
    end
endmodule
