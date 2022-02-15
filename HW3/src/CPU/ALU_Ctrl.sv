module ALU_Ctrl(
	input [2:0] ALUOP,
	input [2:0] EX_funct3,
	input EX_funct7,
	output reg [4:0] ALUCtrl
);
localparam [2:0] ROP = 3'b000,
				 IOP = 3'b001,
				 ADDOP = 3'b010,
				 JALROP = 3'b011,
				 BOP = 3'b100,
				 ULOP = 3'b101;
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
	case(ALUOP)
		ROP:begin 
			case(EX_funct3)
				3'b000: begin
					if(!EX_funct7)	ALUCtrl = ADD;
					else 				ALUCtrl = SUB;
				end
				3'b001: ALUCtrl = SLL;
				3'b010: ALUCtrl = SLT;
				3'b011: ALUCtrl = SLTU;
				3'b100: ALUCtrl = i_XOR;
				3'b101: begin
					if(!EX_funct7) ALUCtrl = SRL;
					else		ALUCtrl = SRA;
				end
				3'b110: ALUCtrl = i_OR;
				default: ALUCtrl = i_AND;
			endcase
		end
		IOP:begin 
			case(EX_funct3)
				3'b000: ALUCtrl = ADD;
				3'b001: ALUCtrl = SLL;
				3'b010: ALUCtrl = SLT;
				3'b011: ALUCtrl = SLTU;
				3'b100: ALUCtrl = i_XOR;
				3'b101: begin
					if(!EX_funct7) ALUCtrl = SRL;
					else		ALUCtrl = SRA;
				end
				3'b110: ALUCtrl = i_OR;
				default: ALUCtrl = i_AND;
			endcase
		end
		ADDOP:begin
			ALUCtrl = ADD;
		end
		JALROP:begin
 			ALUCtrl = JALR;
		end
		BOP:begin
			case(EX_funct3)
				3'b000: ALUCtrl = BEQ;
				3'b001: ALUCtrl = BNE;
				3'b100: ALUCtrl = BLT;
				3'b101: ALUCtrl = BGE;
				3'b110: ALUCtrl = BLTU;
				default: ALUCtrl = BGEU;
			endcase
		end
		default:begin //ULOP
			ALUCtrl = IMM;
		end
	endcase
end

endmodule