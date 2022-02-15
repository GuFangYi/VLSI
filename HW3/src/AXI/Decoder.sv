`include "../../include/AXI_define.svh"

//AXI interconnect -> Slave

module Decoder(
	input VALID,
	input [`AXI_ADDR_BITS-1:0] ADDR,
	output logic VALID_S0,
	output logic VALID_S1,
	output logic VALID_S2,
	output logic VALID_S4,
	output logic VALID_DEFAULT,

	input READY_S0,
	input READY_S1,
	input READY_S2,
	input READY_S4,
	input READY_DEFAULT,
	output logic READY
);

logic [4:0] VALID_TMP;
assign {VALID_DEFAULT, VALID_S4, VALID_S2, VALID_S1, VALID_S0} = VALID_TMP;

always_comb begin
	case(ADDR[`AXI_ADDR_BITS-1:`AXI_ADDR_HBITS])
		16'h0000:begin
			VALID_TMP = {4'b00, VALID};
			READY = VALID? READY_S0 : 1'b1;
		end
		16'h0001:begin
			VALID_TMP = {3'b0, VALID, 1'b0};
			READY = VALID? READY_S1 : 1'b1;
		end
		16'h0002:begin
			VALID_TMP = {2'b0, VALID, 2'b0};
			READY = VALID? READY_S2 : 1'b1;
		end
		16'h2000:begin 
			VALID_TMP = {1'b0, VALID, 3'b0};
			READY = VALID? READY_S4 : 1'b1;
		end
		default:begin
			VALID_TMP = {VALID, 4'b0};
			READY = VALID? READY_DEFAULT: 1'b1;
		end
	endcase


end

/* 
Slave Address:
Slave 0: 0x0000_0000~0x0000_ffff
Slave 1: 0x0001_0000~0x0001_ffff
Slave 2: 0x0002_0000~0x0002_ffff
Slave 4: 0x2000_0000~0x201f_ffff
*/

endmodule