`include "../../include/AXI_define.svh"

module R(
	input ACLK,
	input ARESETn,
	//slave 
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_IDS_BITS-1:0] RID_DEFAULT,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_DEFAULT,
	input [1:0] RRESP_S0,
	input [1:0] RRESP_S1,
	input [1:0] RRESP_DEFAULT,
	input RLAST_S0,
	input RLAST_S1,
	input RLAST_DEFAULT,
	input RVALID_S0,
	input RVALID_S1,
	input RVALID_DEFAULT,
	output logic RREADY_S0,
	output logic RREADY_S1,
    output logic RREADY_DEFAULT,
	//master
	input RREADY_M0,
	input RREADY_M1,
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M0,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M0,
	output logic RLAST_M1,
	output logic RVALID_M0,
	output logic RVALID_M1
);

//for RLAST in accordance with RVALID
logic LOCK_S0;
logic LOCK_S1;
logic LOCK_DEFAULT;

logic [`AXI_ID_BITS-1:0] ID;
logic [`AXI_DATA_BITS-1:0] DATA;
logic [1:0] RESP;
logic LAST;
logic VALID;
logic READY;

assign RID_M0 = ID;
assign RDATA_M0 = DATA;
assign RRESP_M0 = RESP;
assign RLAST_M0 = LAST;

assign RID_M1 = ID;
assign RDATA_M1 = DATA;
assign RRESP_M1 = RESP;
assign RLAST_M1 = LAST;

logic [`AXI_SLAVE_BITS-1:0] SLAVE;
logic [`AXI_MASTER_BITS-1:0] MASTER;


always_ff@(posedge ACLK	or negedge ARESETn)begin
	if(~ARESETn)begin
		LOCK_S0 <= 1'b0;
		LOCK_S1 <= 1'b0;
		LOCK_DEFAULT <= 1'b0;
	end 
	else begin
		LOCK_S0 <= (READY & RLAST_S0)? 1'b0 : (RVALID_S0 & ~RVALID_S1 & ~RVALID_DEFAULT)? 1'b1: LOCK_S0;
		LOCK_S1 <= (READY & RLAST_S1)? 1'b0 : (RVALID_S1 & ~RVALID_DEFAULT & ~LOCK_S0)? 1'b1: LOCK_S1;
		LOCK_DEFAULT <= (READY & RLAST_DEFAULT)? 1'b0 : (RVALID_DEFAULT & ~LOCK_S0 & ~LOCK_S1)? 1'b1: LOCK_DEFAULT;
	end
end
assign SLAVE = (LOCK_DEFAULT | (RVALID_DEFAULT & ~LOCK_S0 & ~LOCK_S1))? `AXI_SLAVE_DEFAULT : (LOCK_S1 | (RVALID_S1 & ~LOCK_S0))? `AXI_SLAVE_1 : (LOCK_S0 | RVALID_S0)? `AXI_SLAVE_0 : `AXI_SLAVE_BITS'b0;
/*
assign SLAVE = RVALID_DEFAULT? `AXI_SLAVE_DEFAULT : (RVALID_S1? `AXI_SLAVE_1 : (RVALID_S0? `AXI_SLAVE_0: 3'b0));
*/

always_comb begin

	case(SLAVE)
		`AXI_SLAVE_0:begin
			MASTER = RID_S0[`AXI_IDS_BITS-1:`AXI_ID_BITS];
			ID = RID_S0[`AXI_ID_BITS-1:0];
			DATA = RDATA_S0;
			RESP = RRESP_S0;
			LAST = RLAST_S0;
			VALID = RVALID_S0;
			{RREADY_DEFAULT, RREADY_S1, RREADY_S0} = {2'b00, READY&RVALID_S0};			
		end
		`AXI_SLAVE_1:begin
			MASTER = RID_S1[`AXI_IDS_BITS-1:`AXI_ID_BITS];
			ID = RID_S1[`AXI_ID_BITS-1:0];
			DATA = RDATA_S1;
			RESP = RRESP_S1;
			LAST = RLAST_S1;
			VALID = RVALID_S1;
			{RREADY_DEFAULT, RREADY_S1, RREADY_S0} = {1'b0, READY&RVALID_S1, 1'b0};			
		end
		`AXI_SLAVE_DEFAULT:begin
			MASTER = RID_DEFAULT[`AXI_IDS_BITS-1:`AXI_ID_BITS];
			ID = RID_DEFAULT[`AXI_ID_BITS-1:0];
			DATA = RDATA_DEFAULT;
			RESP = RRESP_DEFAULT;
			LAST = RLAST_DEFAULT;
			VALID = RVALID_DEFAULT;
			{RREADY_DEFAULT, RREADY_S1, RREADY_S0} = {READY&RVALID_DEFAULT, 2'b00};			
		end
		default:begin
			MASTER = `AXI_MASTER_BITS'b0;
			ID = `AXI_ID_BITS'b0;
			DATA = `AXI_DATA_BITS'b0;
			RESP = 2'b0;
			LAST = 1'b0;
			VALID = 1'b0;
			{RREADY_DEFAULT, RREADY_S1, RREADY_S0} = 3'b000;	
		end
	endcase
end

always_comb begin
	case(MASTER)
		`AXI_MASTER_0:begin
			READY = RREADY_M0;
			{RVALID_M1, RVALID_M0} = {1'b0, VALID};
		end
		`AXI_MASTER_1:begin
			READY = RREADY_M1;
			{RVALID_M1, RVALID_M0} = {VALID, 1'b0};
		end
		default:begin
			READY = 1'b1;
			{RVALID_M1, RVALID_M0} = 2'b00;
		end
	endcase
end

endmodule
