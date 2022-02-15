`include "../include/AXI_define.svh"
`include "./CPU.sv"
`include "./Master.sv"

module CPU_wrapper(
	input clk,
	input rst,

	//SLAVE INTERFACE FOR MASTERS
	//WRITE ADDRESS0
	output logic [`AXI_ID_BITS-1:0] AWID_M0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0,
	output logic [1:0] AWBURST_M0,
	output logic AWVALID_M0,
	input AWREADY_M0,
	//WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] WDATA_M0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M0,
	output logic WLAST_M0,
	output logic WVALID_M0,
	input WREADY_M0,
	//WRITE RESPONSE0
	input [`AXI_ID_BITS-1:0] BID_M0,
	input [1:0] BRESP_M0,
	input BVALID_M0,
	output logic BREADY_M0,
	//WRITE ADDRESS1
	output logic [`AXI_ID_BITS-1:0] AWID_M1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	output logic [1:0] AWBURST_M1,
	output logic AWVALID_M1,
	input AWREADY_M1,
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
	output logic WLAST_M1,
	output logic WVALID_M1,
	input WREADY_M1,
	//WRITE RESPONSE1
	input [`AXI_ID_BITS-1:0] BID_M1,
	input [1:0] BRESP_M1,
	input BVALID_M1,
	output logic BREADY_M1,

	//READ ADDRESS0
	output logic [`AXI_ID_BITS-1:0] ARID_M0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	output logic [1:0] ARBURST_M0,
	output logic ARVALID_M0,
	input ARREADY_M0,
	//READ DATA0
	input [`AXI_ID_BITS-1:0] RID_M0,
	input [`AXI_DATA_BITS-1:0] RDATA_M0,
	input [1:0] RRESP_M0,
	input RLAST_M0,
	input RVALID_M0,
	output logic RREADY_M0,
	//READ ADDRESS1
	output logic [`AXI_ID_BITS-1:0] ARID_M1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	output logic [1:0] ARBURST_M1,
	output logic ARVALID_M1,
	input ARREADY_M1,
	//READ DATA1
	input [`AXI_ID_BITS-1:0] RID_M1,
	input [`AXI_DATA_BITS-1:0] RDATA_M1,
	input [1:0] RRESP_M1,
	input RLAST_M1,
	input RVALID_M1,
	output logic RREADY_M1

);

logic [`AXI_DATA_BITS-1:0] instr_out;
logic instr_read;
logic [`AXI_ADDR_BITS-1:0] instr_addr;

logic [`AXI_DATA_BITS-1:0] data_out;
logic data_read;
logic data_write;
logic [3:0] write_type;
logic [`AXI_ADDR_BITS-1:0] data_addr;
logic [`AXI_DATA_BITS-1:0] dataIn;

logic IM_STALL, DM_STALL;
logic LOCK_DM;

//for solving infinite STALLs from IM and DM
always_ff@(posedge clk or negedge rst)begin
	if(~rst) begin
		LOCK_DM <= 1'b0;
	end
	else begin
		LOCK_DM <= IM_STALL?  ~DM_STALL : 1'b0;
	end
end

CPU CPU(
	.clk (clk),
	.rst (~rst),

	.instr (instr_out),
	.instr_read (instr_read),
	.instr_addr (instr_addr),
	.data_out (data_out),
	.data_read (data_read),
	.data_write (data_write),
	.write_type (write_type),
	.data_addr (data_addr),
	.dataIn (dataIn),
	.stalls ({IM_STALL, DM_STALL})

);

Master M0(
	.ACLK (clk),
	.ARESETn (rst),
	.read (instr_read),
	.write (1'b0),
	.write_type (4'hF),
	.addr_in (instr_addr),
	.data_in (`AXI_DATA_BITS'b0),
	.data_out (instr_out),
	.stall (IM_STALL),

	.AWID(AWID_M0),
	.AWADDR(AWADDR_M0),
	.AWLEN(AWLEN_M0),
	.AWSIZE(AWSIZE_M0),
	.AWBURST(AWBURST_M0),
	.AWVALID(AWVALID_M0),
	.AWREADY(AWREADY_M0),

	//WRITE DATA
	.WDATA(WDATA_M0),
	.WSTRB(WSTRB_M0),
	.WLAST(WLAST_M0),
	.WVALID(WVALID_M0),
	.WREADY(WREADY_M0),
	//WRITE RESPONSE
	.BID(BID_M0),
	.BRESP(BRESP_M0),
	.BVALID(BVALID_M0),
	.BREADY(BREADY_M0),
	//READ ADDRESS
	.ARID(ARID_M0),
	.ARADDR(ARADDR_M0),
	.ARLEN(ARLEN_M0),
	.ARSIZE(ARSIZE_M0),
	.ARBURST(ARBURST_M0),
	.ARVALID(ARVALID_M0),
	.ARREADY(ARREADY_M0),
	//READ DATA
	.RID(RID_M0),
	.RDATA(RDATA_M0),
	.RRESP(RRESP_M0),
	.RLAST(RLAST_M0),
	.RVALID(RVALID_M0),
	.RREADY(RREADY_M0)	
);
Master M1(
	.ACLK (clk),
	.ARESETn (rst),
	.read (data_read & ~LOCK_DM),
	.write (data_write & ~LOCK_DM),
	.write_type (write_type),
	.addr_in (data_addr),
	.data_in (dataIn),
	.data_out (data_out),
	.stall (DM_STALL),

	.AWID(AWID_M1),
	.AWADDR(AWADDR_M1),
	.AWLEN(AWLEN_M1),
	.AWSIZE(AWSIZE_M1),
	.AWBURST(AWBURST_M1),
	.AWVALID(AWVALID_M1),
	.AWREADY(AWREADY_M1),

	//WRITE DATA
	.WDATA(WDATA_M1),
	.WSTRB(WSTRB_M1),
	.WLAST(WLAST_M1),
	.WVALID(WVALID_M1),
	.WREADY(WREADY_M1),
	//WRITE RESPONSE
	.BID(BID_M1),
	.BRESP(BRESP_M1),
	.BVALID(BVALID_M1),
	.BREADY(BREADY_M1),
	//READ ADDRESS
	.ARID(ARID_M1),
	.ARADDR(ARADDR_M1),
	.ARLEN(ARLEN_M1),
	.ARSIZE(ARSIZE_M1),
	.ARBURST(ARBURST_M1),
	.ARVALID(ARVALID_M1),
	.ARREADY(ARREADY_M1),
	//READ DATA
	.RID(RID_M1),
	.RDATA(RDATA_M1),
	.RRESP(RRESP_M1),
	.RLAST(RLAST_M1),
	.RVALID(RVALID_M1),
	.RREADY(RREADY_M1)	
);

endmodule