`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/11/21 22:41:54
// Design Name: origin_cost
// Module Name: tb_testReg
// Project Name: origin_cost
// Target Devices: ZCU208
// Tool Versions: Vivado 2021.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_testReg();

    reg sys_clk;
    reg [3:0] A1;
    reg [3:0] A2;
    reg [3:0] A3;
    reg [3:0] A4;
    reg [15:0] A;
    wire [15:0] my_res;
    wire [15:0] B;
    initial begin
        A1 = 4'b1111;
        A2 = 4'b1111;
        A3 = 4'b1111;
        A4 = 4'b1111;
        A = {A1,A2,A3,A4};
        // A[0+:4]=4'b0000;
        sys_clk = 0;
    end
    always #10 sys_clk = ~sys_clk;
    test_reg my_reg(
        .clk(sys_clk),
        .A(A),
        .outData(my_res),
        .B(B)
    );
endmodule
