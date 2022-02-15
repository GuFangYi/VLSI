module Control_Unit(
	input [6:0] opcode,
	input Flush,
	//input [2:0] funct3,
	//input [31:0] imm,
	//output reg [2:0] //ImmType,
	output reg [2:0] ID_ALUOP,
	output reg ID_ALUSrc,
	output reg ID_MemRead,
	output reg ID_MemWrite,
	output reg ID_MemtoReg,
	output reg ID_RegWrite,
	output reg ID_PCtoRegSrc,
	output reg [1:0] ID_branch,
	output reg ID_RDSrc
);
//imm
localparam [2:0] I_IMM = 3'b000,
				 S_IMM = 3'b001,
				 B_IMM = 3'b010,
				 U_IMM = 3'b011,
				 J_IMM = 3'b100;
//opcode
localparam [6:0] RTYPE = 7'b0110011,
				 ITYPE = 7'b0010011,
				 ITYPE_L = 7'b0000011,
				 ITYPE_J = 7'b1100111,
				 STYPE = 7'b0100011,
				 BTYPE = 7'b1100011,
				 UTYPE_A = 7'b0010111,
				 UTYPE_L = 7'b0110111,
				 JTYPE = 7'b1101111;
//branch
localparam [1:0] NONE = 2'b00,
				 JALR = 2'b01,
				 BRANCH = 2'b10,
				 JUMP = 2'b11;
//aluop
localparam [2:0] ROP = 3'b000,
				 IOP = 3'b001,
				 ADDOP = 3'b010,
				 JALROP = 3'b011,
				 BOP = 3'b100,
				 ULOP = 3'b101;

always_comb begin
	if(~Flush) begin
		case(opcode)
			RTYPE:begin
				//ImmType = 3'b0;//x
				ID_ALUOP = ROP; 
				ID_ALUSrc = 1'b1;//data
				ID_MemRead = 1'b0;//x
				ID_MemWrite = 1'b0;//x
				ID_MemtoReg = 1'b0;//MEM_rd_data
				ID_RegWrite = 1'b1;
				ID_PCtoRegSrc = 1'b0;//x
				ID_branch = NONE;
				ID_RDSrc = 1'b0;//MEM_alu_out
			end
			ITYPE:begin
				//ImmType = I_IMM;
				ID_ALUOP = IOP; 
				ID_ALUSrc = 1'b0;//EX_imm
				ID_MemRead = 1'b0;//x
				ID_MemWrite = 1'b0;//x
				ID_MemtoReg = 1'b0;//MEM_rd_data
				ID_RegWrite = 1'b1;
				ID_PCtoRegSrc = 1'b0;//x
				ID_branch = NONE;
				ID_RDSrc = 1'b0;//MEM_alu_out
			end
			ITYPE_L:begin
				//ImmType = I_IMM;
				ID_ALUOP = ADDOP; 
				ID_ALUSrc = 1'b0;//EX_imm
				ID_MemRead = 1'b1;
				ID_MemWrite = 1'b0;
				ID_MemtoReg = 1'b1;//data_out
				ID_RegWrite = 1'b1;
				ID_PCtoRegSrc = 1'b0;//x
				ID_branch = NONE;
				ID_RDSrc = 1'b0;//x
			end
			ITYPE_J:begin
				//ImmType = I_IMM;
				ID_ALUOP = JALROP;
				ID_ALUSrc = 1'b0;//EX_imm
				ID_MemRead = 1'b0;//x
				ID_MemWrite = 1'b0;//x
				ID_MemtoReg = 1'b0;//MEM_rd_data
				ID_RegWrite = 1'b1;
				ID_PCtoRegSrc = 1'b0;//EX_pc+4
				ID_branch = JALR;
				ID_RDSrc = 1'b1;//WB_pc_to_reg
			end
			STYPE:begin
				//ImmType = S_IMM;
				ID_ALUOP = ADDOP; 
				ID_ALUSrc = 1'b0;//M[rs1+imm]=rs2
				ID_MemRead = 1'b0;
				
				/*case(funct3)
					3'b010: ID_MemWrite =4'b1111; //SW
		            3'b000: begin//SB
		              if((imm%4)==3)
		                ID_MemWrite =4'b1000;
		              else if((imm%4)==2)
		                ID_MemWrite =4'b0100;
		              else if((imm%4)==1)
		                ID_MemWrite =4'b0010;
		              else 
		                ID_MemWrite =4'b0001;
		            end
		            default: begin//SH 3'b001
		              if((imm%4)==2)
		                ID_MemWrite =4'b1100;
		              else 
		                ID_MemWrite =4'b0011;
		            end
				endcase
				*/
				ID_MemWrite = 1'b1;
				//ID_MemWrite = 4'b1111;
				ID_MemtoReg = 1'b0;//x
				ID_RegWrite = 1'b0;
				ID_PCtoRegSrc = 1'b0;//x
				ID_branch = NONE;
				ID_RDSrc = 1'b0;//x
			end
			BTYPE:begin
				//ImmType = B_IMM;
				ID_ALUOP = BOP; 
				ID_ALUSrc = 1'b1;//rs1 vs rs2
				ID_MemRead = 1'b0;//x
				ID_MemWrite = 1'b0;//x
				ID_MemtoReg = 1'b0;//x
				ID_RegWrite = 1'b0;
				ID_PCtoRegSrc = 1'b0;//x
				ID_branch = BRANCH;
				ID_RDSrc = 1'b1;//x
			end
			UTYPE_A:begin
				//ImmType = U_IMM;
				ID_ALUOP = ADDOP;//x 
				ID_ALUSrc = 1'b0;//x
				ID_MemRead = 1'b0;//x
				ID_MemWrite = 1'b0;//x
				ID_MemtoReg = 1'b0;//MEM_rd_data
				ID_RegWrite = 1'b1;
				ID_PCtoRegSrc = 1'b1; //EX_pc + EX_imm
				ID_branch = NONE;
				ID_RDSrc = 1'b1;//MEM_pc_to_reg
			end
			UTYPE_L:begin
				//ImmType = U_IMM;
				ID_ALUOP = ULOP; 
				ID_ALUSrc = 1'b0;//EX_imm
				ID_MemRead = 1'b0;
				ID_MemWrite = 1'b0;
				ID_MemtoReg = 1'b0;//MEM_rd_data
				ID_RegWrite = 1'b1;
				ID_PCtoRegSrc = 1'b0;//x
				ID_branch = NONE;
				ID_RDSrc = 1'b0;//MEM_alu_out
			end
			JTYPE:begin
				//ImmType = J_IMM;
				ID_ALUOP = ADDOP;//x
				ID_ALUSrc = 1'b0;//x
				ID_MemRead = 1'b0;//x
				ID_MemWrite = 1'b0;//x
				ID_MemtoReg = 1'b0;//WB_rd_data
				ID_RegWrite = 1'b1;
				ID_PCtoRegSrc = 1'b0;//EX_pc+4
				ID_branch = JUMP;
				ID_RDSrc = 1'b1;//MEM_pc_to_reg
			end
			default:begin //initial
				//ImmType = 3'b0;
				ID_ALUOP = IOP; 
				ID_ALUSrc = 1'b0;
				ID_MemRead = 1'b0;
				ID_MemWrite = 1'b0;
				ID_MemtoReg = 1'b0;
				ID_RegWrite = 1'b0;
				ID_PCtoRegSrc = 1'b0;
				ID_branch = NONE;
				ID_RDSrc = 1'b0;
			end
		endcase
	end
	else begin
		ID_ALUOP = IOP; 
		ID_ALUSrc = 1'b0;
		ID_MemRead = 1'b0;
		ID_MemWrite = 1'b0;
		ID_MemtoReg = 1'b0;
		ID_RegWrite = 1'b0;
		ID_PCtoRegSrc = 1'b0;
		ID_branch = NONE;
		ID_RDSrc = 1'b0;
	end
end
endmodule