`timescale 1ns / 1ps

module test_arm_alu();

parameter DATAWIDTH = 32;

reg [DATAWIDTH - 1 : 0] A_in, B_in;
reg Cin;
reg [3:0] ALU_op;

wire [DATAWIDTH - 1 : 0] arm_alu_out, arm_alu_behave_out;

arm_alu alu0 (
    .A_in(A_in),
    .B_in(B_in),
    .ALU_op(ALU_op),
    .Cin(Cin),
    .ALU_out(arm_alu_out)
);

arm_alu_behave alu1 (
    .A_in(A_in),
    .B_in(B_in),
    .ALU_op(ALU_op),
    .Cin(Cin),
    .ALU_out(arm_alu_behave_out)
);

integer i, j;
initial begin
    for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 10; j = j + 1) begin
            ALU_op = i;
            A_in = $random;
            B_in = $random;
            Cin = $random;
            #10
            if (arm_alu_out != arm_alu_behave_out) begin
                $display("Hit error: arm_alu_out %x", arm_alu_out);
                $display("    arm_alu_behave_out %x", arm_alu_behave_out);
                $display("                  A_in %x", A_in);
                $display("                  B_in %x", B_in);
                $display("                  OP: %b", ALU_op);
            end
        end
    end
end

endmodule
