`timescale 1ns / 1ps
`include "common.vh"

module test_arm();

reg [3:0] Rn_r_addr;
reg [3:0] Rm_r_addr;
reg [3:0] Rs_r_addr;
reg [3:0] Rd_r_addr;
reg [3:0] Rn_w_addr;
reg [3:0] Rd_w_addr;
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

arm_reg arm(/*autoinst*/
    .Rn_r_addr                  (Rn_r_addr[3:0]    ),
    .Rm_r_addr                  (Rm_r_addr[3:0]    ),
    .Rs_r_addr                  (Rs_r_addr[3:0]    ),
    .Rd_r_addr                  (Rd_r_addr[3:0]    ),
    .Rn_w_addr                  (Rn_w_addr[3:0]    ),
    .Rd_w_addr                  (Rd_w_addr[3:0]    ),
    .Rd_in                      (Rd_in[31:0]        ),
    .Rn_in                      (Rn_in[31:0]        ),
    .PC_in                      (PC_in[31:0]        ),
    .CPSR_in                    (CPSR_in[31:0]      ),
    .SPSR_in                    (SPSR_in[31:0]      ),
    .CPSR_write_en              (CPSR_write_en                  ),
    .SPSR_write_en              (SPSR_write_en                  ),
    .CPSR_byte_w_en             (CPSR_byte_w_en    ),
    .SPSR_byte_w_en             (SPSR_byte_w_en    ),
    .Rd_byte_w_en               (Rd_byte_w_en      ),
    .Rn_byte_w_en               (Rn_byte_w_en      ),
    .Clk                        (Clk                            ),
    .Rst                        (Rst                            ),
    .Rn_out                     (Rn_out[31:0]       ),
    .Rm_out                     (Rm_out[31:0]       ),
    .Rs_out                     (Rs_out[31:0]       ),
    .Rd_out                     (Rd_out[31:0]       ),
    .PC_out                     (PC_out[31:0]       ),
    .CPSR_out                   (CPSR_out[31:0]     ),
    .SPSR_out                   (SPSR_out[31:0]     ),
    .Mode_out                   (Mode_out[4:0]                  )
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
    CPSR_write_en = 0;
    SPSR_write_en = 0;
    CPSR_byte_w_en = 4'b0000;
    SPSR_byte_w_en = 4'b0000;
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
    #5 CPSR_in[4:0] = `USE;
    #5 Rn_in = test_const_1;
    #5 Rn_w_addr = 4'd13;
    #5 Rn_r_addr = 4'd13;
    
    // Write R13 with 32'ffffffff under SVC.
    #5 CPSR_in[4:0] = `SVC;
    #5 Rn_in = test_const_2;

    // Read R13 from USE
    #5 CPSR_in[4:0] = `USE;
    #5 Rn_w_addr = 0; // Otherwise the R13 will be overrite.

    // Write R9 under FIQ
    #5 CPSR_in[4:0] = `FIQ;
    #5 Rn_in = 13;
    #5 Rn_w_addr = 9;
    #5 Rn_r_addr = 9;

    // Write R9 under IRQ
    #5 CPSR_in[4:0] = `IRQ;
    #5 Rn_in = 22;

    // Check R9 under FIQ.
    #5 CPSR_in[4:0] = `FIQ;
    #5 Rn_w_addr = 8; // Prevent overwriting.

    #15 $stop;
end

endmodule
