module m_LMX2594_controller
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
reg	[23:0]	spi_parrallel_data;

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
          	24'h00_003F : spi_parrallel_data <=24'h4E0003;              //78	
			24'hF0_1000 : spi_parrallel_data <=24'h4D0000;              //77     
			24'hF0_2000 : spi_parrallel_data <=24'h4C000C;              //76    24'h4C000C; 
			24'hF0_3000 : spi_parrallel_data <=24'h4B09C0;              //4B_09_40;  //75     
			24'hF0_4000 : spi_parrallel_data <=24'h4A0000;              //74   
			24'hF0_5000 : spi_parrallel_data <=24'h49003F;              //73
			24'hF0_6000 : spi_parrallel_data <=24'h480001;              //72
			24'hF0_7000 : spi_parrallel_data <=24'h470041;              //71
			24'hF0_8000 : spi_parrallel_data <=24'h46C350;              //70 
			24'hF0_9000 : spi_parrallel_data <=24'h450000;              //69
			24'hF0_A000 : spi_parrallel_data <=24'h4403E8;              //68  
			24'hF0_B000 : spi_parrallel_data <=24'h430000;              //67  
			24'hF0_C000 : spi_parrallel_data <=24'h4201F4;              //66  
			24'hF0_D000 : spi_parrallel_data <=24'h410000;              //65          
			24'hF0_E000 : spi_parrallel_data <=24'h401388;              //64  
			24'hF0_F000 : spi_parrallel_data <=24'h3F0000;              //63   		        
			24'hF1_0000 : spi_parrallel_data <=24'h3E0322;              //62 
			24'hF1_1000 : spi_parrallel_data <=24'h3D00A8;              //61 
			24'hF1_2000 : spi_parrallel_data <=24'h3C0000;              //60
			24'hF1_3000 : spi_parrallel_data <=24'h3B0001;              //59
			24'hF1_4000 : spi_parrallel_data <=24'h3A9001;              //58
			24'hF1_5000 : spi_parrallel_data <=24'h390020;              //57
			24'hF1_6000 : spi_parrallel_data <=24'h380000;              //56
			24'hF1_7000 : spi_parrallel_data <=24'h370000;              //55
			24'hF1_8000 : spi_parrallel_data <=24'h360000;              //54     
			24'hF1_9000 : spi_parrallel_data <=24'h350000;              //53    
			24'hF1_A000 : spi_parrallel_data <=24'h340820;              //52     
			24'hF1_B000 : spi_parrallel_data <=24'h330080;              //51     
			24'hF1_C000 : spi_parrallel_data <=24'h320000;              //50
			24'hF1_D000 : spi_parrallel_data <=24'h314180;              //49            
			24'hF1_E000 : spi_parrallel_data <=24'h300300;              //48
			24'hF1_F000 : spi_parrallel_data <=24'h2F0300;               //47
			24'hF2_0000 : spi_parrallel_data <=24'h2E07FC;               //46
			24'hF2_1000 : spi_parrallel_data <=24'h2DC0DE;               //45
			24'hF2_2000 : spi_parrallel_data <=24'h2C1E23;               //44
			24'hF2_3000 : spi_parrallel_data <=24'h2B0000;//24'h2B0000;               //43
			24'hF2_4000 : spi_parrallel_data <=24'h2A0000;               //42
			24'hF2_5000 : spi_parrallel_data <=24'h290000;               //41
			24'hF2_6000 : spi_parrallel_data <=24'h280000;               //40
			24'hF2_7000 : spi_parrallel_data <=24'h2703E8;               //39
			24'hF2_8000 : spi_parrallel_data <=24'h260000;               //38
			24'hF2_9000 : spi_parrallel_data <=24'h250304;              //37
			24'hF2_A000 : spi_parrallel_data <=24'h2403C0;//24'h240080;              //24_00_40  36
			24'hF2_B000 : spi_parrallel_data <=24'h230004;              //35
			24'hF2_C000 : spi_parrallel_data <=24'h220000;              //34
			24'hF2_D000 : spi_parrallel_data <=24'h211E21;              //33
			24'hF2_E000 : spi_parrallel_data <=24'h200393;              //32
			24'hF2_F000 : spi_parrallel_data <=24'h1F43EC;              //31
			24'hF3_0000 : spi_parrallel_data <=24'h1E318C;              //30
			24'hF3_1000 : spi_parrallel_data <=24'h1D318C;              //29
			24'hF3_2000 : spi_parrallel_data <=24'h1C0488;              //28
			24'hF3_3000 : spi_parrallel_data <=24'h1B0002;              //27
			24'hF3_4000 : spi_parrallel_data <=24'h1A0DB0;              //26
			24'hF3_5000 : spi_parrallel_data <=24'h190C2B;              //25
			24'hF3_6000 : spi_parrallel_data <=24'h18071A;              //24
			24'hF3_7000 : spi_parrallel_data <=24'h17007C;              //23
			24'hF3_8000 : spi_parrallel_data <=24'h160001;              //22
			24'hF3_9000 : spi_parrallel_data <=24'h150401;              //21
			24'hF3_A000 : spi_parrallel_data <=24'h14E048;              //20       
			24'hF3_B000 : spi_parrallel_data <=24'h1327B7;              //19
			24'hF3_C000 : spi_parrallel_data <=24'h120064;              //18     
			24'hF3_D000 : spi_parrallel_data <=24'h11012C;              //17
			24'hF3_E000 : spi_parrallel_data <=24'h100080;              //16
			24'hF3_F000 : spi_parrallel_data <=24'h0F064F;              //15
			24'hF4_1000 : spi_parrallel_data <=24'h0E1E70;              //14	
			24'hF4_2000 : spi_parrallel_data <=24'h0D4000;              //13					
			24'hF4_3000 : spi_parrallel_data <=24'h0C5001;              //12 
			24'hF4_4000 : spi_parrallel_data <=24'h0B0018;              //11 
			24'hF4_5000 : spi_parrallel_data <=24'h0A10D8;              //10
			24'hF4_6000 : spi_parrallel_data <=24'h090604;              //9
			24'hF4_7000 : spi_parrallel_data <=24'h082000;              //8
			24'hF4_8000 : spi_parrallel_data <=24'h0740B2;              //7
			24'hF4_9000 : spi_parrallel_data <=24'h06C802;              //6
			24'hF4_A000 : spi_parrallel_data <=24'h0500C8;              //5
			24'hF4_B000 : spi_parrallel_data <=24'h040A43;              //4
			24'hF4_C000 : spi_parrallel_data <=24'h030642;              //3
			24'hF4_D000 : spi_parrallel_data <=24'h020500;              //2
			24'hF4_E000 : spi_parrallel_data <=24'h010808;              //1
			24'hF9_F615 : spi_parrallel_data <=24'h00241C;              //0       00_24_9C 
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
			24'hF0_B000 : trig_spi <= 1;
			24'hF0_C000 : trig_spi <= 1;
			24'hF0_D000 : trig_spi <= 1;
			24'hF0_E000 : trig_spi <= 1;
			24'hF0_F000 : trig_spi <= 1; 
			24'hF1_0000 : trig_spi <= 1;
			24'hF1_1000 : trig_spi <= 1;
			24'hF1_2000 : trig_spi <= 1;
			24'hF1_3000 : trig_spi <= 1;
			24'hF1_4000 : trig_spi <= 1;
			24'hF1_5000 : trig_spi <= 1;
			24'hF1_6000 : trig_spi <= 1;
			24'hF1_7000 : trig_spi <= 1;
			24'hF1_8000 : trig_spi <= 1;
			24'hF1_9000 : trig_spi <= 1;
			24'hF1_A000 : trig_spi <= 1;
			24'hF1_B000 : trig_spi <= 1;
			24'hF1_C000 : trig_spi <= 1;
			24'hF1_D000 : trig_spi <= 1;
			24'hF1_E000 : trig_spi <= 1;
			24'hF1_F000 : trig_spi <= 1;
			24'hF2_0000 : trig_spi <= 1;
			24'hF2_1000 : trig_spi <= 1;
			24'hF2_2000 : trig_spi <= 1;
			24'hF2_3000 : trig_spi <= 1;
			24'hF2_4000 : trig_spi <= 1;
			24'hF2_5000 : trig_spi <= 1;
			24'hF2_6000 : trig_spi <= 1;
			24'hF2_7000 : trig_spi <= 1;
			24'hF2_8000 : trig_spi <= 1;
			24'hF2_9000 : trig_spi <= 1;
			24'hF2_A000 : trig_spi <= 1;
			24'hF2_B000 : trig_spi <= 1;
			24'hF2_C000 : trig_spi <= 1;
			24'hF2_D000 : trig_spi <= 1;
			24'hF2_E000 : trig_spi <= 1;
			24'hF2_F000 : trig_spi <= 1;
			24'hF3_0000 : trig_spi <= 1;
			24'hF3_1000 : trig_spi <= 1;
			24'hF3_2000 : trig_spi <= 1;	
			24'hF3_3000 : trig_spi <= 1;
			24'hF3_4000 : trig_spi <= 1;
			24'hF3_5000 : trig_spi <= 1;
			24'hF3_6000 : trig_spi <= 1;
			24'hF3_7000 : trig_spi <= 1;	
			24'hF3_8000 : trig_spi <= 1;
			24'hF3_9000 : trig_spi <= 1;
			24'hF3_A000 : trig_spi <= 1;	
			24'hF3_B000 : trig_spi <= 1;
			24'hF3_C000 : trig_spi <= 1;            
			24'hF3_D000 : trig_spi <= 1;
			24'hF3_E000 : trig_spi <= 1;
			24'hF3_F000 : trig_spi <= 1;              
			24'hF4_1000 : trig_spi <= 1;              	
			24'hF4_2000 : trig_spi <= 1;              					
			24'hF4_3000 : trig_spi <= 1;               
			24'hF4_4000 : trig_spi <= 1;               
			24'hF4_5000 : trig_spi <= 1;              
			24'hF4_6000 : trig_spi <= 1;              
			24'hF4_7000 : trig_spi <= 1;              
			24'hF4_8000 : trig_spi <= 1;              
			24'hF4_9000 : trig_spi <= 1;              
			24'hF4_A000 : trig_spi <= 1;              
			24'hF4_B000 : trig_spi <= 1;              
			24'hF4_C000 : trig_spi <= 1;              
			24'hF4_D000 : trig_spi <= 1;              
			24'hF4_E000 : trig_spi <= 1;              
			24'hF9_F615 : trig_spi <= 1;               
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
m_adi_spi_controller i_m_adi_spi_controller (
//input clk
	.clk_in			        (clk_in					),
	.rst_n     			    (rst_n					),	
//
    .spi_clk_div_set_in     (16'd8                  ),//16'd4
    .spi_data_length_in     (5'd24                  ),
//trig start singal
	.trig_in   			    (trig_spi				),	
	.data_in   			    (spi_parrallel_data	    ),
//
    .spi_cs_out           (LMX2594_cs_out        ),
    .spi_sclk_out           (LMX2594_sclk_out        ),
    .spi_sdata_out          (LMX2594_sdata_out       ),
// spi read data    
    .spi_sdata_in           (1'b0                   ),       
    .spi_rd_data_out        ()
);
endmodule
    