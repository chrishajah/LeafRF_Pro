`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/09 15:20:33
// Design Name: 
// Module Name: dac_ram
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


module dac_ram(
    input           rst,
    input           clk_in,
    input   [63:0]  udp_data,
    input           udp_valid,
    input   [14:0]  rd_start_addr,
    input   [14:0]  rd_end_addr,
    output [127:0]  dac_data,
    output          dac_valid,
    output reg      ram_full,
    input           clk_out,
    input           out_trig,
    output reg  [3:0] state_rd
);


//    parameter WR_ADDR_BEGIN = 16'd0;
//    parameter WR_ADDR_MAX   = 16'd65535;
//    parameter RD_ADDR_BEGIN = 15'd0;
//    parameter RD_ADDR_MAX   = 15'd32767;

//WIRE & REGS

reg [3:0] state_wr;
localparam WR_IDLE     = 4'b0001;   //空闲状态
localparam WRITE       = 4'b0010;   //
localparam WREND       = 4'b0100;   //
localparam FULL        = 4'b1000;   //

//reg [3:0] state_rd;
localparam RD_IDLE     = 4'b0001;   //空闲状态
localparam READ_PRE    = 4'b0010;   //
localparam READ        = 4'b0100;   //
localparam RDEND       = 4'b1000;   //

reg [15:0] addr_wr;        //写指针
reg [14:0] addr_rd;        //读指针
reg [14:0] addr_wr_latch,addr_wr_latch_delay_reg;        //写指针
wire [14:0]  addr_wr_latch_delay;
wire [127:0] rd_fifo_in;
wire         prog_full,empty;          
//assign addr_wr_wire = addr_wr;
//assign addr_rd_wire = addr_rd;

reg  [31:0]     cnt_wr_wait;
wire             wr_en;
reg rd_en,enb;       
reg out_trig_1;
always@(posedge clk_in)begin
    if (rst) begin
        state_wr <= WR_IDLE;
        addr_wr <= 16'd0;
        ram_full <= 1'b0;
    end else begin
        case(state_wr)
            WR_IDLE:begin
                addr_wr <= 16'd0;
                ram_full <= 1'b0;
                if(udp_valid == 1'b1)begin
                    state_wr <= WRITE;
                    addr_wr <= addr_wr + 1;
                end else begin
                    state_wr <= WR_IDLE;
                end
            end
            WRITE:begin
                if(addr_wr < 16'd65535 && udp_valid == 1'b1) begin
                    addr_wr <= addr_wr + 1;
                    cnt_wr_wait <= 32'd0;
                end
                else begin
                    if(addr_wr == 16'd65535) begin
                        state_wr <= FULL;
                    end else begin
                        cnt_wr_wait <= cnt_wr_wait + 1;
                        if(cnt_wr_wait == 32'd156_250_000) begin
                            state_wr <= WREND;
                            addr_wr_latch <= ((addr_wr + 'd1) >> 1) - 'd1 ;
                        end
                    end
                    
                end
            end
            WREND:begin
                state_wr <= WREND;
            end
            FULL:begin
                state_wr <= FULL;
                ram_full <= 1'b1;
            end
            default:begin
                state_wr <= WR_IDLE;
            end
        endcase
    end
end

always @(posedge clk_out) begin
    out_trig_1 <= out_trig;
end

assign addr_wr_latch_delay = addr_wr_latch_delay_reg;

pipe_delay #(
	.DATA_WIDTH(15),		// DATA_WIDTH = 1,2...
	.DELAY_CLKS(2)		// DELAY_CLKS = 0,1,...
) u_delay_addr (
    .rst(1'b0), 			// input wire rst;    
    .clk(clk_in), 			// input wire clk;    
    .clk_en(1'b1), 	// input wire clk_en;
    .din(addr_wr_latch), 			// input wire [DATA_WIDTH-1:0] din;
    .dout(addr_wr_latch_delay)			// output wire [DATA_WIDTH-1:0] dout;
    );


pipe_delay #(
	.DATA_WIDTH(1),		// DATA_WIDTH = 1,2...
	.DELAY_CLKS(1)		// DELAY_CLKS = 0,1,...
) u_delay_valid (
    .rst(1'b0), 			// input wire rst;    
    .clk(clk_out), 			// input wire clk;    
    .clk_en(1'b1), 	// input wire clk_en;
    .din(enb), 			// input wire [DATA_WIDTH-1:0] din;
    .dout(dac_valid)			// output wire [DATA_WIDTH-1:0] dout;
    );


reg [14:0] rd_end_addr_latch;

always @(posedge clk_out) begin
    if (rst) begin
        state_rd <= RD_IDLE;
        addr_rd <= 15'd0;
        enb <= 1'b0;
    end else begin
        case(state_rd)
            RD_IDLE:begin
                addr_rd <= 15'd0;
                if(out_trig && ~out_trig_1) begin
                    addr_rd <= rd_start_addr;
                    rd_end_addr_latch <= rd_end_addr;
                    state_rd <= READ_PRE;
                    enb <= 1'b1;
                end
            end
            READ_PRE:begin
                if(addr_rd < rd_end_addr_latch - 'd1) begin
                    addr_rd <= addr_rd + 'd1;
                end else begin
                    if(out_trig && ~out_trig_1) begin
                        addr_rd <= rd_start_addr;
                        rd_end_addr_latch <= rd_end_addr;
                        state_rd <= READ_PRE;
                        enb <= 1'b1;
                    end else begin
                        state_rd <= RD_IDLE;
                        enb <= 1'b0;
                    end
                end
            end
            READ:begin
                state_rd <= RD_IDLE;
            end
            RDEND:begin
                state_rd <= RD_IDLE;
            end
            default:begin
                state_rd <= RD_IDLE;
            end
        endcase
    end
end


blk_mem_dac u_blk_mem (
    .clka(clk_in),    // input wire clka
    .ena(udp_valid),
    .wea(1'b1),      // input wire [0 : 0] wea
    .addra(addr_wr),  // input wire [15 : 0] addra
    .dina(udp_data),    // input wire [63 : 0] dina  
    .clkb(clk_out),    // input wire clkb
    .enb(enb),
    .addrb(addr_rd),    // input wire [14 : 0] addrb
    .doutb(blk_mem_out)  // output wire [127 : 0] doutb
);

wire   [127:0]  blk_mem_out;
wire [31:0] cnt_wr_wait_wr;
assign cnt_wr_wait_wr = cnt_wr_wait;
assign dac_data = (dac_valid==1'b1) ? {blk_mem_out[63:0],blk_mem_out[127:64]} : 128'd0 ;

ila_6 u_ila_ramin (
	.clk(clk_in), // input wire clk
	.probe0(udp_data), // input wire [63:0]  probe0  
	.probe1(udp_valid), // input wire [0:0]  probe1 
	.probe2(ram_full), // input wire [0:0]  probe2 
	.probe3('d0), // input wire [0:0]  probe3 
	.probe4('d0), // input wire [0:0]  probe4 
	.probe5(cnt_wr_wait_wr), // input wire [31:0]  probe5 
	.probe6(addr_wr), // input wire [15:0]  probe6 
	.probe7(15'd0), // input wire [14:0]  probe7
    .probe8(state_wr),
    .probe9(128'd0)
);

ila_6 u_ila_ramout (
	.clk(clk_out), // input wire clk
	.probe0('d0), // input wire [63:0]  probe0  
	.probe1('d0), // input wire [0:0]  probe1 
	.probe2('d0), // input wire [0:0]  probe2 
	.probe3(dac_valid), // input wire [0:0]  probe3 
	.probe4('d0), // input wire [0:0]  probe4 
	.probe5('d0), // input wire [31:0]  probe5 
	.probe6('d0), // input wire [15:0]  probe6 
	.probe7(addr_rd), // input wire [14:0]  probe7
    .probe8(state_rd),
    .probe9(dac_data)
);



endmodule
