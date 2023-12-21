`timescale 1ns / 1ps
//-------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------
module D_GRF (
    input clk,
    input reset,
    input CU_EN_RegWrite,
    input [4:0] RegAddr_rs,
    input [4:0] RegAddr_rt,
    input [4:0] WriteRegAddr,
    input [31:0] WriteData,
    input [31:0] PC,
    output [31:0] D_ReadData_rs,
    output [31:0] D_ReadData_rt
    );
//---------------------------------------------------------------------------------------


//define reg---------------------------------------------------------------------------
    reg [31:0] register_32 [0:31];   //构建32个寄存器�
//-------------------------------------------------------------------------------------


//define int---------------------------------------------------------------------------    
    integer GRF_i;     //专用于GRF的循环变�
//-------------------------------------------------------------------------------------


//Read_D-----------------------------------------------------------------------------------------------------
    assign D_ReadData_rs = (RegAddr_rs == 5'b00000) ? 32'H0000_0000 : 
                           (WriteRegAddr == RegAddr_rs && CU_EN_RegWrite == 1) ? WriteData :
                                                                                 register_32[RegAddr_rs];
    assign D_ReadData_rt = (RegAddr_rt == 5'b00000) ? 32'H0000_0000 : 
                           (WriteRegAddr == RegAddr_rt && CU_EN_RegWrite == 1) ? WriteData :
                                                                                 register_32[RegAddr_rt];
//-------------------------------------------------------------------------------------------------------------


//Write_W---------------------------------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            for (GRF_i = 0; GRF_i < 32; GRF_i = GRF_i + 1) begin
                register_32[GRF_i] = 32'H0000_0000;
            end        
        end 
        else begin
            if (CU_EN_RegWrite) begin
                register_32[WriteRegAddr] <= WriteData;
                $display("%d@%h: $%d <= %h", $time, PC, WriteRegAddr, WriteData); 
            end
        end
    end
//----------------------------------------------------------------------------------------

endmodule