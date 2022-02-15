`include "../../include/AXI_define.svh"

module W(
	input ACLK,
	input ARESETn,
	//slave 
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
	output logic [`AXI_DATA_BITS-1:0] WDATA_DEFAULT,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_DEFAULT,
	output logic WLAST_S0,
	output logic WLAST_S1,
	output logic WLAST_S2,
	output logic WLAST_S4,
	output logic WLAST_DEFAULT,
	output logic WVALID_S0,
	output logic WVALID_S1,
	output logic WVALID_S2,
	output logic WVALID_S4,
	output logic WVALID_DEFAULT,
	input WREADY_S0,
	input WREADY_S1,
	input WREADY_S2,
	input WREADY_S4,
    input WREADY_DEFAULT,
    input AWVALID_S0,
    input AWVALID_S1,
    input AWVALID_S2,
    input AWVALID_S4,
    input AWVALID_DEFAULT,
	//master (DM)
	output logic WREADY_M1,
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1
);

logic VALID_S0_TMP;
logic VALID_S1_TMP;
logic VALID_S2_TMP;
logic VALID_S4_TMP;
logic VALID_DEFAULT_TMP;

logic [`AXI_DATA_BITS-1:0] DATA;
logic [`AXI_STRB_BITS-1:0] STRB;
logic VALID;
logic LAST;
logic READY;
logic [`AXI_SLAVE_BITS-1:0] SLAVE;

assign DATA = WDATA_M1;
assign STRB = WSTRB_M1;
assign LAST = WLAST_M1;
assign VALID = WVALID_M1;
assign WREADY_M1 = READY & VALID;

assign WDATA_S0 = DATA;
assign WSTRB_S0 = WVALID_S0 ? STRB : `AXI_STRB_BITS'hF; 
assign WLAST_S0 = LAST;
assign WDATA_S1 = DATA;
assign WSTRB_S1 = WVALID_S1 ? STRB : `AXI_STRB_BITS'hF; 
assign WLAST_S1 = LAST;
assign WDATA_S2 = DATA;
assign WSTRB_S2 = WVALID_S2 ? STRB : `AXI_STRB_BITS'hF; 
assign WLAST_S2 = LAST;
assign WDATA_S4 = DATA;
assign WSTRB_S4 = WVALID_S4 ? STRB : `AXI_STRB_BITS'hF; 
assign WLAST_S4 = LAST;
assign WDATA_DEFAULT = DATA;
assign WSTRB_DEFAULT = STRB; 
assign WLAST_DEFAULT = LAST;

assign SLAVE = {(VALID_DEFAULT_TMP | AWVALID_DEFAULT), (VALID_S4_TMP | AWVALID_S4), (VALID_S2_TMP | AWVALID_S2), (VALID_S1_TMP | AWVALID_S1), (VALID_S0_TMP | AWVALID_S0)};

always_ff@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn)begin
		VALID_S0_TMP <= 1'b0;
		VALID_S1_TMP <= 1'b0;
		VALID_S2_TMP <= 1'b0;
		VALID_S4_TMP <= 1'b0;
		VALID_DEFAULT_TMP <= 1'b0;
	end
	else begin
		VALID_S0_TMP <= AWVALID_S0 ? 1'b1 : ((VALID & READY & LAST)? 1'b0 : VALID_S0_TMP);
		VALID_S1_TMP <= AWVALID_S1 ? 1'b1 : ((VALID & READY & LAST)? 1'b0 : VALID_S1_TMP);
		VALID_S2_TMP <= AWVALID_S2 ? 1'b1 : ((VALID & READY & LAST)? 1'b0 : VALID_S2_TMP);
		VALID_S4_TMP <= AWVALID_S4 ? 1'b1 : ((VALID & READY & LAST)? 1'b0 : VALID_S4_TMP);
		VALID_DEFAULT_TMP <= AWVALID_DEFAULT ? 1'b1 : ((VALID & READY & LAST)? 1'b0 : VALID_DEFAULT_TMP);
	end
end
logic [`AXI_SLAVE_BITS-1:0] WVALID_TMP;
assign {WVALID_DEFAULT, WVALID_S4, WVALID_S2, WVALID_S1, WVALID_S0} = WVALID_TMP;
always_comb begin
	case(SLAVE)
		`AXI_SLAVE_0:begin
			READY = WREADY_S0;
			WVALID_TMP = {4'b00, VALID};
		end
		`AXI_SLAVE_1:begin
			READY = WREADY_S1;
			WVALID_TMP = {3'b0, VALID, 1'b0};
		end
		`AXI_SLAVE_2:begin
			READY = WREADY_S2;
			WVALID_TMP = {2'b0, VALID, 2'b0};
		end
		`AXI_SLAVE_4:begin
			READY = WREADY_S4;
			WVALID_TMP = {1'b0, VALID, 3'b0};
		end
		`AXI_SLAVE_DEFAULT:begin
			READY = WREADY_DEFAULT;
			WVALID_TMP = {VALID, 4'b0};
		end
		default:begin
			READY = 1'b1;
			WVALID_TMP = `AXI_SLAVE_BITS'b0;
		end
	endcase
end


endmodule