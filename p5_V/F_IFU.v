`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------


//端口定义----------------------------------------------------------------------------
module F_IFU(
    input clk,
    input reset,
    input HCU_EN_IFU,
    input [31:0] NPC,
    output [31:0] F_Instr,
    output reg [31:0] F_PC
    );
//-------------------------------------------------------------------------------------    


//define_reg--------------------------------------------------------------------------
    reg [31:0] IM_memory [0:4095];    //实现ROM 4096 * 32bit
//-------------------------------------------------------------------------------------    


//初始化PC和ROM-------------------------------------------------------------------------
    initial begin
        F_PC = 32'H0000_3000;
        $readmemh("code.txt", IM_memory);
    end
//---------------------------------------------------------------------------------------


//PC-------------------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            F_PC <= 32'H0000_3000;
        end
        else begin
            if (HCU_EN_IFU) begin
                F_PC <= NPC;        
            end
        end
    end
//-----------------------------------------------------------------------------------------
    

//IM-----------------------------------------------------------------------------------------
	wire [31:0] real_PC = F_PC - 32'H0000_3000;
	
    wire [11:0] find_addr = real_PC[13:2];
    
    assign F_Instr = IM_memory[find_addr];
//--------------------------------------------------------------------------------------------


endmodule