`include "easy_axi_define.v"
module EASYAXI_SLV (
// Global
    input  wire                      clk,
    input  wire                      rst_n, 
    input  wire                      enable,

// AXI AR Channel
    input  wire                      axi_slv_arvalid,
    output wire                      axi_slv_arready,
    input  wire  [`AXI_ID_W    -1:0] axi_slv_arid,
    input  wire  [`AXI_ADDR_W  -1:0] axi_slv_araddr,
    input  wire  [`AXI_LEN_W   -1:0] axi_slv_arlen,
    input  wire  [`AXI_SIZE_W  -1:0] axi_slv_arsize,
    input  wire  [`AXI_BURST_W -1:0] axi_slv_arburst,

    output wire                      axi_slv_rvalid,
    input  wire                      axi_slv_rready,
    output wire  [`AXI_DATA_W  -1:0] axi_slv_rdata,
    output wire  [`AXI_RESP_W  -1:0] axi_slv_rresp,
    output wire                      axi_slv_rlast
);
localparam DLY       = 0.1;
localparam CLR_CNT_W = 4;     // Clear counter width
localparam REG_ADDR  = 16'h0000;  // Default register address

//--------------------------------------------------------------------------------
// inner signal
//--------------------------------------------------------------------------------

reg  [`AXI_ID_W    -1:0] arid_buff_r;        // AXI ID buffer
reg  [`AXI_ADDR_W  -1:0] araddr_buff_r;      // AXI Address buffer
reg  [`AXI_LEN_W   -1:0] arlen_buff_r;       // AXI Length buffer
reg  [`AXI_SIZE_W  -1:0] arsize_buff_r;      // AXI Size buffer
reg  [`AXI_BURST_W -1:0] arburst_buff_r;     // AXI Burst type buffer

reg ar_capture_r;
wire ar_capture_clr;
wire ar_capture_set;

reg [CLR_CNT_W - 1: 0] rd_gen_cnt;
wire rd_gen;

wire ar_hs_done;
wire rd_hs_done;

reg  [`AXI_LEN_W   -1:0] rd_len_index_r;
wire addr_miss;
wire rlast;

assign ar_hs_done = axi_slv_arvalid && axi_slv_arready;
assign rd_hs_done = axi_slv_rready && axi_slv_rvalid;

//--------------------------------------------------------------------------------
// logic for some general signals
//--------------------------------------------------------------------------------
assign addr_miss = (axi_slv_araddr != REG_ADDR);
assign rlast = (rd_len_index_r == arlen_buff_r);

//--------------------------------------------------------------------------------
// logic for capture the request from ar channel
//--------------------------------------------------------------------------------
assign ar_capture_clr = rd_gen && rlast;
assign ar_capture_set = ar_hs_done;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ar_capture_r <= 0;
    else if(ar_capture_set)
        ar_capture_r <= 1;
    else if(ar_capture_clr)
        ar_capture_r <= 0;
end



//--------------------------------------------------------------------------------
// logic for id buff and addr buff
//--------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arid_buff_r <= 0;
        araddr_buff_r <= 0;
        arlen_buff_r <= 0;
        arsize_buff_r <= 0;
        assign arburst_buff_r = 0;
    end else if(ar_hs_done) begin
        arid_buff_r <= axi_slv_arid;
        araddr_buff_r <= axi_slv_araddr;
        arlen_buff_r <= axi_slv_arlen;
        arsize_buff_r <= axi_slv_arsize;
        arburst_buff_r <= axi_slv_arburst;
    end
end
//--------------------------------------------------------------------------------
// logic for counter to generate fake data
//--------------------------------------------------------------------------------
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rd_gen_cnt = 0;
    else if(ar_capture_r) 
        rd_gen_cnt = rd_gen_cnt + 1;
    else if(rd_hs_done)
        rd_gen_cnt <= rlast ? 0 : 1;
    else if(rd_gen)
        rd_gen_cnt = 0;
    else if(rd_gen_cnt != 0)
        rd_gen_cnt = rd_gen_cnt + 1'b1;
end

assign rd_gen = (rd_gen_cnt == {CLR_CNT_W{1'b1}} - arid_buff_r);

//--------------------------------------------------------------------------------
// logic for index counter
//--------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_len_index_r <= 0;
    end
    else if(rd_gen)begin
        rd_len_index_r <= rd_len_index_r + 1;
    end else if(rlast && rd_hs_done) begin
        rd_len_index_r <= 0;
    end
end

//--------------------------------------------------------------------------------
// output signal
//--------------------------------------------------------------------------------
assign axi_slv_arready = !addr_miss && ~ar_capture_r;


assign axi_slv_rlast = rlast;
assign axi_slv_rdata = rd_len_index_r;
endmodule
