`timescale 1ns / 1ps

// 32 register of 32 bits
module register_mips4x4
#(parameter DATA_WIDTH=4, parameter ADDR_WIDTH=2)
(
    input [(ADDR_WIDTH-1):0] Rs_addr, Rt_addr, Rd_addr,
    input [(DATA_WIDTH-1):0] Rd_in,
    input [3:0] Rd_Byte_w_en,
    input clk,
    output [(DATA_WIDTH-1):0] Rs_out, Rt_out
);
    
    // Declare the register group variable
    reg [DATA_WIDTH-1:0] register[2**ADDR_WIDTH-1:0];
    integer i;
    integer reg_cnt;
    
    initial
    begin
        reg_cnt = 2**ADDR_WIDTH;
        for (i = 0; i < reg_cnt; i = i + 1)
            register[i] = 0;
    end
    
    always @ (negedge clk) begin
        // Write
        if (Rd_addr != 0) begin
            if (Rd_Byte_w_en[3] == 0) register[Rd_addr][3] <= Rd_in[3];
            if (Rd_Byte_w_en[2] == 0) register[Rd_addr][2] <= Rd_in[2];
            if (Rd_Byte_w_en[1] == 0) register[Rd_addr][1] <= Rd_in[1];
            if (Rd_Byte_w_en[0] == 0) register[Rd_addr][0] <= Rd_in[0];
        end
    end
    
    // Read
    assign Rs_out = register[Rs_addr];
    assign Rt_out = register[Rt_addr];
endmodule
