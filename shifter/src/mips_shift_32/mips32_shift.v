`timescale 1ns / 1ps

`define BIT 32
`include "helper.vh"

module mips32_shift (
    input [31:0] shift_in,
    input [4:0] shift_amount,
    input [1:0] shift_op,
    output [31:0] shift_out
);

wire [1:0] s1, s2, s4, s8, s16, op;
wire [31:0] shift_out1, shift_out2, shift_out4, shift_out8;

// this operation will make the logic shift right and
// arithmetic shift right share the same switch code as
// the sign extension can be calculate by other curcuits.
assign op = {shift_op[0] || shift_op[1], shift_op[0] ^~ shift_op[1]};

assign s1  = {op & {2{shift_amount[0]}}};
assign s2  = {op & {2{shift_amount[1]}}};
assign s4  = {op & {2{shift_amount[2]}}};
assign s8  = {op & {2{shift_amount[3]}}};
assign s16 = {op & {2{shift_amount[4]}}};

reg sign;
always @(shift_op or shift_in)
begin
    case (shift_op)
        // Need the sign
        2'b10: sign = shift_in[31];
        // Not need the sign
        default: sign = 1'b0;
    endcase
end

`shift_inst_helper(1,s,shift_in,shift_out1);
`shift_inst_helper(2,s,shift_out1,shift_out2);
`shift_inst_helper(4,s,shift_out2,shift_out4);
`shift_inst_helper(8,s,shift_out4,shift_out8);
`shift_inst_helper(16,s,shift_out8,shift_out);

endmodule
