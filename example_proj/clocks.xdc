# Clocks avaialble from PS (defined in zynq_ps.tcl)
# clk_fpga_0: 100MHz clock (u_zynq/processing_system7_0/inst/FCLK_CLK0)
# clk_fpga_1: 50MHz clock (u_zynq/processing_system7_0/inst/FCLK_CLK1)

# external 125MHz clock
# set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports CLK_125MHZ]
# create_clock -period 8.000 -name sys_clk -waveform {0.000 4.000} [get_ports CLK_125MHZ]
