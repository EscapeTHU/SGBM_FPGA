`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/20 14:55:55
// Design Name: project_sgbm
// Module Name: tb_sgbm_wrapper
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


module tb_sgbm_wrapper();
    reg clk;
    
    wire [31:0] disparity;
    wire [9:0] row_out;
    wire [9:0] col_out;
    wire valid;
    
    initial begin
        clk = 0;
    end
    
    project_sgbm u(
    .clkin(clk),
    .disparity(disparity),
    .row_out(row_out),
    .col_out(col_out),
    .valid(valid)
    );
    
    always #1 clk = ~clk;
    
endmodule
