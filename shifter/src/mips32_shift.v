`timescale 1ns / 1ps

module mips32_shift (
    input [31:0] shift_in,
    input [4:0] shift_amount,
    input [1:0] shift_op,
    output [31:0] shift_out
);

wire [1:0] s [4:0];
wire [1:0] op;
wire [31:0] temp_result [5:0];

// this operation will make the logic shift right and
// arithmetic shift right share the same switch code as
// the sign extension can be calculate by other curcuits.
assign op = {shift_op[0] || shift_op[1], shift_op[0] ^~ shift_op[1]};


assign s[0]  = {op & {2{shift_amount[0]}}};
assign s[1]  = {op & {2{shift_amount[1]}}};
assign s[2]  = {op & {2{shift_amount[2]}}};
assign s[3]  = {op & {2{shift_amount[3]}}};
assign s[4] = {op & {2{shift_amount[4]}}};

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

assign temp_result[0] = shift_in;

genvar i;
generate
    for (i = 0; i < 5; i = i + 1) begin
        mips32_shift_mux inst (
            .switch(s[i]),
            .shift0(temp_result[i]),
            .shift1({temp_result[i][32 - 1 - 2**i : 0], {2**i{1'b0}}}),
            .shift2({{2**i{sign}}, temp_result[i][32 - 1 : 2**i]}),
            .shift3({temp_result[i][2**i - 1 : 0], temp_result[i][32 - 1 : 2**i]}),
            .shift_out(temp_result[i + 1])
        );
    end
endgenerate

assign shift_out = temp_result[5];

endmodule
