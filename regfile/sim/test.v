`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/09/04 21:48:11
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test(

    );
    
    reg [4:0] rsaddr, rtaddr, rdaddr;
    reg [31:0] rdin;
    wire [31:0] rsout, rtout;
    reg [3:0] w_en;
    reg clk;
    
    always
    begin
        #10 clk = ~clk;
    end
    
    register_mips32 r0
    (
        .Rs_addr(rsaddr),
        .Rt_addr(rtaddr),
        .Rd_addr(rdaddr),
        .Rd_in(rdin),
        .Rd_Byte_w_en(w_en),
        .Rs_out(rsout),
        .Rt_out(rtout),
        .clk(clk)
    );
    
    integer i;
    initial
    begin
        $display($time, "<< Starting the Simulation >>");
        clk = 1'b0;
        w_en = 4'b0000;
        rsaddr = 0;
        rtaddr = rsaddr + 1;
        rdaddr = 0;
        rdin = 32'habcde;
    end
    
    always  @(posedge clk)
    begin
        rdaddr <= rdaddr + 1;
        rtaddr <= rsaddr;
        rsaddr <= rsaddr + 1;
    end
    
endmodule
