`timescale 1ns / 1ps

// 32 register of 32 bits
module register_mips32
#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=5)
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
            if (Rd_Byte_w_en[3] == 0) register[Rd_addr][31:24] <= Rd_in[31:24];
            if (Rd_Byte_w_en[2] == 0) register[Rd_addr][23:16] <= Rd_in[23:16];
            if (Rd_Byte_w_en[1] == 0) register[Rd_addr][15:8] <= Rd_in[15:8];
            if (Rd_Byte_w_en[0] == 0) register[Rd_addr][7:0] <= Rd_in[7:0];
        end
    end
    
    // Read
    assign Rs_out = register[Rs_addr];
    assign Rt_out = register[Rt_addr];
endmodule
