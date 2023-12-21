`timescale 1ns / 1ps
//---------------------------------------------------------------------------------------------------------------------
`define dmWord    2'b00
`define dmByte    2'b01
`define dmHalf    2'b10
//--------------------------------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------------
module M_DMIN (
    input CU_EN_DMWrite,
    input [31:0] addr,            
    input [31:0] writeData,
    input [1:0] CU_DM_op,
    output reg [31:0] M_DMIN_out, 
    output reg [3:0] M_DMIN_byte_en
    );
//---------------------------------------------------------------------------------------------------------------------------------


//define wire---------------------------------------------------------------------------------------------------------------------------
    wire [1:0] opB = addr[1:0];                         
    wire opHw = addr[1];    

    wire [7:0] DataB = writeData[7:0];                         
    wire [15:0] DataHw = writeData[15:0];                        
//------------------------------------------------------------------------------------------------------------------------------------


//write-------------------------------------------------------------------------------------------------------------------------------
    always @(*) begin
        if (CU_EN_DMWrite) begin                        
            if (CU_DM_op == `dmWord) begin
                M_DMIN_out = writeData;
                M_DMIN_byte_en = 4'b1111;
            end            
            else if (CU_DM_op == `dmByte) begin
                case (opB)
                    2'b00:  begin
                        M_DMIN_out = {{24{1'b0}}, DataB};
                        M_DMIN_byte_en = 4'b0001;
                    end
                    2'b01:  begin 
                        M_DMIN_out = {{16{1'b0}}, DataB, {8{1'b0}}};
                        M_DMIN_byte_en = 4'b0010;
                    end
                    2'b10:  begin
                        M_DMIN_out = {{8{1'b0}}, DataB, {16{1'b0}}};
                        M_DMIN_byte_en = 4'b0100;                    
                    end
                    2'b11:  begin
                        M_DMIN_out = {DataB, {24{1'b0}}};
                        M_DMIN_byte_en = 4'b1000;                           
                    end
                endcase
            end        
            else if (CU_DM_op == `dmHalf) begin
                case (opHw)
                    0:  begin
                        M_DMIN_out = {{16{1'b0}}, DataHw};
                        M_DMIN_byte_en = 4'b0011;
                    end
                    1:  begin
                        M_DMIN_out = {DataHw, {16{1'b0}}};
                        M_DMIN_byte_en = 4'b1100;
                    end
                endcase                    
            end					 
        end
        else begin
            M_DMIN_out = 32'H9136_6511;
            M_DMIN_byte_en = 4'b0000;
        end
    end
//---------------------------------------------------------------------------------------------------------------------------------------

endmodule