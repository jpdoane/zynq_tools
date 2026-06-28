# Clocks avaialble from PS (defined in zynq_ps.tcl)
# clk_fpga_0: 100MHz clock (u_zynq/CLK0)
# clk_fpga_1: 50MHz clock (u_zynq/CLK1)

# the AXI clock is provided to the PS on port u_zynq/ACLK_in
#   for 50MHz AXI bus you can just set set ACLK_in = CLK1 and it should just work

# external 125MHz clock
# set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports CLK_125MHZ]
# create_clock -period 8.000 -name sys_clk -waveform {0.000 4.000} [get_ports CLK_125MHZ]
