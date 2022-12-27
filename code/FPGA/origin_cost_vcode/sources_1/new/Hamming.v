`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/11/21 18:42:04
// Design Name: origin_cost
// Module Name: Hamming
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


module Hamming(
    input clk,
    input [31:0] x,
    input [31:0] y,
    output reg [7:0] res
    );
    
    reg [31:0] xy_xor;
    always @ (posedge clk) begin
        xy_xor <= x^y;
        res <= xy_xor[0]+xy_xor[1]+xy_xor[2]+xy_xor[3]+xy_xor[4]+xy_xor[5]+xy_xor[6]+xy_xor[7]+xy_xor[8]+xy_xor[9]+xy_xor[10]+xy_xor[11]+xy_xor[12]+xy_xor[13]+xy_xor[14]+xy_xor[15]+xy_xor[16]+xy_xor[17]+xy_xor[18]+xy_xor[19]+xy_xor[20]+xy_xor[21]+xy_xor[22]+xy_xor[23]+xy_xor[24]+xy_xor[25]+xy_xor[26]+xy_xor[27]+xy_xor[28]+xy_xor[29]+xy_xor[30]+xy_xor[31];
    end
endmodule
