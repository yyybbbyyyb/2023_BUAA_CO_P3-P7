`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module D_E (
    input clk,
    input reset,
    input HCU_EN_DE,
    input HCU_clr_DE,
    input req,
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
    input [2:0] D_CU_GRFWriteData_Sel,
    input [1:0] D_T_new,
    input [3:0] D_CU_MDU_op,
    input D_CU_MDU_start, 
    input D_CU_is_mtc0,
    input D_CU_EN_CP0Write,
    input D_CU_is_mfc0,
    input D_CU_is_eret,
    input [4:0] D_rd,
    input D_CU_is_judge_calOv,
    input D_CU_is_judge_addrOv,
    input D_CU_is_store,
    input D_CU_is_load,  
    input [4:0] D_exc_code,
    input D_is_BD,

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
    output reg [2:0] E_CU_GRFWriteData_Sel,
    output reg [1:0] E_T_new,
    output reg [3:0] E_CU_MDU_op,
    output reg E_CU_MDU_start,
    output reg E_CU_is_mtc0,
    output reg E_CU_EN_CP0Write,
    output reg E_CU_is_mfc0,
    output reg E_CU_is_eret,
    output reg [4:0] E_rd,
    output reg E_CU_is_judge_calOv,
    output reg E_CU_is_judge_addrOv,
    output reg E_CU_is_store,
    output reg E_CU_is_load,
    output reg [4:0] E_exc_code,
    output reg E_is_BD
    );
//-----------------------------------------------------------------------------------------------------------------


//E_reg-------------------------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset | HCU_clr_DE | req) begin
            E_ReadData_rs <= 32'H0000_0000;
            E_ReadData_rt <= 32'H0000_0000;
            E_rt <= 5'b00000;
            E_rs <= 5'b00000;
            E_WriteRegAddr <= 5'b00000;
            E_imm32 <= 32'H0000_0000;
            E_PC <= (req) ? 32'H0000_4180 : 
                    (HCU_clr_DE) ? D_PC :
                                   32'H0000_0000;
            E_CU_ALU_op <= 4'b0000;
            E_CU_DM_op <= 2'b00;
            E_CU_EN_RegWrite <= 1'b0;
            E_CU_EN_DMWrite <= 1'b0;
            E_CU_ALUB_Sel <= 1'b0;
            E_CU_GRFWriteData_Sel <= 3'b000;
            E_T_new <= 2'b00;
            E_CU_MDU_op <= 4'b0000;
            E_CU_MDU_start <= 1'b0; 
            E_CU_is_mtc0 <= 1'b0;
            E_CU_EN_CP0Write <= 1'b0;
            E_CU_is_mfc0 <= 1'b0;
            E_CU_is_eret <= 1'b0;
            E_rd <= 5'b00000;
            E_CU_is_judge_calOv <= 1'b0;
            E_CU_is_judge_addrOv <= 1'b0;
            E_CU_is_store <= 1'b0;
            E_CU_is_load <= 1'b0;
            E_exc_code <= 5'b00000;
            E_is_BD <= (HCU_clr_DE) ? D_is_BD : 1'b0;
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
                E_CU_MDU_op <= D_CU_MDU_op;
                E_CU_MDU_start <= D_CU_MDU_start;  
                E_CU_is_mtc0 <= D_CU_is_mtc0;      
                E_CU_EN_CP0Write <= D_CU_EN_CP0Write;
                E_CU_is_mfc0 <= D_CU_is_mfc0;
                E_CU_is_eret <= D_CU_is_eret;
                E_rd <= D_rd;
                E_CU_is_judge_calOv <= D_CU_is_judge_calOv;
                E_CU_is_judge_addrOv <= D_CU_is_judge_addrOv;
                E_CU_is_store <= D_CU_is_store;
                E_CU_is_load <= D_CU_is_load;
                E_exc_code <= D_exc_code;
                E_is_BD <= D_is_BD;
            end
        end
    end
//--------------------------------------------------------------------------------------------------



endmodule