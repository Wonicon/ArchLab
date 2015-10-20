`timescale 1ns / 1ps

module arm_shift_32_behave #(parameter DATA_WIDTH = 32, AMOUNT_WIDTH = $clog2(DATA_WIDTH), RANK = $clog2(DATA_WIDTH)) (
    input                         carry_in,
    input  [1:0]                  shift_op,
    input  [DATA_WIDTH - 1:0]     shift_in,
    input  [AMOUNT_WIDTH - 1:0]   shift_amount,
    output reg [DATA_WIDTH - 1:0] shift_out,
    output reg                    carry_out
);

reg [2 * DATA_WIDTH : 0] ro_temp;
reg [DATA_WIDTH : 0] temp;
wire signed [DATA_WIDTH : 0] sign_shift;
assign sign_shift = {shift_in, carry_in};
always @(shift_op or shift_in or shift_amount or carry_in) begin: Shift
    case (shift_op)
    2'b00: begin: LSL
        temp[DATA_WIDTH : 0] = {carry_in, shift_in} << shift_amount;
        carry_out = temp[DATA_WIDTH];
        shift_out = temp[DATA_WIDTH - 1 : 0];
    end
    2'b01: begin: LSR
        if (shift_amount == 0) begin: LSR0
            shift_out = 0;
            carry_out = shift_in[DATA_WIDTH - 1];
        end
        else begin: Common_LSR
            temp[DATA_WIDTH : 0] = {shift_in, carry_in} >> shift_amount;
            carry_out = temp[0];
            shift_out = temp[DATA_WIDTH : 1];
        end
    end
    2'b10: begin: ASR
        if (shift_amount == 0) begin: ASR0
            shift_out = {DATA_WIDTH{shift_in[DATA_WIDTH - 1]}};
            carry_out = shift_in[DATA_WIDTH - 1];
        end
        else begin: Common_ASR0
            temp = sign_shift >>> shift_amount;
            carry_out = temp[0];
            shift_out = temp[DATA_WIDTH : 1];
        end
    end
    2'b11: begin: ROR
        if (shift_amount == 0) begin: RXX
            shift_out = {carry_in, shift_in[DATA_WIDTH - 1 : 1]};
            carry_out = shift_in[0];
        end
        else begin: Common_ROR
            ro_temp = {{2{shift_in}}, carry_in} >> shift_amount;
            carry_out = ro_temp[0];
            shift_out = ro_temp[DATA_WIDTH : 1];
        end
    end
    endcase
end

endmodule
