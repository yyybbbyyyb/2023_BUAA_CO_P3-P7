`timescale 1ns / 1ps
//---------------------------------------------------------------------------------------------------------------------
`define dmWord    2'b00
`define dmByte    2'b01
`define dmHalf    2'b10
//--------------------------------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------------
module M_DM (
    input clk,
    input reset,
    input CU_EN_DMWrite,
    input [31:0] addr,            
    input [31:0] writeData,
    input [1:0] CU_DM_op,
    input [31:0] PC,
    output reg [31:0] M_DM_out
    );
    

//define reg------------------------------------------------------------------------------------------------------------
    reg [31:0] DM_memory [0:3071];    //实现RAM 3072 * 32bit
//-----------------------------------------------------------------------------------------------------------------------


//define int--------------------------------------------------------------------------------------------------------------
    integer DM_i;                     //专门用于DM的循环变�
//-------------------------------------------------------------------------------------------------------------------------


//define wire---------------------------------------------------------------------------------------------------------------------------
    wire [11:0] addr_DM = addr[13:2];                            //具体去RAM里寻址的地址
    wire [1:0] opB = addr[1:0];                                //按字节寻址的判断信�
    wire opHw = addr[1];                                          //按半字寻址的判断信� 
    wire [7:0] B1 = DM_memory[addr_DM][7:0];                     //读出的按字节分割�是B1�
    wire [7:0] B2 = DM_memory[addr_DM][15:8];
    wire [7:0] B3 = DM_memory[addr_DM][23:16];
    wire [7:0] B4 = DM_memory[addr_DM][31:24];
    wire [15:0] Hw1 = DM_memory[addr_DM][15:0];                  //读出的按半字分割�5是Hw1�
    wire [15:0] Hw2 = DM_memory[addr_DM][31:16];
    wire [7:0] DataB = writeData[7:0];                           //写入的按字节分割
    wire [15:0] DataHw = writeData[15:0];                        //写入的按半字分割
    reg [31:0] final_writeData;                                 //最终写入的数据
//------------------------------------------------------------------------------------------------------------------------------------
  
  
//read-----------------------------------------------------------------------------------------------------------------------------------                                    
    always @(*) begin
        if (CU_DM_op == `dmWord) begin
            M_DM_out = DM_memory[addr_DM];           
        end
        else if (CU_DM_op == `dmByte) begin
            case (opB)
                2'b00:  M_DM_out = {{24{B1[7]}}, B1};
                2'b01:  M_DM_out = {{24{B2[7]}}, B2};
                2'b10:  M_DM_out = {{24{B3[7]}}, B3};
                2'b11:  M_DM_out = {{24{B4[7]}}, B4};
            endcase
        end
        else if (CU_DM_op == `dmHalf) begin
            case (opHw)
                0:  M_DM_out = {{16{Hw1[15]}}, Hw1};
                1:  M_DM_out = {{16{Hw2[15]}}, Hw2};
            endcase
        end 
    end            
//-------------------------------------------------------------------------------------------------------------------------------


//write-------------------------------------------------------------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            for (DM_i = 0; DM_i < 3072; DM_i = DM_i + 1) begin
                DM_memory[DM_i] = 32'H0000_0000;
            end            
        end
        else begin
            if (CU_EN_DMWrite) begin                        
                if (CU_DM_op == `dmWord) begin
                    final_writeData = writeData;
                end            
                else if (CU_DM_op == `dmByte) begin
                    case (opB)
                        2'b00:  final_writeData = {B4, B3, B2, DataB};
                        2'b01:  final_writeData = {B4, B3, DataB, B1};
                        2'b10:  final_writeData = {B4, DataB, B2, B1};
                        2'b11:  final_writeData = {DataB, B3, B2, B1};                           
                    endcase
                end        
                else if (CU_DM_op == `dmHalf) begin
                    case (opHw)
                        0:  final_writeData = {Hw2, DataHw};
                        1:  final_writeData = {DataHw, Hw1};
                    endcase                    
                end
					DM_memory[addr_DM] <= final_writeData;
					$display("%d@%h: *%h <= %h", $time, PC, addr, final_writeData); 					 
            end

        end
    end   
//---------------------------------------------------------------------------------------------------------------------------------------

endmodule