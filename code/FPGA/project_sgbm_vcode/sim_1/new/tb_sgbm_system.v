`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/17 16:57:51
// Design Name: project_sgbm
// Module Name: tb_sgbm_system
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


module tb_sgbm_system();
    parameter image_row = 200;
    parameter image_col = 400;
    
    reg clk;
    reg rst;
    reg [19:0] cnt;
    
    wire [863:0] sgbm_cost;
    wire [9:0] sgbm_row;
    wire [9:0] sgbm_col;
    wire sgbm_valid;
    
    initial begin
        clk <= 0;
        rst <= 1;
        cnt <= 20'b0;
    end
    
    sgbm_system u_all(
    .clk(clk),
    .rst(rst),
    .sgbm_cost(sgbm_cost),
    .sgbm_row(sgbm_row),
    .sgbm_col(sgbm_col),
    .sgbm_valid(sgbm_valid)
    );
    
    always #1 clk = ~clk;
    always @ (posedge clk) begin
        cnt <= cnt + 1;
        if (cnt >= 100) begin
            rst <= 0;
        end
    end
endmodule
