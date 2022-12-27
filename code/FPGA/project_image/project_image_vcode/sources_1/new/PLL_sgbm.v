`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/22 10:21:08
// Design Name: project_image
// Module Name: PLL_sgbm
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


module PLL_sgbm(
    input clkin,
    input rst0,
    output reg clkout,
    output reg restn
    );
    
    reg [4:0] cnt;
    reg [7:0] rst_cnt;
    
    initial begin
        cnt <= 5'b0;
        clkout <= 0;
        restn <= 1;
        rst_cnt <= 8'b0;
    end
    
    always @ (posedge clkin) begin
        if (cnt == 1) begin
            clkout = ~clkout;
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1;
        end
        
        if ((rst_cnt >= 200) & (rst0 == 1)) begin
            restn <= 0;
        end
        else begin
            rst_cnt <= rst_cnt + 1;
            restn <= 1;
        end
    end
endmodule
