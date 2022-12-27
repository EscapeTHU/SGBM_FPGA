`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/17 15:19:30
// Design Name: project_sgbm
// Module Name: sgbm
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


module sgbm(
    input clk,
    input rst,
    input en,
    input [7:0] grey_left,
    input [7:0] grey_right,
    input [9:0] grey_row_left,
    input [9:0] grey_col_left,
    input [9:0] grey_row_right,
    input [9:0] grey_col_right,
    output [863:0] cost_aggr,
    output [9:0] aggr_row,
    output [9:0] aggr_col,
    output aggr_valid
    );
    
    parameter image_row = 200;
    parameter image_col = 400;
    
    wire [31:0] left_census;
    wire [31:0] right_census;
    wire [9:0] census_row_left;
    wire [9:0] census_col_left;
    wire [9:0] census_row_right;
    wire [9:0] census_col_right;
    wire census_valid_left;
    wire census_valid_right;
    wire [863:0] org_cost;
    wire [9:0] org_cost_row;
    wire [9:0] org_cost_col;
    wire org_cost_valid;
    wire [19:0] test_cnt_left;
    wire [19:0] test_cnt_right;
    
    census u_census_left(
    .clk(clk),
    .rst(rst),
    .en(en),
    .inData(grey_left),
    .row_in(grey_row_left),
    .col_in(grey_col_left),
    .outData(left_census),
    .row_out(census_row_left),
    .col_out(census_col_left),
    .valid(census_valid_left),
    .test_cnt(test_cnt_left)
    );
    
    census u_census_right(
    .clk(clk),
    .rst(rst),
    .en(en),
    .inData(grey_right),
    .row_in(grey_row_right),
    .col_in(grey_col_right),
    .outData(right_census),
    .row_out(census_row_right),
    .col_out(census_col_right),
    .valid(census_valid_right),
    .test_cnt(test_cnt_right)
    );
    
    origin_cost u_org(
    .clk(clk),
    .rst(rst),
    .en(census_valid_left),
    .left_pix(left_census),
    .right_pix(right_census),
    .row(census_row_left),
    .col(census_col_left),
    .cost(org_cost),
    .out_row(org_cost_row),
    .out_col(org_cost_col),
    .valid(org_cost_valid)
    );
    
    aggregate_cost u_aggr(
    .clk(clk),
    .rst(rst),
    .en(org_cost_valid),
    .cost_init(org_cost),
    .row(org_cost_row),
    .col(org_cost_col),
    .cost_aggr(cost_aggr),
    .out_row(aggr_row),
    .out_col(aggr_col),
    .valid(aggr_valid)
    );
endmodule
