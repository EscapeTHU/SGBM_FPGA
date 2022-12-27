`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: Tengyu Zhang (EscapeTHU)
// 
// Create Date: 2022/12/17 09:23:43
// Design Name: SGBM algorithm
// Module Name: aggregate_cost
// Project Name: SGBM
// Target Devices: ZCU208
// Tool Versions: Vivado 2021.2
// Description: This module is used to realize sgbm aggregate_cost calculation.
// 
// Dependencies: Non
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module aggregate_cost(
    input clk,
    input rst,
    input en,
    input [863:0] cost_init,
    input [9:0] row,
    input [9:0] col,
    output [863:0] cost_aggr,
    output [9:0] out_row,
    output [9:0] out_col,
    output valid
    );
    
    wire [863:0] cost_aggr_last;
    wire [863:0] cost_aggr_delay;
    wire [863:0] cost_aggr_min;
    wire [9:0] row_delay;
    wire [9:0] col_delay;
    wire [9:0] row_delay_out;
    wire [9:0] col_delay_out;
    wire [7:0] min_aggr;
    wire valid_delay;
    wire valid_delay_out;
    
    assign cost_aggr_delay = cost_aggr;
    assign cost_aggr_min = cost_aggr;
    assign row_delay = out_row;
    assign col_delay = out_col;
    assign valid_delay = valid;
    
    aggregate u_aggr(
    .clk(clk),
    .rst(rst),
    .en(en),
    .cost_init(cost_init),
    .cost_aggr_last(cost_aggr_last),
    .min_aggr_last(min_aggr),
    .row(row),
    .col(col),
    .cost_aggr(cost_aggr),
    .out_row(out_row),
    .out_col(out_col),
    .valid(valid)
    );
    
    delay_aggr #(
    .DATA_WIDTH (864),
    .DIM_WIDTH (10),
    .DELAY_DEEP (8)
    )
    u_delay(
    .clk(clk),
    .rst(rst),
    .data_in(cost_aggr_delay),
    .row_in(row_delay),
    .col_in(col_delay),
    //.en(valid_delay),
    .en(1),
    .data_out(cost_aggr_last),
    .row_out(row_delay_out),
    .col_out(col_delay_out),
    .valid(valid_delay_out)
    );
    
    min_aggr_cost u_min(
    .clk(clk),
    .rst(rst),
    .data_in(cost_aggr_min),
    .min_aggr(min_aggr)
    );
endmodule
