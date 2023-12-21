`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module M_W (
    input clk,
    input reset,
    input HCU_EN_MW,
    input [4:0] M_WriteRegAddr,
    input [31:0] M_ALU_out,
    input [31:0] M_DM_out,
    input [31:0] M_PC,
    input M_CU_EN_RegWrite,
    input [1:0] M_CU_GRFWriteData_Sel,
    input [1:0] M_T_new,
    input [31:0] M_MDU_out,

    output reg [4:0] W_WriteRegAddr,
    output reg [31:0] W_ALU_out,
    output reg [31:0] W_DM_out,
    output reg [31:0] W_PC,
    output reg W_CU_EN_RegWrite,
    output reg [1:0] W_CU_GRFWriteData_Sel,
    output reg [1:0] W_T_new,  
    output reg [31:0] W_MDU_out
);
//----------------------------------------------------------------------------------------------------


//W_reg-------------------------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            W_WriteRegAddr <= 5'b00000;
            W_ALU_out <= 32'H0000_0000;
            W_DM_out <= 32'H0000_0000;
            W_PC <= 32'H0000_0000;
            W_CU_EN_RegWrite <= 1'b0;
            W_CU_GRFWriteData_Sel <= 2'b00;
            W_T_new <= 2'b00;
            W_MDU_out <= 32'H0000_0000;
        end
        else begin
            if (HCU_EN_MW) begin
                W_WriteRegAddr <= M_WriteRegAddr;
                W_ALU_out <= M_ALU_out;
                W_DM_out <=  M_DM_out;
                W_PC <= M_PC;
                W_CU_EN_RegWrite <= M_CU_EN_RegWrite;
                W_CU_GRFWriteData_Sel <= M_CU_GRFWriteData_Sel;
                W_T_new <= (M_T_new - 1 > 0) ? (M_T_new - 1) : 0;     
                W_MDU_out <= M_MDU_out;
            end
        end
    end
//--------------------------------------------------------------------------------------------------


endmodule