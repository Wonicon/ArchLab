ARM的难点在于右移且shift amount为0时不是不移位，而是移满32位。
而且shift amount为0时的循环移位是循环带C移1位。
感觉RRX以外的右移可以在shift amount为0时强制刷成全0（逻辑右移和正数算数右移）或全1（负数算数右移）

虽然按照实验手册3.2.8节中对RRX的描述：“带扩展位的循环右移，操作数右移1位，高端空出的位用C标志填充，由字的低端移出的位填入C标志”，
但是给出的电路图cin和cout是分开的，也就是说，cin来自何方，cout去向何方，不是由这个桶型移位器来决定的。
此外组合电路对寄存器同时读取和写入，感觉时序上比较微妙。

下面对8位桶型移位器的框图进行分析：

最上面的二路选择器1号口接cin，0号口接in[0]，可以看出是其是用来区分ROR和RRX的。其输出只送入第一层选择器的3号口。
因为第一层只移一位，而RRX是只移一位的，估计本来各层选择器的3号口就是用来处理ROR的，因为RRX的特殊存在，需要在第一层（移一位）的情况下做特殊处理。
对这个二路选择器的选择子的分析显得很重要，可能对后面的shift amount为0时的判断也能起到启发作用。

这个选择子对应的输出口在最下面的3输入与门。两个输入是shift op，第三个输入是对3位shift amount的或非输出。是比较直接的判断。

但是shift amount为0还关系到移位问题。
上面提到的判定RRX情况的与门输出，与shift amount[0]是或的关系，这样就能强行使能第一层选择器组了。
**但是不理解的是，为什么后面几层寄存器组要与这个isRRX的取反。isRRX只有在一种特殊情况下才能为0，而此时shift amount都是0，这个与门肯定输出0，平时isRRX都是1，也就只看shift amount行事，这个与门后面考虑下能不能去掉。**

下面通过第一层选择器组的排线推测s1s0的语义。
3号口已经看过了，就是RRX/ROR；2号口直觉告诉我是算数移位的布线：它由一个顶部第二个选择器输入，其选择子是op1，算数右移的op1为1，1号口接的是in的msb，0号口接地，接地还要拖那么长的线到底下，差点看成lsb；
1号口也是很naive的左移布线；0号口是不移位。对比MIPS8的框图，依然是相似的构造，即3循环2符号1左移0不移。但是这里3号的输入会有变化，此外就是s1s0要把0移位的情况考虑清楚！
注意到**每一层都有9个选择器**！最底下的选择器就第一层来看3号和2号口接收移出的lsb，1号口接收左移出的msb，0号口接收cin。对本层没有什么影响，关注其后面的表现！
第一层isRXX和shift amount[0]的或来作为s1s0的使能，暂时忽略掉。op1和op0的或作为s1的输入（忽略掉与使能哦），表明s1是右移相关的。op1与op0的**异或非**作为s0的输入，相同即为1。于是对应关系为：

```
op[1:0] -> s[1:0], 第⑨个选择器在干什么
00(LSL) -> 01(1), 合情合理地接收左移出的MSB
01(LSR) -> 10(2), 合情合理地接收右移出的LSB
10(ASR) -> 10(2), 合情合理地接收右移出的LSB
11(ROR) -> 11(3), 多管闲事地接收右移出的LSB
           00(0), 本层不移动，接收cin
```

下面关注第二层。2号口显然还是ASR和LSR共享的输入，pass；3号口是规规矩矩的ROR；1号口依然是LSL；0号口是不移。
再来看一下第9层寄存器的行为，3号和2号口，接受来自上一个输入的LSB上一个信号，在移两位的情况下，这个信号刚好停留在LSB后面的位置上，语义上与第一层的那个是一致的（丢多的就不要了……）。1号也是一样，只留刚好在MSB上面的一位；
0号口接收前辈的输出，比较难以理解。
至于s[1:0]除了使能的判定有变化外，语义上没有变化！

第三层虽然排线更加复杂，但是只是比较跳跃而已。语义上和第二层已经没有大变化了，包括第9个选择器。

然而还有第四层寄存器！画风大变！这跟说好的不一样 Σ(ﾟДﾟ；≡；ﾟдﾟ)

那长得像使能一样的并排（juxtaposition)的与门以及共享的一根输入线告诉我们那是用来处理shift amount为0是逆天的右移行为的（移32位是要闹哪样！）。
s[1:0]的逻辑函数也是撕破脸皮一般的直截了当！就是来处理32LSR和32ASR的！

```
10 -> 10(2) 喜闻乐见的符号位完全扩展 のワの
01 -> 01(1) 喜闻乐见的吃地线 (σ′▽‵)′▽‵)σ
00 -> 00(0) 安定的原样输出 (ﾟ∀ﾟ)
11 -> 00(0) 安定的原样输出 (ﾟ∀ﾟ)
```

至少中间的几层可以用模板，32位就有3层啊，四舍五入一下就是5层啊（划去）。

## 资料中关于shift的信息

### ARM DataSheet

4.4

Branch instructions contain a signed 2's complement 24 bit offset.
This is shifted left two bits, sign extended to 32 bits, and add to the PC.

提到的shift left two bits只是4字节对齐的需求……

4.5.1

If the S bit is set (and Rd is not R15, see below) the V flag in the CPSR will be unaffected,
the C flag will be set to the carry out from the barrel shifter (or preserved when the shift operation is LSL#0)...

特殊情况下，桶型移位器总是会影响C位，除非是不左移（没有不右移XD）。
**如果高级代码要求右移不确定量（含不位移），编译出的arm代码会是怎么样的？**

### 实验记录

使用generate来批量实例化，虽然写得依旧挺复杂的~

上板测试发现逻辑左移不移动时cout和lsb有关了，

shift_amount有两位为1就会进入#0的特殊状态，原因是把按位或非写成了按位抑或。