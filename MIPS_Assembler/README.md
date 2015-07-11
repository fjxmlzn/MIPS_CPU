#Mips Assembler 文档
* 版本: 0.1.0
* 本程序通过命令行交互的方式将Mips汇编代码转换为机器码。

##汇编代码规范说明
###代码组织
代码由标签、指令和注释组成。每行的结构为

	[标签][指令][注释]

每块内容均为可选项。

* 标签：可由一个或多个标签组成。每个标签均以冒号结尾。具体见[标签](#label)。
* 指令：最多只能有一条指令。具体见[指令](#instruction)。
* 注释：#之后的内容均被视为注释。具体见[注释](#comment)。

###<span id = "instruction">指令</span>
支持以下汇编指令。

|指令|语法|功能|
|---|---|---|
|lw|lw rt, offset, rs|$rt <- memory[$rs + (sign-extend)offset]|
|sw|sw rt, offset, rs|memory[$rs + (sign-extend)offset] <- $rt|
|lui|lui rt, imm|$rt <- imm << 16|
|add|add rd, rs, rt|$rd <- $rs + $rt|
|addu|addu rd, rs, rt|$rd <- $rs + $rt;无符号计算|
|sub|sub rd, rs, rt|$rd <- $rs - $rt|
|subu|subu rd, rs, rt|$rd <- $rs - $rt;无符号计算|
|addi|addi rt, rs, imm|$rt <- $rs + (sign-extend)imm|
|addiu|addiu rt, rs, imm|$rt <- $rs + (zero-extend)imm|
|and|and rd, rs, rt|$rd <- $rs and $rt|
|or|or rd, rs, rt|$rd <- $rs or $rt|
|xor|xor rd, rs, rt|$rd <- $rs xor $rt|
|nor|nor rd, rs, rt|$rd <- not($rs or $rt)|
|andi|andi rt, rs, imm|$rt <- $rs + (zero-extend)imm|
|sll|sll rd, rt, shamt|$rd <- $rt << shamt|
|srl|srl rd, rt, shamt|$rd <- $rt >> shamt;逻辑右移|
|sra|sra rd, rt, shamt|$rd <- $rt >> shamt;算术右移|
|slt|slt rd, rs, rt|if ($rs < $rt) $rd = 1 else $rd = 0|
|slti|slti rt, rs, imm|if ($rs < (sign-extend)imm) $rt = 1 else $rt = 0|
|sltiu|sltiu rt, rs, imm|if ($rs < (zero-extend)imm) $rt = 1 else $rt = 0|
|beq|beq rs, rt, label|if ($rs == $rt) PC <- [label]|
|bne|bne rs, rt, label|if ($rs != $rt) PC <- [label]|
|blez|blez rs, label|if ($rs < 0) PC <- [label]|
|bgtz|bgtz rs, label|if ($rs > 0) PC <- [label]|
|bgez|bgeq rs, label|if ($rs >= 0) PC <- [label]|
|j|j label|PC <- [label]|
|jal|jal label|$rd <- PC + 4;PC <- [label]|
|jr|jr rs|PC = $rs|
|jalr|jalr rd, rs|$ra <- PC + 4;PC = $rs|
|nop|nop|空指令|

###<span id = "label">标签</span>

标签中可以包含任意连续非空格字符，并以冒号结尾。

###<span id = "comment">注释</span>

由#开头，同一行之后的内容均视为注释。

###其他声明

默认指令起始地址为0x00000000。

##使用指南

###运行方式

可以无参数直接启动，程序将进入命令行交互模式。也可以带参数启动，这时参数默认传递给命令`ass`，运行完毕即退出程序。关于此命令的内容参见[命令](#command)。

###<span id = "command">命令</span>

目前仅支持一个命令`ass`。其调用格式为：[^command]

	ass -i <输入文件路径> -o <输出文件路径> [-m ver/bin/hex] [-ad] [-src]

对于各参数的说明如下：

* -i：必选参数。后面跟上输入文件路径。路径中不能包含空格。
* -o：必选参数。后面跟上输出文件路径。路径中不能包含空格。
* -m：可选参数。指定了输出文件模式。未指定时默认为ver。
	* ver：输出纯文本模式的与verilog兼容的代码。
	* bin：二进制文件。
	* hex：输出纯文本模式的十六进制代码。
* -ad：可选参数。指定输出中每一指令的前部是否包含地址。仅对ver和hex模式有效。
	* 对于ver模式，地址为实际地址除以4的十进制形式。
	* 对于hex模式，地址为实际地址的十六进制形式。
* -src：可选参数。指定输出中每一条指令的后部是否包含原汇编代码及标签。若该指令无对应标签则只展示原汇编代码，否则标签紧随其后，展示在`<>`符号中。仅对ver和hex模式有效。
	* 对于ver模式，原汇编代码和标签在`//`符号后以verilog注释的形式存在。
	* 对于hex模式，原汇编代码和标签在`|`符号后。

[^command]: `[]`内为可选参数，`/`表示参数的或关系，`<>`内为说明。
