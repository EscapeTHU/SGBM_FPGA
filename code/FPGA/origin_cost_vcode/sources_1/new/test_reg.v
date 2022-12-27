`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/11/21 22:38:04
// Design Name: origin_cost
// Module Name: test_reg
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


module test_reg(
    input clk,
    input [15:0] A,
    output reg [15:0] outData,
    output reg [15:0] B
    );
    
    integer i;
    
    initial begin
        outData = 0;
        B = 0;
    end
    always @ (posedge clk) begin
        B <= A;
        B[0+:4] <= 4'b0000;
        for (i = 0; i < 4; i = i+1)
            outData[(12-4*i)+:4] <= A[(12-4*i)+:4];
    end
endmodule
