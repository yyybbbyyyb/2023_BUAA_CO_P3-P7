`timescale 1ns / 1ps
//---------------------------------------------------------------------------------------------------------------
`define ALUout    2'b00
`define DMout     2'b01
`define PC8       2'b10

`define Rt        2'b00
`define Rd        2'b01
`define RA        2'b10
`define Zero      2'b11
//---------------------------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module mips(
    input clk,
    input reset
    );
//---------------------------------------------------------------------------------------------------------------




//forward--------------------------------------------------------------------------------------------------------------
//forward_out--------------------------------------------------------------------------------------------------------
	wire [31:0] fwd_sel_E_out;         
	wire [31:0] fwd_sel_M_out;     
	wire [31:0] fwd_sel_W_out;

	assign fwd_sel_E_out = (E_CU_GRFWriteData_Sel == `PC8) ? E_PC + 32'H0000_0008 : 
							                                 32'H9136_6511;

	assign fwd_sel_M_out = (M_CU_GRFWriteData_Sel == `PC8) ? M_PC + 32'H0000_0008 :
						   (M_CU_GRFWriteData_Sel == `ALUout) ? M_ALU_out :
						   										32'H9136_6511;

	assign fwd_sel_W_out = (W_CU_GRFWriteData_Sel == `PC8) ? W_PC + 32'H0000_0008 :
						   (W_CU_GRFWriteData_Sel == `ALUout) ? W_ALU_out :
						   (W_CU_GRFWriteData_Sel == `DMout) ? W_DM_out :
						   										32'H9136_6511;
//---------------------------------------------------------------------------------------------------------------------


//forward_in-----------------------------------------------------------------------------------------------------------
	wire [31:0] fwd_D_ReadData_rs;
	wire [31:0] fwd_D_ReadData_rt;
	wire [31:0] fwd_E_ALU_a;
	wire [31:0] fwd_E_ALU_b;
	wire [31:0] fwd_M_WriteData;

	assign fwd_D_ReadData_rs = (D_rs == 0) ? 32'H0000_0000 :
							   (D_rs == E_WriteRegAddr) ? fwd_sel_E_out :
							   (D_rs == M_WriteRegAddr) ? fwd_sel_M_out :
							   							  D_ReadData_rs;

	assign fwd_D_ReadData_rt = (D_rt == 0) ? 32'H0000_0000 :
							   (D_rt == E_WriteRegAddr) ? fwd_sel_E_out :
							   (D_rt == M_WriteRegAddr) ? fwd_sel_M_out :
							   							  D_ReadData_rt;	

	assign fwd_E_ALU_a = (E_rs == 0) ? 32'H0000_0000 :
						 (E_rs == M_WriteRegAddr) ? fwd_sel_M_out :
						 (E_rs == W_WriteRegAddr) ? fwd_sel_W_out :
						                            E_ReadData_rs;			

	assign fwd_E_ALU_b = (E_rt == 0) ? 32'H0000_0000 :
						 (E_rt == M_WriteRegAddr) ? fwd_sel_M_out :
						 (E_rt == W_WriteRegAddr) ? fwd_sel_W_out :
						                            E_ReadData_rt;	

	assign fwd_M_WriteData = (M_rt == 0) ? 32'H0000_0000 :
							 (M_rt == W_WriteRegAddr) ? fwd_sel_W_out :
							 							M_ReadData_rt;
//------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------




//regular_MUX----------------------------------------------------------------------------------------------------------------
	wire [4:0] D_WriteRegAddr;
	wire [31:0] ALU_b;

	assign D_WriteRegAddr = (CU_GRFWriteAddr_Sel_D == `Rt) ? D_rt :
							(CU_GRFWriteAddr_Sel_D == `Rd) ? D_rd :
							(CU_GRFWriteAddr_Sel_D == `RA) ? 5'b11111 :
															 5'b00000;
							
	assign ALU_b = (E_CU_ALUB_Sel == 1) ? E_imm32 : fwd_E_ALU_b;
//---------------------------------------------------------------------------------------------------------------------------




//stall---------------------------------------------------------------------------------------------------------------------
	wire HCU_EN_IFU = !stall;

    wire HCU_EN_FD = !stall;
    wire HCU_EN_DE = 1;
    wire HCU_EN_EM = 1;
    wire HCU_EN_MW = 1;

    wire HCU_clr_FD = 0;
    wire HCU_clr_DE = stall;
//--------------------------------------------------------------------------------------------------------------------------




//wire(out_signal as the same as its name)---------------------------------------------------------------------------------
//F_IFU---------------------------------------------------------------------------------------------------------------------
	wire [31:0] F_Instr;
	wire [31:0] F_PC;
//F_D---------------------------------------------------------------------------------------------------------------
	wire [31:0] D_Instr;
	wire [31:0] D_PC;
//D_GRF-------------------------------------------------------------------------------------------------------------
    wire [31:0] D_ReadData_rs;
    wire [31:0] D_ReadData_rt;
//D_EXT-----------------------------------------------------------------------------------------------------------------
    wire [31:0] D_imm32;
//D_CMP-----------------------------------------------------------------------------------------------------------------
	wire D_CMP_out;
//D_NPC----------------------------------------------------------------------------------------------------------------
    wire [31:0] NPC;
//D_Splitter------------------------------------------------------------------------------------------------------------
    wire [5:0] D_opcode;
    wire [4:0] D_rs;
    wire [4:0] D_rt;
    wire [4:0] D_rd;
    wire [5:0] D_func;
    wire [15:0] D_imm16;
    wire [25:0] D_imm26;
//D_E-------------------------------------------------------------------------------------------------------------------
    wire [31:0] E_ReadData_rs;
    wire [31:0] E_ReadData_rt;
    wire [4:0] E_rt;
    wire [4:0] E_rs;
    wire [4:0] E_WriteRegAddr;
    wire [31:0] E_imm32;
    wire [31:0] E_PC;
    wire [3:0] E_CU_ALU_op;
    wire [1:0] E_CU_DM_op;
    wire E_CU_EN_RegWrite;
    wire E_CU_EN_DMWrite;
    wire E_CU_ALUB_Sel;
    wire [1:0] E_CU_GRFWriteData_Sel;
    wire [1:0] E_T_new;
//E_ALU---------------------------------------------------------------------------------------------------------------------
    wire [31:0] E_ALU_out;
//E_M------------------------------------------------------------------------------------------------------------------------
    wire [31:0] M_ReadData_rt;
    wire [4:0] M_rt;
    wire [4:0] M_WriteRegAddr;
    wire [31:0] M_ALU_out;
    wire [31:0] M_PC;
    wire [1:0] M_CU_DM_op;
    wire M_CU_EN_RegWrite;
    wire M_CU_EN_DMWrite;
    wire [1:0] M_CU_GRFWriteData_Sel;
    wire [1:0] M_T_new;
//M_DM-----------------------------------------------------------------------------------------------------------------------
    wire [31:0] M_DM_out;
//M_W-------------------------------------------------------------------------------------------------------------------------
    wire [4:0] W_WriteRegAddr;
    wire [31:0] W_ALU_out;
    wire [31:0] W_DM_out;
    wire [31:0] W_PC;
    wire W_CU_EN_RegWrite;
    wire [1:0] W_CU_GRFWriteData_Sel;
    wire [1:0] W_T_new;
//MCU----------------------------------------------------------------------------------------------------------------------------
    wire [2:0] CU_NPC_op_D;
    wire [3:0] CU_ALU_op_D;
    wire CU_EXT_op_D;
    wire [1:0] CU_DM_op_D;
    wire CU_EN_RegWrite_D;
    wire CU_EN_DMWrite_D;
    wire [1:0] CU_GRFWriteData_Sel_D;
    wire [1:0] CU_GRFWriteAddr_Sel_D;
    wire CU_ALUB_Sel_D;
    wire [1:0] T_use_rs;
    wire [1:0] T_use_rt;
    wire [1:0] T_new_D;  
//HCU----------------------------------------------------------------------------------------------------------------------------
    wire stall;
//-------------------------------------------------------------------------------------------------------------------------------




//uut--------------------------------------------------------------------------------------------------------------------
//F_IFU------------------------------------------------------------------------------------------------------------------
	F_IFU f_ifu (
		.clk(clk), 
		.reset(reset), 
		.HCU_EN_IFU(HCU_EN_IFU), 
		.NPC(NPC), 
		.F_Instr(F_Instr), 
		.F_PC(F_PC)
	);
//-----------------------------------------------------------------------------------------------------------------    

//F_D---------------------------------------------------------------------------------------------------------------
	F_D f_d (
		.clk(clk), 
		.reset(reset), 
		.HCU_EN_FD(HCU_EN_FD), 
		.HCU_clr_FD(HCU_clr_FD), 
		.F_Instr(F_Instr), 
		.F_PC(F_PC), 
		.D_Instr(D_Instr), 
		.D_PC(D_PC)
	);
//-------------------------------------------------------------------------------------------------------------------

//D_GRF-------------------------------------------------------------------------------------------------------------
	D_GRF d_grf (
		.clk(clk), 
		.reset(reset), 
		.CU_EN_RegWrite(W_CU_EN_RegWrite), 
		.RegAddr_rs(D_rs), 
		.RegAddr_rt(D_rt), 
		.WriteRegAddr(W_WriteRegAddr), 
		.WriteData(fwd_sel_W_out), 
		.PC(W_PC), 
		.D_ReadData_rs(D_ReadData_rs), 
		.D_ReadData_rt(D_ReadData_rt)
	);
//---------------------------------------------------------------------------------------------------------------------

//D_EXT-----------------------------------------------------------------------------------------------------------------
	D_EXT d_ext (
		.imm16(D_imm16), 
		.CU_EXT_op(CU_EXT_op_D), 
		.D_imm32(D_imm32)
	);
//----------------------------------------------------------------------------------------------------------------------

//D_CMP-----------------------------------------------------------------------------------------------------------------
	D_CMP d_cmp (
		.rs_Data(fwd_D_ReadData_rs), 
		.rt_Data(fwd_D_ReadData_rt), 
		.D_CMP_out(D_CMP_out)
	);
//----------------------------------------------------------------------------------------------------------------------

//D_NPC----------------------------------------------------------------------------------------------------------------
	D_NPC d_npc (
		.F_PC(F_PC), 
		.D_PC(D_PC), 
		.imm26(D_imm26), 
		.ra_Data(fwd_D_ReadData_rs), 
		.CMP_out(D_CMP_out), 
		.CU_NPC_op(CU_NPC_op_D), 
		.NPC(NPC)
	);
//----------------------------------------------------------------------------------------------------------------------

//D_Splitter------------------------------------------------------------------------------------------------------------
	D_Splitter d_splitter (
		.Instr(D_Instr), 
		.D_opcode(D_opcode), 
		.D_rs(D_rs), 
		.D_rt(D_rt), 
		.D_rd(D_rd), 
		.D_func(D_func), 
		.D_imm16(D_imm16), 
		.D_imm26(D_imm26)
	);
//----------------------------------------------------------------------------------------------------------------------

//D_E-------------------------------------------------------------------------------------------------------------------
	D_E d_e (
		.clk(clk), 
		.reset(reset), 
		.HCU_EN_DE(HCU_EN_DE), 
		.HCU_clr_DE(HCU_clr_DE), 
		.D_ReadData_rs(fwd_D_ReadData_rs), 
		.D_ReadData_rt(fwd_D_ReadData_rt), 
		.D_rt(D_rt), 
		.D_rs(D_rs), 
		.D_WriteRegAddr(D_WriteRegAddr), 
		.D_imm32(D_imm32), 
		.D_PC(D_PC), 
		.D_CU_ALU_op(CU_ALU_op_D), 
		.D_CU_DM_op(CU_DM_op_D), 
		.D_CU_EN_RegWrite(CU_EN_RegWrite_D), 
		.D_CU_EN_DMWrite(CU_EN_DMWrite_D), 
		.D_CU_ALUB_Sel(CU_ALUB_Sel_D), 
		.D_CU_GRFWriteData_Sel(CU_GRFWriteData_Sel_D), 
		.D_T_new(T_new_D), 
		.E_ReadData_rs(E_ReadData_rs), 
		.E_ReadData_rt(E_ReadData_rt), 
		.E_rt(E_rt), 
		.E_rs(E_rs), 
		.E_WriteRegAddr(E_WriteRegAddr), 
		.E_imm32(E_imm32), 
		.E_PC(E_PC), 
		.E_CU_ALU_op(E_CU_ALU_op), 
		.E_CU_DM_op(E_CU_DM_op), 
		.E_CU_EN_RegWrite(E_CU_EN_RegWrite), 
		.E_CU_EN_DMWrite(E_CU_EN_DMWrite), 
		.E_CU_ALUB_Sel(E_CU_ALUB_Sel), 
		.E_CU_GRFWriteData_Sel(E_CU_GRFWriteData_Sel), 
		.E_T_new(E_T_new)
	);
//-------------------------------------------------------------------------------------------------------------------------

//E_ALU---------------------------------------------------------------------------------------------------------------------
	E_ALU e_alu (
		.ALU_a(fwd_E_ALU_a), 
		.ALU_b(ALU_b), 
		.CU_ALU_op(E_CU_ALU_op), 
		.E_ALU_out(E_ALU_out)
	);
//---------------------------------------------------------------------------------------------------------------------------

//E_M------------------------------------------------------------------------------------------------------------------------
	E_M e_m (
		.clk(clk), 
		.reset(reset), 
		.HCU_EN_EM(HCU_EN_EM), 
		.E_ReadData_rt(fwd_E_ALU_b), 
		.E_rt(E_rt), 
		.E_WriteRegAddr(E_WriteRegAddr), 
		.E_ALU_out(E_ALU_out), 
		.E_PC(E_PC), 
		.E_CU_DM_op(E_CU_DM_op), 
		.E_CU_EN_RegWrite(E_CU_EN_RegWrite), 
		.E_CU_EN_DMWrite(E_CU_EN_DMWrite), 
		.E_CU_GRFWriteData_Sel(E_CU_GRFWriteData_Sel), 
		.E_T_new(E_T_new), 
		.M_ReadData_rt(M_ReadData_rt), 
		.M_rt(M_rt), 
		.M_WriteRegAddr(M_WriteRegAddr), 
		.M_ALU_out(M_ALU_out), 
		.M_PC(M_PC), 
		.M_CU_DM_op(M_CU_DM_op), 
		.M_CU_EN_RegWrite(M_CU_EN_RegWrite), 
		.M_CU_EN_DMWrite(M_CU_EN_DMWrite), 
		.M_CU_GRFWriteData_Sel(M_CU_GRFWriteData_Sel), 
		.M_T_new(M_T_new)
	);
//----------------------------------------------------------------------------------------------------------------------------

//M_DM-----------------------------------------------------------------------------------------------------------------------
	M_DM m_dm (
		.clk(clk), 
		.reset(reset), 
		.CU_EN_DMWrite(M_CU_EN_DMWrite), 
		.addr(M_ALU_out), 
		.writeData(fwd_M_WriteData), 
		.CU_DM_op(M_CU_DM_op), 
		.PC(M_PC), 
		.M_DM_out(M_DM_out)
	);
//-----------------------------------------------------------------------------------------------------------------------------

//M_W-------------------------------------------------------------------------------------------------------------------------
	M_W m_w (
		.clk(clk), 
		.reset(reset), 
		.HCU_EN_MW(HCU_EN_MW), 
		.M_WriteRegAddr(M_WriteRegAddr), 
		.M_ALU_out(M_ALU_out), 
		.M_DM_out(M_DM_out), 
		.M_PC(M_PC), 
		.M_CU_EN_RegWrite(M_CU_EN_RegWrite), 
		.M_CU_GRFWriteData_Sel(M_CU_GRFWriteData_Sel), 
		.M_T_new(M_T_new), 
		.W_WriteRegAddr(W_WriteRegAddr), 
		.W_ALU_out(W_ALU_out), 
		.W_DM_out(W_DM_out), 
		.W_PC(W_PC), 
		.W_CU_EN_RegWrite(W_CU_EN_RegWrite), 
		.W_CU_GRFWriteData_Sel(W_CU_GRFWriteData_Sel), 
		.W_T_new(W_T_new)
	);
//--------------------------------------------------------------------------------------------------------------------------------

//MCU----------------------------------------------------------------------------------------------------------------------------
	MCU mcu (
		.opcode(D_opcode), 
		.func(D_func), 
		.CU_NPC_op_D(CU_NPC_op_D), 
		.CU_ALU_op_D(CU_ALU_op_D), 
		.CU_EXT_op_D(CU_EXT_op_D), 
		.CU_DM_op_D(CU_DM_op_D), 
		.CU_EN_RegWrite_D(CU_EN_RegWrite_D), 
		.CU_EN_DMWrite_D(CU_EN_DMWrite_D), 
		.CU_GRFWriteData_Sel_D(CU_GRFWriteData_Sel_D), 
		.CU_GRFWriteAddr_Sel_D(CU_GRFWriteAddr_Sel_D), 
		.CU_ALUB_Sel_D(CU_ALUB_Sel_D), 
		.T_use_rs(T_use_rs), 
		.T_use_rt(T_use_rt), 
		.T_new_D(T_new_D)
	);
//-------------------------------------------------------------------------------------------------------------------------------

//HCU----------------------------------------------------------------------------------------------------------------------------
	HCU hcu (
		.D_rs(D_rs), 
		.D_rt(D_rt), 
		.E_WriteRegAddr(E_WriteRegAddr), 
		.M_WriteRegAddr(M_WriteRegAddr), 
		.E_CU_EN_RegWrite(E_CU_EN_RegWrite), 
		.M_CU_EN_RegWrite(M_CU_EN_RegWrite), 
		.T_use_rs(T_use_rs), 
		.T_use_rt(T_use_rt), 
		.E_T_new(E_T_new), 
		.M_T_new(M_T_new), 
		.stall(stall)
	);
//------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------

endmodule