# You have to replace <ENTITY_PORT_NAME_xxx> with the name of the PMOD I/O port
# of your top entity
set_location_assignment PIN_F2 -to CS_SPI 
# set_location_assignment PIN_E3 -to <ENTITY_PORT_NAME_CONNECTED_TO_PMOD1_IO2> 
set_location_assignment PIN_C2 -to SDI_SPI
set_location_assignment PIN_B2 -to SCLK_SPI
# set_location_assignment PIN_F1 -to <ENTITY_PORT_NAME_CONNECTED_TO_PMOD1_IO7>
# set_location_assignment PIN_E4 -to <ENTITY_PORT_NAME_CONNECTED_TO_PMOD1_IO8>
# set_location_assignment PIN_C1 -to <ENTITY_PORT_NAME_CONNECTED_TO_PMOD1_IO9>
# set_location_assignment PIN_B1 -to <ENTITY_PORT_NAME_CONNECTED_TO_PMOD1_IO10>

set_location_assignment PIN_G5 -to MCLK_I2S
set_location_assignment PIN_G4 -to WS_I2S
set_location_assignment PIN_G3 -to SCLK_I2S
set_location_assignment PIN_H2 -to SDO_I2S
# set_location_assignment PIN_H1 -to <ENTITY_PORT_NAME_CONNECTED_TO_PMOD2_IO7>
# set_location_assignment PIN_J3 -to <ENTITY_PORT_NAME_CONNECTED_TO_PMOD2_IO8>
# set_location_assignment PIN_J2 -to <ENTITY_PORT_NAME_CONNECTED_TO_PMOD2_IO9>
# set_location_assignment PIN_J1 -to <ENTITY_PORT_NAME_CONNECTED_TO_PMOD2_IO10>
