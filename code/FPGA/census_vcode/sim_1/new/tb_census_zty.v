`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/16 18:36:02
// Design Name: census
// Module Name: tb_census_zty
// Project Name: census
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


module tb_census_zty();
    parameter image_row = 200;
    parameter image_col = 400;
    
    reg clk;
    reg rst;
    reg en;
    reg [7:0] grey_in;
    reg [9:0] row_in;
    reg [9:0] col_in;
    reg [7:0] image_grey [image_row*image_col-1:0];
    reg [4:0] frame_cnt;
    reg [19:0] cnt;
    
    wire [31:0] outData;
    wire [9:0] row_out;
    wire [9:0] col_out;
    wire valid;
    
    integer file_id;
    
    initial begin
        $readmemh("E:/Xilinx_project/project_census/image_data/image2mem_left.txt", image_grey);
        file_id = $fopen("E:/Xilinx_project/project_census/image_data/mem2image.txt", "w");
        clk = 0;
        rst = 1;
        en = 0;
        cnt = 0;
        frame_cnt = 0;
        grey_in = 0;
        row_in = 0;
        col_in = 0;
    end
    
    census u(
    .clk(clk),
    .rst(rst),
    .en(en),
    .inData(grey_in),
    .row_in(row_in),
    .col_in(col_in),
    .outData(outData),
    .row_out(row_out),
    .col_out(col_out),
    .valid(valid)
    );
    
    always #1 clk = ~clk;
    always @ (posedge clk) begin
        cnt = cnt + 1;
        if ((cnt >= 100) & ((cnt-100)%13 == 0)) begin
            rst <= 0;
            en <= 1;
            grey_in <= image_grey[(cnt - 100)/13];
            row_in <= ((cnt-100)/13)/image_col;
            col_in <= ((cnt-100)/13)%image_col;
        end
        else if (cnt >= 100) begin
            en <= 0;
        end
        if (cnt == image_row*image_col+99) begin
            en <= 0;
            cnt <= 100;
            row_in <= 0;
            col_in <= 0;
            grey_in <= 0;
            frame_cnt <= frame_cnt + 1;
        end
    end
    
    always @ (posedge valid) begin
        $fwrite(file_id, "%H\n", outData);
    end
endmodule
