`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/15 01:24:36
// Design Name: aggregate cost
// Module Name: test_overflow
// Project Name: aggregate cost
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


module test_overflow();
    reg [7:0] hello;
    wire [8:0] A1;
    wire [7:0] A2;
    wire [7:0] A3;
    // reg [7:0] A3_1;
    // reg [7:0] A3_2;
    // reg [7:0] A3_3;
    reg clk;
    
    
    initial begin
        hello = ~0;
        clk = 0;
    end
    
    overflow_tb_mod u(
    .clk(clk),
    .hello(hello),
    .A1(A1),
    .A2(A2),
    .A3(A3)
    );
    
    always #1 clk = ~clk;
    always @ (posedge clk) begin
        hello <= ~0;
    end
    /*
    always @ (posedge clk) begin
        A1 <= hello + P1;
        A2 <= hello + P1;
        A3 <= ((hello + P1) > 255) ? 255 : (hello+P1);
        A3_1 <= A3;
        A3_2 <= A3_1;
        A3_3 <= A3_2;
    end
    */
endmodule
