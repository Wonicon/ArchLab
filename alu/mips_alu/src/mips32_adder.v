`timescale 1ns / 1ps

module mips32_adder #(parameter DATAWIDTH = 32) (
    input [DATAWIDTH - 1:0] A_in,
    input [DATAWIDTH - 1:0] B_in,
    input Cin,
    output Zero,
    output Carry,
    output Overflow,
    output Negative,
    output [DATAWIDTH - 1:0] O_out
);

reg [DATAWIDTH:0] result;
always @(A_in or B_in or Cin) begin
    result = {1'b0, A_in} + {1'b0, B_in} + Cin;
end

assign O_out = result[DATAWIDTH - 1:0];
assign Zero = ~(|O_out);
assign Carry = result[DATAWIDTH];
assign Overflow = ((~A_in[DATAWIDTH - 1]) & (~B_in[DATAWIDTH - 1]) & O_out[DATAWIDTH - 1])
                | (A_in[DATAWIDTH - 1] & B_in[DATAWIDTH - 1] & (~O_out[DATAWIDTH - 1]));
assign Negative = O_out[DATAWIDTH - 1];

endmodule

