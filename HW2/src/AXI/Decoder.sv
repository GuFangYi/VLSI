`include "../../include/AXI_define.svh"

//AXI interconnect -> Slave

module Decoder(
	input VALID,
	input [`AXI_ADDR_BITS-1:0] ADDR,
	output logic VALID_S0,
	output logic VALID_S1,
	output logic VALID_DEFAULT,

	input READY_S0,
	input READY_S1,
	input READY_DEFAULT,
	output logic READY
);

logic [2:0] VALID_TMP;
assign {VALID_DEFAULT, VALID_S1, VALID_S0} = VALID_TMP;

always_comb begin
	case(ADDR[`AXI_ADDR_BITS-1:`AXI_ADDR_HBITS])
		16'h0000:begin
			VALID_TMP = {2'b00, VALID};
			READY = VALID? READY_S0 : 1'b1;
		end
		16'h0001:begin
			VALID_TMP = {1'b0, VALID, 1'b0};
			READY = VALID? READY_S1 : 1'b1;
		end
		default:begin //16'h0002
			VALID_TMP = {VALID, 2'b0};
			READY = VALID? READY_DEFAULT : 1'b1;
		end
	endcase


end

/* 
Slave Address:
Slave 1: 0x0000_0000~0x0000_ffff
Slave 2: 0x0001_0000~0x0001_ffff
Default: 0x0002_0000~0xffff_ffff
*/

endmodule