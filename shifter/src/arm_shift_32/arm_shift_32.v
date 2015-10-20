`timescale 1ns / 1ps

module arm_shift_32 #(parameter DATA_WIDTH = 32, AMOUNT_WIDTH = $clog2(DATA_WIDTH), RANK = $clog2(DATA_WIDTH)) (
    input                         carry_in,
    input  [1:0]                  shift_op,
    input  [DATA_WIDTH - 1:0]     shift_in,
    input  [AMOUNT_WIDTH - 1:0]   shift_amount,
    output reg [DATA_WIDTH - 1:0] shift_out,
    output reg                    carry_out
);

// Generate switch logic and instance for each rank of mux group.
// Under 32-bit situation, we totally need 6 rank and the intermediate 4 ranks
// can be generated from a template while the 1st rank need to handle RXX and
// the last rank need to handle LSL#0 and ASL#0
genvar rank;

// The value of shift_op_remapped directly indicate the port of a single rank
// mux group is 1, 2, or 3. with the en which in some sense derives from each
// bit of shift_amount, form the rank_switch which in addition can select the
// zero port, namely, no shift option.
wire [1:0] shift_op_remapped;
wire [1:0] rank_switch[RANK - 1:0];
wire [1:0] result_switch;
wire rank_en[RANK - 1:0];
// Use an additional bit to transfer MSB.
// Therefore DATA_WIDTH but not DATA_WIDTH - 1
wire [DATA_WIDTH:0] rank_out[RANK - 1:0];
// Indicate whether the shift_amount is all zero.
wire isZero;
// Indicate whether this is a RXX mode.
// TODO: Remove notRXX as it seems duplicated!
wire isRXX, notRXX;

// Prepare for sign and cin
reg sign, cin;

// Bitwise xnor
assign isZero = ~(|shift_amount);
// Bitwise and
assign isRXX = &{isZero, shift_op};
assign notRXX = ~isRXX;
// Remap to combine LSR and ASR
assign shift_op_remapped[0] = ^~shift_op;
assign shift_op_remapped[1] = |shift_op;

// When in the ASR mode, let MSB to be shifted in instead of zero.
always @(shift_op[1] or shift_in[DATA_WIDTH - 1])
begin: SIGNsel
    case (shift_op[1])
        // Not need the sign
        1'b0: sign = 1'b0;
        // Need the sign
        1'b1: sign = shift_in[DATA_WIDTH - 1];
    endcase
end

// When in the RXX mode, let carry_in to be rotated in instead of LSB.
always @(isRXX or shift_in[0] or carry_in)
begin: CINsel
    case (isRXX)
        //1'b0: cin = 1'b0;
        1'b0: cin = shift_in[0];
        1'b1: cin = carry_in;
    endcase
end

// Generate each rank of mux group
// +----+---+---+---+---+---+---+---+---+
// |COUT|MSB|   |   |   |...|   |   |LSB|
// +----+---+---+---+---+---+---+---+---+
// If we let COUT occupy the out[33], then sl is much easier to write,
// but sr and ro is much harder, and vice versa.
// Moreover, the index is ambiguous if we put COUT at LSB!

// Rank 0, special for RXX
assign rank_en[0] = isRXX | shift_amount[0];
assign rank_switch[0][1] = shift_op_remapped[1] & rank_en[0];
assign rank_switch[0][0] = shift_op_remapped[0] & rank_en[0];
arm_shift_32_mux #(.DATA_WIDTH(DATA_WIDTH + 1)) inst (
    .switch(rank_switch[0]),
    .mux_no({cin, shift_in}),
    .mux_sl({shift_in[DATA_WIDTH - 1:0], 1'b0}),
    .mux_sr({shift_in[0], sign, shift_in[DATA_WIDTH - 1:1]}),
    .mux_ro({shift_in[0], cin, shift_in[DATA_WIDTH - 1:1]}),
    .mux_out(rank_out[0])
);

`define BITS (2**rank)
`define CURRENT rank_out[rank - 1]
generate
    // 1 - 5 template
    for (rank = 1; rank < RANK; rank = rank + 1)
    begin: mux_group
        // TODO: Simplify this!
        //assign rank_switch[rank][1:0] = shift_op_remapped[1:0] & {2{notRXX & shift_amount[rank]}};
        assign rank_en[rank] = notRXX & shift_amount[rank];
        assign rank_switch[rank][1] = shift_op_remapped[1] & rank_en[rank];
        assign rank_switch[rank][0] = shift_op_remapped[0] & rank_en[rank];
        // mux group instance
        arm_shift_32_mux #(.DATA_WIDTH(DATA_WIDTH + 1)) inst (
            .switch(rank_switch[rank]),
            .mux_no(rank_out[rank - 1]),
            .mux_sl({rank_out[rank - 1][DATA_WIDTH - `BITS:0], {`BITS{1'b0}}}),
            .mux_sr({
                rank_out[rank - 1][`BITS - 1],              // COUT
                {`BITS{sign}},                              // Sign extention
                rank_out[rank - 1][DATA_WIDTH - 1:`BITS]}), // Rest part
            .mux_ro({
                rank_out[rank - 1][`BITS - 1],              // COUT
                rank_out[rank - 1][`BITS - 1:0],            // Low part into high position
                rank_out[rank - 1][DATA_WIDTH - 1:`BITS]}), // High part into low position
            .mux_out(rank_out[rank])
        );
    end
endgenerate

// Last to handle the ASR#0 and LSR#0
// Output
and Result_S1 (result_switch[1], isZero, shift_op[1], ~shift_op[0]);
and Result_S0 (result_switch[0], isZero, shift_op[0], ~shift_op[1]);
always @(result_switch or shift_in[DATA_WIDTH -1] or rank_out[RANK - 1])
begin: ORG_ASR0_LSR0
    case (result_switch)
        2'b00:
        begin
            shift_out = rank_out[RANK - 1][DATA_WIDTH - 1: 0];
            carry_out = rank_out[RANK - 1][DATA_WIDTH];
        end
        2'b01:
        begin
            shift_out = {DATA_WIDTH{1'b0}};
            carry_out = shift_in[DATA_WIDTH - 1];
        end
        2'b10:
        begin
            shift_out = {DATA_WIDTH{shift_in[DATA_WIDTH - 1]}};
            carry_out = shift_in[DATA_WIDTH - 1];
        end
        2'b11:
        begin
            shift_out = {DATA_WIDTH{1'bx}};
            carry_out = 1'bx;
        end
    endcase
end

endmodule
