`timescale 1ns/1ps

module rs_decode_backend_x4 #(
    parameter integer RS_N           = 255,
    parameter integer OUT_FIFO_DEPTH = 1024,
    parameter integer ORDER_DEPTH    = 64
)(
    input  wire        rst,
    input  wire        core_clk,

    // 内部接口依然使用 9-bit 以节省 RAM 资源
    // [8]=Erasure, [7:0]=Data
    input  wire [8:0]  s_axis_input_tdata,
    input  wire        s_axis_input_tvalid,
    input  wire        s_axis_input_tlast,
    output wire        s_axis_input_tready,

    // 输出 8-bit (纠错后的数据)
    output wire [7:0]  output_tdata,
    output wire        output_tvalid,
    input  wire        output_tready,
    
    // 统计接口 (适配 IP 的 16-bit)
    output wire [15:0] stat_tdata,
    output wire        stat_tvalid
);

    wire clk = core_clk;
    localparam integer IN_AW = $clog2(RS_N); // 8

    // ============================================================
    // 1) 四块输入缓冲：每块缓存 1 个 RS_N 码字 (含 Erasure)
    // ============================================================
    // 即使 IP 需要 16bit，我们存储时只存 9bit 即可，省一半 RAM
    (* ram_style="distributed" *) reg [8:0] inbuf0_mem [0:RS_N-1];
    (* ram_style="distributed" *) reg [8:0] inbuf1_mem [0:RS_N-1];
    (* ram_style="distributed" *) reg [8:0] inbuf2_mem [0:RS_N-1];
    (* ram_style="distributed" *) reg [8:0] inbuf3_mem [0:RS_N-1];

    reg [IN_AW:0] inbuf_cnt  [0:3];
    reg           inbuf_full [0:3];
    reg           fill_active;
    reg [1:0]     fill_sel; // 0..3 轮询指针
    reg           drop_active;

    // ============================================================
    // 2) Order FIFO & Decoder Feed Logic
    // ============================================================
    wire order_full, order_empty;
    wire [1:0] order_dout;
    wire order_wr, order_rd;
    
    reg [IN_AW-1:0] rd_ptr [0:3];
    reg [IN_AW:0]   rd_cnt [0:3];
    reg             feed   [0:3];

    // Buffer 状态检查
    wire [3:0] buf_can_take_new;
    genvar k;
    generate
        for (k=0; k<4; k=k+1) begin : buf_chk
            assign buf_can_take_new[k] = (~inbuf_full[k]) & (~feed[k]);
        end
    endgenerate

    // 只要有任意一个 buffer 空闲，我们就可以接收新帧
    wire any_buf_free = |buf_can_take_new;
    assign s_axis_input_tready = (~rst) & (drop_active ? 1'b1 : ((~order_full) & any_buf_free));

    wire in_fire      = s_axis_input_tvalid && s_axis_input_tready;
    wire in_last_fire = in_fire && s_axis_input_tlast;

    // 当前写入的 buffer index (若空闲则使用 fill_sel 指向的)
    wire [1:0] cur_sel = fill_sel;
    wire [IN_AW:0] cur_cnt_val = inbuf_cnt[cur_sel];

    // Good Last: 长度正确
    wire good_last_fire = (!drop_active) && in_last_fire && (cur_cnt_val == (RS_N-1));
    assign order_wr = good_last_fire;

    rs_backend_fifo #( .WIDTH(2), .DEPTH(ORDER_DEPTH) ) u_order_fifo (
        .clk(clk), .rst(rst),
        .din(cur_sel), .wr_en(order_wr),
        .full(order_full), .dout(order_dout), .rd_en(order_rd), .empty(order_empty)
    );

    // ============================================================
    // 3) 输入写入状态机
    // ============================================================
    wire [3:0] start_feed;
    generate
        for (k=0; k<4; k=k+1) assign start_feed[k] = (!feed[k]) && inbuf_full[k];
    endgenerate

    integer j;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fill_active <= 1'b0;
            fill_sel    <= 2'd0;
            drop_active <= 1'b0;
            for(j=0; j<4; j=j+1) begin
                inbuf_cnt[j]  <= 0;
                inbuf_full[j] <= 0;
            end
        end else begin
            // 提交给 Decoder 后清空 Full 标记
            for(j=0; j<4; j=j+1) begin
                if (start_feed[j]) begin
                    inbuf_full[j] <= 1'b0;
                    inbuf_cnt[j]  <= 0;
                end
            end

            if (drop_active) begin
                if (in_last_fire) begin
                    drop_active <= 1'b0;
                    fill_active <= 1'b0;
                end
            end else begin
                // Start of Frame
                if (!fill_active && in_fire) fill_active <= 1'b1;

                if (in_fire) begin
                    case(cur_sel)
                        2'd0: inbuf0_mem[inbuf_cnt[0]] <= s_axis_input_tdata;
                        2'd1: inbuf1_mem[inbuf_cnt[1]] <= s_axis_input_tdata;
                        2'd2: inbuf2_mem[inbuf_cnt[2]] <= s_axis_input_tdata;
                        2'd3: inbuf3_mem[inbuf_cnt[3]] <= s_axis_input_tdata;
                    endcase
                    
                    if (inbuf_cnt[cur_sel] < RS_N)
                        inbuf_cnt[cur_sel] <= inbuf_cnt[cur_sel] + 1'b1;
                    else begin
                        drop_active <= 1'b1; // 溢出
                        fill_active <= 1'b0;
                        inbuf_full[cur_sel] <= 1'b0;
                        inbuf_cnt[cur_sel]  <= 0;
                    end

                    if (s_axis_input_tlast) begin
                        if (inbuf_cnt[cur_sel] == (RS_N-1)) begin
                            inbuf_full[cur_sel] <= 1'b1; // Good Frame
                            fill_sel <= fill_sel + 1'b1; // 轮询下一个
                        end else begin
                            inbuf_full[cur_sel] <= 1'b0; // Bad Frame
                            inbuf_cnt[cur_sel]  <= 0;
                        end
                        fill_active <= 1'b0;
                    end
                end
            end
        end
    end

    // ============================================================
    // 4) 4路 Decoder 实例化
    // ============================================================
    wire [8:0] dec_in_data [0:3]; // 9-bit internal
    assign dec_in_data[0] = inbuf0_mem[rd_ptr[0]];
    assign dec_in_data[1] = inbuf1_mem[rd_ptr[1]];
    assign dec_in_data[2] = inbuf2_mem[rd_ptr[2]];
    assign dec_in_data[3] = inbuf3_mem[rd_ptr[3]];

    wire [3:0] dec_in_last, dec_in_ready;
    wire [3:0] dec_in_valid; // feed[k]

    generate
        for (k=0; k<4; k=k+1) begin : feeder
            assign dec_in_last[k] = (rd_cnt[k] == RS_N-1);
            assign dec_in_valid[k] = feed[k];
            wire fire = feed[k] && dec_in_ready[k];

            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    feed[k] <= 0; rd_ptr[k] <= 0; rd_cnt[k] <= 0;
                end else begin
                    if (!feed[k] && inbuf_full[k]) begin
                        feed[k] <= 1; rd_ptr[k] <= 0; rd_cnt[k] <= 0;
                    end
                    if (fire) begin
                        if (dec_in_last[k]) feed[k] <= 0;
                        else begin
                            rd_ptr[k] <= rd_ptr[k] + 1; rd_cnt[k] <= rd_cnt[k] + 1;
                        end
                    end
                end
            end
        end
    endgenerate

    // IP Outputs
    wire [7:0]  ip_out_data  [0:3];
    wire [3:0]  ip_out_valid, ip_out_last, ip_out_ready;
    wire [15:0] ip_stat      [0:3]; // 16-bit Stat
    wire [3:0]  ip_stat_vld;

    generate
        for (k=0; k<4; k=k+1) begin : ip_inst
            // ★★★ 核心适配：9-bit -> 16-bit 拼接 ★★★
            // bit[8] 是擦除位，映射到 IP 的 bit[8]
            // bit[7:0] 是数据，映射到 IP 的 bit[7:0]
            // bit[15:9] 补0
            wire [15:0] s_axis_ip_tdata = {7'd0, dec_in_data[k][8], dec_in_data[k][7:0]};

            rs_decoder_0 u_core (
                .aclk                (clk),
                .s_axis_input_tdata  (s_axis_ip_tdata), 
                .s_axis_input_tvalid (dec_in_valid[k]),
                .s_axis_input_tready (dec_in_ready[k]),
                .s_axis_input_tlast  (dec_in_last[k]),

                .m_axis_output_tdata (ip_out_data[k]),
                .m_axis_output_tvalid(ip_out_valid[k]),
                .m_axis_output_tready(ip_out_ready[k]),
                .m_axis_output_tlast (ip_out_last[k]),
                
                .m_axis_stat_tdata   (ip_stat[k]),  // 16-bit
                .m_axis_stat_tvalid  (ip_stat_vld[k]),
                .m_axis_stat_tready  (1'b1),        // 始终准备好接收统计

                .event_s_input_tlast_missing    (),
                .event_s_input_tlast_unexpected (),
                .event_s_ctrl_tdata_invalid     ()
            );
        end
    endgenerate

    // ============================================================
    // 5) 输出 FIFO (9-bit: 8 data + 1 last)
    // ============================================================
    wire [8:0] fifo_din[0:3];
    wire [8:0] fifo_dout[0:3];
    wire fifo_empty[0:3], fifo_full[0:3], fifo_rd[0:3], fifo_wr[0:3];

    generate
        for (k=0; k<4; k=k+1) begin : out_fifo
            assign fifo_din[k] = {ip_out_last[k], ip_out_data[k]};
            assign fifo_wr[k]  = ip_out_valid[k];
            assign ip_out_ready[k] = ~fifo_full[k];

            rs_backend_fifo #( .WIDTH(9), .DEPTH(OUT_FIFO_DEPTH) ) u_fifo (
                .clk(clk), .rst(rst),
                .din(fifo_din[k]), .wr_en(fifo_wr[k]), .full(fifo_full[k]),
                .dout(fifo_dout[k]), .rd_en(fifo_rd[k]), .empty(fifo_empty[k])
            );
        end
    endgenerate

    // ============================================================
    // 6) 输出仲裁
    // ============================================================
    wire [1:0] sel_idx = order_dout;
    wire [8:0] sel_val = fifo_dout[sel_idx];
    wire       sel_emp = fifo_empty[sel_idx];
    
    assign output_tvalid = (~order_empty) & (~sel_emp);
    assign output_tdata  = sel_val[7:0];
    wire   out_last_bit  = sel_val[8];
    wire   out_fire      = output_tvalid && output_tready;

    generate
        for(k=0; k<4; k=k+1) begin : rd_demux
            assign fifo_rd[k] = out_fire && (sel_idx == k);
        end
    endgenerate

    assign order_rd = out_fire && out_last_bit;

    // 简单统计合并 (OR逻辑)
    assign stat_tdata  = ip_stat[0] | ip_stat[1] | ip_stat[2] | ip_stat[3];
    assign stat_tvalid = |ip_stat_vld;

endmodule