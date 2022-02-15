module Forward_Unit(
	input [4:0] EX_rs1_addr,
	input [4:0] EX_rs2_addr,
	input [4:0] MEM_rd_addr,
	input [4:0] WB_rd_addr,
	input MEM_RegWrite,
	input RegWrite,
	//input WB_MEMRead,
	//input [3:0] MemWrite,
	output reg [1:0] ForwardRS1Src,
	output reg [1:0] ForwardRS2Src
	//output reg ForwardRDSrc
);

always_comb begin
	if(MEM_rd_addr == EX_rs1_addr && MEM_rd_addr != 5'b0 && MEM_RegWrite)
		ForwardRS1Src = 2'b01;
	else if(WB_rd_addr == EX_rs1_addr && WB_rd_addr != 5'b0 && RegWrite)
        ForwardRS1Src = 2'b10;
    else 
    	ForwardRS1Src = 2'b00;

    if(MEM_rd_addr == EX_rs2_addr && MEM_rd_addr != 5'b0 && MEM_RegWrite)
		ForwardRS2Src = 2'b01;
	else if(WB_rd_addr == EX_rs2_addr && WB_rd_addr != 5'b0 && RegWrite)
        ForwardRS2Src = 2'b10;
    else 
    	ForwardRS2Src = 2'b00;
end

//lw-sw
/*always_comb begin
	if(MemWrite && MB_MEMRead)
		ForwardRDSrc = 1'b1;
    else
    	ForwardRDSrc = 1'b0;
	
end
*/

endmodule