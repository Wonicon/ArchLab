`timescale 1ns / 1ps

module top(
    input [12:0] sw,
    output [7:0] led
    );
    
    mips8_shift shift (
        .shift_in(sw[12:5]),
        .shift_amount(sw[4:2]),
        .shift_op(sw[1:0]),
        .shift_out(led)
    );
endmodule
