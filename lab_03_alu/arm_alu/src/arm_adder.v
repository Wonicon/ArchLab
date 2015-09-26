`timescale 1ns / 1ps

module arm_adder #(parameter DATAWIDTH = 32) (
    input [DATAWIDTH-1:0] A_in,
    input [DATAWIDTH-1:0] B_in,
    input Cin,
    output [DATAWIDTH-1:0] Sum,
    output Carry,
    output Overflow
);

assign {Carry, Sum} = A_in + B_in + Cin;
assign Overflow =
    (~A_in[DATAWIDTH-1] & ~B_in[DATAWIDTH-1] & Sum[DATAWIDTH-1])
    | (A_in[DATAWIDTH-1] & B_in[DATAWIDTH-1] & ~Sum[DATAWIDTH-1]);

endmodule
