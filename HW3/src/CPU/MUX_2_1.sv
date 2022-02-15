module MUX_2_1(
	input [31:0] in_1,
	input [31:0] in_2,
	input ctrl,
	output reg [31:0] out
);

always_comb begin
	if(ctrl) out = in_1;
	else 	 out = in_2;
end

endmodule