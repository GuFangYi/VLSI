module MEMWB_Reg(
	//input clk,
	//input rst, 
	//Reg file -> FF
	//input MEM_MemtoReg,
	//input [31:0] MEM_rd_data,
	//input [31:0] data_out,
	//output reg MemtoReg,
	//output reg [31:0] WB_rd_data_1,
	//output reg [31:0] WB_data_out,
	//input [2:0] MEM_funct3,
	//input [6:0] MEM_opcode,
	//output reg [2:0] WB_funct3,
	//output reg [6:0] WB_opcode

	input MEM_RegWrite,
	input [4:0] MEM_rd_addr,
	//input [31:0] WB_rd_data_1,
	output reg RegWrite,
	output reg [4:0] WB_rd_addr
	//output reg [31:0] WB_rd_data

	
);
always_comb begin
		WB_rd_addr <= MEM_rd_addr;
		RegWrite <= MEM_RegWrite;
end

/*always@(posedge clk or posedge rst)begin
	if(rst)begin
		//MemtoReg <= 1'b0;
		//WB_rd_data_1 <= 32'b0;
		//WB_data_out <= 32'b0;
		WB_rd_addr <= 5'b0;
		RegWrite <= 1'b0;
		WB_rd_data <= 32'b0;
		//WB_funct3<=3'b0;
		//WB_opcode <=7'b0;
	end
	else begin
		//MemtoReg <= MEM_MemtoReg;
		//WB_rd_data_1 <= MEM_rd_data;
		//WB_data_out <= data_out;
		WB_rd_addr <= MEM_rd_addr;
		RegWrite <= MEM_RegWrite;
		WB_rd_data <= WB_rd_data_1;
		//WB_funct3<=MEM_funct3;
		//WB_opcode <=MEM_opcode;
	end
end
*/
endmodule