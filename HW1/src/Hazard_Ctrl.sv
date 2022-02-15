module Hazard_Ctrl(
	input [1:0] BranchCtrl,
	input EX_MemRead,
	input [4:0] EX_rd_addr,
	input [4:0] rs1_addr,
	input [4:0] rs2_addr,
	//input [2:0] ImmType,
	output reg Flush,
	output reg CtrlFlush,
	output reg IFID_RegWrite,
	output reg PCWrite
);

always_comb begin
	if(BranchCtrl != 2'b00)begin //!=PC_4 jump/jalr/branch
		Flush = 1'b1;
		CtrlFlush = 1'b1;
		IFID_RegWrite = 1'b1;
		PCWrite = 1'b1;
	end
	else if((EX_rd_addr == rs1_addr || EX_rd_addr == rs2_addr) && EX_MemRead)begin //lw-use (except for lw-sw: temporarily delete ImmType != 3'b001)
		Flush = 1'b0;
		CtrlFlush = 1'b1;
		IFID_RegWrite = 1'b0;
		PCWrite = 1'b0;
	end
	else begin
		Flush = 1'b0;
		CtrlFlush = 1'b0;
		IFID_RegWrite = 1'b1;
		PCWrite = 1'b1;
	end

end


endmodule