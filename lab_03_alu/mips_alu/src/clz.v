`timescale 1ns / 1ps

module clz #(parameter DATAWIDTH = 32, WIDTH = $clog2(DATAWIDTH)) (
    input [DATAWIDTH - 1:0] in,
    output [DATAWIDTH - 1:0] cnt
);

wire [WIDTH:0] count;
wire [DATAWIDTH - 1:0] x [WIDTH - 1:0];
wire [DATAWIDTH - 1:0] n [WIDTH - 1:0];

// Binary search calc leading zero...
// int n = 32;
// unsigned y;
// y = x >> 16; if (y != 0) { n = n - 16; x = y; } --- 4
// y = x >> 8; if (y != 0) { n = n - 8; x = y; }   --- 3
// y = x >> 4; if (y != 0) { n = n - 4; x = y; }   --- 2
// y = x >> 2; if (y != 0) { n = n - 2; x = y; }   --- 1
// y = x >> 1; if (y != 0) return n - 2;           --- 0
// return n - x;

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin
        if (i == WIDTH - 1) begin
            assign x[i] = in[DATAWIDTH - 1 : 2**i];
            assign count[i] = !(x[i] == 0);
            assign n[i-1] = (x[i] == 0) ? in[2**i - 1 : 0] : x[i]; 
        end
        else if (i == 0) begin
            assign x[i] = n[i][2**(i+1) - 1 : 2**i];
            assign count[i] = !(x[i] == 0);
        end
        else begin
            assign x[i] = n[i][2**(i+1) - 1 : 2**i];
            assign count[i] = !(x[i] == 0);
            assign n[i - 1] = (x[i] == 0) ? n[i][2**i - 1 : 0] : x[i];
        end
    end
endgenerate

assign count[WIDTH] = 1'b1;
assign cnt = (in == 0) ? 6'd32 : ~count;

endmodule

