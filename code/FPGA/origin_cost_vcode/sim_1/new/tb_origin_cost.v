`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/11/22 10:32:56
// Design Name: origin_cost
// Module Name: tb_origin_cost
// Project Name: origin_cost
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


module tb_origin_cost();
    parameter image_row = 200;
    parameter image_col = 400;

    reg clk;
    reg rst;
    reg en;
    reg [31:0] left_in;
    reg [31:0] right_in;
    reg [9:0] row_in;
    reg [9:0] col_in;
    reg [31:0] image_left [image_row*image_col-1:0];
    reg [31:0] image_right [image_row*image_col-1:0];
    reg [4:0] frame_cnt;
    reg [19:0] cnt;
    
    wire [863:0] cost_out;
    wire [9:0] out_row;
    wire [9:0] out_col;
    wire valid;
    
    integer file_id;
    
    initial begin
        $readmemh("E:/Xilinx_project/origin_cost/image_data/census_left_X.txt", image_left);
        $readmemh("E:/Xilinx_project/origin_cost/image_data/census_right_X.txt", image_right);
        file_id = $fopen("E:/Xilinx_project/origin_cost/image_data/mem2image.txt", "w");
        clk = 0;
        rst = 1;
        en = 0;
        cnt = 0;
        row_in = 0;
        col_in = 0;
        left_in = 0;
        right_in = 0;
        frame_cnt = 0;
    end
    
    origin_cost u_2(
    .clk(clk),
    .rst(rst),
    .en(en),
    .left_pix(left_in),
    .right_pix(right_in),
    .row(row_in),
    .col(col_in),
    .cost(cost_out),
    .out_row(out_row),
    .out_col(out_col),
    .valid(valid)
    );
    
    always #1 clk = ~clk;
    always @ (posedge clk) begin
        cnt = cnt + 1;
        if ((cnt >= 100) & ((cnt-100)%13 == 0)) begin
            rst <= 0;
            en <= 1;
            left_in <= image_left[(cnt - 100)/13];
            right_in <= image_right[(cnt - 100)/13];
            row_in <= ((cnt-100)/13)/image_col;
            col_in <= ((cnt-100)/13)%image_col;
        end
        else if (cnt >= 100) begin
            en <= 0;
        end
        if (cnt == image_row*image_col+99) begin
            en = 0;
            cnt = 100;
            row_in = 0;
            col_in = 0;
            left_in = 0;
            right_in = 0;
            frame_cnt = frame_cnt + 1;
        end
    end
    always @ (posedge valid) begin
        $fwrite(file_id, "%H\n", cost_out);
    end
endmodule