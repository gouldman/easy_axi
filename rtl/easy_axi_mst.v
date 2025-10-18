`include "easy_axi_define.v"

module EASYAXI_MST (
// Global
    input  wire                              clk,
    input  wire                              rst_n, 
    input  wire                              enable,

// AXI AR Channel
    output wire                              axi_mst_arvalid,
    input  wire                              axi_mst_arready,
    output wire  [`AXI_ID_WIDTH  -1:0]       axi_mst_arid,
    output wire  [`AXI_ADDR_WIDTH-1:0]       axi_mst_araddr
);
localparam DLY = 0.1;
//--------------------------------------------------------------------------------
// Inner Signal
//--------------------------------------------------------------------------------
reg axi_mst_arvalid_r;
reg [`AXI_ID_WIDTH  -1:0]       axi_mst_arid_r;
reg [`AXI_ADDR_WIDTH-1:0]       axi_mst_araddr_r;

wire hs_done;

wire arvalid_set;
wire arvalid_clr;

wire ar_req_change;

assign hs_done = axi_mst_arvalid && axi_mst_arready;
assign arvalid_set = enable && ~axi_mst_arvalid;
assign arvalid_clr = hs_done;

assign ar_req_change = hs_done;

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
    end else if(ar_req_change) begin
        axi_mst_arid_r <= #DLY axi_mst_arid + 1'b1;
        axi_mst_araddr_r <= #DLY (axi_mst_arid > 8) ? axi_mst_araddr_r + 4'b1000 : axi_mst_araddr_r;
    end
end

assign axi_mst_arvalid = axi_mst_arvalid_r;
assign axi_mst_arid = axi_mst_arid_r;
assign axi_mst_araddr = axi_mst_araddr_r;
endmodule
