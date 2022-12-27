`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/21 22:07:48
// Design Name: project_sgbm
// Module Name: tb_ram_rw
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


module tb_ram_rw();
    parameter image_row = 200;
    parameter image_col = 400;

    reg clk;
    reg rst;
    reg valid;
    reg [31:0] disparity;
    reg [31:0] disparity_img [image_row*image_col-1:0];
    reg [9:0] row_in;
    reg [9:0] col_in;
    reg [19:0] cnt;
    
    wire ram_clk;
    wire ram_en;
    wire [31:0] ram_addr;
    wire [3:0] ram_we;
    wire [31:0] ram_wr_data;
    wire [31:0] my_addr_cnt;
    wire ram_rst;
    wire intr;
    
    initial begin
        clk = 1'b0;
        rst = 1'b0;
        valid = 1'b0;
        disparity = 32'b0;
        row_in = 10'b0;
        col_in = 10'b0;
        $readmemh("E:/Xilinx_project/project_sgbm/image_data/my_disparity.txt", disparity_img);
        cnt = 20'b0;
    end
    
    ram_rw u(
    .clk(clk),
    .rst(rst),
    .disparity(disparity),
    .row_in(row_in),
    .col_in(col_in),
    .valid(valid),
    .ram_rd_data(32'b0),
    .ram_clk(ram_clk),
    .ram_en(ram_en),
    .ram_addr(ram_addr),
    .ram_we(ram_we),
    .ram_wr_data(ram_wr_data),
    .ram_rst(ram_rst),
    .intr(intr),
    .my_addr_cnt(my_addr_cnt)
    );
    
    always #1 clk = ~clk;
    always @ (posedge clk) begin
        cnt <= cnt + 1;
        if ((cnt >= 100) & ((cnt-100)%13 == 0)) begin
            rst <= 0;
            valid <= 1;
            disparity <= disparity_img[(cnt - 100)/13];
            row_in <= ((cnt-100)/13)/image_col;
            col_in <= ((cnt-100)/13)%image_col;
        end
        else if (cnt >= 100) begin
            valid <= 0;
        end
        if (cnt == image_row*image_col+99) begin
            cnt <= 100;
            row_in <= 0;
            col_in <= 0;
            disparity <= 0;
        end
    end
endmodule
