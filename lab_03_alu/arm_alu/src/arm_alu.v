`timescale 1ns / 1ps

module arm_alu #(parameter DATAWIDTH = 32) (
    input [DATAWIDTH-1:0] A_in,
    input [DATAWIDTH-1:0] B_in,
    input [3:0] ALU_op,
    input Cin,
    output reg [DATAWIDTH-1:0] ALU_out,
    output Negative,
    output Zero,
    output Carry,
    output Overflow
);

reg Cin_mod;
wire [3:0] OP_mod;
assign OP_mod = {ALU_op[3], ~ALU_op[2], ALU_op[1:0]};
wire [DATAWIDTH-1:0] A_mod_en, B_mod_en, Cin_mod_en, A_mod, B_mod;
assign A_mod_en = {DATAWIDTH{~ALU_op[3] & ALU_op[1] & ALU_op[0]}}; // A neg when 0111 0011 but can't 1011
assign B_mod_en = {DATAWIDTH{ALU_op[1] & ~ALU_op[0]}}; // B neg when 0010 0110 1010 and 1110 don't care
assign A_mod = A_in ^ A_mod_en;
assign B_mod = B_in ^ B_mod_en;

always @(OP_mod or Cin or OP_mod) begin
    if (~|OP_mod[3:2] & |OP_mod[1:0]) Cin_mod = Cin; // 0101, 0110, 0111, cin can always be cin
    else Cin_mod = (|OP_mod) & ~(&OP_mod);  // not 0100 or 1011, cin can always be 1
end


wire [DATAWIDTH-1:0] AND_out, EOR_out, OR_out, CAL_out, BIC_MVN_out, AND_EOR_out, OR_MOV_out;
assign AND_out = A_in & B_in;
assign EOR_out = A_in ^ B_in;
assign OR_out = A_in | B_in;
assign {Carry, CAL_out} = A_mod + B_mod + Cin_mod;
assign BIC_MVN_out = ({DATAWIDTH{ALU_op[0]}} | A_in) & ~B_in;
assign AND_EOR_out = ALU_op[0] ? EOR_out : AND_out;
assign OR_MOV_out = ALU_op[0] ? A_in : OR_out;

always @(ALU_op or CAL_out or BIC_MVN_out or AND_EOR_out) begin
    casex (ALU_op[3:1])
        3'bx00: ALU_out = AND_EOR_out;
        3'b110: ALU_out = OR_MOV_out;
        3'b111: ALU_out = BIC_MVN_out;
        default: ALU_out = CAL_out;
    endcase
end

assign Zero = ~|ALU_out;
assign Negative = ALU_out[DATAWIDTH-1];
assign Overflow = (!ALU_out[DATAWIDTH-1] & A_mod[DATAWIDTH-1] & B_mod[DATAWIDTH-1]) |
    (ALU_out[DATAWIDTH-1] & !A_mod[DATAWIDTH-1] & !B_mod[DATAWIDTH-1]);

endmodule
