`timescale 1ns / 1ps

module test_ctrl();

reg [3:0] ALU_op;
wire [2:0] ALU_ctr;
reg [2:0] ctrl;

mips32_alu_ctrl c0 (
    .ALU_op(ALU_op),
    .ALU_ctr(ALU_ctr)
);

task ctrl_truth_table;
    input [3:0] op;
    output [2:0] ctrl;
begin
    case (op)
        4'b0000: ctrl = 3'b111;
        4'b0001: ctrl = 3'b111;
        4'b0010: ctrl = 3'b000;
        4'b0011: ctrl = 3'b000;
        4'b0100: ctrl = 3'b100;
        4'b0101: ctrl = 3'b101;
        4'b0110: ctrl = 3'b010;
        4'b0111: ctrl = 3'b101;
        4'b1000: ctrl = 3'b011;
        4'b1001: ctrl = 3'b001;
        4'b1010: ctrl = 3'b110;
        4'b1011: ctrl = 3'b110;
        4'b1110: ctrl = 3'b111;
        4'b1111: ctrl = 3'b111;
    endcase
end
endtask

integer i;
initial begin
    for (i = 0; i < 16; i = i + 1) begin
        ALU_op = i;
        ctrl_truth_table(ALU_op, ctrl);
        #10 if (ctrl != ALU_ctr && !(ALU_op[3] & ALU_op[2] & ~ALU_op[1])) $display("ERR: op %b ctrl %b expected %b", ALU_op, ALU_ctr, ctrl);
    end
end
endmodule

