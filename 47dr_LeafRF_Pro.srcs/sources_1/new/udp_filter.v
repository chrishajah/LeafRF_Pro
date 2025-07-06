module udp_filter(
    input         clk,
    input       res_n,
    // MAC接口
    input wire [63:0]   rx_data,
    input wire [7:0]    rx_data_valid,
    input wire          rx_good_frame,
    input wire          rx_bad_frame,

    output reg [63:0]   filtered_data,
    output reg          filtered_valid,
    output reg          filtered_good,
    output reg          filtered_bad,
    output reg [31:0]    cmd_word
);

// 参数配置（IP和端口采用网络字节序）
parameter [31:0] TARGET_IP = 32'hC0_A8_05_02;  // 192.168.5.2
parameter [31:0] DEST_IP = 32'hC0_A8_05_03;  // 192.168.5.3
parameter [31:0] TARGET_PORT = 32'h1F_90_1F_90;      // 8080

// 协议偏移量定义
localparam ETH_HDR_LEN = 14;     // 以太网头长度
localparam IP_HDR_LEN  = 20;     // IP头长度
localparam UDP_HDR_LEN = 8;      // UDP头长度

// 状态寄存器
reg [3:0]  parse_state;
reg [15:0] byte_counter;
reg [15:0] dst_port_reg;
reg [31:0] dest_ip_reg;
reg [15:0] dest_ip_h_reg;
reg        is_udp_packet;
reg        is_src_ip;   
reg        is_dest_ip;



reg  [15:0] data_byte_num;

wire [15:0] eth_type;        // 以太网类型（字节12-13）
wire [7:0]  ip_protocol;     // IP协议类型（字节23）
wire [31:0] src_ip;          // 源IP地址（字节26-29）
wire [31:0] udp_dst_port;    // 目标端口（字节36-37）

// 以太网类型解析（修正为第二字的字节4-5）
assign eth_type = rx_data[31:16];  // 字节 (0x0800)

// IP协议解析（第三字的字节7）
assign ip_protocol = rx_data[7:0];              // 字节23

// 源IP地址解析（第四字的字节2-5）
assign src_ip = rx_data[47:16];  // 字节26-29
// UDP目标端口解析（第五字的字节4-5）
assign udp_dst_port = {rx_data[47:16]};  // 字节36-37

always @(posedge clk or negedge res_n) begin
    if (!res_n) begin
        parse_state    <= 4'd0;
        byte_counter   <= 16'd0;
        dest_ip_h_reg <=  16'h0;
        is_udp_packet  <= 1'b0;
        is_src_ip     <= 1'b0;  
        is_dest_ip    <= 1'b0;
        filtered_valid <= 1'd0;
        filtered_good  <= 1'b0;
        filtered_bad   <= 1'b0;
        data_byte_num <=  16'h0;
        cmd_word <= 32'hFFFFFFFF;
    end else begin
        // 仅在数据有效时处理
        if (rx_data_valid == 8'hFF) begin
            case (parse_state)
                0: begin // 解析以太网头
                    filtered_valid <= 1'd0;
                    filtered_data <= 64'h0;
                    cmd_word <= 32'hFFFFFFFF;
                    if (eth_type == 16'h0800) begin
                        parse_state <= 1;
                        byte_counter <= ETH_HDR_LEN+8;
                    end else begin
                        parse_state    <= 4'd0;
                        byte_counter <= ETH_HDR_LEN;
                    end
                end
                1: begin // 解析IP头
                    if (byte_counter >= 22) begin
                        if (ip_protocol == 8'h11) begin // UDP协议
                            parse_state <= 2;
                        end
                    end else begin
                        parse_state <= 0;
                    end
                end
                2: begin // 解析来源ip
                    if (src_ip == TARGET_IP) begin
                        dest_ip_h_reg <= rx_data[15:0];
                        is_src_ip <= (src_ip == TARGET_IP);
                        parse_state = 3;
                    end else begin
                        parse_state <= 0;
                    end 
                end
                3: begin // 解析目的IP和端口号
                    is_udp_packet <= is_src_ip && ({dest_ip_h_reg,rx_data[63:48]} == DEST_IP) && (udp_dst_port == TARGET_PORT);
                    if(is_src_ip && ({dest_ip_h_reg,rx_data[63:48]} == DEST_IP) && (udp_dst_port == TARGET_PORT)) begin
                        data_byte_num <= rx_data[15:0] - 16'd14;
                        byte_counter <= 16'h00;
                        parse_state <= 4;
                    end else begin
                        parse_state <= 0;
                    end
                end
                4: begin //判断自定义帧头
                    //数据协议 输出数据
                    if(rx_data[47:0]==48'h060406040604) begin
                        parse_state <= 5;
                    end
                    if(rx_data[47:32] == 16'h0604 && rx_data[31:0] !=32'h06040604) begin
                        cmd_word <= rx_data[31:0];
                        parse_state <= 0;
                        filtered_valid <= 1'd0;
                    end
                end
                5: begin
                    if(byte_counter < data_byte_num) begin
                        filtered_valid <= 1'd1;
                        filtered_data <= rx_data;
                        byte_counter = byte_counter + 8;
                    end else begin
                        if (data_byte_num - byte_counter) begin
                            filtered_data <= rx_data;
                            byte_counter <= 16'h0;
                            parse_state <= 6;
                        end else begin
                            parse_state <= 0;
                            filtered_data <= rx_data;
                            byte_counter <= 16'h0;
                        end
                    end
                    
                end
                6: begin
                    //filtered_valid <= 1'd0;
                    parse_state <= 0;
                end
            endcase
        end
        else begin
            filtered_valid <= 1'd0;
            parse_state <= 0;
        end

        // 帧结束处理
        if (rx_good_frame || rx_bad_frame) begin
            parse_state <= 0;
            //filtered_data <= 64'h0;
            //filtered_valid <= 1'd0;
            filtered_good <= is_udp_packet & rx_good_frame;
            filtered_bad  <= is_udp_packet & rx_bad_frame;
        end
    end
end


endmodule
