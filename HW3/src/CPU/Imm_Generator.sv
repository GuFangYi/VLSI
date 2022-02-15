module Imm_Generator(
	//input [2:0] ImmType,
	input [6:0] opcode,
	input [31:0] instr_out,
	output reg [31:0] imm
);

/*localparam 	ITYPE = 3'b000,
			STYPE = 3'b001,
			BTYPE = 3'b010,
			UTYPE = 3'b011,
			JTYPE = 3'b100;
			*/
localparam [6:0] RTYPE = 7'b0110011,
				 ITYPE = 7'b0010011,
				 ITYPE_L = 7'b0000011,
				 ITYPE_J = 7'b1100111,
				 STYPE = 7'b0100011,
				 BTYPE = 7'b1100011,
				 UTYPE_A = 7'b0010111,
				 UTYPE_L = 7'b0110111,
				 JTYPE = 7'b1101111;


always_comb begin
	/*case(ImmType)
		ITYPE:	imm = {{20{instr_out[31]}}, instr_out[31:20]};
		STYPE:	imm = {{20{instr_out[31]}}, instr_out[31:25], instr_out[11:7]};
		BTYPE:	imm = {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
		UTYPE:	imm = {instr_out[31:12], 12'b0};
		default:imm = {{12{instr_out[31]}},instr_out[19:12],instr_out[20],instr_out[30:21],1'b0}; //JTYPE
	endcase
	*/
	case(opcode)
		STYPE: imm = {{20{instr_out[31]}}, instr_out[31:25], instr_out[11:7]};
		BTYPE: imm = {{19{instr_out[31]}}, instr_out[31], instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
		UTYPE_A: imm = {instr_out[31:12], 12'b0};
		UTYPE_L: imm = {instr_out[31:12], 12'b0};
		JTYPE: imm = {{12{instr_out[31]}},instr_out[19:12],instr_out[20],instr_out[30:21],1'b0};
		default: imm = {{20{instr_out[31]}}, instr_out[31:20]};
	endcase
end


endmodule