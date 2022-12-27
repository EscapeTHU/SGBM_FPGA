`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/20 10:30:08
// Design Name: project_sgbm
// Module Name: tb_disparity_aggr
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


module tb_disparity_aggr();
    parameter image_row = 200;
    parameter image_col = 400;
    
    reg clk;
    reg rst;
    reg en;
    reg [863:0] cost_aggr;
    reg [863:0] cost_aggr_image [image_row*image_col-1:0];
    reg [9:0] row_in;
    reg [9:0] col_in;
    reg [4:0] frame_cnt;
    reg [19:0] cnt;
    
    wire [31:0] disparity;
    wire [7:0] min_aggr_out;
    wire [7:0] sec_min_aggr_out;
    wire [7:0] pos_min_out;
    wire [7:0] check_min_output;
    wire [7:0] check_min_aggr_new;
    wire [7:0] check_min_aggr_new_delay;
    wire [9:0] row_out;
    wire [9:0] col_out;
    wire valid;
    
    integer file_id;
    
    initial begin
        $readmemh("E:/Xilinx_project/project_sgbm/image_data/aggr_lr_X_t.txt", cost_aggr_image);
        file_id = $fopen("E:/Xilinx_project/project_sgbm/image_data/disparity_res.txt", "w");
        clk = 0;
        rst = 0;
        en = 0;
        cost_aggr = 0;
        row_in = 0;
        col_in = 0;
        cnt = 0;
        frame_cnt = 0;
    end
    
    disparity_calc_test u(
    .clk(clk),
    .rst(rst),
    .en(en),
    .cost_aggr(cost_aggr),
    .row_in(row_in),
    .col_in(col_in),
    .disparity(disparity),
    .min_aggr_out(min_aggr_out),
    .sec_min_aggr_out(sec_min_aggr_out),
    .pos_min_out(pos_min_out),
    .check_min_output(check_min_output),
    .check_min_aggr_new(check_min_aggr_new),
    .check_min_aggr_new_delay(check_min_aggr_new_delay),
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
            cost_aggr <= cost_aggr_image[(cnt - 100)/13];
            row_in <= ((cnt-100)/13)/image_col;
            col_in <= ((cnt-100)/13)%image_col;
        end
        else if (cnt >= 100) begin
            en <= 0;
        end
        if (cnt == image_row*image_col+99) begin
            cnt <= 100;
            row_in <= 0;
            col_in <= 0;
            cost_aggr <= 0;
            frame_cnt <= frame_cnt + 1;
        end
    end
    
    always @ (posedge valid) begin
        $fwrite(file_id, "%H\n", disparity);
    end
endmodule
