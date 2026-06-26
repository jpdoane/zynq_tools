#!/usr/bin/env python3

import argparse
import os
import time
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

PROJ_DIR = os.path.dirname(os.path.abspath(__file__))
BUILD_DIR  = os.path.join(PROJ_DIR, 'build')
INC_DIR  = os.path.join(PROJ_DIR, '..')

sys.path.append(str(INC_DIR))
from xsct_utils import Xsct


proj_name = my_zynq_project
BITFILE = os.path.join(BUILD_DIR, f'{proj_name}.bit')
XSA     = os.path.join(BUILD_DIR, f'{proj_name}.xsa')
PS7     = os.path.join(BUILD_DIR, 'workspace', proj_name, '_ide', 'psinit', 'ps7_init.tcl')


# ---------------------------------------------------------------------------
# Memory map
# ---------------------------------------------------------------------------
REG0_BASE      = 0x40000000
REG1_BASE      = 0x42000000


xsct = Xsct()
xsct.program_board(BITFILE, XSA, PS7)

r0in = 0xdeadbeef
r1in = 0x1234abcd

xsct.write32(REG0_BASE, r0in)
xsct.write32(REG1_BASE, r1in)
r0out = xsct.read32(REG0_BASE)
r1out = xsct.read32(REG1_BASE)
print(f'REG0[0]: wrote {r0in:#010x}, read {r0out:#010x}')
print(f'REG1[0]: wrote {r1in:#010x}, read {r1out:#010x}')

if r0in == r0out and r1in == r1out:
    print("test passed :)")
else:
    print("test failed :(")
