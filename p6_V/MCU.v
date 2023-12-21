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
`define aluSlt    4'b0101
`define aluSltu   4'b0110

`define dmWord    2'b00
`define dmByte    2'b01
`define dmHalf    2'b10

`define ALUout    2'b00
`define DMout     2'b01
`define PC8       2'b10
`define MDUout    2'b11

`define Rt        2'b00
`define Rd        2'b01
`define RA        2'b10
`define Zero      2'b11

`define mult      4'b0000
`define multu     4'b0001
`define div       4'b0010
`define divu      4'b0011
`define mfhi      4'b0100
`define mflo      4'b0101
`define mthi      4'b0110
`define mtlo      4'b0111
//--------------------------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module MCU(
    input [5:0] opcode,
    input [5:0] func,

    output [2:0] CU_NPC_op_D,
    output [3:0] CU_ALU_op_D,
    output CU_EXT_op_D,
    output [1:0] CU_DM_op_D,
    output [3:0] CU_MDU_op_D,
    output [1:0] CU_CMP_op_D,

    output CU_EN_RegWrite_D,
    output CU_EN_DMWrite_D,
    output CU_MDU_start_D,

    output CU_is_MDU_opcode_D,

    output [1:0] CU_GRFWriteData_Sel_D,
    output [1:0] CU_GRFWriteAddr_Sel_D,
    output CU_ALUB_Sel_D,

    output [1:0] T_use_rs,
    output [1:0] T_use_rt,
    output [1:0] T_new_D    
    );
//----------------------------------------------------------------------------------------------------
    
    
//instr_wire----------------------------------------------------------------------------------------------------           
    wire add = (opcode == 6'b000000 && func == 6'b100000) ? 1 : 0;
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

    wire _and = (opcode == 6'b000000 && func == 6'b100100) ? 1 : 0;
    wire _or = (opcode == 6'b000000 && func == 6'b100101) ? 1 : 0;
    wire slt = (opcode == 6'b000000 && func == 6'b101010) ? 1 : 0;
    wire sltu = (opcode == 6'b000000 && func == 6'b101011) ? 1 : 0;
    wire addi = (opcode == 6'b001000) ? 1 : 0;
    wire andi = (opcode == 6'b001100) ? 1 : 0;

    wire mult = (opcode == 6'b000000 && func == 6'b011000) ? 1 : 0;
    wire multu = (opcode == 6'b000000 && func == 6'b011001) ? 1 : 0;
    wire div = (opcode == 6'b000000 && func == 6'b011010) ? 1 : 0;
    wire divu = (opcode == 6'b000000 && func == 6'b011011) ? 1 : 0;
    wire mfhi = (opcode == 6'b000000 && func == 6'b010000) ? 1 : 0;
    wire mflo = (opcode == 6'b000000 && func == 6'b010010) ? 1 : 0;
    wire mthi = (opcode == 6'b000000 && func == 6'b010001) ? 1 : 0;
    wire mtlo = (opcode == 6'b000000 && func == 6'b010011) ? 1 : 0;
    
    wire lb = (opcode == 6'b100000) ? 1 : 0;
    wire lh = (opcode == 6'b100001) ? 1 : 0;
    wire sb = (opcode == 6'b101000) ? 1 : 0;
    wire sh = (opcode == 6'b101001) ? 1 : 0;

    wire bne = (opcode == 6'b000101) ? 1 : 0;



    wire CALR = (add | sub | _and | _or | slt | sltu) ? 1 : 0;    
    wire STORE = (sw | sb | sh) ? 1 : 0;
    wire LOAD = (lw | lb | lh) ? 1 : 0;
    wire CALI = (ori | lui | addiu | addi | andi) ? 1 : 0;
    wire BRANCH = (bne | beq) ? 1 : 0;
    wire CALDM = (mult | multu | div | divu) ? 1 : 0;     //j、jal、jr、mfhi、mflo、mthi、mtlo未抽象    
//--------------------------------------------------------------------------------------------------------------


//op_signal------------------------------------------------------------------------------------------------------------
    assign CU_NPC_op_D = (BRANCH) ? `npcBranch :
                         (jal | j) ? `npcJal :
                         (jr) ? `npcJr :
                                `npcPC4;

    assign CU_ALU_op_D = (sub) ? `aluSub :
                         (ori | _or) ? `aluOr :
                         (lui) ? `aluLui :
                         (_and | andi) ? `aluAnd :
                         (slt) ? `aluSlt :
                         (sltu) ? `aluSltu :
                                 `aluAdd;
    
    assign CU_EXT_op_D = (addiu | addi | STORE | LOAD) ? 1 : 0;
    
    assign CU_DM_op_D = (lb | sb) ? `dmByte :
                        (lh | sh) ? `dmHalf :
                                    `dmWord;

    assign CU_MDU_op_D = (mult) ? `mult :
                         (multu) ? `multu :
                         (div) ? `div :
                         (divu) ? `divu :
                         (mfhi) ? `mfhi :
                         (mflo) ? `mflo :
                         (mthi) ? `mthi :
                         (mtlo) ? `mtlo :
                                  4'b1111;

    assign CU_CMP_op_D = (bne) ? 2'b01 :
                                 2'b00;
//---------------------------------------------------------------------------------------------------------------------    
    
    
//en_signal--------------------------------------------------------------------------------------------------------    
    assign CU_EN_RegWrite_D = (jal | mfhi | mflo | CALI | CALR | LOAD) ? 1 : 0;
    
    assign CU_EN_DMWrite_D = (STORE) ? 1 : 0;

    assign CU_MDU_start_D = (CALDM) ? 1 : 0;
//-----------------------------------------------------------------------------------------------------------------


//is_signal--------------------------------------------------------------------------------------------------------------
    assign CU_is_MDU_opcode_D = (CALDM | mfhi | mflo | mthi | mtlo) ? 1 : 0;
//------------------------------------------------------------------------------------------------------------------------


//sel_signal------------------------------------------------------------------------------------------------------
    assign CU_GRFWriteData_Sel_D = (LOAD) ? `DMout :
                                   (jal) ? `PC8 :
                                   (mfhi | mflo) ? `MDUout :
                                           `ALUout;

    assign CU_GRFWriteAddr_Sel_D = (mfhi | mflo | CALR) ? `Rd :
                                   (LOAD | CALI) ? `Rt :
                                   (jal) ? `RA :
                                           `Zero;

    assign CU_ALUB_Sel_D = (STORE | LOAD | CALI) ? 1 : 0;
//-----------------------------------------------------------------------------------------------------------------


//T_signal----------------------------------------------------------------------------------------------------------
    assign T_use_rs = (CALR | CALI | STORE | LOAD | CALDM | mthi | mtlo ) ? 2'b01 :
                      (BRANCH | jr) ? 2'b00 :
                                   2'b11;

    assign T_use_rt = (CALR | CALDM) ? 2'b01 :
                      (BRANCH) ? 2'b00 :
                      (STORE) ? 2'b10 :
                             2'b11;

    assign T_new_D = (CALR | CALI | mfhi | mflo) ? 2'b10 :
                     (LOAD) ? 2'b11 :
                     (jal) ? 2'b01 :
                             2'b00;
//----------------------------------------------------------------------------------------------------------------------
                             
endmodule