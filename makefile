VFILE := $(shell find ./cpu/src -name "*.v")
VFILE := $(VFILE) $(shell find ./alu/src -name "*.v")
VFILE := $(VFILE) $(shell find ./shifter/src -name "*.v")
VFILE := $(VFILE) $(shell find ./regfile/src -name "*.v")
test: $(VFILE)
	@iverilog $(VFILE)
