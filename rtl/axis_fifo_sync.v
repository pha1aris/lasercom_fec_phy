`timescale 1ns/1ps

module axis_fifo_sync #(
    parameter integer WIDTH = 33,
    parameter integer DEPTH = 1024  // 深度=words；建议是 2 的幂
)(
    input  wire               clk,
    input  wire               rst,

    input  wire [WIDTH-1:0]   s_axis_tdata,
    input  wire               s_axis_tvalid,
    output wire               s_axis_tready,

    output wire [WIDTH-1:0]   m_axis_tdata,
    output wire               m_axis_tvalid,
    input  wire               m_axis_tready
);
    // 用 xpm_fifo_sync 做 FWFT
    wire full, empty;
    wire [WIDTH-1:0] dout;
    wire wr_en = s_axis_tvalid && s_axis_tready;
    wire rd_en = m_axis_tvalid && m_axis_tready;

    assign s_axis_tready = ~full;
    assign m_axis_tvalid = ~empty;
    assign m_axis_tdata  = dout;

    // XPM 参数说明：
    // - READ_MODE="fwft"：empty=0 时 dout 就是当前可读数据，直到 rd_en 拉走
    // - FIFO_WRITE_DEPTH：写深度（单位=entries）
    xpm_fifo_sync #(
        .DOUT_RESET_VALUE    ("0"),
        .ECC_MODE            ("no_ecc"),
        .FIFO_MEMORY_TYPE    ("auto"),
        .FIFO_READ_LATENCY   (0),
        .FIFO_WRITE_DEPTH    (DEPTH),
        .FULL_RESET_VALUE    (0),
        .PROG_EMPTY_THRESH   (10),
        .PROG_FULL_THRESH    (DEPTH-10),
        .RD_DATA_COUNT_WIDTH ($clog2(DEPTH+1)),
        .READ_DATA_WIDTH     (WIDTH),
        .READ_MODE           ("fwft"),
        .SIM_ASSERT_CHK      (0),
        .USE_ADV_FEATURES    ("0000"),
        .WR_DATA_COUNT_WIDTH ($clog2(DEPTH+1)),
        .WRITE_DATA_WIDTH    (WIDTH)
    ) u_xpm_fifo_sync (
        .sleep         (1'b0),
        .rst           (rst),
        .wr_clk        (clk),
        .wr_en         (wr_en),
        .din           (s_axis_tdata),
        .full          (full),
        .overflow      (),

        .rd_en         (rd_en),
        .dout          (dout),
        .empty         (empty),
        .underflow     (),

        .data_valid    (),
        .rd_rst_busy   (),
        .wr_rst_busy   (),
        .prog_full     (),
        .prog_empty    (),
        .wr_data_count (),
        .rd_data_count (),
        .injectsbiterr (1'b0),
        .injectdbiterr (1'b0),
        .sbiterr       (),
        .dbiterr       ()
    );

endmodule
