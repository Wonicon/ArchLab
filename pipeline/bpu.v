`timescale 1ns / 1ps

//
// 分支预测单元
//
// 采用 1 位有效位, 1 位预测位, 直接映射, 直接替换策略
// 一般来说, PC 的 [27:2] 是足够用来区分一条指令的,
// 但是这依然是一个很大的数字, 所以拟采用 [9:2] 作为标签.
// 由于是直接映射, 所以标签直接作为检索下标.
//
// 有效位的含义是判断是否采用存储的 PC 作为下一条指令的 PC,
// 有效位无效的时候采用 current_pc_4 作为下一条地址.
// 有效位在第一次被置 1 后即不会恢复为 0. 有效位置 1 时存储的一定是跳转指令的目标地址.
// 之后靠预测位来决策地址的修正
//
// 预测位在为 0 时一定会更新目标地址, 同时自增 1, 在 1 的时候给错误预测留有缓冲的机会
//
// 对于跳转指令, 存储 PC 表明的可以是跳转地址, 也可以是顺序执行地址
// 为了减少延迟槽的 nop 指令带来的性能损失, 顺序执行地址存储的是 PC + 8
// 由于标签的位宽有限, 所以会有碰撞的情况出现, 在 MEM 段修正后 PC + 4 也可以存储到里面
//
// 表项格式
// +------------------------------+------+------+
// |       预测地址               |预测位|有效位|
// +------------------------------+------+------+
//          [31:2]                   [1]    [0]
//

// 标签位宽
`define TAG_WIDTH 6
// 地址线宽度
`define PC_WIDTH 32
// 预测表条目长度
`define ENTRY_WIDTH 32
// 预测表条目数
`define NR_SLOT (2 ** `TAG_WIDTH)

// 总线截取
`define PC_BUS      (`PC_WIDTH - 1)    : 0
`define ENTRY_BUS   (`ENTRY_WIDTH - 1) : 0
`define TABLE_BUS   (`NR_SLOT - 1)     : 0
`define PREDICT_BUS (`PC_WIDTH - 1)    : 2
`define TAG_BUS 7:2

// 状态位助记符
`define VALID 0
`define PREDICT 1

module bpu(
    input clk,
    input reset,
    input [`PC_BUS] current_pc,        // 当前用来查询下一条指令的PC
    input [`PC_BUS] tag_pc,            // 用来获取标签的PC
    input [`PC_BUS] next_pc,           // 标签PC对应的下一条执行指令的PC
    input bpu_w_en,                    // 写使能, 驱动 bpu 进行状态更新
    output reg [`PC_BUS] predicted_pc  // 预测 PC
);

reg [`ENTRY_BUS] bpu_table [`TABLE_BUS];

integer i;
initial begin
    for (i = 0; i < `NR_SLOT; i = i + 1) begin
        bpu_table[i] = 0;
    end
end

// 预测逻辑
wire [`TAG_WIDTH - 1 : 0] predict_tag = current_pc[`TAG_BUS];
wire [`ENTRY_BUS] predict_slot = bpu_table[predict_tag];

always @(*) begin
   if (predict_slot[`VALID] == 1'b1) begin
       predicted_pc = { predict_slot[`PREDICT_BUS], 2'b0 };
   end
   else begin
       predicted_pc = current_pc + 4;
   end
end

// 更新逻辑
wire [`TAG_WIDTH - 1 : 0] update_tag = tag_pc[`TAG_BUS];
wire [`ENTRY_BUS] update_slot = bpu_table[update_tag];

always @(negedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < `NR_SLOT; i = i + 1) begin
            bpu_table[i] <= 0;
        end
    end
    else if (bpu_w_en) begin
        // 有效位有效后一直有效
        bpu_table[update_tag][`VALID] <= 1'b1;
        // 预测位为 0 时立即更新, 之后容忍一次错误
        if (update_slot[`PREDICT] == 1'b0) begin
            bpu_table[update_tag][`PREDICT_BUS] <= next_pc[`PREDICT_BUS];
        end
        // 翻转预测位, 因为只有一位, 相当于加一
        bpu_table[update_tag][`PREDICT] <= ~update_slot[`PREDICT];
    end
    else begin
        // 预测正确的情况, 将预测位维持在 1
        bpu_table[update_tag][`PREDICT] <= 1'b1;
    end
end

endmodule
