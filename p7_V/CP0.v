`timescale 1ns / 1ps
//-----------------------------------------------------------------------------------------------------------------
`define SR_addr		  12
`define Cause_addr	  13
`define EPC_addr      14

`define IM        SR[15:10]           //外设允许中断使能信号
`define EXL       SR[1]               //异常发生时置为，有效时禁止中�
`define IE        SR[0]               //全局中断使能
`define BD        Cause[31]           //有效时表示该指令为延迟槽指令，受害PC是宏观PC-4
`define IP        Cause[15:10]        //外设中断信号
`define ExcCode   Cause[6:2]          //记录异常类型
//-----------------------------------------------------------------------------------------------------------------


//端口定义--------------------------------------------------------------------------------------------------------
module CP0 (
    input clk,
    input reset,
    input EN_CP0_Write,
    input [4:0] ReadAddr,
    input [4:0] WriteAddr,
    input [31:0] WriteData,
    input [31:0] M_PC,                    //宏观PC，根据is_BD去计算受害PC
    
    input [4:0] ExcCode_op,               //异常的类�
    input is_Branch_Delay,                //是否是延迟操指令
    input [5:0] Exter_HW_Int,             //外设输入中断信号
    input EXL_clr,                        //复位EXL
    
    output CP0_req,                       //进入处理程序请求/异常中断请求
    output [31:0] CP0_EPC_out,         
    output [31:0] CP0_Data_out,
    output response
    );
//---------------------------------------------------------------------------------------------------------------------    


//define reg-----------------------------------------------------------------------------------------------------------
    reg [31:0] SR;
    reg [31:0] Cause;
    reg [31:0] EPC;
//---------------------------------------------------------------------------------------------------------------------


//read------------------------------------------------------------------------------------------------------------------
    assign CP0_Data_out = (ReadAddr == `SR_addr) ? {16'H0000, `IM, 8'H00, `EXL, `IE} :
					      (ReadAddr == `Cause_addr) ? Cause :
					      (ReadAddr == `EPC_addr) ? EPC :
					                          32'H9136_6511;

    assign CP0_EPC_out = EPC;
//-----------------------------------------------------------------------------------------------------------------------


//Interrupt_request-------------------------------------------------------------------------------------------------------
    wire Exter_hardware_interrupt = (|(Exter_HW_Int & `IM)) & (`IE) & (!`EXL);                        //外部中断
    wire Inter_exception_interrupt = (|ExcCode_op) & (!`EXL);                                         //内部异常

    assign CP0_req = (Exter_hardware_interrupt | Inter_exception_interrupt);

    assign response = (Exter_hardware_interrupt) & (Exter_HW_Int[2]);
//-------------------------------------------------------------------------------------------------------------------------


//write-------------------------------------------------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            SR <= 32'H0000_0000;
            Cause <= 32'H0000_0000;
            EPC <= 32'H0000_0000;                    
        end
        else if (EXL_clr) begin
            `EXL <= 1'b0;
        end
        else if (CP0_req) begin
            `BD <= is_Branch_Delay;
            `EXL <= 1'b1;
            `ExcCode <= (Exter_hardware_interrupt) ? 5'b00000 : ExcCode_op;
            EPC <= (is_Branch_Delay) ? M_PC - 4 : M_PC;                          
        end
        else if (EN_CP0_Write) begin
            if (WriteAddr == `SR_addr) begin
                SR <= WriteData;    
            end
            else if (WriteAddr == `Cause_addr) begin
                Cause <= WriteData;
            end
            else if (WriteAddr == `EPC_addr) begin
                EPC = WriteData;
            end
        end


        if (!reset) begin
            `IP <= Exter_HW_Int;
        end
    end 
//---------------------------------------------------------------------------------------------------------------------------

endmodule