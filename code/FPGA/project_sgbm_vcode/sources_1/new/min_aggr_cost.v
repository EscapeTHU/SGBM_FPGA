`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: Tengyu Zhang (EscapeTHU)
// 
// Create Date: 2022/12/17 09:27:24
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


module min_aggr_cost(
    input clk,
    input rst,
    input [863:0] data_in,
    output reg [7:0] min_aggr
    );
    
    parameter min_disparity = 20;
    parameter max_disparity = 128;
    parameter disp_range = 108;
    parameter pixel_width = 8;
    parameter P1 = 9'd10;
    
    reg [863:0] aggr_in;
    reg [431:0] aggr_min_lv1;
    reg [215:0] aggr_min_lv2;
    reg [111:0] aggr_min_lv3;
    reg [55:0] aggr_min_lv4;
    reg [31:0] aggr_min_lv5;
    reg [15:0] aggr_min_lv6;
    integer i_lv1, i_lv2, i_lv3, i_lv4, i_lv5, i_lv6;
    
    initial begin
        aggr_in <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        aggr_min_lv1 <= 432'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        aggr_min_lv2 <= 216'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        aggr_min_lv3 <= 112'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        aggr_min_lv4 <= 56'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        aggr_min_lv5 <= 32'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        aggr_min_lv6 <= 16'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        min_aggr <= 8'hFF;
    end
    
    always @ (posedge clk) begin
        if (rst) begin
            aggr_in <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            aggr_min_lv1 <= 432'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            aggr_min_lv2 <= 216'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            aggr_min_lv3 <= 112'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            aggr_min_lv4 <= 56'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            aggr_min_lv5 <= 32'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            aggr_min_lv6 <= 16'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            min_aggr <= 8'hFF;
        end
        else begin
            // tictoc #1 initialization
            aggr_in <= data_in;
        
            // tictoc #2 calc_level_1
            for (i_lv1 = 0; i_lv1 < 54; i_lv1 = i_lv1 + 1) begin
                aggr_min_lv1[pixel_width*i_lv1+:pixel_width] <= (aggr_in[pixel_width*2*i_lv1+:pixel_width] < aggr_in[pixel_width*(2*i_lv1+1)+:pixel_width]) ? aggr_in[pixel_width*2*i_lv1+:pixel_width] : aggr_in[pixel_width*(2*i_lv1+1)+:pixel_width];
            end
        
            // tictoc #3 calc_level_2
            for (i_lv2 = 0; i_lv2 < 27; i_lv2 = i_lv2 + 1) begin
                aggr_min_lv2[pixel_width*i_lv2+:pixel_width] <= (aggr_min_lv1[pixel_width*2*i_lv2+:pixel_width] < aggr_min_lv1[pixel_width*(2*i_lv2+1)+:pixel_width]) ? aggr_min_lv1[pixel_width*2*i_lv2+:pixel_width] : aggr_min_lv1[pixel_width*(2*i_lv2+1)+:pixel_width];
            end
        
            // tictoc #4 calc_level_3
            for (i_lv3 = 0; i_lv3 < 14; i_lv3 = i_lv3 + 1) begin
                if (i_lv3 == 13) begin
                    aggr_min_lv3[pixel_width*i_lv3+:pixel_width] <= aggr_min_lv2[208+:pixel_width];
                end
                else begin
                    aggr_min_lv3[pixel_width*i_lv3+:pixel_width] <= (aggr_min_lv2[pixel_width*2*i_lv3+:pixel_width] < aggr_min_lv2[pixel_width*(2*i_lv3+1)+:pixel_width]) ? aggr_min_lv2[pixel_width*2*i_lv3+:pixel_width] : aggr_min_lv2[pixel_width*(2*i_lv3+1)+:pixel_width];
                end
            end
        
            // tictoc #5 calc_level_4
            for (i_lv4 = 0; i_lv4 < 7; i_lv4 = i_lv4 + 1) begin
                aggr_min_lv4[pixel_width*i_lv4+:pixel_width] <= (aggr_min_lv3[pixel_width*2*i_lv4+:pixel_width] < aggr_min_lv3[pixel_width*(2*i_lv4+1)+:pixel_width]) ? aggr_min_lv3[pixel_width*2*i_lv4+:pixel_width] : aggr_min_lv3[pixel_width*(2*i_lv4+1)+:pixel_width];
            end
        
            // tictoc #6 calc_level_5
            for (i_lv5 = 0; i_lv5 < 4; i_lv5 = i_lv5 + 1) begin
                if (i_lv5 == 3) begin
                    aggr_min_lv5[pixel_width*i_lv5+:pixel_width] <= aggr_min_lv4[48+:pixel_width];
                end
                else begin
                    aggr_min_lv5[pixel_width*i_lv5+:pixel_width] <= (aggr_min_lv4[pixel_width*2*i_lv5+:pixel_width] < aggr_min_lv4[pixel_width*(2*i_lv5+1)+:pixel_width]) ? aggr_min_lv4[pixel_width*2*i_lv5+:pixel_width] : aggr_min_lv4[pixel_width*(2*i_lv5+1)+:pixel_width];
                end
            end
        
            // tictoc #7 calc_level_6
            for (i_lv6 = 0; i_lv6 < 2; i_lv6 = i_lv6 + 1) begin
                aggr_min_lv6[pixel_width*i_lv6+:pixel_width] <= (aggr_min_lv5[pixel_width*2*i_lv6+:pixel_width] < aggr_min_lv5[pixel_width*(2*i_lv6+1)+:pixel_width]) ? aggr_min_lv5[pixel_width*2*i_lv6+:pixel_width] : aggr_min_lv5[pixel_width*(2*i_lv6+1)+:pixel_width];
            end
        
            // tictoc #8 calc_final_min
            min_aggr <= (aggr_min_lv6[0+:pixel_width] < aggr_min_lv6[pixel_width+:pixel_width]) ? aggr_min_lv6[0+:pixel_width] : aggr_min_lv6[pixel_width+:pixel_width];
        end
    end
    
endmodule
