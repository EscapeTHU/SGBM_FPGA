`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/17 16:46:29
// Design Name: project_sgbm
// Module Name: sgbm_system
// Project Name: project_sgbm
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


module sgbm_system(
    input clk,
    input rst,
    output [863:0] sgbm_cost,
    output [9:0] sgbm_row,
    output [9:0] sgbm_col,
    output sgbm_valid
    );
    
    parameter image_row = 200;
    parameter image_col = 400;
    
    wire ctrl_en;
    wire [7:0] grey_left;
    wire [7:0] grey_right;
    wire [9:0] grey_row_left;
    wire [9:0] grey_col_left;
    wire [9:0] grey_row_right;
    wire [9:0] grey_col_right;
    
    sgbm_ctrl u_ctrl(
    .clk(clk),
    .rst(rst),
    .grey_left(grey_left),
    .grey_right(grey_right),
    .grey_row_left(grey_row_left),
    .grey_col_left(grey_col_left),
    .grey_row_right(grey_row_right),
    .grey_col_right(grey_col_right),
    .valid(en)
    );
    
    sgbm u_calc(
    .clk(clk),
    .rst(rst),
    .en(en),
    .grey_left(grey_left),
    .grey_right(grey_right),
    .grey_row_left(grey_row_left),
    .grey_col_left(grey_col_left),
    .grey_row_right(grey_row_right),
    .grey_col_right(grey_col_right),
    .cost_aggr(sgbm_cost),
    .aggr_row(sgbm_row),
    .aggr_col(sgbm_col),
    .aggr_valid(sgbm_valid)
    );
    
endmodule
