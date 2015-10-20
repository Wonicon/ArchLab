`timescale 1ns / 1ps

module top(
    input [15:2] sw,
    input btnc,
    input clk,
    output [7:0] led
    );
    
    wire debounced_btn;
    
    btn_debounce db
    (
        .btn(btnc),
        .clk(clk),
        .out(debounced_btn)
    );
    
    register_mips4x4 reg_file
    (
        .clk(debounced_btn),
        .Rs_addr(sw[15:14]),
        .Rt_addr(sw[13:12]),
        .Rd_addr(sw[11:10]),
        .Rd_in(sw[9:6]),
        .Rd_Byte_w_en(sw[5:2]),
        .Rs_out(led[3:0]),
        .Rt_out(led[7:4])
    );
endmodule
