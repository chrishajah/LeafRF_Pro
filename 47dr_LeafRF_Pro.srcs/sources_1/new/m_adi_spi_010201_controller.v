`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/17 14:11:51
// Design Name: 
// Module Name: m_adi_spi_controller
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


module m_adi_spi_010201_controller (
//input clk
input 				clk_in,
//reset ,active low
input 				rst_n,
//
input       [15:0]  spi_clk_div_set_in,
input       [ 5:0]  spi_data_length_in,
//trig start singal
input				trig_in,
//prarall data in
input		[31:0]	data_in,
//
input               spi_sdata_in,              
output reg   		spi_cs_out,
output reg 			spi_sclk_out,
output reg 			spi_sdata_out,         
//spi read
output reg  [31:0] 	spi_rd_data_out
);

//shift reg data in
reg	[31:0] 	reg_spi_data;
//cnt0 : count the divd
reg	[15:0] 	cnt_0;
//cnt1 : count the data bit
reg	[ 5:0] 	cnt_1;
wire [31:0] RdAddr[2:0];
//count the divd 
always @(posedge clk_in )
begin
	if(!rst_n)
		cnt_0 <= 0;
	else if((spi_cs_out==0) && (cnt_0==spi_clk_div_set_in))
		cnt_0 <= 0;
	else if(spi_cs_out==0)
		cnt_0 <= cnt_0 + 1'b1;
	else
		cnt_0 <= cnt_0;  //////////////////////////////////cnt_0<=0
end
//count the data bit
always @(posedge clk_in )
begin
	if(!rst_n)
		cnt_1 <= 0;
	else if(spi_cs_out)
		cnt_1 <= 0;
	else if((spi_cs_out==0) && (spi_sclk_out==0) && (cnt_0==spi_clk_div_set_in))
		cnt_1 <= cnt_1 + 1'b1;
end
always @(posedge clk_in )
begin
	if(!rst_n)
		reg_spi_data <= 32'd0;
	else if(trig_in)
		reg_spi_data <= data_in;
	else
		reg_spi_data <= reg_spi_data;
end
//spi_cs_n_out
always @(posedge clk_in )
begin
	if(!rst_n)
		spi_cs_out <= 1;
	else if(trig_in)
		spi_cs_out <= 0;
	else if((cnt_0==spi_clk_div_set_in) && (cnt_1==spi_data_length_in))
		spi_cs_out <= 1;
end
//spi_sclk_out
always @(posedge clk_in )
begin
	if(!rst_n)
		spi_sclk_out <= 0;
	else if(spi_cs_out || ((cnt_0==spi_clk_div_set_in) && (cnt_1==spi_data_length_in)))
		spi_sclk_out <= 0;
	else if(cnt_0==spi_clk_div_set_in)
		spi_sclk_out <= ~spi_sclk_out;
    else
		spi_sclk_out <= spi_sclk_out;
end
//spi_sdata_out
always @(posedge clk_in )
begin
	if(!rst_n)
		spi_sdata_out <= 1;
	else if(spi_cs_out==0 && cnt_0 == 16'd2)
        case(cnt_1)
            5'h00   :   spi_sdata_out <= reg_spi_data[31];
            5'h01   :   spi_sdata_out <= reg_spi_data[30];
            5'h02   :   spi_sdata_out <= reg_spi_data[29];
            5'h03   :   spi_sdata_out <= reg_spi_data[28];
            5'h04   :   spi_sdata_out <= reg_spi_data[27];
            5'h05   :   spi_sdata_out <= reg_spi_data[26];
            5'h06   :   spi_sdata_out <= reg_spi_data[25];
            5'h07   :   spi_sdata_out <= reg_spi_data[24];
            5'h08   :   spi_sdata_out <= reg_spi_data[23];
            5'h09   :   spi_sdata_out <= reg_spi_data[22];
            5'h0A   :   spi_sdata_out <= reg_spi_data[21];
            5'h0B   :   spi_sdata_out <= reg_spi_data[20];
            5'h0C   :   spi_sdata_out <= reg_spi_data[19];
            5'h0D   :   spi_sdata_out <= reg_spi_data[18];
            5'h0E   :   spi_sdata_out <= reg_spi_data[17];
            5'h0F   :   spi_sdata_out <= reg_spi_data[16];
            5'h10   :   spi_sdata_out <= reg_spi_data[15];
            5'h11   :   spi_sdata_out <= reg_spi_data[14];
            5'h12   :   spi_sdata_out <= reg_spi_data[13];
            5'h13   :   spi_sdata_out <= reg_spi_data[12];
            5'h14   :   spi_sdata_out <= reg_spi_data[11];
            5'h15   :   spi_sdata_out <= reg_spi_data[10];
            5'h16   :   spi_sdata_out <= reg_spi_data[9];
            5'h17   :   spi_sdata_out <= reg_spi_data[8];
            5'h18   :   spi_sdata_out <= reg_spi_data[7];
            5'h19   :   spi_sdata_out <= reg_spi_data[6];
            5'h1A   :   spi_sdata_out <= reg_spi_data[5];
            5'h1B   :   spi_sdata_out <= reg_spi_data[4];
            5'h1C   :   spi_sdata_out <= reg_spi_data[3];
            5'h1D   :   spi_sdata_out <= reg_spi_data[2];
            5'h1E   :   spi_sdata_out <= reg_spi_data[1];
            5'h1F   :   spi_sdata_out <= reg_spi_data[0];
            
       
            default :   spi_sdata_out <= spi_sdata_out;
        endcase
    else
        spi_sdata_out <= spi_sdata_out;
end
//reg_spi_rd_data
always @(posedge clk_in )
begin
	if(!rst_n)
		spi_rd_data_out <= 32'h0000_0000;
	else if(spi_cs_out==0)
        case(cnt_1)
            5'h00   :  if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[31] <= spi_sdata_in;
                        else
                            spi_rd_data_out[31] <= spi_rd_data_out[31];
            5'h01   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[30] <= spi_sdata_in;
                        else
                            spi_rd_data_out[30] <= spi_rd_data_out[30];
            5'h02   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[29] <= spi_sdata_in;
                        else
                            spi_rd_data_out[29] <= spi_rd_data_out[29];
            5'h03   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[28] <= spi_sdata_in;
                        else
                            spi_rd_data_out[28] <= spi_rd_data_out[28];
            5'h04   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[27] <= spi_sdata_in;
                        else
                            spi_rd_data_out[27] <= spi_rd_data_out[27];
            5'h05   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[26] <= spi_sdata_in;
                        else
                            spi_rd_data_out[26] <= spi_rd_data_out[26];
            5'h06   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[25] <= spi_sdata_in;
                        else
                            spi_rd_data_out[25] <= spi_rd_data_out[25];
            5'h07   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[24] <= spi_sdata_in;
                        else
                            spi_rd_data_out[24] <= spi_rd_data_out[24];
            5'h08   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[23] <= spi_sdata_in;
                        else
                            spi_rd_data_out[23] <= spi_rd_data_out[23];
            5'h09   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[22] <= spi_sdata_in;
                        else
                            spi_rd_data_out[22] <= spi_rd_data_out[22];
            5'h0A   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[21] <= spi_sdata_in;
                        else
                            spi_rd_data_out[21] <= spi_rd_data_out[21];
            5'h0B   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[20] <= spi_sdata_in;
                        else
                            spi_rd_data_out[20] <= spi_rd_data_out[20];
            5'h0C   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[19] <= spi_sdata_in;
                        else
                            spi_rd_data_out[19] <= spi_rd_data_out[19];
            5'h0D   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[18] <= spi_sdata_in;
                        else
                            spi_rd_data_out[18] <= spi_rd_data_out[18];
            5'h0E   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[17] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[17] <= spi_rd_data_out[17];
            5'h0F   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[16] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[16] <= spi_rd_data_out[16];
            5'h10   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[15] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[15] <= spi_rd_data_out[15];
            5'h11   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[14] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[14] <= spi_rd_data_out[14];
            5'h12   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[13] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[13] <= spi_rd_data_out[13];
            5'h13   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[12] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[12] <= spi_rd_data_out[12];
            5'h14   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[11] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[11] <= spi_rd_data_out[11];
            5'h15   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[10] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[10] <= spi_rd_data_out[10];
            5'h16   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[9] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[9] <= spi_rd_data_out[9];
            5'h17   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[8] <= spi_sdata_in;
                        else
                            spi_rd_data_out[8] <= spi_rd_data_out[8];
           5'h18   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[7] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[7] <= spi_rd_data_out[7];
            5'h19   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[6] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[6] <= spi_rd_data_out[6];
            5'h1A   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[5] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[5] <= spi_rd_data_out[5];
            5'h1B   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[4] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[4] <= spi_rd_data_out[4];
            5'h1C   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[3] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[3] <= spi_rd_data_out[3];
            5'h1D   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[2] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[2] <= spi_rd_data_out[2];
            5'h1E   :   if(spi_sclk_out && cnt_0==1)               
                            spi_rd_data_out[1] <= spi_sdata_in;   
                        else                                       
                            spi_rd_data_out[1] <= spi_rd_data_out[1];
            5'h1F   :   if(spi_sclk_out && cnt_0==1)   
                            spi_rd_data_out[0] <= spi_sdata_in;
                        else
                            spi_rd_data_out[0] <= spi_rd_data_out[0];                
                                               
                            
            default :   spi_rd_data_out <= spi_sdata_out;
        endcase
    else
        spi_rd_data_out <= spi_rd_data_out;
end
endmodule