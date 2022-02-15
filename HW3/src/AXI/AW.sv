`include "../../include/AXI_define.svh"
`include "Arbiter.sv"
`include "Decoder.sv"
module AW(
    input ACLK,
    input ARESETn,
    //SLAVE INTERFACE FOR MASTER_1 (DM)
    //WRITE ADDRESS
    input [`AXI_ID_BITS-1:0] AWID_M1,
    input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    input [`AXI_LEN_BITS-1:0] AWLEN_M1,
    input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
    input [1:0] AWBURST_M1,
    input AWVALID_M1,
    output AWREADY_M1,
    //MASTER INTERFACE FOR SLAVES
    //WRITE ADDRESS0
    output [`AXI_IDS_BITS-1:0] AWID_S0,
    output [`AXI_IDS_BITS-1:0] AWID_S1,
    output [`AXI_IDS_BITS-1:0] AWID_S2,
    output [`AXI_IDS_BITS-1:0] AWID_S4,
    output [`AXI_IDS_BITS-1:0] AWID_DEFAULT,
    output [`AXI_ADDR_BITS-1:0] AWADDR_S0,
    output [`AXI_ADDR_BITS-1:0] AWADDR_S1,
    output [`AXI_ADDR_BITS-1:0] AWADDR_S2,
    output [`AXI_ADDR_BITS-1:0] AWADDR_S4,
    output [`AXI_ADDR_BITS-1:0] AWADDR_DEFAULT,
    output [`AXI_LEN_BITS-1:0] AWLEN_S0,
    output [`AXI_LEN_BITS-1:0] AWLEN_S1,
    output [`AXI_LEN_BITS-1:0] AWLEN_S2,
    output [`AXI_LEN_BITS-1:0] AWLEN_S4,
    output [`AXI_LEN_BITS-1:0] AWLEN_DEFAULT,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
    output [`AXI_SIZE_BITS-1:0] AWSIZE_DEFAULT,
    output [1:0] AWBURST_S0,
    output [1:0] AWBURST_S1,
    output [1:0] AWBURST_S2,
    output [1:0] AWBURST_S4,
    output [1:0] AWBURST_DEFAULT,
    output AWVALID_S0,
    output AWVALID_S1,
    output AWVALID_S2,
    output AWVALID_S4,
    output AWVALID_DEFAULT,
    input AWREADY_S0,
    input AWREADY_S1,
    input AWREADY_S2,
    input AWREADY_S4,
    input AWREADY_DEFAULT
);

logic [`AXI_IDS_BITS-1:0] ID;
logic [`AXI_ADDR_BITS-1:0] ADDR;
logic [`AXI_SIZE_BITS-1:0] SIZE;
logic [`AXI_LEN_BITS-1:0] LEN;
logic [1:0] BURST;
logic VALID;
logic READY;

assign AWID_S0 = ID;
assign AWADDR_S0 = ADDR;
assign AWLEN_S0 = LEN;
assign AWSIZE_S0 = SIZE;
assign AWBURST_S0 = BURST;

assign AWID_S1 = ID;
assign AWADDR_S1 = ADDR;
assign AWLEN_S1 = LEN;
assign AWSIZE_S1 = SIZE;
assign AWBURST_S1 = BURST;

assign AWID_S2 = ID;
assign AWADDR_S2 = ADDR;
assign AWLEN_S2 = LEN;
assign AWSIZE_S2 = SIZE;
assign AWBURST_S2 = BURST;

assign AWID_S4 = ID;
assign AWADDR_S4 = ADDR;
assign AWLEN_S4 = LEN;
assign AWSIZE_S4 = SIZE;
assign AWBURST_S4 = BURST;

assign AWID_DEFAULT = ID;
assign AWADDR_DEFAULT = ADDR;
assign AWLEN_DEFAULT = LEN;
assign AWSIZE_DEFAULT = SIZE;
assign AWBURST_DEFAULT = BURST;

logic AWREADY_M0_BUF;//DUMMY

Arbiter AW_Arbiter(
    .ACLK (ACLK),
    .ARESETn (ARESETn),
    //o
    .ID (ID),
    .ADDR (ADDR),
    .SIZE (SIZE),
    .LEN (LEN),
    .BURST (BURST),
    .VALID (VALID),
    //i
    .READY (READY),

    //o
    .READY_M0 (AWREADY_M0_BUF),
    .READY_M1 (AWREADY_M1),
    //i
    .ID_M0 (`AXI_ID_BITS'b0),
    .ID_M1 (AWID_M1),
    .ADDR_M0 (`AXI_ADDR_BITS'b0),
    .ADDR_M1 (AWADDR_M1),
    .SIZE_M0 (`AXI_SIZE_BITS'b0),
    .SIZE_M1 (AWSIZE_M1),
    .LEN_M0 (`AXI_LEN_BITS'b0),
    .LEN_M1 (AWLEN_M1),
    .BURST_M0 (2'b0),
    .BURST_M1 (AWBURST_M1),
    .VALID_M0 (1'b0),
    .VALID_M1 (AWVALID_M1)
);

Decoder AW_Decoder(
    //i
    .VALID (VALID),
    .ADDR (ADDR),
    //o
    .VALID_S0 (AWVALID_S0),
    .VALID_S1 (AWVALID_S1),
    .VALID_S2 (AWVALID_S2),
    .VALID_S4 (AWVALID_S4),
    .VALID_DEFAULT (AWVALID_DEFAULT),
    //i
    .READY_S0 (AWREADY_S0),
    .READY_S1 (AWREADY_S1),
    .READY_S2 (AWREADY_S2),
    .READY_S4 (AWREADY_S4),
    .READY_DEFAULT (AWREADY_DEFAULT),
    //o
    .READY (READY)
);


endmodule