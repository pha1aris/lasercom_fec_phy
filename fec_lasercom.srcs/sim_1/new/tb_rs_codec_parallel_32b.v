`timescale 1ns/1ps

module tb_rs_codec_parallel_32b;

    //============================================================
    // 参数设置
    //============================================================
    localparam integer RS_K             = 229;
    localparam integer RS_N             = 255;
    localparam integer MODE_RST_CYCLES  = 20;

    // 仿真控制
    localparam integer TEST_DURATION_NS = 200_000; // 仿真时长

    // 错误注入参数 (简单模拟)
    // 0 = 无错
    // 1 = 注入随机误码 (不标记擦除) -> 验证硬纠错
    // 2 = 注入擦除 (标记擦除) -> 验证擦除解码

// 测试方法：

    reg [1:0] err_inject_mode = 0; 
    
    //============================================================
    // 时钟 & 复位
    //============================================================
    reg aclk;
    reg aresetn; // 异步低有效 (适配 IP 接口)

    initial begin
        aclk = 1'b0;
        forever #5 aclk = ~aclk;   // 100MHz (3.2Gbps throughput)
    end

    initial begin
        aresetn = 1'b0;
        #100;
        aresetn = 1'b1;
    end

    //============================================================
    // 模式选择: 1=PRBS, 0=CNT
    //============================================================
    reg sel = 1'b1; 
    
    // 简单的模式切换复位逻辑
    reg sel_d;
    reg [4:0] rst_cnt;
    wire mode_sw = (sel ^ sel_d);
    
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            sel_d <= 1'b0;
            rst_cnt <= 0;
        end else begin
            sel_d <= sel;
            if (mode_sw) rst_cnt <= MODE_RST_CYCLES;
            else if (rst_cnt != 0) rst_cnt <= rst_cnt - 1;
        end
    end
    
    wire soft_rst = (rst_cnt != 0);
    wire sys_rst_n = aresetn & ~soft_rst; // 组合复位

    //============================================================
    // 1. 并行数据源生成 (Source Generation)
    //    我们需要 4 路独立的 PRBS/CNT 来填充 32-bit
    //============================================================
    wire [7:0] src_lane_data [0:3];
    wire       src_valid = 1'b1; // 始终有效，压力测试
    wire       fifo_ready;       // 编码器反压信号

    // 定义一个生成函数：生成 CNT 格式数据
    // 注意：并行架构下，每个 Lane 都在独立计数 0..228
    function [7:0] get_cnt_byte(input [15:0] cw, input [7:0] pos);
        case (pos)
            8'd0: get_cnt_byte = 8'hEE; // SYNC0
            8'd1: get_cnt_byte = 8'hE1; // SYNC1
            8'd2: get_cnt_byte = cw[7:0];
            8'd3: get_cnt_byte = cw[15:8];
            default: get_cnt_byte = (pos - 8'd4);
        endcase
    endfunction

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_lanes
            // --- PRBS 源 ---
            wire [7:0] prbs_out;
            gtwizard_ultrascale_0_prbs_any #(
                .CHK_MODE(0), .POLY_LENGHT(7), .POLY_TAP(6), .NBITS(8)
            ) u_prbs_gen (
                .RST(~sys_rst_n), .CLK(aclk), .DATA_IN(8'd0), 
                .EN(sel && fifo_ready), .DATA_OUT(prbs_out)
            );

            // --- CNT 源 ---
            reg [15:0] tx_cw_id;
            reg [7:0]  tx_pos;
            always @(posedge aclk or negedge sys_rst_n) begin
                if (!sys_rst_n) begin
                    tx_cw_id <= 16'd0;
                    tx_pos   <= 8'd0;
                end else if (!sel && fifo_ready) begin
                    if (tx_pos == RS_K-1) begin
                        tx_pos <= 0;
                        tx_cw_id <= tx_cw_id + 1;
                    end else begin
                        tx_pos <= tx_pos + 1;
                    end
                end
            end
            wire [7:0] cnt_out = get_cnt_byte(tx_cw_id, tx_pos);

            // --- MUX ---
            assign src_lane_data[i] = sel ? prbs_out : cnt_out;
        end
    endgenerate

    // 拼装 32-bit 输入
    wire [31:0] enc_din_32 = {src_lane_data[3], src_lane_data[2], src_lane_data[1], src_lane_data[0]};

    //============================================================
    // 2. DUT1: 并行编码器
    //============================================================
    wire [31:0] enc_dout_32;
    wire        enc_dout_valid;
    wire        enc_dout_last;
    wire        enc_dout_ready; // 来自 Channel 的反压

    rs_encoder_parallel_32b u_encoder (
        .aclk                (aclk),
        .aresetn             (sys_rst_n),
        .s_axis_input_tdata  (enc_din_32),
        .s_axis_input_tvalid (src_valid),
        .s_axis_input_tready (fifo_ready), // Output to Source
        
        .m_axis_output_tdata (enc_dout_32),
        .m_axis_output_tvalid(enc_dout_valid),
        .m_axis_output_tlast (enc_dout_last),
        .m_axis_output_tready(enc_dout_ready) // Input from Channel
    );

    //============================================================
    // 3. 信道模拟 (Channel & Error Injector)
    //    这里不仅注入错误，还负责生成“擦除标记”
    //============================================================
    reg [31:0] channel_data;
    reg [3:0]  channel_erase; // 4-bit erasure flag
    reg        channel_valid;
    reg        channel_last;
    
    // 简单的错误计数器，每隔 N 拍搞坏一次
    integer err_timer = 0;
    
    always @(posedge aclk) begin
        if (!sys_rst_n) begin
            channel_data  <= 0;
            channel_erase <= 0;
            channel_valid <= 0;
            channel_last  <= 0;
            err_timer     <= 0;
        end else begin
            // 直通逻辑 (Pipelined)
            channel_valid <= enc_dout_valid;
            channel_last  <= enc_dout_last;
            
            // 错误注入逻辑
            if (enc_dout_valid) begin
                err_timer <= err_timer + 1;
                
                // 默认数据透传
                channel_data  <= enc_dout_32;
                channel_erase <= 4'b0000;

                // ------------------------------------------------
                // 场景 A: 随机误码 (每 100 拍，翻转 Lane 0 的数据，不给 Erasure)
                // ------------------------------------------------
                if (err_inject_mode == 1 && (err_timer % 100 == 0)) begin
                    channel_data[7:0] <= ~enc_dout_32[7:0]; // Bit flip
                    $display("[%0t] Inject Random Error @ Lane 0 (No Erasure Flag)", $time);
                end
                
                // ------------------------------------------------
                // 场景 B: 突发擦除 (每 300 拍，把整个 32-bit 标记为 Erasure)
                // ------------------------------------------------
                else if (err_inject_mode == 2 && (err_timer % 300 == 0)) begin
                    channel_data  <= 32'hDEADBEEF; // 数据全坏
                    channel_erase <= 4'b1111;      // 标记 4 个字节全为擦除
                    $display("[%0t] Inject Burst Erasure (4 Bytes Marked)", $time);
                end
            end
        end
    end

    // 假设信道吞吐量足够，不反压编码器
    assign enc_dout_ready = 1'b1;

    //============================================================
    // 4. DUT2: 并行解码器 (带擦除支持)
    //============================================================
    wire [31:0] dec_dout_32;
    wire        dec_dout_valid;
    wire        dec_dout_last;
    wire [15:0] dec_stat_16;  // 16-bit stat
    wire        dec_stat_valid;

    rs_decoder_parallel_32b u_decoder (
        .aclk                     (aclk),
        .aresetn                  (sys_rst_n),
        
        .s_axis_input_tdata       (channel_data),
        .s_axis_input_tuser_erase (channel_erase), // ★ 关键：注入擦除标记
        .s_axis_input_tvalid      (channel_valid),
        .s_axis_input_tlast       (channel_last),
        .s_axis_input_tready      (), // 暂不处理 Ready，假设全速

        .m_axis_output_tdata      (dec_dout_32),
        .m_axis_output_tvalid     (dec_dout_valid),
        .m_axis_output_tlast      (dec_dout_last),
        .m_axis_output_tready     (1'b1), // 接收端全速

        .m_stat_tdata             (dec_stat_16),
        .m_stat_tvalid            (dec_stat_valid)
    );

    //============================================================
    // 5. 结果检查 (Checkers)
    //============================================================
    
    // 拆分输出用于检查
    wire [7:0] dec_lane_data [0:3];
    assign dec_lane_data[0] = dec_dout_32[7:0];
    assign dec_lane_data[1] = dec_dout_32[15:8];
    assign dec_lane_data[2] = dec_dout_32[23:16];
    assign dec_lane_data[3] = dec_dout_32[31:24];

    // 统计纠错次数
    integer total_corrected_cnt = 0;
    always @(posedge aclk) begin
        if (dec_stat_valid && (dec_stat_16 != 0)) begin
            total_corrected_cnt <= total_corrected_cnt + 1;
            // 可以在这里打印纠错详情
            // $display("[%0t] RS Corrected! Stat=%x", $time, dec_stat_16);
        end
    end

    // --- 并行 PRBS Checkers ---
    wire [3:0] prbs_err_found;
    generate
        for (i = 0; i < 4; i = i + 1) begin : checkers
            wire [7:0] err_vec;
            gtwizard_ultrascale_0_prbs_any #(
                .CHK_MODE(1), .POLY_LENGHT(7), .POLY_TAP(6), .NBITS(8)
            ) u_prbs_chk (
                .RST(~sys_rst_n), .CLK(aclk), 
                .DATA_IN(dec_lane_data[i]), .EN(sel && dec_dout_valid), 
                .DATA_OUT(err_vec)
            );
            assign prbs_err_found[i] = |err_vec;
            
            // 错误打印
            always @(posedge aclk) begin
                if (sel && dec_dout_valid && (|err_vec)) begin
                    $display("[%0t] [Lane %0d] PRBS MISMATCH! Data=%x ErrVec=%x", 
                             $time, i, dec_lane_data[i], err_vec);
                end
            end
        end
    endgenerate

    //============================================================
    // 6. CSV Dump & 流程控制
    //============================================================
    integer f_csv;
    initial begin
        f_csv = $fopen("tb_system_result.csv", "w");
        $fwrite(f_csv, "Time,Mode,Enc_Data_32,Inj_Erase,Dec_Data_32,Dec_Stat\n");
    end

    always @(posedge aclk) begin
        // 只有当解码输出有效时才记录
        if (dec_dout_valid) begin
            $fwrite(f_csv, "%0t,%s,%08x,%b,%08x,%04x\n", 
                    $time, sel?"PRBS":"CNT", 
                    channel_data, channel_erase, // 注意：这是延迟后的 channel 数据，仅作参考
                    dec_dout_32, dec_stat_16);
        end
    end

    // 主测试流程
    initial begin
        // 1. 初始化
        #200;
        $display("=== TEST START ===");
        
        // 2. 阶段一：无错传输 (PRBS)
        $display("--- Phase 1: Clean Channel (PRBS) ---");
        err_inject_mode = 0;
        sel = 1;
        #50000;
        
        // 3. 阶段二：注入随机误码 (无擦除标记) -> 验证硬纠错
        $display("--- Phase 2: Random Errors (No Erasure Flag) ---");
        err_inject_mode = 1;
        #50000;
        
        // 4. 阶段三：注入突发擦除 (带擦除标记) -> 验证擦除纠错
        $display("--- Phase 3: Burst Erasures (With Erasure Flag) ---");
        err_inject_mode = 2;
        #50000;

        // 5. 阶段四：切换到 CNT 模式观察细节
        $display("--- Phase 4: Switch to CNT Mode (Clean) ---");
        sel = 0; // 切 CNT
        err_inject_mode = 0;
        #50000;

        $display("=== TEST DONE ===");
        $display("Total Corrected Events: %0d", total_corrected_cnt);
        $fclose(f_csv);
        $finish;
    end

endmodule