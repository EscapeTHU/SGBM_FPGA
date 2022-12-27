`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/11/21 20:16:23
// Design Name: origin_cost
// Module Name: tb_Hamming
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


module tb_Hamming();

    reg sys_clk;
    reg unsigned [31:0] x;
    reg unsigned [31:0] y;
    wire [7:0] hamming;
    
    initial begin
        sys_clk = 0;
        x = 10;
        y = 5;
    end
    always #10 sys_clk = ~sys_clk;
    Hamming my_Hamming(
        .clk(sys_clk),
        .x(x),
        .y(y),
        .res(hamming)
    );
endmodule
