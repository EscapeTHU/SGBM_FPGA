`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/18 22:01:56
// Design Name: project
// Module Name: tb_disparity_calc
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/18 19:59:46
// Design Name: 
// Module Name: tb_disparity_calc
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

module tb_disparity_calc();
    reg clk;
    reg rst;
    reg en;
    reg [863:0] cost_aggr;
    reg [9:0] row_in;
    reg [9:0] col_in;
    wire[31:0] disparity;
    wire [9:0] row_out;
    wire [9:0] col_out;
    wire valid;
    reg [15:0]cnt;
    reg [15:0]cnt_19;
    reg start;
    
    wire [7:0] min_aggr_out;
    wire [7:0] sec_min_aggr_out;
    wire [7:0] pos_min_out;
    wire [7:0] check_min_output;
    wire [7:0] check_min_aggr_output;
    wire [7:0] check_min_aggr_delay_output;
    
    initial begin
    clk <= 0;
    rst <= 1;
    en <= 1;
    cost_aggr <= 0;
    row_in <= 15;
    col_in <= 55;
    cnt <= 1;
    cnt_19 <= 0;
    start <= 0;
    #25
    cost_aggr <= cost_aggr-1;
    #25
    cost_aggr[15:8] <= 10;
    cost_aggr[31:24] <= 5;
    #125
    start <= 1;
    #25
    rst <= 0;
    en <= 1;
    end
    always #25 clk <= ~clk;
    
    disparity_calc tb(
    .clk(clk),
    .rst(rst),
    .en(en),
    .cost_aggr(cost_aggr),
    .row_in(row_in),
    .col_in(col_in),
    .valid(valid),
    .disparity(disparity),
    .row_out(row_out),
    .col_out(col_out),
    .min_aggr_out(min_aggr_out),
    .sec_min_aggr_out(sec_min_aggr_out),
    .pos_min_out(pos_min_out),
    .check_min_output(check_min_output),
    .check_min_aggr_new(check_min_aggr_output),
    .check_min_aggr_new_delay(check_min_aggr_delay_output)
    );
    
    always@(posedge clk)
    begin
    if(start == 1)
    begin
    if(cnt_19 < 18)
      cnt_19 <= cnt_19+1;
    else
    begin
       cnt_19 <= 0;
        if(cnt == 10)
        begin
            cnt <= 1;
            cost_aggr[15:8] <= 10;
            cost_aggr[31:24] <= 5;
        end
        else
        begin
            cnt <= cnt +1;
            cost_aggr[cnt*16-1 -: 8] <= 10;
            cost_aggr[cnt*16+15 -: 8] <= 5;
        end
     end
    end
    
    
    end
endmodule
