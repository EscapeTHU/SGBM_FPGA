`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/22 10:19:20
// Design Name: project_image
// Module Name: aggregate
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


module aggregate(
    input clk,
    input rst,
    input en,
    input [863:0] cost_init,
    input [863:0] cost_aggr_last,
    input [7:0] min_aggr_last,
    input [9:0] row,
    input [9:0] col,
    output reg [863:0] cost_aggr,
    output reg [9:0] out_row,
    output reg [9:0] out_col,
    output reg valid
);

    parameter min_disparity = 20;
    parameter max_disparity = 128;
    parameter disp_range = 108;
    parameter frame_width = 400;
    parameter frame_height = 200;
    parameter pixel_width = 8;
    parameter P1 = 9'd10;
    
    
    reg [863:0] cost_init_reg;
    reg [863:0] cost_last_reg;
    
    reg [9:0] my_row;
    reg [9:0] my_col;
    reg [9:0] my_row_1;
    reg [9:0] my_col_1;
    reg [9:0] my_row_2;
    reg [9:0] my_col_2;
    reg [9:0] my_row_3;
    reg [9:0] my_col_3;
    
    reg [863:0] cost;
    reg [863:0] cost_1;
    reg [863:0] cost_2;
    reg [863:0] l1;
    reg [863:0] l2;
    reg [863:0] l3;
    reg [863:0] min_step1_1;
    reg [863:0] min_step1_2;
    reg [863:0] cost_col0_init [2:0];
    reg [7:0] min_aggr;
    reg [7:0] min_aggr_1;
    reg [7:0] min_aggr_2;
    reg [7:0] min_aggr_3;
    
    reg en_save;
    reg en_save_1;
    reg en_save_2;
    reg en_save_3;
    
    
    integer i, j;

    initial begin
        cost_init_reg <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        cost_last_reg <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        cost_aggr <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        min_step1_1 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        min_step1_2 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        my_row <= 10'h0;
        my_col <= 10'h0;
        my_row_1 <= 10'h0;
        my_col_1 <= 10'h0;
        my_row_2 <= 10'h0;
        my_col_2 <= 10'h0;
        my_row_3 <= 10'h0;
        my_col_3 <= 10'h0;
        out_row <= 10'h0;
        out_col <= 10'h0;
        cost <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        cost_1 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        cost_2 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        l1 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        l2 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        l3 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        cost_col0_init[0] <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        cost_col0_init[1] <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        cost_col0_init[2] <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        min_aggr <= 8'hFF;
        min_aggr_1 <= 8'hFF;
        min_aggr_2 <= 8'hFF;
        min_aggr_3 <= 8'hFF;
        en_save <= 0;
        en_save_1 <= 0;
        en_save_2 <= 0;
        en_save_3 <= 0;
        valid <= 0;
    end

    always @ (posedge clk) begin
        if (rst) begin
            cost_init_reg <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            cost_last_reg <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            cost_aggr <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            min_step1_1 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            min_step1_2 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            my_row <= 10'h0;
            my_col <= 10'h0;
            my_row_1 <= 10'h0;
            my_col_1 <= 10'h0;
            my_row_2 <= 10'h0;
            my_col_2 <= 10'h0;
            my_row_3 <= 10'h0;
            my_col_3 <= 10'h0;
            out_row <= 10'h0;
            out_col <= 10'h0;
            cost <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            cost_1 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            cost_2 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            l1 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            l2 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            l3 <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            cost_col0_init[0] <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            cost_col0_init[1] <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            cost_col0_init[2] <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            min_aggr <= 8'hFF;
            min_aggr_1 <= 8'hFF;
            min_aggr_2 <= 8'hFF;
            min_aggr_3 <= 8'hFF;
            en_save <= 0;
            en_save_1 <= 0;
            en_save_2 <= 0;
            en_save_3 <= 0;
            valid <= 0;
        end
        else begin
            // tictoc #1 initialization
            my_row <= row;
            my_col <= col;
            cost_init_reg <= cost_init;
            cost_last_reg <= cost_aggr_last;
            en_save <= en;
            min_aggr <= min_aggr_last;

            // tictoc #2 loss_calculation
            cost_col0_init[0] <= cost_init_reg;
            // tictoc #3 find_min_loss
            cost_col0_init[1] <= cost_col0_init[0];
            // tictoc #4 find_min_loss
            cost_col0_init[2] <= cost_col0_init[1];

            
            // tictoc #2** for_min_aggr_last
            min_aggr_1 <= min_aggr;
            // tictoc #3** for_min_aggr_last
            min_aggr_2 <= min_aggr_1;
            // tictoc #4** for_min_aggr_last
            min_aggr_3 <= min_aggr_2;
            
            for (j = 0; j < disp_range; j = j + 1) begin
                // tictoc #2 loss_calculation
                if (j == 0) begin
                    cost[pixel_width*j+:pixel_width] <= cost_init_reg[pixel_width*j+:pixel_width];
                    l1[pixel_width*j+:pixel_width] <= cost_last_reg[pixel_width*j+:pixel_width];
                    l2[pixel_width*j+:pixel_width] <= 8'd255;
                    l3[pixel_width*j+:pixel_width] <= ((cost_last_reg[pixel_width*(j+1)+:pixel_width] + P1) > 8'd255) ? 8'd255 : (cost_last_reg[pixel_width*(j+1)+:pixel_width] + P1);
                end
                else if (j < disp_range-1) begin
                    cost[pixel_width*j+:pixel_width] <= cost_init_reg[pixel_width*j+:pixel_width];
                    l1[pixel_width*j+:pixel_width] <= cost_last_reg[pixel_width*j+:pixel_width];
                    l2[pixel_width*j+:pixel_width] <= ((cost_last_reg[pixel_width*(j-1)+:pixel_width] + P1) > 255) ? 255 : (cost_last_reg[pixel_width*(j-1)+:pixel_width] + P1);
                    // l3[pixel_width*i+:pixel_width] <= 255 + P1;
                    l3[pixel_width*j+:pixel_width] <= ((cost_last_reg[pixel_width*(j+1)+:pixel_width] + P1) > 255) ? 255 : (cost_last_reg[pixel_width*(j+1)+:pixel_width] + P1);
                end
                else begin
                    cost[pixel_width*j+:pixel_width] <= cost_init_reg[pixel_width*j+:pixel_width];
                    l1[pixel_width*j+:pixel_width] <= cost_last_reg[pixel_width*j+:pixel_width];
                    l2[pixel_width*j+:pixel_width] <= ((cost_last_reg[pixel_width*(j-1)+:pixel_width] + P1) > 255) ? 255 : (cost_last_reg[pixel_width*(j-1)+:pixel_width] + P1);
                    // l3[pixel_width*i+:pixel_width] <= 255 + P1;
                    l3[pixel_width*j+:pixel_width] <= 255;
                end

                // tictoc #3 finding_min_loss
                min_step1_1[pixel_width*j+:pixel_width] <= (l1[pixel_width*j+:pixel_width]<l2[pixel_width*j+:pixel_width]) ? l1[pixel_width*j+:pixel_width] : l2[pixel_width*j+:pixel_width];
                cost_1[pixel_width*j+:pixel_width] <= cost[pixel_width*j+:pixel_width];
                    
                // tictoc #4 finding_min_loss
                min_step1_2[pixel_width*j+:pixel_width] <= (min_step1_1[pixel_width*j+:pixel_width]<l3[pixel_width*j+:pixel_width]) ? min_step1_1[pixel_width*j+:pixel_width] : l3[pixel_width*j+:pixel_width];
                cost_2[pixel_width*j+:pixel_width] <= cost_1[pixel_width*j+:pixel_width];

                // tictoc #5 output_aggr_result
                if (my_col_3 == 0) begin
                    cost_aggr[pixel_width*j+:pixel_width] <= cost_col0_init[2][pixel_width*j+:pixel_width];
                end
                else begin
                    // cost_aggr[pixel_width*j+:pixel_width] <= ((min_step1_2[pixel_width*j+:pixel_width] + cost_2[pixel_width*j+:pixel_width]) < min_aggr_3) ? 0 : (min_step1_2[pixel_width*j+:pixel_width] + cost_2[pixel_width*j+:pixel_width] - min_aggr_3);
                    cost_aggr[pixel_width*j+:pixel_width] <= min_step1_2[pixel_width*j+:pixel_width] + cost_2[pixel_width*j+:pixel_width] - min_aggr_3;
                end
            end

            
            // tictoc #2* for_row_n_col_n_en
            my_row_1 <= my_row;
            my_col_1 <= my_col;
            en_save_1 <= en_save;
            // tictoc #3* for_row_n_col_n_en
            my_row_2 <= my_row_1;
            my_col_2 <= my_col_1;
            en_save_2 <= en_save_1;
            // tictoc #4* for_row_n_col_n_en
            my_row_3 <= my_row_2;
            my_col_3 <= my_col_2;
            en_save_3 <= en_save_2;
            // tictoc #5* for_row_n_col_n_en
            out_row <= my_row_3;
            out_col <= my_col_3;
            valid <= en_save_3;
        end
    end
endmodule
