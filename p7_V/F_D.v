`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module F_D (
    input clk,
    input reset,
    input HCU_EN_FD,
    input HCU_clr_FD,
    input req,
    input [31:0] F_Instr,
    input [31:0] F_PC,
    input [4:0] F_exc_code,
    input F_is_BD,
    output reg [31:0] D_Instr,
    output reg [31:0] D_PC,
    output reg [4:0] D_exc_code,
    output reg D_is_BD
    );
//----------------------------------------------------------------------------------------------------


//D_reg-------------------------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset | HCU_clr_FD | req) begin
            D_Instr <= 32'H0000_0000;
            D_PC <= (req) ? 32'H0000_4180 : 32'H0000_0000;
            D_exc_code <= 5'b00000;
            D_is_BD <= 1'b0;
        end
        else begin
            if (HCU_EN_FD) begin
                D_Instr <= F_Instr;
                D_PC <= F_PC;
                D_exc_code <= F_exc_code;
                D_is_BD <= F_is_BD;
            end
        end
    end
//--------------------------------------------------------------------------------------------------


endmodule