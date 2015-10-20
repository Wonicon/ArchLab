module control (
    input     [31:0] IR,                // I want more information
    input            Overflow_out,      // The overflow signal sent by ALU
    output           Jump,              // Enable absolute jump when Jump = 1
    output           Extend_sel,        // Extend IR[15:0] by its msb when Extend_sel = 1
    output           Rd_addr_sel,       // Select the dest register address source: 1 is Rd, 0 is Rt
    output           Rt_addr_sel,       // Select the second operand source: 1 is 0, 0 is Rt
    output reg       ALU_Shift_sel,     // Select the result: 1 is Shift, 0 is ALU
    output           Shift_amount_sel,  // Select the shift amount source: 1 is R[Rs], 0 is IR[10:6]
    output     [1:0] B_in_sel,          // Select the source of THE SECOND OPERAND OF ALU
    output reg [3:0] ALU_op,            // Select the ALU operation
    output reg [1:0] Shift_op,          // Select the shift operation
    output reg [2:0] condition,         // Select which condition to judge branch
    output     [3:0] Rd_byte_w_en       // Enable writing to R[Rd] when Rd_byte_w_en is 1111B
);

wire [5:0] Op;    // The opecode of instructions, which equals to IR[31:16]
wire [5:0] Func;  // Decide ALU_op
assign Op = IR[31:26];
assign Func = IR[5:0];
//
// Opecode
//
parameter ALU   = 6'b000000;  // A set of arithmetic operations using ALU; detailed by Func
parameter BLG   = 6'b000001;  // BLTZ and BGEZ; their results are opposite; indicated by other fields; so they share the opecode
parameter BEQ   = 6'b000100;  // Branch equal; containing a fake instruction `B(absolute branch)'
parameter BNE   = 6'b000101;  // Branch not equal; opposite to BEQ
parameter BLE   = 6'b000110;  // Although it is BLEZ in the book; it can be noticed that it is have constant 0 in instruction
parameter BGT   = 6'b000111;
parameter JMP   = 6'b000010;
// The following arithmetic instructions using Imm has opecode 001XXX; where XXX = Func[2:0]
parameter ADDI  = 6'b001000;  // ADD using Imm
parameter ADDIU = 6'b001001;  // ADDU using Imm
parameter SLTI  = 6'b001010;  // SLT using Imm
parameter SLTIU = 6'b001011;  // SLTIU using Imm
parameter ANDI  = 6'b001100;  // AND using Imm
parameter ORI   = 6'b001101;  // OR using Imm
parameter XORI  = 6'b001110;  // XORI using Imm
// End; see above
parameter LUI   = 6'b001111;
parameter CLZ   = 6'b011100;  // CLZ and CLO; distinguished by Func
parameter SE    = 6'b011111;  // SEB and SEH; distinguished by Rd

//
// Func
//
parameter FUNC_ADD   = 6'b100000;
parameter FUNC_ADDU  = 6'b100001;
parameter FUNC_SUB   = 6'b100010;
parameter FUNC_SUBU  = 6'b100011;
parameter FUNC_AND   = 6'b100100;
parameter FUNC_OR    = 6'b100101;
parameter FUNC_XOR   = 6'b100110;
parameter FUNC_NOR   = 6'b100111;
parameter FUNC_SLT   = 6'b101010;
parameter FUNC_SLTU  = 6'b101011;
parameter FUNC_TLT   = 6'b110010;
parameter FUNC_TLTU  = 6'b110011;
parameter FUNC_CLZ   = 6'b100000;
parameter FUNC_CLO   = 6'b100001;
parameter FUNC_SEB   = 6'b100000;
parameter FUNC_SEH   = 6'b100000;
parameter FUNC_SLL   = 6'b000000;
parameter FUNC_SLLV  = 6'b000100;
parameter FUNC_SRA   = 6'b000011;
parameter FUNC_SRAV  = 6'b000111;
parameter FUNC_SRL   = 6'b000010;  // wtf IR[25:21] = 5'b0000
parameter FUNC_SRLV  = 6'b000110;  // wtf IR[10:6]  = 5'b0000
parameter FUNC_ROTR  = 6'b000010;  // wtf IR[25:21] = 5'b0001
parameter FUNC_ROTRV = 6'b000110;  // wtf IR[10:6]  = 5'b0001


//
// Rd_byte_en
//

// Rd_byte_en_sel: select the output of Rd_byte_en
//   00: 4'b0001
//   01: 4'b1111
//   1x: according to Overflow
// NOTE: Rd_byte_en = 4'b0000 allows writing to R[Rd]
//
wire [1:0] Rd_byte_en_sel;
// Overflow effectiveness
// Only ADD, SUB, ADDI will set Rd_w_en according to the Overflow_out from ALU
// Their binaries:
//   ADD:  000000 100000
//   SUB:  000000 100010
//   ADDI: 001000 XXXXXX
assign Rd_byte_en_sel[1] = ((Op == ALU) && {Func[4:2], Func[0]})  // AND or SUB, Func[5] is always 1
                           || (Op == ADDI);  // ADDI, although Op[5] is always zero...
// Rd_byte can always be 4'b1111:
//   BXX can be simplified as 6'b0001xx and 6'b000001
assign Rd_byte_en_sel[0] = (Op[5:2] == 4'b0001)  // BXX other than BLG
                           || (Op == BLG)        // BLG is 6'b000001
                           || (Op == JMP);       // JMP
assign Rd_byte_en = {4{Rd_byte_en_sel[1] & Overflow_out}}  // Rd_byte_en_sel[1] = 1 allows Overflow_out to pass
                    | {4{!Rd_byte_en_sel[1] & Rd_byte_en_sel[0]}};  // ...[1] = 0 allows ...[0] to pass, exclusively.

//
// condition
//
always @(Op) begin
    case (Op)
    // The IR[16] of BLTZ is 0B while 1B in BGEZ
    // The BLTZ and BGEZ can only be distinguished from this bit
    BLG: condition = {!IR[16], 1'b1, IR[16]};  // 110 -> 'less than', 011 -> 'greater than and equal to'
    BNE: condition = 3'b010;                   // not equal to
    BEQ: condition = 3'b001;                   // equal to
    BLE: condition = 3'b101;                   // less than and equal to
    BGT: condition = 3'b100;                   // greater than
    default: condition = 3'b000;               // don't jump
    endcase
end

//
// Shift_op
//
wire arith_mask;  // When it is arith operation, let something pass
wire [5:0] arith_op_masked;  // The signal passed mask links to it
assign arith_mask = !(|Op);

// Let XXI and FUNC_XXX to be in one bus
assign arith_op_masked = ({5{arith_mask}} & Func) | Op;
always @(arith_op_masked, IR[21], IR[6]) begin
    case (arith_op_masked)
    FUNC_SLL : Shift_op = 2'b00;
    FUNC_SLLV: Shift_op = 2'b00;
    FUNC_SRA : Shift_op = 2'b10;
    FUNC_SRAV: Shift_op = 2'b10;
    FUNC_SRL : Shift_op = {IR[21], 1'b1};  // Can become 2'b11
    FUNC_SRLV: Shift_op = {IR[6],  1'b1};  // Can become 2'b11
    default: Shift_op = 6'bxxxxxx;
    endcase
end

//
// ALU_op
// TODO: LUT is low, try logic function.
//
always @(arith_op_masked, Func[0], IR[6]) begin
    case (arith_op_masked)
    FUNC_ADD:  ALU_op = 4'b1110;  // ADD
    FUNC_ADDU: ALU_op = 4'b0000;  // ADDU
    FUNC_SUB:  ALU_op = 4'b1111;  // SUB
    FUNC_SUBU: ALU_op = 4'b0001;  // SUBU
    FUNC_AND:  ALU_op = 4'b0100;  // AND
    FUNC_OR:   ALU_op = 4'b0110;  // OR
    FUNC_XOR:  ALU_op = 4'b1001;  // XOR
    FUNC_NOR:  ALU_op = 4'b1000;  // NOR
    FUNC_SLT:  ALU_op = 4'b0101;  // SLT
    FUNC_SLTU: ALU_op = 4'b0111;  // SLTU
    FUNC_TLT:  ALU_op = 4'b0001;  // SUBU
    FUNC_TLTU: ALU_op = 4'b0001;  // SUBU
    BLG:       ALU_op = 4'b0001;  // SUBU
    BEQ:       ALU_op = 4'b0001;  // SUBU
    BNE:       ALU_op = 4'b0001;  // SUBU
    BGT:       ALU_op = 4'b0001;  // SUBU
    BLE:       ALU_op = 4'b0001;  // SUBU
    ADDI:      ALU_op = 4'b1110;  // ADD
    ADDIU:     ALU_op = 4'b0000;  // ADDU
    SLTI:      ALU_op = 4'b0101;  // SLT
    SLTIU:     ALU_op = 4'b0111;  // SLTU
    ANDI:      ALU_op = 4'b0100;  // AND
    ORI:       ALU_op = 4'b0110;  // OR
    XORI:      ALU_op = 4'b1001;  // XOR
    LUI:       ALU_op = 4'b0000;  // LUI
    CLZ:       ALU_op = {3'b001, Func[0]};  // 0: CLZ, 1: CLO
    SE:        ALU_op = {3'b101, IR[6]};    // 0: SEB, 1: SEH
    endcase
end

//
// B_in_sel
//
wire is_lui;
assign is_lui = &Op[2:0];  // lui is 001 111, 111 is distinguished among xxi.
assign B_in_sel = (Op[4:3] != 2'b01) ? 2'b00 : (  // arith without imm, cl?, se?
                  (is_lui) ? 2'b10 :  // lui, shift_imm
                  2'b01);  // ext_imm

//
// Shift_amount_sel, ALU_Shift_sel
// As shift is used in a few of cases. We only need to promise the ALU_Shift_sel
// to be exactly correct!
//
assign Shift_amount_sel = Func[2];
// We can simplify the Shift Func into 6'b000xxx because the missing 6'b000101 is
// a float point instruction whose Op is not 6'b000000
wire is_shift;
assign is_shift = !(|Func[5:3]);
always @(arith_mask, is_shift) begin
    case ({arith_mask, is_shift})
    2'b0x: ALU_Shift_sel = 1'bx;
    2'b10: ALU_Shift_sel = 1'b0;
    2'b11: ALU_Shift_sel = 1'b1;
    endcase
end

//
// Rt_addr_sel
// Typically, the instruction using imm operand can ignore Rt_addr_sel but focusing on the B_in_sel.
// In other situation, Rt_addr_sel is always 0, namely using the Rt embeded in the instruction.
// But BGEZ will force the Rt_addr_sel to 1, as we don't have any information about its feature
// other than the Op code itself.
// Moreover, the I-type always use rt as the destination register, which will act as Rd
// As the Rt_addr_sel = 1 is so special, we can left all the not-care situation use the 1
//

assign Rt_addr_sel = (Op == BLG);  // BLG contains BLTZ and BGEZ, both of them expect $zero, promising the correctness.


//
// Rd_addr_sel
//
// The expanse of the easy assignment of Rt_addr_sel is the relative complexity of Rd_addr_sel
// The arithmetic operation with opecode equals to zero will use the Rd code in the instruction
// while those which use imm operand will use the Rt code in the instruction.
// Other instructions may doesn't need a register to store their result. Typically they will hard-encode
// the Rd operand pointing to $zero (and disable the write enable), otherwise they have a convention that Rd == Rt.
// So a simple function is that we only recognize the instruction using imm, and let all the other situations to be 1
//

assign Rd_addr_sel = Op[4] || !Op[3];
//~~~~~~~~~~~~~~~~~~~~~~^~~ To avoid clz/clo, seb/seh


//
// Extend_sel
//
// Much like Rd_addr_sel, but contains all the branch instruction.
//

// assign Extend_sel = 1'b1;

// Branch instruction opecode can be simplified as 0001xx and 000001,
// All the arithmetic operation can set this signal to 1, so 000001 -> 00000x,
// => 001xxx, 0001xx, 00000x
// note that 000010 is jmp and 000011 is jal, which also don't care Extend_sel
// => 00xxxx
// This assignment takes all the instructions implemented into consideraton
// and avoid covering future instructions
assign Extend_sel = (Op[5:4] == 2'b00);

//
// J
// use JAL(000011) to simplify
//
assign Jump = (Op[5:1] == 5'b00001);

endmodule
