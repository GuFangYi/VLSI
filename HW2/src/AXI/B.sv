`include "../../include/AXI_define.svh"

module B(
	input ACLK,
	input ARESETn,
	//slave 
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [`AXI_IDS_BITS-1:0] BID_DEFAULT,
	input [1:0] BRESP_S0,
	input [1:0] BRESP_S1,
	input [1:0] BRESP_DEFAULT,
	input BVALID_S0,
	input BVALID_S1,
	input BVALID_DEFAULT,
	output logic BREADY_S0,
	output logic BREADY_S1,
    output logic BREADY_DEFAULT,
	//master (DM)
	input BREADY_M1,
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1
);

logic VALID;
logic READY;


logic [`AXI_SLAVE_BITS-1:0] SLAVE;
logic [`AXI_MASTER_BITS-1:0] MASTER;

assign SLAVE = BVALID_DEFAULT? `AXI_SLAVE_DEFAULT : (BVALID_S1? `AXI_SLAVE_1 : (BVALID_S0? `AXI_SLAVE_0: 3'b0));

always_comb begin
	
	case(SLAVE)
		`AXI_SLAVE_0:begin
			MASTER = BID_S0[`AXI_IDS_BITS-1:`AXI_ID_BITS];
			BID_M1 = BID_S0[`AXI_ID_BITS-1:0];		
			BRESP_M1 = BRESP_S0;
			VALID = BVALID_S0;
			{BREADY_DEFAULT, BREADY_S1, BREADY_S0} = {2'b00, READY&BVALID_S0};			
		end
		`AXI_SLAVE_1:begin
			MASTER = BID_S1[`AXI_IDS_BITS-1:`AXI_ID_BITS];
			BID_M1 = BID_S1[`AXI_ID_BITS-1:0];
			BRESP_M1 = BRESP_S1;
			VALID = BVALID_S1;
			{BREADY_DEFAULT, BREADY_S1, BREADY_S0} = {1'b0, READY&BVALID_S1, 1'b0};			
		end
		`AXI_SLAVE_DEFAULT:begin
			MASTER = BID_DEFAULT[`AXI_IDS_BITS-1:`AXI_ID_BITS];
			BID_M1 = BID_DEFAULT[`AXI_ID_BITS-1:0];
			BRESP_M1 = BRESP_DEFAULT;
			VALID = BVALID_DEFAULT;
			{BREADY_DEFAULT, BREADY_S1, BREADY_S0} = {READY&BVALID_DEFAULT, 2'b00};			
		end
		default:begin
			MASTER = `AXI_MASTER_BITS'b0;
			BID_M1 = `AXI_ID_BITS'b0;
			BRESP_M1 = 2'b0;
			VALID = 1'b0;
			{BREADY_DEFAULT, BREADY_S1, BREADY_S0} = 3'b000;	
		end
	endcase
end

always_comb begin
	case(MASTER)
		`AXI_MASTER_1:begin
			READY = BREADY_M1;
			BVALID_M1 = VALID;
		end
		default:begin
			READY = 1'b1;
			BVALID_M1 = 1'b0;
		end
	endcase
end


endmodule