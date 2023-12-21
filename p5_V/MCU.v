`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------
`define npcPC4    3'b000
`define npcJal    3'b001
`define npcJr     3'b010
`define npcBranch 3'b011

`define aluAdd    4'b0000
`define aluSub    4'b0001
`define aluOr     4'b0010
`define aluAnd    4'b0011
`define aluLui    4'b0100

`define dmWord    2'b00
`define dmByte    2'b01
`define dmHalf    2'b10

`define ALUout    2'b00
`define DMout     2'b01
`define PC8       2'b10

`define Rt        2'b00
`define Rd        2'b01
`define RA        2'b10
`define Zero      2'b11
//--------------------------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module MCU(
    input [5:0] opcode,
    input [5:0] func,

    output [2:0] CU_NPC_op_D,
    output [3:0] CU_ALU_op_D,
    output CU_EXT_op_D,
    output [1:0] CU_DM_op_D,
    
    output CU_EN_RegWrite_D,
    output CU_EN_DMWrite_D,
    
    output [1:0] CU_GRFWriteData_Sel_D,
    output [1:0] CU_GRFWriteAddr_Sel_D,
    output CU_ALUB_Sel_D,

    output [1:0] T_use_rs,
    output [1:0] T_use_rt,
    output [1:0] T_new_D    
    );
//----------------------------------------------------------------------------------------------------
    
    
//instr_wire----------------------------------------------------------------------------------------------------   
    wire add = (opcode == 6'b000000 && func == 6'b100000) ? 1 : 0;;
    wire sub = (opcode == 6'b000000 && func == 6'b100010) ? 1 : 0;
    wire ori = (opcode == 6'b001101) ? 1 : 0;
    wire lw = (opcode == 6'b100011) ? 1 : 0;
    wire sw = (opcode == 6'b101011) ? 1 : 0;
    wire beq = (opcode == 6'b000100) ? 1 : 0;
    wire lui = (opcode == 6'b001111) ? 1 : 0;
    wire addiu = (opcode == 6'b001001) ? 1 : 0;
    wire jal = (opcode == 6'b000011) ? 1 : 0;
    wire jr = (opcode == 6'b000000 && func == 6'b001000) ? 1 : 0;
    wire j = (opcode == 6'b000010) ? 1 : 0;
//--------------------------------------------------------------------------------------------------------------


//op_signal------------------------------------------------------------------------------------------------------------
    assign CU_NPC_op_D = (beq) ? `npcBranch :
                         (jal | j) ? `npcJal :
                         (jr) ? `npcJr :
                                `npcPC4;

    assign CU_ALU_op_D = (sub) ? `aluSub :
                         (ori) ? `aluOr :
                         (lui) ? `aluLui :
                                 `aluAdd;
    
    assign CU_EXT_op_D = (sw | lw | addiu) ? 1 : 0;
    
    assign CU_DM_op_D = `dmWord;
//---------------------------------------------------------------------------------------------------------------------    
    
    
//en_signal--------------------------------------------------------------------------------------------------------    
    assign CU_EN_RegWrite_D = (add | sub | ori | lw | lui | addiu | jal) ? 1 : 0;
    
    assign CU_EN_DMWrite_D = (sw) ? 1 : 0;
//-----------------------------------------------------------------------------------------------------------------


//sel_signal------------------------------------------------------------------------------------------------------
    assign CU_GRFWriteData_Sel_D = (lw) ? `DMout :
                                   (jal) ? `PC8 :
                                           `ALUout;

    assign CU_GRFWriteAddr_Sel_D = (add | sub) ? `Rd :
                                   (ori | lw | lui | addiu) ? `Rt :
                                   (jal) ? `RA :
                                           `Zero;

    assign CU_ALUB_Sel_D = (ori | lw | sw | lui | addiu) ? 1 : 0;
//-----------------------------------------------------------------------------------------------------------------


//T_signal----------------------------------------------------------------------------------------------------------
    assign T_use_rs = (add | sub | ori | lw | sw | lui | addiu) ? 2'b01 :
                      (beq | jr) ? 2'b00 :
                                   2'b11;

    assign T_use_rt = (add | sub) ? 2'b01 :
                      (beq) ? 2'b00 :
                      (sw) ? 2'b10 :
                             2'b11;

    assign T_new_D = (add | sub | ori | lui | addiu) ? 2'b10 :
                     (lw) ? 2'b11 :
                     (jal) ? 2'b01 :
                             2'b00;
//----------------------------------------------------------------------------------------------------------------------
                             
endmodule