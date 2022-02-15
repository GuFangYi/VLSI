module MUX_3_1(
	input [31:0] in_1,
	input [31:0] in_2,
	input [31:0] in_3,
	input [1:0] ctrl,
	output reg [31:0] out
);

always_comb begin
	case(ctrl)
		2'b00:	out = in_1;
		2'b01:  out = in_2;
		default:out = in_3; //PC_4
	endcase
end

endmodule