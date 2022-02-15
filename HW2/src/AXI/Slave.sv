`include "../../include/AXI_define.svh"

module Slave(
	input ACLK,
	input ARESETn,

	//Address read M->S
	input [`AXI_IDS_BITS-1:0] ARID_DEFAULT,
	input [`AXI_ADDR_BITS-1:0] ARADDR_DEFAULT,
	input [`AXI_LEN_BITS-1:0] ARLEN_DEFAULT,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_DEFAULT,
	input [1:0] ARBURST_DEFAULT,
	input ARVALID_DEFAULT,
	//Address read S->M
	output logic ARREADY_DEFAULT,

	//Data read M->S
	output logic [`AXI_IDS_BITS-1:0] RID_DEFAULT,
	output logic [`AXI_DATA_BITS-1:0] RDATA_DEFAULT,
	output logic [1:0] RRESP_DEFAULT,
	output logic RVALID_DEFAULT,
	output logic RLAST_DEFAULT,
	//Data read S->M
	input RREADY_DEFAULT,

	//Address write M->S
	input [`AXI_IDS_BITS-1:0] AWID_DEFAULT,
	input [`AXI_ADDR_BITS-1:0] AWADDR_DEFAULT,
	input [`AXI_LEN_BITS-1:0] AWLEN_DEFAULT,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_DEFAULT,
	input [1:0] AWBURST_DEFAULT,
	input AWVALID_DEFAULT,
	//Address write S->M
	output logic AWREADY_DEFAULT,

	//Data write M->S
	input [`AXI_STRB_BITS-1:0] WSTRB_DEFAULT,
	input [`AXI_DATA_BITS-1:0] WDATA_DEFAULT,
	input WVALID_DEFAULT,
	input WLAST_DEFAULT,
	//Data read S->M
	output logic WREADY_DEFAULT,

	//Data write response S->M
	output logic [`AXI_IDS_BITS-1:0] BID_DEFAULT,
	output logic [1:0] BRESP_DEFAULT,
	output logic BVALID_DEFAULT,
	//Data write response M->S
	input BREADY_DEFAULT
);

logic [1:0] CURRENT, NEXT;
logic [`AXI_LEN_BITS-1:0] ARLEN_TMP;

parameter [1:0] A = 2'b00, 	//read address
				R = 2'b01,	//read data
				W = 2'b10,	//write data
				B = 2'b11;	//write response

always_ff@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)
		CURRENT <= A;
	else
		CURRENT <= NEXT;
end

always_ff @(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		RID_DEFAULT <= `AXI_IDS_BITS'b0;
		BID_DEFAULT <= `AXI_IDS_BITS'b0;
		RLAST_DEFAULT <= 1'b1;
		ARLEN_TMP <= `AXI_LEN_BITS'b0;
	end
	else begin
		//The slave must ensure that the RID value of any returned data matches the ARID value of the address to which it is responding.
		RID_DEFAULT <= (ARREADY_DEFAULT & ARVALID_DEFAULT)? ARID_DEFAULT : RID_DEFAULT;
		BID_DEFAULT <= (AWREADY_DEFAULT & AWVALID_DEFAULT)? AWID_DEFAULT : BID_DEFAULT;	
		ARLEN_TMP <= (ARREADY_DEFAULT & ARVALID_DEFAULT)? ARLEN_DEFAULT : ARLEN_TMP;	

		if(ARREADY_DEFAULT & ARVALID_DEFAULT)
			RLAST_DEFAULT <= (ARLEN_DEFAULT != `AXI_LEN_BITS'b1);
		else if(RREADY_DEFAULT & RVALID_DEFAULT) begin
			if(ARLEN_TMP == `AXI_LEN_BITS'b1 & ~RLAST_DEFAULT)
				RLAST_DEFAULT <= 1'b1;
		end
	end
end

assign ARREADY_DEFAULT = (CURRENT == A);
assign AWREADY_DEFAULT = (AWVALID_DEFAULT & (CURRENT== A));

assign RDATA_DEFAULT = `AXI_DATA_BITS'b0;
assign RRESP_DEFAULT = `AXI_RESP_DECERR;
assign RVALID_DEFAULT = (CURRENT == R);

assign WREADY_DEFAULT = (WVALID_DEFAULT & (CURRENT == W));
assign BRESP_DEFAULT = `AXI_RESP_DECERR;
assign BVALID_DEFAULT = (CURRENT == B); 

always_comb begin
	case(CURRENT)
		A:		 NEXT = (ARREADY_DEFAULT & ARVALID_DEFAULT)? R : ((AWREADY_DEFAULT & AWVALID_DEFAULT)? W : A);
		R:		 NEXT = (RREADY_DEFAULT & RVALID_DEFAULT)? A : R;
		W:		 NEXT = (WREADY_DEFAULT & WVALID_DEFAULT & WLAST_DEFAULT)? B : W;	
		default: NEXT = (BREADY_DEFAULT & BVALID_DEFAULT)? A : B;
	endcase
end


endmodule