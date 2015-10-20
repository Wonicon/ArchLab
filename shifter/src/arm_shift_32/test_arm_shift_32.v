`timescale 1ns / 1ps

module test_arm_shift_32 ();

reg carry_in;
reg [31:0] shift_in;
reg [4:0] shift_amount;
reg [1:0] shift_op;
wire carry_out;
wire carry_out_behave;
wire [31:0] shift_out;
wire [31:0] shift_out_behave;

arm_shift_32 s0 (
    .carry_in(carry_in),
    .shift_in(shift_in),
    .shift_amount(shift_amount),
    .shift_op(shift_op),
    .shift_out(shift_out),
    .carry_out(carry_out)
);

arm_shift_32_behave s1 (
    .carry_in(carry_in),
    .shift_in(shift_in),
    .shift_amount(shift_amount),
    .shift_op(shift_op),
    .shift_out(shift_out_behave),
    .carry_out(carry_out_behave)
);

`define LSL 2'b00
`define LSR 2'b01
`define ASR 2'b10
`define ROR 2'b11

task LOG;
    input [31:0] shift_in;
    input carry_in;
    input [1:0] op;
    input [4:0] amount;
    input [31:0] shift_out;
    input carry_out;
    input [31:0] exp;
    input exp_c;

    reg[63:0] mode;
    begin
        #10;
        case (op)
            2'b00: mode = "LSL";
            2'b01: if (amount == 0) mode = "LSR#0"; else mode = "LSR";
            2'b10: if (amount == 0) mode = "ASR#0"; else mode = "ASR";
            2'b11: if (amount == 0) mode = "RXX";   else mode = "ROR";
        endcase
        $display("输入 %b %x 模式 %s 位移量 %d", carry_in, shift_in, mode, amount);
        $display("期望 %x cout %b", exp, exp_c);
        $display("结果 %x cout %b", shift_out, carry_out);
        #10;
    end
    
endtask

`define log(x, y)\
#10 LOG(shift_in, carry_in, shift_op, shift_amount, shift_out, carry_out, (x), (y))

integer mode, offset;
reg isERR;
initial
begin
    shift_in = 32'habcdefab;
    carry_in = 1'b1;
    isERR = 1'b0;
    for (mode = 0; mode < 4; mode = mode + 1) begin
        for (offset = 0; offset < 32; offset = offset + 1) begin
            shift_op = mode;
            shift_amount = offset;
            #10
            if (shift_out != shift_out_behave || carry_out != carry_out_behave) begin
                isERR = 1'b1;
                `log(shift_out_behave, carry_out_behave);
            end
        end
    end
    if (!isERR) begin
        $display("Clear");
    end
    $stop;
end

endmodule
