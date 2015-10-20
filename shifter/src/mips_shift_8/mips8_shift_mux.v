`timescale 1ns / 1ps

// shift0: not shift
// shift1: logic left
// shift2: airthmetic/logic right
// shift3: loop right
module mips8_shift_mux (
    input [7:0] shift0,
    input [7:0] shift1,
    input [7:0] shift2,
    input [7:0] shift3,
    input [1:0] switch,
    output reg [7:0] shift_out
);

always @(switch or shift0 or shift1 or shift2 or shift3)
begin
    case (switch)
        4'b00: shift_out = shift0;
        4'b01: shift_out = shift1;
        4'b10: shift_out = shift2;
        4'b11: shift_out = shift3;
    endcase
end

endmodule
