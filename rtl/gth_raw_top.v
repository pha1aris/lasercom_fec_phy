
`timescale 1ns/1ps

module gth_raw_top #(
    parameter integer W = 32
)(
    input  wire         freerun_clk,      // 用作 gtwiz_reset_clk_freerun_in
    input  wire         gth_reset_all,     // 异步高有效

    input  wire         mgtrefclk0_x1y1_p,
    input  wire         mgtrefclk0_x1y1_n,
    input  wire         gthrxp_in,
    input  wire         gthrxn_in,
    output wire         gthtxp_out,
    output wire         gthtxn_out,

    input  wire [2:0]   i_loopback,       // loopback 模式
    output wire         o_pll_locked,

    output wire         o_tx_clk,          // TX usrclk2
    output wire         o_tx_rst_n,        // TX 域复位 (active-low)
    output wire         o_tx_done,         // TX reset done
    output wire         o_tx_active,       // TX userclk active
    input  wire [W-1:0] i_tx_data,         // TX 并行数据

    output wire         o_rx_clk,          // RX usrclk2
    output wire         o_rx_rst_n,        // RX 域复位
    output wire         o_rx_done,         // RX reset done
    output wire         o_rx_active,       // RX userclk active
    output wire         o_cdr_stable,      // CDR 稳定指示
    output wire [W-1:0] o_rx_data,         // RX 并行数据
    input  wire         i_rx_slide         // RX slide 请求
);

    assign o_pll_locked = 1'b1;

    // =========================================================================
    // 1. refclk 缓冲
    // =========================================================================
    wire gtrefclk_int;

    IBUFDS_GTE4 #(
        .REFCLK_EN_TX_PATH  (1'b0),
        .REFCLK_HROW_CK_SEL (2'b00),
        .REFCLK_ICNTL_RX    (2'b00)
    ) u_ibufds_refclk (
        .I     (mgtrefclk0_x1y1_p),
        .IB    (mgtrefclk0_x1y1_n),
        .CEB   (1'b0),
        .O     (gtrefclk_int),
        .ODIV2 ()
    );

    // =========================================================================
    // 2. gth_reset_all 异步复位同步到 freerun_clk 域
    // =========================================================================
    wire gth_reset_sync;

    xpm_cdc_async_rst #(
        .DEST_SYNC_FF   (4),
        .RST_ACTIVE_HIGH(1)
    ) u_rst_sync (
        .src_arst (gth_reset_all),
        .dest_clk (freerun_clk),
        .dest_arst(gth_reset_sync)
    );

    // =========================================================================
    // 3. 与 gtwizard_ultrascale_0 的连线
    // =========================================================================
    wire [0:0] gtwiz_userclk_tx_active_in;
    wire [0:0] gtwiz_userclk_rx_active_in;

    wire [0:0] gtwiz_reset_clk_freerun_in   = {freerun_clk};
    wire [0:0] gtwiz_reset_all_in           = {gth_reset_sync};

    wire [0:0] gtwiz_reset_tx_pll_and_datapath_in = 1'b0;
    wire [0:0] gtwiz_reset_tx_datapath_in         = 1'b0;
    wire [0:0] gtwiz_reset_rx_pll_and_datapath_in = 1'b0;
    wire [0:0] gtwiz_reset_rx_datapath_in         = 1'b0;

    wire [0:0] gtwiz_reset_rx_cdr_stable_out;
    wire [0:0] gtwiz_reset_tx_done_out;
    wire [0:0] gtwiz_reset_rx_done_out;

    wire [31:0] gtwiz_userdata_tx_in;
    wire [31:0] gtwiz_userdata_rx_out;

    wire [0:0] gtrefclk01_in          = {gtrefclk_int};
    wire [0:0] qpll1outclk_out;
    wire [0:0] qpll1outrefclk_out;

    wire [0:0] gthrxn_in_vec          = {gthrxn_in};
    wire [0:0] gthrxp_in_vec          = {gthrxp_in};
    wire [0:0] gthtxn_out_vec;
    wire [0:0] gthtxp_out_vec;

    wire [0:0] gtpowergood_out;
    wire [0:0] rxoutclk_out;
    wire [0:0] rxpmaresetdone_out;
    wire [0:0] rxsliderdy_out;
    wire [0:0] txoutclk_out;
    wire [0:0] txpmaresetdone_out;

    assign gtwiz_userdata_tx_in = i_tx_data;
    assign o_rx_data            = gtwiz_userdata_rx_out;

    // =========================================================================
    // 4. BUFG_GT 产生 txusrclk2 / rxusrclk2
    // =========================================================================
    wire txusrclk2;
    wire rxusrclk2;

    BUFG_GT u_bufg_tx (
        .I      (txoutclk_out[0]),
        .CE     (1'b1),
        .CEMASK (1'b0),
        .CLR    (1'b0),
        .CLRMASK(1'b0),
        .DIV    (3'd0),
        .O      (txusrclk2)
    );

    BUFG_GT u_bufg_rx (
        .I      (rxoutclk_out[0]),
        .CE     (1'b1),
        .CEMASK (1'b0),
        .CLR    (1'b0),
        .CLRMASK(1'b0),
        .DIV    (3'd0),
        .O      (rxusrclk2)
    );

    assign o_tx_clk = txusrclk2;
    assign o_rx_clk = rxusrclk2;

    //==============================================================
    // CDC: tx_done/rx_done -> usrclk2
    //==============================================================
    reg tx_done_u1, tx_done_u2;
    always @(posedge txusrclk2 or posedge gth_reset_sync) begin
        if (gth_reset_sync) begin
            tx_done_u1 <= 1'b0;
            tx_done_u2 <= 1'b0;
        end else begin
            tx_done_u1 <= gtwiz_reset_tx_done_out[0];
            tx_done_u2 <= tx_done_u1;
        end
    end
    wire tx_done_usr = tx_done_u2;

    reg rx_done_u1, rx_done_u2;
    always @(posedge rxusrclk2 or posedge gth_reset_sync) begin
        if (gth_reset_sync) begin
            rx_done_u1 <= 1'b0;
            rx_done_u2 <= 1'b0;
        end else begin
            rx_done_u1 <= gtwiz_reset_rx_done_out[0];
            rx_done_u2 <= rx_done_u1;
        end
    end
    wire rx_done_usr = rx_done_u2;

    //==============================================================
    // userclk_active：freerun_clk 域生成
    //==============================================================
    reg tx_active_reg, rx_active_reg;

    always @(posedge freerun_clk or posedge gth_reset_sync) begin
        if (gth_reset_sync) begin
            tx_active_reg <= 1'b0;
            rx_active_reg <= 1'b0;
        end else begin
            if (txpmaresetdone_out[0])
                tx_active_reg <= 1'b1;
            if (rxpmaresetdone_out[0])
                rx_active_reg <= 1'b1;
        end
    end

    assign gtwiz_userclk_tx_active_in = {tx_active_reg};
    assign gtwiz_userclk_rx_active_in = {rx_active_reg};

    assign o_tx_active = tx_active_reg;
    assign o_rx_active = rx_active_reg;

    //==============================================================
    // CDC: tx_active_reg/rx_active_reg -> usrclk2
    //==============================================================
    reg tx_act_u1, tx_act_u2;
    always @(posedge txusrclk2 or posedge gth_reset_sync) begin
        if (gth_reset_sync) begin
            tx_act_u1 <= 1'b0;
            tx_act_u2 <= 1'b0;
        end else begin
            tx_act_u1 <= tx_active_reg;
            tx_act_u2 <= tx_act_u1;
        end
    end
    wire tx_active_usr = tx_act_u2;

    reg rx_act_u1, rx_act_u2;
    always @(posedge rxusrclk2 or posedge gth_reset_sync) begin
        if (gth_reset_sync) begin
            rx_act_u1 <= 1'b0;
            rx_act_u2 <= 1'b0;
        end else begin
            rx_act_u1 <= rx_active_reg;
            rx_act_u2 <= rx_act_u1;
        end
    end
    wire rx_active_usr = rx_act_u2;

    // =========================================================================
    // 6. GTH IP 实例化
    // =========================================================================
    gtwizard_ultrascale_0 u_gth (
        .gtwiz_userclk_tx_active_in      (gtwiz_userclk_tx_active_in),
        .gtwiz_userclk_rx_active_in      (gtwiz_userclk_rx_active_in),
        .gtwiz_reset_clk_freerun_in      (gtwiz_reset_clk_freerun_in),
        .gtwiz_reset_all_in              (gtwiz_reset_all_in),
        .gtwiz_reset_tx_pll_and_datapath_in(gtwiz_reset_tx_pll_and_datapath_in),
        .gtwiz_reset_tx_datapath_in      (gtwiz_reset_tx_datapath_in),
        .gtwiz_reset_rx_pll_and_datapath_in(gtwiz_reset_rx_pll_and_datapath_in),
        .gtwiz_reset_rx_datapath_in      (gtwiz_reset_rx_datapath_in),
        .gtwiz_reset_rx_cdr_stable_out   (gtwiz_reset_rx_cdr_stable_out),
        .gtwiz_reset_tx_done_out         (gtwiz_reset_tx_done_out),
        .gtwiz_reset_rx_done_out         (gtwiz_reset_rx_done_out),

        .gtwiz_userdata_tx_in            (gtwiz_userdata_tx_in),
        .gtwiz_userdata_rx_out           (gtwiz_userdata_rx_out),

        .gtrefclk01_in                   (gtrefclk01_in),
        .qpll1outclk_out                 (qpll1outclk_out),
        .qpll1outrefclk_out              (qpll1outrefclk_out),

        .gthrxn_in                       (gthrxn_in_vec),
        .gthrxp_in                       (gthrxp_in_vec),

        .loopback_in                     (i_loopback),
        .rxcdrhold_in                    (1'b0),
        .rxlpmen_in                      (1'b0),
        .rxslide_in                      ({1{i_rx_slide}}),

        .rxusrclk_in                     ({1{rxusrclk2}}),
        .rxusrclk2_in                    ({1{rxusrclk2}}),

        .txdiffctrl_in                   (5'b11000),
        .txpostcursor_in                 (5'b00000),
        .txprecursor_in                  (5'b00000),

        .txusrclk_in                     ({1{txusrclk2}}),
        .txusrclk2_in                    ({1{txusrclk2}}),

        .gthtxn_out                      (gthtxn_out_vec),
        .gthtxp_out                      (gthtxp_out_vec),

        .gtpowergood_out                 (gtpowergood_out),
        .rxoutclk_out                    (rxoutclk_out),
        .rxpmaresetdone_out              (rxpmaresetdone_out),
        .rxsliderdy_out                  (rxsliderdy_out),
        .txoutclk_out                    (txoutclk_out),
        .txpmaresetdone_out              (txpmaresetdone_out)
    );

    assign gthtxn_out   = gthtxn_out_vec[0];
    assign gthtxp_out   = gthtxp_out_vec[0];
    assign o_cdr_stable = gtwiz_reset_rx_cdr_stable_out[0];
    assign o_tx_done    = gtwiz_reset_tx_done_out[0];
    assign o_rx_done    = gtwiz_reset_rx_done_out[0];

    // =========================================================================
    // 7. 在 TX / RX userclk 域生成同步释放的 rst_n
    // =========================================================================
    reg [3:0] tx_rst_shift = 4'b0000;
    reg [3:0] rx_rst_shift = 4'b0000;

    always @(posedge o_tx_clk or posedge gth_reset_sync) begin
        if (gth_reset_sync)
            tx_rst_shift <= 4'b0000;
        else if (tx_done_usr && tx_active_usr)
            tx_rst_shift <= {tx_rst_shift[2:0], 1'b1};
        else
            tx_rst_shift <= 4'b0000;
    end
    assign o_tx_rst_n = tx_rst_shift[3];

    always @(posedge o_rx_clk or posedge gth_reset_sync) begin
        if (gth_reset_sync)
            rx_rst_shift <= 4'b0000;
        else if (rx_done_usr && rx_active_usr)
            rx_rst_shift <= {rx_rst_shift[2:0], 1'b1};
        else
            rx_rst_shift <= 4'b0000;
    end
    assign o_rx_rst_n = rx_rst_shift[3];

endmodule
