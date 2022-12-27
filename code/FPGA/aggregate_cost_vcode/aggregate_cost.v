`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/13 10:11:03
// Design Name: 
// Module Name: aggregate_cost
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
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
    input [863:0] cost_aggr_last,
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
    parameter pixel_width = 8;
    parameter P1 = 9'b10;
    
    
    reg [863:0] cost_init_reg;
    reg [863:0] cost_last_reg;
    
    reg [9:0] my_row;
    reg [9:0] my_col;
    reg [9:0] my_row_1;
    reg [9:0] my_col_1;
    reg [9:0] my_row_2;
    reg [9:0] my_col_2;
    
    reg [863:0] cost;
    reg [863:0] l1;
    reg [863:0] l2;
    reg [863:0] l3;
    reg [863:0] min_step1_1;
    reg [863:0] min_step1_2;
    
    reg en_save;
    reg en_save_1;
    reg en_save_2;
    
    
    integer i;

    initial begin
        cost_init_reg <= ~0;
        cost_last_reg <= ~0;
        cost_aggr <= ~0;
        min_step1_1 <= ~0;
        min_step1_2 <= ~0;
        my_row <= 0;
        my_col <= 0;
        my_row_1 <= 0;
        my_col_1 <= 0;
        my_row_2 <= 0;
        my_col_2 <= 0;
        out_row <= 0;
        out_col <= 0;
        cost <= ~0;
        l1 <= ~0;
        l2 <= ~0;
        l3 <= ~0;
        en_save <= 0;
        en_save_1 <= 0;
        en_save_2 <= 0;
        valid <= 0;
    end

    always @ (posedge clk) begin
        if (rst) begin
            cost_init_reg <= ~0;
            cost_last_reg <= ~0;
            cost_aggr <= ~0;
            min_step1_1 <= ~0;
            min_step1_2 <= ~0;
            my_row <= 0;
            my_col <= 0;
            my_row_1 <= 0;
            my_col_1 <= 0;
            my_row_2 <= 0;
            my_col_2 <= 0;
            out_row <= 0;
            out_col <= 0;
            cost <= ~0;
            l1 <= ~0;
            l2 <= ~0;
            l3 <= ~0;
            en_save <= 0;
            en_save_1 <= 0;
            en_save_2 <= 0;
            valid <= 0;
        end
        else begin
            // tictoc #1 initialization
            my_row <= row;
            my_col <= col;
            cost_init_reg <= cost_init;
            cost_last_reg <= cost_aggr_last;
            en_save <= en;

            if (my_col == 0) begin
                for (i = 0; i < disp_range; i = i + 1) begin
                    // tictoc #2 loss_calculation
                    cost[pixel_width*i+:pixel_width] <= cost_init_reg[pixel_width*i+:pixel_width];

                    // tictoc #3 find_min_loss
                    min_step1_1[pixel_width*i+:pixel_width] <= cost[pixel_width*i+:pixel_width];

                    // tictoc #4 output_aggr_result
                    cost_aggr[pixel_width*i+:pixel_width] <= min_step1_1[pixel_width*i+:pixel_width];
                end
            end
            else begin
                for (i = 0; i < disp_range; i = i + 1) begin
                    // tictoc #2 loss_calculation
                    if (i < disp_range-2) begin
                        cost[pixel_width*i+:pixel_width] <= cost_init_reg[pixel_width*i+:pixel_width];
                        l1[pixel_width*i+:pixel_width] <= cost_last_reg[pixel_width*(i+1)+:pixel_width];
                        l2[pixel_width*i+:pixel_width] <= ((cost_last_reg[pixel_width*i+:pixel_width] + P1) > 255) ? 255 : (cost_last_reg[pixel_width*i+:pixel_width] + P1);
                        l3[pixel_width*i+:pixel_width] <= ((cost_last_reg[pixel_width*(i+2)+:pixel_width] + P1) > 255) ? 255 : (cost_last_reg[pixel_width*(i+2)+:pixel_width] + P1);
                    end
                    else if (i < disp_range-1) begin
                        cost[pixel_width*i+:pixel_width] <= cost_init_reg[pixel_width*i+:pixel_width];
                        l1[pixel_width*i+:pixel_width] <= cost_last_reg[pixel_width*(i+1)+:pixel_width];
                        l2[pixel_width*i+:pixel_width] <= ((cost_last_reg[pixel_width*i+:pixel_width] + P1) > 255) ? 255 : (cost_last_reg[pixel_width*i+:pixel_width] + P1);
                        // l3[pixel_width*i+:pixel_width] <= 255 + P1;
                        l3[pixel_width*i+:pixel_width] <= 255;
                    end
                    else begin
                        cost[pixel_width*i+:pixel_width] <= cost_init_reg[pixel_width*i+:pixel_width];
                        l1[pixel_width*i+:pixel_width] <= 255;
                        l2[pixel_width*i+:pixel_width] <= ((cost_last_reg[pixel_width*i+:pixel_width] + P1) > 255) ? 255 : (cost_last_reg[pixel_width*i+:pixel_width] + P1);
                        // l3[pixel_width*i+:pixel_width] <= 255 + P1;
                        l3[pixel_width*i+:pixel_width] <= 255;
                    end

                    // tictoc #3 finding_min_loss
                    min_step1_1[pixel_width*i+:pixel_width] <= (cost[pixel_width*i+:pixel_width]<l1[pixel_width*i+:pixel_width]) ? cost[pixel_width*i+:pixel_width] : l1[pixel_width*i+:pixel_width];
                    min_step1_2[pixel_width*i+:pixel_width] <= (l2[pixel_width*i+:pixel_width]<l3[pixel_width*i+:pixel_width]) ? l2[pixel_width*i+:pixel_width] : l3[pixel_width*i+:pixel_width];

                    // tictoc #4 output_aggr_result
                    cost_aggr[pixel_width*i+:pixel_width] <= (min_step1_1[pixel_width*i+:pixel_width]<min_step1_2[pixel_width*i+:pixel_width]) ? min_step1_1[pixel_width*i+:pixel_width] : min_step1_2[pixel_width*i+:pixel_width];
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
            out_row <= my_row_2;
            out_col <= my_col_2;
            valid <= en_save_2;
        end
    end
endmodule
