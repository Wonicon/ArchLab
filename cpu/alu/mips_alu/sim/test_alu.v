`timescale 1ns / 1ps

module test_alu();

reg [31:0] A_in;
reg [31:0] B_in;
reg [3:0] ALU_op;
wire Zero, Less, Overflow_out;
wire [31:0] ALU_out;

mips32_alu alu (
    .A_in(A_in),
    .B_in(B_in),
    .ALU_op(ALU_op),
    .Zero(Zero),
    .Less(Less),
    .Overflow_out(Overflow_out),
    .ALU_out(ALU_out)
);

integer i, j;
initial begin 
    for (i = 0; i < 16; i = i + 1) begin
        if (i != 12 && i != 13) begin
            ALU_op = i;
            for (j = 0; j < 10; j = j + 1) begin
                A_in = {$random};
                B_in = {$random};
                #10
                $display("===========================================================================>");
                $display("A_in = %dd = %bb", A_in, A_in);
                $display("B_in = %dd = %bb", B_in, B_in);
                $display("OP %b Zero %b Less %b OF %b", ALU_op, Zero, Less, Overflow_out);
                $display("ALU_out = %dd = %bb", ALU_out, ALU_out);
            end
        end
    end
end
endmodule
