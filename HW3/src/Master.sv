`include "../include/AXI_define.svh"
`include "../include/def.svh"
module Master (
    input ACLK,   
    input ARESETn,  
    //CPU
    input read,
    input write,
    input [`AXI_STRB_BITS-1:0] write_type,
    input [`AXI_ADDR_BITS-1:0] addr_in,
    input [`AXI_DATA_BITS-1:0] data_in,
    output logic [`AXI_DATA_BITS-1:0] data_out,
    output logic stall, 

    // AXI
    //WRITE ADDRESS
    output logic [`AXI_ID_BITS-1:0] AWID,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR,
    output logic [`AXI_LEN_BITS-1:0] AWLEN,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE,
    output logic [1:0] AWBURST,
    output logic AWVALID,
    input AWREADY,
    //WRITE DATA
    output logic [`AXI_DATA_BITS-1:0] WDATA,
    output logic [`AXI_STRB_BITS-1:0] WSTRB,
    output logic WLAST,
    output logic WVALID,
    input WREADY,
    //WRITE RESPONSE
    input [`AXI_ID_BITS-1:0] BID,
    input [1:0] BRESP,
    input BVALID,
    output logic BREADY,
    //READ ADDRESS
    output logic [`AXI_ID_BITS-1:0] ARID,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR,
    output logic [`AXI_LEN_BITS-1:0] ARLEN,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE,
    output logic [1:0] ARBURST,
    output logic ARVALID,
    input ARREADY,
    //READ DATA
    input [`AXI_ID_BITS-1:0] RID,
    input [`AXI_DATA_BITS-1:0] RDATA,
    input [1:0] RRESP,
    input RLAST,
    input RVALID,
    output logic RREADY
);

    parameter [2:0] FIRST = 3'b000,
                    A_R  = 3'b001,
                    D_R  = 3'b010,
                    A_W  = 3'b011,
                    D_W  = 3'b100,
                    B    = 3'b101;

    logic [2:0] CURRENT, NEXT;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if(~ARESETn) begin
            CURRENT <= FIRST;
        end 
        else begin
            CURRENT <= NEXT;
        end
    end

    logic AR_DONE;
    logic R_DONE;
    logic W_DONE;
    logic B_DONE;
    logic AW_DONE;
    logic [`AXI_DATA_BITS-1:0] RDATA_TMP;

    assign AR_DONE = ARREADY & ARVALID;
    assign R_DONE = RREADY & RVALID;
    assign W_DONE = WREADY & WVALID;
    assign AW_DONE = AWREADY & AWVALID;
    assign B_DONE = BREADY & BVALID;

    always_comb begin
        case(CURRENT)
            FIRST: begin
                if(ARVALID)      NEXT = AR_DONE? D_R : A_R;
                else if(AWVALID) NEXT = AW_DONE? D_W : A_W;
                else             NEXT = FIRST;
            end
            A_R:     NEXT = AR_DONE? D_R  : A_R;
            D_R:     NEXT = R_DONE & RLAST ? FIRST : D_R;
            A_W:     NEXT = AW_DONE? D_W  : A_W;
            D_W:     NEXT = W_DONE ? B    : D_W;
            default: NEXT = B_DONE ? FIRST : B;
        endcase // CURRENT
    end

    logic START;
    always_ff@(posedge ACLK or negedge ARESETn)begin
        if(~ARESETn) START <= 1'b0;
        else     START <= 1'b1;
    end

    // RA
    assign ARID     = `AXI_ID_BITS'b0; 
    assign ARADDR   = addr_in;
    assign ARLEN    = `AXI_LEN_BITS'd3; //change
    assign ARSIZE   = `AXI_SIZE_BITS'b10; // temp
    assign ARBURST  = `AXI_BURST_INC;
    assign ARVALID  = (CURRENT == FIRST)? (read&START):(CURRENT == A_R);

    // R
    assign data_out = R_DONE? RDATA : RDATA_TMP;
    assign RREADY   = (CURRENT == D_R);
    
    always_ff @(posedge ACLK or negedge ARESETn) begin
        if(~ARESETn) begin
            RDATA_TMP <= `AXI_DATA_BITS'b0;
        end else begin
            RDATA_TMP <= R_DONE? RDATA : RDATA_TMP;
        end
    end

    // WA
    assign AWID     = `AXI_ID_BITS'b0; 
    assign AWADDR   = addr_in;
    assign AWLEN    = `AXI_LEN_BITS'b0; 
    assign AWSIZE   = `AXI_SIZE_BITS'b10; 
    assign AWBURST  = `AXI_BURST_INC;
    assign AWVALID  = (CURRENT== FIRST)? (write&START) :(CURRENT == A_W);

    // WD
    assign WDATA    = data_in;
    //change 12/28
    // assign WSTRB    = write_type;
    always_comb begin
        WSTRB = 4'b1111;
        case(write_type)
            `CACHE_BYTE:    WSTRB[addr_in[1:0]] = 1'b0;
            `CACHE_HWORD:   WSTRB[{addr_in[1],1'b0}+:2] = 2'b0;
            `CACHE_WORD:    WSTRB = 4'b0000;
        endcase
    end

    assign WLAST    = 1'b1;
    assign WVALID   = (CURRENT == D_W);

    // B
    assign BREADY   = (CURRENT == B | W_DONE);

   // assign stall = (read & ~R_DONE) | (write & ~W_DONE);
   always_comb begin
    case(CURRENT)
        FIRST: stall = (START&write) | (START&read);
        A_R:  stall = 1'b1;
        D_R:  stall = ~R_DONE;
        A_W:  stall = 1'b1;
        D_W:  stall = ~W_DONE;
        B:    stall = (START&write) | (START&read);
        default: stall = 1'b0;
    endcase
   end
endmodule : Master
