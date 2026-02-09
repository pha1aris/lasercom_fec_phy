`timescale 1ns/1ps

module fec_tx #(
    parameter integer W                 = 32,
    parameter integer PAYLOAD_WORDS     = 16,
    parameter integer RS_K              = 229,
    parameter integer RS_N              = 255,
    parameter integer INTLV_D           = 4808,
    parameter integer INTLV_N           = 255,
    parameter integer FRAMES_PER_BLOCK  = 255 
)(
    input  wire             line_clk,
    input  wire             core_clk,
    input  wire             rst_n,
    // 原始 8bit 数据
    input  wire [7:0]       i_data,
    input  wire             i_valid,
    output wire             i_ready,
    // 输出给 GTH TX 的 32bit 数据
    input  wire             scrambler_en,
    output wire [31:0]      o_tx_data_line,
    output wire             o_tx_valid_line,
    output wire [15:0]      o_tx_frame_index
);
    // 顶层传进来的异步复位（已经包含 logic_rst_n & tx_rst_n & tx_done）
    wire rst = ~rst_n;
    wire [W-1:0]     o_tx_data;
    wire             o_tx_valid;
    // -------- 各时钟域同步复位（可用于本模块内部状态机 / 监控） --------
    reg core_rst_d0, core_rst_d1;
    always @(posedge core_clk or posedge rst) begin
        if (rst) begin
            core_rst_d0 <= 1'b1;
            core_rst_d1 <= 1'b1;
        end else begin
            core_rst_d0 <= 1'b0;
            core_rst_d1 <= core_rst_d0;
        end
    end
    wire core_rst_sync = core_rst_d1;

    reg line_rst_d0, line_rst_d1;
    always @(posedge line_clk or posedge rst) begin
        if (rst) begin
            line_rst_d0 <= 1'b1;
            line_rst_d1 <= 1'b1;
        end else begin
            line_rst_d0 <= 1'b0;
            line_rst_d1 <= line_rst_d0;
        end
    end
    wire line_rst_sync = line_rst_d1;

    // ================= RS 编码 =================
    wire [7:0] enc_data;
    wire       enc_valid;
    wire       enc_last;
    wire       xpm_input_tready;

    wire enc_fifo_rdy;
    assign i_ready = enc_fifo_rdy;

    rs_encode_frontend  u_rs_encode_frontend (
        .clk                    (core_clk),  // 上游 8bit 数据时钟
        .rst                    (rst),
        .enc_clk                (core_clk),
        .fifo_input_rdy         (enc_fifo_rdy),
        .data_i                 (i_data),
        .data_valid_i           (i_valid),

        .m_axis_output_tready   (xpm_input_tready),
        .m_axis_output_tlast    (enc_last),
        .m_axis_output_tdata    (enc_data),
        .m_axis_output_tvalid   (enc_valid)
    );

    // ================= 交织器 ==================
    wire        intlv_valid;
    wire [7:0]  intlv_data;
    wire        intlv_block_start;
    wire        intlv_out_ready;

    rs_interleaver_xpm #(
        .D (INTLV_D),
        .N (INTLV_N)
    ) u_interleaver (
        .clk            (core_clk),
        .rst            (rst),
        .in_valid       (enc_valid),
        .in_data        (enc_data),
        .in_ready       (xpm_input_tready),
        .out_ready      (intlv_out_ready),
        .out_valid      (intlv_valid),
        .out_data       (intlv_data),
        .out_block_start(intlv_block_start)
    );

    // =============== 8bit → 32bit 打包 + 块起始 ===============
    wire [31:0] gb_data;
    wire        gb_valid;
    wire        gb_block_start;
    wire        gb_ready;

    gearbox_8to32_bs u_gb_8to32 (
        .clk            (core_clk),
        .rst            (rst),

        .in_data        (intlv_data),
        .in_valid       (intlv_valid),
        .in_block_start (intlv_block_start),
        .in_ready       (intlv_out_ready),

        .out_ready      (gb_ready),
        .out_data       (gb_data),
        .out_valid      (gb_valid),
        .out_block_start(gb_block_start)
    );

    wire        tx32_wr_ready_raw;
    wire        tx32_wr_ready;   
    wire [15:0] tx_block_id;
    wire [15:0] tx_frame_in_block;

    // ================= 帧封装器 =================
    fso_framer #(
      .W                (W),
      .PAYLOAD_WORDS    (PAYLOAD_WORDS),
      .FRAMES_PER_BLOCK (FRAMES_PER_BLOCK)
    ) u_fso_framer (
      .clk                     (core_clk),
      .rst_n                   (rst_n),

      .i_payload_data          (gb_data),
      .i_payload_valid         (gb_valid),
      .i_payload_block_start   (gb_block_start),  // 边界信息
      .scrambler_en            (scrambler_en),
      .o_payload_ready         (gb_ready),

      .i_tx_ready              (tx32_wr_ready),
      .o_tx_data               (o_tx_data),
      .o_tx_valid              (o_tx_valid),
      .o_frame_in_block        (tx_frame_in_block),
      .o_block_id              (tx_block_id),
      .o_frame_index           (o_tx_frame_index)
    );

    // ================= async FIFO: core_clk → line_clk ==============
    wire        tx32_fifo_empty;
    wire        tx32_fifo_full;
    wire        tx32_fifo_wrstbsy;
    wire        tx32_fifo_rrstbsy;
    wire [31:0] tx32_fifo_dout;
    wire        tx32_fifo_rd_en;
    wire [11:0]  tx_fifo_rdcnt;
    wire [11:0]  tx_fifo_wrcnt;

    // “物理” ready：只看 FIFO 自身是否能写
    assign tx32_wr_ready_raw = ~tx32_fifo_full & ~tx32_fifo_wrstbsy;

    // *** 最简单反压：framer 直接看 FIFO 的物理 ready
    assign tx32_wr_ready = tx32_wr_ready_raw;

    // line_clk 域同步后的 reset 给 FIFO
    reg rst_sync_d0, rst_sync_d1;
    always @(posedge line_clk or posedge rst) begin
        if (rst) begin
            rst_sync_d0 <= 1'b1;
            rst_sync_d1 <= 1'b1;
        end else begin
            rst_sync_d0 <= 1'b0;
            rst_sync_d1 <= rst_sync_d0;
        end
    end
    // FWFT 
    async_fifo_32w_32r u_tx_fifo (
        .rst           (rst_sync_d1),  
        .wr_clk        (core_clk),
        .rd_clk        (line_clk),
        .din           (o_tx_data),
        .wr_en         (o_tx_valid && tx32_wr_ready_raw), // 非满就写
        .rd_en         (tx32_fifo_rd_en),                 // 非空就读（见下）
        .dout          (tx32_fifo_dout),
        .full          (tx32_fifo_full),
        .empty         (tx32_fifo_empty),
        .rd_data_count (tx_fifo_rdcnt),
        .wr_data_count (tx_fifo_wrcnt),
        .wr_rst_busy   (tx32_fifo_wrstbsy),
        .rd_rst_busy   (tx32_fifo_rrstbsy)
    );

// ----------------------------------------------------------------
// line_clk 域：按“整帧突发”从 TX FIFO 读出
// ----------------------------------------------------------------
    localparam [31:0] IDLE_WORD = 32'h0707_0707;
    // 一帧总 word 数：2(preamble) + 1(header) + PAYLOAD_WORDS + 1(CRC)
    localparam integer FRAME_WORDS = PAYLOAD_WORDS + 4;

    localparam [1:0] L_IDLE  = 2'd0;
    localparam [1:0] L_BURST = 2'd1;

    reg [1:0]  lstate;
    reg [15:0] burst_rem;            // 剩余要发的 word 数
    reg        tx_fifo_rd_en_reg;
    reg [31:0] tx_data_out_reg;
    reg        tx_valid_out_reg;
    reg        burst_underflow_err;

    wire fifo_has_one_frame =
        (!tx32_fifo_rrstbsy) &&
        (!tx32_fifo_empty)  &&
        (tx_fifo_rdcnt >= FRAME_WORDS[11:0]);   // tx_fifo_rdcnt 是 12bit

    always @(posedge line_clk or posedge rst) begin
        if (rst) begin
            lstate              <= L_IDLE;
            burst_rem           <= 16'd0;
            tx_fifo_rd_en_reg   <= 1'b0;
            tx_data_out_reg     <= IDLE_WORD;
            tx_valid_out_reg    <= 1'b0;
            burst_underflow_err <= 1'b0;
        end else begin
            tx_fifo_rd_en_reg <= 1'b0;

            if (tx32_fifo_rrstbsy) begin
                lstate           <= L_IDLE;
                burst_rem        <= 16'd0;
                tx_data_out_reg  <= IDLE_WORD;
                tx_valid_out_reg <= 1'b0;
            end else begin
                case (lstate)
                    L_IDLE: begin
                        // 平时发 idle（帧间空闲允许）
                        tx_data_out_reg  <= IDLE_WORD;
                        tx_valid_out_reg <= 1'b0;

                        if (fifo_has_one_frame) begin
                            lstate            <= L_BURST;
                            burst_rem         <= FRAME_WORDS[15:0];

                            tx_fifo_rd_en_reg <= 1'b1;        
                            tx_data_out_reg   <= tx32_fifo_dout;
                            tx_valid_out_reg  <= 1'b1;

                            burst_rem         <= FRAME_WORDS[15:0] - 16'd1;
                        end
                    end

                    L_BURST: begin
                        if (tx32_fifo_empty) begin
                            burst_underflow_err <= 1'b1;
                            lstate              <= L_IDLE;
                            burst_rem           <= 16'd0;
                            tx_data_out_reg     <= IDLE_WORD;
                            tx_valid_out_reg    <= 1'b0;
                        end else begin
                            tx_fifo_rd_en_reg <= 1'b1;
                            tx_data_out_reg   <= tx32_fifo_dout;
                            tx_valid_out_reg  <= 1'b1;

                            if (burst_rem == 16'd1) begin
                                lstate    <= L_IDLE;
                                burst_rem <= 16'd0;
                            end else begin
                                burst_rem <= burst_rem - 16'd1;
                            end
                        end
                    end

                    default: begin
                        lstate           <= L_IDLE;
                        burst_rem        <= 16'd0;
                        tx_data_out_reg  <= IDLE_WORD;
                        tx_valid_out_reg <= 1'b0;
                    end
                endcase
            end
        end
    end

    assign tx32_fifo_rd_en = tx_fifo_rd_en_reg;
    assign o_tx_data_line  = tx_data_out_reg;
    assign o_tx_valid_line = tx_valid_out_reg;



endmodule
