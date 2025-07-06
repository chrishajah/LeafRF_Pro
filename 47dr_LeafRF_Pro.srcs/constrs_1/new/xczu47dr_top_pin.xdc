#************************* Clock PINs **************************************#

#************************* 300M OSC **************************************#
set_property PACKAGE_PIN AJ17 [get_ports OSC_300M_P]
set_property PACKAGE_PIN AK16 [get_ports OSC_300M_N]
set_property IOSTANDARD DIFF_SSTL12 [get_ports OSC_300M_P]
create_clock -period 3.333 -name OSC_300M_P -waveform {0.000 1.667} [get_ports OSC_300M_P]

#************************* 156M25 MGT ************************************#
set_property PACKAGE_PIN M29 [get_ports MGT_CLK_156M25_N]
set_property PACKAGE_PIN M28 [get_ports MGT_CLK_156M25_P]
create_clock -period 6.400 -name MGT_CLK_156M25_P -waveform {0.000 3.200} [get_ports MGT_CLK_156M25_P]

#********************* SYSREF FROM LMK01020 ******************************#
set_property PACKAGE_PIN AG17 [get_ports PL_SYSREF_P]
set_property PACKAGE_PIN AH17 [get_ports PL_SYSREF_N]

set_property IOSTANDARD DIFF_SSTL12 [get_ports PL_SYSREF_N]
set_property IOSTANDARD DIFF_SSTL12 [get_ports PL_SYSREF_P]

set_property DIFF_TERM_ADV  ""  [get_ports PL_SYSREF_P ]
set_property DIFF_TERM_ADV  ""  [get_ports PL_SYSREF_N ]

#********************* 125M FROM LMX2594**********************************#

set_property PACKAGE_PIN AG15 [get_ports PL_CLK_P]

set_property IOSTANDARD DIFF_SSTL12 [get_ports PL_CLK_N]
set_property IOSTANDARD DIFF_SSTL12 [get_ports PL_CLK_P]

set_property DIFF_TERM_ADV  ""  [get_ports PL_CLK_P ]
set_property DIFF_TERM_ADV  ""  [get_ports PL_CLK_N ]







#************************* GTY PINs **************************************#
set_property PACKAGE_PIN P33 [get_ports QSFP_RX_P]
set_property PACKAGE_PIN P34 [get_ports QSFP_RX_N]
set_property PACKAGE_PIN N30 [get_ports QSFP_TX_P]
set_property PACKAGE_PIN N31 [get_ports QSFP_TX_N]


#************************* DDR PINs **************************************#

set_property PACKAGE_PIN AN17 [get_ports {c0_ddr4_adr[16]}]
set_property PACKAGE_PIN AK18 [get_ports {c0_ddr4_adr[15]}]
set_property PACKAGE_PIN AM15 [get_ports {c0_ddr4_adr[14]}]
set_property PACKAGE_PIN AJ18 [get_ports {c0_ddr4_adr[13]}]
set_property PACKAGE_PIN AP16 [get_ports {c0_ddr4_adr[12]}]
set_property PACKAGE_PIN AF16 [get_ports {c0_ddr4_adr[11]}]
set_property PACKAGE_PIN AN14 [get_ports {c0_ddr4_adr[10]}]
set_property PACKAGE_PIN AM17 [get_ports {c0_ddr4_adr[9]}]
set_property PACKAGE_PIN AE16 [get_ports {c0_ddr4_adr[8]}]
set_property PACKAGE_PIN AH18 [get_ports {c0_ddr4_adr[7]}]
set_property PACKAGE_PIN AG14 [get_ports {c0_ddr4_adr[6]}]
set_property PACKAGE_PIN AN18 [get_ports {c0_ddr4_adr[5]}]
set_property PACKAGE_PIN AH13 [get_ports {c0_ddr4_adr[4]}]
set_property PACKAGE_PIN AM16 [get_ports {c0_ddr4_adr[3]}]
set_property PACKAGE_PIN AM14 [get_ports {c0_ddr4_adr[2]}]
set_property PACKAGE_PIN AL17 [get_ports {c0_ddr4_adr[1]}]
set_property PACKAGE_PIN AH14 [get_ports {c0_ddr4_adr[0]}]
set_property PACKAGE_PIN AF17 [get_ports {c0_ddr4_ba[1]}]
set_property PACKAGE_PIN AJ13 [get_ports {c0_ddr4_ba[0]}]
set_property PACKAGE_PIN AK14 [get_ports {c0_ddr4_bg[0]}]
set_property PACKAGE_PIN AJ16 [get_ports {c0_ddr4_ck_t[0]}]
set_property PACKAGE_PIN AF13 [get_ports {c0_ddr4_cke[0]}]
set_property PACKAGE_PIN AP17 [get_ports {c0_ddr4_cs_n[0]}]
set_property PACKAGE_PIN AP13 [get_ports {c0_ddr4_dm_dbi_n[3]}]
set_property PACKAGE_PIN AL9 [get_ports {c0_ddr4_dm_dbi_n[2]}]
set_property PACKAGE_PIN AG12 [get_ports {c0_ddr4_dm_dbi_n[1]}]
set_property PACKAGE_PIN AP8 [get_ports {c0_ddr4_dm_dbi_n[0]}]
set_property PACKAGE_PIN AN13 [get_ports {c0_ddr4_dq[28]}]
set_property PACKAGE_PIN AN8 [get_ports {c0_ddr4_dq[26]}]
set_property PACKAGE_PIN AP11 [get_ports {c0_ddr4_dq[30]}]
set_property PACKAGE_PIN AN7 [get_ports {c0_ddr4_dq[24]}]
set_property PACKAGE_PIN AP10 [get_ports {c0_ddr4_dq[29]}]
set_property PACKAGE_PIN AN10 [get_ports {c0_ddr4_dq[25]}]
set_property PACKAGE_PIN AN12 [get_ports {c0_ddr4_dq[31]}]
set_property PACKAGE_PIN AM10 [get_ports {c0_ddr4_dq[27]}]
set_property PACKAGE_PIN AJ11 [get_ports {c0_ddr4_dq[23]}]
set_property PACKAGE_PIN AK10 [get_ports {c0_ddr4_dq[22]}]
set_property PACKAGE_PIN AK11 [get_ports {c0_ddr4_dq[21]}]
set_property PACKAGE_PIN AM11 [get_ports {c0_ddr4_dq[20]}]
set_property PACKAGE_PIN AK13 [get_ports {c0_ddr4_dq[19]}]
set_property PACKAGE_PIN AM12 [get_ports {c0_ddr4_dq[18]}]
set_property PACKAGE_PIN AL13 [get_ports {c0_ddr4_dq[17]}]
set_property PACKAGE_PIN AK9 [get_ports {c0_ddr4_dq[16]}]
set_property PACKAGE_PIN AG9 [get_ports {c0_ddr4_dq[15]}]
set_property PACKAGE_PIN AE11 [get_ports {c0_ddr4_dq[14]}]
set_property PACKAGE_PIN AG10 [get_ports {c0_ddr4_dq[13]}]
set_property PACKAGE_PIN AF12 [get_ports {c0_ddr4_dq[12]}]
set_property PACKAGE_PIN AH9 [get_ports {c0_ddr4_dq[11]}]
set_property PACKAGE_PIN AF11 [get_ports {c0_ddr4_dq[10]}]
set_property PACKAGE_PIN AH10 [get_ports {c0_ddr4_dq[9]}]
set_property PACKAGE_PIN AF10 [get_ports {c0_ddr4_dq[8]}]
set_property PACKAGE_PIN AM5 [get_ports {c0_ddr4_dq[2]}]
set_property PACKAGE_PIN AP2 [get_ports {c0_ddr4_dq[0]}]
set_property PACKAGE_PIN AM6 [get_ports {c0_ddr4_dq[5]}]
set_property PACKAGE_PIN AN2 [get_ports {c0_ddr4_dq[6]}]
set_property PACKAGE_PIN AP5 [get_ports {c0_ddr4_dq[3]}]
set_property PACKAGE_PIN AP3 [get_ports {c0_ddr4_dq[7]}]
set_property PACKAGE_PIN AP6 [get_ports {c0_ddr4_dq[1]}]
set_property PACKAGE_PIN AN1 [get_ports {c0_ddr4_dq[4]}]
set_property PACKAGE_PIN AM8 [get_ports {c0_ddr4_dqs_t[3]}]
set_property PACKAGE_PIN AL12 [get_ports {c0_ddr4_dqs_t[2]}]
set_property PACKAGE_PIN AJ10 [get_ports {c0_ddr4_dqs_t[1]}]
set_property PACKAGE_PIN AN5 [get_ports {c0_ddr4_dqs_t[0]}]
set_property PACKAGE_PIN AP15 [get_ports {c0_ddr4_odt[0]}]
set_property PACKAGE_PIN AN15 [get_ports c0_ddr4_act_n]
set_property PACKAGE_PIN AF14 [get_ports c0_ddr4_reset_n]



#************************* CLK SPI PINs *************************************#

set_property PACKAGE_PIN K10 [get_ports CLK_led]
set_property IOSTANDARD LVCMOS33 [get_ports CLK_led]
set_property SLEW FAST [get_ports CLK_led]
set_property PACKAGE_PIN B10 [get_ports LMX2594_cs]
set_property PACKAGE_PIN C10 [get_ports LMX2594_sclk]
set_property PACKAGE_PIN B11 [get_ports LMX2594_sdata]
set_property IOSTANDARD LVCMOS33 [get_ports LMX2594_cs]
set_property IOSTANDARD LVCMOS33 [get_ports LMX2594_sclk]
set_property SLEW FAST [get_ports LMX2594_sdata]
set_property SLEW FAST [get_ports LMX2594_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports LMX2594_sdata]
set_property SLEW FAST [get_ports LMX2594_cs]
set_property PACKAGE_PIN C11 [get_ports LMX2594_mux]
set_property IOSTANDARD LVCMOS33 [get_ports LMX2594_mux]
set_property IOSTANDARD LVCMOS33 [get_ports LMK010201_sdata]
set_property IOSTANDARD LVCMOS33 [get_ports LMK01020_cs]
set_property IOSTANDARD LVCMOS33 [get_ports LMK01020_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports LMK010201_cs]
set_property IOSTANDARD LVCMOS33 [get_ports LMK010201_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports LMK01020_sdata]
set_property PACKAGE_PIN H15 [get_ports LMK01020_cs]
set_property PACKAGE_PIN G13 [get_ports LMK01020_sclk]
set_property PACKAGE_PIN H13 [get_ports LMK01020_sdata]
set_property PACKAGE_PIN J13 [get_ports LMK010201_cs]
set_property PACKAGE_PIN K15 [get_ports LMK010201_sclk]
set_property PACKAGE_PIN K14 [get_ports LMK010201_sdata]
set_property SLEW FAST [get_ports LMK010201_sdata]
set_property SLEW FAST [get_ports LMK010201_sclk]
set_property SLEW FAST [get_ports LMK010201_cs]
set_property SLEW FAST [get_ports LMK01020_sdata]
set_property SLEW FAST [get_ports LMK01020_sclk]
set_property SLEW FAST [get_ports LMK01020_cs]
set_property PULLUP true [get_ports LMX2594_cs]

