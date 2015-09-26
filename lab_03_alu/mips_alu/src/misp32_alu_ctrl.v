`timescale 1ns / 1ps

module mips32_alu_ctrl (
    input [3:0] ALU_op,
    output [2:0] ALU_ctr
);

assign ALU_ctr[2] = (!ALU_op[3] & !ALU_op[1]) | (!ALU_op[3] & ALU_op[2] & ALU_op[0]) | (ALU_op[3] & ALU_op[1]);
assign ALU_ctr[1] = (!ALU_op[3] & !ALU_op[2] & !ALU_op[1]) | (ALU_op[3] & !ALU_op[2] & !ALU_op[0]) | (ALU_op[2] & ALU_op[1] & !ALU_op[0]) | (ALU_op[3] & ALU_op[1]);
assign ALU_ctr[0] = (!ALU_op[2] & !ALU_op[1]) | (!ALU_op[3] & ALU_op[2] & ALU_op[0]) | (ALU_op[3] & ALU_op[2] & ALU_op[1]);

endmodule

