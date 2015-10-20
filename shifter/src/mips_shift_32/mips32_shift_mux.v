`timescale 1ns / 1ps

// shift0: not shift
// shift1: logic left
// shift2: airthmetic/logic right
// shift3: loop right
module mips32_shift_mux #(parameter DATAWIDTH = 32) (
    input [1:0] switch,
    input [DATAWIDTH - 1:0] shift0,
    input [DATAWIDTH - 1:0] shift1,
    input [DATAWIDTH - 1:0] shift2,
    input [DATAWIDTH - 1:0] shift3,
    output reg [DATAWIDTH - 1:0] shift_out
);

always @(switch or shift0 or shift1 or shift2 or shift3)
begin
    case (switch)
        4'b00: 
            begin
                shift_out = shift0;
                //$display("not shift");
            end
        4'b01:
            begin
                shift_out = shift1;
                //$display("logic right");
            end
        4'b10:
            begin
                shift_out = shift2;
                //$display("arith right");
            end
        4'b11:
            begin
                shift_out = shift3;
                //$display("rotate right");
            end
    endcase
    //$display("in mux shift out %x", shift_out);
end

endmodule
