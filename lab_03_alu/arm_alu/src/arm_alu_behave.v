`timescale 1ns / 1ps

module arm_alu_behave #(parameter DATAWIDTH = 32) (
    input [DATAWIDTH - 1 : 0] A_in,
    input [DATAWIDTH - 1 : 0] B_in,
    input [3:0] ALU_op,
    input Cin,
    output reg [DATAWIDTH - 1 : 0] ALU_out,
    output Negative,
    output Zero,
    output Carry,
    output Overflow
);

parameter AND = 4'd0;
parameter EOR = 4'd1;
parameter SUB = 4'd2;
parameter RSB = 4'd3;
parameter ADD = 4'd4;
parameter ADC = 4'd5;
parameter SBC = 4'd6;
parameter RSC = 4'd7;
parameter TST = 4'd8;
parameter TEQ = 4'd9;
parameter CMP = 4'd10;
parameter CMN = 4'd11;
parameter ORR = 4'd12;
parameter MOV = 4'd13;
parameter BIC = 4'd14;
parameter MVN = 4'd15;


wire [DATAWIDTH - 1 : 0] AND_out, EOR_out, CAL_out, ORR_out, MOV_out, BIC_out, MVN_out;
reg [DATAWIDTH - 1 : 0] A_mod, B_mod;
reg Cin_mod;

assign AND_out = A_in & B_in;
assign EOR_out = A_in ^ B_in;
assign ORR_out = A_in | B_in;
assign {Carry, CAL_out} = A_mod + B_mod + Cin_mod;
assign MOV_out = B_in;
assign MVN_out = ~B_in;
assign BIC_out = A_in & MVN_out;
assign Negative = ALU_out[DATAWIDTH - 1];
assign Zero = !(|ALU_out);
assign Overflow = (~ALU_out[DATAWIDTH - 1] & A_in[DATAWIDTH - 1] & B_in[DATAWIDTH - 1]) |
    (ALU_out[DATAWIDTH - 1] & ~A_in[DATAWIDTH - 1] & ~B_in[DATAWIDTH - 1]);

/* A_mod = A_in or -A_in */
always @(ALU_op, A_in) begin
    case (ALU_op)
        SUB: A_mod = A_in;
        RSB: A_mod = ~A_in;
        ADD: A_mod = A_in;
        ADC: A_mod = A_in;
        SBC: A_mod = A_in;
        RSC: A_mod = ~A_in;
        CMP: A_mod = A_in;
        CMN: A_mod = A_in;
        default: A_mod = {DATAWIDTH{1'bx}};
    endcase
end

/* B_mod = B_in or -B_in */
always @(ALU_op, B_in, MVN_out) begin
    case (ALU_op)
        SUB: B_mod = MVN_out;
        RSB: B_mod = B_in;
        ADD: B_mod = B_in;
        ADC: B_mod = B_in;
        SBC: B_mod = MVN_out;
        RSC: B_mod = B_in;
        CMP: B_mod = MVN_out;
        CMN: B_mod = B_in;
        default: B_mod = {DATAWIDTH{1'bx}};
    endcase
end

/* Cin_mod = 0, 1 or Cin */
always @(ALU_op, Cin) begin
    case (ALU_op)
        SUB: Cin_mod = 1'b1;
        RSB: Cin_mod = 1'b1;
        ADD: Cin_mod = 1'b0;
        ADC: Cin_mod = Cin;
        SBC: Cin_mod = Cin;
        RSC: Cin_mod = Cin;
        CMP: Cin_mod = 1'b1;
        CMN: Cin_mod = 1'b0;
        default: Cin_mod = 1'bx;
    endcase
end

always @(ALU_op, AND_out, EOR_out, CAL_out, ORR_out, MOV_out, MVN_out) begin
    case (ALU_op)
        AND: ALU_out = AND_out;
        EOR: ALU_out = EOR_out;
        SUB: ALU_out = CAL_out;
        RSB: ALU_out = CAL_out;
        ADD: ALU_out = CAL_out;
        ADC: ALU_out = CAL_out;
        SBC: ALU_out = CAL_out;
        RSC: ALU_out = CAL_out;
        TST: ALU_out = AND_out;
        TEQ: ALU_out = EOR_out;
        CMP: ALU_out = CAL_out;
        CMN: ALU_out = CAL_out;
        ORR: ALU_out = ORR_out;
        MOV: ALU_out = MOV_out;
        BIC: ALU_out = BIC_out;
        MVN: ALU_out = MVN_out;
    endcase
end

endmodule
    
