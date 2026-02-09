`timescale 1ns/1ps
`include "global_defines.vh"

module rs_interleaver_xpm #(
    parameter integer D = 4808,
    parameter integer N = 255
)(
    input  wire         clk,
    input  wire         rst,

    // 上游 RS 编码输出（未交织）
    input  wire         in_valid,
    input  wire [7:0]   in_data,
    output wire         in_ready,

    // 下游带 ready/valid 的输出（已交织）
    output wire         out_valid,
    output wire [7:0]   out_data,
    output wire         out_block_start,
    input  wire         out_ready
);

    // ===================== 常量 =====================
    localparam integer MEM_ADDR_W = 20;
    localparam integer MAX_DEPTH  = (1 << MEM_ADDR_W);   // 1M symbol
    localparam integer MEM_SIZE   = MAX_DEPTH * 8;       // 每个 bank 的 bit 数

    localparam integer MAX_D      = MAX_DEPTH / N;
    localparam integer D_EFF      = (D > MAX_D) ? MAX_D : D;
    localparam integer TOTAL_SYM  = D_EFF * N;

    localparam integer ROW_W      = $clog2(D_EFF);
    localparam integer COL_W      = $clog2(N);
    localparam integer SYM_IDX_W  = MEM_ADDR_W;

// `ifdef SIM
//     initial begin
//         if (D > MAX_D) begin
//             $display("[%0t] WARNING(rs_interleaver_xpm): D=%0d > MAX_D=%0d, D_EFF=%0d",
//                      $time, D, MAX_D, D_EFF);
//         end
//         if (TOTAL_SYM > MAX_DEPTH) begin
//             $display("[%0t] ERROR(rs_interleaver_xpm): TOTAL_SYM=%0d > MAX_DEPTH=%0d",
//                      $time, TOTAL_SYM, MAX_DEPTH);
//         end
//     end
// `endif

    // ===================== 写侧：线性写入 + 双缓冲 =====================
    reg [SYM_IDX_W-1:0] wr_sym_idx;
    reg                 wr_bank;          // 当前写 bank：0/1
    reg [1:0]           block_ready;      // block_ready[b]=1 该 bank 有完整 block 等待读

    wire cur_bank_full = block_ready[wr_bank];

    wire in_can_fire = ~rst & ~cur_bank_full;
    assign in_ready  = in_can_fire;

    wire wr_fire     = in_valid && in_can_fire;
    wire wr_last_sym = wr_fire && (wr_sym_idx == TOTAL_SYM-1);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_sym_idx <= {SYM_IDX_W{1'b0}};
            wr_bank    <= 1'b0;
        end else if (wr_fire) begin
            if (wr_sym_idx == TOTAL_SYM-1) begin
                wr_sym_idx <= {SYM_IDX_W{1'b0}};
                wr_bank    <= ~wr_bank;
            end else begin
                wr_sym_idx <= wr_sym_idx + 1'b1;
            end
        end
    end

    wire wea0 = wr_fire && (wr_bank == 1'b0);
    wire wea1 = wr_fire && (wr_bank == 1'b1);

    // ===================== 读侧：列优先读出 =====================
    reg [ROW_W-1:0] rd_row;
    reg [COL_W-1:0] rd_col;
    reg             rd_busy;
    reg             rd_bank;

    wire have_block0     = block_ready[0];
    wire have_block1     = block_ready[1];
    wire any_block_ready = have_block0 | have_block1;
    wire next_rd_bank    = have_block0 ? 1'b0 : 1'b1;

    // ---------- 输出 FIFO 写口握手 ----------
    wire ofifo_in_ready;

    // 保持原来的保守策略：地址拍只在 FIFO ready 时才发起读
    wire rd_fire = rd_busy && ofifo_in_ready;

    wire rd_last_sym = rd_fire &&
                       (rd_row == D_EFF-1) &&
                       (rd_col == N-1);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_busy <= 1'b0;
            rd_bank <= 1'b0;
            rd_row  <= {ROW_W{1'b0}};
            rd_col  <= {COL_W{1'b0}};
        end else begin
            if (!rd_busy && any_block_ready && ofifo_in_ready) begin
                rd_busy <= 1'b1;
                rd_bank <= next_rd_bank;
                rd_row  <= {ROW_W{1'b0}};
                rd_col  <= {COL_W{1'b0}};
            end else if (rd_fire) begin
                if (rd_row == D_EFF-1) begin
                    rd_row <= {ROW_W{1'b0}};
                    if (rd_col == N-1) begin
                        rd_col  <= {COL_W{1'b0}};
                        rd_busy <= 1'b0;
                    end else begin
                        rd_col <= rd_col + 1'b1;
                    end
                end else begin
                    rd_row <= rd_row + 1'b1;
                end
            end
        end
    end

    // ===================== block_ready 更新 =====================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            block_ready <= 2'b00;
        end else begin
            if (wr_last_sym)
                block_ready[wr_bank] <= 1'b1;
            if (rd_last_sym)
                block_ready[rd_bank] <= 1'b0;
        end
    end

    // ===================== 地址 & block_start（读地址侧） =====================
    wire [SYM_IDX_W-1:0] rd_row_ext = rd_row;
    wire [SYM_IDX_W-1:0] rd_col_ext = rd_col;
    wire [SYM_IDX_W-1:0] row_mul_N  = rd_row_ext * N;
    wire [SYM_IDX_W-1:0] rd_sym_idx = row_mul_N + rd_col_ext;

    wire block_start_this = rd_fire &&
                            (rd_row == {ROW_W{1'b0}}) &&
                            (rd_col == {COL_W{1'b0}});

    // ===================== RAM 实现 =====================
    wire [7:0] doutb0, doutb1;

// `ifdef SIM
//     reg [7:0] mem0 [0:TOTAL_SYM-1];
//     reg [7:0] mem1 [0:TOTAL_SYM-1];
//     reg [7:0] doutb0_r, doutb1_r;
//     integer i;
//     initial begin
//         $display("rs_interleaver_xpm: dpram simulation model.");
//         for (i = 0; i < TOTAL_SYM; i = i + 1) begin
//             mem0[i] = 8'd0;
//             mem1[i] = 8'd0;
//         end
//     end

//     always @(posedge clk) begin
//         if (wea0)
//             mem0[wr_sym_idx] <= in_data;
//         doutb0_r <= mem0[rd_sym_idx];
//     end

//     always @(posedge clk) begin
//         if (wea1)
//             mem1[wr_sym_idx] <= in_data;
//         doutb1_r <= mem1[rd_sym_idx];
//     end

//     assign doutb0 = doutb0_r;
//     assign doutb1 = doutb1_r;

// `else
    xpm_memory_tdpram #(
        .MEMORY_SIZE        (MEM_SIZE),
        .MEMORY_PRIMITIVE   ("block"),
        .CLOCKING_MODE      ("common_clock"),
        .MEMORY_INIT_FILE   ("none"),
        .MEMORY_INIT_PARAM  ("0"),
        .USE_MEM_INIT       (1),
        .WAKEUP_TIME        ("disable_sleep"),
        .MESSAGE_CONTROL    (0),
        .WRITE_DATA_WIDTH_A (8),
        .READ_DATA_WIDTH_A  (8),
        .WRITE_DATA_WIDTH_B (8),
        .READ_DATA_WIDTH_B  (8),
        .BYTE_WRITE_WIDTH_A (8),
        .BYTE_WRITE_WIDTH_B (8),
        .ADDR_WIDTH_A       (SYM_IDX_W),
        .ADDR_WIDTH_B       (SYM_IDX_W),
        .READ_LATENCY_A     (1),
        .READ_LATENCY_B     (1),
        .WRITE_MODE_A       ("no_change"),
        .WRITE_MODE_B       ("no_change")
    ) u_mem_bank0 (
        .clka    (clk),
        .rsta    (1'b0),
        .ena     (1'b1),
        .regcea  (1'b1),
        .wea     (wea0),
        .addra   (wr_sym_idx),
        .dina    (in_data),
        .douta   (),
        .clkb    (clk),
        .rstb    (1'b0),
        .enb     (1'b1),
        .regceb  (1'b1),
        .web     (1'b0),
        .addrb   (rd_sym_idx),
        .dinb    (8'd0),
        .doutb   (doutb0),
        .sleep   (1'b0),
        .injectsbiterra (1'b0),
        .injectdbiterra (1'b0)
    );

    xpm_memory_tdpram #(
        .MEMORY_SIZE        (MEM_SIZE),
        .MEMORY_PRIMITIVE   ("block"),
        .CLOCKING_MODE      ("common_clock"),
        .MEMORY_INIT_FILE   ("none"),
        .MEMORY_INIT_PARAM  ("0"),
        .USE_MEM_INIT       (1),
        .WAKEUP_TIME        ("disable_sleep"),
        .MESSAGE_CONTROL    (0),
        .WRITE_DATA_WIDTH_A (8),
        .READ_DATA_WIDTH_A  (8),
        .WRITE_DATA_WIDTH_B (8),
        .READ_DATA_WIDTH_B  (8),
        .BYTE_WRITE_WIDTH_A (8),
        .BYTE_WRITE_WIDTH_B (8),
        .ADDR_WIDTH_A       (SYM_IDX_W),
        .ADDR_WIDTH_B       (SYM_IDX_W),
        .READ_LATENCY_A     (1),
        .READ_LATENCY_B     (1),
        .WRITE_MODE_A       ("no_change"),
        .WRITE_MODE_B       ("no_change")
    ) u_mem_bank1 (
        .clka    (clk),
        .rsta    (1'b0),
        .ena     (1'b1),
        .regcea  (1'b1),
        .wea     (wea1),
        .addra   (wr_sym_idx),
        .dina    (in_data),
        .douta   (),
        .clkb    (clk),
        .rstb    (1'b0),
        .enb     (1'b1),
        .regceb  (1'b1),
        .web     (1'b0),
        .addrb   (rd_sym_idx),
        .dinb    (8'd0),
        .doutb   (doutb1),
        .sleep   (1'b0),
        .injectsbiterra (1'b0),
        .injectdbiterra (1'b0)
    );
// `endif

    wire rd_req = rd_fire;
    reg rd_bank_q;
    always @(posedge clk or posedge rst) begin
      if (rst) rd_bank_q <= 1'b0;
      else if (rd_req)  rd_bank_q <= rd_bank;
    end
    wire [7:0] dout_mux = (rd_bank_q == 1'b0) ? doutb0 : doutb1;

    // ===================== RAM 一拍延迟标志 =====================
    reg rd_fire_d1;
    reg block_start_d1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_fire_d1     <= 1'b0;
            block_start_d1 <= 1'b0;
        end else begin
            rd_fire_d1     <= rd_fire;
            block_start_d1 <= block_start_this;
        end
    end

    // ===================== ★关键修复：RAM->FIFO skid buffer =====================
    wire       src_valid = rd_fire_d1;
    wire [7:0] src_data  = dout_mux;
    wire       src_flag  = block_start_d1;

    reg        skid_v;
    reg [7:0]  skid_d;
    reg        skid_f;

    // 给 FIFO 的输入：skid 有数据就先发 skid，否则直通 src
    wire       fifo_in_valid = skid_v ? 1'b1   : src_valid;
    wire [7:0] fifo_in_data  = skid_v ? skid_d : src_data;
    wire       fifo_in_flag  = skid_v ? skid_f : src_flag;

    // skid 更新：支持“同拍消费 skid，同时同拍把 src 塞进 skid”
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            skid_v <= 1'b0;
            skid_d <= 8'd0;
            skid_f <= 1'b0;
        end else begin
            if (ofifo_in_ready) begin
                // FIFO ready：当前展示给 FIFO 的那个 token 会被吃掉（如果 valid=1）
                if (skid_v) begin
                    // 本拍吃掉 skid
                    if (src_valid) begin
                        // 同拍 src 也来了，但 FIFO 只能吃一个 → 把 src 续进 skid
                        skid_d <= src_data;
                        skid_f <= src_flag;
                        skid_v <= 1'b1;
                    end else begin
                        skid_v <= 1'b0;
                    end
                end else begin
                    // skid 空：直通 src，本拍不需要存
                    // 但如果 src_valid=0，也没事
                end
            end else begin
                // FIFO not ready：只能在 skid 空时把 src 存起来
                if (!skid_v && src_valid) begin
                    skid_d <= src_data;
                    skid_f <= src_flag;
                    skid_v <= 1'b1;
                end
            end
        end
    end

// `ifdef SIM
//     // 如果这里触发，说明“FIFO not ready 且 skid 已满”时又来了 src_valid（将会溢出）
//     always @(posedge clk) begin
//         if (!rst) begin
//             if (src_valid && skid_v && !ofifo_in_ready) begin
//                 $display("[%0t] INTERLEAVER SKID OVERFLOW (should never happen)", $time);
//                 // $stop;
//             end
//         end
//     end
// `endif

    // ===================== 输出 FIFO =====================
    wire [7:0]  ofifo_out_data;
    wire        ofifo_out_flag;
    wire        ofifo_out_valid;

    fifo_8b_flag_sync #(
        .DEPTH (512),
        .GUARD (1)
    ) u_out_fifo (
        .clk       (clk),
        .rst       (rst),

        .in_data   (fifo_in_data),
        .in_flag   (fifo_in_flag),
        .in_valid  (fifo_in_valid),
        .in_ready  (ofifo_in_ready),

        .out_data  (ofifo_out_data),
        .out_flag  (ofifo_out_flag),
        .out_valid (ofifo_out_valid),
        .out_ready (out_ready)
    );

    assign out_valid       = ofifo_out_valid;
    assign out_data        = ofifo_out_data;
    assign out_block_start = ofifo_out_flag;

endmodule
