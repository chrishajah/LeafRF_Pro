`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/16 09:25:03
// Design Name: 
// Module Name: fr_gen
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


module fr_gen(
    input clk,
    input rst,
    input transmit_flag,
    input [15:0] pulse_num_reg,
    input [15:0] pulse_repeat_reg,
    input [15:0] pulse_width_reg,
    output  [14:0]  rd_start_addr,
    output  [14:0]  rd_end_addr,
    
    output fr_n
    );

    reg fr;

    reg[1:0] state;
    reg[15:0] pulse_inter_cnt,pulse_num_cnt;
    reg[15:0] pulse_num_latch;
    reg[15:0] pulse_width_latch;
    reg[24:0] pulse_repeat_latch;
    reg[9:0] pull_up_cnt;

    mult_cnt u_mult_cnt(
        .CLK(clk),
        .A(pulse_repeat_reg),
        .P(pulse_repeat_mult)
    );


    always@(posedge clk or posedge rst)begin
        if(rst)begin
            fr <= 1'd0;
            state <= 2'd0;
        end else begin
            case(state)
            0:begin
                fr <= 1'd0;
                pulse_inter_cnt <= 16'd0; 
                pulse_num_cnt <= 16'd0;
                pull_up_cnt <= 10'd0;
                if(transmit_flag)begin
                    pulse_num_latch <= pulse_num_reg;
                    pulse_width_latch <= pulse_width_reg;
                    pulse_repeat_latch <= pulse_repeat_mult;//1us
                    state <= 1;
                end else begin
                    state <= 0;
                end
            end
            1:begin
                pull_up_cnt <= 10'd0;
                if(pulse_num_cnt < pulse_num_latch) begin
                    pulse_num_cnt <= pulse_num_cnt + 1;
                    fr <= 1'd1;
                    state <= 2;
                end else begin
                    state <= 0;
                end
            end
            2:begin
                if(pulse_inter_cnt < pulse_repeat_latch) begin
                    pulse_inter_cnt <= pulse_inter_cnt + 1;
                    pull_up_cnt <= pull_up_cnt + 1;
                    if(pull_up_cnt >= 10'd149) begin //拉高0.5us
                        fr <= 1'd0;
                    end
                end else begin
                    pulse_inter_cnt <= 16'd0;
                    state <= 1;
                end
            end
            default:begin
                state <= 0;
            end
            endcase
        end
    end

    assign fr_n = ~fr;

endmodule
