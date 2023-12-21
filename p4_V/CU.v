`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:48:10 11/02/2023 
// Design Name: 
// Module Name:    CU 
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
module CU(
    input [5:0] OP_CU,
    input [5:0] func,
    output [1:0] RegDst,
    output ALUSrc,
    output [1:0] MemToReg,
    output RegWrite,
    output MemWrite,
    output EXTOp,
    output [3:0] ALUOp,
    output [2:0] NPCOp
    );

    //定义reg、wire、interger区   
    wire add;
    wire sub;
    wire ori;
    wire lw;
    wire sw;
    wire beq;
    wire lui;
    wire addiu;
    wire jal;
    wire jr;

    //and_logic(组合逻辑)
    assign add = (OP_CU == 6'b000000 && func == 6'b100000) ? 1 : 0;
    assign sub = (OP_CU == 6'b000000 && func == 6'b100010) ? 1 : 0;
    assign ori = (OP_CU == 6'b001101) ? 1 : 0;
    assign lw = (OP_CU == 6'b100011) ? 1 : 0;
    assign sw = (OP_CU == 6'b101011) ? 1 : 0;
    assign beq = (OP_CU == 6'b000100) ? 1 : 0;
    assign lui = (OP_CU == 6'b001111) ? 1 : 0;
    assign addiu = (OP_CU == 6'b001001) ? 1 : 0;
    assign jal = (OP_CU == 6'b000011) ? 1 : 0;
    assign jr = (OP_CU == 6'b000000 && func == 6'b001000) ? 1 : 0;

    //or_logic(组合逻辑)
    assign RegDst = (add || sub) ? 2'b01 :
                    (jal) ? 2'b10 :
                            2'b00;

    assign ALUSrc = (ori || lw || sw || lui || addiu) ? 1 : 0;

    assign MemToReg = (lw) ? 2'b01 :
                      (jal) ? 2'b10 :
                              2'b00;

    assign RegWrite = (add || sub || ori || lw || lui || addiu || jal) ? 1 : 0;

    assign MemWrite = (sw) ? 1 : 0;

    assign EXTOp = (sw || lw || addiu) ? 1 : 0;

    assign ALUOp = (sub || beq) ? 4'b0001 :
                   (ori) ? 4'b0010 :
                   (lui) ? 4'b0100 :
                           4'b0000;

    assign NPCOp = (beq) ? 3'b001 :
                   (jal) ? 3'b010 :
                   (jr) ? 3'b011 :
                          3'b000;

endmodule
