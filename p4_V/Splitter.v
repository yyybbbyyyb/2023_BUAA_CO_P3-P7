`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:47:44 11/02/2023 
// Design Name: 
// Module Name:    Splitter 
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
module Splitter(
    input [31:0] OP,
    output [5:0] OP_CU,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [5:0] func,
    output [15:0] imm16,
    output [25:0] imm26
    );

    //组合逻辑，实现分线功能
    assign OP_CU = OP[31:26];
    assign rs = OP[25:21];
    assign rt = OP[20:16];
    assign rd = OP[15:11];
    assign func = OP[5:0];
    assign imm16 = OP[15:0];
    assign imm26 = OP[25:0];

endmodule
