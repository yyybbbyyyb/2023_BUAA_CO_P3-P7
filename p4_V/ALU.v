`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:23:58 11/01/2023 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [31:0] a,
    input [31:0] b,
    input [3:0] ALUOp,
    output [31:0] result,
    output JSignal
    );

	wire [31:0] lui_result = {b[15:0], 16'H0000};
	
    assign result = (ALUOp == 4'b0000) ? a + b :                    //加运算
                    (ALUOp == 4'b0001) ? a - b :                    //减运算
                    (ALUOp == 4'b0010) ? a | b :                    //或运算
                    (ALUOp == 4'b0011) ? a & b :                    //和运算
                    (ALUOp == 4'b0100) ? lui_result :     //低16位补0
                                         32'H0000_0000;

    assign JSignal = (result == 32'H0000_0000) ? 1 : 0;             //判断是否跳转信号

endmodule
