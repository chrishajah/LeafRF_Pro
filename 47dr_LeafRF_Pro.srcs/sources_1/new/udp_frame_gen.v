module udp_frame_gen (
    input wire clk,
    input wire [63:0] data_in,
    input wire [7:0] data_in_length,
    input wire en,
    output reg [63:0] tx_data,
    output reg tx_start,
    output reg [7:0] tx_data_valid
);
    localparam ETH_TYPE   = 16'h0800; // IPv4
    localparam IP_HEADER  = {8'h45, 8'h00, 16'd0, 16'h99AF, 16'h0000, 8'h80, 8'h11, 16'h0000};
    localparam IP_SRC     = 32'hC0A80503; // 192.168.5.3
    localparam IP_DEST    = 32'hC0A80502; // 192.168.5.2
    localparam UDP_PORT   = 16'h1F90; // 8080

    reg [3:0] state;
    reg [7:0] count;
    reg [15:0] udp_length;
    reg [15:0] total_length;
    reg [15:0] ip_checksum;
    reg en_prev;  // 新增边沿检测寄存器
    

    initial begin
        state <= 1'b0;
        tx_start <= 1'b0;
        ip_checksum <= 16'h0;
    end


    always @(posedge clk) begin
        en_prev <= en;  // 每个时钟存储en信号前值
        
        case (state)
            0: begin
                tx_data <= 64'h0000000000000000;
                tx_data_valid <= 8'h00;
                
                // 修改为仅检测上升沿
                if(en && !en_prev) begin  // 当en从0变1时触发
                    tx_start <= 1'b1;
                    state <= 1;
                end
            end
            1: begin
                state <= 2;
            end
            2: begin
                //tx_start <= 1'b1;
                //tx_data  <= 64'h1A4B24A4947E1122;
                tx_data  <= 64'h22117E94A4244B1A;
                tx_data_valid <= 8'hFF;
                state <= 3;
            end
            3: begin
                //tx_data  <= 64'h3344556608004500;
                tx_data  <= 64'h0045000866554433;
                state <= 4;
                total_length <= 16'd20 + 16'd8 + 16'd6 + (16'd8 * data_in_length); // IP Header + UDP Header + Data Header + Data
                
            end
            4: begin
                //tx_data <= {total_length, 16'h0001, 16'h0000 , 16'h8011}; 15:0
                tx_data <= {16'h1180,16'h0000,16'h0100,total_length[7:0],total_length[15:8]};
                ip_checksum = calc_ip_checksum(
                    16'h4500,
                    total_length,
                    16'h0001,
                    16'h0000,
                    16'h8011,
                    IP_SRC[31:16], IP_SRC[15:0],
                    IP_DEST[31:16], IP_DEST[15:0],
                    16'h0000  // checksum field set to 0 during calculation
                );
                state <= 5;
            end
            5: begin
                //tx_data <= {16'h0000, IP_SRC ,IP_DEST[31:16]};
                tx_data <= {IP_DEST[23:16],IP_DEST[31:24],IP_SRC[7:0],IP_SRC[15:8],IP_SRC[23:16],IP_SRC[31:24],ip_checksum[7:0],ip_checksum[15:8]};
                udp_length <= 16'd8 + 16'd6 + (16'd8 * data_in_length); // UDP Header + Data
                state <= 6;
                count <= 0;
            end
            6: begin
                //tx_data <= {IP_DEST[15:0],32'h1F901F90,udp_length};
                tx_data <= {udp_length[7:0],udp_length[15:8],32'h901F901F,IP_DEST[7:0],IP_DEST[15:8]};
                state <= 7;
            end
            7: begin
                //tx_data <= {16'h0000,48'h060406040604};
                tx_data <= {64'h0406040604060000};
                state <= 8;
            end
            8: begin
                if (count < data_in_length) begin
                    tx_data <= {data_in[7:0],   data_in[15:8],
					data_in[23:16], data_in[31:24],
					data_in[39:32], data_in[47:40],
					data_in[55:48], data_in[63:56]};
                    count <= count + 1;
                end else begin
                    tx_start <= 1'b0;
                    tx_data_valid <= 8'h00;
                    state <= 0;
                end
            end
        endcase
    end

ila_2 u_ila_frame(
    .clk(clk),
    .probe0(state),
    .probe1(tx_data),
    .probe2(data_in),
    .probe3(tx_data_valid),
    .probe4(tx_start)
);


function [15:0] calc_ip_checksum;
    input [15:0] a0, a1, a2, a3, a4, a5, a6, a7, a8, a9;
    reg [17:0] sum;  // 17 bits to hold carry
begin
    sum = a0 + a1;
    sum = (sum[16] ? sum[15:0] + 1 : sum[15:0]) + a2;
    sum = (sum[16] ? sum[15:0] + 1 : sum[15:0]) + a3;
    sum = (sum[16] ? sum[15:0] + 1 : sum[15:0]) + a4;
    sum = (sum[16] ? sum[15:0] + 1 : sum[15:0]) + a5;
    sum = (sum[16] ? sum[15:0] + 1 : sum[15:0]) + a6;
    sum = (sum[16] ? sum[15:0] + 1 : sum[15:0]) + a7;
    sum = (sum[16] ? sum[15:0] + 1 : sum[15:0]) + a8;
    sum = (sum[16] ? sum[15:0] + 1 : sum[15:0]) + a9;
    sum = (sum[16] ? sum[15:0] + 1 : sum[15:0]); // final carry

    calc_ip_checksum = ~sum[15:0];
end
endfunction



endmodule
