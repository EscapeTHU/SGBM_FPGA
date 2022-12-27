`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Tsinghua University
// Engineer: EscapeTHU (Tengyu Zhang)
// 
// Create Date: 2022/12/13 16:30:00
// Design Name: census
// Module Name: tb_census
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


module tb_census(

    );
    reg clk;
    reg [7:0] inData;
    reg [19:0] cnt;
    reg [9:0] row;
    wire [7:0] outData;
    reg [7:0] image [307199:0];
    integer file_id;
    reg [4:0] frame_cnt;
    
    initial begin
        $readmemh("D:/Vivado_projiect/census/test/image2mem.txt", image);
        file_id = $fopen("D:/Vivado_projiect/census/test/mem2image.txt", "w");
        clk = 0;
        cnt = 0;
        row = 0;
        frame_cnt = 0;
    end
    census t_1(
    .clk(clk),
    .x(1),
    .y(1),
    .inData(inData),
    .outData(outData)
    );
    
    always #1 clk = ~clk;
    always @ (posedge clk)
    begin
        if (cnt == 307200) begin
            cnt = 0;
            row = 0;
            frame_cnt = frame_cnt+1;
        end
        else
            inData = image[cnt];
            cnt = cnt+1;
            if (frame_cnt == 1) begin
                $fwrite(file_id, "%d\t", outData);
                if (((cnt%640) == 0) && (cnt>0)) begin
                    $fwrite(file_id, "\n");
                    row = row+1;
                end
            end
    end
    
endmodule
