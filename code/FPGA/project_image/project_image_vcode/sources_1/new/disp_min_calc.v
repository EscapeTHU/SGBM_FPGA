`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/22 10:19:20
// Design Name: project_image
// Module Name: disp_min_calc
// Project Name: project_image
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


module disp_min_calc(
    input clk,
    input rst,
    input [863:0] cost_aggr,
    output [7:0] min_cost,
    output [7:0] min_cost_pos
    );
    
    parameter min_disparity = 20;
    parameter max_disparity = 128;
    parameter disp_range = 108;
    parameter pixel_width = 8;
    
    reg [863:0] pos_in;
    reg [863:0] aggr_in;
    
    reg [431:0] aggr_min_lv1;
    reg [431:0] pos_min_lv1;
    
    reg [215:0] aggr_min_lv2;
    reg [215:0] pos_min_lv2;
    
    reg [111:0] aggr_min_lv3;
    reg [111:0] pos_min_lv3;
    
    reg [55:0] aggr_min_lv4;
    reg [55:0] pos_min_lv4;
    
    reg [31:0] aggr_min_lv5;
    reg [31:0] pos_min_lv5;
    
    reg [15:0] aggr_min_lv6;
    reg [15:0] pos_min_lv6;
    
    reg [7:0] min_aggr;
    reg [7:0] pos_min;
        
    integer i_init, i_lv1, i_lv2, i_lv3, i_lv4, i_lv5, i_lv6;
    
    initial begin
        aggr_in <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        aggr_min_lv1 <= 432'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        aggr_min_lv2 <= 216'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        aggr_min_lv3 <= 112'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        aggr_min_lv4 <= 56'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        aggr_min_lv5 <= 32'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        aggr_min_lv6 <= 16'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        min_aggr <= 8'hFF;
        pos_in <= 864'h0;
        pos_min_lv1 <= 432'h0;
        pos_min_lv2 <= 216'h0;
        pos_min_lv3 <= 112'h0;
        pos_min_lv4 <= 56'h0;
        pos_min_lv5 <= 32'h0;
        pos_min_lv6 <= 16'h0;
        pos_min <= 8'h0;
    end
    
    assign min_cost = min_aggr;
    assign min_cost_pos = pos_min;
    
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
            for (i_init = 0; i_init < 108; i_init = i_init + 1) begin
                pos_in[pixel_width*i_init+:pixel_width] <= i_init;
            end
            pos_min_lv1 <= 432'h0;
            pos_min_lv2 <= 216'h0;
            pos_min_lv3 <= 112'h0;
            pos_min_lv4 <= 56'h0;
            pos_min_lv5 <= 32'h0;
            pos_min_lv6 <= 16'h0;
            pos_min <= 8'h0;
        end
        else begin
            // tictoc #1 initialization
            aggr_in <= cost_aggr;
            for (i_init = 0; i_init < 108; i_init = i_init + 1) begin
                pos_in[pixel_width*i_init+:pixel_width] <= i_init;
            end
        
            // tictoc #2 calc_level_1
            for (i_lv1 = 0; i_lv1 < 54; i_lv1 = i_lv1 + 1) begin
                aggr_min_lv1[pixel_width*i_lv1+:pixel_width] <= (aggr_in[pixel_width*2*i_lv1+:pixel_width] < aggr_in[pixel_width*(2*i_lv1+1)+:pixel_width]) ? aggr_in[pixel_width*2*i_lv1+:pixel_width] : aggr_in[pixel_width*(2*i_lv1+1)+:pixel_width];
                pos_min_lv1[pixel_width*i_lv1+:pixel_width] <= (aggr_in[pixel_width*2*i_lv1+:pixel_width] < aggr_in[pixel_width*(2*i_lv1+1)+:pixel_width]) ? pos_in[pixel_width*2*i_lv1+:pixel_width] : pos_in[pixel_width*(2*i_lv1+1)+:pixel_width];
            end
        
            // tictoc #3 calc_level_2
            for (i_lv2 = 0; i_lv2 < 27; i_lv2 = i_lv2 + 1) begin
                aggr_min_lv2[pixel_width*i_lv2+:pixel_width] <= (aggr_min_lv1[pixel_width*2*i_lv2+:pixel_width] < aggr_min_lv1[pixel_width*(2*i_lv2+1)+:pixel_width]) ? aggr_min_lv1[pixel_width*2*i_lv2+:pixel_width] : aggr_min_lv1[pixel_width*(2*i_lv2+1)+:pixel_width];
                pos_min_lv2[pixel_width*i_lv2+:pixel_width] <= (aggr_min_lv1[pixel_width*2*i_lv2+:pixel_width] < aggr_min_lv1[pixel_width*(2*i_lv2+1)+:pixel_width]) ? pos_min_lv1[pixel_width*2*i_lv2+:pixel_width] : pos_min_lv1[pixel_width*(2*i_lv2+1)+:pixel_width];
            end
            
        
            // tictoc #4 calc_level_3
            for (i_lv3 = 0; i_lv3 < 14; i_lv3 = i_lv3 + 1) begin
                if (i_lv3 == 13) begin
                    aggr_min_lv3[pixel_width*i_lv3+:pixel_width] <= aggr_min_lv2[208+:pixel_width];
                    pos_min_lv3[pixel_width*i_lv3+:pixel_width] <= pos_min_lv2[208+:pixel_width];
                end
                else begin
                    aggr_min_lv3[pixel_width*i_lv3+:pixel_width] <= (aggr_min_lv2[pixel_width*2*i_lv3+:pixel_width] < aggr_min_lv2[pixel_width*(2*i_lv3+1)+:pixel_width]) ? aggr_min_lv2[pixel_width*2*i_lv3+:pixel_width] : aggr_min_lv2[pixel_width*(2*i_lv3+1)+:pixel_width];
                    pos_min_lv3[pixel_width*i_lv3+:pixel_width] <= (aggr_min_lv2[pixel_width*2*i_lv3+:pixel_width] < aggr_min_lv2[pixel_width*(2*i_lv3+1)+:pixel_width]) ? pos_min_lv2[pixel_width*2*i_lv3+:pixel_width] : pos_min_lv2[pixel_width*(2*i_lv3+1)+:pixel_width];
                end
            end
        
            // tictoc #5 calc_level_4
            for (i_lv4 = 0; i_lv4 < 7; i_lv4 = i_lv4 + 1) begin
                aggr_min_lv4[pixel_width*i_lv4+:pixel_width] <= (aggr_min_lv3[pixel_width*2*i_lv4+:pixel_width] < aggr_min_lv3[pixel_width*(2*i_lv4+1)+:pixel_width]) ? aggr_min_lv3[pixel_width*2*i_lv4+:pixel_width] : aggr_min_lv3[pixel_width*(2*i_lv4+1)+:pixel_width];
                pos_min_lv4[pixel_width*i_lv4+:pixel_width] <= (aggr_min_lv3[pixel_width*2*i_lv4+:pixel_width] < aggr_min_lv3[pixel_width*(2*i_lv4+1)+:pixel_width]) ? pos_min_lv3[pixel_width*2*i_lv4+:pixel_width] : pos_min_lv3[pixel_width*(2*i_lv4+1)+:pixel_width];
            end
        
            // tictoc #6 calc_level_5
            for (i_lv5 = 0; i_lv5 < 4; i_lv5 = i_lv5 + 1) begin
                if (i_lv5 == 3) begin
                    aggr_min_lv5[pixel_width*i_lv5+:pixel_width] <= aggr_min_lv4[48+:pixel_width];
                    pos_min_lv5[pixel_width*i_lv5+:pixel_width] <= pos_min_lv4[48+:pixel_width];
                end
                else begin
                    aggr_min_lv5[pixel_width*i_lv5+:pixel_width] <= (aggr_min_lv4[pixel_width*2*i_lv5+:pixel_width] < aggr_min_lv4[pixel_width*(2*i_lv5+1)+:pixel_width]) ? aggr_min_lv4[pixel_width*2*i_lv5+:pixel_width] : aggr_min_lv4[pixel_width*(2*i_lv5+1)+:pixel_width];
                    pos_min_lv5[pixel_width*i_lv5+:pixel_width] <= (aggr_min_lv4[pixel_width*2*i_lv5+:pixel_width] < aggr_min_lv4[pixel_width*(2*i_lv5+1)+:pixel_width]) ? pos_min_lv4[pixel_width*2*i_lv5+:pixel_width] : pos_min_lv4[pixel_width*(2*i_lv5+1)+:pixel_width];
                end
            end
        
            // tictoc #7 calc_level_6
            for (i_lv6 = 0; i_lv6 < 2; i_lv6 = i_lv6 + 1) begin
                aggr_min_lv6[pixel_width*i_lv6+:pixel_width] <= (aggr_min_lv5[pixel_width*2*i_lv6+:pixel_width] < aggr_min_lv5[pixel_width*(2*i_lv6+1)+:pixel_width]) ? aggr_min_lv5[pixel_width*2*i_lv6+:pixel_width] : aggr_min_lv5[pixel_width*(2*i_lv6+1)+:pixel_width];
                pos_min_lv6[pixel_width*i_lv6+:pixel_width] <= (aggr_min_lv5[pixel_width*2*i_lv6+:pixel_width] < aggr_min_lv5[pixel_width*(2*i_lv6+1)+:pixel_width]) ? pos_min_lv5[pixel_width*2*i_lv6+:pixel_width] : pos_min_lv5[pixel_width*(2*i_lv6+1)+:pixel_width];
            end
        
            // tictoc #8 calc_final_min
            min_aggr <= (aggr_min_lv6[0+:pixel_width] < aggr_min_lv6[pixel_width+:pixel_width]) ? aggr_min_lv6[0+:pixel_width] : aggr_min_lv6[pixel_width+:pixel_width];
            pos_min <= (aggr_min_lv6[0+:pixel_width] < aggr_min_lv6[pixel_width+:pixel_width]) ? pos_min_lv6[0+:pixel_width] : pos_min_lv6[pixel_width+:pixel_width];
        end
    end
endmodule
