`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
`define aluAdd    4'b0000
`define aluSub    4'b0001
`define aluOr     4'b0010
`define aluAnd    4'b0011
`define aluLui    4'b0100
`define aluSlt    4'b0101
`define aluSltu   4'b0110
//-------------------------------------------------------------------------------


//端口定义------------------------------------------------------------------------
module E_ALU(
    input [31:0] ALU_a,
    input [31:0] ALU_b,
    input [3:0] CU_ALU_op,
    input judge_calOv,
    input judge_addrOv,

    output [31:0] E_ALU_out,
    output E_is_calOv,
    output E_is_addrOv
    );
//---------------------------------------------------------------------------------	
      


//function-----------------------------------------------------------------------------------
    wire [32:0] unsigned_a = {1'b0, ALU_a};
    wire [32:0] unsigned_b = {1'b0, ALU_b};    

    wire [31:0] sltResult = ($signed(ALU_a) < $signed(ALU_b)) ? 32'H0000_0001 : 32'H0000_0000;
//--------------------------------------------------------------------------------------



//select_area----------------------------------------------------------------------    
    assign E_ALU_out = (CU_ALU_op == `aluAdd) ? ALU_a + ALU_b :           //加运�
                     (CU_ALU_op == `aluSub) ? ALU_a - ALU_b :           //减运�
                     (CU_ALU_op == `aluOr) ? ALU_a | ALU_b :            //或运�
                     (CU_ALU_op == `aluAnd) ? ALU_a & ALU_b :           //和运�
                     (CU_ALU_op == `aluLui) ? {ALU_b[15:0], 16'H0000} : //�6位补0
                     (CU_ALU_op == `aluSlt) ? sltResult :
                     (CU_ALU_op == `aluSltu) ? (unsigned_a < unsigned_b) ? 32'H0000_0001 : 32'H0000_0000 :
                     32'H0000_0000;
//----------------------------------------------------------------------------------


//exc_Ov_handle---------------------------------------------------------------------------
    wire [32:0] ext32_a = {ALU_a[31], ALU_a}; 
    wire [32:0] ext32_b = {ALU_b[31], ALU_b};

    wire [32:0] ext32_add = ext32_a + ext32_b;
    wire [32:0] ext32_sub = ext32_a - ext32_b;
    
    assign E_is_calOv = (judge_calOv) & 
                        ((CU_ALU_op == `aluAdd && ext32_add[32] != ext32_add[31]) ||
                         (CU_ALU_op == `aluSub && ext32_sub[32] != ext32_sub[31]));
    
    assign E_is_addrOv = (judge_addrOv) & 
                        ((CU_ALU_op == `aluAdd && ext32_add[32] != ext32_add[31]) ||
                         (CU_ALU_op == `aluSub && ext32_sub[32] != ext32_sub[31]));

//--------------------------------------------------------------------------------------------
endmodule
