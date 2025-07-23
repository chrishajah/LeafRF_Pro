`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/14 14:55:26
// Design Name: 
// Module Name: leaf_mem_ctrl
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


module leaf_mem_ctrl(
    input clk,
    input rst,
    input [15:0] pwidth,
    input [15:0] prt,
    input prt_valid,
    input [14:0] paddr,
    input paddr_valid,
    input [15:0] pnum,
    input global_trig,
    input [127:0] rddata,
    input [3:0]     state_rd,


    output reg out_trig,
    output reg [14:0] rd_start_addr,
    output reg [14:0] rd_end_addr,
    output reg rd_paddr,
    output reg rd_prt,
    output reg adc_flag
    
    );

    reg [15:0] pwidth_latch;
    wire [15:0] pwidth_delay,pnum_delay;
    reg  [3:0]  state;
    reg global_trig_1;

always @(posedge clk) begin
    global_trig_1 <= global_trig;
end


ila_memctrl u_ila_memctrl (
	.clk(clk), // input wire clk

	.probe0(pwidth), // input wire [15:0]  probe0  
	.probe1(prt), // input wire [15:0]  probe1 
	.probe2(prt_valid), // input wire [0:0]  probe2 
	.probe3(paddr), // input wire [14:0]  probe3 
	.probe4(paddr_valid), // input wire [0:0]  probe4 
	.probe5(pnum), // input wire [15:0]  probe5 
	.probe6(out_trig), // input wire [0:0]  probe6 
	.probe7(rd_start_addr), // input wire [14:0]  probe7 
	.probe8(rd_end_addr), // input wire [14:0]  probe8 
	.probe9(rd_paddr), // input wire [0:0]  probe9 
	.probe10(rd_prt), // input wire [0:0]  probe10
    .probe11(state_rd),
    .probe12(subpulse_cnt),
    .probe13(subpulse_wait_cnt),
    .probe14(prt_wait_cnt),
    .probe15(pnum_cnt),
    .probe16(rddata)
);


    localparam IDLE  = 4'b0001,
           SENDING_SUBPULSE  = 4'b0010,
           PRT_WAIT = 4'b0100,
           END_TX = 4'b1000;



    pipe_delay #(
        .DATA_WIDTH(16),		// DATA_WIDTH = 1,2...
        .DELAY_CLKS(2)		// DELAY_CLKS = 0,1,...
    ) u_delay_pwidth (
        .rst(1'b0), 			// input wire rst;    
        .clk(clk), 			// input wire clk;    
        .clk_en(1'b1), 	// input wire clk_en;
        .din(pwidth), 			// input wire [DATA_WIDTH-1:0] din;
        .dout(pwidth_delay)			// output wire [DATA_WIDTH-1:0] dout;
        );


    pipe_delay #(
        .DATA_WIDTH(16),		// DATA_WIDTH = 1,2...
        .DELAY_CLKS(2)		// DELAY_CLKS = 0,1,...
    ) u_delay_pnum (
        .rst(1'b0), 			// input wire rst;    
        .clk(clk), 			// input wire clk;    
        .clk_en(1'b1), 	// input wire clk_en;
        .din(pnum), 			// input wire [DATA_WIDTH-1:0] din;
        .dout(pnum_delay)			// output wire [DATA_WIDTH-1:0] dout;
        );
        


    reg [2:0]   subpulse_cnt;
    reg [15:0]  subpulse_wait_cnt , prt_wait_cnt , prt_latch ,pnum_latch , pnum_cnt;
    always@(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            out_trig <= 1'b0;
            rd_paddr <= 1'b0;
            rd_prt <= 1'b0;
            rd_start_addr <= 15'd0;
            rd_end_addr <= 15'd0;
            subpulse_cnt <= 3'd0;
            subpulse_wait_cnt <= 16'd0;
            prt_wait_cnt <= 16'd0;
            pnum_cnt <= 16'd0;
        end else begin
            case(state)
                IDLE:begin
                    out_trig <= 1'b0;
                    rd_start_addr <= 15'd0;
                    rd_end_addr <= 15'd0;
                    subpulse_cnt <= 3'd0;
                    subpulse_wait_cnt <= 16'd0;
                    prt_wait_cnt <= 16'd0;
                    if(global_trig & ~global_trig_1) begin
                        pwidth_latch <= pwidth_delay ;
                        pnum_latch <= pnum_delay - 'd1;
                        if(paddr_valid) begin
                            rd_start_addr <= paddr;
                            rd_end_addr <= paddr + pwidth_delay;
                            rd_paddr <= 1'b1;
                            state <= SENDING_SUBPULSE;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        state <= IDLE;
                    end
                end
                SENDING_SUBPULSE:begin
                    rd_paddr <= 1'b0;
                    if(subpulse_cnt < 'd4) begin
                        if(subpulse_wait_cnt < pwidth_latch - 'd1) begin
                            subpulse_wait_cnt <= subpulse_wait_cnt + 'd1;
                            if(subpulse_wait_cnt < 'd4)begin
                                out_trig <= 1'b1;
                            end else begin
                                out_trig <= 1'b0;
                            end
                            //if(subpulse_wait_cnt == pwidth_latch - 'd1 && (subpulse_cnt != 'd4 && subpulse_cnt != 'd3)) begin
                            //    rd_paddr <= 1'b1;
                            //end
                            state <= SENDING_SUBPULSE;
                        end else begin
                            subpulse_wait_cnt <= 'd0;
                            rd_start_addr <= paddr;
                            rd_end_addr <= paddr + pwidth_delay;
                            subpulse_cnt <= subpulse_cnt + 'd1;
                            if(subpulse_cnt != 'd4 && subpulse_cnt != 'd3) begin
                                rd_paddr <= 1'b1;
                            end
                            if (subpulse_cnt < 'd4)
                            state <= SENDING_SUBPULSE;
                        end
                    end else begin
                        subpulse_cnt <= 3'd0;
                        prt_latch <= prt;
                        rd_prt <= 1'd1;
                        state <= PRT_WAIT;
                    end
                end
                PRT_WAIT:begin
                    rd_prt <= 1'd0;
                    if (pnum_cnt < pnum_latch) begin
                        if(prt_wait_cnt <= prt_latch) begin
                        prt_wait_cnt <= prt_wait_cnt + 'd1;
                        end else begin
                            prt_wait_cnt <= 'd0;
                            pnum_cnt <= pnum_cnt + 'd1;
                            rd_start_addr <= paddr;
                            rd_end_addr <= paddr + pwidth_latch;
                            rd_paddr <= 1'b1;
                            state <= SENDING_SUBPULSE;
                        end
                    end else begin
                        pnum_cnt <= 'd0;
                        state <= END_TX;
                    end
                end
                END_TX :begin
                    state <= IDLE;
                end
                default : begin
                    state <= IDLE;
                end
            endcase
        end
    end


endmodule
