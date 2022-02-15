module ALU(
	input [31:0] alu_in1,
	input [31:0] alu_in2,
	input [4:0] ALUCtrl,
	output reg ZeroFlag,
	output reg [31:0] alu_out
);

localparam [4:0] ADD = 5'b00000,
                 SUB = 5'b00001,
                 SLL = 5'b00010,
                 SLT = 5'b00011,
                 SLTU = 5'b00100,
                 i_XOR = 5'b00101,
                 SRL = 5'b00110,
                 SRA = 5'b00111,
                 i_OR = 5'b01000,
                 i_AND = 5'b01001,
                 JALR = 5'b01010,
                 BEQ = 5'b01011,
                 BNE = 5'b01100,
                 BLT = 5'b01101,
                 BGE = 5'b01110,
                 BLTU = 5'b01111,
                 BGEU = 5'b10000,
                 IMM = 5'b10001;
always_comb begin
	case(ALUCtrl)
		ADD: 	alu_out = alu_in1 + alu_in2;
		SUB: 	alu_out = alu_in1 - alu_in2;
		SLL: 	alu_out = alu_in1 << alu_in2[4:0];
		SLT: 	alu_out = ($signed(alu_in1)<$signed(alu_in2))?32'b1:32'b0;
		SLTU:	alu_out = (alu_in1<alu_in2)?32'b1:32'b0;
		i_XOR: 	alu_out = alu_in1 ^ alu_in2;
		SRL: 	alu_out = alu_in1 >> alu_in2[4:0];
		SRA: 	alu_out = $signed(alu_in1) >>> alu_in2[4:0];
		i_OR:  	alu_out = alu_in1 | alu_in2;
		i_AND: 	alu_out = alu_in1 & alu_in2;
		JALR:	alu_out = (alu_in1 + alu_in2) & {28'hfffffff,4'b1110};
		IMM:	alu_out = alu_in2;
		default:alu_out = 32'b0;
	endcase
	case(ALUCtrl)
		BEQ:	ZeroFlag = (alu_in1 == alu_in2)?1'b1:1'b0;
		BNE:	ZeroFlag = (alu_in1 != alu_in2)?1'b1:1'b0;
		BLT:	ZeroFlag = ($signed(alu_in1) < $signed(alu_in2))?1'b1:1'b0;
		BGE:	ZeroFlag = ($signed(alu_in1) >= $signed(alu_in2))?1'b1:1'b0;
		BLTU:	ZeroFlag = (alu_in1 < alu_in2)?1'b1:1'b0;
		BGEU:	ZeroFlag = (alu_in1 >= alu_in2)?1'b1:1'b0;
		default:ZeroFlag = 1'b0;
	endcase
end

endmodule