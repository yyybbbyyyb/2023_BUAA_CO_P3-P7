`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:36:05 11/01/2023 
// Design Name: 
// Module Name:    GRF 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module GRF(
    input clk,
    input rst,
    input RegWrite,
    input [4:0] RegAddr1,
    input [4:0] RegAddr2,
    input [4:0] WriteRegAddr,
    input [31:0] WriteData,
    output [31:0] ReadData1,
    output [31:0] ReadData2
    );

    //定义reg、wire、interger区
    reg [31:0] register_32 [0:31];   //构建32个寄存器堆

    integer GRF_i;     //专用于GRF的循环变量

    //读数据（直接使用组合逻辑）
    assign ReadData1 = (RegAddr1 == 5'b00000) ? 32'H0000_0000 : register_32[RegAddr1];
    assign ReadData2 = (RegAddr2 == 5'b00000) ? 32'H0000_0000 : register_32[RegAddr2];

    //写数据（顺便处理复位操作）
    always @(posedge clk) begin
        if (rst) begin
            for (GRF_i = 0; GRF_i < 32; GRF_i = GRF_i + 1) begin
                register_32[GRF_i] = 32'H0000_0000;
            end        
        end 
        else begin
            if (RegWrite) begin
                register_32[WriteRegAddr] <= WriteData;
            end
        end
    end

endmodule
