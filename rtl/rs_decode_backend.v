`timescale 1ns/1ps

module rs_decode_backend #(
    parameter integer RS_N           = 255,
    parameter integer OUT_FIFO_DEPTH = 1024,   // 每路 decoder 输出 FIFO 深度(单位=byte)
    parameter integer ORDER_DEPTH    = 64      // order token FIFO 深度(单位=codeword)
)(
    input  wire        rst,
    input  wire        core_clk,
    input  wire        output_clk,   // 目前未用（可等于 core_clk）

    // 8-bit AXI Stream Input（来自 deinterleaver）
    input  wire [7:0]  s_axis_input_tdata,
    input  wire        s_axis_input_tvalid,
    input  wire        s_axis_input_tlast,
    output wire        s_axis_input_tready,

    // 8-bit AXI Stream Output（给后级，如 PRBS checker）
    output wire [7:0]  output_tdata,
    output wire        output_tvalid,
    input  wire        output_tready,

    // Statistics Outputs
    output wire [31:0] o_stat_cnt0,
    output wire [31:0] o_stat_nz_cnt0,
    output wire [31:0] o_stat_cnt1,
    output wire [31:0] o_stat_nz_cnt1,
    output wire [31:0] o_stat_fail_cnt0,
    output wire [31:0] o_stat_fail_cnt1
);

    wire clk = core_clk;
    localparam integer IN_AW = $clog2(RS_N); // 255 -> 8

    // ============================================================
    // 0) 两块输入码字缓冲：每块缓存 1 个 RS_N 字节码字
    // ============================================================
    (* ram_style="distributed" *) reg [7:0] inbuf0_mem [0:RS_N-1];
    (* ram_style="distributed" *) reg [7:0] inbuf1_mem [0:RS_N-1];

    reg [IN_AW:0] inbuf0_cnt, inbuf1_cnt;   // 接收计数 0..RS_N
    reg           inbuf0_full, inbuf1_full; // 好码字才置 1（等待提交给 decoder）

    // 码字接收状态：锁定一个 buffer 直到看到输入 tlast
    reg fill_active;
    reg fill_sel;   // 0->buf0, 1->buf1

    // drop 模式：遇到“长帧”后丢弃直到输入 tlast
    reg drop_active;

    // ============================================================
    // 1) order_fifo：记录码字输出顺序（0->路0，1->路1）
    // ============================================================
    wire order_full, order_empty;
    wire order_dout;
    wire order_wr, order_rd;

    // ============================================================
    // 2) feed0/feed1：表示该 buffer 正在被读出喂给 decoder
    //    ★ 直接用 feed0/feed1 作为“busy”，不要绑在输出是否读走
    // ============================================================
    reg [IN_AW-1:0] rd_ptr0, rd_ptr1;
    reg [IN_AW:0]   rd_cnt0, rd_cnt1;
    reg             feed0, feed1;

    // buffer 是否可用于“接收新码字”
    // 不能 full；也不能正在被读(feed*)，否则会写坏 mem
    wire buf0_can_take_new = (~inbuf0_full) & (~feed0);
    wire buf1_can_take_new = (~inbuf1_full) & (~feed1);

    wire choose_buf0 = buf0_can_take_new;
    wire choose_buf1 = (~buf0_can_take_new) & buf1_can_take_new;
    wire have_any_buf = (buf0_can_take_new | buf1_can_take_new);

    // fill_active 时必须继续写同一个 buf，因此检查对应 buf 的可写性
    wire sel_can_accept = (fill_sel==1'b0) ? buf0_can_take_new : buf1_can_take_new;

    wire ready_core = fill_active ? sel_can_accept : have_any_buf;

    // drop_active 时：我们要尽快把这一帧吃完直到 tlast，所以 ready=1
    assign s_axis_input_tready = (~rst) & (drop_active ? 1'b1 : ((~order_full) & ready_core));

    wire in_fire      = s_axis_input_tvalid && s_axis_input_tready;
    wire in_last_fire = in_fire && s_axis_input_tlast;

    // 当前写入目标：fill_active 用 fill_sel；否则用 choose_buf0/1 决定
    wire cur_sel = fill_active ? fill_sel : (choose_buf0 ? 1'b0 : 1'b1);

    wire [IN_AW:0] cur_cnt = (cur_sel==1'b0) ? inbuf0_cnt : inbuf1_cnt;

    // “好码字 last”：输入 last 且长度恰好 RS_N
    wire good_last_fire = (!drop_active) && in_last_fire && (cur_cnt == (RS_N-1));

    // token 只在“好码字 last”写入
    assign order_wr = good_last_fire;

    rs_backend_fifo #(
        .WIDTH (1),
        .DEPTH (ORDER_DEPTH)
    ) u_order_fifo (
        .clk   (clk),
        .rst   (rst),
        .din   (cur_sel),
        .wr_en (order_wr),
        .full  (order_full),
        .dout  (order_dout),
        .rd_en (order_rd),
        .empty (order_empty)
    );

    // ============================================================
    // ★ 关键修复：start_feed0/1 只表示“开始提交该 buffer 给 decoder”
    //    提交的同拍：清 inbuf*_full / inbuf*_cnt（避免二处驱动）
    // ============================================================
    wire start_feed0 = (!feed0) && inbuf0_full;
    wire start_feed1 = (!feed1) && inbuf1_full;

    // ============================================================
    // 3) 输入收码字：严格依赖输入 tlast 还原码字边界
    // ============================================================
    reg err_len_short;
    reg err_len_long;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fill_active   <= 1'b0;
            fill_sel      <= 1'b0;

            inbuf0_cnt    <= 'd0;
            inbuf1_cnt    <= 'd0;
            inbuf0_full   <= 1'b0;
            inbuf1_full   <= 1'b0;

            drop_active   <= 1'b0;

            err_len_short <= 1'b0;
            err_len_long  <= 1'b0;
        end else begin
            // 提交给 decoder 的同拍，清 full/计数（只在此 always 写）
            if (start_feed0) begin
                inbuf0_full <= 1'b0;
                inbuf0_cnt  <= 'd0;
            end
            if (start_feed1) begin
                inbuf1_full <= 1'b0;
                inbuf1_cnt  <= 'd0;
            end

            // drop 模式：直到吃到 tlast 才退出
            if (drop_active) begin
                if (in_last_fire) begin
                    drop_active <= 1'b0;
                    fill_active <= 1'b0;
                    // 不强行清另一侧计数（由 start_feed 清，或自然接收清）
                end
            end else begin
                // 新码字开始：第一次 in_fire 时锁定 fill_sel
                if (!fill_active && in_fire) begin
                    fill_active <= 1'b1;
                    fill_sel    <= choose_buf0 ? 1'b0 : 1'b1;
                end

                if (in_fire) begin
                    if (cur_sel==1'b0) begin
                        // 写 buf0
                        if (inbuf0_cnt < RS_N) begin
                            inbuf0_mem[inbuf0_cnt[IN_AW-1:0]] <= s_axis_input_tdata;
                            inbuf0_cnt <= inbuf0_cnt + 1'b1;
                        end else begin
                            // 长帧：进入 drop，丢弃直到 tlast
                            err_len_long <= 1'b1;
                            drop_active  <= 1'b1;
                            fill_active  <= 1'b0;
                            inbuf0_cnt   <= 'd0;
                            inbuf0_full  <= 1'b0;
                        end

                        if (s_axis_input_tlast) begin
                            if (cur_cnt != (RS_N-1)) begin
                                // 短帧：丢弃
                                err_len_short <= 1'b1;
                                inbuf0_cnt    <= 'd0;
                                inbuf0_full   <= 1'b0;
                            end else begin
                                // 好码字：置 full（order_wr 同拍写 token）
                                inbuf0_full <= 1'b1;
                            end
                            fill_active <= 1'b0;
                        end
                    end else begin
                        // 写 buf1
                        if (inbuf1_cnt < RS_N) begin
                            inbuf1_mem[inbuf1_cnt[IN_AW-1:0]] <= s_axis_input_tdata;
                            inbuf1_cnt <= inbuf1_cnt + 1'b1;
                        end else begin
                            err_len_long <= 1'b1;
                            drop_active  <= 1'b1;
                            fill_active  <= 1'b0;
                            inbuf1_cnt   <= 'd0;
                            inbuf1_full  <= 1'b0;
                        end

                        if (s_axis_input_tlast) begin
                            if (cur_cnt != (RS_N-1)) begin
                                err_len_short <= 1'b1;
                                inbuf1_cnt    <= 'd0;
                                inbuf1_full   <= 1'b0;
                            end else begin
                                inbuf1_full <= 1'b1;
                            end
                            fill_active <= 1'b0;
                        end
                    end
                end
            end
        end
    end

    // ============================================================
    // 4) 将 inbuf0/inbuf1 喂给各自 decoder（按 decoder 的 tready 推进）
    // ============================================================
    wire [7:0] dec_in_data0 = inbuf0_mem[rd_ptr0];
    wire [7:0] dec_in_data1 = inbuf1_mem[rd_ptr1];

    wire dec_in_last0 = (rd_cnt0 == RS_N-1);
    wire dec_in_last1 = (rd_cnt1 == RS_N-1);

    wire s_axis_input_tready0, s_axis_input_tready1;

    wire dec_in_fire0 = feed0 && s_axis_input_tready0;
    wire dec_in_fire1 = feed1 && s_axis_input_tready1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            feed0   <= 1'b0;
            feed1   <= 1'b0;
            rd_ptr0 <= 'd0;
            rd_ptr1 <= 'd0;
            rd_cnt0 <= 'd0;
            rd_cnt1 <= 'd0;
        end else begin
            // start feed0：只要 buf0_full 就提交（不再依赖“输出读走 tlast”）
            if (!feed0 && inbuf0_full) begin
                feed0   <= 1'b1;
                rd_ptr0 <= 'd0;
                rd_cnt0 <= 'd0;
            end
            // start feed1
            if (!feed1 && inbuf1_full) begin
                feed1   <= 1'b1;
                rd_ptr1 <= 'd0;
                rd_cnt1 <= 'd0;
            end

            // feed0 推进：只有 decoder 接收(ready) 才前进
            if (dec_in_fire0) begin
                if (dec_in_last0) begin
                    feed0 <= 1'b0; // ★忙状态到此为止：输入喂完就算完成
                end else begin
                    rd_ptr0 <= rd_ptr0 + 1'b1;
                    rd_cnt0 <= rd_cnt0 + 1'b1;
                end
            end

            // feed1 推进
            if (dec_in_fire1) begin
                if (dec_in_last1) begin
                    feed1 <= 1'b0;
                end else begin
                    rd_ptr1 <= rd_ptr1 + 1'b1;
                    rd_cnt1 <= rd_cnt1 + 1'b1;
                end
            end
        end
    end

    wire [7:0] s_axis_input_tdata0  = dec_in_data0;
    wire       s_axis_input_tvalid0 = feed0;
    wire       s_axis_input_tlast0  = feed0 && dec_in_last0;

    wire [7:0] s_axis_input_tdata1  = dec_in_data1;
    wire       s_axis_input_tvalid1 = feed1;
    wire       s_axis_input_tlast1  = feed1 && dec_in_last1;

    // ============================================================
    // 5) 两个 RS 解码 IP
    // ============================================================
    wire [7:0] m_axis_output_tdata0, m_axis_output_tdata1;
    wire       m_axis_output_tvalid0, m_axis_output_tvalid1;
    wire       m_axis_output_tlast0,  m_axis_output_tlast1;

    wire [7:0] m_axis_stat_tdata0, m_axis_stat_tdata1;
    wire       m_axis_stat_tvalid0, m_axis_stat_tvalid1;

    wire event_s_input_tlast_missing0;
    wire event_s_input_tlast_unexpected0;
    wire event_s_ctrl_tdata_invalid0;

    wire event_s_input_tlast_missing1;
    wire event_s_input_tlast_unexpected1;
    wire event_s_ctrl_tdata_invalid1;

    wire decoder_out_ready0, decoder_out_ready1;

    rs_decoder_0 Decoder_U0 (
      .aclk                           (clk),

      .s_axis_input_tdata             (s_axis_input_tdata0),
      .s_axis_input_tvalid            (s_axis_input_tvalid0),
      .s_axis_input_tlast             (s_axis_input_tlast0),
      .s_axis_input_tready            (s_axis_input_tready0),

      .m_axis_output_tdata            (m_axis_output_tdata0),
      .m_axis_output_tvalid           (m_axis_output_tvalid0),
      .m_axis_output_tready           (decoder_out_ready0),
      .m_axis_output_tlast            (m_axis_output_tlast0),

      .m_axis_stat_tdata              (m_axis_stat_tdata0),
      .m_axis_stat_tvalid             (m_axis_stat_tvalid0),
      .m_axis_stat_tready             (1'b1),

      .event_s_input_tlast_missing    (event_s_input_tlast_missing0),
      .event_s_input_tlast_unexpected (event_s_input_tlast_unexpected0),
      .event_s_ctrl_tdata_invalid     (event_s_ctrl_tdata_invalid0)
    );

    rs_decoder_0 Decoder_U1 (
      .aclk                           (clk),

      .s_axis_input_tdata             (s_axis_input_tdata1),
      .s_axis_input_tvalid            (s_axis_input_tvalid1),
      .s_axis_input_tlast             (s_axis_input_tlast1),
      .s_axis_input_tready            (s_axis_input_tready1),

      .m_axis_output_tdata            (m_axis_output_tdata1),
      .m_axis_output_tvalid           (m_axis_output_tvalid1),
      .m_axis_output_tready           (decoder_out_ready1),
      .m_axis_output_tlast            (m_axis_output_tlast1),

      .m_axis_stat_tdata              (m_axis_stat_tdata1),
      .m_axis_stat_tvalid             (m_axis_stat_tvalid1),
      .m_axis_stat_tready             (1'b1),

      .event_s_input_tlast_missing    (event_s_input_tlast_missing1),
      .event_s_input_tlast_unexpected (event_s_input_tlast_unexpected1),
      .event_s_ctrl_tdata_invalid     (event_s_ctrl_tdata_invalid1)
    );

    // ============================================================
    // 6) 两路 decoder 输出各进一个 FIFO（存 {tlast,data}）
    // ============================================================
    wire [8:0] fifo0_din  = {m_axis_output_tlast0, m_axis_output_tdata0};
    wire       fifo0_wr   = m_axis_output_tvalid0 && decoder_out_ready0;

    wire [8:0] fifo1_din  = {m_axis_output_tlast1, m_axis_output_tdata1};
    wire       fifo1_wr   = m_axis_output_tvalid1 && decoder_out_ready1;

    wire [8:0] fifo0_dout, fifo1_dout;
    wire       fifo0_full, fifo0_empty;
    wire       fifo1_full, fifo1_empty;

    // 输出永不阻塞 decoder（除非 FIFO 真满）
    assign decoder_out_ready0 = ~fifo0_full;
    assign decoder_out_ready1 = ~fifo1_full;

    wire fifo0_rd, fifo1_rd;

    rs_backend_fifo #(
        .WIDTH (9),
        .DEPTH (OUT_FIFO_DEPTH)
    ) u_out_fifo0 (
        .clk   (clk),
        .rst   (rst),
        .din   (fifo0_din),
        .wr_en (fifo0_wr),
        .full  (fifo0_full),
        .dout  (fifo0_dout),
        .rd_en (fifo0_rd),
        .empty (fifo0_empty)
    );

    rs_backend_fifo #(
        .WIDTH (9),
        .DEPTH (OUT_FIFO_DEPTH)
    ) u_out_fifo1 (
        .clk   (clk),
        .rst   (rst),
        .din   (fifo1_din),
        .wr_en (fifo1_wr),
        .full  (fifo1_full),
        .dout  (fifo1_dout),
        .rd_en (fifo1_rd),
        .empty (fifo1_empty)
    );


// ============================================================
//  状态监控部分（RS Decoder IP 事件/统计）
//  放置位置：Decoder_U0 / Decoder_U1 实例化之后
// ============================================================

// ---------------- event counters + sticky ----------------
reg [31:0] miss_cnt0, unexp_cnt0, ctrl_inv_cnt0;
reg [31:0] miss_cnt1, unexp_cnt1, ctrl_inv_cnt1;

// sticky：事件脉冲可能很短（手册也提醒别漏），用 sticky 保留到复位
reg miss_sticky0, unexp_sticky0, ctrl_inv_sticky0;
reg miss_sticky1, unexp_sticky1, ctrl_inv_sticky1;

always @(posedge clk or posedge rst) begin
  if (rst) begin
    miss_cnt0       <= 32'd0;
    unexp_cnt0      <= 32'd0;
    ctrl_inv_cnt0   <= 32'd0;
    miss_cnt1       <= 32'd0;
    unexp_cnt1      <= 32'd0;
    ctrl_inv_cnt1   <= 32'd0;

    miss_sticky0    <= 1'b0;
    unexp_sticky0   <= 1'b0;
    ctrl_inv_sticky0<= 1'b0;
    miss_sticky1    <= 1'b0;
    unexp_sticky1   <= 1'b0;
    ctrl_inv_sticky1<= 1'b0;
  end else begin
    // U0 events
    if (event_s_input_tlast_missing0) begin
      miss_cnt0    <= miss_cnt0 + 1'b1;
      miss_sticky0 <= 1'b1;
    end
    if (event_s_input_tlast_unexpected0) begin
      unexp_cnt0    <= unexp_cnt0 + 1'b1;
      unexp_sticky0 <= 1'b1;
    end
    if (event_s_ctrl_tdata_invalid0) begin
      ctrl_inv_cnt0    <= ctrl_inv_cnt0 + 1'b1;
      ctrl_inv_sticky0 <= 1'b1;
    end

    // U1 events
    if (event_s_input_tlast_missing1) begin
      miss_cnt1    <= miss_cnt1 + 1'b1;
      miss_sticky1 <= 1'b1;
    end
    if (event_s_input_tlast_unexpected1) begin
      unexp_cnt1    <= unexp_cnt1 + 1'b1;
      unexp_sticky1 <= 1'b1;
    end
    if (event_s_ctrl_tdata_invalid1) begin
      ctrl_inv_cnt1    <= ctrl_inv_cnt1 + 1'b1;
      ctrl_inv_sticky1 <= 1'b1;
    end
  end
end

// ---------------- stat counters ----------------
// 规范写法：stat_fire = tvalid&tready（你现在 tready=1，但这样以后可扩展）
wire stat_fire0 = m_axis_stat_tvalid0 & 1'b1; // m_axis_stat_tready0 固定 1
wire stat_fire1 = m_axis_stat_tvalid1 & 1'b1;

reg [31:0] stat_cnt0, stat_cnt1;
reg [31:0] stat_nz_cnt0, stat_nz_cnt1;
reg [7:0]  stat_last0, stat_last1;

// 可选：把“最近一次非0 stat”也记下来，方便定位（可删）
reg [7:0]  stat_last_nz0, stat_last_nz1;

// 可选：统计某些 bit（如果你后面确定 FAIL/ERR_FOUND 在哪一位，可以在这里直接加）
reg [31:0] stat_bit0_cnt0, stat_bit0_cnt1; // 示例：统计 stat[0]==1 的次数

always @(posedge clk or posedge rst) begin
  if (rst) begin
    stat_cnt0       <= 32'd0;
    stat_nz_cnt0    <= 32'd0;
    stat_last0      <= 8'd0;
    stat_last_nz0   <= 8'd0;
    stat_bit0_cnt0  <= 32'd0;
  end else if (stat_fire0) begin
    stat_cnt0  <= stat_cnt0 + 1'b1;
    stat_last0 <= m_axis_stat_tdata0;

    if (m_axis_stat_tdata0 != 8'd0) begin
      stat_nz_cnt0  <= stat_nz_cnt0 + 1'b1;
      stat_last_nz0 <= m_axis_stat_tdata0;
    end

    if (m_axis_stat_tdata0[0])
      stat_bit0_cnt0 <= stat_bit0_cnt0 + 1'b1;
  end
end

always @(posedge clk or posedge rst) begin
  if (rst) begin
    stat_cnt1       <= 32'd0;
    stat_nz_cnt1    <= 32'd0;
    stat_last1      <= 8'd0;
    stat_last_nz1   <= 8'd0;
    stat_bit0_cnt1  <= 32'd0;
  end else if (stat_fire1) begin
    stat_cnt1  <= stat_cnt1 + 1'b1;
    stat_last1 <= m_axis_stat_tdata1;

    if (m_axis_stat_tdata1 != 8'd0) begin
      stat_nz_cnt1  <= stat_nz_cnt1 + 1'b1;
      stat_last_nz1 <= m_axis_stat_tdata1;
    end

    if (m_axis_stat_tdata1[0])
      stat_bit0_cnt1 <= stat_bit0_cnt1 + 1'b1;
  end
end

// ---------------- optional simulation prints ----------------
// 上板建议关掉；仿真时定位很快
`ifdef SIM
always @(posedge clk) begin
  if (!rst) begin
    if (event_s_input_tlast_missing0)    $display("[%0t] DEC0 TLAST_MISSING",    $time);
    if (event_s_input_tlast_unexpected0) $display("[%0t] DEC0 TLAST_UNEXPECTED", $time);
    if (event_s_ctrl_tdata_invalid0)     $display("[%0t] DEC0 CTRL_TDATA_INVALID",$time);
    if (stat_fire0 && (m_axis_stat_tdata0 != 8'h00))
      $display("[%0t] DEC0 STAT=%02x", $time, m_axis_stat_tdata0);

    if (event_s_input_tlast_missing1)    $display("[%0t] DEC1 TLAST_MISSING",    $time);
    if (event_s_input_tlast_unexpected1) $display("[%0t] DEC1 TLAST_UNEXPECTED", $time);
    if (event_s_ctrl_tdata_invalid1)     $display("[%0t] DEC1 CTRL_TDATA_INVALID",$time);
    if (stat_fire1 && (m_axis_stat_tdata1 != 8'h00))
      $display("[%0t] DEC1 STAT=%02x", $time, m_axis_stat_tdata1);
  end
end
`endif


    // ============================================================
    // 7) 输出仲裁：严格按 order_fifo 队头选择输出来源
    // ============================================================
    wire sel_is_1  = order_dout; // 0->fifo0, 1->fifo1
    wire sel_empty = sel_is_1 ? fifo1_empty : fifo0_empty;
    wire [8:0] sel_dout = sel_is_1 ? fifo1_dout : fifo0_dout;

    assign output_tvalid = (~order_empty) & (~sel_empty);
    assign output_tdata  = sel_dout[7:0];

    wire out_fire = output_tvalid && output_tready;

    assign fifo0_rd = out_fire && (~sel_is_1);
    assign fifo1_rd = out_fire && ( sel_is_1);

    // 码字输出结束（读到 tlast）才 pop order
    assign order_rd = out_fire && sel_dout[8];

    // Assign stats to outputs
    assign o_stat_cnt0    = stat_cnt0;
    assign o_stat_nz_cnt0 = stat_nz_cnt0;
    assign o_stat_cnt1    = stat_cnt1;
    assign o_stat_nz_cnt1 = stat_nz_cnt1;
    assign o_stat_fail_cnt0 = stat_bit0_cnt0;
    assign o_stat_fail_cnt1 = stat_bit0_cnt1;

endmodule


// // ================================================================
// // Simple sync FIFO (1-clock), show-ahead/FWFT style
// //   - dout = mem[rd_ptr] always
// //   - rd_en pops current element
// // ================================================================
// module rs_backend_fifo #(
//     parameter integer WIDTH = 9,
//     parameter integer DEPTH = 512
// )(
//     input  wire             clk,
//     input  wire             rst,

//     input  wire [WIDTH-1:0] din,
//     input  wire             wr_en,
//     output wire             full,

//     output wire [WIDTH-1:0] dout,
//     input  wire             rd_en,
//     output wire             empty
// );
//     reg [WIDTH-1:0] mem [0:DEPTH-1];

//     reg [$clog2(DEPTH):0]     count;
//     reg [$clog2(DEPTH)-1:0]   wr_ptr, rd_ptr;

//     assign full  = (count == DEPTH);
//     assign empty = (count == 0);

//     // FWFT/show-ahead
//     assign dout = mem[rd_ptr];

//     wire do_wr = wr_en && ~full;
//     wire do_rd = rd_en && ~empty;

//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             count  <= 0;
//             wr_ptr <= 0;
//             rd_ptr <= 0;
//         end else begin
//             if (do_wr) begin
//                 mem[wr_ptr] <= din;
//                 if (wr_ptr == DEPTH-1) wr_ptr <= 0;
//                 else wr_ptr <= wr_ptr + 1'b1;
//             end

//             if (do_rd) begin
//                 if (rd_ptr == DEPTH-1) rd_ptr <= 0;
//                 else rd_ptr <= rd_ptr + 1'b1;
//             end

//             case ({do_wr, do_rd})
//               2'b10: count <= count + 1'b1;
//               2'b01: count <= count - 1'b1;
//               default: count <= count;
//             endcase
//         end
//     end
// endmodule
