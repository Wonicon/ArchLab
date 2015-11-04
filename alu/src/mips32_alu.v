`timescale 1ns / 1ps

module mips32_alu #(parameter DATAWIDTH = 32, SEB = 0, SEH = 1, WIDTH = $clog2(DATAWIDTH)) (
    input [3:0] ALU_op,
    input [DATAWIDTH - 1:0] A_in,
    input [DATAWIDTH - 1:0] B_in,
    output Zero,
    output Less,
    output Overflow_out,
    output reg [DATAWIDTH - 1:0] ALU_out
);

wire Negative, Overflow, Carry;
wire [DATAWIDTH - 1:0] Adder_out;

mips32_adder adder (
    .A_in(A_in),
    .B_in(B_in ^ {DATAWIDTH{ALU_op[0]}}),
    .Cin(ALU_op[0]),
    .Zero(Zero),
    .Negative(Negative),
    .Overflow(Overflow),
    .Carry(Carry),
    .O_out(Adder_out)
);

// Oerflow out
assign Overflow_out = &{ALU_op[3:1], Overflow};

// Less SLT SLTI SLTU SLTIU
wire less_out, less_sw;
assign less_sw = ~ALU_op[3] & ALU_op[2] & ALU_op[1] & ALU_op[0];
assign Less = less_sw ? ~Carry : (Overflow ^ Negative);
assign less_out = Less ? 32'd1 : 32'd0;

// seb and seh
reg [DATAWIDTH - 1:0] sign_extend;
always @(ALU_op or B_in) begin
    case (ALU_op[0])
    SEB: sign_extend = {{(DATAWIDTH - DATAWIDTH / 4){B_in[DATAWIDTH / 4 - 1]}}, B_in[DATAWIDTH / 4 - 1:0]};
    SEH: sign_extend = {{(DATAWIDTH - DATAWIDTH / 2){B_in[DATAWIDTH / 2 - 1]}}, B_in[DATAWIDTH / 2 - 1:0]}; 
    endcase
end

// AND OR XOR NOR
wire [DATAWIDTH - 1:0] and_out, or_out, xor_out, nor_out;
assign and_out = A_in & B_in;
assign or_out = A_in | B_in;
assign xor_out = A_in ^ B_in;
assign nor_out = ~or_out;

wire [DATAWIDTH - 1:0] cntlz;
clz z0 (
    .in(A_in ^ {DATAWIDTH{ALU_op[0]}}),
    .cnt(cntlz)
);

wire [2:0] ALU_ctr;

mips32_alu_ctrl c0 (
    .ALU_op(ALU_op),
    .ALU_ctr(ALU_ctr)
);

always @(ALU_ctr or cntlz or and_out or or_out or xor_out or nor_out or Adder_out or sign_extend or less_out) begin
    case (ALU_ctr)
       3'd0: ALU_out = cntlz;
       3'd1: ALU_out = xor_out;
       3'd2: ALU_out = or_out;
       3'd3: ALU_out = nor_out;
       3'd4: ALU_out = and_out;
       3'd5: ALU_out = less_out;
       3'd6: ALU_out = sign_extend;
       3'd7: ALU_out = Adder_out;
    endcase
end

endmodule
