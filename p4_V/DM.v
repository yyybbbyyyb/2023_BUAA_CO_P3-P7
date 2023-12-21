`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:18:38 11/02/2023 
// Design Name: 
// Module Name:    DM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define WORD 2'b00
`define BYTE 2'b01
`define HALFWORD 2'b10

module DM(
    input [31:0] addr,             //传入的是32位的地址，可以更好在里面操作
    input [31:0] writeData,
    input clk,
    input MemWrite,
    input rst,
    input [1:0] DMOp,
    output reg [31:0] ReadData
    );

    //定义reg、wire、interger区
    reg [31:0] DM_memory [0:3071];    //实现RAM 3072 * 32bit

    integer DM_i;                     //专门用于DM的循环变量

    wire [11:0] addr_DM;              //具体去RAM里寻址的地址
    wire [1:0] opB;                   //按字节寻址的判断信号
    wire opHw;                        //按半字寻址的判断信号    
    wire [7:0] B1;                    //读出的按字节分割（0-7是B1）
    wire [7:0] B2;
    wire [7:0] B3;
    wire [7:0] B4;
    wire [15:0] Hw1;                  //读出的按半字分割（0-15是Hw1）
    wire [15:0] Hw2;
    wire [7:0] DataB;                  //写入的按字节分割
    wire [15:0] DataHw;                //写入的按半字分割

    //一些组合逻辑
    assign addr_DM = addr[13:2];
    assign opB = addr[1:0];
    assign opHw = addr[1];
    assign B1 = DM_memory[addr_DM][7:0];
    assign B2 = DM_memory[addr_DM][15:8];
    assign B3 = DM_memory[addr_DM][23:16];
    assign B4 = DM_memory[addr_DM][31:24];
    assign Hw1 = DM_memory[addr_DM][15:0];
    assign Hw2 = DM_memory[addr_DM][31:16];
    assign DataB = writeData[7:0];
    assign DataHw = writeData[15:0];

    //读操作（组合逻辑）                                     
    always @(*) begin
        if (DMOp == `WORD) begin
            ReadData = DM_memory[addr_DM];           
        end
        else if (DMOp == `BYTE) begin
            case (opB)
                2'b00:  ReadData = {{24{B1[7]}}, B1};
                2'b01:  ReadData = {{24{B2[7]}}, B2};
                2'b10:  ReadData = {{24{B3[7]}}, B3};
                2'b11:  ReadData = {{24{B4[7]}}, B4};
            endcase
        end
        else if (DMOp == `HALFWORD) begin
            case (opHw)
                0:  ReadData = {{16{Hw1[15]}}, Hw1};
                1:  ReadData = {{16{Hw2[15]}}, Hw2};
            endcase
        end 
    end            

    //写操作（时序逻辑）
    always @(posedge clk) begin
        if (rst) begin
            for (DM_i = 0; DM_i < 3072; DM_i = DM_i + 1) begin
                DM_memory[DM_i] = 32'H0000_0000;
            end            
        end
        else begin
            if (MemWrite) begin                        
                if (DMOp == `WORD) begin
                    DM_memory[addr_DM] <= writeData;
                end            
                else if (DMOp == `BYTE) begin
                    case (opB)
                        2'b00:  DM_memory[addr_DM] <= {B4, B3, B2, DataB};
                        2'b01:  DM_memory[addr_DM] <= {B4, B3, DataB, B1};
                        2'b10:  DM_memory[addr_DM] <= {B4, DataB, B2, B1};
                        2'b11:  DM_memory[addr_DM] <= {DataB, B3, B2, B1};                         
                        default:  DM_memory[addr_DM] <= 32'H0000_0000;  
                    endcase
                end        
                else if (DMOp == `HALFWORD) begin
                    case (opHw)
                        0:  DM_memory[addr_DM] <= {Hw2, DataHw};
                        1:  DM_memory[addr_DM] <= {DataHw, Hw1};
                        default: DM_memory[addr_DM] <= 32'H0000_0000;
                    endcase                    
                end
            end
        end
    end   
     
endmodule
