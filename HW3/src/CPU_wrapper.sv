`include "../include/AXI_define.svh"
`include "CPU.sv"
`include "./Master.sv"
`include "../include/def.svh"
`include "L1C_inst.sv"
`include "L1C_data.sv"

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

logic [`CACHE_TYPE_BITS-1:0] core_type;
logic [`DATA_BITS-1:0] I_out;
logic I_wait;
logic I_req;
logic [`DATA_BITS-1:0] I_addr;
logic I_write;
logic [`DATA_BITS-1:0] I_in;
logic [`CACHE_TYPE_BITS-1:0] I_type;

logic [`DATA_BITS-1:0] D_out;
logic D_wait;
logic D_req;
logic [`DATA_BITS-1:0] D_addr;
logic D_write;
logic [`DATA_BITS-1:0] D_in;
logic [`CACHE_TYPE_BITS-1:0] D_type;

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
	.stalls ({IM_STALL, DM_STALL}),
	.core_type (core_type)

);

Master M0(
	.ACLK (clk),
	.ARESETn (rst),
	.read (/*instr_read*/ I_req & ~I_write),
	.write (1'b0),
	.write_type (/*4'hF*/ 3'b0),//check
	.addr_in (/*instr_addr*/I_addr),
	.data_in (/*`AXI_DATA_BITS'b0*/ I_in),
	.data_out (/*instr_out*/ I_out),
	.stall (/*IM_STALL*/I_wait),

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
	.read (/*data_read & ~LOCK_DM*/ D_req & ~D_write),
	.write (/*data_write & ~LOCK_DM*/ D_req & D_write),
	.write_type (/*write_type*/ D_type),
	.addr_in (/*data_addr*/ D_addr),
	.data_in (/*dataIn*/ D_in),
	.data_out (/*data_out*/ D_out),
	.stall (/*DM_STALL*/ D_wait),

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
L1C_inst L1CI(
    .clk(clk),
    .rst(~rst),
    // input from CPU
    .core_addr(instr_addr),
    .core_req(instr_read),
    .core_write(1'b0),
    .core_in(`DATA_BITS'b0),
    .core_type(`CACHE_WORD),
    // input from CPU wrapper(AXI, SRAM), need to fix
    .I_out(I_out),
    .I_wait(I_wait),
    // output to CPU
    .core_out(instr_out),
    .core_wait(IM_STALL),
    // output to CPU wrapper
    .I_req(I_req),
    .I_addr(I_addr),
    .I_write(I_write),
    .I_in(I_in),
    .I_type(I_type)
);
L1C_data L1CD(
    .clk(clk),
    .rst(~rst),
    // input from CPU
    .core_addr(data_addr),
    .core_req((data_read | data_write) & ~LOCK_DM),
    .core_write(data_write),
    .core_in(dataIn),
    .core_type(core_type), // need to fix, wait for CPU
    // input from CPU wrapper(AXI ,SRAM)
    .D_out(D_out),
    .D_wait(D_wait),
    // output to CPU
    .core_out(data_out),
    .core_wait(DM_STALL),
    // output to CPU wrapper(AXI, SRAM)
    .D_req(D_req),
    .D_addr(D_addr),
    .D_write(D_write),
    .D_in(D_in),
    .D_type(D_type)
    );
endmodule