`timescale 1ns/1ps

module zynq_top
(
    input  [1:0]  SW,
    input  [3:0]  BTN,
    output [3:0]  LED,

    // Zynq DDR and fixed IO
    inout [14:0] DDR_addr,
    inout [2:0]  DDR_ba,
    inout        DDR_cas_n,
    inout        DDR_ck_n,
    inout        DDR_ck_p,
    inout        DDR_cke,
    inout        DDR_cs_n,
    inout [3:0]  DDR_dm,
    inout [31:0] DDR_dq,
    inout [3:0]  DDR_dqs_n,
    inout [3:0]  DDR_dqs_p,
    inout        DDR_odt,
    inout        DDR_ras_n,
    inout        DDR_reset_n,
    inout        DDR_we_n,
    inout        FIXED_IO_ddr_vrn,
    inout        FIXED_IO_ddr_vrp,
    inout [53:0] FIXED_IO_mio,
    inout        FIXED_IO_ps_clk,
    inout        FIXED_IO_ps_porb,
    inout        FIXED_IO_ps_srstb
);

    localparam int  AXIL_ADDR_WIDTH  = 25;
    localparam real AXI_FREQ_MHZ   = 50.0;

    // Clocks / resets from Zynq PS block design
    wire ACLK;   // 50 MHz from FCLK_CLK1 (drives all PL logic)
    wire ARST;   // active-high synchronous reset

    // map btn[0] to reset module
    wire btn_rst = BTN[0];

    // axil-mapped registers
    localparam int N_REGS = 16;
    (* mark_debug = "true" *)  logic [31:0] regs0[N_REGS];
    (* mark_debug = "true" *)  logic [31:0] regs1[N_REGS];
    (* mark_debug = "true" *)  logic [N_REGS-1:0] regs0_wflag;
    (* mark_debug = "true" *)  logic [N_REGS-1:0] regs1_wflag;

    // AXI-Lite signals: Zynq PS M00_AXI_0
    logic [31:0] axil0_awaddr;
    logic        axil0_awvalid;
    logic        axil0_awready;
    logic [31:0] axil0_wdata;
    logic [3:0]  axil0_wstrb;
    logic        axil0_wvalid;
    logic        axil0_wready;
    logic [1:0]  axil0_bresp;
    logic        axil0_bvalid;
    logic        axil0_bready;
    logic [31:0] axil0_araddr;
    logic        axil0_arvalid;
    logic        axil0_arready;
    logic [31:0] axil0_rdata;
    logic [1:0]  axil0_rresp;
    logic        axil0_rvalid;
    logic        axil0_rready;

    // AXI-Lite signals: Zynq PS M01_AXI_0
    logic [31:0] axil1_awaddr;
    logic        axil1_awvalid;
    logic        axil1_awready;
    logic [31:0] axil1_wdata;
    logic [3:0]  axil1_wstrb;
    logic        axil1_wvalid;
    logic        axil1_wready;
    logic [1:0]  axil1_bresp;
    logic        axil1_bvalid;
    logic        axil1_bready;
    logic [31:0] axil1_araddr;
    logic        axil1_arvalid;
    logic        axil1_arready;
    logic [31:0] axil1_rdata;
    logic [1:0]  axil1_rresp;
    logic        axil1_rvalid;
    logic        axil1_rready;



    // -----------------------------------------------------------------------
    // Zynq PS block design (for axi)
    // -----------------------------------------------------------------------
    zynq_ps_axi u_zynq
    (
        .ACLK_in          (ACLK),       // use 50MHz CLK1 for AXI clock
        .ARST             (ARST),
        .ARST_in          (btn_rst),
        .CLK0             (),           // 100 MHz -- unused
        .CLK1             (ACLK),       // 50 MHz  -- main PL clock
        .DDR_addr         (DDR_addr),
        .DDR_ba           (DDR_ba),
        .DDR_cas_n        (DDR_cas_n),
        .DDR_ck_n         (DDR_ck_n),
        .DDR_ck_p         (DDR_ck_p),
        .DDR_cke          (DDR_cke),
        .DDR_cs_n         (DDR_cs_n),
        .DDR_dm           (DDR_dm),
        .DDR_dq           (DDR_dq),
        .DDR_dqs_n        (DDR_dqs_n),
        .DDR_dqs_p        (DDR_dqs_p),
        .DDR_odt          (DDR_odt),
        .DDR_ras_n        (DDR_ras_n),
        .DDR_reset_n      (DDR_reset_n),
        .DDR_we_n         (DDR_we_n),
        .FIXED_IO_ddr_vrn (FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp (FIXED_IO_ddr_vrp),
        .FIXED_IO_mio     (FIXED_IO_mio),
        .FIXED_IO_ps_clk  (FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb (FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),

        // M00_AXI_0
        .M00_AXI_0_araddr (axil0_araddr),
        .M00_AXI_0_arprot (),
        .M00_AXI_0_arready(axil0_arready),
        .M00_AXI_0_arvalid(axil0_arvalid),
        .M00_AXI_0_awaddr (axil0_awaddr),
        .M00_AXI_0_awprot (),
        .M00_AXI_0_awready(axil0_awready),
        .M00_AXI_0_awvalid(axil0_awvalid),
        .M00_AXI_0_bready (axil0_bready),
        .M00_AXI_0_bresp  (axil0_bresp),
        .M00_AXI_0_bvalid (axil0_bvalid),
        .M00_AXI_0_rdata  (axil0_rdata),
        .M00_AXI_0_rready (axil0_rready),
        .M00_AXI_0_rresp  (axil0_rresp),
        .M00_AXI_0_rvalid (axil0_rvalid),
        .M00_AXI_0_wdata  (axil0_wdata),
        .M00_AXI_0_wready (axil0_wready),
        .M00_AXI_0_wstrb  (axil0_wstrb),
        .M00_AXI_0_wvalid (axil0_wvalid),

        // M01_AXI_1
        .M01_AXI_0_araddr (axil1_araddr),
        .M01_AXI_0_arprot (),
        .M01_AXI_0_arready(axil1_arready),
        .M01_AXI_0_arvalid(axil1_arvalid),
        .M01_AXI_0_awaddr (axil1_awaddr),
        .M01_AXI_0_awprot (),
        .M01_AXI_0_awready(axil1_awready),
        .M01_AXI_0_awvalid(axil1_awvalid),
        .M01_AXI_0_bready (axil1_bready),
        .M01_AXI_0_bresp  (axil1_bresp),
        .M01_AXI_0_bvalid (axil1_bvalid),
        .M01_AXI_0_rdata  (axil1_rdata),
        .M01_AXI_0_rready (axil1_rready),
        .M01_AXI_0_rresp  (axil1_rresp),
        .M01_AXI_0_rvalid (axil1_rvalid),
        .M01_AXI_0_wdata  (axil1_wdata),
        .M01_AXI_0_wready (axil1_wready),
        .M01_AXI_0_wstrb  (axil1_wstrb),
        .M01_AXI_0_wvalid (axil1_wvalid)
    );



    axil_regs #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(32),
        .N_REGS(N_REGS)
    ) u_regs0 (
    .clk(ACLK),
    .rst(ARST),
    .axil_awaddr    (axil0_awaddr),
    .axil_awvalid   (axil0_awvalid),
    .axil_awready   (axil0_awready),
    .axil_wdata     (axil0_wdata),
    .axil_wstrb     (axil0_wstrb),
    .axil_wvalid    (axil0_wvalid),
    .axil_wready    (axil0_wready),
    .axil_bresp     (axil0_bresp),
    .axil_bvalid    (axil0_bvalid),
    .axil_bready    (axil0_bready),
    .axil_araddr    (axil0_araddr),
    .axil_arvalid   (axil0_arvalid),
    .axil_arready   (axil0_arready),
    .axil_rdata     (axil0_rdata),
    .axil_rresp     (axil0_rresp),
    .axil_rvalid    (axil0_rvalid),
    .axil_rready    (axil0_rready),
    .regs_o         (regs0),
    .regs_i         (regs0),
    .regs_o_flag    (regs0_wflag)
);

    axil_regs #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(32),
        .N_REGS(N_REGS)
    ) u_regs1 (
    .clk(ACLK),
    .rst(ARST),
    .axil_awaddr    (axil1_awaddr),
    .axil_awvalid   (axil1_awvalid),
    .axil_awready   (axil1_awready),
    .axil_wdata     (axil1_wdata),
    .axil_wstrb     (axil1_wstrb),
    .axil_wvalid    (axil1_wvalid),
    .axil_wready    (axil1_wready),
    .axil_bresp     (axil1_bresp),
    .axil_bvalid    (axil1_bvalid),
    .axil_bready    (axil1_bready),
    .axil_araddr    (axil1_araddr),
    .axil_arvalid   (axil1_arvalid),
    .axil_arready   (axil1_arready),
    .axil_rdata     (axil1_rdata),
    .axil_rresp     (axil1_rresp),
    .axil_rvalid    (axil1_rvalid),
    .axil_rready    (axil1_rready),
    .regs_o         (regs1),
    .regs_i         (regs1),
    .regs_o_flag    (regs1_wflag)
);

endmodule
