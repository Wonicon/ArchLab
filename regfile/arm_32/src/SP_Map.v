`timescale 1ns / 1ps
`include "common.vh"

module SR_Map (
    input [4:0] mode,
    output reg [2:0] dst
    );

    always @(mode)
    begin
        $display("SP_MAP MODE: %x", mode);
        case (mode)
            `FIQ: dst = `SPSR_FIQ;
            `SVC: dst = `SPSR_SVC;
            `ABT: dst = `SPSR_ABT;
            `IRQ: dst = `SPSR_IRQ;
            `UND: dst = `SPSR_UND;
            default: dst = `CPSR;
        endcase
    end

endmodule
