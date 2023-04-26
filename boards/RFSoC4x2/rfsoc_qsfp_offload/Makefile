overlay_name := rfsoc_offload
design_name := block_design

all: bitstream

block_design:
	vivado -mode batch -source make_block_design.tcl -notrace -nojournal -nolog

bitstream: block_design
	vivado -mode batch -source make_bitstream.tcl -notrace -nojournal -nolog

clean:
	rm -rf rfsoc_offload *.jou *.log NA
