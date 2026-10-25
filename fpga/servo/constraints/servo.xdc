# Combo II-DLD S75 / main clock 50 MHz
set_property PACKAGE_PIN B6 [get_ports clk_50mhz]
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]

# Buttons: mapping from the provided servo_ctrl.zip XDC
set_property PACKAGE_PIN K4 [get_ports left_button]
set_property PACKAGE_PIN N4 [get_ports right_button]
set_property PACKAGE_PIN N8 [get_ports rst_p]

# On-board servo control signal
set_property PACKAGE_PIN AA22 [get_ports servo]

set_property IOSTANDARD LVCMOS33 [get_ports *]

set_false_path -from [get_ports {rst_p left_button right_button}]