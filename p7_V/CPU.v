`timescale 1ns / 1ps
//---------------------------------------------------------------------------------------------------------------
`define ALUout    3'b000
`define DMout     3'b001
`define PC8       3'b010
`define MDUout    3'b011
`define CP0out    3'b100

`define Rt        2'b00
`define Rd        2'b01
`define RA        2'b10
`define Zero      2'b11

`define EXC_NULL        5'b00000
`define EXC_AdEL        5'b00100
`define EXC_AdES		5'b00101
`define EXC_Syscall 	5'b01000
`define EXC_RI   		5'b01010
`define EXC_Ov  		5'b01100
//---------------------------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module CPU(
    input clk,
    input reset,
	input [5:0] Exter_HW_Int, 
	input [31:0] i_inst_rdata,
    input [31:0] m_data_rdata,
    
	output [31:0] i_inst_addr,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3 :0] m_data_byteen,
    output [31:0] m_inst_addr,
    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr,
	output [31:0] Macro_PC,
	output exter_int_response
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
						   (M_CU_GRFWriteData_Sel == `MDUout) ? M_MDU_out :
						   										32'H9136_6511;

	assign fwd_sel_W_out = (W_CU_GRFWriteData_Sel == `PC8) ? W_PC + 32'H0000_0008 :
						   (W_CU_GRFWriteData_Sel == `ALUout) ? W_ALU_out :
						   (W_CU_GRFWriteData_Sel == `DMout) ? W_DM_out :
						   (W_CU_GRFWriteData_Sel == `MDUout) ? W_MDU_out :
						   (W_CU_GRFWriteData_Sel == `CP0out) ? W_CP0_out :
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
	wire [4:0] CP0_readAddr;
	wire [4:0] CP0_writeAddr;

	assign D_WriteRegAddr = (CU_GRFWriteAddr_Sel_D == `Rt) ? D_rt :
							(CU_GRFWriteAddr_Sel_D == `Rd) ? D_rd :
							(CU_GRFWriteAddr_Sel_D == `RA) ? 5'b11111 :
															 5'b00000;
							
	assign ALU_b = (E_CU_ALUB_Sel == 1) ? E_imm32 : fwd_E_ALU_b;

	assign CP0_readAddr = (M_CU_is_mfc0 == 1) ? M_rd : 5'b00000; 

	assign CP0_writeAddr = (M_CU_is_mtc0 == 1) ? M_rd : 5'b00000;
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
	wire [31:0] F_PC;
//F_D---------------------------------------------------------------------------------------------------------------
	wire [31:0] D_Instr;
	wire [31:0] D_PC;
	wire [4:0] D_exc_code;
	wire D_is_BD;
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
    wire [2:0] E_CU_GRFWriteData_Sel;
    wire [1:0] E_T_new;
	wire [3:0] E_CU_MDU_op;
	wire E_CU_MDU_start;
	wire E_CU_is_mtc0;
	wire E_CU_EN_CP0Write;
	wire E_CU_is_mfc0;
	wire E_CU_is_eret;
    wire [4:0] E_rd;
	wire E_CU_is_judge_calOv;
    wire E_CU_is_judge_addrOv;
	wire E_CU_is_store;
    wire E_CU_is_load;
	wire [4:0] E_exc_code;
	wire E_is_BD;
//E_ALU---------------------------------------------------------------------------------------------------------------------
    wire [31:0] E_ALU_out;
	wire E_is_calOv;
    wire E_is_addrOv;
//E_MDU-----------------------------------------------------------------------------------------------------------------------
	wire E_MDU_busy;
	wire [31:0] E_MDU_out;
//E_M------------------------------------------------------------------------------------------------------------------------
    wire [31:0] M_ReadData_rt;
    wire [4:0] M_rt;
    wire [4:0] M_WriteRegAddr;
    wire [31:0] M_ALU_out;
    wire [31:0] M_PC;
    wire [1:0] M_CU_DM_op;
    wire M_CU_EN_RegWrite;
    wire M_CU_EN_DMWrite;
    wire [2:0] M_CU_GRFWriteData_Sel;
    wire [1:0] M_T_new;
	wire [31:0] M_MDU_out;
	wire M_CU_is_mtc0;
	wire M_CU_EN_CP0Write;
	wire M_CU_is_mfc0;
	wire M_CU_is_eret;
    wire [4:0] M_rd;
	wire M_exc_addrOv;
	wire M_CU_is_store;
    wire M_CU_is_load;
	wire [4:0] M_exc_code;
	wire M_is_BD;
//M_DMIN-----------------------------------------------------------------------------------------------------------------------
    wire [31:0] M_DMIN_out;
	wire [3:0] M_DMIN_byte_en;
	wire M_is_AdES;
//M_DMOUT------------------------------------------------------------------------------------------------------------------------
	wire [31:0] M_DM_out;
	wire M_is_AdEL;
//M_W-------------------------------------------------------------------------------------------------------------------------
    wire [4:0] W_WriteRegAddr;
    wire [31:0] W_ALU_out;
    wire [31:0] W_DM_out;
    wire [31:0] W_PC;
    wire W_CU_EN_RegWrite;
    wire [2:0] W_CU_GRFWriteData_Sel;
    wire [1:0] W_T_new;
	wire [31:0] W_MDU_out;
	wire [31:0] W_CP0_out;
//MCU----------------------------------------------------------------------------------------------------------------------------
    wire [2:0] CU_NPC_op_D;
    wire [3:0] CU_ALU_op_D;
    wire CU_EXT_op_D;
    wire [1:0] CU_DM_op_D;
	wire [3:0] CU_MDU_op_D;
	wire [1:0] CU_CMP_op_D;
    wire CU_EN_RegWrite_D;
    wire CU_EN_DMWrite_D;
	wire CU_MDU_start_D;
    wire CU_EN_CP0Write_D;
	wire CU_is_MDU_opcode_D;
	wire CU_is_eret_D;
    wire CU_is_mtc0_D;
	wire CU_is_mfc0_D;
	wire CU_is_judge_calOv_D;
    wire CU_is_judge_addrOv_D;
	wire CU_is_store_D;
    wire CU_is_load_D;
	wire CU_is_beforeBD_D;
    wire [2:0] CU_GRFWriteData_Sel_D;
    wire [1:0] CU_GRFWriteAddr_Sel_D;
    wire CU_ALUB_Sel_D;
    wire [1:0] T_use_rs;
    wire [1:0] T_use_rt;
    wire [1:0] T_new_D;  
	wire CU_exc_RI_D; 
	wire CU_exc_Syscall_D;
//HCU----------------------------------------------------------------------------------------------------------------------------
    wire stall;
//CP0----------------------------------------------------------------------------------------------------------------------------
    wire CP0_req;                   
	wire [31:0] CP0_EPC_out;         
	wire [31:0] CP0_Data_out;
	wire response;
//-------------------------------------------------------------------------------------------------------------------------------


//exc_handle------------------------------------------------------------------------------------------------------------------
	wire F_exc_AdEL;
	wire D_exc_RI;
	wire D_exc_Syscall;
	wire E_exc_Ov;
	wire E_exc_addrOv;
	wire M_exc_AdES;
	wire M_exc_AdEL;

	wire [4:0] F_exc_code = (F_exc_AdEL) ? `EXC_AdEL : `EXC_NULL;

	wire [4:0] D_new_exc_code = (|D_exc_code) ? D_exc_code :
								(D_exc_RI) ? `EXC_RI :
								(D_exc_Syscall) ? `EXC_Syscall :
												  `EXC_NULL;

	wire [4:0] E_new_exc_code = (|E_exc_code) ? E_exc_code :
								(E_exc_Ov) ? `EXC_Ov :
											 `EXC_NULL;

	wire [4:0] M_new_exc_code = (|M_exc_code) ? M_exc_code :
								(M_exc_AdES) ? `EXC_AdES :
								(M_exc_AdEL) ? `EXC_AdEL :
											   `EXC_NULL;
//-----------------------------------------------------------------------------------------------------------------------------


//uut---------------------------------------------------------------------------------------------------------------------------
//F_IFU-------------------------------------------------------------------------------------------------------------------------
	F_IFU f_ifu (
		.clk(clk), 
		.reset(reset), 
		.req(CP0_req),
		.HCU_EN_IFU(HCU_EN_IFU), 
		.NPC(NPC), 
		.F_PC(F_PC)
	);
//------------------------------------------------------------------------------------------------------------------------------    

//F_exc_handle----------------------------------------------------------------------------------------------------------------
	wire [31:0] real_F_PC = (CU_is_eret_D) ? CP0_EPC_out : F_PC;            
	
	assign F_exc_AdEL = ((|real_F_PC[1:0]) | (real_F_PC < 32'H0000_3000) | (real_F_PC > 32'H0000_6FFF)) & (!CU_is_eret_D);

	wire [31:0] real_F_Instr = (F_exc_AdEL) ? 32'H0000_0000 : i_inst_rdata;

	wire F_is_BD = (CU_is_beforeBD_D) ? 1 : 0;
//-----------------------------------------------------------------------------------------------------------------------------

	assign i_inst_addr = real_F_PC;

//F_D--------------------------------------------------------------------------------------------------------------------------
	F_D f_d (
		.clk(clk), 
		.reset(reset), 
		.HCU_EN_FD(HCU_EN_FD), 
		.HCU_clr_FD(HCU_clr_FD), 
		.req(CP0_req),
		.F_Instr(real_F_Instr), 
		.F_PC(real_F_PC), 
		.F_exc_code(F_exc_code),
		.F_is_BD(F_is_BD),
		.D_Instr(D_Instr), 
		.D_PC(D_PC),
		.D_exc_code(D_exc_code),
		.D_is_BD(D_is_BD)
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
		.D_ReadData_rs(D_ReadData_rs), 
		.D_ReadData_rt(D_ReadData_rt)
	);
//---------------------------------------------------------------------------------------------------------------------

    assign w_grf_we = W_CU_EN_RegWrite;
    assign w_grf_addr = W_WriteRegAddr;
    assign w_grf_wdata = fwd_sel_W_out;
    assign w_inst_addr = W_PC;
	
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
		.CU_CMP_op(CU_CMP_op_D),
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
		.req(CP0_req),
		.EPC(CP0_EPC_out),
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

//D_exc_handle----------------------------------------------------------------------------------------------------------
	assign D_exc_RI = CU_exc_RI_D; 

	assign D_exc_Syscall = CU_exc_Syscall_D;
//-----------------------------------------------------------------------------------------------------------------------

//D_E-------------------------------------------------------------------------------------------------------------------
	D_E d_e (
		.clk(clk), 
		.reset(reset), 
		.HCU_EN_DE(HCU_EN_DE), 
		.HCU_clr_DE(HCU_clr_DE), 
		.req(CP0_req),
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
		.D_CU_MDU_op(CU_MDU_op_D),
		.D_CU_MDU_start(CU_MDU_start_D),
		.D_CU_is_mtc0(CU_is_mtc0_D),
		.D_CU_EN_CP0Write(CU_EN_CP0Write_D),
		.D_CU_is_mfc0(CU_is_mfc0_D),
		.D_CU_is_eret(CU_is_eret_D),
    	.D_rd(D_rd),
		.D_CU_is_judge_calOv(CU_is_judge_calOv_D),
    	.D_CU_is_judge_addrOv(CU_is_judge_addrOv_D),
		.D_CU_is_store(CU_is_store_D),
    	.D_CU_is_load(CU_is_load_D),
		.D_exc_code(D_new_exc_code),
		.D_is_BD(D_is_BD),
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
		.E_T_new(E_T_new),
		.E_CU_MDU_op(E_CU_MDU_op),
		.E_CU_MDU_start(E_CU_MDU_start),
		.E_CU_is_mtc0(E_CU_is_mtc0),
		.E_CU_EN_CP0Write(E_CU_EN_CP0Write),
		.E_CU_is_mfc0(E_CU_is_mfc0),
		.E_CU_is_eret(E_CU_is_eret),
    	.E_rd(E_rd),
		.E_CU_is_judge_calOv(E_CU_is_judge_calOv),
    	.E_CU_is_judge_addrOv(E_CU_is_judge_addrOv),
		.E_CU_is_store(E_CU_is_store),
    	.E_CU_is_load(E_CU_is_load),
		.E_exc_code(E_exc_code),
		.E_is_BD(E_is_BD)
	);
//-------------------------------------------------------------------------------------------------------------------------

//E_ALU---------------------------------------------------------------------------------------------------------------------
	E_ALU e_alu (
		.ALU_a(fwd_E_ALU_a), 
		.ALU_b(ALU_b), 
		.CU_ALU_op(E_CU_ALU_op), 
		.judge_calOv(E_CU_is_judge_calOv),
    	.judge_addrOv(E_CU_is_judge_addrOv),
		.E_ALU_out(E_ALU_out),
		.E_is_calOv(E_is_calOv),
    	.E_is_addrOv(E_is_addrOv)
	);
//---------------------------------------------------------------------------------------------------------------------------

//E_exc_handle----------------------------------------------------------------------------------------------------------
	assign E_exc_Ov = E_is_calOv;

	assign E_exc_addrOv = E_is_addrOv; 
//-----------------------------------------------------------------------------------------------------------------------

//E_MDU---------------------------------------------------------------------------------------------------------------------
	E_MDU e_mdu (
    	.clk(clk),
    	.reset(reset),
    	.start(E_CU_MDU_start),
		.req(CP0_req),
    	.CU_MDU_op(E_CU_MDU_op),
    	.MDU_a(fwd_E_ALU_a),
    	.MDU_b(ALU_b),
    	.E_MDU_busy(E_MDU_busy),
    	.E_MDU_out(E_MDU_out)
    );
//---------------------------------------------------------------------------------------------------------------------------

//E_M------------------------------------------------------------------------------------------------------------------------
	E_M e_m (
		.clk(clk), 
		.reset(reset), 
		.HCU_EN_EM(HCU_EN_EM), 
		.req(CP0_req),
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
		.E_MDU_out(E_MDU_out),
		.E_CU_is_mtc0(E_CU_is_mtc0),
		.E_CU_EN_CP0Write(E_CU_EN_CP0Write),
		.E_CU_is_mfc0(E_CU_is_mfc0),
		.E_CU_is_eret(E_CU_is_eret),
    	.E_rd(E_rd),
		.E_exc_addrOv(E_exc_addrOv),
		.E_CU_is_store(E_CU_is_store),
    	.E_CU_is_load(E_CU_is_load),
		.E_exc_code(E_new_exc_code),
		.E_is_BD(E_is_BD),
		.M_ReadData_rt(M_ReadData_rt), 
		.M_rt(M_rt), 
		.M_WriteRegAddr(M_WriteRegAddr), 
		.M_ALU_out(M_ALU_out), 
		.M_PC(M_PC), 
		.M_CU_DM_op(M_CU_DM_op), 
		.M_CU_EN_RegWrite(M_CU_EN_RegWrite), 
		.M_CU_EN_DMWrite(M_CU_EN_DMWrite), 
		.M_CU_GRFWriteData_Sel(M_CU_GRFWriteData_Sel), 
		.M_T_new(M_T_new),
		.M_MDU_out(M_MDU_out),
		.M_CU_is_mtc0(M_CU_is_mtc0),
		.M_CU_EN_CP0Write(M_CU_EN_CP0Write),
		.M_CU_is_mfc0(M_CU_is_mfc0),
		.M_CU_is_eret(M_CU_is_eret),
    	.M_rd(M_rd),
		.M_exc_addrOv(M_exc_addrOv),
		.M_CU_is_store(M_CU_is_store),
    	.M_CU_is_load(M_CU_is_load),
		.M_exc_code(M_exc_code),
		.M_is_BD(M_is_BD)
	);
//----------------------------------------------------------------------------------------------------------------------------

//M_DMIN--------------------------------------------------------------------------------------------------------------------
	M_DMIN m_dmin (
		.CU_EN_DMWrite(M_CU_EN_DMWrite), 
		.addr(M_ALU_out), 
		.writeData(fwd_M_WriteData), 
		.CU_DM_op(M_CU_DM_op),  
		.is_store(M_CU_is_store),
		.is_addrOv(M_exc_addrOv),
		.req(CP0_req),
		.M_DMIN_out(M_DMIN_out),
		.M_DMIN_byte_en(M_DMIN_byte_en),
		.M_is_AdES(M_is_AdES)
	);
//---------------------------------------------------------------------------------------------------------------------------

//M_DMOUT-----------------------------------------------------------------------------------------------------------------------
	M_DMOUT m_dmout (  
		.addr(M_ALU_out), 
		.readData(m_data_rdata), 
		.CU_DM_op(M_CU_DM_op),  
		.is_load(M_CU_is_load),
		.is_addrOv(M_exc_addrOv),
		.M_DM_out(M_DM_out),
		.M_is_AdEL(M_is_AdEL)
	);
//-----------------------------------------------------------------------------------------------------------------------------

	assign m_data_addr = M_ALU_out;
	assign m_data_wdata = M_DMIN_out;
	assign m_data_byteen = M_DMIN_byte_en;
	assign m_inst_addr = M_PC;

	assign Macro_PC = M_PC;

//M_exc_hand---------------------------------------------------------------------------------------------------------------------
	assign M_exc_AdES = M_is_AdES;

	assign M_exc_AdEL = M_is_AdEL;
//---------------------------------------------------------------------------------------------------------------------------

//M_W-------------------------------------------------------------------------------------------------------------------------
	M_W m_w (
		.clk(clk), 
		.reset(reset), 
		.HCU_EN_MW(HCU_EN_MW), 
		.req(CP0_req),
		.M_WriteRegAddr(M_WriteRegAddr), 
		.M_ALU_out(M_ALU_out), 
		.M_DM_out(M_DM_out), 
		.M_PC(M_PC), 
		.M_CU_EN_RegWrite(M_CU_EN_RegWrite), 
		.M_CU_GRFWriteData_Sel(M_CU_GRFWriteData_Sel), 
		.M_T_new(M_T_new), 
		.M_MDU_out(M_MDU_out),
		.M_CP0_out(CP0_Data_out),
		.W_WriteRegAddr(W_WriteRegAddr), 
		.W_ALU_out(W_ALU_out), 
		.W_DM_out(W_DM_out), 
		.W_PC(W_PC), 
		.W_CU_EN_RegWrite(W_CU_EN_RegWrite), 
		.W_CU_GRFWriteData_Sel(W_CU_GRFWriteData_Sel), 
		.W_T_new(W_T_new),
		.W_MDU_out(W_MDU_out),
		.W_CP0_out(W_CP0_out)
	);
//--------------------------------------------------------------------------------------------------------------------------------

//MCU----------------------------------------------------------------------------------------------------------------------------
	MCU mcu (
		.opcode(D_opcode), 
		.func(D_func), 
		.rs(D_rs),
		.CU_NPC_op_D(CU_NPC_op_D), 
		.CU_ALU_op_D(CU_ALU_op_D), 
		.CU_EXT_op_D(CU_EXT_op_D), 
		.CU_DM_op_D(CU_DM_op_D), 
		.CU_MDU_op_D(CU_MDU_op_D),
		.CU_CMP_op_D(CU_CMP_op_D),
		.CU_EN_RegWrite_D(CU_EN_RegWrite_D), 
		.CU_EN_DMWrite_D(CU_EN_DMWrite_D),
		.CU_MDU_start_D(CU_MDU_start_D),
		.CU_EN_CP0Write_D(CU_EN_CP0Write_D),
		.CU_is_MDU_opcode_D(CU_is_MDU_opcode_D), 
		.CU_is_eret_D(CU_is_eret_D),
    	.CU_is_mtc0_D(CU_is_mtc0_D),
		.CU_is_mfc0_D(CU_is_mfc0_D),
		.CU_is_judge_calOv_D(CU_is_judge_calOv_D),
    	.CU_is_judge_addrOv_D(CU_is_judge_addrOv_D),
		.CU_is_store_D(CU_is_store_D),
    	.CU_is_load_D(CU_is_load_D),
		.CU_is_beforeBD_D(CU_is_beforeBD_D),
		.CU_GRFWriteData_Sel_D(CU_GRFWriteData_Sel_D), 
		.CU_GRFWriteAddr_Sel_D(CU_GRFWriteAddr_Sel_D), 
		.CU_ALUB_Sel_D(CU_ALUB_Sel_D), 
		.T_use_rs(T_use_rs), 
		.T_use_rt(T_use_rt), 
		.T_new_D(T_new_D),
		.CU_exc_RI_D(CU_exc_RI_D) ,
		.CU_exc_Syscall_D(CU_exc_Syscall_D)
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
		.D_is_MDU_opcode(CU_is_MDU_opcode_D),
		.E_MDU_busy(E_MDU_busy),
		.E_MDU_start(E_CU_MDU_start),
	 	.D_is_eret(CU_is_eret_D),
    	.E_is_mtc0(E_CU_is_mtc0),
    	.M_is_mtc0(M_CU_is_mtc0),
		.E_CP0_addr(E_rd),
		.M_CP0_addr(M_rd),
		.stall(stall)
	);
//------------------------------------------------------------------------------------------------------------------------------

//CP0---------------------------------------------------------------------------------------------------------------------------
	CP0 cp0 (
    	.clk(clk),
    	.reset(reset),
    	.EN_CP0_Write(M_CU_EN_CP0Write),
    	.ReadAddr(CP0_readAddr),
    	.WriteAddr(CP0_writeAddr),
    	.WriteData(fwd_M_WriteData),
    	.M_PC(M_PC),                                
    	.ExcCode_op(M_new_exc_code),                 
		.is_Branch_Delay(M_is_BD),                   
		.Exter_HW_Int(Exter_HW_Int),                             
		.EXL_clr(M_CU_is_eret),                                
    	.CP0_req(CP0_req),                          
		.CP0_EPC_out(CP0_EPC_out),         
		.CP0_Data_out(CP0_Data_out),
		.response(response)
	);
//----------------------------------------------------------------------------------------------------------------------------

	assign exter_int_response = response;
	
//------------------------------------------------------------------------------------------------------------------------------

endmodule