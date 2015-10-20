`timescale 1ns / 1ps
`define DATAWIDTH 8
`define DATAWIDTH_LOG 3

// 使用移位操作符来完成以为操作，生成的RTL图中，每个移位操作符产生了一个对应的
// RLT_LSHIFT或RTL_RSHIFT，同时为了方便符号位扩展和循环移位，将对应的输入扩大
// 到16位。按权移位的写法主要部件是大入扇数（8位 x 4）的选择器，不知道和移位器
// 相比哪个性能更优？

module mips_shift_with_shift_operator
#(parameter DATA_WIDTH = `DATAWIDTH, parameter AMOUNT_WIDTH = `DATAWIDTH_LOG)
(
    input [1:0] shift_op,
    input [AMOUNT_WIDTH - 1 : 0] shift_amount,
    input [DATA_WIDTH - 1 : 0] shift_in,
    output reg [DATA_WIDTH - 1 : 0] shift_out
);

always @(shift_op or shift_in or shift_amount)
begin
    case (shift_op)
        // Logic shift left
        2'b00: shift_out = shift_in << shift_amount;
        // Logic shift right
        2'b01: shift_out = shift_in >> shift_amount;
        // Arithmetic shift right
        2'b10: shift_out = {{{DATA_WIDTH{shift_in[DATA_WIDTH - 1]}}, shift_in} >> shift_amount}[DATA_WIDTH - 1 : 0];
        // Rotate shift right
        2'b11: shift_out = {{2{shift_in}} >> shift_amount}[DATA_WIDTH - 1 : 0];
    endcase
end

endmodule
