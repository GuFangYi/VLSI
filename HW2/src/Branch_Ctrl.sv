module Branch_Ctrl(
	input [1:0] branch_input,
	input ZeroFlag,
	output reg [1:0] BranchCtrl
);

localparam [1:0]  PC_4 = 2'b00,
                  PC_IMM = 2'b01,
                  PC_ALU = 2'b10;

localparam [1:0] NONE = 2'b00,
				 JALR = 2'b01,
				 BRANCH = 2'b10,
				 JUMP = 2'b11;

always_comb begin
	case(branch_input)
		NONE:begin
			BranchCtrl = PC_4;
		end
		JALR:begin
			BranchCtrl = PC_ALU;//pc = imm + rs1
		end
		BRANCH:begin
			if(ZeroFlag) 
				BranchCtrl = PC_IMM;
			else
				BranchCtrl = PC_4;
		end
		default:begin
			BranchCtrl = PC_IMM;
		end
	endcase
end


endmodule