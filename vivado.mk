# SPDX-License-Identifier: MIT
###################################################################
#
# Xilinx Vivado FPGA Makefile
#
# Copyright (c) 2016-2025 Alex Forencich
#
###################################################################
#
# Parameters:
# FPGA_TOP - Top module name
# FPGA_FAMILY - FPGA family (e.g. VirtexUltrascale)
# FPGA_DEVICE - FPGA device (e.g. xcvu095-ffva2104-2-e)
# RTL_FILES - list of source files
# INC_FILES - list of include files
# XDC_FILES - list of timing constraint files
# XCI_FILES - list of IP XCI files
# TCL_FILES - list of IP TCL files (sourced during project creation)
# CONFIG_TCL_FILES - list of config TCL files (sourced before each build)
#
# Note: both RTL_FILES and INC_FILES support file list files.  File list
# files are files with a .f extension that contain a list of additional
# files to include, one path relative to the .f file location per line.
# The .f files are processed recursively, and then the complete file list
# is de-duplicated, with later files in the list taking precedence.
#
# Example:
#
# FPGA_TOP = fpga
# FPGA_FAMILY = VirtexUltrascale
# FPGA_DEVICE = xcvu095-ffva2104-2-e
# RTL_FILES = rtl/fpga.v
# XDC_FILES = fpga.xdc
# XCI_FILES = ip/pcspma.xci
# include ../common/vivado.mk
#
###################################################################

# phony targets
.PHONY: fpga vivado synth impl program flash tmpclean clean distclean debug lint
# prevent make from deleting intermediate files and reports
.PRECIOUS: %.xpr %.bit %.bin %.ltx %.xsa %.mcs %.prm
.SECONDARY:

ROOT ?= $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
BUILD ?= $(ROOT)/build/
HW_SERVER ?= 127.0.0.1:3121
HW_DEVICE_IDX ?= 1

FPGA_TOP ?= fpga
PROJECT ?= $(FPGA_TOP)
XDC_FILES ?= $(BUILD)/$(PROJECT).xdc

# handle file list files
process_f_file = $(call process_f_files,$(addprefix $(dir $1),$(shell cat $1)))
process_f_files = $(foreach f,$1,$(if $(filter %.f,$f),$(call process_f_file,$f),$f))
uniq_base = $(if $1,$(call uniq_base,$(foreach f,$1,$(if $(filter-out $(notdir $(lastword $1)),$(notdir $f)),$f,))) $(lastword $1))
RTL_FILES := $(call uniq_base,$(call process_f_files,$(RTL_FILES)))
INC_FILES := $(call uniq_base,$(call process_f_files,$(INC_FILES)))


###################################################################
# Main Targets
#
# all: build everything (fpga)
# fpga: build FPGA config
# vivado: open project in Vivado
# tmpclean: remove intermediate files
# clean: remove output files and project files
# distclean: remove archived output files
###################################################################

PROJECTFILE = $(BUILD)/$(PROJECT).xpr
SYNTH_DCP = $(BUILD)/post_synth_debug.dcp
IMPL_DCP = $(BUILD)/post_route.dcp
BITFILE = $(BUILD)/$(PROJECT).bit
PROBE_FILE = $(BUILD)/probes.ltx
XSA_FILE = $(BUILD)/$(PROJECT).xsa
VDEF_FILE = $(BUILD)/defines.v
SETUP_FILE = $(BUILD)/setup.tcl

all: fpga
vivado: $(PROJECTFILE)
	cd $(BUILD); vivado $<

synth: $(SYNTH_DCP)
impl: $(IMPL_DCP)
fpga: $(BITFILE)


# tmpclean::
# 	-rm -rf *.log *.jou *.cache *.gen *.hbs *.hw *.ip_user_files *.runs *.xpr *.html *.xml *.sim *.srcs *.str .Xil defines.v
# 	-rm -rf create_project.tcl update_config.tcl run_synth.tcl run_impl.tcl generate_bit.tcl

clean::
	rm -rf $(BUILD)
	rm -rf .Xil
	rm *.jou
	rm *.log
	
# -rm -rf *.bit *.bin *.ltx *.xsa program.tcl generate_mcs.tcl *.mcs *.prm flash.tcl
# -rm -rf *_utilization.rpt *_utilization_hierarchical.rpt
# -rm -rf rev

distclean:: clean
	-rm -rf rev


###################################################################
# Target implementations
###################################################################


# Vivado project file
# create fresh project if Makefile or IP files have changed
# create_project.tcl: Makefile $(XCI_FILES) $(TCL_FILES)

$(VDEF_FILE): $(DEFS)
	-mkdir $(BUILD)
	rm -rf $(BUILD)/defines.v
	touch $(BUILD)/defines.v
	for x in $(DEFS); do echo '`define' $$x >> $(BUILD)/defines.v; done

$(SETUP_FILE): $(VDEF_FILE) $(RTL_FILES) $(TCL_FILES) $(XDC_FILES)
	-mkdir $(BUILD)
	echo "set ROOT $(ROOT)" > $@
	echo "set BUILD $(BUILD)" >> $@
	echo "set DEVICE_LONG $(DEVICE_LONG)" >> $@
	echo "set DEVICE_SHORT $(DEVICE_SHORT)" >> $@
	echo "set BITFILE $(BITFILE)" >> $@
	echo "set PROJECTNAME $(PROJECT)" >> $@
	echo "set TOP $(FPGA_TOP)" >> $@
	echo "set_part $(DEVICE_LONG)" >> $@
	for x in $(CONFIG_TCL_FILES); do echo "source $$x" >> $@; done
	for x in $(TCL_FILES); do echo "source $$x" >> $@; done
	echo "read_verilog $(RTL_FILES)" >> $@
	echo "read_xdc $(XDC_FILES)" >> $@

# synthesis run
$(SYNTH_DCP): $(SETUP_FILE)
	echo "source $(SETUP_FILE)" > $(BUILD)/run_synth.tcl
	echo "synth_design -top $(FPGA_TOP) -part $(DEVICE_LONG) -flatten_hierarchy rebuilt" >> $(BUILD)/run_synth.tcl
	@if [ -n "$(ILA_DEBUG)" ]; then \
		echo "source $(ZYNQ_COMMON)/insert_ila.tcl" >> $(BUILD)/run_synth.tcl;  \
	fi
	echo "write_checkpoint -force $(SYNTH_DCP)" >> $(BUILD)/run_synth.tcl
	echo "report_timing_summary -file $(BUILD)/post_synth_timing.rpt" >> $(BUILD)/run_synth.tcl
	cd $(BUILD); vivado -mode batch -source $(BUILD)/run_synth.tcl

# implementation run
$(IMPL_DCP): $(SYNTH_DCP)
	echo "open_checkpoint $(SYNTH_DCP)" > $(BUILD)/run_impl.tcl
	echo "place_design" >> $(BUILD)/run_impl.tcl
	echo "phys_opt_design" >> $(BUILD)/run_impl.tcl
	echo "route_design" >> $(BUILD)/run_impl.tcl
	echo "write_checkpoint -force $(IMPL_DCP)" >> $(BUILD)/run_impl.tcl
	echo "report_timing_summary -file $(BUILD)/post_route_timing.rpt" >> $(BUILD)/run_impl.tcl
	echo "report_utilization -file $(BUILD)/utilization.rpt" >> $(BUILD)/run_impl.tcl
	echo "report_utilization -hierarchical -file $(BUILD)/utilization_hierarchical.rpt" >> $(BUILD)/run_impl.tcl
	cd $(BUILD); vivado -mode batch -source $(BUILD)/run_impl.tcl

# output files (including potentially bit, bin, ltx, and xsa)
$(BITFILE) $(BUILD)/$(PROJECT).bin $(XSA_FILE): $(IMPL_DCP)
	echo "open_checkpoint $(IMPL_DCP)" > $(BUILD)/generate_bit.tcl
	echo "write_bitstream -force -bin_file $(BITFILE)" >> $(BUILD)/generate_bit.tcl
	@if [ -n "$(ILA_DEBUG)" ]; then \
		echo "write_debug_probes -force $(PROBE_FILE)" >> $(BUILD)/generate_bit.tcl; \
	fi
	echo "write_hw_platform -fixed -force -include_bit $(XSA_FILE)" >> $(BUILD)/generate_bit.tcl
	cd $(BUILD); vivado -nojournal -nolog -mode batch -source $(BUILD)/generate_bit.tcl

# open hw_manager and connect to fpga
$(BUILD)/connect_device.tcl:
	echo "open_hw_manager" > $@
	echo "connect_hw_server -url TCP:$(HW_SERVER)" >> $@
	echo "open_hw_target" >> $@
	echo "set DEVICE_ID [lsearch -glob [get_hw_devices] $(DEVICE_SHORT)* ]" >> $@
	echo "current_hw_device $(DEVICE_ID)" >> $@

$(BUILD)/debug_hw.tcl: $(BUILD)/connect_device.tcl $(PROBE_FILE)
	@if [ -z "$(ILA_DEBUG)" ]; then \
		echo "set ILA_DEBUG variable to enable debug"; \
		exit 1;\
	fi
	cp $(BUILD)/connect_device.tcl"  $@
	echo "set_property PROBES.FILE $(PROBE_FILE) [current_hw_device]" >> $@
	echo "set_property FULL_PROBES.FILE $(PROBE_FILE) [current_hw_device]" >> $@
	echo "set_property PROGRAM.FILE {/home/jpdoane/6502_zynq/build/zynq_6502.bit} [current_hw_device]" >> $@
	echo "program_hw_devices [current_hw_device]" >> $@
	echo "refresh_hw_device [current_hw_device]" >> $@
	echo "display_hw_ila_data [ get_hw_ila_data hw_ila_data_1 -of_objects [get_hw_ilas -of_objects [current_hw_device] -filter {CELL_NAME=~"ila_*"}]]" >> $@

$(BUILD)/program.tcl: $(BUILD)/connect_device.tcl $(BITFILE)
	cp $(BUILD)/connect_device.tcl"  $@
	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> $@
	echo "set_property PROGRAM.FILE {$(PROJECT).bit} [current_hw_device]" >> $@
	echo "program_hw_devices [current_hw_device]" >> $@
	echo "exit" >> $@

program: $(BUILD)/program.tcl
	cd $(BUILD); vivado -nojournal -nolog -mode batch -source $(BUILD)/program.tcl

debug: $(BUILD)/debug_hw.tcl 
	cd $(BUILD); vivado -mode gui -source debug_hw.tcl; \

$(BUILD)/$(PROJECT).mcs $(BUILD)/$(PROJECT).prm: $(BITFILE)
	echo "write_cfgmem -force -format mcs -size 16 -interface SPIx4 -loadbit {up 0x0000000 $*.bit} -checksum -file $*.mcs" > $(BUILD)/generate_mcs.tcl
	echo "exit" >> $(BUILD)/generate_mcs.tcl
	vivado -nojournal -nolog -mode batch -source $(BUILD)/generate_mcs.tcl
	mkdir -p rev
	COUNT=100; \
	while [ -e rev/$*_rev$$COUNT.bit ]; \
	do COUNT=$$((COUNT+1)); done; \
	COUNT=$$((COUNT-1)); \
	for x in .mcs .prm; \
	do cp $(BUILD)/$*$$x rev/$*_rev$$COUNT$$x; \
	echo "Output: rev/$*_rev$$COUNT$$x"; done;





# flash: $(PROJECT).mcs $(PROJECT).prm
# 	echo "open_hw_manager" > flash.tcl
# 	echo "connect_hw_server" >> flash.tcl
# 	echo "open_hw_target" >> flash.tcl
# 	echo "current_hw_device [lindex [get_hw_devices] 0]" >> flash.tcl
# 	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> flash.tcl
# 	echo "create_hw_cfgmem -hw_device [current_hw_device] [lindex [get_cfgmem_parts {mt25ql128-spi-x1_x2_x4}] 0]" >> flash.tcl
# 	echo "current_hw_cfgmem -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM [current_hw_device]]" >> flash.tcl
# 	echo "set_property PROGRAM.FILES [list \"$(PROJECT).mcs\"] [current_hw_cfgmem]" >> flash.tcl
# 	echo "set_property PROGRAM.PRM_FILES [list \"$(PROJECT).prm\"] [current_hw_cfgmem]" >> flash.tcl
# 	echo "set_property PROGRAM.ERASE 1 [current_hw_cfgmem]" >> flash.tcl
# 	echo "set_property PROGRAM.CFG_PROGRAM 1 [current_hw_cfgmem]" >> flash.tcl
# 	echo "set_property PROGRAM.VERIFY 1 [current_hw_cfgmem]" >> flash.tcl
# 	echo "set_property PROGRAM.CHECKSUM 0 [current_hw_cfgmem]" >> flash.tcl
# 	echo "set_property PROGRAM.ADDRESS_RANGE {use_file} [current_hw_cfgmem]" >> flash.tcl
# 	echo "set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [current_hw_cfgmem]" >> flash.tcl
# 	echo "create_hw_bitstream -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM_BITFILE [current_hw_device]]" >> flash.tcl
# 	echo "program_hw_devices [current_hw_device]" >> flash.tcl
# 	echo "refresh_hw_device [current_hw_device]" >> flash.tcl
# 	echo "program_hw_cfgmem -hw_cfgmem [current_hw_cfgmem]" >> flash.tcl
# 	echo "boot_hw_device [current_hw_device]" >> flash.tcl
# 	echo "exit" >> flash.tcl
# 	vivado -nojournal -nolog -mode batch -source flash.tcl
