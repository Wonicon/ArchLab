`timescale 1ns / 1ps
`include "common.vh"

module test_regfile();

reg [4:0] Rn_r_addr;
reg [4:0] Rm_r_addr;
reg [4:0] Rs_r_addr;
reg [4:0] Rd_r_addr;
reg [4:0] Rn_w_addr;
reg [4:0] Rd_w_addr;
reg [31:0] Rd_in;
reg [31:0] Rn_in;
reg [31:0] PC_in;
reg [31:0] CPSR_in;
reg [31:0] SPSR_in;
reg        CPSR_write_en;
reg        SPSR_write_en;
reg [3:0]  CPSR_byte_w_en;
reg [3:0]  SPSR_byte_w_en;
reg [3:0]  Rd_byte_w_en;
reg [3:0]  Rn_byte_w_en;
reg        Clk;
reg        Rst;
wire [31:0] Rn_out;
wire [31:0] Rm_out;
wire [31:0] Rs_out;
wire [31:0] Rd_out;
wire [31:0] PC_out;
wire [31:0] CPSR_out;
wire [31:0] SPSR_out;
wire [4:0]  Mode_out;

regfile registers
(
    .Rn_r_addr(Rn_r_addr),
    .Rm_r_addr(Rm_r_addr),
    .Rs_r_addr(Rs_r_addr),
    .Rd_r_addr(Rd_r_addr),
    .Rn_w_addr(Rn_w_addr),
    .Rd_w_addr(Rd_w_addr),

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

always
begin
    #5 Clk = ~Clk; // 10ns a cycle.
end

parameter test_const_1 = 32'habcddcba;
parameter test_const_2 = 32'hffffffff;
parameter test_const_3 = 32'hcccccccc;
parameter test_const_4 = 32'habababab;

initial
begin
    Clk = 1'b0;
    Rst = 1'b1; // Rst is low effective
    CPSR_write_en = 1'b1;
    SPSR_write_en = 1'b1;
    CPSR_byte_w_en = 0;
    SPSR_byte_w_en = 0;
    CPSR_in = 0;
    SPSR_in = 0;
    Rd_byte_w_en = 0;
    Rn_byte_w_en = 0;
    PC_in = test_const_3;

    Rn_r_addr = 0;
    Rm_r_addr = 0;
    Rs_r_addr = 0;
    Rd_r_addr = 1;
    Rd_w_addr = 1;
    Rd_in = test_const_2;
    
    // Write R13 with 32'habcddcba under USE.
    CPSR_in[4:0] = `USE;
    Rn_in = test_const_1;
    Rn_w_addr = 4'd13;
    Rn_r_addr = 4'd13;
    #15;
    
    // Write R13 with 32'ffffffff under SVC.
    CPSR_in[4:0] = `SVC;
    Rn_in = test_const_2;
    #15;

    // Read R13 from USE
    CPSR_in[4:0] = `USE;
    #15;

    $stop;
end

endmodule
