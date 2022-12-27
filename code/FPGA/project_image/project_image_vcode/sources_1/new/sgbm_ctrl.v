`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/22 10:13:50
// Design Name: project_image
// Module Name: sgbm_ctrl
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


module sgbm_ctrl(
    input clk,
    input rst,
    
    output [7:0] grey_left,
    output [7:0] grey_right,
    output reg [9:0] grey_row_left,
    output reg [9:0] grey_col_left,
    output reg [9:0] grey_row_right,
    output reg [9:0] grey_col_right,
    output reg valid
    );
    
    parameter image_row = 200;
    parameter image_col = 400;
    
    reg [19:0] cnt;
    reg [9:0] row_cnt;
    reg [9:0] col_cnt;
    reg en;
    reg [16:0] addr;
    
    initial begin
        cnt <= 0;
        row_cnt <= 0;
        col_cnt <= 0;
        
        grey_row_left <= 0;
        grey_col_left <= 0;
        grey_row_right <= 0;
        grey_col_right <= 0;
        valid <= 0;
        en <= 0;
        addr <= 0;
    end
    
    blk_grey_left grey_left_gen(
    .clka(clk),
    .ena(en),
    .wea(0),
    .addra(addr),
    .dina(16'b0),
    .douta(grey_left)
    );
    
    blk_grey_right grey_right_gen(
    .clka(clk),
    .ena(en),
    .wea(0),
    .addra(addr),
    .dina(16'b0),
    .douta(grey_right)
    );
    
    always @ (posedge clk) begin
        if (rst) begin
            cnt <= 20'b0;
            row_cnt <= 10'b0;
            col_cnt <= 10'b0;
        
            grey_row_left <= 10'b0;
            grey_col_left <= 10'b0;
            grey_row_right <= 10'b0;
            grey_col_right <= 10'b0;
            valid <= 0;
            en <= 0;
            addr <= 0;
        end
        else begin
            // tictoc #1 cnt_judge
            if (cnt%13==0) begin
                en <= 1;
                addr <= cnt/13;
                row_cnt <= (cnt/13)/image_col;
                col_cnt <= (cnt/13)%image_col;
            end
            else begin
                en <= 0;
            end
            // tictoc #2 cnt_increase_n_output
            cnt <= cnt + 1;
            grey_row_left <= row_cnt;
            grey_row_right <= row_cnt;
            grey_col_left <= col_cnt;
            grey_col_right <= col_cnt;
            valid <= en;
        end
    end
    
endmodule
