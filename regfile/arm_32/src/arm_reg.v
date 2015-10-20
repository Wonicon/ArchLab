`timescale 1ns / 1ps
`include "common.vh"

module arm_reg
#(
    parameter DATA_WIDTH = 32,
    parameter BYTES = (DATA_WIDTH / 8),
    parameter ADDR_WIDTH = 4,
    parameter SR_ADDR_WIDTH = 3,
    parameter MODE_WIDTH = 5
)
(
    input [ADDR_WIDTH - 1:0] Rn_r_addr,
    input [ADDR_WIDTH - 1:0] Rm_r_addr,
    input [ADDR_WIDTH - 1:0] Rs_r_addr,
    input [ADDR_WIDTH - 1:0] Rd_r_addr,
    input [ADDR_WIDTH - 1:0] Rn_w_addr,
    input [ADDR_WIDTH - 1:0] Rd_w_addr,

    input [DATA_WIDTH - 1:0] Rd_in,
    input [DATA_WIDTH - 1:0] Rn_in,
    input [DATA_WIDTH - 1:0] PC_in,
    input [DATA_WIDTH - 1:0] CPSR_in,
    input [DATA_WIDTH - 1:0] SPSR_in,

    input CPSR_write_en,
    input SPSR_write_en,

    input [BYTES - 1:0] CPSR_byte_w_en,
    input [BYTES - 1:0] SPSR_byte_w_en,
    input [BYTES - 1:0] Rd_byte_w_en,
    input [BYTES - 1:0] Rn_byte_w_en,

    input Clk,
    input Rst,

    output [DATA_WIDTH - 1:0] Rn_out,
    output [DATA_WIDTH - 1:0] Rm_out,
    output [DATA_WIDTH - 1:0] Rs_out,
    output [DATA_WIDTH - 1:0] Rd_out,
    output [DATA_WIDTH - 1:0] PC_out,
    output [DATA_WIDTH - 1:0] CPSR_out,
    output [DATA_WIDTH - 1:0] SPSR_out,
    output [4:0] Mode_out
);

wire [ADDR_WIDTH : 0] map_rn_addr;
wire [ADDR_WIDTH : 0] map_rm_addr;
wire [ADDR_WIDTH : 0] map_rs_addr;
wire [ADDR_WIDTH : 0] map_rd_addr;
wire [ADDR_WIDTH : 0] map_rd_w_addr;
wire [ADDR_WIDTH : 0] map_rn_w_addr;
wire [SR_ADDR_WIDTH - 1:0] SR_addr;

wire [MODE_WIDTH - 1:0] mode;
assign mode = CPSR_out[MODE_WIDTH - 1:0];

Address_Map map_rn
(
    .addr(Rn_r_addr),
    .mode(mode),
    .dst(map_rn_addr)
);

Address_Map map_rm
(
    .addr(Rm_r_addr),
    .mode(mode),
    .dst(map_rm_addr)
);

Address_Map map_rs
(
    .addr(Rs_r_addr),
    .mode(mode),
    .dst(map_rs_addr)
);

Address_Map map_rd
(
    .addr(Rd_r_addr),
    .mode(mode),
    .dst(map_rd_addr)
);

Address_Map map_rd_w
(
    .addr(Rd_w_addr),
    .mode(mode),
    .dst(map_rd_w_addr)
);

Address_Map map_rn_w
(
    .addr(Rn_w_addr),
    .mode(mode),
    .dst(map_rn_w_addr)
);

SR_Map map_sr
(
    .mode(mode),
    .dst(SR_addr)
);

regfile registers
(
    .Rn_r_addr(map_rn_addr),
    .Rm_r_addr(map_rm_addr),
    .Rs_r_addr(map_rs_addr),
    .Rd_r_addr(map_rd_addr),
    .Rn_w_addr(map_rn_w_addr),
    .Rd_w_addr(map_rd_w_addr),
    .SR_addr(SR_addr),

    .Rd_in(Rd_in),
    .Rn_in(Rn_in),
    .PC_in(PC_in),
    .CPSR_in(CPSR_in),
    .SPSR_in(SPSR_in),

    .CPSR_write_en(CPSR_write_en),
    .SPSR_write_en(SPSR_write_en),

    .CPSR_byte_w_en(CPSR_byte_w_en),
    .SPSR_byte_w_en(SPSR_byte_w_en),
    .Rd_byte_w_en(Rd_byte_w_en),
    .Rn_byte_w_en(Rn_byte_w_en),

    .Clk(Clk),
    .Rst(Rst),

    .Rn_out(Rn_out),
    .Rm_out(Rm_out),
    .Rs_out(Rs_out),
    .Rd_out(Rd_out),
    .PC_out(PC_out),
    .CPSR_out(CPSR_out),
    .SPSR_out(SPSR_out),
    .Mode_out(Mode_out)
);

endmodule
