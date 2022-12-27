`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/22 10:19:20
// Design Name: project_image
// Module Name: origin_cost
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


module origin_cost(
    input clk,
    input rst,
    input en,
    input [31:0] left_pix,
    input [31:0] right_pix,
    input [9:0] row,
    input [9:0] col,
    output reg [863:0] cost,
    output reg [9:0] out_row,
    output reg [9:0] out_col,
    output reg valid
    );
    
    parameter min_disparity = 20;
    parameter max_disparity = 128;
    parameter disp_range = 108;
    parameter frame_width = 400;
    parameter pixel_width = 32;
    parameter hamming_width = 8;
    parameter shiftRegSize = pixel_width * max_disparity;
    reg [31:0] shiftReg_left;
    reg [shiftRegSize-1:0] shiftReg_right;
    reg [shiftRegSize-1:0] xy_xor;
    reg [9:0] my_row;
    reg [9:0] my_col;
    reg [9:0] new_my_row;
    reg [9:0] new_my_col;
    reg en_save;
    reg en_save_new;
    integer i;
    
    initial begin
        shiftReg_left <= 32'b0;
        shiftReg_right <= 4096'b0;
        cost <= ~(864'h0);
        out_row <= 0;
        out_col <= 0;
        my_row <= 0;
        my_col <= 0;
        new_my_row <= 0;
        new_my_col <= 0;
        en_save <= 0;
        en_save_new <= 0;
        valid <= 0;
    end
    
    always @ (posedge clk) begin
        if (rst) begin
            shiftReg_left <= 32'b0;
            shiftReg_right <= 4096'b0;
            cost <= ~(864'h0);
            out_row <= 10'h0;
            out_col <= 10'h0;
            my_row <= 10'h0;
            my_col <= 10'h0;
            new_my_row <= 10'h0;
            new_my_col <= 10'h0;
            en_save <= 0;
            en_save_new <= 0;
            valid <= 0;
        end
        else begin
            if (en) begin
                // tictoc #1 initialization
                shiftReg_left <= left_pix;
                shiftReg_right <= {shiftReg_right, right_pix};
            end
        
                for (i = min_disparity; i < max_disparity; i = i + 1) begin
                    // tictoc #2 xor_calculation
                    xy_xor[pixel_width*i+:pixel_width] <= shiftReg_left ^ shiftReg_right[pixel_width*i+:pixel_width];
            
                    // tictoc #3 cost_calculation
                    if (new_my_col < i) begin
                        cost[hamming_width*(i-min_disparity)+:hamming_width] <= 8'b1111_1111;
                    end
                    else begin
                        cost[hamming_width*(i-min_disparity)+:hamming_width] <= xy_xor[pixel_width*i+0]+
                                                                                xy_xor[pixel_width*i+1]+
                                                                                xy_xor[pixel_width*i+2]+
                                                                                xy_xor[pixel_width*i+3]+
                                                                                xy_xor[pixel_width*i+4]+
                                                                                xy_xor[pixel_width*i+5]+
                                                                                xy_xor[pixel_width*i+6]+
                                                                                xy_xor[pixel_width*i+7]+
                                                                                xy_xor[pixel_width*i+8]+
                                                                                xy_xor[pixel_width*i+9]+
                                                                                xy_xor[pixel_width*i+10]+
                                                                                xy_xor[pixel_width*i+11]+
                                                                                xy_xor[pixel_width*i+12]+
                                                                                xy_xor[pixel_width*i+13]+
                                                                                xy_xor[pixel_width*i+14]+
                                                                                xy_xor[pixel_width*i+15]+
                                                                                xy_xor[pixel_width*i+16]+
                                                                                xy_xor[pixel_width*i+17]+
                                                                                xy_xor[pixel_width*i+18]+
                                                                                xy_xor[pixel_width*i+19]+
                                                                                xy_xor[pixel_width*i+20]+
                                                                                xy_xor[pixel_width*i+21]+
                                                                                xy_xor[pixel_width*i+22]+
                                                                                xy_xor[pixel_width*i+23]+
                                                                                xy_xor[pixel_width*i+24]+
                                                                                xy_xor[pixel_width*i+25]+
                                                                                xy_xor[pixel_width*i+26]+
                                                                                xy_xor[pixel_width*i+27]+
                                                                                xy_xor[pixel_width*i+28]+
                                                                                xy_xor[pixel_width*i+29]+
                                                                                xy_xor[pixel_width*i+30]+
                                                                                xy_xor[pixel_width*i+31];
                    
                end
            end
            // The synthesis sequence is probably currently wrong, ramains to be checked further...
            // In fact this is not necessary...
            // if (col == frame_width - 1) begin
            //     cost <= 863'b0;
            //     shiftReg_left <= 32'b0;
            //     shiftReg_right <= 4096'b0;
            // end
        
            // tictoc #1* for_row_n_col_n_en
            my_row <= row;
            my_col <= col;
            en_save <= en;
            // tictoc #2* for_row_n_col_n_en
            new_my_col <= my_col;
            new_my_row <= my_row;
            en_save_new <= en_save;
            // tictoc #3* for_row_n_col_n_en
            out_row <= new_my_row;
            out_col <= new_my_col;
            valid <= en_save_new;
        end
    end
endmodule
