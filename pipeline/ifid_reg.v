`timescale 1ns / 1ps

/**
 * ifid 流水段寄存器
 * pc + 4直接实现在内部了
 */
 `define PC_WIDTH 32
 `define INSTR_WIDTH 32
`define PC_BUS 31:0
`define DATA_BUS 31:0
`define JMP_SLICE 25:0
`define RS_SLICE 25:21
`define RT_SLICE 20:16
`define RD_SLICE 15:11
module ifid_reg (
    input clk,
    input reset,
    input cu_stall,
    input cu_flush,
    input [`PC_BUS] pc,
    input [`DATA_BUS] instr,
    output reg [`PC_BUS] ifid_pc,
    output reg [`PC_BUS] ifid_pc_4,
    output reg [`DATA_BUS] ifid_instr
    );

    initial begin
        ifid_pc = `PC_WIDTH'd0;
        ifid_pc_4 = `PC_WIDTH'd4;
        ifid_instr <= `PC_WIDTH'd0;
    end
    
    always @(negedge clk or posedge reset) begin
        if (reset || cu_flush) begin
            ifid_pc <= `PC_WIDTH'd0;
            ifid_pc_4 <= `PC_WIDTH'd4;
            ifid_instr <= `PC_WIDTH'd0;
        end
        else if (cu_stall) begin
            ifid_pc <= ifid_pc;
            ifid_pc_4 <= ifid_pc_4;
            ifid_instr <= ifid_instr;
        end
        else begin
            ifid_pc <= pc;
            ifid_pc_4 <= pc + 4;
            ifid_instr <= instr;
        end
    end

endmodule
