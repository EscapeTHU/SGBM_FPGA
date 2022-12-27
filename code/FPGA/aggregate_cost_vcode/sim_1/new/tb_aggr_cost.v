`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/14 18:24:41
// Design Name: aggregate cost
// Module Name: tb_aggr_cost
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
    
    wire [863:0] cost_aggr_last;
    wire [863:0] cost_aggr_delay;
    wire [863:0] cost_aggr_min;
    wire [863:0] cost_aggr;
    wire [9:0] out_row;
    wire [9:0] out_col;
    wire [9:0] row_delay;
    wire [9:0] col_delay;
    wire [9:0] row_delay_out;
    wire [9:0] col_delay_out;
    wire [7:0] min_aggr;
    wire valid;
    wire valid_delay;
    wire valid_delay_out;
    
    assign cost_aggr_delay = cost_aggr;
    assign cost_aggr_min = cost_aggr;
    assign row_delay = out_row;
    assign col_delay = out_col;
    assign valid_delay = valid;
    
    integer file_id;
    
    initial begin
        $readmemh("E:/Xilinx_project/aggregate_cost/image_data/cost_init_X_t.txt", cost_init_image);
        file_id = $fopen("E:/Xilinx_project/aggregate_cost/image_data/mem2image.txt", "w");
        clk = 0;
        rst = 1;
        en = 0;
        frame_cnt = 5'h0;
        row_in = 10'h0;
        col_in = 10'h0;
        cost_init_in = 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        cnt = 20'h0;
    end
    
    aggregate_cost u_aggr(
    .clk(clk),
    .rst(rst),
    .en(en),
    .cost_init(cost_init_in),
    .cost_aggr_last(cost_aggr_last),
    .min_aggr_last(min_aggr),
    .row(row_in),
    .col(col_in),
    .cost_aggr(cost_aggr),
    .out_row(out_row),
    .out_col(out_col),
    .valid(valid)
    );
    
    delay_aggr #(
    .DATA_WIDTH (864),
    .DIM_WIDTH (10),
    .DELAY_DEEP (8)
    )
    u_delay(
    .clk(clk),
    .rst(rst),
    .data_in(cost_aggr_delay),
    .row_in(row_delay),
    .col_in(col_delay),
    // .en(valid_delay),
    .en(1),
    .data_out(cost_aggr_last),
    .row_out(row_delay_out),
    .col_out(col_delay_out),
    .valid(valid_delay_out)
    );
    
    min_aggr_cost u_min(
    .clk(clk),
    .rst(rst),
    .data_in(cost_aggr_min),
    .min_aggr(min_aggr)
    );

    always #1 clk = ~clk;
    always @ (posedge clk) begin
        cnt = cnt + 1;
        if ((cnt >= 100) & ((cnt-100)%13==0)) begin
            rst <= 0;
            en <= 1;
            cost_init_in <= cost_init_image[(cnt - 100)/13];
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
            cost_init_in <= 0;
            frame_cnt <= frame_cnt + 1;
        end
    end
    
    always @ (posedge valid) begin
        $fwrite(file_id, "%H\n", cost_aggr);
    end
endmodule
