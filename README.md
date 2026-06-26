# Zynq Tools

Makefile based tools for building and debugging Zynq SoCs using vivado & xsct

Example project and Makefile in `example_proj/`

## Usage
```
cd example_proj
make fpga       # synthesize, place and route, write bitfile
make target     # build baremetal software and FSBL
make program    # program bitfile
make run        # load FSBL and run PS software
make test       # simple example HIL python test script
```
