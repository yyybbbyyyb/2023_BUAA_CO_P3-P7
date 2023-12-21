`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
`define mult      4'b0000
`define multu     4'b0001
`define div       4'b0010
`define divu      4'b0011
`define mfhi      4'b0100
`define mflo      4'b0101
`define mthi      4'b0110
`define mtlo      4'b0111
//-------------------------------------------------------------------------------


//端口定义------------------------------------------------------------------------
module E_MDU(
    input clk,
    input reset,
    input start,
    input [3:0] CU_MDU_op,
    input [31:0] MDU_a,
    input [31:0] MDU_b,
    output reg E_MDU_busy,
    output [31:0] E_MDU_out
    );
//----------------------------------------------------------------------------------


//HI_Reg and LO_Reg------------------------------------------------------------------
    reg [31:0] HI;
    reg [31:0] LO;

    reg [63:0] temp_HI;
    reg [31:0] temp_LO;
        
    reg [4:0] count;
//-----------------------------------------------------------------------------------


//read------------------------------------------------------------------------------
    assign E_MDU_out = (CU_MDU_op == `mfhi) ? HI :
                       (CU_MDU_op == `mflo) ? LO :
                                              32'H9136_6511;
//----------------------------------------------------------------------------------


//MDU-------------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            HI <= 32'H0000_0000;
            LO <= 32'H0000_0000;            
            count <= 0;
            E_MDU_busy <= 0;
        end
        else begin
            if (start) begin
                if (CU_MDU_op == `mult) begin
                    E_MDU_busy <= 1;
                    count <= 5;
                    {temp_HI, temp_LO} <= $signed(MDU_a) * $signed(MDU_b);                
                end
                else if (CU_MDU_op == `multu) begin
                    E_MDU_busy <= 1;
                    count <= 5;
                    {temp_HI, temp_LO} <= MDU_a * MDU_b;                      
                end
                else if (CU_MDU_op == `div) begin
                    E_MDU_busy <= 1;
                    count <= 10;
                    temp_LO <= $signed(MDU_a) / $signed(MDU_b);
                    temp_HI <= $signed(MDU_a) % $signed(MDU_b);                     
                end              
                else if (CU_MDU_op == `divu) begin
                    E_MDU_busy <= 1;
                    count <= 10;
                    temp_LO <= MDU_a / MDU_b;
                    temp_HI <= MDU_a % MDU_b;                     
                end
            end
            else if (CU_MDU_op == `mthi) begin
                HI <= MDU_a;
            end 
            else if (CU_MDU_op == `mtlo) begin
                LO <= MDU_a;        
            end
            else if (count == 1) begin
                E_MDU_busy <= 0;
                count <= 0;
                HI <= temp_HI;
                LO <= temp_LO;
            end
            else if (count > 0)begin
                count <= count - 1;
            end
        end
    end
//-----------------------------------------------------------------------------------------------


endmodule