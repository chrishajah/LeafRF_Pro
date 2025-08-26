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

    input cmd_en,
    output reg [63:0] feedback_data,
    output reg [7:0]  feedback_data_length,
    output reg feedback_en,
    output reg [7:0]  state,
    output reg [31:0]  cmd_word_reg,
    output reg [15:0]  func_mode_reg,
    output reg [15:0]  pulse_width_reg,
    output reg [15:0]  pulse_repeat_reg,
    output reg [15:0]  pulse_num_reg,
    output reg [15:0]  freq_index_reg,
    output reg         rd_en,

    input         clk_out,
    input         prt_fifo_rd,
    input         freq_fifo_rd,
    output [15:0] prt_serial_out,
    output prt_serial_out_valid,
    output [15:0] addr_serial_out,
    output addr_serial_out_valid
    );

    reg [3:0] send_cnt;
    reg [31:0] cmd_word_prev;
    reg [7:0] length_cnt;
    reg [7:0] pack_cnt;





    always @(posedge clk) begin
        cmd_word_prev <= cmd_word;  // 寄存前值
        case (state)
            0: begin
                feedback_data <= 64'h0;
                feedback_data_length <= 8'h0;
                feedback_en <= 1'b0;
                rd_en <= 1'b0;
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
                // 控制字段——参数设置
                // 3300 查询
                if(cmd_word_reg[31:0] == 32'h33000000) begin
                    feedback_en <= 1'b1;
                    feedback_data <= {func_mode_reg,pulse_width_reg,pulse_repeat_reg,pulse_num_reg};
                    feedback_data_length <= 8'h1;
                    state <= 2; 
                end else
                // 3301 信号发射
                if(cmd_word_reg[31:16] == 16'h3301) begin
                    rd_en <= 1'b1;
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
                // 3303 PRT更改
                if(cmd_word_reg[31:16] == 16'h3303) begin
                    pulse_repeat_reg <= cmd_word_reg[15:0];
                    feedback_en <= 1'b1;
                    feedback_data <= {func_mode_reg,pulse_width_reg,cmd_word_reg[15:0],pulse_num_reg};
                    feedback_data_length <= 8'h1;
                    state <= 2; 
                end else
                //  3304 脉冲数更改
                if(cmd_word_reg[31:16] == 16'h3304) begin
                    pulse_num_reg <= cmd_word_reg[15:0];
                    feedback_en <= 1'b1;
                    feedback_data <= {func_mode_reg,pulse_width_reg,pulse_repeat_reg,cmd_word_reg[15:0]};
                    feedback_data_length <= 8'h1;
                    state <= 2; 
                end else
                // 3305 捷变序列设置
                if(cmd_word_reg[31:16] == 16'h3305) begin
                    freq_index_reg <= cmd_word_reg[15:0];
                    feedback_en <= 1'b1;
                    feedback_data <= {freq_index_reg,freq_index_reg,freq_index_reg,cmd_word_reg[31:16]};
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
                rd_en <= 1'b0;
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
    

reg        prt_fifo_wr_en,freq_fifo_wr_en,freq_fifo_wr_en_delay;
wire [15:0] multped_addr;


fifo_prt u_fifo_prt (
    .rst(1'b0),                  // input wire rst
    .wr_clk(clk),            // input wire wr_clk
    .rd_clk(clk_out),            // input wire rd_clk
    .din(pulse_repeat_reg),      // input wire [15 : 0] din
    .wr_en(prt_fifo_wr_en),              // input wire wr_en
    .rd_en(prt_fifo_rd),              // input wire rd_en
    .dout(prt_serial_out),                // output wire [15 : 0] dout
    .full(),                // output wire full
    .empty(),              // output wire empty
    .valid(prt_serial_out_valid),              // output wire valid
    .wr_rst_busy(),  // output wire wr_rst_busy
    .rd_rst_busy()  // output wire rd_rst_busy
);




mult_gen_0 u_multplier_addr (
  .CLK(clk),  // input wire CLK
  .A(freq_index_reg[1:0]),      // input wire [1 : 0] A
  .B(pulse_width_reg[14:0]),      // input wire [14 : 0] B
  .P(multped_addr)      // output wire [16 : 0] P
);



fifo_prt u_fifo_freq (
    .rst(1'b0),                  // input wire rst
    .wr_clk(clk),            // input wire wr_clk
    .rd_clk(clk_out),            // input wire rd_clk
    .din(multped_addr),      // input wire [15 : 0] din
    .wr_en(freq_fifo_wr_en_delay),              // input wire wr_en
    .rd_en(freq_fifo_rd),              // input wire rd_en
    .dout(addr_serial_out),                // output wire [15 : 0] dout
    .full(),                // output wire full
    .empty(),              // output wire empty
    .valid(addr_serial_out_valid),              // output wire valid
    .wr_rst_busy(),  // output wire wr_rst_busy
    .rd_rst_busy()  // output wire rd_rst_busy
);


// PRT变化序列fifo读控制
    always@(posedge clk) begin
        if(state == 1) begin
            if(cmd_word_reg[31:16] == 16'h3303) begin
                prt_fifo_wr_en <= 1'b1;
            end else begin
                prt_fifo_wr_en <= 1'b0;
            end
        end else begin
            prt_fifo_wr_en <= 1'b0;
        end
    end

// freq变化序列fifo读控制
    always@(posedge clk) begin
        if(state == 1) begin
            if(cmd_word_reg[31:16] == 16'h3305) begin
                freq_fifo_wr_en <= 1'b1;
            end else begin
                freq_fifo_wr_en <= 1'b0;
            end
        end else begin
            freq_fifo_wr_en <= 1'b0;
        end
    end


    always@(posedge clk) begin
        freq_fifo_wr_en_delay <= freq_fifo_wr_en;
    end

ila_7 ila_cmd (
	.clk(clk), // input wire clk

	.probe0(16'd0), // input wire [15:0]  probe0  
	.probe1(1'd0), // input wire [0:0]  probe1 
	.probe2(cmd_word_reg), // input wire [31:0]  probe2 
	.probe3(multped_addr), // input wire [15:0]  probe3 
	.probe4(freq_index_reg), // input wire [15:0]  probe4 
	.probe5(1'd0), // input wire [0:0]  probe5 
	.probe6(pulse_width_reg), // input wire [15:0]  probe6 
	.probe7(pulse_repeat_reg), // input wire [15:0]  probe7 
	.probe8(pulse_num_reg), // input wire [15:0]  probe8 
	.probe9(state) // input wire [7:0]  probe9
);

ila_7 ila_cmd_out (
	.clk(clk_out), // input wire clk

	.probe0(prt_serial_out), // input wire [15:0]  probe0  
	.probe1(prt_serial_out_valid), // input wire [0:0]  probe1 
	.probe2(32'd0), // input wire [31:0]  probe2 
	.probe3(16'd0), // input wire [15:0]  probe3 
	.probe4(addr_serial_out), // input wire [15:0]  probe4 
	.probe5(addr_serial_out_valid), // input wire [0:0]  probe5 
	.probe6(16'd0), // input wire [15:0]  probe6 
	.probe7(16'd0), // input wire [15:0]  probe7 
	.probe8(16'd0), // input wire [15:0]  probe8 
	.probe9(8'd0) // input wire [7:0]  probe9
);


endmodule
