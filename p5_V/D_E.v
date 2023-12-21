`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module D_E (
    input clk,
    input reset,
    input HCU_EN_DE,
    input HCU_clr_DE,
    input [31:0] D_ReadData_rs,
    input [31:0] D_ReadData_rt,
    input [4:0] D_rt,
    input [4:0] D_rs,
    input [4:0] D_WriteRegAddr,
    input [31:0] D_imm32,
    input [31:0] D_PC,
    input [3:0] D_CU_ALU_op,
    input [1:0] D_CU_DM_op,
    input D_CU_EN_RegWrite,
    input D_CU_EN_DMWrite,
    input D_CU_ALUB_Sel,
    input [1:0] D_CU_GRFWriteData_Sel,
    input [1:0] D_T_new,

    output reg [31:0] E_ReadData_rs,
    output reg [31:0] E_ReadData_rt,
    output reg [4:0] E_rt,
    output reg [4:0] E_rs,
    output reg [4:0] E_WriteRegAddr,
    output reg [31:0] E_imm32,
    output reg [31:0] E_PC,
    output reg [3:0] E_CU_ALU_op,
    output reg [1:0] E_CU_DM_op,
    output reg E_CU_EN_RegWrite,
    output reg E_CU_EN_DMWrite,
    output reg E_CU_ALUB_Sel,
    output reg [1:0] E_CU_GRFWriteData_Sel,
    output reg [1:0] E_T_new
    );
//-----------------------------------------------------------------------------------------------------------------


//E_reg-------------------------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset | HCU_clr_DE) begin
            E_ReadData_rs <= 32'H0000_0000;
            E_ReadData_rt <= 32'H0000_0000;
            E_rt <= 5'b00000;
            E_rs <= 5'b00000;
            E_WriteRegAddr <= 5'b00000;
            E_imm32 <= 32'H0000_0000;
            E_PC <= 32'H0000_0000;
            E_CU_ALU_op <= 4'b0000;
            E_CU_DM_op <= 2'b00;
            E_CU_EN_RegWrite <= 1'b0;
            E_CU_EN_DMWrite <= 1'b0;
            E_CU_ALUB_Sel <= 1'b0;
            E_CU_GRFWriteData_Sel <= 2'b00;
            E_T_new <= 2'b00;
        end
        else begin
            if (HCU_EN_DE) begin
                E_ReadData_rs <= D_ReadData_rs;
                E_ReadData_rt <= D_ReadData_rt;
                E_rt <= D_rt;
                E_rs <= D_rs;
                E_WriteRegAddr<= D_WriteRegAddr;
                E_imm32 <= D_imm32;
                E_PC <= D_PC;
                E_CU_ALU_op <= D_CU_ALU_op;
                E_CU_DM_op <= D_CU_DM_op;
                E_CU_EN_RegWrite <= D_CU_EN_RegWrite;
                E_CU_EN_DMWrite <= D_CU_EN_DMWrite;
                E_CU_ALUB_Sel <= D_CU_ALUB_Sel;
                E_CU_GRFWriteData_Sel <= D_CU_GRFWriteData_Sel;
                E_T_new <= (D_T_new - 1 > 0) ? (D_T_new - 1) : 0;
            end
        end
    end
//--------------------------------------------------------------------------------------------------



endmodule