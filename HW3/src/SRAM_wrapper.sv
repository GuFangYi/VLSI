`include "../include/AXI_define.svh"
module SRAM_wrapper (
    input clk,
    input rst,

    // WRITE ADDRESS
    input [`AXI_IDS_BITS-1:0] AWID,
    input [`AXI_ADDR_BITS-1:0] AWADDR,
    input [`AXI_LEN_BITS-1:0] AWLEN,
    input [`AXI_SIZE_BITS-1:0] AWSIZE,
    input [1:0] AWBURST,
    input AWVALID,
    output logic AWREADY,
    // WRITE DATA
    input [`AXI_DATA_BITS-1:0] WDATA,
    input [`AXI_STRB_BITS-1:0] WSTRB,
    input WLAST,
    input WVALID,
    output logic WREADY,
    // WRITE RESPONSE
    output logic [`AXI_IDS_BITS-1:0] BID,
    output logic [1:0] BRESP,
    output logic BVALID,
    input BREADY,

    // READ ADDRESS
    input [`AXI_IDS_BITS-1:0] ARID,
    input [`AXI_ADDR_BITS-1:0] ARADDR,
    input [`AXI_LEN_BITS-1:0] ARLEN,
    input [`AXI_SIZE_BITS-1:0] ARSIZE,
    input [1:0] ARBURST,
    input ARVALID,
    output logic ARREADY,
    // READ DATA
    output logic [`AXI_IDS_BITS-1:0] RID,
    output logic [`AXI_DATA_BITS-1:0] RDATA,
    output logic [1:0] RRESP,
    output logic RLAST,
    output logic RVALID,
    input RREADY

);
    
logic [13:0] A;
logic [`AXI_DATA_BITS-1:0] DI;
logic [`AXI_DATA_BITS-1:0] DO;
logic [`AXI_STRB_BITS-1:0] WEB;
logic CS;
logic OE;

parameter [1:0] ADDR = 2'b00,
                R    = 2'b01,
                W    = 2'b10,
                B    = 2'b11;



logic [1:0] CURRENT;
logic [1:0] NEXT; 

logic AW_DONE;
logic W_DONE;
logic B_DONE;
logic R_DONE;
logic AR_DONE;

logic [`AXI_LEN_BITS-1:0] COUNT;
logic [`AXI_IDS_BITS-1:0] ARID_TMP, AWID_TMP;
logic [`AXI_LEN_BITS-1:0] ARLEN_TMP, AWLEN_TMP;
logic RVALID_TMP;
logic [`AXI_DATA_BITS-1:0] RDATA_TMP;
logic [13:0] RADDR_TMP, WADDR_TMP;

assign AW_DONE = AWVALID & AWREADY;
assign W_DONE = WVALID & WREADY;
assign B_DONE = BVALID & BREADY;
assign AR_DONE = ARVALID & ARREADY;
assign R_DONE = RVALID & RREADY;

assign RLAST = (ARLEN_TMP == COUNT);
// assign RDATA = (RVALID & RVALID_TMP)? RDATA_TMP : DO;
assign RDATA = DO; //change: for outputing same value (e.g., 93 all the time)

assign RRESP = `AXI_RESP_OKAY;
assign BRESP = `AXI_RESP_OKAY;
assign RID = ARID_TMP; 
assign BID = AWID_TMP;

assign DI = WDATA;
assign WEB = WSTRB;
//assign CS = (CURRENT == B)? 1'b0 : (CURRENT == ADDR)? (AWVALID | ARVALID) : 1'b1;
assign CS = (CURRENT == ADDR)? (AWVALID | ARVALID) : 1'b1;

always_ff@(posedge clk or negedge rst)begin
    if(~rst)
        CURRENT <= ADDR;
    else 
        CURRENT <= NEXT;
end

always_comb begin
    case(CURRENT)
        ADDR:      NEXT = (AW_DONE & W_DONE)? B : (AW_DONE? W : (AR_DONE? R : ADDR));
        R:         NEXT = (R_DONE & RLAST & AW_DONE)? W : ((R_DONE & RLAST & AR_DONE)? R : ((R_DONE & RLAST)? ADDR : R));
        W:         NEXT = (W_DONE & WLAST) ? B : W;
        default:   NEXT = (B_DONE & AW_DONE)? W : ((B_DONE &AR_DONE)? R : (B_DONE? ADDR :B));
    endcase
end

// change add 20211227
logic [1:0] A_OFFSET;
always_comb begin
    if(COUNT[1:0]==2'b0)begin // every four data 0000, 0100, 1000, 1100
        if(R_DONE) A_OFFSET = COUNT[1:0]+2'b1;
        else A_OFFSET = COUNT[1:0];
    end
    else A_OFFSET = COUNT[1:0]+2'b1;
end

always_comb begin
    case(CURRENT)
        ADDR: begin
            A = AW_DONE? AWADDR[15:2] : ARADDR[15:2];
            AWREADY = 1'b1;
            ARREADY = ~AWVALID;
            OE = ~AWVALID & AR_DONE;
        end
        R: begin
            // A = RADDR_TMP;
            A = RADDR_TMP + A_OFFSET;
            AWREADY = R_DONE;
            ARREADY = R_DONE & ~AWVALID;
            OE = 1'b1;
        end
        W: begin
            A = WADDR_TMP;
            AWREADY = 1'b0;
            ARREADY = 1'b0;
            OE = 1'b0;

        end
        default: begin
            A = B_DONE? (AW_DONE? AWADDR[15:2] : ARADDR[15:2]) : WADDR_TMP;
            AWREADY = B_DONE;
            ARREADY = B_DONE & ~AWVALID;
            OE = 1'b0;
        end
    endcase
end

assign RVALID = (CURRENT == R);
assign BVALID = (CURRENT == B);
assign WREADY = (CURRENT == W);

always_ff@(posedge clk or negedge rst)begin
    if(~rst) begin
        ARID_TMP <= `AXI_IDS_BITS'b0;
        AWID_TMP <= `AXI_IDS_BITS'b0;

        ARLEN_TMP <= `AXI_LEN_BITS'b0;
        AWLEN_TMP <= `AXI_LEN_BITS'b0;
        COUNT <= `AXI_LEN_BITS'b0;

        RVALID_TMP <= 1'b0;
        RDATA_TMP <= `AXI_DATA_BITS'b0;

        RADDR_TMP <= 14'b0;
        WADDR_TMP <= 14'b0;
    end
    else begin
        ARID_TMP <= AR_DONE? ARID : ARID_TMP;
        AWID_TMP <= AW_DONE? AWID : AWID_TMP;

        ARLEN_TMP <= AR_DONE? ARLEN : ARLEN_TMP;
        AWLEN_TMP <= AW_DONE? AWLEN : AWLEN_TMP;
        if(CURRENT == R)        COUNT <= (R_DONE & RLAST)? `AXI_LEN_BITS'b0 : R_DONE? (COUNT + `AXI_LEN_BITS'b1) : COUNT;
        else if (CURRENT == W)  COUNT <= (W_DONE & WLAST)? `AXI_LEN_BITS'b0 : W_DONE? (COUNT + `AXI_LEN_BITS'b1) : COUNT;

        RVALID_TMP <= RVALID;
        RDATA_TMP <= (RVALID & ~ RVALID_TMP)? DO : RDATA_TMP;

        RADDR_TMP <= AR_DONE? ARADDR[15:2] : RADDR_TMP;
        WADDR_TMP <= AW_DONE? AWADDR[15:2] : WADDR_TMP;
    end
end

SRAM i_SRAM (
    .A0   (A[0]  ),
    .A1   (A[1]  ),
    .A2   (A[2]  ),
    .A3   (A[3]  ),
    .A4   (A[4]  ),
    .A5   (A[5]  ),
    .A6   (A[6]  ),
    .A7   (A[7]  ),
    .A8   (A[8]  ),
    .A9   (A[9]  ),
    .A10  (A[10] ),
    .A11  (A[11] ),
    .A12  (A[12] ),
    .A13  (A[13] ),
    .DO0  (DO[0] ),
    .DO1  (DO[1] ),
    .DO2  (DO[2] ),
    .DO3  (DO[3] ),
    .DO4  (DO[4] ),
    .DO5  (DO[5] ),
    .DO6  (DO[6] ),
    .DO7  (DO[7] ),
    .DO8  (DO[8] ),
    .DO9  (DO[9] ),
    .DO10 (DO[10]),
    .DO11 (DO[11]),
    .DO12 (DO[12]),
    .DO13 (DO[13]),
    .DO14 (DO[14]),
    .DO15 (DO[15]),
    .DO16 (DO[16]),
    .DO17 (DO[17]),
    .DO18 (DO[18]),
    .DO19 (DO[19]),
    .DO20 (DO[20]),
    .DO21 (DO[21]),
    .DO22 (DO[22]),
    .DO23 (DO[23]),
    .DO24 (DO[24]),
    .DO25 (DO[25]),
    .DO26 (DO[26]),
    .DO27 (DO[27]),
    .DO28 (DO[28]),
    .DO29 (DO[29]),
    .DO30 (DO[30]),
    .DO31 (DO[31]),
    .DI0  (DI[0] ),
    .DI1  (DI[1] ),
    .DI2  (DI[2] ),
    .DI3  (DI[3] ),
    .DI4  (DI[4] ),
    .DI5  (DI[5] ),
    .DI6  (DI[6] ),
    .DI7  (DI[7] ),
    .DI8  (DI[8] ),
    .DI9  (DI[9] ),
    .DI10 (DI[10]),
    .DI11 (DI[11]),
    .DI12 (DI[12]),
    .DI13 (DI[13]),
    .DI14 (DI[14]),
    .DI15 (DI[15]),
    .DI16 (DI[16]),
    .DI17 (DI[17]),
    .DI18 (DI[18]),
    .DI19 (DI[19]),
    .DI20 (DI[20]),
    .DI21 (DI[21]),
    .DI22 (DI[22]),
    .DI23 (DI[23]),
    .DI24 (DI[24]),
    .DI25 (DI[25]),
    .DI26 (DI[26]),
    .DI27 (DI[27]),
    .DI28 (DI[28]),
    .DI29 (DI[29]),
    .DI30 (DI[30]),
    .DI31 (DI[31]),
    .CK   (clk   ),
    .WEB0 (WEB[0]),
    .WEB1 (WEB[1]),
    .WEB2 (WEB[2]),
    .WEB3 (WEB[3]),
    .OE   (OE    ),
    .CS   (CS    )
  );
  
endmodule