`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module mips(
    input clk,                      // 时钟信号
    input reset,                    // 同步复位信号
    input interrupt,                // 外部中断信号
    output [31:0] macroscopic_pc,   // 宏观 PC

    output [31:0] i_inst_addr,      // IM 读取地址（取�PC�
    input  [31:0] i_inst_rdata,     // IM 读取数据

    output [31:0] m_data_addr,      // DM 读写地址
    input  [31:0] m_data_rdata,     // DM 读取数据
    output [31:0] m_data_wdata,     // DM 待写入数�
    output [3 :0] m_data_byteen,    // DM 字节使能信号

    output [31:0] m_int_addr,       // 中断发生器待写入地址
    output [3 :0] m_int_byteen,     // 中断发生器字节使能信�

    output [31:0] m_inst_addr,      // M �PC

    output w_grf_we,                // GRF 写使能信�
    output [4 :0] w_grf_addr,       // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,      // GRF 待写入数�

    output [31:0] w_inst_addr       // W �PC
    );
//-----------------------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------------------------
//tc0---------------------------------------------------------------------------------------------------------------------
    wire [31:0] TC0_Dout;
    wire TC0_IRQ;
//tc1---------------------------------------------------------------------------------------------------------------------
    wire [31:0] TC1_Dout;
    wire TC1_IRQ;
//CPU--------------------------------------------------------------------------------------------------------------------------
    wire exter_int_response;

    wire [31:0] cpu_m_data_addr;
    wire [31:0] cpu_m_data_wdata;
    wire [3:0] cpu_m_data_byteen;
//bridge-------------------------------------------------------------------------------------------------------------------
    wire TC0_WE;
    wire TC1_WE; 
    wire [31:0] TC0_Din;
    wire [31:0] TC1_Din;
    wire [31:0] TC0_Addr;
    wire [31:0] TC1_Addr;

    wire [31:0] bridge_m_data_rdata;
    wire [31:0] bridge_m_data_addr;
    wire [31:0] bridge_m_data_wdata;
    wire [3:0] bridge_m_data_byteen;
//--------------------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------------------
    wire [5:0] Exter_HW_Int = {3'b000, interrupt, TC1_IRQ, TC0_IRQ};

    assign m_data_addr = bridge_m_data_addr;

    assign m_data_byteen = bridge_m_data_byteen;

    assign m_data_wdata = bridge_m_data_wdata;

    assign m_int_addr = (exter_int_response && interrupt) ? 32'H0000_7F20 : bridge_m_data_addr;
    
    assign m_int_byteen = (exter_int_response && interrupt) ? 1 : bridge_m_data_byteen;
//-------------------------------------------------------------------------------------------------------------------------


//uut---------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------
	TC tc0 (
		.clk(clk), 
		.reset(reset), 
		.Addr(TC0_Addr[31:2]), 
		.WE(TC0_WE), 
		.Din(TC0_Din), 
		.Dout(TC0_Dout), 
		.IRQ(TC0_IRQ)
	);	
//--------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------------------
	TC tc1 (
		.clk(clk), 
		.reset(reset), 
		.Addr(TC1_Addr[31:2]), 
		.WE(TC1_WE), 
		.Din(TC1_Din), 
		.Dout(TC1_Dout), 
		.IRQ(TC1_IRQ)
	);    
//--------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------
	Bridge bridge (
		.m_data_rdata(m_data_rdata), 
		.m_data_addr(bridge_m_data_addr), 
		.m_data_wdata(bridge_m_data_wdata), 
		.m_data_byteen(bridge_m_data_byteen), 
		.temp_m_data_addr(cpu_m_data_addr), 
		.temp_m_data_wdata(cpu_m_data_wdata), 
		.temp_m_data_byteen(cpu_m_data_byteen), 
		.temp_m_data_rdata(bridge_m_data_rdata), 
		.TC0_Dout(TC0_Dout), 
		.TC0_Din(TC0_Din), 
		.TC0_Addr(TC0_Addr), 
		.TC0_WE(TC0_WE), 
		.TC1_Dout(TC1_Dout), 
		.TC1_Din(TC1_Din), 
		.TC1_Addr(TC1_Addr), 
		.TC1_WE(TC1_WE)
	);    
//------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------
    CPU cpu (
		.clk(clk), 
		.reset(reset), 
		.Exter_HW_Int(Exter_HW_Int), 
		.i_inst_rdata(i_inst_rdata), 
		.m_data_rdata(bridge_m_data_rdata), 
		.i_inst_addr(i_inst_addr), 
		.m_data_addr(cpu_m_data_addr), 
		.m_data_wdata(cpu_m_data_wdata), 
		.m_data_byteen(cpu_m_data_byteen), 
		.m_inst_addr(m_inst_addr), 
		.w_grf_we(w_grf_we), 
		.w_grf_addr(w_grf_addr), 
		.w_grf_wdata(w_grf_wdata), 
		.w_inst_addr(w_inst_addr), 
		.Macro_PC(macroscopic_pc),
        .exter_int_response(exter_int_response)
	);
//---------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------
endmodule


