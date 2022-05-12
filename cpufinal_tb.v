`timescale 1ns / 1ps

`include "cpu_final.v"

module test;

reg Reset = 1;
reg Clock = 1;
reg [7:0] data;
reg We1 = 1;
reg [3:0] addr;
reg Extern = 0;
reg a = 0; //Multiplexer select to change between RUN mode or PROGRAMMING mode
reg Lip = 0;
wire [3:0] Qp, Qm, Qa, Qb, Qc, Ib, Qalu, Qo;
wire [7:0] Qi, Content;
wire Lp, Cp, Ep, Lm, Cs, Li, Ei, La, Ea, We, Lc, Ec, Mtwo, Mone, Mzero, Lib, Ealu, Lz, Lo, Stop, Zeroflag;
tri [3:0] BusWires1;
tri [3:0] BusWires2;
wire [2:0] Tstate;
wire [3:0] Addr;

/*RAM Contents - Machine Code (Fibonacci)*/
 /*****Address*****/    /**Instruction or Data**/
reg addr0 = 4'b0000; reg [7:0] data0 = 8'b10111111; //STORE A15
reg addr1 = 4'b0001; reg [7:0] data1 = 8'b00001110; //ADD A14 (A13 + A14)
reg addr2 = 4'b0010; reg [7:0] data2 = 8'b11100000; //OUTPUT
reg addr3 = 4'b0011; reg [7:0] data3 = 8'b10111101; // STORE A13
reg addr4 = 4'b0100; reg [7:0] data4 = 8'b10001101; //LOAD A13
reg addr5 = 4'b0101; reg [7:0] data5 = 8'b10111111; //STORE A15
reg addr6 = 4'b0110; reg [7:0] data6 = 8'b00001110; //ADD A14 (A13 + A14) 
reg addr7 = 4'b0111; reg [7:0] data7 = 8'b11100000; // OUTPUT
reg addr8 = 4'b1000; reg [7:0] data8 = 8'b10111101; // STORE A13
reg addr9 = 4'b1001; reg [7:0] data9 = 8'b10001111; //LOAD A13
reg addr10 = 4'b1010; reg [7:0] data10 = 8'b10111110; //LOAD A14
reg addr11 = 4'b1011; reg [7:0] data11 = 8'b10101100; //JUMP A12
reg addr12 = 4'b1100; reg [7:0] data12 = 8'b00000100; //Address 0100
reg addr13 = 4'b1101; reg [7:0] data13 = 8'b00000000; //Immediate 0
reg addr14 = 4'b1110; reg [7:0] data14 = 8'b00000001; //Immediate 1
reg addr15 = 4'b1111; reg [7:0] data15 = 8'b00000001; //Immediate 1

always #1 Clock = !Clock;

cpu cpu2 (Reset, Clock, Extern, data, Addr, addr, We1, a, BusWires1, BusWires2, Lip, Qp, Qm, Content, Qi, Qa, Qc, Qalu, Qo, Ib, Lp, Cp, Ep, Lm, Cs, Li, Ei, La, Ea, We, Lc, Ec, Mtwo, One, Mzero, Lib, Ealu, Lz, Lo, Stop, Tstate, Zeroflag);

initial
        /*Print out contents of all modules, including the instruction word for each instant in time*/
        //$monitor("At time %t, Clock = %b, Reset = %b State = %b, PC = %b, Data Path = %b%b, MAR = %b, Addr = %b, Content = %b, IR = %b, Qa = %d, Qc = %b, Qalu = %b, Ib = %b, Zeroflag = %b, Output = %d", $time, Clock, Reset, Tstate, Qp, BusWires2, BusWires1, Qm, Addr, Content, Qi, Qa, Qc, Qalu, Ib, Zeroflag, Qo);
        
        /*Print out the contents of only the accumulator and the output register*/
        $monitor("At time %t, Clock = %b, State = %d, Qa = %d, Output = %d", $time, Clock, Tstate, Qa, Qo);


/*Create .vcd file for GTKWave*/
/*Reset CPU. The CPU will be resetted until time = 39.*/
initial 
begin
        $dumpfile("cpuf.vcd");
        $dumpvars(0, test);
        # 39 Reset = 0; //Turn off reset
        # 550 $finish; //This may be adjusted depending on the length of the program
end

/*Load machine code into RAM each address at a time*/
/*Program Mode*/
initial
begin
    data = data0;
    addr = 4'b000;
    #2;
    data = data1;
    addr = 4'b0001;
    #2;
    data = data2;
    addr = 4'b0010;
    #2;
    data = data3;
    addr = 4'b0011;
    #2;
    data = data4;
    addr = 4'b0100;
    #2;
    data = data5;
    addr = 4'b0101;
    #2;
    data = data6;
    addr = 4'b0110;
    #2;
    data = data7;
    addr = 4'b0111;
    #2;
    data = data8;
    addr = 4'b1000;
    #2;
    data = data9;
    addr = 4'b1001;
    #2;
    data = data10;
    addr = 4'b1010;
    #2;
    data = data11;
    addr = 4'b1011;
    #2;
    data = data12;
    addr = 4'b1100;
    #2;
    data = data13;
    addr = 4'b1101;
    #2;
    data = data14;
    addr = 4'b1110;
    #2;
    data = data15;
    addr = 4'b1111;
    #2;
    We1 = 0;
end

/*Enter RUN mode*/
initial
begin
    # 37 a = 1; //Select RUN mode
    # 550 $finish;
end

endmodule

