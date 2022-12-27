`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/15 03:53:04
// Design Name: aggregate cost
// Module Name: overflow_tb_mod
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


module overflow_tb_mod(
    input clk,
    input [7:0] hello,
    output reg [8:0] A1,
    output reg [7:0] A2,
    output reg [7:0] A3
    );
    parameter  P1 = 9'b10;
    always @ (posedge clk) begin
        A1 <= hello + P1;
        A2 <= hello + P1;
        A3 <= ((hello + P1) > 255) ? 255 : (hello+P1);
    end
endmodule
