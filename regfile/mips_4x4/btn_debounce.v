`timescale 1ns / 1ps

module btn_debounce(
    input btn,
    input clk,
    output out
    );
    
    reg delay1;
    reg delay2;
    reg [19:0] count;
    reg clk_20ms;
    
    always @ (posedge clk)
        if (count == 20'hfffff)
        begin
            clk_20ms <= ~clk_20ms;
            count <= 20'd0;
       end
       else
           count <= count + 1'b1;
   
   always @ (posedge clk_20ms)
   begin
       delay1 <= btn;
       delay2 <= delay1;
   end
   
   assign out = delay1 & delay2;
   
endmodule
