`timescale 1ns / 1ps
`include "common.vh"

module test_Address_Map();

reg [3:0] addr;
reg [4:0] mode;
wire [4:0] out;

reg [4:0] i;

//Address_Map m0
QM m0
(
    .addr(addr),
    .mode(mode),
    .dst(out)
);

initial
begin
    $display("Hello\n");
    mode = `SYS;
    for (i = 0; i < 16; i = i + 1)
    begin
        addr = i[3:0];
        // This delay is necessary, at the out signal cannot reflect the change at once.
        #5
        if (out[4:0] == i[4:0]) $display("Corret SYS ");
        #5;
    end

    $display("Test USE");
    mode = `USE;
    for (i = 0; i < 16; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == i) $display("Correct USE ", i);
        #5;
    end

    mode = `FIQ;
    for (i = 0; i < 8; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == i) $display("Correct FIQ ", i);
        #5;
    end
    for (i = 8; i < 15; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == (i + `R8_FIQ - `R8)) $display("Correct FIQ spec ", i);
        #5;
    end
    addr = 15;
    #5;
    if (out == `R15) $display("Correct FIQ PC");
    #5;

    mode = `SVC;
    for (i = 0; i < 13; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == i) $display("Correct SVC ", i);
        #5;
    end
    for (i = 13; i < 15; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == (i + `R13_SVC - `R13)) $display("Correct SVC spec ", i);
        #5;
    end
    addr = 15;
    #5;
    if (out == `R15) $display("Correct SVC PC");
    #5;


    mode = `SVC;
    for (i = 0; i < 13; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == i) $display("Correct SVC ", i);
        #5;
    end
    for (i = 13; i < 15; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == (i + `R13_SVC - `R13)) $display("Correct SVC spec ", i);
        #5;
    end
    addr = 15;
    #5;
    if (out == `R15) $display("Correct SVC PC");
    #5;

    mode = `ABT;
    for (i = 0; i < 13; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == i) $display("Correct ABT ", i);
        #5;
    end
    for (i = 13; i < 15; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == (i + `R13_ABT - `R13)) $display("Correct ABT spec ", i);
        #5;
    end
    addr = 15;
    #5;
    if (out == `R15) $display("Correct ABT PC");
    #5;

    mode = `IRQ;
    for (i = 0; i < 13; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == i) $display("Correct IRQ ", i);
        #5;
    end
    for (i = 13; i < 15; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == (i + `R13_IRQ - `R13)) $display("Correct IRQ spec ", i);
        #5;
    end
    addr = 15;
    #5;
    if (out == `R15) $display("Correct IRQ PC");
    #5;

    mode = `UND;
    for (i = 0; i < 13; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == i) $display("Correct UND ", i);
        #5;
    end
    for (i = 13; i < 15; i = i + 1)
    begin
        addr = i;
        #5;
        if (out == (i + `R13_UND - `R13)) $display("Correct UND spec ", i);
        #5;
    end
    addr = 15;
    #5;
    if (out == `R15) $display("Correct UND PC");
    #5;

end


endmodule
