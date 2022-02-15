`include "Reg_File.sv"
`include "PC.sv"
`include "IFID_Reg.sv"
`include "IDEX_Reg.sv"
`include "EXMEM_Reg.sv"
`include "Imm_Generator.sv"
`include "Hazard_Ctrl.sv"
`include "Forward_Unit.sv"
`include "Control_Unit.sv"
`include "Branch_Ctrl.sv"
`include "ALU_Ctrl.sv"
`include "ALU.sv"
`include "SRAM_wrapper.sv"
`include "MUX_3_1.sv"
`include "MUX_2_1.sv"

module top(
    input clk, 			//system clock
    input rst			//system reset (active high)
   
);

//IF
reg [31:0] pc_in;
wire [31:0] pc_out, ID_pc;
wire [31:0] pc_add;
wire [31:0] instr, instr_out;
reg [31:0] instr_in;


//ID
wire [31:0] RS1Data, RS2Data;
wire [31:0] imm;
reg [2:0] funct3;
reg funct7;
reg [4:0] rd_addr, rs1_addr, rs2_addr;


//EX
wire [31:0] EX_pc;
wire [31:0] EX_imm;
wire [2:0] EX_funct3;
wire EX_funct7;
wire [4:0] EX_rd_addr; 
wire [31:0] alu_out;
reg [31:0] EX_pc_imm, EX_pc_4, pc_to_reg;
reg [31:0] alu_in1, alu_in2, alu_in2_2;
wire ZeroFlag;

wire [6:0] EX_opcode; 

//MEM
reg [31:0] MEM_rd_data;
wire [4:0] MEM_rd_addr;
wire [15:0] MEM_alu_out;
wire [31:0] MEM_forward_rs2_data;
reg [31:0] data_in;//data input in DM
wire [31:0] data_out;

wire [2:0] MEM_funct3;
wire [6:0] MEM_opcode;

//WB
reg [31:0] WB_rd_data;

//HazardUnit
wire IFID_RegWrite;
wire Flush;
wire CtrlFlush;
wire PCWrite;

//BranchCtrl
wire [1:0] BranchCtrl;

//ControlUnit
//wire [2:0] ImmType;
wire [2:0] ID_ALUOP;
wire ID_ALUSrc;
wire ID_MemRead;
wire ID_MemWrite;
wire ID_MemtoReg;
wire ID_RegWrite;
wire ID_PCtoRegSrc;
wire [1:0] ID_branch;
wire ID_RDSrc;

wire [2:0] ALUOP;
wire ALUSrc;
wire EX_MemRead;
wire EX_MemWrite;
wire EX_MemtoReg;
wire EX_RegWrite;
wire PCtoRegSrc;
wire [1:0] branch;

wire MEM_RegWrite;
wire MemRead;
wire MemWrite;
wire RDSrc;
wire chip_select;

//wire RegWrite;
wire MemtoReg;


//ALUCtrl
wire [4:0] ALUCtrl;

//ForwardingUnit
wire [1:0] ForwardRS1Src, ForwardRS2Src;
//wire ForwardRDSrc;

/**********************************************/
localparam [1:0]  PC_4 = 2'b00,
                  PC_IMM = 2'b01,
                  PC_ALU = 2'b10;

assign pc_add = pc_out + 32'd4;

MUX_3_1 pc_MUX(
	.in_1(pc_add),
	.in_2(EX_pc_imm),
	.in_3(alu_out),
	.ctrl(BranchCtrl),
	.out(pc_in)
);

PC i_PC(
  .clk    			( clk),
  .rst    			( rst),
  .pc_in  			( pc_in),
  .PCWrite 			( PCWrite),
  .pc_out 			( pc_out)
);

SRAM_wrapper IM1(
  .CK 				( ~clk 		), //i: system clock
  .CS 				( 1'b1 		), //i: chip select (active high) mem read or write 
  .OE 				( 1'b1		), //i: output enable (active high)
  .WEB				( 4'b1111	), //i: write enable (active low)
  .A 				( pc_out[15:2]	), //i: address
  .DI 				( 32'b0			), //i: data input
  .DO 				( instr			)  //o: data output
);

MUX_2_1 instr_MUX(
	.in_1(32'b0),
	.in_2(instr),
	.ctrl(Flush),
	.out(instr_in)
);

IFID_Reg i_IFID_Reg(
	.clk 			( clk),
	.rst 			( rst),
	.instr 			( instr_in),
	.pc_out 		( pc_out),
	.IFID_RegWrite 	( IFID_RegWrite),
	.instr_out 		( instr_out),
	.ID_pc			( ID_pc)
);


/*Reg File->FF
Reg_File i_Reg_File(
	.clk 			( clk),
	.rst 			( rst),
	.rs1_addr 		( rs1_addr),
	.rs2_addr 		( rs2_addr),
	.WB_rd_addr 	( WB_rd_addr),
	.WB_rd_data 	( WB_rd_data),
	.RegWrite 		( RegWrite),
	.funct3  		( WB_funct3 ),
	.opcode 		( WB_opcode),
	.RS1Data 		( RS1Data),
	.RS2Data 		( RS2Data)
);
*/
Reg_File i_Reg_File(
	.clk 			( clk),
	.rst 			( rst),
	.rs1_addr 		( rs1_addr),
	.rs2_addr 		( rs2_addr),
	.WB_rd_addr 	( MEM_rd_addr),
	.WB_rd_data 	( WB_rd_data),
	.RegWrite 		( MEM_RegWrite),
	.funct3  		( MEM_funct3 ),
	.opcode 		( MEM_opcode),
	.RS1Data 		( RS1Data),
	.RS2Data 		( RS2Data)
);

Imm_Generator i_Imm_Gen(
	//.ImmType 		( ImmType),
	.opcode 		( instr_out[6:0]),
	.instr_out 	( instr_out),
	.imm 				( imm)
);

always_comb begin
	if(Flush)begin
		rd_addr  = 5'b0;
		funct3 	 = 3'b0;
		rs1_addr = 5'b0;
		rs2_addr = 5'b0;
		funct7 	 = 1'b0;
	end
	else begin
		rd_addr  = instr_out[11:7];
		funct3 	 = instr_out[14:12];
		rs1_addr = instr_out[19:15];
		rs2_addr = instr_out[24:20];
		funct7 	 = instr_out[30];
	end
end

Control_Unit i_Control_Unit(
	.opcode		 	( instr_out[6:0]),
	//.imm 				( imm),
	//.ImmType	 	( ImmType),
	.ID_ALUOP	 	( ID_ALUOP),
	.ID_ALUSrc	 	( ID_ALUSrc),
	.ID_MemRead	 	( ID_MemRead),
	.ID_MemWrite 	( ID_MemWrite),
	.ID_MemtoReg 	( ID_MemtoReg),
	.ID_RegWrite 	( ID_RegWrite),
	.ID_PCtoRegSrc 	( ID_PCtoRegSrc),
	.ID_branch 		( ID_branch),
	.ID_RDSrc		( ID_RDSrc) 
);

wire [31:0] ID_alu_in1, ID_alu_in2;

IDEX_Reg i_IDEX_Reg(
	.clk 			( clk),
	.rst 			( rst),
	.Flush 			( CtrlFlush),
	.ID_ALUOP 		( ID_ALUOP),
	.ID_ALUSrc 		( ID_ALUSrc),
	.ID_MemRead 	( ID_MemRead),
	.ID_MemWrite 	( ID_MemWrite),
	.ID_MemtoReg 	( ID_MemtoReg),
	.ID_RegWrite 	( ID_RegWrite),
	.ID_PCtoRegSrc 	( ID_PCtoRegSrc),
	.ID_RDSrc 		( ID_RDSrc),
	.ID_branch 		( ID_branch),
	.ID_pc 			( ID_pc),
	.ID_alu_in1	(ID_alu_in1),
	.ID_alu_in2 (ID_alu_in2),
	.imm 			( imm),
	.funct3 		( funct3),
	.funct7 		( funct7), 
	.rd_addr 		( rd_addr),   

	.opcode 		( instr_out[6:0]),
	.ALUOP 			( ALUOP),
	.ALUSrc 		( ALUSrc),
	.EX_MemRead 	( EX_MemRead),
	.EX_MemWrite 	( EX_MemWrite),
	.EX_MemtoReg 	( EX_MemtoReg),
	.EX_RegWrite 	( EX_RegWrite),
	.PCtoRegSrc 	( PCtoRegSrc),
	.branch 		( branch),
	.EX_RDSrc 	( RDSrc),
	.EX_pc 			( EX_pc),
	.alu_in1 		( alu_in1),
	.alu_in2  ( alu_in2),
	.EX_imm 		( EX_imm),
	.EX_funct3 		( EX_funct3),
	.EX_funct7 		( EX_funct7),
	.EX_rd_addr 	( EX_rd_addr), 
	.EX_opcode 	( EX_opcode)

);

assign EX_pc_imm = EX_pc + EX_imm;
assign EX_pc_4	 = EX_pc +4;

MUX_2_1 pc_to_reg_MUX(
	.in_1(EX_pc_imm),
	.in_2(EX_pc_4),
	.ctrl(PCtoRegSrc),
	.out(pc_to_reg)
);

wire [31:0] EX_rd_data;
MUX_3_1 alu_in1_MUX(
	.in_1(RS1Data),
	.in_2(EX_rd_data),
	.in_3(WB_rd_data),
	.ctrl(ForwardRS1Src),
	.out(ID_alu_in1)
);
MUX_3_1 alu_in2_1_MUX(
	.in_1(RS2Data),
	.in_2(EX_rd_data),
	.in_3(WB_rd_data),
	.ctrl(ForwardRS2Src),
	.out(ID_alu_in2)
);


MUX_2_1 alu_in2_2_MUX(
	.in_1(alu_in2),
	.in_2(EX_imm),
	.ctrl(ALUSrc),
	.out(alu_in2_2)
);

ALU_Ctrl i_ALU_Ctrl(
	.ALUOP 				( ALUOP),
	.EX_funct3 		( EX_funct3),
	.EX_funct7 		( EX_funct7),
	.ALUCtrl 			( ALUCtrl)
);

ALU i_ALU(
	.alu_in1 		( alu_in1),
	.alu_in2 		( alu_in2_2),
	.ALUCtrl 		( ALUCtrl),
	.ZeroFlag 		( ZeroFlag),
	.alu_out 		( alu_out)
);

Forward_Unit i_Forward_Unit(
	.EX_rs1_addr 	( rs1_addr),
	.EX_rs2_addr 	( rs2_addr),
	.MEM_rd_addr 	( EX_rd_addr),
	.WB_rd_addr 	( MEM_rd_addr),
	.MEM_RegWrite 	( EX_RegWrite),
	.RegWrite 	( MEM_RegWrite),
	.ForwardRS1Src 	( ForwardRS1Src),
	.ForwardRS2Src 	( ForwardRS2Src)
	//.ForwardRDSrc 	( ForwardRDSrc)
);

Branch_Ctrl i_Branch_Ctrl(
	.branch_input 		( branch),
	.ZeroFlag 		( ZeroFlag),
	.BranchCtrl 	( BranchCtrl)

);

Hazard_Ctrl i_Hazard_Ctrl(
	.BranchCtrl 	( BranchCtrl),
	.EX_MemRead 	( EX_MemRead),
	.EX_rd_addr 	( EX_rd_addr),
	.rs1_addr 	 	( rs1_addr),
	.rs2_addr 		( rs2_addr),
	.Flush 			( Flush),
	.CtrlFlush 		( CtrlFlush),
	.IFID_RegWrite 	( IFID_RegWrite),
	.PCWrite 		( PCWrite)
);



EXMEM_Reg i_EXMEM_Reg(
	.clk 			( clk),
	.rst 			( rst),
	.EX_MemRead 	( EX_MemRead),
	.EX_MemWrite 	( EX_MemWrite),
	.EX_MemtoReg 	( EX_MemtoReg),
	.EX_RegWrite 	( EX_RegWrite),
	.EX_funct3 		( EX_funct3),
	.EX_opcode 	( EX_opcode),
	.EX_rd_data ( EX_rd_data),
	.alu_out 		( alu_out),
	.EX_forward_rs2_data ( alu_in2),
	.EX_rd_addr 	( EX_rd_addr),
	.MemRead 		( MemRead),
	.MemWrite 		( MemWrite),
	.MEM_MemtoReg 	( MemtoReg),//reg file->FF so MEM_MemtoReg change to MemtoReg
	.MEM_RegWrite 	( MEM_RegWrite),
	.MEM_funct3 	( MEM_funct3),
	.MEM_opcode 	( MEM_opcode),
	.MEM_rd_data  ( MEM_rd_data),
	.MEM_alu_out 	( MEM_alu_out),
	.MEM_forward_rs2_data 	( MEM_forward_rs2_data),
	.MEM_rd_addr	( MEM_rd_addr)
);

MUX_2_1 MEM_rd_data_MUX(
	.in_1(pc_to_reg),
	.in_2(alu_out),
	.ctrl(RDSrc),
	.out(EX_rd_data)
);
/*MUX_2_1 data_in_MUX(
	.in_1(MEM_forward_rs2_data),
	.in_2(WB_rd_data),
	.ctrl(~ForwardRDSrc),
	.out(data_in)
);
*/

/*always_comb begin
	unique case(MemWrite)
		4'b0000:	data_in = MEM_forward_rs2_data;
		4'b0001:	data_in = {{24{1'b0}},MEM_forward_rs2_data[7:0]};
		4'b0010:	data_in = {{16{1'b0}},MEM_forward_rs2_data[7:0],8'd0};
		4'b0100:	data_in = {{8{1'b0}},MEM_forward_rs2_data[7:0],16'd0};
		4'b1000:	data_in = {MEM_forward_rs2_data[7:0],{24{1'b0}}};
		4'b0011:	data_in = {{16{1'b0}},MEM_forward_rs2_data[15:0]};
		4'b1100:	data_in = {MEM_forward_rs2_data[15:0],{16{1'b0}}};
		default:	data_in = MEM_forward_rs2_data;//4'b1111
	endcase
end
*/
always_comb begin
	data_in = 32'b0;
		case (MEM_funct3)
      3'b000: // SB
        data_in[{MEM_alu_out[1:0], 3'b0}+:8] = MEM_forward_rs2_data[7:0];
      3'b001: // SH
        data_in[{MEM_alu_out[1], 4'b0}+:16] = MEM_forward_rs2_data[15:0];
      default : // SW
        data_in = MEM_forward_rs2_data;
    endcase
end

/*wire write;
assign write = (MemWrite==4'b0)?1'b0:1'b1;
assign chip_select = MemRead | write;*/
assign chip_select = MemRead | MemWrite;
reg [3:0] mem_write;
//assign mem_write = MemWrite^4'b1111;//invert

always_comb begin
        mem_write = 4'b1111;
        if(MemWrite) begin
            case (MEM_funct3)
                3'b000: // SB
                    mem_write[MEM_alu_out[1:0]] = 1'b0;
                3'b001: // SH
                    mem_write[{MEM_alu_out[1],1'b0}+:2] = 2'b00;
                default: // SW
                    mem_write = 4'b0000;
            endcase
        end
    end

SRAM_wrapper DM1(
  .CK       	( ~clk         		), //i: system clock
  .CS 			( chip_select		), //i: chip select (active high)
  .OE       	( MemRead      		), //i: output enable (active high)
  .WEB			( mem_write	), //i: write enable (active low)
  .A 			( MEM_alu_out[15:2]	), //i: address
  .DI 			( data_in	), //i: data input
  .DO 			( data_out			)  //o: data output
);

MUX_2_1 WB_rd_data_MUX(
	.in_1(data_out),
	.in_2(MEM_rd_data),
	.ctrl(MemtoReg),
	.out(WB_rd_data)
);

endmodule