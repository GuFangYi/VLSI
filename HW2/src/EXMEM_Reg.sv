module EXMEM_Reg(
	input clk,
	input rst,
	//input EX_RDSrc,
	input EX_MemRead,
	input EX_MemWrite,
	input EX_MemtoReg,
	input EX_RegWrite,
	
	//input [31:0] pc_to_reg,
	input [31:0] EX_rd_data,
	input [31:0] alu_out,
	input [31:0] EX_forward_rs2_data,
	input [4:0] EX_rd_addr,
	//output reg RDSrc,
	output reg MemRead, 
	output reg MemWrite,
	output reg MEM_MemtoReg,
	output reg MEM_RegWrite,
	//output reg [31:0] MEM_pc_to_reg,
	output reg [31:0] MEM_rd_data,
	output reg [31:0] MEM_alu_out,
	output reg [31:0] MEM_forward_rs2_data,
	output reg [4:0] MEM_rd_addr,

	input [2:0] EX_funct3,
	input [6:0] EX_opcode,
	output reg [2:0] MEM_funct3,
	output reg [6:0] MEM_opcode,
	input CtrlFlush,
	input stage_Flush
);

always@(posedge clk or posedge rst)begin
	if(rst)begin
		//RDSrc <= 1'b0;
		MemRead <= 1'b0;
		MemWrite <= 1'b0;
		//MEM_pc_to_reg <= 32'b0;
		MEM_alu_out <= 32'b0;
		MEM_forward_rs2_data <= 32'b0;
		MEM_rd_addr <= 5'b0;
		MEM_MemtoReg <= 1'b0;
		MEM_RegWrite <= 1'b0;
		MEM_funct3 <= 3'b0;
		MEM_opcode <= 7'b0;
		MEM_rd_data <= 32'b0;
	end
	else begin
		/*if(stage_Flush)begin
			MemRead <= MemRead;
			MemWrite <= MemWrite;
			MEM_alu_out <= MEM_alu_out;
			MEM_forward_rs2_data <= MEM_forward_rs2_data;
			MEM_rd_addr <= MEM_rd_addr;
			MEM_MemtoReg <= MEM_MemtoReg;
			MEM_RegWrite <= MEM_RegWrite;
			MEM_funct3<=MEM_funct3;
			MEM_opcode <=MEM_opcode;
			MEM_rd_data <= MEM_rd_data;

		end
		else if(CtrlFlush)begin	
			MemRead <= 1'b0;
			MemWrite <= 1'b0;
			MEM_alu_out <= 32'b0;
			MEM_forward_rs2_data <= 32'b0;
			MEM_rd_addr <= 5'b0;
			MEM_MemtoReg <= 1'b0;
			MEM_RegWrite <= 1'b0;
			MEM_funct3 <= 3'b0;
			MEM_opcode <= 7'b0;
			MEM_rd_data <= 32'b0;
		end
		*/
		if(~stage_Flush) begin
			//RDSrc <= EX_RDSrc;
			MemRead <= EX_MemRead;
			MemWrite <= EX_MemWrite;
			//MEM_pc_to_reg <= pc_to_reg;
			MEM_alu_out <= alu_out;
			MEM_forward_rs2_data <= EX_forward_rs2_data;
			MEM_rd_addr <= EX_rd_addr;
			MEM_MemtoReg <= EX_MemtoReg;
			MEM_RegWrite <= EX_RegWrite;
			MEM_funct3<=EX_funct3;
			MEM_opcode <=EX_opcode;
			MEM_rd_data <= EX_rd_data;
		end
	end
end

endmodule