`ifndef __COMMON_H__
`define __COMMON_H__

`define USE  5'b10000
`define FIQ  5'b10001
`define IRQ  5'b10010
`define SVC  5'b10011
`define ABT  5'b10111
`define UND  5'b11011
`define SYS  5'b11111

`define R0       5'd0
`define R1       5'd1
`define R2       5'd2
`define R3       5'd3
`define R4       5'd4
`define R5       5'd5
`define R6       5'd6
`define R7       5'd7
`define R8       5'd8
`define R9       5'd9
`define R10      5'd10
`define R11      5'd11
`define R12      5'd12
`define R13      5'd13
`define R14      5'd14
`define R15      5'd15
`define R8_FIQ   5'd16
`define R9_FIQ   5'd17
`define R10_FIQ  5'd18
`define R11_FIQ  5'd19
`define R12_FIQ  5'd20
`define R13_FIQ  5'd21
`define R14_FIQ  5'd22
`define R13_SVC  5'd23
`define R14_SVC  5'd24 
`define R13_ABT  5'd25
`define R14_ABT  5'd26
`define R13_IRQ  5'd27
`define R14_IRQ  5'd28
`define R13_UND  5'd29
`define R14_UND  5'd30

`define PC       5'd15

`define CPSR      3'd0
`define SPSR_FIQ  3'd1
`define SPSR_SVC  3'd2
`define SPSR_ABT  3'd3
`define SPSR_IRQ  3'd4
`define SPSR_UND  3'd5

`endif
