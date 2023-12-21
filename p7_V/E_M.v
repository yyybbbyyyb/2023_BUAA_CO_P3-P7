`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module E_M (
    input clk,
    input reset,
    input HCU_EN_EM,
    input req,
    input [31:0] E_ReadData_rt,
    input [4:0] E_rt,
    input [4:0] E_WriteRegAddr,
    input [31:0] E_ALU_out,
    input [31:0] E_PC,
    input [1:0] E_CU_DM_op,
    input E_CU_EN_RegWrite,
    input E_CU_EN_DMWrite,
    input [2:0] E_CU_GRFWriteData_Sel,
    input [1:0] E_T_new,
    input [31:0] E_MDU_out,
    input E_CU_is_mtc0,
    input E_CU_EN_CP0Write,
    input E_CU_is_mfc0,
    input E_CU_is_eret,
    input [4:0] E_rd,
    input E_exc_addrOv,
    input E_CU_is_store,
    input E_CU_is_load,
    input [4:0] E_exc_code,
    input E_is_BD,

    output reg [31:0] M_ReadData_rt,
    output reg [4:0] M_rt,
    output reg [4:0] M_WriteRegAddr,
    output reg [31:0] M_ALU_out,
    output reg [31:0] M_PC,
    output reg [1:0] M_CU_DM_op,
    output reg M_CU_EN_RegWrite,
    output reg M_CU_EN_DMWrite,
    output reg [2:0] M_CU_GRFWriteData_Sel,
    output reg [1:0] M_T_new,
    output reg [31:0] M_MDU_out,
    output reg M_CU_is_mtc0,
    output reg M_CU_EN_CP0Write,
    output reg M_CU_is_mfc0,
    output reg M_CU_is_eret,
    output reg [4:0] M_rd,
    output reg M_exc_addrOv,
    output reg M_CU_is_store,
    output reg M_CU_is_load,
    output reg [4:0] M_exc_code,
    output reg M_is_BD
    );
//----------------------------------------------------------------------------------------------------
    

//M_reg-------------------------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset | req) begin
            M_ReadData_rt <= 32'H0000_0000;
            M_rt <= 5'b00000;
            M_WriteRegAddr <= 5'b00000;
            M_ALU_out <= 32'H0000_0000;
            M_PC <= (req) ? 32'H0000_4180 : 32'H0000_0000;
            M_CU_DM_op <= 2'b00;
            M_CU_EN_RegWrite <= 1'b0;
            M_CU_EN_DMWrite <= 1'b0;
            M_CU_GRFWriteData_Sel <= 3'b000;
            M_T_new <= 2'b00;
            M_MDU_out <= 32'H0000_0000;
            M_CU_is_mtc0 <= 1'b0;
            M_CU_EN_CP0Write <= 1'b0;
            M_CU_is_mfc0 <= 1'b0;
            M_CU_is_eret <= 1'b0;
            M_rd <= 5'b00000;
            M_exc_addrOv <= 1'b0;
            M_CU_is_store <= 1'b0;
            M_CU_is_load <= 1'b0;
            M_exc_code <= 5'b00000;
            M_is_BD <= 1'b0;
        end
        else begin
            if (HCU_EN_EM) begin
                M_ReadData_rt <= E_ReadData_rt;
                M_rt <= E_rt;
                M_WriteRegAddr <= E_WriteRegAddr;
                M_ALU_out <= E_ALU_out;
                M_PC <= E_PC;
                M_CU_DM_op <= E_CU_DM_op;
                M_CU_EN_RegWrite <= E_CU_EN_RegWrite;
                M_CU_EN_DMWrite <= E_CU_EN_DMWrite;
                M_CU_GRFWriteData_Sel <= E_CU_GRFWriteData_Sel;
                M_T_new <= (E_T_new - 1 > 0) ? (E_T_new - 1) : 0;                
                M_MDU_out <= E_MDU_out;
                M_CU_is_mtc0 <= E_CU_is_mtc0;
                M_CU_EN_CP0Write <= E_CU_EN_CP0Write;
                M_CU_is_mfc0 <= E_CU_is_mfc0;
                M_CU_is_eret <= E_CU_is_eret;
                M_rd <= E_rd;
                M_exc_addrOv <= E_exc_addrOv;
                M_CU_is_store <= E_CU_is_store;
                M_CU_is_load <= E_CU_is_load;
                M_exc_code <= E_exc_code;
                M_is_BD <= E_is_BD;
            end
        end
    end
//--------------------------------------------------------------------------------------------------


endmodule