`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: Tengyu Zhang (EscapeTHU)
// 
// Create Date: 2022/12/18 12:14:12
// Design Name: project_sgbm
// Module Name: delay_disp
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


module delay_disp#(
    parameter DATA_WIDTH = 864,
    parameter DIM_WIDTH = 10,
    parameter DELAY_DEEP = 13
    )(
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] data_in,
    input [DIM_WIDTH-1:0] row_in,
    input [DIM_WIDTH-1:0] col_in,
    input en,
    output [DATA_WIDTH-1:0] data_out,
    output [DIM_WIDTH-1:0] row_out,
    output [DIM_WIDTH-1:0] col_out,
    output valid
    );
    
    reg [DATA_WIDTH-1:0] data_delay_buffer [DELAY_DEEP-1:0];
    reg [DIM_WIDTH-1:0] row_delay_buffer [DELAY_DEEP-1:0];
    reg [DIM_WIDTH-1:0] col_delay_buffer [DELAY_DEEP-1:0];
    reg en_delay_buffer [DELAY_DEEP-1:0];
    reg [8:0] i;
    assign data_out = data_delay_buffer[DELAY_DEEP-1];
    assign valid = en_delay_buffer[DELAY_DEEP-1];
    assign row_out = row_delay_buffer[DELAY_DEEP-1];
    assign col_out = col_delay_buffer[DELAY_DEEP-1];
    
    initial begin
        for (i = 0; i < DELAY_DEEP; i = i + 1) begin
            data_delay_buffer[i] <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            row_delay_buffer[i] <= 10'h0;
            col_delay_buffer[i] <= 10'h0;
            en_delay_buffer[i] <= 0;
        end
    end
    
    always @ (posedge clk) begin
        if (rst) begin
            for (i = 0; i < DELAY_DEEP; i = i + 1) begin
                data_delay_buffer[i] <= 864'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                row_delay_buffer[i] <= 0;
                col_delay_buffer[i] <= 0;
                en_delay_buffer[i] <= 0;
            end
        end
        else begin
            data_delay_buffer[0] <= data_in;
            row_delay_buffer[0] <= row_in;
            col_delay_buffer[0] <= col_in;
            en_delay_buffer[0] <= en;
            for (i = 1; i < DELAY_DEEP; i = i + 1) begin
                data_delay_buffer[i] <= data_delay_buffer[i-1];
                row_delay_buffer[i] <= row_delay_buffer[i-1];
                col_delay_buffer[i] <= col_delay_buffer[i-1];
                en_delay_buffer[i] <= en_delay_buffer[i-1];
            end
        end
    end
endmodule
