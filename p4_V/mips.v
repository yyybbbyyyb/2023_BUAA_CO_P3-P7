`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:23:43 11/01/2023 
// Design Name: 
// Module Name:    mips 
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
module mips(
    input clk,
    input reset
    );

//导线------------------------------------------------------------------------------
//CU--------------------------------------------------------------------------------
    wire [1:0] RegDst;
    wire ALUScr;
    wire [1:0] MemToReg;
    wire RegWrite;
    wire MemWrite;
    wire EXTOp;
    wire [3:0] ALUOp;
    wire [2:0] NPCOp;
//NPC-------------------------------------------------------------------------------
    wire [31:0] PC4;
    wire [31:0] NPC;
//IFU-------------------------------------------------------------------------------
    wire [31:0] OP;
    wire [31:0] PC;
//Splitter--------------------------------------------------------------------------
    wire [5:0] OP_CU;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [5:0] func;
    wire [15:0] imm16;
    wire [25:0] imm26;
//GRF-------------------------------------------------------------------------------
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
//ALU-------------------------------------------------------------------------------
    wire [31:0] result;
    wire JSignal;
//DM--------------------------------------------------------------------------------
    wire [31:0] ReadData;
//----------------------------------------------------------------------------------



//顶层逻辑的多路选择器（组合逻辑）-------------------------------------------------------
    wire [4:0] RegAddr;
    wire [31:0] RegData;
    wire [31:0] imm16_ext;
    wire [31:0] ALU_B;

    assign RegAddr = (RegDst == 2'b00) ? rt :
                     (RegDst == 2'b01) ? rd :
                                         5'b11111;

    assign RegData = (MemToReg == 2'b00) ? result :
                     (MemToReg == 2'b01) ? ReadData :
                                           PC4;

    assign imm16_ext = (EXTOp == 1) ? {{16{imm16[15]}}, imm16} : 
                                      {16'H0000, imm16};

    assign ALU_B = (ALUSrc == 1) ? imm16_ext : ReadData2;
//--------------------------------------------------------------------------------------
	
    
    
//连线----------------------------------------------------------------------------------    
//NPC-----------------------------------------------------------------------------------    
    NPC npc (
		.PC(PC), 
		.imm26(imm26), 
		.imm16(imm16), 
		.Register_ra(ReadData1), 
		.NPCOp(NPCOp), 
		.JSignal(JSignal), 
		.NPC(NPC), 
		.PC4(PC4)
	);
//IFU-----------------------------------------------------------------------------------
	IFU ifu (
		.NPC(NPC), 
		.clk(clk), 
		.rst(reset), 
        .PC(PC),
		.OP(OP)
	);
//Splitter------------------------------------------------------------------------------
	Splitter splitter (
		.OP(OP), 
		.OP_CU(OP_CU), 
		.rs(rs), 
		.rt(rt), 
		.rd(rd), 
		.func(func), 
		.imm16(imm16), 
		.imm26(imm26)
	);
//GRF------------------------------------------------------------------------------------
	GRF grf (
		.clk(clk), 
		.rst(reset), 
		.RegWrite(RegWrite), 
		.RegAddr1(rs), 
		.RegAddr2(rt), 
		.WriteRegAddr(RegAddr), 
		.WriteData(RegData), 
		.ReadData1(ReadData1), 
		.ReadData2(ReadData2)
	);    
//ALU-------------------------------------------------------------------------------------
	ALU alu (
		.a(ReadData1), 
		.b(ALU_B), 
		.ALUOp(ALUOp), 
		.result(result), 
		.JSignal(JSignal)
	);
//DM--------------------------------------------------------------------------------------
	DM dm (
		.addr(result), 
		.writeData(ReadData2), 
		.clk(clk), 
		.MemWrite(MemWrite), 
		.rst(reset), 
		.DMOp(2'b00),         
		.ReadData(ReadData)
	);
//CU--------------------------------------------------------------------------------------
	CU cu (
		.OP_CU(OP_CU), 
		.func(func), 
		.RegDst(RegDst), 
		.ALUSrc(ALUSrc), 
		.MemToReg(MemToReg), 
		.RegWrite(RegWrite), 
		.MemWrite(MemWrite), 
		.EXTOp(EXTOp), 
		.ALUOp(ALUOp), 
		.NPCOp(NPCOp)
	);
//----------------------------------------------------------------------------------------



//输出语句
    always @(posedge clk)begin
        if (RegWrite == 1 && !reset)  begin
            $display("@%h: $%d <= %h", PC, RegAddr, RegData);
        end
        if (MemWrite == 1 && !reset)  begin
            $display("@%h: *%h <= %h", PC, result, ReadData2);
        end
    end


endmodule
