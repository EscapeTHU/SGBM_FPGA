`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/15 04:12:29
// Design Name: aggregate cost
// Module Name: tb_delay
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


module tb_delay();
    parameter image_row = 200;
    parameter image_col = 400;

    reg clk;
    reg [863:0] cost_init_in;
    reg [863:0] cost_init_image [image_row*image_col-1:0];
    reg en;
    reg rst;
    reg [19:0] cnt;
    wire [863:0] cost_delay_out;
    wire valid;
    
    initial begin
        $readmemh("E:/Xilinx_project/aggregate_cost/image_data/cost_init_X_t.txt", cost_init_image);
        clk = 0;
        cost_init_in = 0;
        cnt = 0;
        rst = 1;
        en = 0;
        cnt = 0;
    end
    
    delay u(
    .clk(clk),
    .rst(rst),
    .data_in(cost_init_in),
    .en(en),
    .data_out(cost_delay_out),
    .valid(valid)
    );
    
    always #1 clk = ~clk;
    always @ (posedge clk) begin
        cnt <= cnt + 1;
        if (cnt >= 100) begin
            rst <= 0;
            en <= 1;
            cost_init_in <= cost_init_image[cnt-100];
        end
        if (cnt == 99+image_row*image_col) begin
            cnt <= 100;
        end
    end
endmodule
