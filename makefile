VFILE := $(shell find ./cpu/src -name "*.v")
VFILE := $(VFILE) $(shell find ./alu/mips_alu/src -name "*.v")
VFILE := $(VFILE) $(shell find ./shifter/src/mips_shift_32 -name "*.v")
DIR := ./shifter/include
HFILE := $(shell find $(DIR) -name "*.h")
test: $(VFILE)
	@iverilog $(VFILE) -I$(DIR)
