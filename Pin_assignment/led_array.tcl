#Please do not remove the below two lines as they are required to use one of the 120/108 LED's
set_global_assignment -name RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"

# You have to replace <ENTITY_PORT_NAME_xxx> with the name of the Output port
# of your top entity

set_location_assignment PIN_E6 -to LED[1][1]
set_location_assignment PIN_J16 -to LED[1][2]
set_location_assignment PIN_K16 -to LED[1][3]
set_location_assignment PIN_J17 -to LED[1][4]
set_location_assignment PIN_K17 -to LED[1][5]
set_location_assignment PIN_J18 -to LED[1][6]
set_location_assignment PIN_K18 -to LED[1][7]
set_location_assignment PIN_F19 -to LED[1][8]
set_location_assignment PIN_J15 -to LED[1][9]
set_location_assignment PIN_K15 -to LED[1][10]
set_location_assignment PIN_L16 -to LED[1][11]
set_location_assignment PIN_L15 -to LED[1][12]

set_location_assignment PIN_D6 -to LED[2][1]
set_location_assignment PIN_H9 -to LED[2][2]
set_location_assignment PIN_F10 -to LED[2][3]
set_location_assignment PIN_G12 -to LED[2][4]
set_location_assignment PIN_E10 -to LED[2][5]
set_location_assignment PIN_G14 -to LED[2][6]
set_location_assignment PIN_G15 -to LED[2][7]
set_location_assignment PIN_G16 -to LED[2][8]
set_location_assignment PIN_F14 -to LED[2][9]
set_location_assignment PIN_J22 -to LED[2][10]
set_location_assignment PIN_K21 -to LED[2][11]
set_location_assignment PIN_D19 -to LED[2][12]

set_location_assignment PIN_E5 -to LED[3][1]
set_location_assignment PIN_F8 -to LED[3][2]
set_location_assignment PIN_G10 -to LED[3][3]
set_location_assignment PIN_F11 -to LED[3][4]
set_location_assignment PIN_E9 -to LED[3][5]
set_location_assignment PIN_H13 -to LED[3][6]
set_location_assignment PIN_H14 -to LED[3][7]
set_location_assignment PIN_H15 -to LED[3][8]
set_location_assignment PIN_G17 -to LED[3][9]
set_location_assignment PIN_J21 -to LED[3][10]
set_location_assignment PIN_F15 -to LED[3][11]
set_location_assignment PIN_F17 -to LED[3][12]

set_location_assignment PIN_B5 -to LED[4][1]
set_location_assignment PIN_G8 -to LED[4][2]
set_location_assignment PIN_H10 -to LED[4][3]
set_location_assignment PIN_E11 -to LED[4][4]
set_location_assignment PIN_G7 -to LED[4][5]
set_location_assignment PIN_G13 -to LED[4][6]
set_location_assignment PIN_D10 -to LED[4][7]
set_location_assignment PIN_F12 -to LED[4][8]
set_location_assignment PIN_H16 -to LED[4][9]
set_location_assignment PIN_H19 -to LED[4][10]
set_location_assignment PIN_E15 -to LED[4][11]
set_location_assignment PIN_D17 -to LED[4][12]

set_location_assignment PIN_C4 -to LED[5][1]
set_location_assignment PIN_E7 -to LED[5][2]
set_location_assignment PIN_G9 -to LED[5][3]
set_location_assignment PIN_H11 -to LED[5][4]
set_location_assignment PIN_F7 -to LED[5][5]
set_location_assignment PIN_H12 -to LED[5][6]
set_location_assignment PIN_F9 -to LED[5][7]
set_location_assignment PIN_E12 -to LED[5][8]
set_location_assignment PIN_E13 -to LED[5][9]
set_location_assignment PIN_H17 -to LED[5][10]
set_location_assignment PIN_D15 -to LED[5][11]
set_location_assignment PIN_K22 -to LED[5][12]

set_location_assignment PIN_A4 -to LED[6][1]
set_location_assignment PIN_C7 -to LED[6][2]
set_location_assignment PIN_A8 -to LED[6][3]
set_location_assignment PIN_A10 -to LED[6][4]
set_location_assignment PIN_A14 -to LED[6][5]
set_location_assignment PIN_A16 -to LED[6][6]
set_location_assignment PIN_A18 -to LED[6][7]
set_location_assignment PIN_B20 -to LED[6][8]
set_location_assignment PIN_B22 -to LED[6][9]
set_location_assignment PIN_E22 -to LED[6][10]
set_location_assignment PIN_H21 -to LED[6][11]
set_location_assignment PIN_L21 -to LED[6][12]

set_location_assignment PIN_C3 -to LED[7][1]
set_location_assignment PIN_A5 -to LED[7][2]
set_location_assignment PIN_B7 -to LED[7][3]
set_location_assignment PIN_B9 -to LED[7][4]
set_location_assignment PIN_C13 -to LED[7][5]
set_location_assignment PIN_C15 -to LED[7][6]
set_location_assignment PIN_C17 -to LED[7][7]
set_location_assignment PIN_C19 -to LED[7][8]
set_location_assignment PIN_A20 -to LED[7][9]
set_location_assignment PIN_D20 -to LED[7][10]
set_location_assignment PIN_F20 -to LED[7][11]
set_location_assignment PIN_F16 -to LED[7][12]

set_location_assignment PIN_B3 -to LED[8][1]
set_location_assignment PIN_C6 -to LED[8][2]
set_location_assignment PIN_A7 -to LED[8][3]
set_location_assignment PIN_A9 -to LED[8][4]
set_location_assignment PIN_B13 -to LED[8][5]
set_location_assignment PIN_B15 -to LED[8][6]
set_location_assignment PIN_B17 -to LED[8][7]
set_location_assignment PIN_B19 -to LED[8][8]
set_location_assignment PIN_C21 -to LED[8][9]
set_location_assignment PIN_D21 -to LED[8][10]
set_location_assignment PIN_F22 -to LED[8][11]
set_location_assignment PIN_E16 -to LED[8][12]

set_location_assignment PIN_A3 -to LED[9][1]
set_location_assignment PIN_B6 -to LED[9][2]
set_location_assignment PIN_C8 -to LED[9][3]
set_location_assignment PIN_C10 -to LED[9][4]
set_location_assignment PIN_A13 -to LED[9][5]
set_location_assignment PIN_A15 -to LED[9][6]
set_location_assignment PIN_A17 -to LED[9][7]
set_location_assignment PIN_A19 -to LED[9][8]
set_location_assignment PIN_B21 -to LED[9][9]
set_location_assignment PIN_D22 -to LED[9][10]
set_location_assignment PIN_F21 -to LED[9][11]
set_location_assignment PIN_L22 -to LED[9][12]

set_location_assignment PIN_B4 -to LED[10][1]
set_location_assignment PIN_A6 -to LED[10][2]
set_location_assignment PIN_B8 -to LED[10][3]
set_location_assignment PIN_B10 -to LED[10][4]
set_location_assignment PIN_B14 -to LED[10][5]
set_location_assignment PIN_B16 -to LED[10][6]
set_location_assignment PIN_B18 -to LED[10][7]
set_location_assignment PIN_C20 -to LED[10][8]
set_location_assignment PIN_C22 -to LED[10][9]
set_location_assignment PIN_E21 -to LED[10][10]
set_location_assignment PIN_H22 -to LED[10][11]
set_location_assignment PIN_H20 -to LED[10][12]
