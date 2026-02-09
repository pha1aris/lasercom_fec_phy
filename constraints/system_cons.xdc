################====== GTH =======##################
# GTH reference clock
set_property PACKAGE_PIN L7 [get_ports mgtrefclk0_x1y1_n]
set_property PACKAGE_PIN L8 [get_ports mgtrefclk0_x1y1_p]

# Tx Disable Constraints
set_property PACKAGE_PIN G13 [get_ports {tx_disable[0]}]
set_property PACKAGE_PIN H12 [get_ports {tx_disable[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {tx_disable[*]}]
# set_property SLEW SLOW [get_ports {tx_disable[*]}]
set_property PACKAGE_PIN H13 [get_ports {sfp_loss[0]}]
set_property PACKAGE_PIN J12 [get_ports {sfp_loss[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sfp_loss[*]}]
############### ====== sys ===== ###############
set_property PACKAGE_PIN AL8 [get_ports sys_clk_p]
set_property PACKAGE_PIN AL7 [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_clk_n]

set_property PACKAGE_PIN AN12 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]
##################### uart ###########################
set_property PACKAGE_PIN D10 [get_ports uart_txd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]
set_property PACKAGE_PIN D11 [get_ports uart_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rxd]
##################### LED ###########################
# set_property PACKAGE_PIN AM13 [get_ports pl_led1]
# set_property IOSTANDARD LVCMOS33 [get_ports pl_led1]
# set_property PACKAGE_PIN AP12 [get_ports pl_led2]
# set_property IOSTANDARD LVCMOS33 [get_ports pl_led2]
