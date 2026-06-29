###########
# SDRAM
#
# for https://github.com/jpdoane/sdram
#
# Outer ChipKit digital header: Address bus, clock, clock enable
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {sdram_a[0]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {sdram_a[1]}]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {sdram_a[2]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {sdram_a[3]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {sdram_a[4]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {sdram_a[5]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {sdram_a[6]}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {sdram_a[7]}]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {sdram_a[8]}]
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports {sdram_a[9]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {sdram_a[10]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {sdram_a[11]}]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {sdram_a[12]}]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports sdram_cke]
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS33} [get_ports clk_sdram]

# ChipKit Inner Digital Header: Data Bus
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[0]}]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[1]}]
set_property -dict {PACKAGE_PIN V6 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[2]}]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[3]}]
set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[4]}]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[5]}]
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[6]}]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[7]}]
set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[8]}]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[9]}]
set_property -dict {PACKAGE_PIN Y6 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[10]}]
set_property -dict {PACKAGE_PIN Y7 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[11]}]
set_property -dict {PACKAGE_PIN W8 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[12]}]
set_property -dict {PACKAGE_PIN Y8 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[13]}]
set_property -dict {PACKAGE_PIN W9 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[14]}]
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports {sdram_dq[15]}]

# ChipKit Analog Header (as Digital I/O): SDRAM Control
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS33} [get_ports sdram_we_n]
set_property -dict {PACKAGE_PIN Y12 IOSTANDARD LVCMOS33} [get_ports sdram_cas_n]
set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVCMOS33} [get_ports sdram_ras_n]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports sdram_cs_n]
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {sdram_ba[0]}]
set_property -dict {PACKAGE_PIN U10 IOSTANDARD LVCMOS33} [get_ports {sdram_ba[1]}]
set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS33} [get_ports {sdram_dqm[0]}]
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS33} [get_ports {sdram_dqm[1]}]

# set_max_delay -datapath_only -from [all_registers] -to [get_ports clk_sdram] 4
# set_max_delay -datapath_only -from [all_registers] -to [get_ports sdram_cke] 4
# set_max_delay -datapath_only -from [all_registers] -to [get_ports sdram_cs_n] 4
# set_max_delay -datapath_only -from [all_registers] -to [get_ports sdram_ras_n] 4
# set_max_delay -datapath_only -from [all_registers] -to [get_ports sdram_cas_n] 4
# set_max_delay -datapath_only -from [all_registers] -to [get_ports sdram_we_n] 4
# set_max_delay -datapath_only -from [all_registers] -to [get_ports sdram_dqm] 4
# set_max_delay -datapath_only -from [all_registers] -to [get_ports sdram_a] 4
# set_max_delay -datapath_only -from [all_registers] -to [get_ports sdram_ba] 4
# set_max_delay -datapath_only -from [get_ports sdram_dq] 4
