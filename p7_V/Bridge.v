`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module Bridge(
    input [31:0] m_data_rdata,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3:0] m_data_byteen,

    input [31:0] temp_m_data_addr,
    input [31:0] temp_m_data_wdata,
    input [3:0] temp_m_data_byteen,    
    output [31:0] temp_m_data_rdata,

    input [31:0] TC0_Dout,
    output [31:0] TC0_Din,
    output [31:0] TC0_Addr,
    output TC0_WE,

    input [31:0] TC1_Dout,
    output [31:0] TC1_Din,
    output [31:0] TC1_Addr,
    output TC1_WE 
    );
//-----------------------------------------------------------------------------------------------------------------------


//bridge------------------------------------------------------------------------------------------------------------------
    wire sel_TC0 = (temp_m_data_addr >= 32'H0000_7F00) & (temp_m_data_addr <= 32'H0000_7F0B);
    wire sel_TC1 = (temp_m_data_addr >= 32'H0000_7F10) & (temp_m_data_addr <= 32'H0000_7F1B);
    wire sel_DM = (temp_m_data_addr >= 32'H0000_0000) & (temp_m_data_addr <= 32'H0000_2FFF);

    assign m_data_wdata = (sel_DM) ? temp_m_data_wdata : 32'H9136_6511;
    assign m_data_addr = temp_m_data_addr;
    assign m_data_byteen = (sel_DM) ? temp_m_data_byteen : 4'b0000;

    assign temp_m_data_rdata = (sel_DM) ? m_data_rdata :
                               (sel_TC0) ? TC0_Dout :
                               (sel_TC1) ? TC1_Dout :
                                           32'H9136_6511;

    assign TC0_Din = (sel_TC0) ? temp_m_data_wdata : 32'H9136_6511;
    assign TC0_Addr = temp_m_data_addr;
    assign TC0_WE = sel_TC0;

    assign TC1_Din = (sel_TC1) ? temp_m_data_wdata : 32'H9136_6511;
    assign TC1_Addr = temp_m_data_addr;
    assign TC1_WE = sel_TC1;
//------------------------------------------------------------------------------------------------------------------------


endmodule