`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/18 13:37:54
// Design Name: 
// Module Name: ddr4_rw
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:zzl重新编写 2025年5月15日
// 
//////////////////////////////////////////////////////////////////////////////////


module ddr4_rw#(
    parameter WR_ADDR_BEGIN = 29'd0,
    parameter WR_ADDR_END   = 29'd536870912 - 29'd8,
    parameter RD_ADDR_BEGIN = 29'd0,
    parameter RD_ADDR_END   = 29'd800 - 29'd8
)
(

input            rst_n            ,  //复位信号
input            wr_clk           ,  //写fifo写时钟
input            ui_clk           ,  //用户时钟
input            wr_en            ,  //写数据有效信号,对应wrfifo_wren
input            init_calib_complete,  //DDR4初始化完成
input            app_rdy          ,  //MIG IP核空闲
input            app_wdf_rdy      ,  //MIG写数据空闲
input            app_rd_data_valid,  //读数据有效
input   [9:0]    wfifo_rcount     ,  //写端口FIFO中的数据量
input   [9:0]    rfifo_wcount     ,  //读端口FIFO中的数据量

input            rd_req           ,  //用来指示跳转到READ状态,即DDR读出来到读FIFO
output           wr_end           ,
output           rd_end           ,  //读完成信号
output           app_en           ,  //MIG IP核操作使能
output  [28:0]   app_addr         ,  //DDR4地址
output           app_wdf_wren     ,  //用户写使能，对接wfifo_rden信号
output           app_wdf_end      ,  //突发写当前时钟最后一个数据
output           app_cmd          ,  //MIG IP核操作命令，读或者写
output           rfifo_wren       ,  //从ddr3读出数据存进rfifo的有效使能

input         wr_fifo_full,                  //写fifo满信号
input         wr_fifo_empty,                 //写fifo空信号
input         rd_fifo_full,                  //读fifo满信号
input         rd_fifo_empty,                 //读fifo空信号
input         prog_full   ,                   //读fifo半满信号
output reg [28:0] app_addr_wr   ,      //DDR写指针
output  ddr_state_trig
);

localparam IDLE        = 4'b0001;   //空闲状态
localparam WRITE       = 4'b0010;   //写进DDR4状态,把wfifo中的数据写进DDR4
localparam WAIT        = 4'b0100;   //等待状态
localparam READ        = 4'b1000;   //读DDR4状态，从DDR读出来到读FIFO
//reg define
reg [28:0] app_addr_rd;          //DDR读指针
reg [3:0] state;

wire app_en_rd;

//读请求信号打拍
reg rd_req_sync1, rd_req_sync2;
always @(posedge ui_clk) begin
    rd_req_sync1 <= rd_req;
    rd_req_sync2 <= rd_req_sync1;
end

//定义写完成信号
reg [31:0] cnt_wr_done;
reg wr_done;




always @(posedge wr_clk or negedge rst_n) begin
    if (!rst_n)
        cnt_wr_done <= 0;
    else if (wr_en)
        cnt_wr_done <= 0;  // 有新数据，清零等待
    else if (cnt_wr_done < 32'd100000)
        cnt_wr_done <= cnt_wr_done + 1;  // wr_data_valid 长时间为0，开始计数
end

always @(posedge wr_clk or negedge rst_n) begin
    if (!rst_n)
        wr_done <= 0;
    else if (cnt_wr_done ==  32'd100000)
        wr_done <= 1;  // 超过阈值，认为写完
    else if (wr_en)
        wr_done <= 0;  // 一旦又有数据进来，重新等待
end

reg wr_done_sync1, wr_done_sync2;//写完成信号打拍
always @(posedge ui_clk) begin
    wr_done_sync1 <= wr_done;
    wr_done_sync2 <= wr_done_sync1;
end

//由于DDR读取速度快于FIFO的速度，因此有可能上游FIFO空了但是实际上并没有完全写完
reg [31:0] cnt_wr_wait;

always @(posedge ui_clk or negedge rst_n) begin
    if(~rst_n)
        cnt_wr_wait <= 0;
    else if((state == WRITE) && wr_fifo_empty && ( cnt_wr_wait < 32'd100000))
        cnt_wr_wait <= cnt_wr_wait + 1;
    else if (state == IDLE)
        cnt_wr_wait <= 0;
    else if( cnt_wr_wait == 32'd100000)
        cnt_wr_wait <= 32'd100000;
    else
        cnt_wr_wait <= cnt_wr_wait;
end

//由于DDR写进读FIFO的速度快于读FIFO读出数据的速度，因此有可能下游FIFO满了但是实际上还有数据要写进去的时候没写进去
//所以需要定义一个信号当读FIFO半满的时候停一段时间


assign rfifo_wren =  app_rd_data_valid; //将ddr4的读到数据有效信号赋给rfifo写使能
assign rd_end = (state == READ && (app_addr_rd == app_addr_wr)) ? 1'b1 : 1'b0; //读完成信号
assign app_en = (~wr_fifo_empty && app_wdf_wren || app_en_rd); //MIG IP核操作使能
assign app_cmd = (state == WRITE) ? 3'b000 : 3'b001; //MIG IP核操作命令，读0,写1
assign app_wdf_wren = ((state == WRITE) && ~wr_fifo_empty && app_wdf_rdy && app_rdy) ? 1'b1 : 1'b0; //用户写使能
assign app_wdf_end = app_wdf_wren;
assign app_addr = (state == WRITE) ? app_addr_wr : app_addr_rd; //DDR4地址
assign app_en_rd = (state == READ && app_rdy && ~prog_full) ? 1'b1 : 1'b0; //读使能信号
//对信号进行打拍
reg rd_end_r;
always @(posedge ui_clk) begin
    rd_end_r <= rd_end;
end
//修改为上升沿触发 0507-zzl

//reg wr_req_prev;

/*
vio_0 vio_0 (
  .clk(ui_clk),                // input wire clk
  .probe_out0(vio)  // output wire [0 : 0] probe_out0
);
*/
reg [3:0] state_1;

reg ddr_state_trig_0,ddr_state_trig_1,ddr_state_trig_2,ddr_state_trig_3;

always @(posedge ui_clk) begin
    ddr_state_trig_1 <= ddr_state_trig_0;
    ddr_state_trig_2 <= ddr_state_trig_1;
    ddr_state_trig_3 <= ddr_state_trig_2;
end

assign ddr_state_trig = ddr_state_trig_0 || ddr_state_trig_1 || ddr_state_trig_2 || ddr_state_trig_3;
assign wr_end = (state == READ) ? 1'b1 : 1'b0;
//ddr_state_trig = |{ddr_state_trig_0,ddr_state_trig_0,ddr_state_trig_0,ddr_state_trig_0}

always @(posedge ui_clk) begin
    state_1 <= state;
    if((state_1 == WAIT) && (state == READ))begin
        ddr_state_trig_0 <= 1'b1;
    end else begin 
        ddr_state_trig_0 <= 1'b0;
    end

end

reg [28:0] wait_cnt;


always @(posedge ui_clk) begin
    //vio_prev <= vio;
    if(!rst_n)begin
        state <= IDLE;
        app_addr_rd <= RD_ADDR_BEGIN; //读地址初始值
        app_addr_wr <= WR_ADDR_BEGIN; //写地址初始值
    end
    else begin
        case (state)
            IDLE:begin
                app_addr_rd <= RD_ADDR_BEGIN; //读地址初始值
                app_addr_wr <= WR_ADDR_BEGIN; //写地址初始值
                if(init_calib_complete &&  ~wr_fifo_empty)begin
                    state <= WRITE; //初始化完成 且 fifo非空 进入写入状态
                end
                else begin
                    state <= IDLE;
                end
            end 

            WRITE:begin
                wait_cnt <= 29'd333_250_000;
                if(wr_fifo_empty && wr_done_sync2 && (cnt_wr_wait>=100))begin
                    state <= WAIT; //写完成+写FIFO空+等待一段时间确定没有新数据进来后，跳到等待状态
                end
                else if(app_addr_wr >= WR_ADDR_END)begin
                    state <= WAIT; //写超过地址上限，跳到等待状态
                end
                else if(app_wdf_rdy && app_rdy && app_wdf_wren)begin
                    app_addr_wr <= app_addr_wr + 8; //写地址加8
                end
                else begin
                    state <= WRITE;
                    app_addr_wr <= app_addr_wr;
                end
            end
            WAIT:begin
                if(wait_cnt) begin
                    state <= WAIT;
                    wait_cnt <= wait_cnt - 'd1; //进入等待状态 等待1s
                end
                else begin
                    state <= READ; //跳到读状态
                end
            end
            READ:begin
                //if(app_addr_rd == app_addr_wr || app_addr_rd >= RD_ADDR_END)begin
                if(app_addr_rd == app_addr_wr - 8 || app_addr_rd >= WR_ADDR_END)begin
                    app_addr_rd <= 29'd0;
                    //state <= READ;
                    state <= IDLE; //读完成(读地址等于写地址)
                end
                else if(app_rdy && app_en_rd)begin
                    app_addr_rd <= app_addr_rd + 8; //读地址加8
                    state <= READ;
                end
                else begin
                    state <= READ;
                    app_addr_rd <= app_addr_rd;
                end
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end
end

ila_10 ila_10 (
	.clk(ui_clk), // input wire clk


	.probe0(state), // input wire [3:0]  probe0  
	.probe1(app_en_rd), // input wire [0:0]  probe1 
	.probe2(cnt_wr_wait), // input wire [6:0]  probe2 
	.probe3(app_addr_wr), // input wire [28:0]  probe3 
	.probe4(app_addr_rd) // input wire [28:0]  probe4
);
endmodule
