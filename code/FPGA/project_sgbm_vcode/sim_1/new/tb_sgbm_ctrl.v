`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/17 16:34:34
// Design Name: project_sgbm
// Module Name: tb_sgbm_ctrl
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



module tb_sgbm_ctrl();
    parameter image_row = 200;
    parameter image_col = 400;
    
    reg clk;
    reg rst;
    reg [19:0] cnt;
    
    wire [7:0] grey_left;
    wire [7:0] grey_right;
    wire [9:0] grey_row_left;
    wire [9:0] grey_col_left;
    wire [9:0] grey_row_right;
    wire [9:0] grey_col_right;
    wire valid;
    
    initial begin
        clk <= 0;
        rst <= 1;
        cnt <= 20'b0;
    end
    
    sgbm_ctrl u(
    .clk(clk),
    .rst(rst),
    .grey_left(grey_left),
    .grey_right(grey_right),
    .grey_row_left(grey_row_left),
    .grey_col_left(grey_col_left),
    .grey_row_right(grey_row_right),
    .grey_col_right(grey_col_right),
    .valid(valid)
    );
    
    always #1 clk = ~clk;
    always @ (posedge clk) begin
        cnt <= cnt + 1;
        if (cnt >= 100) begin
            rst <= 0;
        end
    end
endmodule
