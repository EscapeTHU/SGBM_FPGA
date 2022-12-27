`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/16 08:55:36
// Design Name: aggregate cost
// Module Name: delay_buffer
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


module delay_buffer(
    input clk,
    input rst,
    input en,
    input [863:0] data_in,
    input [9:0] row_in,
    input [9:0] col_in,
    output reg valid,
    output reg [863:0] data_out,
    output reg [9:0] row_out,
    output reg [9:0] col_out
    );
    
    parameter min_disparity = 20;
    parameter max_disparity = 128;
    parameter disp_range = 108;
    parameter frame_width = 400;
    parameter frame_height = 200;
    parameter pixel_width = 8;
    parameter P1 = 9'd10;
    
    reg [19:0] input_cnt;
    reg [5:0] output_cnt;
    reg [863:0] my_buf;
    
endmodule
