`include "easy_axi_define.v"

module EASYAXI_MST (
// Global
    input  wire                      clk,
    input  wire                      rst_n, 
    input  wire                      enable,

// AXI AR Channel
    output wire                      axi_mst_arvalid,
    input  wire                      axi_mst_arready,
    output wire  [`AXI_ID_W    -1:0] axi_mst_arid,
    output wire  [`AXI_ADDR_W  -1:0] axi_mst_araddr,
    output wire  [`AXI_LEN_W   -1:0] axi_mst_arlen,
    output wire  [`AXI_SIZE_W  -1:0] axi_mst_arsize,
    output wire  [`AXI_BURST_W -1:0] axi_mst_arburst,

    input  wire                      axi_mst_rvalid,
    output wire                      axi_mst_rready,
    input  wire  [`AXI_DATA_W  -1:0] axi_mst_rdata,
    input  wire  [`AXI_RESP_W  -1:0] axi_mst_rresp,
    input  wire                      axi_mst_rlast
);
localparam DLY = 0.1;
//--------------------------------------------------------------------------------
// Inner Signal
//--------------------------------------------------------------------------------
reg axi_mst_arvalid_r;
reg [`AXI_ID_W  -1:0]  axi_mst_arid_r;
reg [`AXI_ADDR_W -1:0] axi_mst_araddr_r;
reg [`AXI_SIZE_W -1:0] axi_mst_arsize_r;
reg [`AXI_LEN_W   -1:0] axi_mst_arlen_r;
reg [`AXI_BURST_W -1:0] axi_mst_arburst_r;

reg trans_buffer_r;//indicate that the whole transition(including address read and read finished.
wire trans_buffer_set;
wire trans_buffer_clr;

wire ar_hs_done;
wire rd_hs_done;

wire arvalid_set;
wire arvalid_clr;

wire ar_req_change;

assign ar_hs_done = axi_mst_arvalid && axi_mst_arready;
assign rd_hs_done = axi_mst_rvalid && axi_mst_rready;
assign arvalid_set = enable && ~axi_mst_arvalid;
assign arvalid_clr = ar_hs_done;
assign ar_req_change = ar_hs_done;
assign trans_buffer_clr = rd_hs_done;
assign trans_buffer_set = ar_hs_done;


//--------------------------------------------------------------------------------
// logic for ar channel
//--------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        axi_mst_arvalid_r <= #DLY 0;
    else if(arvalid_set)
        axi_mst_arvalid_r <= #DLY 1;
    else if(arvalid_clr)
        axi_mst_arvalid_r <= #DLY 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        axi_mst_arid_r <= #DLY 0;
        axi_mst_araddr_r <= #DLY 0;
        axi_mst_arsize_r <= `AXI_SIZE_4B;
        axi_mst_arlen_r <= 0;
        axi_mst_arburst_r <= `AXI_BURST_FIXED;
    end else if(ar_req_change) begin
        axi_mst_arid_r <= #DLY axi_mst_arid + 1'b1;
        axi_mst_araddr_r <= #DLY (axi_mst_arid > 8) ? axi_mst_araddr_r + 4'b1000 : axi_mst_araddr_r;
    end
end

//--------------------------------------------------------------------------------
// logic for r channel
//--------------------------------------------------------------------------------



//--------------------------------------------------------------------------------
// logic for output
//--------------------------------------------------------------------------------
assign axi_mst_arvalid = axi_mst_arvalid_r;
assign axi_mst_arid = axi_mst_arid_r;
assign axi_mst_araddr = axi_mst_araddr_r;
assign axi_mst_arready = 1;
endmodule
