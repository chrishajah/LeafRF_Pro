module m_01020_controller
(
//input clk
input 					clk_in,
//reset ,active low
input 					rst_n,
//trig start singal
input					trig_in,
//spi_control
output 	 			 	LMX2594_cs_out,
output 				 	LMX2594_sclk_out,
output 	 			 	LMX2594_sdata_out,
//constant
output 	 			 	LMX2594_refsel_out,
output 	 			 	LMX2594_pdwn_out,
output 	 			 	LMX2594_rstn_out,
//serial data out
output 	 				LMX2594_syn_n_out,
output  reg				LMX2594_cfg_end_out
//
);


reg	[23: 0] cnt_0;
reg			trig_spi;
reg	[31:0]	spi_parrallel_data;

//
assign	LMX2594_refsel_out = 1'b1;
assign	LMX2594_pdwn_out   = 1'b1;
assign	LMX2594_rstn_out   = 1'b1;
assign	LMX2594_syn_n_out  = 1'b1;

//cnt_0 : statics the cnt_0 to send data
always @(posedge clk_in )
begin
	if(!rst_n)
		cnt_0 <= 24'd0;
	else if(cnt_0==24'hFF_0000)
		cnt_0 <= 24'd0;
	else if(trig_in || cnt_0>=1)
		cnt_0 <= cnt_0 + 1'd1;
	else
		cnt_0 <= 24'd0;
end
//config
always @(posedge clk_in )
begin
	if(!rst_n)
		spi_parrallel_data <= 0;
	else
		case(cnt_0)
            //LMX2594 vco initialation
          	24'h00_003F : spi_parrallel_data <=32'h80000100;              //78
			24'hF0_1000 : spi_parrallel_data <=32'h00010100;              //77     
			24'hF0_2000 : spi_parrallel_data <=32'h00010101;              //76    24'h4C000C; 
			24'hF0_3000 : spi_parrallel_data <=32'h00010102;              //4B_09_40;  //75     
			24'hF0_4000 : spi_parrallel_data <=32'h00010103;              //74   
			24'hF0_5000 : spi_parrallel_data <=32'h00010104;              //73
			24'hF0_6000 : spi_parrallel_data <=32'h00010105;              //72
			24'hF0_7000 : spi_parrallel_data <=32'h00010106;              //71
			24'hF0_8000 : spi_parrallel_data <=32'h00010107;              //70 
			24'hF0_9000 : spi_parrallel_data <=32'h00022A09;              //69
//			24'hF0_A000 : spi_parrallel_data <=24'h4403E8;              //68  
			24'hF0_A000 : spi_parrallel_data <=32'h6800000E;              //0       00_24_9C 
			default: spi_parrallel_data <= spi_parrallel_data;
		endcase
end          
//trig_spi : correspond to spi_parrallel_data
always @(posedge clk_in )
begin
	if(!rst_n)
		trig_spi <= 0;
	else
		case(cnt_0)				
			24'h00_003F : trig_spi <= 1;
			24'hF0_1000 : trig_spi <= 1;
			24'hF0_2000 : trig_spi <= 1;
			24'hF0_3000 : trig_spi <= 1;
			24'hF0_4000 : trig_spi <= 1;
			24'hF0_5000 : trig_spi <= 1;
			24'hF0_6000 : trig_spi <= 1;
			24'hF0_7000 : trig_spi <= 1;
			24'hF0_8000 : trig_spi <= 1;
			24'hF0_9000 : trig_spi <= 1;
			24'hF0_A000 : trig_spi <= 1;
//			24'hF0_B000 : trig_spi <= 1;
   
			default     : trig_spi <= 0;
		endcase
end 

//cnt_0 : statics the cnt_0 to send data
always @(posedge clk_in )
begin
	if(!rst_n)
		LMX2594_cfg_end_out <= 1'd0;
	else if(trig_in)
        LMX2594_cfg_end_out <= 1'd0;
	else if(cnt_0==24'hFA_00_10)
		LMX2594_cfg_end_out <= 1'd1;
	else
		LMX2594_cfg_end_out <= LMX2594_cfg_end_out;
end
//    
m_adi_spi_010201_controller i_m_adi_spi_controller (
//input clk
	.clk_in			        (clk_in					),
	.rst_n     			    (rst_n					),	
//
    .spi_clk_div_set_in     (16'd8                  ),//16'd4
    .spi_data_length_in     (6'd32                  ),
//trig start singal
	.trig_in   			    (trig_spi				),	
	.data_in   			    (spi_parrallel_data	    ),
//
    .spi_cs_out             (LMX2594_cs_out        ),
    .spi_sclk_out           (LMX2594_sclk_out        ),
    .spi_sdata_out          (LMX2594_sdata_out       ),
// spi read data    
    .spi_sdata_in           (1'b0                   ),       
    .spi_rd_data_out        ()
);
endmodule
