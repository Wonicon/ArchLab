`timescale 1ns / 1ps

module test_clz();

reg [31:0] in;
wire [5:0] cnt;
reg [5:0] expec;

clz z0 (
    .in(in),
    .cnt(cnt)
);

task CLZ;
    input [31:0] in;
    output [5:0] cnt;

    integer i;
    reg flag;
begin
    flag = 1;
    cnt = 0;
    for (i = 31; i >= 0; i = i - 1) begin
        if (in[i] == 1'b1) flag = 0;
        if (flag) cnt = cnt + 1;
    end
end

endtask

integer i;
wire [31:0] a, b;
assign b = 32'habcddcba;
assign a = b[31:16];
initial begin
    $display("a %b", a);
    for (i = 0; i < 100; i = i + 1) begin
        in = {$random};
        CLZ(in, expec);
        #10 if(cnt != expec) $display("ERR below!");
        $display("in %b cnt %d expec %d", in, cnt, expec);
        in = {$random} % (2**16);
        CLZ(in, expec);
        #10 if(cnt != expec) $display("ERR below!");
        $display("in %b cnt %d expec %d", in, cnt, expec);
    end
    
    in = 0;
    #10 $display("in %b cnt %d", in, cnt);
end

endmodule

