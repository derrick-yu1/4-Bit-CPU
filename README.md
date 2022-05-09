# 4-Bit-CPU
By Derrick Yu and Alex Liu </br>
ECE-251 Professor Marano

## Introduction
A 4-bit CPU and a 16 by 8 RAM in a von Neumann computer architecture was designed using Verilog. The CPU was modeled after the SAP computer series taught in *Digital Computer Electronics* by Malvino and Brown. However, this CPU has a different overall instruction set from all architectures because of its limited but useful 4 bit opcodes and the Verilog simulation had to be designed from scratch. The priority was for the CPU to be capable of doing arithmetic/logical operations, load/store, unconditional jump and unconditional/conditional branch and link. These operations are highlighted in the ultimate Fibonacci code that will be presented later. Despite being a 4 bit CPU with the ALU operand being 4 bits, all instructions (and as a result RAM word width) are 8 bits (upper nibble is the opcode and lower nibble is the operand), therefore requiring an 8 bit data bus. 

## Description of Each Module
1. Program Counter: Register that holds the address of the next instruction in memory. It is positively edge triggered with three control pins
  - Lp - Load the program counter from the bus
  - Cp - Increment the program counter 
  - Ep - Output the program counter onto the bus
2. Memory Address Register (MAR): Register that holds the address of the current instruction. It is positively edge triggered with two control pins
  - Lm - Load MAR from the bus from the bus
  - Em - Output MAR onto the bus 
3. RAM: Stores data and instructions. It is positively edge triggered with two control pins
  - Cs - Output RAM in Read mode
  - We - Read RAM or Write to RAM
4. Instruction Register: Register that holds the instruction. It is positively edge triggered with two control pins
  - Li - Load the instruction register from the bus
  - Ei - Output the instruction register onto the bus
5. Control Unit: It decodes the opcode from the instruction and controls all control pins of all modules. It is negatively edge triggered. 
6. Accumulator: Register that stores the result of an ALU operation. It is positively edge triggered with two control pins
  - La - Load the accumulator from the bus
  - Ea - Output the accumulator onto the bus
7. ALU: Performs arithmetic and logical operations. It has three control pins grouped as a single“Select” control
  - ALU Select (M2M1M0)
8. ALU Input Register: Register that holds the data that will be used to perform an operation by the ALU with the content in the accumulator. It is positively edge triggered with one control pin
  - Lib - Load IB from the bus
9. Return Address Register: Register that holds the address of the instruction that the program will return to after branching. It is positively edge triggered with two control pins
  - Lc - Load the return address register from the bus
  - Ec - Output the return address register onto the bus
10. Output Register: Register that holds the content that the user wants to be outputted from the accumulator. It is positively edge triggered with one control pin
  - Lo - Load the output register from the bus

## Instruction Set Architecture
| Instruction Name     | Addressing      | Opcode | Format   
| ------------- | ------------- | --------    | ---------- |
| ADD | Direct | 0000 | ADD (Address) |
| SUB | Direct | 0001 | SUB (Address) |
| MUL | Direct | 0010 | MUL (Address) |
| DIV | Direct | 0011 | DIV (Address) |
| NOT | Direct | 0100 | NOT (Address) | 
| AND | Direct | 0101 | AND (Address) |
| OR | Direct | 0110 | OR (Address) | 
| STOP | Implied | 0111 | STOP |
| LOAD | Direct | 1000 | LOAD (Address) |
| BRLINKZ | Direct | 1001 | BRLINKZ (Address) |
| JUMP | Direct | 1010 | JUMP (Address) |
| STORE | Direct | 1011 | STORE (Address) |
| BRLINK | Direct | 1101 | BRLINK (Address) |
| OUTPUT | Implied | 1110 | OUTPUT |
| BRR | Implied | 1111 | BRR |

## Description of Each Instruction
ADD - Add the data stored in the address (operand) to the data in the accumulator 
SUB - Subtract the data stored in the address (operand) to the data in the accumulator
MUL - Multiply the data stored in the address (operand) to the data in the accumulator
DIV - Divide the data stored in the address (operand) to the data in the accumulator
NOT - Bit NOT the data stored in the address (operand) with the data in the accumulator
AND - Bit AND the data stored in the address (operand) with the data in the accumulator
OR - Bit OR the data stored in the address (operand) with the data in the accumulator
STOP - Stop the clock
LOAD - Load the data stored in the address (operand) to the accumulator
BRLINKZ - If the zero flag of the accumulator is 1, branch to a procedure to the address stored in the operand of the instruction and load the return address to the return address register
JUMP - Jump to a instruction to the address stored in the operand of the instruction
STORE - Store the data in the accumulator to the address in the operand of the instruction
BRLINK - Branch to a procedure to the address stored in the operand of the instruction and load the return address to the return address register
OUTPUT - Load the data stored in the accumulator to the output register 
BRR - Return to the address in the return address register


As you can see, the majority of the instructions have a direct addressing mode. This means that the assembly code will be in terms of ADDRESSES in the RAM module, not registers like more advanced architectures. For example, the instruction “ADD A15”, means “add whatever is in address 1111 in your RAM to whatever is in the accumulator”. If the number 5 is in address 1111, running “ADD A15” will add +5 to the accumulator. When you program your own code, you have the freedom of adding any constant that you like, but the addresses of the constants must be higher than the addresses of the instructions. (NOTE THE MEMORY HIERARCHY)
