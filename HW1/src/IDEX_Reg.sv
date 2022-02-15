module IDEX_Reg(
	input clk,
	input rst,
	input Flush,
	input [2:0] ID_ALUOP,
	input ID_ALUSrc,
	input ID_MemRead,
	input ID_MemWrite,
	input ID_MemtoReg,
	input ID_RegWrite,
	input ID_PCtoRegSrc,
	input ID_RDSrc,
	input [1:0] ID_branch,
	input [31:0] ID_pc,
	//input [31:0] RS1Data,
	//input [31:0] RS2Data,
	input [31:0] ID_alu_in1,
	input [31:0] ID_alu_in2,
	input [31:0] imm,
	input [2:0] funct3,
	input funct7,
	input [4:0] rd_addr, 
	//input [4:0] rs1_addr, 
	//input [4:0] rs2_addr,

	output reg [2:0] ALUOP,
	output reg ALUSrc,
	output reg EX_MemRead,
	output reg EX_MemWrite,
	output reg EX_MemtoReg,
	output reg EX_RegWrite,
	output reg PCtoRegSrc,
	output reg EX_RDSrc,
	output reg [1:0] branch,
	output reg [31:0] EX_pc,
	//output reg [31:0] EX_rs1_data,
	//output reg [31:0] EX_rs2_data,
	output reg [31:0] alu_in1,
	output reg [31:0] alu_in2,
	output reg [31:0] EX_imm,
	output reg [2:0] EX_funct3,
	output reg EX_funct7,
	output reg [4:0] EX_rd_addr, 
	//output reg [4:0] EX_rs1_addr, 
	//output reg [4:0] EX_rs2_addr,

	input [6:0] opcode,
	output reg [6:0] EX_opcode
);

always@(posedge clk or posedge rst)begin
	if(rst)begin
		ALUOP <= 3'b0;
		ALUSrc <= 1'b0;
		EX_MemRead <= 1'b0;
		EX_MemWrite <= 1'b0;
		EX_MemtoReg <= 1'b0;
		EX_RegWrite <= 1'b0;
		PCtoRegSrc <= 1'b0;
		branch <= 2'b0;
		EX_RDSrc <= 1'b0;

		EX_pc <= 32'b0;
		//EX_rs1_data <= 32'b0;
		//EX_rs2_data <= 32'b0;
		alu_in1 <= 32'b0;
		alu_in2 <= 32'b0;
		EX_imm <= 32'b0;
		EX_funct3 <= 3'b0;
		EX_funct7 <= 1'b0;
		EX_rd_addr <= 5'b0;
		//EX_rs1_addr <= 5'b0;
		//EX_rs2_addr <= 5'b0;

		EX_opcode <= 7'b0;
	end
	else begin
		
		if(Flush)begin
			ALUOP <= 3'b0;
			ALUSrc <= 1'b0;
			EX_MemRead <= 1'b0;
			EX_MemWrite <= 1'b0;
			EX_MemtoReg <= 1'b0;
			EX_RegWrite <= 1'b0;
			PCtoRegSrc <= 1'b0;
			branch <= 2'b0;
			EX_RDSrc <= 1'b0;
		end
		else begin
			ALUOP <= ID_ALUOP;
			ALUSrc <= ID_ALUSrc;
			EX_MemRead <= ID_MemRead;
			EX_MemWrite <= ID_MemWrite;
			EX_MemtoReg <= ID_MemtoReg;
			EX_RegWrite <= ID_RegWrite;
			PCtoRegSrc <= ID_PCtoRegSrc;
			branch <= ID_branch;
			EX_RDSrc <= ID_RDSrc;
			
		end

    EX_imm<=imm;
		EX_pc <= ID_pc;
		//EX_rs1_data <= RS1Data;
		//EX_rs2_data <= RS2Data;
		alu_in1 <= ID_alu_in1;
		alu_in2 <= ID_alu_in2;

		EX_funct3 <= funct3;
		EX_funct7 <= funct7;
		EX_rd_addr <= rd_addr;
		//EX_rs1_addr <= rs1_addr;
		//EX_rs2_addr <= rs2_addr;

		EX_opcode <= opcode;
	end
end


endmodule