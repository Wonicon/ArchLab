//
// ideal_instr_mem
// 
// A memory implemented using registers, which will adjust the address to align to 4 bytes.o
// Just for test.
//

module ideal_instr_mem #(parameter SIZE) (
    input [31:0] address,
    output [31:0] dword
);

// Addressing based on dword
reg [31:0] mem [127:0];

assign dword = mem[ address[31:2] ];

endmodule
