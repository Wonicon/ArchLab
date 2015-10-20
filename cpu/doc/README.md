# 单周期 CPU 的设计实验

使用 MIPS 指令集

## 对控制信号的理解

下面罗列的控制信号, 针对给定的单周期 CPU 电路原理图. 它们都是由控制器根据 MIPS 指令的高 5 位和低 6 位计算得出的.

### Rt_addr_sel:

Rt_addr_sel 为 0 的情况下, 输入到寄存器组 Rt_addr 端口的是 IR[20:16], 即指令的 rt 操作数. 
否则, 输入到寄存器组 Rt_addr 端口的是 0, 即 rt 操作数为 $zero 寄存器. 
$zero 寄存器不会被修改, rt 为 $zero 应该表示的是没有 rt 操作数的场合.

### Rd_addr_sel:

Rd_addr_sel 为 0 的情况下, 输入到寄存器组 Rd_addr 端口的是 IR[20:16], 即指令的 rt 操作数. 
否则, 输入到寄存器 Rd_addr 端口的是 IR[15:11], 即 指令的 rd 操作数.

现在的问题是, 会不会有 Rt_addr_sel = 0 而 Rd_addr_sel = 0 的情况? 这种情况下, 寄存器组看到的 rt 是 $zero, 看到的 rd 是 指令中的 rt. 
如果 rt 被解释成 $zero 的情况下, 指令中的 rt 域是不确定的值, 那此时 rd 的解释也就是不确定的, 会不会产生不确定的行为?

rd 是目的操作数, 主要用于写入, rt 是第二操作数, 有时候是可选的.

### Rd_byte_w_en\[3:0\] (Overflow_out=0):

虽然 Overflow_out 在控制器的右侧, 但是连的是 ALU 的 Overflow_out 的输出端, 所以 Overflow_out 应该也是控制器的输入. 
这样也容易解释为什么 Rd_byte_w_en 要依 Overflow_out 的值来分情况讨论. 

由于 MIPS 没有标志位, 溢出信号应该即刻使用, 也就是说, 不写入目的操作数(?) 此时 Rd_byte_w_en 应该为 0. 

由于 Overflow_out 也经过控制器, 所以是否应用溢出信号也可以在控制器中完成. 
关于 Overflow_out 的有效性是在 ALU 中处理, 还是在控制器中判断, 有待进一步讨论. 

### Rd_byte_w_en\[3:0\] (Overflow_out=1):

见上.

### B_in_sel\[1:0\]:

选择第二操作数送入 ALU. 虽然 B_in_sel 有两位, 但是只有 3 个选择.

0 号总线连接的就是寄存器组的 Rt_out, 这种情况应该也承载了没有第二操作数的情况.

1 号总线连接的是 Ex_offset[31:0], 是[符号位扩展后]的立即操作数, 具体来源在下面讨论.

2 号总线连接的是 Imm_ex[31:0], 是左移16位后的立即操作数. 主要是 lui 指令使用(?)

1 号和 2 号总线都与 IR[15:0] 相关, 它的语义是 Imm 或者 Offset.

### Extend_sel:

符号位扩展使能.

### ALU_op\[3:0\]:

很熟悉了的 ALU_op, 这个应该能直接输出(?)

### Shift_amount_sel:

位移量来源的选择子, 为 0 时是 IR[10:6], 为 1 时是 Rs_out[4:0].

### Shift_op\[1:0\]:

很熟悉了的 Shift_op. 桶形移位器的 Shift_in 只来源于 Rt_out.

### ALU_Shift_sel:

选择输出是 ALU 的运算结果 (0) 还是桶形移位器的运算结果 (1).

ALU_Shift_out 连接着 Rd_in.

### Condition\[2:0\]:

条件功能的选择子, 输入的都是一些条件判断函数.

输出的条件判断对下一条指令地址进行选择, 0的话即简单的加4, 1的话是在**加4的情况下**再加入偏移量, 偏移量注意按照规定进行位拼接. 

### Jump:

Jump 控制最终的地址是经过 Condition 选择的地址还是直接从 IR[25:0] 拼接出来的绝对转移地址.