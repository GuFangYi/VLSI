`include "../../include/AXI_define.svh"

//determine M0, M1 to Slave
module Arbiter(
	input ACLK,
	input ARESETn,

	//slave 
	output logic [`AXI_IDS_BITS-1:0] ID,
	output logic [`AXI_ADDR_BITS-1:0] ADDR,
	output logic [`AXI_SIZE_BITS-1:0] SIZE,
	output logic [`AXI_LEN_BITS-1:0] LEN,
	output logic [1:0] BURST,
	output logic VALID,
	input READY,

	//master0, 1
	output logic READY_M0,
	output logic READY_M1,
	input [`AXI_ID_BITS-1:0] ID_M0,
	input [`AXI_ID_BITS-1:0] ID_M1,
	input [`AXI_ADDR_BITS-1:0] ADDR_M0,
	input [`AXI_ADDR_BITS-1:0] ADDR_M1,
	input [`AXI_SIZE_BITS-1:0] SIZE_M0,
	input [`AXI_SIZE_BITS-1:0] SIZE_M1,
	input [`AXI_LEN_BITS-1:0] LEN_M0,
	input [`AXI_LEN_BITS-1:0] LEN_M1,
	input [1:0] BURST_M0,
	input [1:0] BURST_M1,
	input VALID_M0,
	input VALID_M1
);

logic LOCK_M0;
logic LOCK_M1;
logic [`AXI_MASTER_BITS-1:0] MASTER;

//add 12/27
always_ff @(posedge ACLK or negedge ARESETn) begin : proc_
	if(~ARESETn) begin
		 LOCK_M0 <= 1'b0;
		 LOCK_M1 <= 1'b0;
	end else begin
		 LOCK_M0 <= (LOCK_M0 & READY)? 1'b0:(~VALID_M1 & VALID_M0 & ~READY);
		 LOCK_M0 <= (LOCK_M1 & READY)? 1'b0:(VALID_M1 & ~LOCK_M0 & ~READY);
	end
end

/*always_ff@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn) MASTER <= `AXI_MASTER_BITS'b0;
	else begin
		case(MASTER)
			`AXI_MASTER_DEFAULT: MASTER <= VALID_M1? `AXI_MASTER_1 : (VALID_M0? `AXI_MASTER_0: `AXI_MASTER_DEFAULT);
			`AXI_MASTER_0: MASTER <= READY? `AXI_MASTER_DEFAULT: `AXI_MASTER_0;
			`AXI_MASTER_1: MASTER <= READY? `AXI_MASTER_DEFAULT: `AXI_MASTER_1;
			default: MASTER <= `AXI_MASTER_BITS'b0;
		endcase
	end
end
*/
always_comb begin
	if((VALID_M1 & ~LOCK_M0) | LOCK_M1) MASTER = `AXI_MASTER_1;
	else if (VALID_M0 | LOCK_M0) MASTER = `AXI_MASTER_0;
	else MASTER = `AXI_MASTER_DEFAULT;

end
always_comb begin
	case(MASTER)
		`AXI_MASTER_1:begin
			ID = {`AXI_MASTER_1, ID_M1};
			ADDR = ADDR_M1;
			LEN = LEN_M1;
			SIZE = SIZE_M1;
			BURST = BURST_M1;
			VALID = VALID_M1;
			READY_M0 = 1'b0;
			READY_M1 = VALID_M1 & READY;
		end
		`AXI_MASTER_0:begin
			ID = {`AXI_MASTER_0, ID_M0};
			ADDR = ADDR_M0;
			LEN = LEN_M0;
			SIZE = SIZE_M0;
			BURST = BURST_M0;
			VALID = VALID_M0;
			READY_M1 = 1'b0;
			READY_M0 = VALID_M0 & READY;
		end
		default:begin
			ID = `AXI_IDS_BITS'b0;
			ADDR = `AXI_ADDR_BITS'b0;
			LEN = `AXI_LEN_BITS'b0;
			SIZE = `AXI_SIZE_BITS'b0;
			BURST = 2'b0;
			VALID = 1'b0;
			READY_M0 = 1'b0;
			READY_M1 = 1'b0;
		end
	endcase
end


endmodule