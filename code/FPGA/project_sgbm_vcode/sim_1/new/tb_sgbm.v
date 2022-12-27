`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/17 11:41:37
// Design Name: project_sgbm
// Module Name: tb_sgbm
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


module tb_sgbm();
    parameter image_row = 200;
    parameter image_col = 400;
    
    wire [31:0] left_census;
    wire [31:0] right_census;
    wire [9:0] census_row_left;
    wire [9:0] census_col_left;
    wire [9:0] census_row_right;
    wire [9:0] census_col_right;
    wire census_valid_left;
    wire census_valid_right;
    wire [863:0] org_cost;
    wire [9:0] org_cost_row;
    wire [9:0] org_cost_col;
    wire org_cost_valid;
    wire [863:0] cost_aggr;
    wire [9:0] aggr_row;
    wire [9:0] aggr_col;
    wire aggr_valid;
    
    wire [19:0] test_cnt_left;
    wire [19:0] test_cnt_right;
    
    reg clk;
    reg rst;
    reg en;
    reg [7:0] grey_left;
    reg [7:0] grey_right;
    reg [9:0] grey_row_left;
    reg [9:0] grey_col_left;
    reg [9:0] grey_row_right;
    reg [9:0] grey_col_right;
    
    reg [7:0] grey_img_left [image_row*image_col-1:0];
    reg [7:0] grey_img_right [image_row*image_col-1:0];
    
    reg [19:0] cnt;
    reg [4:0] frame_cnt;
    
    integer file_id;
    
    census u_census_left(
    .clk(clk),
    .rst(rst),
    .en(en),
    .inData(grey_left),
    .row_in(grey_row_left),
    .col_in(grey_col_left),
    .outData(left_census),
    .row_out(census_row_left),
    .col_out(census_col_left),
    .valid(census_valid_left),
    .test_cnt(test_cnt_left)
    );
    
    census u_census_right(
    .clk(clk),
    .rst(rst),
    .en(en),
    .inData(grey_right),
    .row_in(grey_row_right),
    .col_in(grey_col_right),
    .outData(right_census),
    .row_out(census_row_right),
    .col_out(census_col_right),
    .valid(census_valid_right),
    .test_cnt(test_cnt_right)
    );
    
    origin_cost u_org(
    .clk(clk),
    .rst(rst),
    .en(census_valid_left),
    .left_pix(left_census),
    .right_pix(right_census),
    .row(census_row_left),
    .col(census_col_left),
    .cost(org_cost),
    .out_row(org_cost_row),
    .out_col(org_cost_col),
    .valid(org_cost_valid)
    );
    
    aggregate_cost u_aggr(
    .clk(clk),
    .rst(rst),
    .en(org_cost_valid),
    .cost_init(org_cost),
    .row(org_cost_row),
    .col(org_cost_col),
    .cost_aggr(cost_aggr),
    .out_row(aggr_row),
    .out_col(aggr_col),
    .valid(aggr_valid)
    );

    initial begin
        $readmemh("E:/Xilinx_project/project_sgbm/image_data/image2mem_left.txt", grey_img_left);
        $readmemh("E:/Xilinx_project/project_sgbm/image_data/image2mem_right.txt", grey_img_right);
        file_id = $fopen("E:/Xilinx_project/project_sgbm/image_data/mem2image.txt", "w");
        clk <= 1'b0;
        rst <= 1'b1;
        en <= 1'b0;
        grey_left <= 8'b0;
        grey_right <= 8'b0;
        grey_row_left <= 8'b0;
        grey_col_left <= 8'b0;
        grey_row_right <= 8'b0;
        grey_col_right <= 8'b0;
        cnt <= 0;
        frame_cnt <= 0;
    end
    
    always #1 clk = ~clk;
    always @ (posedge clk) begin
        cnt = cnt + 1;
        if ((cnt >= 100) & ((cnt-100)%13==0)) begin
            rst <= 0;
            en <= 1;
            grey_left <= grey_img_left[(cnt - 100)/13];
            grey_right <= grey_img_right[(cnt - 100)/13];
            grey_row_left <= ((cnt-100)/13)/image_col;
            grey_col_left <= ((cnt-100)/13)%image_col;
            grey_row_right <= ((cnt-100)/13)/image_col;
            grey_col_right <= ((cnt-100)/13)%image_col;
        end
        else if (cnt >= 100) begin
            en <= 0;
        end
        if (cnt == image_row*image_col+99) begin
            cnt <= 100;
            grey_left <= 0;
            grey_right <= 0;
            grey_row_left <= 0;
            grey_col_left <= 0;
            grey_row_right <= 0;
            grey_col_right <= 0;
            frame_cnt <= frame_cnt + 1;
        end
    end
    always @ (posedge aggr_valid) begin
        $fwrite(file_id, "%H\n", cost_aggr);
    end
endmodule
