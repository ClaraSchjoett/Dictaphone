# Use all available processors and silence the associated warning
set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL


########################################################################
# SDRAM
########################################################################

set_location_assignment PIN_N5 -to sdram_addr[0]
set_location_assignment PIN_N6 -to sdram_addr[1]
set_location_assignment PIN_P4 -to sdram_addr[2]
set_location_assignment PIN_P5 -to sdram_addr[3]
set_location_assignment PIN_W6 -to sdram_addr[4]
set_location_assignment PIN_V7 -to sdram_addr[5]
set_location_assignment PIN_V6 -to sdram_addr[6]
set_location_assignment PIN_V5 -to sdram_addr[7]
set_location_assignment PIN_V1 -to sdram_addr[8]
set_location_assignment PIN_V4 -to sdram_addr[9]
set_location_assignment PIN_U2 -to sdram_addr[10]
set_location_assignment PIN_U8 -to sdram_addr[11]
set_location_assignment PIN_V2 -to sdram_addr[12]

set_location_assignment PIN_M6 -to sdram_ba[0]
set_location_assignment PIN_M7 -to sdram_ba[1]

set_location_assignment PIN_M1  -to sdram_data[0]
set_location_assignment PIN_M2  -to sdram_data[1]
set_location_assignment PIN_M3  -to sdram_data[2]
set_location_assignment PIN_N1  -to sdram_data[3]
set_location_assignment PIN_N2  -to sdram_data[4]
set_location_assignment PIN_P1  -to sdram_data[5]
set_location_assignment PIN_P2  -to sdram_data[6]
set_location_assignment PIN_P3  -to sdram_data[7]
set_location_assignment PIN_W1  -to sdram_data[8]
set_location_assignment PIN_W2  -to sdram_data[9]
set_location_assignment PIN_Y1  -to sdram_data[10]
set_location_assignment PIN_Y2  -to sdram_data[11]
set_location_assignment PIN_Y3  -to sdram_data[12]
set_location_assignment PIN_AA1 -to sdram_data[13]
set_location_assignment PIN_AB3 -to sdram_data[14]
set_location_assignment PIN_AA4 -to sdram_data[15]

set_location_assignment PIN_R1 -to sdram_dqm_n[0]
set_location_assignment PIN_V3 -to sdram_dqm_n[1]

set_location_assignment PIN_U7  -to sdram_cke
set_location_assignment PIN_AA3 -to sdram_clk
set_location_assignment PIN_M5  -to sdram_cas_n
set_location_assignment PIN_M4  -to sdram_ras_n
set_location_assignment PIN_U1  -to sdram_cs_n
set_location_assignment PIN_R2  -to sdram_we_n


