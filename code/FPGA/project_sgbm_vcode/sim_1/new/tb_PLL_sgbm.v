`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/18 19:47:04
// Design Name: project_sgbm
// Module Name: tb_PLL_sgbm
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


module tb_PLL_sgbm();
    reg clk;
    
    wire clkout;
    wire rst;
    
    initial begin
        clk <= 0;
    end
    
    PLL_sgbm u(
    .clkin(clk),
    .clkout(clkout),
    .restn(rst)
    );
    
    always #1 clk = ~clk;
endmodule
