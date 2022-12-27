`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/22 10:21:45
// Design Name: project_image
// Module Name: ram_rw
// Project Name: project_image
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


module ram_rw(
    input clk,
    input rst,
    input [31:0] disparity,
    input [9:0] row_in,
    input [9:0] col_in,
    input valid,
    // RAM ports
    output ram_clk,
    input [31:0] ram_rd_data,
    output reg ram_en,
    output reg [31:0] ram_addr,
    output reg [3:0] ram_we,
    output reg [31:0] ram_wr_data,
    output reg ram_rst,
    output reg intr
    // output reg [31:0] my_addr_cnt
    );
    
    assign ram_clk = clk;
    reg [31:0] my_addr_cnt;
    reg status;
    
    initial begin
        my_addr_cnt <= 32'b0;
        status <= 0;
        ram_en <= 1'b0;
        ram_addr <= 32'b0;
        ram_we <= 4'b1111;
        ram_rst <= 1'b1;
        ram_wr_data <= 32'b0;
        intr <= 1'b0;
    end
    
    always @ (posedge clk) begin
        if (rst) begin
            my_addr_cnt <= 32'b0;
            status <= 0;
            ram_en <= 1'b0;
            ram_addr <= 32'b0;
            ram_we <= 4'b1111;
            ram_rst <= 1'b1;
            ram_wr_data <= 32'b0;
            intr <= 1'b0;
        end
        else begin
            if ((valid) & (status == 1'b0)) begin
                if ((row_in == 10'd199) & (col_in == 10'd399)) begin
                    // tictoc #1 write_to_output
                    status <= 1'b1;
                    ram_en <= 1'b1;
                    ram_addr <= my_addr_cnt;
                    ram_we <= 4'b1111;
                    ram_rst <= 1'b0;
                    ram_wr_data <= disparity;
                    // tictoc #2 renew_my_new_addr
                    my_addr_cnt <= my_addr_cnt + 4;
                end
                else begin
                    // tictoc #1 write_to_output
                    ram_en <= 1'b1;
                    ram_addr <= my_addr_cnt;
                    ram_we <= 4'b1111;
                    ram_rst <= 1'b0;
                    ram_wr_data <= disparity;
                    // tictoc #2 renew_my_new_addr
                    my_addr_cnt <= my_addr_cnt + 4;
                end
            end
            else if (status == 1'b1) begin
                intr <= 1'b1;
            end
        end
    end
endmodule
