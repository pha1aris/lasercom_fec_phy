`timescale 1ns / 1ps
// `include "global_defines.vh"

module fec_tx_fpga_top #(
    parameter integer W                = 32,
    parameter integer PAYLOAD_WORDS    = 16,
    parameter integer RS_K             = 229,
    parameter integer RS_N             = 255,
    // ★ 修改为 4096 以匹配参数约束：INTLV_D × 255 = FRAMES_PER_BLOCK × PAYLOAD_WORDS × 4
    parameter integer INTLV_D          = 4096,  
    parameter integer INTLV_N          = 255,
    parameter integer FRAMES_PER_BLOCK = 16384,
    parameter integer LOCK_THRESH      = 1024,
    parameter integer TEST_PRBS        = 1,
    parameter integer CORE_CLK_HZ      = 100_000_000,
    parameter integer UART_BAUD        = 115200,
    parameter integer PRINT_DIV        = 100_000_000
)(
    input  wire         sys_clk_p,
    input  wire         sys_clk_n,
    input  wire         sys_rst_n,

    input  wire         mgtrefclk0_x1y1_p,
    input  wire         mgtrefclk0_x1y1_n,

    output wire         uart_txd,
    input  wire         uart_rxd,

    input  wire         gthrxp_in,
    input  wire         gthrxn_in,
    output wire         gthtxp_out,
    output wire         gthtxn_out,

    input  wire [1:0]   sfp_loss,
    output wire [1:0]   tx_disable
);

    // =========================================================
    // 1. 基础配置
    // =========================================================
    assign tx_disable = 2'b00; 
    // TX 端不发送 UART 数据，始终置为 IDLE (1)
    assign uart_txd = 1'b1;

    // 时钟生成 [cite: 6]
    wire freerun_clk;
    wire core_clk;
    wire clk_locked;

    clk_wiz_sys u_clk_wiz (
        .clk_out1 (freerun_clk),
        .clk_out2 (core_clk),
        .clk_out3 (), // axi_clk unused
        .reset    (~sys_rst_n),
        .locked   (clk_locked),
        .clk_in1_p(sys_clk_p),
        .clk_in1_n(sys_clk_n)
    );

    wire logic_rst_n = sys_rst_n & clk_locked;
    wire logic_rst   = ~logic_rst_n;
    wire gth_reset_all = logic_rst;

    // =========================================================
    // 2. GTH Core (TX Mode)
    // =========================================================
    wire        tx_usr_clk;
    wire        tx_rst_n;
    wire        tx_done;
    wire        tx_active;
    wire [W-1:0] tx_data_to_gth;

    gth_raw_top #(
        .W (W)
    ) u_gth_raw (
        .freerun_clk        (freerun_clk),
        .gth_reset_all      (gth_reset_all),

        .mgtrefclk0_x1y1_p  (mgtrefclk0_x1y1_p),
        .mgtrefclk0_x1y1_n  (mgtrefclk0_x1y1_n),
        
        // 物理端口连接（RX 端口必须连，防止 EDA 工具优化报错，但逻辑不使用）
        .gthrxp_in          (gthrxp_in),
        .gthrxn_in          (gthrxn_in),
        .gthtxp_out         (gthtxp_out),
        .gthtxn_out         (gthtxn_out),

        .i_loopback         (3'b000), 
        .o_pll_locked       (),

        // TX 接口
        .o_tx_clk           (tx_usr_clk),
        .o_tx_rst_n         (tx_rst_n),
        .o_tx_done          (tx_done),
        .o_tx_active        (tx_active),
        .i_tx_data          (tx_data_to_gth),

        // RX 接口 (TX板不关心接收，悬空)
        .o_rx_clk           (),
        .o_rx_rst_n         (),
        .o_rx_done          (),
        .o_rx_active        (),
        .o_cdr_stable       (),
        .o_rx_data          (),
        .i_rx_slide         (1'b0)
    );

    // TX 状态同步 CDC
    reg tx_done_cdc1, tx_done_cdc2;
    reg tx_rstn_cdc1, tx_rstn_cdc2;
    reg tx_act_cdc1, tx_act_cdc2;

    always @(posedge core_clk or posedge logic_rst) begin
        if (logic_rst) begin
            tx_done_cdc1 <= 0; tx_done_cdc2 <= 0;
            tx_rstn_cdc1 <= 0; tx_rstn_cdc2 <= 0;
            tx_act_cdc1  <= 0; tx_act_cdc2  <= 0;
        end else begin
            tx_done_cdc1 <= tx_done;   tx_done_cdc2 <= tx_done_cdc1;
            tx_rstn_cdc1 <= tx_rst_n;  tx_rstn_cdc2 <= tx_rstn_cdc1;
            tx_act_cdc1  <= tx_active; tx_act_cdc2  <= tx_act_cdc1;
        end
    end

    wire tx_path_rst_n = logic_rst_n & tx_rstn_cdc2 & tx_done_cdc2;
    wire tx_path_rst   = ~tx_path_rst_n;
    wire tx_active_core = tx_act_cdc2;

    // =========================================================
    // 3. 数据源 (PRBS) & FEC TX
    // =========================================================
    wire [7:0]   prbs_tx_data;
    wire         prbs_tx_ready;
    wire [W-1:0] fec_tx_data_line;
    
    // 只有当 GTH TX 准备好 且 FEC 准备好时，PRBS 才使能
    wire prbs_en = tx_active_core & prbs_tx_ready;

    gtwizard_ultrascale_0_prbs_any #(
        .CHK_MODE    (0),
        .NBITS       (8)
    ) u_prbs_gen_tx (
        .RST      (tx_path_rst),
        .CLK      (core_clk),
        .DATA_IN  (8'd0),
        .EN       (prbs_en),
        .DATA_OUT (prbs_tx_data),
        .i_force_lock (1'b0)
    );

    fec_tx #(
        .W(W),
        .PAYLOAD_WORDS(PAYLOAD_WORDS),
        .RS_K(RS_K),
        .RS_N(RS_N),
        .INTLV_D(INTLV_D),
        .INTLV_N(INTLV_N),
        .FRAMES_PER_BLOCK(FRAMES_PER_BLOCK)
    ) u_fec_tx (
        .line_clk   (tx_usr_clk),
        .core_clk   (core_clk),
        .rst_n      (tx_path_rst_n),
        .scrambler_en(1'b0), // 可根据需要改为 1
        .i_data     (prbs_tx_data),
        .i_valid    (prbs_en),
        .i_ready    (prbs_tx_ready),
        .o_tx_data_line(fec_tx_data_line),
        .o_tx_valid_line(), // GTH 实际上是流式发送，可忽略 valid
        .o_tx_frame_index()
    );

    assign tx_data_to_gth = fec_tx_data_line;

endmodule