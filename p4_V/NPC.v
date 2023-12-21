`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:05:31 11/02/2023 
// Design Name: 
// Module Name:    NPC 
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
`define PC4     3'b000
`define beq     3'b001
`define jTarget 3'b010        //含j和jal，具体判断由CU的控制信号MemToReg实现
`define jr      3'b011        //$ra的输入靠CU中RegDst来实现

module NPC(
    input [31:0] PC,
    input [25:0] imm26,
    input [15:0] imm16,
    input [31:0] Register_ra,
    input [2:0] NPCOp,
    input JSignal,
    output reg [31:0] NPC,
    output [31:0] PC4
    );

    //定义reg、wire、interger区                 
    wire [31:0] beq_ext;          //imm16（beq）的拓展
    wire [31:0] Target;           //j、jal的拓展
    wire [31:0] temp;

    //组合逻辑进行NPC的选择
    assign PC4 = PC + 32'H0000_0004;

    assign temp = {{14{imm16[15]}}, imm16, 2'b00};
    assign beq_ext = temp + PC4;
    
    assign Target = {PC[31:28], imm26, 2'b00};

    always @(*) begin
        case (NPCOp)
            `PC4:        NPC = PC4;
            `beq:        NPC = (JSignal == 1) ? beq_ext : PC4;
            `jTarget:    NPC = Target;
            `jr:         NPC = Register_ra; 
        endcase
    end
    
endmodule
