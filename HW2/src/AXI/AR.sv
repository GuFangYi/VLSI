`include "../../include/AXI_define.svh"
//`include "Arbiter.sv"
//`include "Decoder.sv"
/*
Read address channel
	M: ARADDR/ARVALID->			 
	S: 					ARREADY->

*/
module AR(

	input ACLK,
	input ARESETn,
	//slave 
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_IDS_BITS-1:0] ARID_DEFAULT,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_DEFAULT,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_DEFAULT,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_DEFAULT,
	output logic [1:0] ARBURST_S0,
	output logic [1:0] ARBURST_S1,
	output logic [1:0] ARBURST_DEFAULT,
	output logic ARVALID_S0,
	output logic ARVALID_S1,
	output logic ARVALID_DEFAULT,
	input ARREADY_S0,
	input ARREADY_S1,
    input ARREADY_DEFAULT,
	//master
	output logic ARREADY_M0,
	output logic ARREADY_M1,
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [1:0] ARBURST_M0,
	input [1:0] ARBURST_M1,
	input ARVALID_M0,
	input ARVALID_M1

);

logic BUSY_S0;
logic BUSY_S1;
logic BUSY_DEFAULT;
logic READY_S0_TMP;
logic READY_S1_TMP;
logic READY_DEFAULT_TMP;
logic VALID_S0_TMP;
logic VALID_S1_TMP;
logic VALID_DEFAULT_TMP;

assign BUSY_S0 = READY_S0_TMP & ~ARREADY_S0;
assign BUSY_S1 = READY_S1_TMP & ~ARREADY_S1;
assign BUSY_DEFAULT = READY_DEFAULT_TMP & ~ARREADY_DEFAULT;

assign ARVALID_S0 = BUSY_S0 ? 1'b0 : VALID_S0_TMP;
assign ARVALID_S1 = BUSY_S1 ? 1'b0 : VALID_S1_TMP;
assign ARVALID_DEFAULT = BUSY_DEFAULT ? 1'b0 : VALID_DEFAULT_TMP;

always_ff@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		READY_S0_TMP <= 1'b0;
		READY_S1_TMP <= 1'b0;
		READY_DEFAULT_TMP <= 1'b0;
	end
	else begin
		READY_S0_TMP <= ARREADY_S0 ? 1'b1 : READY_S0_TMP;
		READY_S1_TMP <= ARREADY_S1 ? 1'b1 : READY_S1_TMP;
		READY_DEFAULT_TMP <= ARREADY_DEFAULT ? 1'b1 : READY_DEFAULT_TMP;
	end
end

logic [`AXI_IDS_BITS-1:0] ID;
logic [`AXI_ADDR_BITS-1:0] ADDR;
logic [`AXI_SIZE_BITS-1:0] SIZE;
logic [`AXI_LEN_BITS-1:0] LEN;
logic [1:0] BURST;
logic VALID;
logic READY;

assign ARID_S0 = ID;
assign ARADDR_S0 = ADDR;
assign ARLEN_S0 = LEN;
assign ARSIZE_S0 = SIZE;
assign ARBURST_S0 = BURST;

assign ARID_S1 = ID;
assign ARADDR_S1 = ADDR;
assign ARLEN_S1 = LEN;
assign ARSIZE_S1 = SIZE;
assign ARBURST_S1 = BURST;

assign ARID_DEFAULT = ID;
assign ARADDR_DEFAULT = ADDR;
assign ARLEN_DEFAULT = LEN;
assign ARSIZE_DEFAULT = SIZE;
assign ARBURST_DEFAULT = BURST;

Arbiter AR_Arbiter(
	.ACLK (ACLK),
	.ARESETn (ARESETn),
	
	.ID (ID),
	.ADDR (ADDR),
	.SIZE (SIZE),
	.LEN (LEN),
	.BURST (BURST),
	.VALID (VALID),
	.READY (READY),

	.READY_M0 (ARREADY_M0),
	.READY_M1 (ARREADY_M1),
	.ID_M0 (ARID_M0),
	.ID_M1 (ARID_M1),
	.ADDR_M0 (ARADDR_M0),
	.ADDR_M1 (ARADDR_M1),
	.SIZE_M0 (ARSIZE_M0),
	.SIZE_M1 (ARSIZE_M1),
	.LEN_M0 (ARLEN_M0),
	.LEN_M1 (ARLEN_M1),
	.BURST_M0 (ARBURST_M0),
	.BURST_M1 (ARBURST_M1),
	.VALID_M0 (ARVALID_M0),
	.VALID_M1 (ARVALID_M1)
);

Decoder AR_Decoder(
	.VALID (VALID),
	.ADDR (ADDR),
	.VALID_S0 (VALID_S0_TMP),
	.VALID_S1 (VALID_S1_TMP),
	.VALID_DEFAULT (VALID_DEFAULT_TMP),

	.READY_S0 (ARREADY_S0),
	.READY_S1 (ARREADY_S1),
	.READY_DEFAULT (ARREADY_DEFAULT),
	.READY (READY)
);

endmodule