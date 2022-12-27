`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/15 13:57:32
// Design Name: aggregate cost
// Module Name: tb_min_aggr
// Project Name: aggregate cost
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


module tb_min_aggr();
    reg clk;
    reg rst;
    reg [863:0] cost_init_n;
    reg [863:0] mem [9:0];
    reg [19:0] cnt;
    
    wire [7:0] min_cost;
    
    initial begin
        $readmemh("E:/Xilinx_project/aggregate_cost/image_data/min_aggr.txt", mem);
        cost_init_n <= 0;
        clk <= 0;
        rst <= 0;
        cnt <= 0;
    end
    
    min_aggr_cost u(
    .clk(clk),
    .rst(rst),
    .data_in(cost_init_n),
    .min_aggr(min_cost)
    );
    
    always #1 clk = ~clk;
    always @ (posedge clk) begin
        cnt = cnt + 1;
        if (cnt <= 100) begin
            rst <= 1;
        end
        else begin
            // $readmemh("E:/Xilinx_project/aggregate_cost/image_data/min_aggr.txt", cost_init_n);
            cost_init_n <= mem[0];
            rst <= 0;
        end
    end
endmodule
