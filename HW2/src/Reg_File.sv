module Reg_File(
	input clk,
	input rst,
	input [4:0] rs1_addr,
	input [4:0] rs2_addr,
	input [4:0] WB_rd_addr,
	input [31:0] WB_rd_data,
	input RegWrite,
	input [2:0] funct3,
	input [6:0] opcode,
	output [31:0] RS1Data,
	output [31:0] RS2Data
);

reg [31:0] REGISTER [0:31];
integer i;

always@(posedge clk or posedge rst) begin
	if(rst)begin
		for(int i = 0; i < 32; i++)
			REGISTER[i]<=0;
	end
	else begin
		if(RegWrite && WB_rd_addr!=5'b0) begin
			if(opcode==7'b0000011)begin
				case(funct3)
					3'b010: REGISTER[WB_rd_addr] <= WB_rd_data;//LW
					3'b000: REGISTER[WB_rd_addr]<={{24{WB_rd_data[7]}}, WB_rd_data[7:0]}; //LB
			        3'b001: REGISTER[WB_rd_addr]<={{16{WB_rd_data[15]}}, WB_rd_data[15:0]}; //LH
			        3'b100: REGISTER[WB_rd_addr]<={24'h0, WB_rd_data[7:0]}; //LBU
			        default: REGISTER[WB_rd_addr]<={16'h0, WB_rd_data[15:0]}; //LHU 101
			    endcase
		    end
		    else 
		    	REGISTER[WB_rd_addr] <= WB_rd_data;
		end
	end

end

assign	RS1Data = REGISTER[rs1_addr];
assign	RS2Data = REGISTER[rs2_addr];


endmodule