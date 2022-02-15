module DRAM_wrapper (
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
    input RREADY,

    output logic DRAM_CSn,
    output logic [`AXI_STRB_BITS-1:0] DRAM_WEn,
    output logic DRAM_RASn,
    output logic DRAM_CASn,
    output logic [10:0] DRAM_A,
    output logic [`AXI_DATA_BITS-1:0] DRAM_D,
    input [`AXI_DATA_BITS-1:0] DRAM_Q,
    input DRAM_valid
);
    logic AW_DONE;
    logic W_DONE;
    logic B_DONE;
    logic R_DONE;
    logic AR_DONE;
    assign AR_DONE = ARVALID & ARREADY;
    assign R_DONE  = RVALID  & RREADY;
    assign AW_DONE = AWVALID & AWREADY;
    assign W_DONE  = WVALID  & WREADY;
    assign B_DONE  = BVALID  & BREADY;

    parameter INIT  = 3'b000,
              ACTIVATE   = 3'b001,
              READ  = 3'b010,
              WRITE = 3'b011,
              PREV   = 3'b100;

    logic [2:0] delay_cnt;  // wait 5 cycle
    logic [2:0] CURRENT, NEXT;
    logic delay_done;
    assign delay_done = (CURRENT == READ) ? delay_cnt == 3'h5 : delay_cnt[2];

    logic write;
    always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            write <= 1'b0;
        end else begin
            case (CURRENT)
                INIT: begin
                    if(AW_DONE)
                        write <= 1'b1;
                end
                ACTIVATE:
                    write <= write;
                default : /* default */
                    write <= 1'b0;
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst) begin
        if(~rst)
            CURRENT <= INIT;
        else
            CURRENT <= NEXT;
    end
    always_comb begin
        case (CURRENT)
            INIT: begin
                if(AR_DONE | AW_DONE)
                    NEXT = ACTIVATE;
                else
                    NEXT = INIT;
            end
            ACTIVATE: begin
                if(delay_done) begin
                    if(write)
                        NEXT = WRITE;
                    else
                        NEXT = READ;
                end
                else
                    NEXT = ACTIVATE;
            end
            READ: begin
                if(delay_done & R_DONE & RLAST)
                    NEXT = PREV;
                else
                    NEXT = READ;
            end
            WRITE: begin
                if(delay_done)
                    NEXT = PREV;
                else
                    NEXT = WRITE;
            end
            default: begin /*PREV*/
                if(delay_done)
                    NEXT = INIT;
                else
                    NEXT = PREV;
            end
        endcase
    end

    logic [`AXI_ADDR_BITS-1:0] reg_ADDR;
    logic [`AXI_IDS_BITS-1:0] reg_ID;
    logic [1:0] reg_BURST;
    logic [`AXI_LEN_BITS  -1:0] reg_LEN;
    logic [`AXI_SIZE_BITS -1:0] reg_SIZE;
    // logic [`AXI_DATA_BITS -1:0] reg_WDATA;




    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            reg_ADDR    <= `AXI_ADDR_BITS'b0;
            reg_ID      <= `AXI_IDS_BITS'b0;
            reg_BURST   <= 2'b0;
            reg_LEN     <= `AXI_LEN_BITS'b0;
            reg_SIZE    <= `AXI_SIZE_BITS'b0;
        end
        else begin
            if(AR_DONE) begin
                reg_ID      <= ARID;
                reg_ADDR    <= ARADDR;
                reg_LEN     <= ARLEN;
                reg_SIZE    <= ARSIZE;
                reg_BURST   <= ARBURST;
            end
            else if(AW_DONE) begin
                reg_ID      <= AWID;
                reg_ADDR    <= AWADDR;
                reg_LEN     <= AWLEN;
                reg_SIZE    <= AWSIZE;
                reg_BURST   <= AWBURST;
            end
        end
    end
    always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            delay_cnt <= 3'b0;
        end else begin
            case (CURRENT)
                INIT:
                    delay_cnt <= 3'b0;
                default : /* default */
                    delay_cnt <= (delay_done)? 3'b0:delay_cnt + 3'b1;
            endcase
        end
    end

    logic [`AXI_LEN_BITS-1:0] read_cnt;
    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            read_cnt <= `AXI_LEN_BITS'b0;
        end
        else begin
            case (CURRENT)
                READ:
                    read_cnt  <= R_DONE? read_cnt + `AXI_LEN_BITS'b1:read_cnt;
                default: /* default */
                    read_cnt  <= `AXI_LEN_BITS'b0;
            endcase
        end
    end

    logic [`DATA_BITS -1:0] reg_WDATA;

    always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            reg_WDATA   <= `DATA_BITS'b0;
        end else begin
            reg_WDATA <= (CURRENT == ACTIVATE)? WDATA:reg_WDATA;
        end
    end

    // DRAM simulator
    // only first cycle can activate DRAM, and every state need wait 5 cycle at least
    always_comb begin
        case (CURRENT)
            INIT: begin
                DRAM_RASn = 1'b1;
                DRAM_CASn = 1'b1;
                DRAM_WEn  = 4'hF;
            end
            ACTIVATE: begin
                DRAM_RASn = ~(delay_cnt == 3'b0);
                DRAM_CASn = 1'b1;
                DRAM_WEn  = 4'hF;
            end
            READ: begin
                DRAM_RASn = 1'b1;
                DRAM_CASn = ~(delay_cnt == 3'b0);
                DRAM_WEn  = 4'hF;
            end
            WRITE: begin
                DRAM_RASn = 1'b1;
                DRAM_CASn = ~(delay_cnt == 3'b0);
                DRAM_WEn  = (delay_cnt == 3'b0)? WSTRB:4'hF;
            end
            default: begin /* PREV */
                DRAM_RASn = ~(delay_cnt == 3'b0);
                DRAM_CASn = 1'b1;
                DRAM_WEn  = (delay_cnt == 3'b0)? 4'b0:4'hF;
            end
        endcase
    end

    always_comb begin
        case (CURRENT)
            INIT: begin
                DRAM_A      = reg_ADDR[22:12];
                DRAM_D      = `DATA_BITS'h0;
                DRAM_CSn    = 1'b1;
            end
            ACTIVATE: begin
                DRAM_A      = reg_ADDR[22:12];
                DRAM_D      = WDATA;
                DRAM_CSn    = 1'b0;
            end
            READ: begin
                DRAM_A      = reg_ADDR[11:2] + read_cnt[1:0];
                DRAM_D      = WDATA;
                DRAM_CSn    = 1'b0;
            end
            WRITE: begin
                DRAM_A      = reg_ADDR[11:2];
                DRAM_D      = reg_WDATA;
                DRAM_CSn    = 1'b0;
            end
            default: begin /* PREV */
                DRAM_A      = reg_ADDR[22:12];
                DRAM_D      = `DATA_BITS'h0;
                DRAM_CSn    = 1'b0;
            end
        endcase
    end

    always_comb begin
        case (CURRENT)
            INIT: begin
                ARREADY = ~AWVALID;
                AWREADY = 1'b1;
            end
            default: begin
                ARREADY = 1'b0;
                AWREADY = 1'b0;
            end
        endcase
    end

    always_comb begin
        case (CURRENT)
            WRITE:
                WREADY = 1'b1;
            default:
                WREADY = 1'b0;
        endcase
    end

    always_comb begin
        case (CURRENT)
            READ: begin
                RVALID = DRAM_valid;
                BVALID = 1'b0;
            end
            PREV: begin
                RVALID = 1'b0;
                BVALID = (delay_cnt == 3'b0);
            end
            default : begin /* default */
                RVALID = 1'b0;
                BVALID = 1'b0;
            end
        endcase
    end

    logic [`DATA_BITS -1:0] reg_RDATA;
    always_ff @(posedge clk or negedge rst) begin
        if(~rst) begin
            reg_RDATA <= `DATA_BITS'b0;
        end else begin
            reg_RDATA <= DRAM_valid? DRAM_Q:reg_RDATA;
        end
    end

    assign RID   = reg_ID;
    assign RDATA = DRAM_valid? DRAM_Q : reg_RDATA;
    assign RRESP = `AXI_RESP_OKAY;

    assign RLAST = (read_cnt == reg_LEN);
    assign BID   = reg_ID;
    assign BRESP = `AXI_RESP_OKAY;

endmodule