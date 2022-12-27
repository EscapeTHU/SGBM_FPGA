`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/14 11:15:09
// Design Name: aggregate cost
// Module Name: delay
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


module delay#(
    parameter DATA_WIDTH = 864,
    parameter DELAY_DEEP = 4
    )(
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] data_in,
    input en,
    output [DATA_WIDTH-1:0] data_out,
    output valid
    );
    
    reg [DATA_WIDTH-1:0] data_delay_buffer [DELAY_DEEP-1:0];
    reg en_delay_buffer [DELAY_DEEP-1:0];
    reg [8:0] i;
    assign data_out = data_delay_buffer[DELAY_DEEP-1];
    assign valid = en_delay_buffer[DELAY_DEEP-1];
    
    initial begin
        for (i = 0; i < DELAY_DEEP; i = i + 1) begin
            data_delay_buffer[i] <= ~0;
            en_delay_buffer[i] <= 0;
        end
    end
    
    always @ (posedge clk) begin
        if (rst) begin
            for (i = 0; i < DELAY_DEEP; i = i + 1) begin
                data_delay_buffer[i] <= ~0;
                en_delay_buffer[i] <= 0;
            end
        end
        else if (en) begin
            data_delay_buffer[0] <= data_in;
            en_delay_buffer[0] <= en;
            for (i = 1; i < DELAY_DEEP; i = i + 1) begin
                data_delay_buffer[i] <= data_delay_buffer[i-1];
                en_delay_buffer[i] <= en_delay_buffer[i-1];
            end
        end
    end
endmodule
