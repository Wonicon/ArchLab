`timescale 1ns / 1ps

module top (
    input [15:0] sw,
    output [15:0] led
);

arm_shift_32 #(.DATA_WIDTH(8)) s0 (
    .carry_in(sw[15]),
    .shift_in(sw[13:6]),
    .shift_amount(sw[4:2]),
    .shift_op(sw[1:0]),
    .shift_out(led[7:0]),
    .carry_out(led[15])
);

assign led[14:8] = 0;

endmodule
