`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:24:25 11/01/2023 
// Design Name: 
// Module Name:    IFU 
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
module IFU(
    input [31:0] NPC,
    input clk,
    input rst,
    output reg [31:0] PC,
    output [31:0] OP
    );

    //定义reg、wire、interger区
    reg [31:0] IM_memory [0:4095];    //实现ROM 4096 * 32bit
    
    integer IFU_i;    //专门用于IFU的循环变量

    wire [31:0] realPC;       //PC - 0x00003000
	wire [11:0] findAddr;    //具体去ROM里寻址的地址

    
	//初始化PC和ROM
    initial begin
        PC = 32'H0000_3000;
        $readmemh("code.txt", IM_memory);
    end

    //处理PC寄存器
    always @(posedge clk) begin
        if (rst) begin
            PC <= 32'H0000_3000;
        end
        else begin
            PC <= NPC;
        end
    end


    //IM寻址操作
	assign realPC = PC - 32'H0000_3000;
	assign findAddr = realPC[13:2];
    assign OP = IM_memory[findAddr];

endmodule
