`timescale 1ns / 1ps

module test_mips_shift_32 ();

integer i;
reg [1:0] test_op [7:0];
reg [31:0] shift_in;
reg [4:0] shift_amount;
reg [1:0] shift_op;
wire [31:0] shift_out;

mips32_shift s0 (
    .shift_in(shift_in),
    .shift_amount(shift_amount),
    .shift_op(shift_op),
    .shift_out(shift_out)
);

initial
begin
    test_op[0] = 2'b00;
    test_op[1] = 2'b01;
    test_op[2] = 2'b10;
    test_op[3] = 2'b11;
    test_op[4] = 2'b10;
    test_op[5] = 2'b01;
    test_op[6] = 2'b11;
    test_op[7] = 2'b10;

    shift_in = 32'hcfcfcfcf;
    shift_amount = 0;
    shift_op = 0;

    for (i = 0; i < 7; i = i + 1)
    begin
        $display("loop %d", i);
        #5 shift_op = test_op[i];
        shift_amount = 4 * i;
        #5;
        case (shift_op)
            2'b00: $display("logic left %d", shift_amount);
            2'b01: $display("logic right %d", shift_amount);
            2'b10: $display("arithmetic right %d", shift_amount);
            2'b11: $display("rotate right %d", shift_amount);
        endcase
        $display("in %x out %x", shift_in, shift_out);
    end
end
endmodule
