`timescale 1ns / 1ps
`include "common.vh"

module regfile 
#(
    parameter DATA_WIDTH = 32,
    parameter BYTES = (DATA_WIDTH / 8),
    parameter GPR_CNT = 31,
    parameter ADDR_WIDTH = 5,
    parameter SR_CNT = 6,
    parameter SP_ADDR_WIDTH = 3,
    parameter MODE_WIDTH = 5
)
(
    // Common
    input Clk,
    input Rst,

    // Addresses
    input [ADDR_WIDTH - 1:0] Rn_r_addr,
    input [ADDR_WIDTH - 1:0] Rm_r_addr,
    input [ADDR_WIDTH - 1:0] Rs_r_addr,
    input [ADDR_WIDTH - 1:0] Rd_r_addr,
    input [ADDR_WIDTH - 1:0] Rn_w_addr,
    input [ADDR_WIDTH - 1:0] Rd_w_addr,
    input [SP_ADDR_WIDTH - 1:0] SR_addr,

    // Input data
    input [DATA_WIDTH - 1:0] Rd_in,
    input [DATA_WIDTH - 1:0] Rn_in,
    input [DATA_WIDTH - 1:0] PC_in,
    input [DATA_WIDTH - 1:0] CPSR_in,
    input [DATA_WIDTH - 1:0] SPSR_in,

    // High effective enables
    input CPSR_write_en,
    input SPSR_write_en,
    // Low effective enables
    input [BYTES - 1:0] CPSR_byte_w_en,
    input [BYTES - 1:0] SPSR_byte_w_en,
    input [BYTES - 1:0] Rd_byte_w_en,
    input [BYTES - 1:0] Rn_byte_w_en,

    // Outputs
    output [DATA_WIDTH - 1:0] Rn_out,
    output [DATA_WIDTH - 1:0] Rm_out,
    output [DATA_WIDTH - 1:0] Rs_out,
    output [DATA_WIDTH - 1:0] Rd_out,
    output [DATA_WIDTH - 1:0] PC_out,
    output [DATA_WIDTH - 1:0] CPSR_out,
    output [DATA_WIDTH - 1:0] SPSR_out,
    output [MODE_WIDTH - 1:0] Mode_out
    );


    // General purpose registers
    reg [DATA_WIDTH - 1:0] gpr[GPR_CNT - 1:0];
    // State registers
    reg [DATA_WIDTH - 1:0] sr[SR_CNT - 1:0];

    reg pre_rst; // Record the previous level of Rst
    integer i;   // Iterating index

    // Assign all registers to 0
    // Otherwise the compiler will connect some ports to ground.
    initial
    begin
        pre_rst = 1'b1;
        for (i = 0; i < GPR_CNT; i = i + 1)
            gpr[i] = 0;
        for (i = 0; i < SR_CNT; i = i + 1)
            sr[i] = 0;
    end

    // Writing block
    always @(negedge Clk)
    begin
        $display("Current Mode %b, Next Mode %b", sr[`CPSR][MODE_WIDTH - 1:0], CPSR_in[MODE_WIDTH - 1:0]);

        // Write Rd
        $display("Rd_w_addr is %x write %x", Rd_w_addr, Rd_in);
        if (Rd_byte_w_en[3] == 1'b0) gpr[Rd_w_addr][31:24] <= Rd_in[31:24];
        if (Rd_byte_w_en[2] == 1'b0) gpr[Rd_w_addr][23:16] <= Rd_in[23:16];
        if (Rd_byte_w_en[1] == 1'b0) gpr[Rd_w_addr][15:8]  <= Rd_in[15:8];
        if (Rd_byte_w_en[0] == 1'b0) gpr[Rd_w_addr][7:0]   <= Rd_in[7:0];

        // Write Rn
        $display("Rn_w_addr is %x write %x", Rn_w_addr, Rn_in);
        if (Rn_byte_w_en[3] == 1'b0) gpr[Rn_w_addr][31:24] <= Rn_in[31:24];
        if (Rn_byte_w_en[2] == 1'b0) gpr[Rn_w_addr][23:16] <= Rn_in[23:16];
        if (Rn_byte_w_en[1] == 1'b0) gpr[Rn_w_addr][15:8]  <= Rn_in[15:8];
        if (Rn_byte_w_en[0] == 1'b0) gpr[Rn_w_addr][7:0]   <= Rn_in[7:0];

        // Write CPSR
        if (CPSR_write_en == 1'b0)
        begin
            $display("Writing CPSR");
            if (CPSR_byte_w_en[3] == 1'b0) begin $display("BYTE"); sr[`CPSR][31:24] <= CPSR_in[31:24]; end
            if (CPSR_byte_w_en[2] == 1'b0) sr[`CPSR][23:16] <= CPSR_in[23:16];
            if (CPSR_byte_w_en[1] == 1'b0) sr[`CPSR][15:8]  <= CPSR_in[15:8];
            if (CPSR_byte_w_en[0] == 1'b0) sr[`CPSR][7:0]   <= CPSR_in[7:0];
            $display("CPSR %x", sr[`CPSR]);
        end

        // Write SPSR
        if (SPSR_write_en == 1'b0)
        begin
            $display("Writing SPSR");
            if (SPSR_byte_w_en[3] == 1'b0) sr[SR_addr][31:24] <= SPSR_in[31:24];
            if (SPSR_byte_w_en[2] == 1'b0) sr[SR_addr][23:16] <= SPSR_in[23:16];
            if (SPSR_byte_w_en[1] == 1'b0) sr[SR_addr][15:8]  <= SPSR_in[15:8];
            if (SPSR_byte_w_en[0] == 1'b0) sr[SR_addr][7:0]   <= SPSR_in[7:0];
        end

        // Write PC
        gpr[`PC] <= PC_in;

        // Rst recover
        pre_rst <= Rst;
        if (!pre_rst && Rst)
        begin
            $display("Reset recovering");
            gpr[`R14_SVC] <= gpr[`PC];
            sr[`SPSR_SVC] <= sr[`CPSR];
            sr[`CPSR][4:0] <= 5'b10011; // SVC
            sr[`CPSR][7] <= 1'b1;       // Set I
            sr[`CPSR][6] <= 1'b1;       // Set F
            sr[`CPSR][5] <= 1'b0;       // Clear T
            gpr[`PC] <= 0;
        end
    end

    // Outputs
    assign Rn_out = gpr[Rn_r_addr];
    assign Rm_out = gpr[Rm_r_addr];
    assign Rs_out = gpr[Rs_r_addr];
    assign Rd_out = gpr[Rd_r_addr];
    assign PC_out = gpr[`PC];

    assign Mode_out = sr[`CPSR][MODE_WIDTH - 1:0];
    assign CPSR_out = sr[`CPSR];
    assign SPSR_out = sr[SR_addr];

endmodule
