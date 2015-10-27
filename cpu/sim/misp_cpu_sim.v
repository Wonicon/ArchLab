`timescale 1ns / 1ps

module mips_cpu_sim ();
reg clk;
reg reset;
wire [31:0] trap, pc_p, ir_p;

always #5 clk = ~clk;
always @(posedge clk) if (pc_p == 32'hf3c) $stop;
misp_cpu_top cpu (
    .clk(clk),
    .reset(reset),
    .pc_p(pc_p),
    .ir_p(ir_p)
);

initial begin
clk = 0;
reset = 0;
#5 reset = 1;
#5 reset = 0;
end

endmodule
