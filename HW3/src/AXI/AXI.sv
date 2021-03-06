//================================================
// Auther:      Chen Tsung-Chi (Michael)           
// Filename:    AXI.sv                            
// Description: Top module of AXI                  
// Version:     1.0 
//================================================
`include "../../include/AXI_define.svh"
`include "AW.sv"
`include "AR.sv"
`include "R.sv"
`include "W.sv"
`include "B.sv"
`include "Slave.sv"

module AXI(

	input ACLK,
	input ARESETn,

	//SLAVE INTERFACE FOR MASTERS
	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output AWREADY_M1,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output WREADY_M1,
	//WRITE RESPONSE
	output [`AXI_ID_BITS-1:0] BID_M1,
	output [1:0] BRESP_M1,
	output BVALID_M1,
	input BREADY_M1,

	//READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output ARREADY_M0,
	//READ DATA0
	output [`AXI_ID_BITS-1:0] RID_M0,
	output [`AXI_DATA_BITS-1:0] RDATA_M0,
	output [1:0] RRESP_M0,
	output RLAST_M0,
	output RVALID_M0,
	input RREADY_M0,
	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output ARREADY_M1,
	//READ DATA1
	output [`AXI_ID_BITS-1:0] RID_M1,
	output [`AXI_DATA_BITS-1:0] RDATA_M1,
	output [1:0] RRESP_M1,
	output RLAST_M1,
	output RVALID_M1,
	input RREADY_M1,

	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS0
	output [`AXI_IDS_BITS-1:0] AWID_S0,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output [1:0] AWBURST_S0,
	output AWVALID_S0,
	input AWREADY_S0,
	//WRITE DATA0
	output [`AXI_DATA_BITS-1:0] WDATA_S0,
	output [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output WLAST_S0,
	output WVALID_S0,
	input WREADY_S0,
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output BREADY_S0,
	
	//WRITE ADDRESS1
	output [`AXI_IDS_BITS-1:0] AWID_S1,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output [1:0] AWBURST_S1,
	output AWVALID_S1,
	input AWREADY_S1,
	//WRITE DATA1
	output [`AXI_DATA_BITS-1:0] WDATA_S1,
	output [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output WLAST_S1,
	output WVALID_S1,
	input WREADY_S1,
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output BREADY_S1,

    //WRITE ADDRESS2
    output [`AXI_IDS_BITS-1:0] AWID_S2,
    output [`AXI_ADDR_BITS-1:0] AWADDR_S2,
    output [`AXI_LEN_BITS-1:0] AWLEN_S2,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
    output [1:0] AWBURST_S2,
    output AWVALID_S2,
    input AWREADY_S2,
    //WRITE DATA2
    output [`AXI_DATA_BITS-1:0] WDATA_S2,
    output [`AXI_STRB_BITS-1:0] WSTRB_S2,
    output WLAST_S2,
    output WVALID_S2,
    input WREADY_S2,
    //WRITE RESPONSE2
    input [`AXI_IDS_BITS-1:0] BID_S2,
    input [1:0] BRESP_S2,
    input BVALID_S2,
    output BREADY_S2,

    //WRITE ADDRESS3
    output [`AXI_IDS_BITS-1:0] AWID_S4,
    output [`AXI_ADDR_BITS-1:0] AWADDR_S4,
    output [`AXI_LEN_BITS-1:0] AWLEN_S4,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
    output [1:0] AWBURST_S4,
    output AWVALID_S4,
    input AWREADY_S4,
    //WRITE DATA1
    output [`AXI_DATA_BITS-1:0] WDATA_S4,
    output [`AXI_STRB_BITS-1:0] WSTRB_S4,
    output WLAST_S4,
    output WVALID_S4,
    input WREADY_S4,
    //WRITE RESPONSE3
    input [`AXI_IDS_BITS-1:0] BID_S4,
    input [1:0] BRESP_S4,
    input BVALID_S4,
    output BREADY_S4,

	
	//READ ADDRESS0
	output [`AXI_IDS_BITS-1:0] ARID_S0,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output [1:0] ARBURST_S0,
	output ARVALID_S0,
	input ARREADY_S0,
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output RREADY_S0,
	//READ ADDRESS1
	output [`AXI_IDS_BITS-1:0] ARID_S1,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output [1:0] ARBURST_S1,
	output ARVALID_S1,
	input ARREADY_S1,
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output RREADY_S1,
	//READ ADDRESS2
    output [`AXI_IDS_BITS-1:0] ARID_S2,
    output [`AXI_ADDR_BITS-1:0] ARADDR_S2,
    output [`AXI_LEN_BITS-1:0] ARLEN_S2,
    output [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
    output [1:0] ARBURST_S2,
    output ARVALID_S2,
    input ARREADY_S2,
    //READ DATA2
    input [`AXI_IDS_BITS-1:0] RID_S2,
    input [`AXI_DATA_BITS-1:0] RDATA_S2,
    input [1:0] RRESP_S2,
    input RLAST_S2,
    input RVALID_S2,
    output RREADY_S2,

    //READ ADDRESS3
    output [`AXI_IDS_BITS-1:0] ARID_S4,
    output [`AXI_ADDR_BITS-1:0] ARADDR_S4,
    output [`AXI_LEN_BITS-1:0] ARLEN_S4,
    output [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
    output [1:0] ARBURST_S4,
    output ARVALID_S4,
    input ARREADY_S4,
    //READ DATA2
    input [`AXI_IDS_BITS-1:0] RID_S4,
    input [`AXI_DATA_BITS-1:0] RDATA_S4,
    input [1:0] RRESP_S4,
    input RLAST_S4,
    input RVALID_S4,
    output RREADY_S4
	
);
    //---------- you should put your design here ----------//
// DEFAULT SLAVE WIRES
//Address read M->S
logic [`AXI_IDS_BITS-1:0] ARID_DEFAULT;
logic [`AXI_ADDR_BITS-1:0] ARADDR_DEFAULT;
logic [`AXI_LEN_BITS-1:0] ARLEN_DEFAULT;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_DEFAULT;
logic [1:0] ARBURST_DEFAULT;
logic ARVALID_DEFAULT;
//Address read S->M
logic ARREADY_DEFAULT;

//Data read M->S
logic [`AXI_IDS_BITS-1:0] RID_DEFAULT;
logic [`AXI_DATA_BITS-1:0] RDATA_DEFAULT;
logic [1:0] RRESP_DEFAULT;
logic RVALID_DEFAULT;
logic RLAST_DEFAULT;
//Data read S->M
logic RREADY_DEFAULT;

//Address write M->S
logic [`AXI_IDS_BITS-1:0] AWID_DEFAULT;
logic [`AXI_ADDR_BITS-1:0] AWADDR_DEFAULT;
logic [`AXI_LEN_BITS-1:0] AWLEN_DEFAULT;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_DEFAULT;
logic [1:0] AWBURST_DEFAULT;
logic AWVALID_DEFAULT;
//Address write S->M
logic AWREADY_DEFAULT;

//Data write M->S
logic [`AXI_STRB_BITS-1:0] WSTRB_DEFAULT;
logic [`AXI_DATA_BITS-1:0] WDATA_DEFAULT;
logic WVALID_DEFAULT;
logic WLAST_DEFAULT;
//Data read S->M
logic WREADY_DEFAULT;

//Data write response S->M
logic [`AXI_IDS_BITS-1:0] BID_DEFAULT;
logic [1:0] BRESP_DEFAULT;
logic BVALID_DEFAULT;
//Data write response M->S
logic BREADY_DEFAULT;

AR AR(
	.ACLK (ACLK),
	.ARESETn (ARESETn),
	//Slave out
	.ARID_S0 (ARID_S0),
	.ARID_S1 (ARID_S1),
	.ARID_S2 (ARID_S2),
	.ARID_S4 (ARID_S4),
	.ARID_DEFAULT (ARID_DEFAULT),
	.ARADDR_S0 (ARADDR_S0),
	.ARADDR_S1 (ARADDR_S1),
	.ARADDR_S2 (ARADDR_S2),
	.ARADDR_S4 (ARADDR_S4),
	.ARADDR_DEFAULT (ARADDR_DEFAULT),
	.ARSIZE_S0 (ARSIZE_S0),
	.ARSIZE_S1 (ARSIZE_S1),
	.ARSIZE_S2 (ARSIZE_S2),
	.ARSIZE_S4 (ARSIZE_S4),
	.ARSIZE_DEFAULT (ARSIZE_DEFAULT),
	.ARLEN_S0 (ARLEN_S0),
	.ARLEN_S1 (ARLEN_S1),
	.ARLEN_S2 (ARLEN_S2),
	.ARLEN_S4 (ARLEN_S4),
	.ARLEN_DEFAULT (ARLEN_DEFAULT),
	.ARBURST_S0 (ARBURST_S0),
	.ARBURST_S1 (ARBURST_S1),
	.ARBURST_S2 (ARBURST_S2),
	.ARBURST_S4 (ARBURST_S4),
	.ARBURST_DEFAULT (ARBURST_DEFAULT),
	.ARVALID_S0 (ARVALID_S0),
	.ARVALID_S1 (ARVALID_S1),
	.ARVALID_S2 (ARVALID_S2),
	.ARVALID_S4 (ARVALID_S4),
	.ARVALID_DEFAULT (ARVALID_DEFAULT),
	//in
	.ARREADY_S0 (ARREADY_S0),
	.ARREADY_S1 (ARREADY_S1),
	.ARREADY_S2 (ARREADY_S2),
	.ARREADY_S4 (ARREADY_S4),
	.ARREADY_DEFAULT (ARREADY_DEFAULT),

	//Master out
	.ARREADY_M0 (ARREADY_M0),
	.ARREADY_M1 (ARREADY_M1),
	//in
	.ARID_M0 (ARID_M0),
	.ARID_M1 (ARID_M1),
	.ARADDR_M0 (ARADDR_M0),
	.ARADDR_M1 (ARADDR_M1),
	.ARSIZE_M0 (ARSIZE_M0),
	.ARSIZE_M1 (ARSIZE_M1),
	.ARLEN_M0 (ARLEN_M0),
	.ARLEN_M1 (ARLEN_M1),
	.ARBURST_M0 (ARBURST_M0),
	.ARBURST_M1 (ARBURST_M1),
	.ARVALID_M0 (ARVALID_M0),
	.ARVALID_M1 (ARVALID_M1)
);	

R R(
	.ACLK (ACLK),
	.ARESETn (ARESETn),
	//Slave in
	.RID_S0 (RID_S0),
	.RID_S1 (RID_S1),
	.RID_S2 (RID_S2),
	.RID_S4 (RID_S4),
	.RID_DEFAULT (RID_DEFAULT),
	.RDATA_S0 (RDATA_S0),
	.RDATA_S1 (RDATA_S1),
	.RDATA_S2 (RDATA_S2),
	.RDATA_S4 (RDATA_S4),
	.RDATA_DEFAULT (RDATA_DEFAULT),
	.RRESP_S0 (RRESP_S0),
	.RRESP_S1 (RRESP_S1),
	.RRESP_S2 (RRESP_S2),
	.RRESP_S4 (RRESP_S4),
	.RRESP_DEFAULT (RRESP_DEFAULT),
	.RLAST_S0 (RLAST_S0),
	.RLAST_S1 (RLAST_S1),
	.RLAST_S2 (RLAST_S2),
	.RLAST_S4 (RLAST_S4),
	.RLAST_DEFAULT (RLAST_DEFAULT),
	.RVALID_S0 (RVALID_S0),
	.RVALID_S1 (RVALID_S1),
	.RVALID_S2 (RVALID_S2),
	.RVALID_S4 (RVALID_S4),
	.RVALID_DEFAULT (RVALID_DEFAULT),
	//out
	.RREADY_S0 (RREADY_S0),
	.RREADY_S1 (RREADY_S1),
	.RREADY_S2 (RREADY_S2),
	.RREADY_S4 (RREADY_S4),
	.RREADY_DEFAULT (RREADY_DEFAULT),

	//Master in
	.RREADY_M0 (RREADY_M0),
	.RREADY_M1 (RREADY_M1),
	//out
	.RID_M0 (RID_M0),
	.RID_M1 (RID_M1),
	.RDATA_M0 (RDATA_M0),
	.RDATA_M1 (RDATA_M1),
	.RRESP_M0 (RRESP_M0),
	.RRESP_M1 (RRESP_M1),
	.RLAST_M0 (RLAST_M0),
	.RLAST_M1 (RLAST_M1),
	.RVALID_M0 (RVALID_M0),
	.RVALID_M1 (RVALID_M1)
);

AW AW(
	.ACLK (ACLK),
	.ARESETn (ARESETn),
	//Slave out
	.AWID_S0 (AWID_S0),
	.AWID_S1 (AWID_S1),
	.AWID_S2 (AWID_S2),
	.AWID_S4 (AWID_S4),
	.AWID_DEFAULT (AWID_DEFAULT),
	.AWADDR_S0 (AWADDR_S0),
	.AWADDR_S1 (AWADDR_S1),
	.AWADDR_S2 (AWADDR_S2),
	.AWADDR_S4 (AWADDR_S4),
	.AWADDR_DEFAULT (AWADDR_DEFAULT),
	.AWSIZE_S0 (AWSIZE_S0),
	.AWSIZE_S1 (AWSIZE_S1),
	.AWSIZE_S2 (AWSIZE_S2),
	.AWSIZE_S4 (AWSIZE_S4),
	.AWSIZE_DEFAULT (AWSIZE_DEFAULT),
	.AWLEN_S0 (AWLEN_S0),
	.AWLEN_S1 (AWLEN_S1),
	.AWLEN_S2 (AWLEN_S2),
	.AWLEN_S4 (AWLEN_S4),
	.AWLEN_DEFAULT (AWLEN_DEFAULT),
	.AWBURST_S0 (AWBURST_S0),
	.AWBURST_S1 (AWBURST_S1),
	.AWBURST_S2 (AWBURST_S2),
	.AWBURST_S4 (AWBURST_S4),
	.AWBURST_DEFAULT (AWBURST_DEFAULT),
	.AWVALID_S0 (AWVALID_S0),
	.AWVALID_S1 (AWVALID_S1),
	.AWVALID_S2 (AWVALID_S2),
	.AWVALID_S4 (AWVALID_S4),
	.AWVALID_DEFAULT (AWVALID_DEFAULT),
	//in
	.AWREADY_S0 (AWREADY_S0),
	.AWREADY_S1 (AWREADY_S1),
	.AWREADY_S2 (AWREADY_S2),
	.AWREADY_S4 (AWREADY_S4),
	.AWREADY_DEFAULT (AWREADY_DEFAULT),

	//Master out
	.AWREADY_M1 (AWREADY_M1),
	//in
	.AWID_M1 (AWID_M1),
	.AWADDR_M1 (AWADDR_M1),
	.AWSIZE_M1 (AWSIZE_M1),
	.AWLEN_M1 (AWLEN_M1),
	.AWBURST_M1 (AWBURST_M1),
	.AWVALID_M1 (AWVALID_M1)
);	

W W(
	.ACLK (ACLK),
	.ARESETn (ARESETn),
	//Slave out
	.WDATA_S0 (WDATA_S0),
	.WDATA_S1 (WDATA_S1),
	.WDATA_S2 (WDATA_S2),
	.WDATA_S4 (WDATA_S4),
	.WDATA_DEFAULT (WDATA_DEFAULT),
	.WSTRB_S0 (WSTRB_S0),
	.WSTRB_S1 (WSTRB_S1),
	.WSTRB_S2 (WSTRB_S2),
	.WSTRB_S4 (WSTRB_S4),
	.WSTRB_DEFAULT (WSTRB_DEFAULT),
	.WLAST_S0 (WLAST_S0),
	.WLAST_S1 (WLAST_S1),
	.WLAST_S2 (WLAST_S2),	
	.WLAST_S4 (WLAST_S4),
	.WLAST_DEFAULT (WLAST_DEFAULT),
	.WVALID_S0 (WVALID_S0),
	.WVALID_S1 (WVALID_S1),
	.WVALID_S2 (WVALID_S2),
	.WVALID_S4 (WVALID_S4),
	.WVALID_DEFAULT (WVALID_DEFAULT),
	.AWVALID_S0 (AWVALID_S0),
	.AWVALID_S1 (AWVALID_S1),
	.AWVALID_S2 (AWVALID_S2),
	.AWVALID_S4 (AWVALID_S4),
	.AWVALID_DEFAULT (AWVALID_DEFAULT),
	//in
	.WREADY_S0 (WREADY_S0),
	.WREADY_S1 (WREADY_S1),
	.WREADY_S2 (WREADY_S2),
	.WREADY_S4 (WREADY_S4),
	.WREADY_DEFAULT (WREADY_DEFAULT),

	//Master out
	.WREADY_M1 (WREADY_M1),
	//in
	.WDATA_M1 (WDATA_M1),
	.WSTRB_M1 (WSTRB_M1),
	.WLAST_M1 (WLAST_M1),
	.WVALID_M1 (WVALID_M1)
);

B B(
	.ACLK (ACLK),
	.ARESETn (ARESETn),
	//Slave in
	.BID_S0 (BID_S0),
	.BID_S1 (BID_S1),
	.BID_S2 (BID_S2),
	.BID_S4 (BID_S4),
	.BID_DEFAULT (BID_DEFAULT),
	.BRESP_S0 (BRESP_S0),
	.BRESP_S1 (BRESP_S1),
	.BRESP_S2 (BRESP_S2),
	.BRESP_S4 (BRESP_S4),
	.BRESP_DEFAULT (BRESP_DEFAULT),
	.BVALID_S0 (BVALID_S0),
	.BVALID_S1 (BVALID_S1),
	.BVALID_S2 (BVALID_S2),
	.BVALID_S4 (BVALID_S4),
	.BVALID_DEFAULT (BVALID_DEFAULT),
	//out
	.BREADY_S0 (BREADY_S0),
	.BREADY_S1 (BREADY_S1),
	.BREADY_S2 (BREADY_S2),
	.BREADY_S4 (BREADY_S4),
	.BREADY_DEFAULT (BREADY_DEFAULT),
	//Master in 
	.BREADY_M1 (BREADY_M1),
	//out
	.BID_M1 (BID_M1),
	.BRESP_M1 (BRESP_M1),
	.BVALID_M1 (BVALID_M1)
);
	
Slave Default_Slave(
	.ACLK (ACLK),
	.ARESETn (ARESETn),
	.ARID_DEFAULT (ARID_DEFAULT),
	.ARADDR_DEFAULT (ARADDR_DEFAULT),
	.ARLEN_DEFAULT (ARLEN_DEFAULT),
	.ARSIZE_DEFAULT (ARSIZE_DEFAULT),
	.ARBURST_DEFAULT (ARBURST_DEFAULT),
	.ARVALID_DEFAULT (ARVALID_DEFAULT),
	.ARREADY_DEFAULT (ARREADY_DEFAULT),

	.RID_DEFAULT (RID_DEFAULT),
	.RDATA_DEFAULT (RDATA_DEFAULT),
	.RRESP_DEFAULT (RRESP_DEFAULT),
	.RLAST_DEFAULT (RLAST_DEFAULT),
	.RVALID_DEFAULT (RVALID_DEFAULT),
	.RREADY_DEFAULT (RREADY_DEFAULT),

	.AWID_DEFAULT (AWID_DEFAULT),
	.AWADDR_DEFAULT (AWADDR_DEFAULT),
	.AWLEN_DEFAULT (AWLEN_DEFAULT),
	.AWSIZE_DEFAULT (AWSIZE_DEFAULT),
	.AWBURST_DEFAULT (AWBURST_DEFAULT),
	.AWVALID_DEFAULT (AWVALID_DEFAULT),
	.AWREADY_DEFAULT (AWREADY_DEFAULT),

	.WSTRB_DEFAULT (WSTRB_DEFAULT),
	.WDATA_DEFAULT (WDATA_DEFAULT),
	.WLAST_DEFAULT (WLAST_DEFAULT),
	.WVALID_DEFAULT (WVALID_DEFAULT),
	.WREADY_DEFAULT (WREADY_DEFAULT),

	.BID_DEFAULT (BID_DEFAULT),
	.BRESP_DEFAULT (BRESP_DEFAULT),
	.BVALID_DEFAULT (BVALID_DEFAULT),
	.BREADY_DEFAULT (BREADY_DEFAULT)
);


endmodule
