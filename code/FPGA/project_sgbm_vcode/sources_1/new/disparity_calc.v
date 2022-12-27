`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: Tengyu Zhang (EscapeTHU)
// 
// Create Date: 2022/12/17 23:57:51
// Design Name: SGBM algorithm
// Module Name: disparity_calc
// Project Name: SGBM
// Target Devices: ZCU208 
// Tool Versions: Vivado 2021.2
// Description: This module is used to calculate sgbm after process.
// 
// Dependencies: Non
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module disparity_calc(
    input clk,
    input rst,
    input en,
    input [863:0] cost_aggr,
    input [9:0] row_in,
    input [9:0] col_in,
    output reg [31:0] disparity,
    output reg [9:0] row_out,
    output reg [9:0] col_out,
    output reg valid
    );
    
    parameter min_disparity = 32'd20;
    parameter max_disparity = 32'd128;
    parameter disp_range = 108;
    parameter pixel_width = 8;
    // parameter invalid = 4294967296-1; // 2^32 - 1 : which means all 1 in disparity!
    
    // This part is activated in disparity_calc_test
    // assign check_min_output = min_aggr;
    // assign check_min_aggr_new = min_aggr_new;
    // assign check_min_aggr_new_delay = min_aggr_new_delay;
    
    // ######################################
    wire [7:0] min_aggr;
    wire [7:0] pos_min;
    
    wire [863:0] cost_aggr_delay;
    wire [9:0] row_delay;
    wire [9:0] col_delay;
    wire valid_delay;
    
    // ######################################
    wire [7:0] sec_min_aggr;
    wire [7:0] pos_sec_min;
    
    wire [7:0] min_aggr_new_delay;
    wire [7:0] pos_min_new_delay;
    wire [7:0] cost_1_delay;
    wire [7:0] cost_2_delay;
    wire [9:0] row_new_delay;
    wire [9:0] col_new_delay;
    wire valid_new_delay;
    
    // ######################################
    reg [863:0] cost_aggr_new;
    reg [9:0] row_new;
    reg [9:0] col_new;
    reg [7:0] min_aggr_new;
    reg [7:0] cost_1;
    reg [7:0] cost_2;
    reg [7:0] pos_min_new;
    reg valid_new;
    
    integer i;
    
    initial begin
        cost_aggr_new <= ~(864'h0);
        row_new <= 10'b0;
        col_new <= 10'b0;
        min_aggr_new <= 8'b0;
        cost_1 <= 8'b0;
        cost_2 <= 8'b0;
        pos_min_new <= 8'b0;
        valid_new <= 0;
        
        disparity <= 32'b0;
        row_out <= 10'b0;
        col_out <= 10'b0;
        valid <= 0;
        
        // This part is activated in disparity_calc_test
        // min_aggr_out <= 0;
        // sec_min_aggr_out <= 0;
        // pos_min_out <= 0;
    end
    
    // tictoc #1 ~ 8 calc_min_aggr_n_pos
    disp_min_calc u_min(
    .clk(clk),
    .rst(rst),
    .cost_aggr(cost_aggr),
    .min_cost(min_aggr),
    .min_cost_pos(pos_min)
    );
    
    // tictoc #1 ~ 8 delay1
    delay_disp  #(
    .DATA_WIDTH (864),
    .DIM_WIDTH (10),
    .DELAY_DEEP (8)
    )
    u_delay_min(
    .clk(clk),
    .rst(rst),
    .en(en),
    .data_in(cost_aggr),
    .row_in(row_in),
    .col_in(col_in),
    .data_out(cost_aggr_delay),
    .row_out(row_delay),
    .col_out(col_delay),
    .valid(valid_delay)
    );
    
    // tictoc # 10 ~ 18 calc_sec_min_n_secmin_pos
    disp_min_calc u_sec_min(
    .clk(clk),
    .rst(rst),
    .cost_aggr(cost_aggr_new),
    .min_cost(sec_min_aggr),
    .min_cost_pos(pos_sec_min)
    );
    
    // tictoc # 10 ~ 18 delay2
    delay_sec_disp #(
    .DATA_WIDTH (8),
    .POS_WIDTH (8),
    .DIM_WIDTH (10),
    .DELAY_DEEP (8)
    )
    u_delay_sec_min(
    .clk(clk),
    .rst(rst),
    .en(valid_new),
    .data_in1(min_aggr_new),
    .data_in2(cost_1),
    .data_in3(cost_2),
    .pos_in(pos_min_new),
    .row_in(row_new),
    .col_in(col_new),
    .data_out1(min_aggr_new_delay),
    .data_out2(cost_1_delay),
    .data_out3(cost_2_delay),
    .pos_out(pos_min_new_delay),
    .row_out(row_new_delay),
    .col_out(col_new_delay),
    .valid(valid_new_delay)
    );
    
    always @ (posedge clk) begin
        if (rst) begin
            cost_aggr_new <= ~(864'h0);
            row_new <= 10'b0;
            col_new <= 10'b0;
            min_aggr_new <= 8'b0;
            cost_1 <= 8'b0;
            cost_2 <= 8'b0;
            pos_min_new <= 8'b0;
            valid_new <= 0;
            
            disparity <= 32'b0;
            row_out <= 10'b0;
            col_out <= 10'b0;
            valid <= 0;
            
            // This part is activated in disparity_calc_test
            // min_aggr_out <= 0;
            // sec_min_aggr_out <= 0;
            // pos_min_out <= 0;
        end
        else begin
            // if (valid_delay) begin
                // tictoc #9 renew_cost_aggr_n_row_n_col
                for (i = 0; i < disp_range; i = i + 1) begin
                    if ((pos_min != 0) & (pos_min != 107) & (i == pos_min) & (i > 0) & (i < 107)) begin
                        cost_aggr_new[pixel_width*i+:pixel_width] <= 8'hFF;
                        cost_1 <= cost_aggr_delay[pixel_width*(i-1)+:pixel_width];
                        cost_2 <= cost_aggr_delay[pixel_width*(i+1)+:pixel_width];
                    end
                    else if (i == pos_min) begin
                        cost_aggr_new[pixel_width*i+:pixel_width] <= 8'hFF;
                        cost_1 <= 8'hFF;
                        cost_2 <= 8'hFF;
                    end
                    else begin
                        cost_aggr_new[pixel_width*i+:pixel_width] <= cost_aggr_delay[pixel_width*i+:pixel_width];
                    end
                end
                row_new <= row_delay;
                col_new <= col_delay;
                valid_new <= valid_delay;
                min_aggr_new <= min_aggr;
                pos_min_new <= pos_min;
            // end
            
            
            // if (valid_new_delay) begin
                // tictoc #19 calculate_disparity_n_output
                if ((100*(sec_min_aggr - min_aggr_new_delay) < min_aggr_new_delay) || (pos_min_new_delay == 0) || (pos_min_new_delay == 107)) begin
                    disparity <= 32'hFFFF_FFFF;
                end
                else begin
                    // TODO: This following calculation should be changed into decimal calculation !!! 
                    // If this calculation is changed into decimal, MIND THE TICTOC OF DECIMAL CALCULATION !!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    // disparity <= pos_min_new_delay + (cost_1_delay - cost_2_delay) / (2*cost_1_delay + 2*cost_2_delay - 4*min_aggr_new_delay);
                    disparity <= pos_min_new_delay + min_disparity;
                end
                row_out <= row_new_delay;
                col_out <= col_new_delay;
                valid <= valid_new_delay;
                
                // This part is activated in disparity_calc_test
                // min_aggr_out <= min_aggr_new_delay;
                // sec_min_aggr_out <= sec_min_aggr;
                // pos_min_out <= pos_min_new_delay;
                
            // end
        end
    end
endmodule