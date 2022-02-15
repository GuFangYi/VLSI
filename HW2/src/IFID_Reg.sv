module IFID_Reg (
	input clk,
	input rst,
	input [31:0] instr,
	input [31:0] pc_out,
	input IFID_RegWrite,
	//input CtrlFlush,
	output reg [31:0] instr_out,
	output reg [31:0] ID_pc
);

always@(posedge clk or posedge rst) begin
	if(rst)begin
		ID_pc <= 0;
		instr_out <= 0;
	end
	else begin
		if(IFID_RegWrite)begin//~CtrlFlush
			ID_pc <= pc_out;
			instr_out <= instr;
		end
	end
end

//assign ID_pc = pc_out;
//assign instr_out = instr;
	
endmodule