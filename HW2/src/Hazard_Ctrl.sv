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
	output reg PCWrite,
	input [1:0] stalls
	//output reg stage_RegWrite
);

//logic [2:0] temp;
assign Flush = (BranchCtrl != 2'b0);

always_comb begin
	if(stalls[0])begin//DM_stall
		//Flush = (BranchCtrl != 2'b00)? 1'b1:1'b0;
		CtrlFlush = 1'b1;
		IFID_RegWrite = 1'b0;
		PCWrite = 1'b0;
		//stage_RegWrite = 1'b0;
		//temp =3'd0;
	end
	else if (stalls[1])begin
		//Flush = 1'b0;
		CtrlFlush = 1'b0;
		IFID_RegWrite = 1'b0;
		PCWrite = 1'b0;
		//stage_RegWrite = 1'b1;
		//temp =3'd1;
	end
	else if(BranchCtrl != 2'b00)begin //!=PC_4 jump/jalr/branch
		//Flush = 1'b1;
		CtrlFlush = 1'b0;
		IFID_RegWrite = 1'b1;
		PCWrite = 1'b1;
		//stage_RegWrite = 1'b1;
		//temp =3'd2;
	end
	else if((EX_rd_addr == rs1_addr || EX_rd_addr == rs2_addr) && EX_MemRead)begin //lw-use (except for lw-sw: temporarily delete ImmType != 3'b001)
		//Flush = 1'b0;
		CtrlFlush = 1'b1;
		IFID_RegWrite = 1'b0;
		PCWrite = 1'b0;
		//stage_RegWrite = 1'b1;
		//temp =3'd3;
	end
	else begin
		//Flush = 1'b0;
		CtrlFlush = 1'b0;
		IFID_RegWrite = 1'b1;
		PCWrite = 1'b1;
		//stage_RegWrite = 1'b1;
		//temp =3'd4;
	end

end


endmodule