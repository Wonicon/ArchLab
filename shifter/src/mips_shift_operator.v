`timescale 1ns / 1ps
`define DATAWIDTH 8
`define DATAWIDTH_LOG 3

// ʹ����λ�������������Ϊ���������ɵ�RTLͼ�У�ÿ����λ������������һ����Ӧ��
// RLT_LSHIFT��RTL_RSHIFT��ͬʱΪ�˷������λ��չ��ѭ����λ������Ӧ����������
// ��16λ����Ȩ��λ��д����Ҫ�����Ǵ���������8λ x 4����ѡ��������֪������λ��
// ����ĸ����ܸ��ţ�

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
