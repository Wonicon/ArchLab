`timescale 1ns / 1ps

module QM (
    input [3:0] addr,
    input [4:0] mode,
    output [4:0] dst
    );

    wire a, b, c, d, e, f, g;
    wire na, nb, nc, nd, ne, nf, ng;
    assign a = mode[3];
    assign b = mode[2];
    assign c = mode[1];
    assign d = mode[0];
    assign e = addr[2];
    assign f = addr[1];
    assign g = addr[0];
    assign na = ~a;
    assign nb = ~b;
    assign nc = ~c;
    assign nd = ~d;
    assign ne = ~e;
    assign nf = ~f;
    assign ng = ~g;

    wire a0, a1, a2, a3, a4;
    assign a0 = (na & nb & nc & d & ne) |
        (na & nb & nc & d & nf) |
        (na & nb & nc & d & ng) |
        (na & nb & c & e & nf & g) |
        (na & nb & c & e & f & ng) |
        (na & c & d & e & nf & g) |
        (na & c & d & e & f & ng) |
        (nb & c & d & e & nf & g) |
        (nb & c & d & e & f & ng);
    assign a1 = (na & nb & nd) | 
        (na & nb & e & f & g) |
        (a & c & d) | 
        (b & c & d) |
        (c & d & ne) |
        (c & d & f) | 
        (c & d & ng);
    assign a2 = (na & nb & nc & e) |
        (na & nb & nd & e & f) |
        (na & nb & e & f & g) |
        (a & c & d & e) |
        (nb & c & d & e & g) |
        (c & d & e & nf & ng) |
        (c & d & e & f & g);
    assign a3 = (na & nb & nc & f) |
        (na & nb & c & e & g) |
        (na & nb & ne & f) |
        (a & c & d & f) |
        (b & c & d & f);
    assign a4 = (na & nb & g) | (c & d & g);
    assign dst = addr[3] ? {a0,a1,a2,a3,a4} : {1'b0, addr};
endmodule
