`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: Tengyu Zhang (EscapeTHU)
// 
// Create Date: 2022/12/17 09:29:44
// Design Name: SGBM algorithm
// Module Name: aggregate_cost
// Project Name: SGBM
// Target Devices: ZCU208
// Tool Versions: Vivado 2021.2
// Description: This module is used to realize sgbm census calculation.
// 
// Dependencies: Non
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module census(
    input clk,
    input rst,
    input en,
    input [7:0] inData,
    input [9:0] row_in,
    input [9:0] col_in,
    output [31:0] outData,
    output [9:0] row_out,
    output [9:0] col_out,
    output valid,
    
    output reg [19:0] test_cnt
    );
    
    parameter pixel_depth = 8;
    parameter frame_width = 400;
    parameter block_width = 3;
    parameter block_height = 3;
    
    parameter shiftRegSize = pixel_depth * ( ( block_height - 1) * frame_width + block_width );
    reg [shiftRegSize-1:0] shiftReg;
    reg [pixel_depth-1:0] grey_center;
    reg [pixel_depth-1:0] pix00;
    reg [pixel_depth-1:0] pix01;
    reg [pixel_depth-1:0] pix02;
    reg [pixel_depth-1:0] pix10;
    reg [pixel_depth-1:0] pix12;
    reg [pixel_depth-1:0] pix20;
    reg [pixel_depth-1:0] pix21;
    reg [pixel_depth-1:0] pix22;
    reg [9:0] my_row_buf [3:0];
    reg [9:0] my_col_buf [3:0];
    reg [31:0] census;
    reg en_save [3:0];
    reg census_1;
    reg census_2;
    reg census_3;
    reg census_4;
    reg census_6;
    reg census_7;
    reg census_8;
    reg census_9;
    reg [19:0] cnt [3:0];
    
    initial begin
        shiftReg = 6424'b0;
        census = 32'b0;
        census_1 = 1'b0;
        census_2 = 1'b0;
        census_3 = 1'b0;
        census_4 = 1'b0;
        census_6 = 1'b0;
        census_7 = 1'b0;
        census_8 = 1'b0;
        census_9 = 1'b0;
        my_row_buf[0] = 10'h0;
        my_row_buf[1] = 10'h0;
        my_row_buf[2] = 10'h0;
        my_row_buf[3] = 10'h0;
        my_col_buf[0] = 10'h0;
        my_col_buf[1] = 10'h0;
        my_col_buf[2] = 10'h0;
        my_col_buf[3] = 10'h0;
        cnt[0] = 20'b0;
        cnt[1] = 20'b0;
        cnt[2] = 20'b0;
        cnt[3] = 20'b0;
    end
    
    always@(posedge clk)begin
        if (rst) begin
            // shiftReg <= 10264'b0;
            shiftReg <= 6424'b0;
            census <= 32'b0;
            census_1 <= 1'b0;
            census_2 <= 1'b0;
            census_3 <= 1'b0;
            census_4 <= 1'b0;
            census_6 <= 1'b0;
            census_7 <= 1'b0;
            census_8 <= 1'b0;
            census_9 <= 1'b0;
            my_row_buf[0] <= 10'h0;
            my_row_buf[1] <= 10'h0;
            my_row_buf[2] <= 10'h0;
            my_row_buf[3] <= 10'h0;
            my_col_buf[0] <= 10'h0;
            my_col_buf[1] <= 10'h0;
            my_col_buf[2] <= 10'h0;
            my_col_buf[3] <= 10'h0;
            cnt[0] <= 20'b0;
            cnt[1] <= 20'b0;
            cnt[2] <= 20'b0;
            cnt[3] <= 20'b0;
        end
        if (en) begin
            // tictoc #1 initialization
            shiftReg <= {shiftReg,inData};
            cnt[0] <= cnt[0] + 1;
        end
        // tictoc #2 grey_center
        grey_center <= shiftReg[pixel_depth*(((block_height+1)/2)-1)*(frame_width+1)+:pixel_depth];
        pix00 <= shiftReg[pixel_depth*(0*frame_width+0)+:pixel_depth];
        pix01 <= shiftReg[pixel_depth*(0*frame_width+1)+:pixel_depth];
        pix02 <= shiftReg[pixel_depth*(0*frame_width+2)+:pixel_depth];
        pix10 <= shiftReg[pixel_depth*(1*frame_width+0)+:pixel_depth];
        pix12 <= shiftReg[pixel_depth*(1*frame_width+2)+:pixel_depth];
        pix20 <= shiftReg[pixel_depth*(2*frame_width+0)+:pixel_depth];
        pix21 <= shiftReg[pixel_depth*(2*frame_width+1)+:pixel_depth];
        pix22 <= shiftReg[pixel_depth*(2*frame_width+2)+:pixel_depth];
        // tictoc #3 census_calculation
        if(pix00 < grey_center)
            census_1 <= 1'b1;
            else
            census_1 <= 1'b0;
        if(pix01 < grey_center)
            census_2 <= 1'b1;
            else
            census_2 <= 1'b0;
        if(pix02 < grey_center)
            census_3 <= 1'b1;
            else
            census_3 <= 1'b0;
        if(pix10 < grey_center)
            census_4 <= 1'b1;
            else
            census_4 <= 1'b0;
        if(pix12 < grey_center)
            census_6 <= 1'b1;
            else
            census_6 <= 1'b0;
        if(pix20 < grey_center)
            census_7 <= 1'b1;
            else
            census_7 <= 1'b0;
        if(pix21 < grey_center)
            census_8 <= 1'b1;
            else
            census_8 <= 1'b0;
        if(pix22 < grey_center)
            census_9 <= 1'b1;
            else
            census_9 <= 1'b0;
        // tictoc #4 output_census
        // census <= {census_9,census_8,census_7,census_6,1'b0,census_4,census_3,census_2,census_1};
        if ((my_row_buf[2] < 2) || ((my_row_buf[2] == 2) & (my_col_buf[2] < 2)) || ((cnt[2] - 402)/frame_width < 1) || ((cnt[2] - 402)/frame_width >198) || ((cnt[2] - 402)%frame_width < 1) || ((cnt[2] - 402)%frame_width > 398)) begin
            census <= 0;
        end
        else begin
            census <= {census_9,census_8,census_7,census_6,1'b0,census_4,census_3,census_2,census_1};
        end
        
        // tictoc #1* for_row_n_col_n_en
        my_row_buf[0] <= row_in;
        my_col_buf[0] <= col_in;
        en_save[0] <= en;
        // tictoc #2* for_row_n_col_n_en
        my_row_buf[1] <= my_row_buf[0];
        my_col_buf[1] <= my_col_buf[0];
        en_save[1] <= en_save[0];
        cnt[1] <= cnt[0];
        // tictoc #3* for_row_n_col_n_en
        my_row_buf[2] <= my_row_buf[1];
        my_col_buf[2] <= my_col_buf[1];
        en_save[2] <= en_save[1];
        cnt[2] <= cnt[1];
        // tictoc #4* for_row_n_col_n_en
        test_cnt <= cnt[2];
        if (my_row_buf[2] < 1 || ((my_row_buf[2] == 1) & (my_col_buf[2] < 1))) begin
            my_row_buf[3] <= 0;
            my_col_buf[3] <= 0;
            en_save[3] <= 0;
        end
        else begin
            my_row_buf[3] <= (cnt[2] - 402)/frame_width;
            my_col_buf[3] <= (cnt[2] - 402)%frame_width;
            en_save[3] <= en_save[2];
        end
        
    end
    
    assign outData = census;    
    assign row_out = my_row_buf[3];
    assign col_out = my_col_buf[3];
    assign valid = en_save[3];
endmodule
