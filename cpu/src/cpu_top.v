`timescale 1ns / 1ps

module misp_cpu_top (
    input clk,
    input reset,
    output [31:0] outp,
    output [31:0] pc_p, ir_p
);

// PC: the current instruction address
// PC_in: the next instruction address to be calculated
reg [31:0] PC;  // PC will not act like a real memory?
wire [31:0] PC_in;
always @(negedge clk or posedge reset)
    if (reset == 1)
        PC <= 32'd0;
    else
        PC <= PC_in;


assign pc_p = PC;
assign ir_p = IR;
//
// Instruction Memory
//
wire [31:0] IR;   // Instruction Bus
ideal_instr_mem mem (
    .address(PC[31:2]),
    .dword(IR)
);

//
// Instruction Format: Rs, Rt, Rd
//
wire [4:0] Rd_instr = IR[15:11];
wire [4:0] Rt_instr = IR[20:16];
wire [4:0] Rs_instr = IR[25:21];


//
// Controller
//
// See the description of these wires besides instance of controller.
// Or get it in the module controller.
wire Jump, Extend_sel, Rd_addr_sel, Rt_addr_sel, ALU_Shift_sel, Shift_amount_sel, Rd_in_sel, mem_w_en;
wire [1:0] B_in_sel, Shift_op;
wire [2:0] condition;
wire [3:0] ALU_op, Rd_byte_w_en;
wire Overflow_out;  // Declare here for right connection
controller ctrl (
    .IR(IR),                              // [in] I want more information
    .Overflow_out(Overflow_out),          // [in] The overflow signal sent by ALU
    .Jump(Jump),                          // [out] Enable absolute jump when Jump = 1
    .Extend_sel(Extend_sel),              // [out] Extend IR[15:0] by its msb when Extend_sel = 1
    .Rd_addr_sel(Rd_addr_sel),            // [out] Select the dest register address source: 1 is Rd, 0 is Rt
    .Rt_addr_sel(Rt_addr_sel),            // [out] Select the second operand source: 1 is 0, 0 is Rt
    .ALU_Shift_sel(ALU_Shift_sel),        // [out] Select the result: 1 is Shift, 0 is ALU
    .Shift_amount_sel(Shift_amount_sel),  // [out] Select the shift amount source: 1 is R[Rs], 0 is IR[10:6]
    .B_in_sel(B_in_sel),                  // [out] Select the source of THE SECOND OPERAND OF ALU
    .ALU_op(ALU_op),                      // [out] Select the ALU operation
    .Shift_op(Shift_op),                  // [out] Select the shift operation
    .condition(condition),                // [out] Select which condition to judge branch
    .Rd_byte_w_en(Rd_byte_w_en),          // [out] Enable writing to R[Rd] when Rd_byte_w_en is 1111B
    .Rd_in_sel(Rd_in_sel),
    .mem_w_en(mem_w_en)
);


//
// Get the real operand address
// They are the final register address sent to the register file
//
wire [4:0] Rt_real, Rd_real;

assign Rt_real = Rt_addr_sel ? 5'd0      // When we don't have or need Rt from instruction, or expect a constant zero
                             : Rt_instr;

assign Rd_real = Rd_addr_sel ? Rd_instr
                             : Rt_instr; // This typically occurred with I-type instructions


//
// Read and write register file
//
wire [31:0] ALU_Shift_out,  // The output from alu or shifter depeding on regfile
            Rs_out,
            Rt_out,
            mem_out,
            Rd_in;

assign Rd_in = Rd_in_sel ? mem_out : ALU_Shift_out;

register_mips32 regfile (
    .Rs_addr(Rs_instr),
    .Rt_addr(Rt_real),
    .Rd_addr(Rd_real),
    .Rd_in(Rd_in),  // Actual write happens when a new cycle starts
    .Rd_Byte_w_en(Rd_byte_w_en),
    .clk(clk),
    .Rs_out(Rs_out),
    .Rt_out(Rt_out)
);


//
// Prepare the second operand B for ALU
//

// As Sign-Extended immediate operand
wire [31:0] Ex_offset = Extend_sel ? {{16{IR[15]}}, IR[15:0]} // Sign extending
                                   : {16'd0, IR[15:0]};
wire [31:0] Imm_ex = {IR[15:0], 16'd0};  // Used by LUI

reg [31:0] B_in;  // Selected data sent to ALU
always @(B_in_sel, Rt_out, Ex_offset, Imm_ex) begin: select_b_in
    case (B_in_sel)
    2'd0: B_in = Rt_out;
    2'd1: B_in = Ex_offset;
    2'd2: B_in = Imm_ex;
    default: B_in = 32'dx;
    endcase
end


//
// ALU
//
wire Less, Zero;
wire [31:0] ALU_out;
mips32_alu alu (
    .ALU_op(ALU_op),
    .A_in(Rs_out),
    .B_in(B_in),
    .Zero(Zero),
    .Less(Less),
    .Overflow_out(Overflow_out),
    .ALU_out(ALU_out)
);


//
// Shifter
//
wire [31:0] Shift_out;
wire [4:0] Shift_amount = Shift_amount_sel ? Rs_out[4:0]  // Shamt from register
                                                          : IR[10:6];    // Const shamt

mips32_shift shifter (
    .shift_in(Rt_out),
    .shift_amount(Shift_amount),
    .shift_op(Shift_op),
    .shift_out(Shift_out)
);


//
// Select the result
//
assign ALU_Shift_out = ALU_Shift_sel ? Shift_out : ALU_out;  // This value will send to R[Rd]


//
// Condition selection
//
reg cond_en;
always @(condition, Less, Zero) begin: select_condition
    case (condition)
    3'd0: cond_en = 1'b0;            // No branch
    3'd1: cond_en = Zero;            // ==
    3'd2: cond_en = !Zero;           // !=
    3'd3: cond_en = !Less;           // >=
    3'd4: cond_en = !(Less || Zero); // >
    3'd5: cond_en = Less || Zero;    // <=
    3'd6: cond_en = Less;            // <
    3'd7: cond_en = 1'b1;            // Absoute branch, absolutely never use it
    default: cond_en = 1'bx;
    endcase
end


//
// Next PC
//

// PC_normal: a common next PC which plus 4.
// PC_branch: the PC determined by branch instruction
// PC_jmp: the PC determined by jmp instruction
wire [31:0] PC_normal = PC + 4;
wire [31:0] PC_branch = PC_normal + {Ex_offset[29:0], 2'd0};
wire [31:0] PC_jmp = {PC[31:28], IR[25:0], 2'd0};

assign PC_in = Jump ? PC_jmp                // PC_jmp
                    : cond_en ? PC_branch   // PC_branch
                              : PC_normal;  // PC_normal

//
// For test purpose
//
assign outp = ALU_Shift_out;

//
// Memory
//
ideal_instr_mem storage (
    .address(ALU_out),
    .clk(clk),
    .w_en(mem_w_en),
    .data_in(Rt_out),
    .dword(mem_out)
);


endmodule
