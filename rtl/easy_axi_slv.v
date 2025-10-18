`include "easy_axi_define.v"
module EASYAXI_SLV (
// Global
    input  wire                              clk,
    input  wire                              rst_n, 
    input  wire                              enable,

// AXI AR Channel
    input  wire                              axi_slv_arvalid,
    output wire                              axi_slv_arready,
    input  wire  [`AXI_ID_WIDTH  -1:0]       axi_slv_arid,
    input  wire  [`AXI_ADDR_WIDTH-1:0]       axi_slv_araddr
);
localparam DLY       = 0.1;
localparam CLR_CNT_W = 4;     // Clear counter width
localparam REG_ADDR  = 16'h0000;  // Default register address

//--------------------------------------------------------------------------------
// inner signal
//--------------------------------------------------------------------------------

reg [`AXI_ID_WIDTH  -1:0]       arid_buff_r;
reg [`AXI_ADDR_WIDTH-1:0]       araddr_buff_r;

reg ar_capture_r;
wire ar_capture_clr;
wire ar_capture_set;

reg [CLR_CNT_W - 1: 0] rd_gen_cnt;
wire rd_gen;

wire hs_done;

wire addr_miss;

assign hs_done = axi_slv_arvalid && axi_slv_arready;

//--------------------------------------------------------------------------------
// logic for some general signals
//--------------------------------------------------------------------------------
assign addr_miss = (axi_slv_araddr != REG_ADDR);

//--------------------------------------------------------------------------------
// logic for capture the request from ar channel
//--------------------------------------------------------------------------------
assign ar_capture_clr = rd_gen;
assign ar_capture_set = hs_done;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ar_capture_r <= 0;
    else if(ar_capture_set)
        ar_capture_r <= 1;
    else if(ar_capture_clr)
        ar_capture_r <= 0;
end

//--------------------------------------------------------------------------------
// logic for counter to generate fake data
//--------------------------------------------------------------------------------
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rd_gen_cnt = 0;
    else if(ar_capture_r) 
        rd_gen_cnt = rd_gen_cnt + 1;
    else if(rd_gen)
        rd_gen_cnt = 0;
    else if(rd_gen_cnt != 0)
        rd_gen_cnt = rd_gen_cnt + 1'b1;
end

assign rd_gen = {rd_gen_cnt == {CLR_CNT_W{1'b1}}};

//--------------------------------------------------------------------------------
// logic for id buff and addr buff
//--------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        arid_buff_r <= 0;
        araddr_buff_r <= 0;
    end else if(hs_done) begin
        arid_buff_r <= axi_slv_arid;
        araddr_buff_r <= axi_slv_araddr;
    end
end

//--------------------------------------------------------------------------------
// output signal
//--------------------------------------------------------------------------------
assign axi_slv_arready = !addr_miss && ~ar_capture_r;
endmodule
