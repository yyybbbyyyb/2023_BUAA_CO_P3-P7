`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module D_CMP (
    input [31:0] rs_Data,
    input [31:0] rt_Data,
    output D_CMP_out
    );
//--------------------------------------------------------------------------------------------------------------    


//----------------------------------------------------------------------------------------------------------------
    assign D_CMP_out = (rs_Data == rt_Data);
//---------------------------------------------------------------------------------------------------------------

endmodule