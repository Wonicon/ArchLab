`timescale 1ns / 1ps
`include "common.vh"

module Address_Map (
    input [3:0] addr,
    input [4:0] mode,
    output reg [4:0] dst
    );

    always @(addr or mode)
    begin
        case ({mode[3:0], addr})
            // FIQ
            8'b00011000: dst = `R8_FIQ;
            8'b00011001: dst = `R9_FIQ;
            8'b00011010: dst = `R10_FIQ;
            8'b00011011: dst = `R11_FIQ;
            8'b00011100: dst = `R12_FIQ;
            8'b00011101: dst = `R13_FIQ;
            8'b00011110: dst = `R14_FIQ;
            // SVC
            8'b00111101: dst = `R13_SVC;
            8'b00111110: dst = `R14_SVC;
            // ABT
            8'b01111101: dst = `R13_ABT;
            8'b01111110: dst = `R14_ABT;
            // IRQ
            8'b00101101: dst = `R13_IRQ;
            8'b00101110: dst = `R14_IRQ;
            // UND
            8'b10111101: dst = `R13_UND;
            8'b10111110: dst = `R14_UND;
            default: dst = {1'b0, addr};
        endcase
    end
endmodule
