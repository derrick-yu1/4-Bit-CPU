# 4-Bit-CPU
By Derrick Yu and Alex Liu </br>
ECE-251 Professor Marano

## Introduction
	A 4-bit CPU and a 16 by 8 RAM in a von Neumann computer architecture was designed using Verilog. The CPU was modeled after the SAP computer series taught in Digital Computer Electronics by Malvino and Brown. However, this CPU has a different overall instruction set from all architectures because of its limited but useful 4 bit opcodes and the Verilog simulation had to be designed from scratch. The priority was for the CPU to be capable of doing arithmetic/logical operations, load/store, unconditional jump and unconditional/conditional branch and link. These operations are highlighted in the ultimate Fibonacci code that will be presented later. Despite being a 4 bit CPU with the ALU operand being 4 bits, all instructions (and as a result RAM word width) are 8 bits (upper nibble is the opcode and lower nibble is the operand), therefore requiring an 8 bit data bus. 
