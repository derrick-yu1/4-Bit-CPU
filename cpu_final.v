/*4 Bit CPU - By Derrick Yu and Alex Liu */
/*ECE-251 - Professor Marano*/


/*Program Counter*/
module pc (R, Reset, L, C, Clock, Q);
parameter n = 4;
input [n-1:0] R;
input Reset, L, C, Clock;
output reg [n-1:0] Q;

always @(negedge Reset, posedge Clock)
        if (Reset)
                Q <= 0;
        else if (L)
                Q <= R;
        else if (C)
                Q <= Q + 1;
endmodule


/*n-bit Register*/
module regn (R, L, Clock, Q, Reset);
parameter n = 4;
input [n-1:0] R;
input L, Clock, Reset;
output reg [n-1:0] Q;

always @(posedge Clock)
        if (L)
                Q <= R;
        else if (Reset)
                Q <= 0;
endmodule


/*n-bit Tri-State Logic*/
module trin (R, E, Q);
parameter n = 4;
input [n-1:0] R;
input E;
output wire [n-1:0] Q;

assign Q = E ? R : 'bz;
endmodule


/*4 Bit ALU*/
module alu (A, B, ALU_Sel, ALU_Out, Zeroflag);
input [3:0] A, B;
input [2:0] ALU_Sel;
output reg [3:0] ALU_Out;
output Zeroflag;

always @(A, B, ALU_Sel)
        case (ALU_Sel)
                3'b000:
                        ALU_Out = A + B;
                3'b001:
                        ALU_Out = A - B;
                3'b010:
                        ALU_Out = A * B;
                3'b011:
                        ALU_Out = A/B;
                3'b100:
                        ALU_Out = A & B;
                3'b101:
                        ALU_Out = A | B;
                3'b110:
                        ALU_Out = ~ A;
                3'b111:
                        ALU_Out = A ^ B;
                default: ALU_Out = 4'bxxxx;
        endcase

assign Zeroflag = (ALU_Out == 4'b0000);

endmodule


/*RAM Module and Multiplexers to switch between Run Mode or Programming Mode*/
module ram (Data, Addr, we, Clock, q);

input [7:0] Data;
input [3:0] Addr;
input we;
input Clock;
output reg [7:0] q;

reg [7:0] ram [15:0];

always @(negedge Clock)
begin
    if (we)
        ram[Addr] <= Data;
    else
        q <= ram[Addr];
end
endmodule

module mux (x, y, a, z);
parameter n = 4;
input [n - 1:0] x;
input a;
input [n - 1:0] y;
output reg [n - 1:0] z;
always @(*) 
    if (a)
        z <= x;
    else
        z <= y;
endmodule


/*Counter (1-6) for Control Unit*/
/*Each instruction will take six clock cycles. Each individual cycle will have a specific purpose within the architecture of the program. Therefore, 
each cycle of a instruction will be given a label "T", which represents the state of the instruction*/
module counter(Clock, Reset, Y);
input Clock, Reset;
reg [2:0] y;
output reg [2:0] Y;
parameter [2:0] A = 3'b001, B = 3'b010, C = 3'b011, D = 3'b100, E = 3'b101, F = 3'b110; //Six cycles or states ("T states") -> 6 Cycles per instruction
/*A = T1, B = T2, C = T3, D = T4, E = T5, F = T6*/

always @(Y)
        case (Y)
                A: y = B;
                B: y = C;
                C: y = D;
                D: y = E;
                E: y = F;
                F: y = A;
                default y = 3'bxxx;
        endcase

always @(negedge Reset, negedge Clock)
        if (Reset == 1) Y <= A;
        else Y <= y;

endmodule


/*Control Unit (Control Path)*/
module controller (Opcode, Tstate, Zeroflag, Lp, Cp, Ep, Lm, Cs, Li, Ei, La, Ea, We, Lc, Ec, Mtwo, Mone, Mzero, Lib, Ealu, Lz, Lo, Stop);
input [3:0] Opcode;
input [2:0] Tstate; //Output of 1-6 Counter 
input Zeroflag;
wire [6:0] address = {Opcode, Tstate}; //Instruction word depends on the opcode and the state from the 1-6 counter
reg [20:0] inter; //Instruction Word 
output Lp, Cp, Ep, Lm, Cs, Li, Ei, La, Ea, We, Lc, Ec, Mtwo, Mone, Mzero, Lib, Ealu, Lz, Lo, Stop;
/*The above control signals form the instruction word during each clock cycle depending on the opcode and the specific state from the counter
 (first cycle to the sixth cycle)*/
/*Description of each control signal can be found at the end of the module*/

always @(address)
        case (address)
                7'bxxxx001: inter = 20'b00110000000000000000; //T1
                7'bxxxx010: inter = 20'b01000000000000000000; //T2
                7'bxxxx011: inter = 20'b00001100000000000000; //T3
                7'b1000001: inter = 20'b00110000000000000000; //LOAD T1
                7'b1000010: inter = 20'b01000000000000000000; //LOAD T2
                7'b1000011: inter = 20'b00001100000000000000; //LOAD T3
                7'b1000100: inter = 20'b00010010000000000000; //LOAD T4
                7'b1000101: inter = 20'b00001001000000000000; //LOAD T5
                7'b1000110: inter = 20'b00000000000000000000; //LOAD T6
                7'b1110001: inter = 20'b00110000000000000000; //OUTPUT T1
                7'b1110010: inter = 20'b01000000000000000000; //OUTPUT T2
                7'b1110011: inter = 20'b00001100000000000000; //OUTPUT T3
                7'b1110100: inter = 20'b00010010000000000000; //OUTPUT T4
                7'b1110101: inter = 20'b00000000100000000010; //OUTPUT T5
                7'b1110110: inter = 20'b00000000000000000000; //OUTPUT T6
                7'b1010001: inter = 20'b00110000000000000000; //JUMP T1
                7'b1010010: inter = 20'b01000000000000000000; //JUMP T2
                7'b1010011: inter = 20'b00001100000000000000; //JUMP T3
                7'b1010100: inter = 20'b00010010000000000000; //JUMP T4
                7'b1010101: inter = 20'b10001000000000000000; //JUMP T5
                7'b1010110: inter = 20'b00000000000000000000; //JUMP T6
                7'b1101001: inter = 20'b00110000000000000000; //BRLINK T1
                7'b1101010: inter = 20'b01000000000000000000; //BRLINK T2
                7'b1101011: inter = 20'b00001100000000000000; //BRLINK T3
                7'b1101100: inter = 20'b00100000001000000000; //BRLINK T4
                7'b1101101: inter = 20'b00010010000000000000; //BRLINK T5
                7'b1101110: inter = 20'b10001000000000000000; //BRLINK T6
                7'b1111001: inter = 20'b00110000000000000000; //BRR T1
                7'b1111010: inter = 20'b01000000000000000000; //BRR T2
                7'b1111011: inter = 20'b00001100000000000000; //BRR T3
                7'b1111100: inter = 20'b10000000000100000000; //BRR T4
                7'b1111101: inter = 20'b00000000000000000000; //BRR T5
                7'b1111110: inter = 20'b00000000000000000000; //BRR T6
                7'b0000001: inter = 20'b00110000000000000000; //ADD T1
                7'b0000010: inter = 20'b01000000000000000000; //ADD T2
                7'b0000011: inter = 20'b00001100000000000000; //ADD T3
                7'b0000100: inter = 20'b00010010000000000000; //ADD T4
                7'b0000101: inter = 20'b00001000000000010100; //ADD T5
                7'b0000110: inter = 20'b00000001000000001000; //ADD T6
                7'b0001001: inter = 20'b00110000000000000000; //SUB T1
                7'b0001010: inter = 20'b01000000000000000000; //SUB T2
                7'b0001011: inter = 20'b00001100000000000000; //SUB T3
                7'b0001100: inter = 20'b00010010000000000000; //SUB T4
                7'b0001101: inter = 20'b00001000000000110000; //SUB T5
                7'b0001110: inter = 20'b00000001000000101100; //SUB T6
                7'b0010001: inter = 20'b00110000000000000000; //MUL T1
                7'b0010010: inter = 20'b01000000000000000000; //MUL T2
                7'b0010011: inter = 20'b00001100000000000000; //MUL T3
                7'b0010100: inter = 20'b00010010000000000000; //MUL T4
                7'b0010101: inter = 20'b00001000000001010100; //MUL T5
                7'b0010110: inter = 20'b00000001000001001000; //MUL T6
                7'b0011001: inter = 20'b00110000000000000000; //DIV T1
                7'b0011010: inter = 20'b01000000000000000000; //DIV T2
                7'b0011011: inter = 20'b00001100000000000000; //DIV T3
                7'b0011100: inter = 20'b00010010000000000000; //DIV T4
                7'b0011101: inter = 20'b00001000000001110100; //DIV T5
                7'b0011110: inter = 20'b00000001000001101000; //DIV T6
                7'b0100001: inter = 20'b00110000000000000000; //NOT T1
                7'b0100010: inter = 20'b01000000000000000000; //NOT T2
                7'b0100011: inter = 20'b00001100000000000000; //NOT T3
                7'b0100100: inter = 20'b00010010000000000000; //NOT T4
                7'b0100101: inter = 20'b00001000000011010100; //NOT T5
                7'b0100110: inter = 20'b00000001000011001000; //NOT T6
                7'b0101001: inter = 20'b00110000000000000000; //AND T1
                7'b0101010: inter = 20'b01000000000000000000; //ADD T2
                7'b0101011: inter = 20'b00001100000000000000; //ADD T3
                7'b0101100: inter = 20'b00010010000000000000; //ADD T4
                7'b0101101: inter = 20'b00001000000010010100; //ADD T5
                7'b0101110: inter = 20'b00000001000010001000; //ADD T6
                7'b0110001: inter = 20'b00110000000000000000; //OR T1
                7'b0110010: inter = 20'b01000000000000000000; //OR T2
                7'b0110011: inter = 20'b00001100000000000000; //OR T3 
                7'b0110100: inter = 20'b00010010000000000000; //OR T4
                7'b0110101: inter = 20'b00001000000010110100; //OR T5
                7'b0110110: inter = 20'b00000001000010101000; //OR T6
                7'b0111001: inter = 20'b00110000000000000000; //STOP T1
                7'b0111010: inter = 20'b01000000000000000000; //STOP T2
                7'b0111011: inter = 20'b00001100000000000000; //STOP T3
                7'b0111100: inter = 20'b00000000000000000001; //STOP T4
                7'b1011001: inter = 20'b00110000000000000000; //STORE T1
                7'b1011010: inter = 20'b01000000000000000000; //STORE T2
                7'b1011011: inter = 20'b00001100000000000000; //STORE T3
                7'b1011100: inter = 20'b00010010000000000000; //STORE T4
                7'b1011101: inter = 20'b00000000110000000000; //STORE T5 
                7'b1011110: inter = 20'b00000000000000000000; //STORE T6
                7'b1001001: inter = 20'b00110000000000000000; //BRLINKZ T1
                7'b1001010: inter = 20'b01000000000000000000; //BRLINKZ T2
                7'b1001011: inter = 20'b00001100000000000000; //BRLINKZ T3
                7'b1001100: if (Zeroflag) inter = 20'b00100000001000000000; //BRLINKZ T4
                            else inter = 20'b00000000000000000000;
                7'b1001101: if (Zeroflag) inter = 20'b00011010000000000000; //BRLINKZ T5
                            else inter = 20'b00000000000000000000;
                7'b1001110: if (Zeroflag) inter = 20'b10001000000000000000; //BRLINKZ T6
                            else inter = 20'b00000000000000000000;
                default inter = 20'bxxxxxxxxx0xxxxxxxxxx;
        endcase

assign Lp = inter[20:19]; //Load the program counter with the content from the bus
assign Cp = inter[19:18]; //Increment the program counter
assign Ep = inter[18:17]; //Put the content of the program counter onto the bus
assign Lm = inter[17:16]; //Load the memory address register with the content from the bus
assign Cs = inter[16:15]; //Enable RAM
assign Li = inter[15:14]; //Load the instruction register with the content from the bus
assign Ei = inter[14:13]; //Put the content of the program counter onto the bus
assign La = inter[13:12]; //Load the accumalator with the content from the bus
assign Ea = inter[12:11]; //Put the content of the accumulator onto the bus
assign We = inter[11:10]; //Write enable of RAM
assign Lc = inter[10:9]; //Load the return address register with the content from the bus
assign Ec = inter[9:8]; //Put the contents of the return address register onto the bus 
assign Mtwo = inter[8:7]; //ALU Select (Third bit)
assign Mone = inter[7:6]; //ALU Select (Second bit)
assign Mzero = inter[6:5]; //ALU Select (First bit)
assign Lib = inter[5:4]; //Load data from RAM into the input register of the ALU
assign Ealu = inter[4:3]; //Put the data from the ALU onto the bus
assign Lz = inter[3:2]; //Enable the Zero flag register 
assign Lo = inter[2:1]; //Load the output register with the content from the bus
assign Stop = inter[1:0]; //Stop signal

endmodule


/*CPU (Datapath)*/
module cpu (Reset, Clock, Extern, Data, Addr, AddrO, We1, a, BusWires1, BusWires2, Lip, Qp, Qm, Content, Qi, Qa, Qc, Qalu, Qo, Ib, Lp, Cp, Ep, Lm, Cs, Li, Ei, La, Ea, We, Lc, Ec, Mtwo, Mone, Mzero, Lib, Ealu, Lz, Lo, Stop, Tstate, Zeroflag2);
parameter n = 4;

//Inputs for programming mode 
input Reset, Clock, Extern, Lip, We1, a; 
input [7:0] Data;
input [3:0] AddrO; 

/*Bus and Control Signals*/
output tri [3:0] BusWires1; //4 Bit components use this bus line
output tri [3:0] BusWires2; //8 bit components use both bus lines
output wire [n-1:0] Qp, Qm, Qa, Qc, Qalu, Qo, Ib;
output wire [7:0] Content;
output wire [2:0] Tstate;
output wire [7:0] Qi;
wire [3:0] opcode = Qi[7:4];
wire [3:0] data = Qi[3:0];
wire Zeroflag; //Input for Zero flag 1 bit register 
output wire Zeroflag2; //Q state of Zero Flag 1 bit register 

wire [7:0] DataM; //Resultant data for RAM module
output wire [3:0] Addr; //Resultant address for RAM module
wire we; //Resultant write enable for RAM

output wire Lp, Cp, Ep, Lm, Cs, Li, Ei, La, Ea, We, Lc, Ec, Mtwo, Mone, Mzero, Lib, Ealu, Lz, Lo, Stop;
wire Clock2 = Clock & (~Stop); //Stop the clock when Stop signal is high

/*Individual Modules within the CPU*/
/*Each module will have its own tri-state logic for the bus interface*/

//Program Counter
pc pc1 (BusWires1, Reset, Lp | Lip, Cp, Clock2, Qp);
trin tri_pc (Qp, Ep, BusWires1);

//Memory Address Register
regn reg_M (BusWires1, Lm, Clock2, Qm, Reset);

/*The following multiplexers are used to set the CPU mode in either programming mode (load object file from testbench) or run mode*/

//Multiplexer for Address for RAM
mux mux_M (Qm, AddrO, a, Addr);

//Multiplexer for Write Enable for RAM
mux mux_W (We, We1, a, we);
defparam mux_W.n = 1;

//Multiplexer for Data for RAM
mux mux_I ({BusWires2, BusWires1}, Data, a, DataM);
defparam mux_I.n = 8;

//RAM Module
ram ram_O (DataM, Addr, we, Clock2, Content);
trin tri_mem (Content, Cs, {BusWires2, BusWires1});
defparam tri_mem.n = 8;

//Instruction Register
regn reg_I ({BusWires2, BusWires1}, Li, Clock2, Qi, Reset);
defparam reg_I.n = 8;
trin tri_I (data, Ei, BusWires1);

//Counter for Control Unit
counter rc (Clock2, Reset, Tstate);
controller ctrl (opcode, Tstate, Zeroflag2, Lp, Cp, Ep, Lm, Cs, Li, Ei, La, Ea, We, Lc, Ec, Mtwo, Mone, Mzero, Lib, Ealu, Lz, Lo, Stop);

//Accumulator
regn reg_A (BusWires1, La, Clock2, Qa, Reset);
trin tri_A (Qa, Ea, BusWires1);

//Return Address Register
regn reg_C (BusWires1, Lc, Clock2, Qc, Reset);
trin tri_C (Qc, Ec, BusWires1);

//ALU 
regn ALU_InputB (BusWires1, Lib, Clock2, Ib, Reset);
alu alu1 (Qa, Ib, {Mtwo, Mone, Mzero}, Qalu, Zeroflag);
trin ALU_Out (Qalu, Ealu, BusWires1);

//Zero Flag 1 Bit Register
regn reg_Z (Zeroflag, Lz, Clock2, Zeroflag2, Reset);
defparam reg_Z.n = 1;

//Output Register
regn reg_O (BusWires1, Lo, Clock2, Qo, Reset);

endmodule




