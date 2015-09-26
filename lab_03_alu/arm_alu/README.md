### 功能表

| ALU_op[3:0] | 助记符 | 操作       | 结果               | 是否更新标志 |
|-------------|--------|------------|--------------------|--------------|
| 0000        | AND    | 按位与     | Rd← Rn AND Rs      | S=1          |
| 0001        | EOR    | 按位异或   | Rd← Rn EOR Rs      | S=1          |
| 0010        | SUB    | 减         | Rd← Rn - Rs        | S=1          |
| 0011        | RSB    | 反向减     | Rd← Rs - Rn        | S=1          |
| 0100        | ADD    | 加         | Rd← Rn + Rs        | S=1          |
| 0101        | ADC    | 带进位加   | Rd← Rn + Rs        | S=1          |
| 0110        | SBC    | 带进位减   | Rd← Rn - Rs - !Cin | S=1          |
| 0111        | RSC    | 带进位反减 | Rd← Rs - Rn - !Cin | S=1          |
| 1000        | TST    | 测试       | Rn AND Rs          | 强制         |
| 1001        | TEQ    | 测试相等   | Rn EOR Rs          | 强制         |
| 1010        | CMP    | 比较       | Rn - Rs            | 强制         |
| 1011        | CMN    | 比较反值   | Rn + Rs            | 强制         |
| 1100        | ORR    | 按位或     | Rd← Rn OR Rs       | S=1          |
| 1101        | MOV    | 传送       | Rd← Rs             | S=1          |
| 1110        | BIC    | 清零       | Rd← Rn AND ~Rs     | S=1          |
| 1111        | MVN    | 求反       | Rd← ~Rs            | S=1          |



Of the two source operands, one is always a register. The other is called a shifter operand and is either an immediate value or a register.
If the second operand is a register value, it can have a shift applied to it.
