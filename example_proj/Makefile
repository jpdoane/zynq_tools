# design
PROJECT=my_zynq_project
FPGA_TOP = zynq_top

# project base dir
ROOT = $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
# build dir
BUILD = $(ROOT)/build
# ZYNQ_TOOLS base dir
ZYNQ_TOOLS = $(abspath $(ROOT)/../)


# board 
DEVICE_LONG = xc7z020clg400-1
DEVICE_SHORT = xc7z020

# tools
HW_SERVER = 127.0.0.1:3121
FLASH_TARGET_ID = 3
TTY_DEV = /dev/ttyUSB0

# configure ila debug
ILA_DEBUG = 1 #set to nonzero to insert ila

# RTL sources
RTL_FILES = $(ROOT)/rtl/axil_regs.sv
RTL_FILES += $(ROOT)/rtl/top.sv

# constraints
XDC_FILES = $(ZYNQ_TOOLS)/boards/artyz7.xdc
XDC_FILES += $(ROOT)/clocks.xdc

# TCL sources (eg. PS with AXI)
TCL_FILES = $(ZYNQ_TOOLS)/zynq_ps.tcl

# TCL project-specific config (run before all other scripts)
CONFIG_TCL_FILES = $(ROOT)/config.tcl          


# PS software
PS_SOURCE = $(ROOT)/ps_src/main.c

include $(ZYNQ_TOOLS)/zynq.mk

test: loadhw
	source $(ENV_SCRIPT)
	python3 test_axi.py
