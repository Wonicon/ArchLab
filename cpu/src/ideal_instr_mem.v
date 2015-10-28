`timescale 1ns / 1ps

//
// ideal_instr_mem
//
// A memory implemented using registers, which will adjust the address to align to 4 bytes.o
// Just for test.
//

module ideal_instr_mem (
    input [29:0] address,
    input clk, w_en,
    input [31:0] data_in,
    output [31:0] dword
);

parameter RAM_WIDTH = 32;
parameter RAM_ADDR_BITS = 10;

reg [RAM_WIDTH-1:0] mem [(2**RAM_ADDR_BITS)-1:0];

initial $readmemh("/home/whz/Projects/arch_lab/testbench4mips/single-cycle/ram.txt",mem);

always @(negedge clk) if (w_en) mem[address] <= data_in;

assign dword = mem[address];

endmodule
