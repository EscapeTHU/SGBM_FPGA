`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/14 18:24:41
// Design Name: 
// Module Name: tb_aggr_cost
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_aggr_cost();
    parameter image_row = 200;
    parameter image_col = 400;
    
    reg clk;
    reg rst;
    reg en;
    reg [863:0] cost_init_in;
    reg [9:0] row_in;
    reg [9:0] col_in;
    reg [863:0] cost_init_image [image_row*image_col-1:0];
    reg [4:0] frame_cnt;
    reg [19:0] cnt;
    
    wire [863:0] cost_aggr_out;
    wire [863:0] cost_delay_in;
    wire [9:0] row_delay;
    wire [9:0] col_delay;
    wire [9:0] row_out;
    wire [9:0] col_out;
    wire valid_delay;
    wire valid;
    
    integer file_id;
    
    initial begin
        $readmemh("E:/Xilinx_project/aggregate_cost/image_data/cost_init_X_t.txt", cost_init_image);
        file_id = $fopen("E:/Xilinx_project/aggregate_cost/image_data/mem2image.txt", "w");
        clk = 0;
        rst = 1;
        en = 0;
        frame_cnt = 0;
        row_in = 0;
        col_in = 0;
        cost_init_in = 0;
        cnt = 0;
    end
    
    delay_aggr u_0(
    .clk(clk),
    .rst(rst),
    .en(en),
    .data_in(cost_init_in),
    .row_in(row_in),
    .col_in(col_in),
    .data_out(cost_delay_in),
    .row_out(row_delay),
    .col_out(col_delay),
    .valid(valid_delay)
    );
    
    aggregate_cost u_1(
    .clk(clk),
    .rst(rst),
    .en(valid_delay),
    .cost_init(cost_delay_in),
    .cost_aggr_last(cost_aggr_out),
    .row(row_delay),
    .col(col_delay),
    .cost_aggr(cost_aggr_out),
    .out_row(row_out),
    .out_col(col_out),
    .valid(valid)
    );
    
    always #1 clk = ~clk;
    always @ (posedge clk) begin
        cnt = cnt + 1;
        if (cnt >= 100) begin
            rst <= 0;
            en <= 1;
            cost_init_in <= cost_init_image[cnt - 100];
            row_in <= (cnt-100)/image_col;
            col_in <= (cnt-100)%image_col;
            if (valid == 1) begin
                $fwrite(file_id, "%H\n", cost_aggr_out);
            end
        end
        if (cnt == image_row*image_col+99) begin
            cnt <= 100;
            row_in <= 0;
            col_in <= 0;
            cost_init_in <= 0;
            frame_cnt <= frame_cnt + 1;
        end
    end
endmodule
