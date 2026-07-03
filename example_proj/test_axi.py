#!/usr/bin/env python3

from xsct_utils import Xsct

# ---------------------------------------------------------------------------
# Memory map
# ---------------------------------------------------------------------------
REG0_BASE      = 0x40000000
REG1_BASE      = 0x42000000

xsct = Xsct()
xsct.connect()

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
