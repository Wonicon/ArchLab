`timescale 1ns / 1ps

//
// ideal_instr_mem
// 
// A memory implemented using registers, which will adjust the address to align to 4 bytes.o
// Just for test.
//

module ideal_instr_mem #(parameter SIZE = 32) (
    input [31:0] address,
    output [31:0] dword
);

// Addressing based on dword
reg [7:0] mem [SIZE - 1:0];

integer i;
initial begin
    for (i = 0; i < SIZE; i = i + 1) begin
        mem[i] = i;
    end
end

assign dword = {mem[address], mem[address+1], mem[address+2], mem[address+3]};

endmodule
