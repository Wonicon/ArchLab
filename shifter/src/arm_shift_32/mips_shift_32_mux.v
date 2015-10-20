`timescale 1ns / 1ps

// mux_no: not shift
// mux_sl: logic left
// mux_sr: airthmetic/logic right
// mux_ro: loop right
module arm_shift_32_mux #(parameter DATA_WIDTH = 33) (
    input [1:0] switch,
    input [DATA_WIDTH - 1:0] mux_no,
    input [DATA_WIDTH - 1:0] mux_sl,
    input [DATA_WIDTH - 1:0] mux_sr,
    input [DATA_WIDTH - 1:0] mux_ro,
    output reg [DATA_WIDTH - 1:0] mux_out
);

always @(switch or mux_no or mux_sl or mux_sr or mux_ro)
begin
    case (switch)
        4'b00: mux_out = mux_no;
        4'b01: mux_out = mux_sl;
        4'b10: mux_out = mux_sr;
        4'b11: mux_out = mux_ro;
    endcase
end

endmodule
