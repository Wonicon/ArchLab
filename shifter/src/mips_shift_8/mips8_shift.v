`timescale 1ns / 1ps

`define BIT 8
`include "helper.vh"

module mips8_shift (
    input [7:0] shift_in,
    input [2:0] shift_amount,
    input [1:0] shift_op,
    output [7:0] shift_out
);

wire [1:0] s1, s2, s4, op;
wire [7:0] shift_out0, shift_out1;

assign op = {shift_op[0] || shift_op[1], shift_op[0] ^~ shift_op[1]};

assign s1 = {op & {2{shift_amount[0]}}};
assign s2 = {op & {2{shift_amount[1]}}};
assign s4 = {op & {2{shift_amount[2]}}};

reg sign;
always @(shift_op or shift_in)
begin
    case (shift_op)
        2'b00: sign = 1'b0;
        2'b01: sign = 1'b0;
        2'b10: sign = shift_in[7];
        2'b11: sign = 1'b0;
    endcase
end

`shift_inst_helper(1,s,shift_in,shift_out0);
`shift_inst_helper(2,s,shift_out0,shift_out1);
`shift_inst_helper(4,s,shift_out1,shift_out);

endmodule
