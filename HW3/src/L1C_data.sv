//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_data.sv
// Description: L1 Cache for Data
// Version:     0.1
//================================================
`include "../include/def.svh"
`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"

module L1C_data(
  input clk,
  input rst,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,
  input core_write,
  input [`DATA_BITS-1:0] core_in,
  input [`CACHE_TYPE_BITS-1:0] core_type,
  // Mem to CPU wrapper
  input [`DATA_BITS-1:0] D_out,
  input D_wait,
  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,
  output logic core_wait,
  // CPU wrapper to Mem
  output logic D_req,
  output logic [`DATA_BITS-1:0] D_addr,
  output logic D_write,
  output logic [`DATA_BITS-1:0] D_in,
  output logic [`CACHE_TYPE_BITS-1:0] D_type
);

  logic [`CACHE_INDEX_BITS-1:0] index;
  logic [`CACHE_DATA_BITS-1:0] DA_out;
  logic [`CACHE_DATA_BITS-1:0] DA_in;
  logic [`CACHE_WRITE_BITS-1:0] DA_write;
  logic DA_read;
  logic [`CACHE_TAG_BITS-1:0] TA_out;
  logic [`CACHE_TAG_BITS-1:0] TA_in;
  logic TA_write;
  logic TA_read;
  logic [`CACHE_LINES-1:0] valid;

  //--------------- complete this part by yourself -----------------//

    logic [2:0] CURRENT, NEXT;
    parameter   IDLE  = 3'b0,
                CHECK = 3'b1,
                RMISS  = 3'b10,
                WHIT = 3'b11,
                WMISS = 3'b100,
                DONE = 3'b101;
    integer i;
    logic hit;
    logic cnt_finish;
    logic [2:0] read_cnt;

    logic [`DATA_BITS-1:0] core_addr_TMP;
    logic core_req_TMP;
    logic core_write_TMP;
    logic [`DATA_BITS-1:0] core_in_TMP;
    logic [`CACHE_TYPE_BITS-1:0] core_type_TMP;
    logic [`CACHE_TAG_BITS-1:0] TA_in_TMP;
    logic [`CACHE_INDEX_BITS-1:0] index_TMP;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            core_addr_TMP   <= `DATA_BITS'b0;
            core_write_TMP  <= 1'b0;
            core_in_TMP     <= `DATA_BITS'b0;
            core_type_TMP   <= `CACHE_TYPE_BITS'b0;
            TA_in_TMP       <= `CACHE_TAG_BITS'b0;
            index_TMP       <= `CACHE_INDEX_BITS'b0;
        end else begin
            core_addr_TMP   <= core_addr;
            core_write_TMP  <= core_write;
            core_in_TMP     <= core_in;
            core_type_TMP   <= core_type;
            TA_in_TMP       <= TA_in;
            index_TMP       <= index;
        end
    end
    // line = 64, index = log2(line) = 6
    // line size = 4 words = 16 bytes, 
    //      offset = log2(line size_byte) = 4, WO = log2(line size_word) = 2

    //    tag   | index | offset  |
    //          |       | WO | BO | WO=word offset/ BO=byte offset
    // (32-6-4) |   6   | 2  |  2 |

    assign index = core_addr[9:4];
    assign TA_in = core_addr[31:10]; //tag: write data to tag_array
    assign hit = (TA_out == TA_in);



    always_ff @(posedge clk or posedge rst) begin 
        if(rst) 
             for(i=0;i<`CACHE_LINES;i=i+1)
                valid[i] <= 1'b0;
        else begin
            if(CURRENT == RMISS)
                valid[index] <= 1'b1;//check
        end
    end

    always_ff@(posedge clk or posedge rst) begin
        if(rst)
            CURRENT <= IDLE;
        else
            CURRENT <= NEXT;
    end

    always_comb begin
        case (CURRENT)
            IDLE: begin
                if(core_req)begin
                   if(valid[index]) NEXT = CHECK;
                   else if(core_write) NEXT = WMISS;
                   else NEXT = RMISS;   
                end
                else NEXT = IDLE;
            end
            CHECK: begin //check if cache hit
                if(core_write)begin
                    if(hit) NEXT = WHIT;
                    else NEXT = WMISS;
                end
                else begin
                    if(hit) NEXT = DONE;
                    else NEXT = RMISS;
                end
            end
            RMISS, WHIT, WMISS: begin
                if(cnt_finish)NEXT = DONE;
                else NEXT = CURRENT;
            end
            default : NEXT = IDLE;
        endcase
    end
    
    /* output port
    core_out: data to CPU
    core_wait: wait signal to CPU
    D_req: request to CPU wrapper
    D_addr: address to CPU wrapper
    D_write: write signal to CPU wrapper
    D_in: write data to CPU wrapper
    D_type: write/read size to CPU wrapper   
    */

    /* core_out
    data_array: 128 bits/line -> 4 instructions (4*32 bits) can be read and stored in cache
    WO = 0: data_array [0+:32]
    WO = 1: data_array [32+:32]..... 32 = 7'b0100000
    WO = 2: data_array [64+:32]..... 64 = 7'b1000000
    WO = 3: data_array [96+:32]..... 96 = 7'b1100000     
    */ 
    logic [1:0] WO;
    assign WO = core_addr_TMP[3:2];
    // assign core_out = DA_out[{WO,5'b0}+:`DATA_BITS]; //check
    always_ff @(posedge clk or posedge rst) begin : proc_
        if(rst) begin
            core_out <= `DATA_BITS'b0;
        end else begin
             case (CURRENT)
                CHECK: core_out <= DA_out[{WO,5'b0}+:`DATA_BITS];
                RMISS: begin
                    if(cnt_finish)
                        core_out <= DA_in[{WO,5'b0}+:`DATA_BITS];

                end
                default : core_out <= `DATA_BITS'b0;
             endcase
        end
    end
    assign core_wait = (CURRENT == IDLE)? core_req: ~(CURRENT==DONE);
    always_comb begin
        case (CURRENT)
            RMISS:begin
                D_req = ~cnt_finish;
                D_addr = {core_addr_TMP[31:4],4'h0}; //check
                D_write = 1'b0;
                D_in = `DATA_BITS'b0;
                D_type = core_type_TMP;
            end        
            WMISS, WHIT:begin
                D_req = (read_cnt == 3'b0);
                D_addr = core_addr_TMP;
                D_write = 1'b1;
                D_in = core_in_TMP;
                D_type = core_type_TMP;
            end
            default:begin
                D_req = 1'b0;
                D_addr = `DATA_BITS'h0; 
                D_write = 1'b0;
                D_in = `DATA_BITS'h0;
                D_type = `CACHE_TYPE_BITS'b0;
            end

        endcase

    end
    
    /*
    TA_x: x to tag_array
    DA_x: x to data_array
    */
    
    logic reset_cnt;
    assign reset_cnt = ~((CURRENT == RMISS) | (CURRENT == WMISS) | (CURRENT == WHIT));
    always_ff @(posedge clk or posedge rst) begin : read_counter
        if(rst) begin
            read_cnt <= 3'b0;
        end else begin
            if (reset_cnt)
                read_cnt <= 3'b0; //reset count
            else 
                if(cnt_finish) read_cnt <= 3'b0;
               else if (~D_wait) read_cnt <= read_cnt + 3'b1;
        end
    end

    always_comb begin
        case (CURRENT)
            WMISS, WHIT: cnt_finish = (read_cnt == 3'd1);
            RMISS: cnt_finish = (read_cnt == 3'd4);
            default: cnt_finish = 1'b0;
        endcase
    end

    logic [3:0] DA_write_Ctrl;
    logic [`CACHE_WRITE_BITS-1:0] DA_write_full;
    always_comb begin
        DA_write_Ctrl = 4'hF;
        DA_write_full = `CACHE_WRITE_BITS'hFFFF;
        if(core_write_TMP)begin
            case(core_type_TMP)
                `CACHE_WORD:begin
                    DA_write_Ctrl = 4'b0;
                    DA_write_full[{index_TMP,2'b00}+:4] = DA_write_Ctrl;
                end
                `CACHE_BYTE, `CACHE_BYTE_U:begin
                    DA_write_Ctrl[core_addr[1:0]]=1'b0;
                    DA_write_full[{index_TMP,2'b00}+:4]=DA_write_Ctrl;
                end
                `CACHE_HWORD, `CACHE_HWORD_U:begin
                    DA_write_Ctrl[{core_addr[1],1'b0}+2]=2'b0;
                    DA_write_full[{index_TMP, 2'b0}+:4]=DA_write_Ctrl;
                end
                default: 
                    DA_write_Ctrl = 4'hF;
            endcase
        end
       else DA_write_Ctrl = D_wait? 4'hF:4'b0;
    end
    logic [`CACHE_DATA_BITS-1:0] core_in_full;
    always_comb begin
        core_in_full = `CACHE_DATA_BITS'b0;
        if(core_write_TMP)
            core_in_full[{WO, 5'b0}+:32] = core_in_TMP;
    end

    assign TA_read = (CURRENT == IDLE) |(CURRENT== CHECK);
    assign TA_write = (CURRENT == RMISS)? ~(read_cnt == 3'b0): 1'b1;//active low
    assign DA_read = (CURRENT == CHECK)? (hit & ~core_write_TMP): 1'b0;//active high
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            DA_write <= `CACHE_WRITE_BITS'hffff;
            DA_in    <= `CACHE_DATA_BITS'b0;
        end
        else begin
            case (CURRENT)
                WHIT    : begin
                    DA_write <= cnt_finish? DA_write_full:`CACHE_WRITE_BITS'hffff;
                    DA_in    <= (read_cnt == 3'b0)? core_in_full:DA_in;
                end
                RMISS  : begin
                    DA_in[{read_cnt[1:0], 5'b0}+:32] <= D_out;
                    if(read_cnt == 3'd3)
                        DA_write <= `CACHE_WRITE_BITS'b0;
                    else
                        DA_write <= `CACHE_WRITE_BITS'hffff;
                end
                default : begin
                    DA_write <= `CACHE_WRITE_BITS'hffff;
                    DA_in    <= `CACHE_DATA_BITS'b0;
                end
            endcase
        end
    end

    /* byte offset: offset of the byte within the word
    write|   WORD    |   HWORD   |   BYTE    |
    BO=0 |   0000    |   1100    |   1110    |        
    BO=1 |   0000    |     -     |   1101    |
    BO=2 |   0000    |   0011    |   1011    |
    BO=3 |   0000    |     -     |   0111    |
    */
    /*
    CACHE_WORD: core_type[1:0]  =1x
    CACHE_BYTE: core_type[1:0]  =00
    CACHE_HWORD: core_type[1:0] =01
    */
   

  data_array_wrapper DA(
    .A(index),
    .DO(DA_out),
    .DI(DA_in),
    .CK(clk),
    .WEB(DA_write),
    .OE(DA_read),
    .CS(1'b1)
  );
   
  tag_array_wrapper  TA(
    .A(index),
    .DO(TA_out),
    .DI(TA_in_TMP),
    .CK(clk),
    .WEB(TA_write),
    .OE(TA_read),
    .CS(1'b1)
  );

endmodule

