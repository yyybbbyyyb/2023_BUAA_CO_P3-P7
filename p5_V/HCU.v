`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module HCU(
    input [4:0] D_rs,  
    input [4:0] D_rt, 

    input [4:0] E_WriteRegAddr,
    input [4:0] M_WriteRegAddr,

    input E_CU_EN_RegWrite,  
    input M_CU_EN_RegWrite,      

    input [1:0] T_use_rs,
    input [1:0] T_use_rt,

    input [1:0] E_T_new,
    input [1:0] M_T_new,

    output stall
    );
//------------------------------------------------------------------------------------------------------------------------


//judge_stall--------------------------------------------------------------------------------------------------------------
    wire E_stall_rs = (E_WriteRegAddr == D_rs) & (D_rs != 0) & (T_use_rs < E_T_new) & (E_CU_EN_RegWrite == 1);
    wire E_stall_rt = (E_WriteRegAddr == D_rt) & (D_rt != 0) & (T_use_rt < E_T_new) & (E_CU_EN_RegWrite == 1);
    wire M_stall_rs = (M_WriteRegAddr == D_rs) & (D_rs != 0) & (T_use_rs < M_T_new) & (M_CU_EN_RegWrite == 1);
    wire M_stall_rt = (M_WriteRegAddr == D_rt) & (D_rt != 0) & (T_use_rt < M_T_new) & (M_CU_EN_RegWrite == 1);
//---------------------------------------------------------------------------------------------------------------------------
    

//stall_signal----------------------------------------------------------------------------------------------------------------
    assign stall = E_stall_rs | E_stall_rt | M_stall_rs | M_stall_rt;
//-----------------------------------------------------------------------------------------------------------------------------

endmodule