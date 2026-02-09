`timescale 1ns / 1ps

module fec_rx_fpga_top #(
    parameter integer W                = 32,
    parameter integer PAYLOAD_WORDS    = 16,
    parameter integer RS_K             = 229,
    parameter integer RS_N             = 255,
    // ★ 必须与 TX 端完全一致：4096 × 255 = 16384 × 16 × 4
    parameter integer INTLV_D          = 4096,  
    parameter integer INTLV_N          = 255,
    parameter integer FRAMES_PER_BLOCK = 16384,
    parameter integer LOCK_THRESH      = 1024,
    // 1=PRBS Check, 0=Counter Check (必须与 TX 一致)
    parameter integer TEST_PRBS        = 1, 

    // UART 参数
    parameter integer CORE_CLK_HZ      = 100_000_000,
    parameter integer UART_BAUD        = 115200,
    parameter integer PRINT_DIV        = 100_000_000
)(
    input  wire         sys_clk_p,
    input  wire         sys_clk_n,
    input  wire         sys_rst_n,

    // GTH 参考时钟 (RX 板卡也必须有参考时钟)
    input  wire         mgtrefclk0_x1y1_p,
    input  wire         mgtrefclk0_x1y1_n,

    // UART 输出 (用于在电脑上看误码率)
    output wire         uart_txd,
    input  wire         uart_rxd,

    // SFP / GTH 物理接口
    input  wire         gthrxp_in,
    input  wire         gthrxn_in,
    output wire         gthtxp_out,
    output wire         gthtxn_out,

    input  wire [1:0]   sfp_loss,
    output wire [1:0]   tx_disable
);

    // 开启光模块 (接收端通常也需要拉低 Disable 以保证模块正常工作)
    assign tx_disable = 2'b00;

    // ======================================================================
    // 1. 时钟 & 复位
    // ======================================================================
    wire freerun_clk;
    wire core_clk;
    wire clk_locked;

    clk_wiz_sys u_clk_wiz (
        .clk_out1 (freerun_clk),
        .clk_out2 (core_clk),
        .clk_out3 (),
        .reset    (~sys_rst_n),
        .locked   (clk_locked),
        .clk_in1_p(sys_clk_p),
        .clk_in1_n(sys_clk_n)
    );

    wire logic_rst_n = sys_rst_n & clk_locked;
    wire logic_rst   = ~logic_rst_n;
    wire gth_reset_all = logic_rst;

    // ======================================================================
    // 2. 控制信号 (替代原本的 VIO)
    // ======================================================================
    // 必须与 TX 端配置一致
    wire        scrambler_en = 1'b0; 
    wire [2:0]  loop_backmode = 3'b000; // 正常模式
    wire        use_prbs = (TEST_PRBS != 0);

    // ======================================================================
    // 3. GTH Top (RX 模式)
    // ======================================================================
    wire        rx_usr_clk;
    wire        rx_rst_n;
    wire        rx_done;
    wire        rx_active;
    wire        cdr_stable;
    wire [W-1:0] rx_data_from_gth;
    wire        rx_slide_req;

    gth_raw_top #(
        .W (W)
    ) u_gth_raw (
        .freerun_clk        (freerun_clk),
        .gth_reset_all      (gth_reset_all),

        .mgtrefclk0_x1y1_p  (mgtrefclk0_x1y1_p),
        .mgtrefclk0_x1y1_n  (mgtrefclk0_x1y1_n),
        .gthrxp_in          (gthrxp_in),
        .gthrxn_in          (gthrxn_in),
        .gthtxp_out         (gthtxp_out),
        .gthtxn_out         (gthtxn_out),

        .i_loopback         (loop_backmode),
        .o_pll_locked       (),

        // TX 接口在 RX 板卡上闲置 (输入置 0)
        .o_tx_clk           (),
        .o_tx_rst_n         (),
        .o_tx_done          (),
        .o_tx_active        (),
        .i_tx_data          (32'hA5A5_A5A5), 

        // RX 接口
        .o_rx_clk           (rx_usr_clk),
        .o_rx_rst_n         (rx_rst_n),
        .o_rx_done          (rx_done),
        .o_rx_active        (rx_active),
        .o_cdr_stable       (cdr_stable),
        .o_rx_data          (rx_data_from_gth),
        .i_rx_slide         (rx_slide_req)
    );

    // GTH 状态信号 CDC 同步
    reg rx_done_cdc1, rx_done_cdc2;
    reg rx_rstn_cdc1, rx_rstn_cdc2;

    always @(posedge core_clk or posedge logic_rst) begin
        if (logic_rst) begin
            rx_done_cdc1 <= 0; rx_done_cdc2 <= 0;
            rx_rstn_cdc1 <= 0; rx_rstn_cdc2 <= 0;
        end else begin
            rx_done_cdc1 <= rx_done;  rx_done_cdc2 <= rx_done_cdc1;
            rx_rstn_cdc1 <= rx_rst_n; rx_rstn_cdc2 <= rx_rstn_cdc1;
        end
    end

    wire rx_done_core  = rx_done_cdc2;
    wire rx_rst_n_core = rx_rstn_cdc2;

    // SFP Loss 和 CDR 状态同步
    reg [1:0] loss_core_ff1, loss_core_ff2;
    reg cdr_core_ff1, cdr_core_ff2;

    always @(posedge core_clk) begin
        if(logic_rst) begin
            loss_core_ff1 <= 2'b11; loss_core_ff2 <= 2'b11;
            cdr_core_ff1 <= 0;      cdr_core_ff2 <= 0;
        end else begin
            loss_core_ff1 <= sfp_loss;    loss_core_ff2 <= loss_core_ff1;
            cdr_core_ff1  <= cdr_stable;  cdr_core_ff2  <= cdr_core_ff1;
        end
    end
    
    // 真实的物理状态 (用于 UART 上报)
    wire sfp_real_status_core = ~loss_core_ff2[0];
    wire cdr_stable_core = cdr_core_ff2;

    // ★ 强制逻辑状态：即便光功率低，也允许逻辑尝试锁定 (与原代码一致 [cite: 51])
    wire have_light_line = 1'b1; 
    wire have_light_core = 1'b1;

    // ======================================================================
    // 4. FEC RX 核心模块
    // ======================================================================
    wire [7:0]  fec_rx_data;
    wire        fec_rx_valid;
    wire        bit_locked;
    wire [15:0] rx_frame_index;
    wire [15:0] rx_block_id;
    wire [15:0] rx_frame_in_block;
    wire        rx_frame_locked;
    wire        rx_block_aligned;
    wire        rx_realign_req;

    wire fec_rx_rst_n = logic_rst_n & rx_rst_n_core & rx_done_core;

    // RX 侧使能信号 CDC
    reg rx_act_l1, rx_act_l2;
    reg cdr_st_l1, cdr_st_l2;

    always @(posedge rx_usr_clk) begin
        rx_act_l1 <= rx_active; rx_act_l2 <= rx_act_l1;
        cdr_st_l1 <= cdr_stable; cdr_st_l2 <= cdr_st_l1;
    end

    wire rx_active_line     = rx_act_l2;
    wire cdr_stable_line    = cdr_st_l2;
    wire rx_word_valid_line = rx_active_line & cdr_stable_line & have_light_line;

    fec_rx #(
        .W(W),
        .PAYLOAD_WORDS(PAYLOAD_WORDS),
        .RS_N(RS_N),
        .INTLV_D(INTLV_D),
        .FRAMES_PER_BLOCK(FRAMES_PER_BLOCK),
        .INTLV_N(INTLV_N)
    ) u_fec_rx (
        .line_clk         (rx_usr_clk),
        .core_clk         (core_clk),
        .rst_n            (fec_rx_rst_n),
        .i_rx_data        (rx_data_from_gth),
        .i_rx_valid       (rx_word_valid_line),
        
        .rx_reset_done    (rx_active_line),
        .rx_cdr_stable    (cdr_stable_line),
        .scrambler_en     (scrambler_en),
        
        .o_data           (fec_rx_data),
        .o_valid          (fec_rx_valid),
        .i_data_ready     (1'b1), // 始终准备好接收
        
        .o_rxslide        (rx_slide_req),
        .bit_locked_core  (bit_locked),
        .o_frame_index    (rx_frame_index),
        .o_block_id       (rx_block_id),
        .o_frame_in_block (rx_frame_in_block),
        .o_frame_locked   (rx_frame_locked),
        .o_block_aligned  (rx_block_aligned),
        .o_realign_req    (rx_realign_req)
    );

    // ======================================================================
    // 5. UART RX (用于接收 'c' 指令复位误码计数)
    // ======================================================================
    localparam integer CORE_CLK_MHZ = CORE_CLK_HZ / 1_000_000;
    wire [7:0] uart_rx_byte;
    wire       uart_rx_valid;

    uart_rx #(
        .CLK_FRE  (CORE_CLK_MHZ),
        .BAUD_RATE(UART_BAUD)
    ) u_uart_rx (
        .clk(core_clk),
        .rst_n(logic_rst_n),
        .rx_data(uart_rx_byte),
        .rx_data_valid(uart_rx_valid),
        .rx_data_ready(1'b1),
        .rx_pin(uart_rxd)
    );

    // 支持 'c' 或 'C' 复位
    wire uart_clr_cmd = uart_rx_valid && (uart_rx_byte == 8'h63 || uart_rx_byte == 8'h43); 
    wire ber_clear_pulse = uart_clr_cmd;

    // ======================================================================
    // 6. PRBS 校验 & 统计 (从原代码移植的核心部分)
    // ======================================================================
    wire prbs_meas_ok = have_light_core & use_prbs & bit_locked; 
    wire prbs_chk_fire = fec_rx_valid & prbs_meas_ok;

    reg prbs_meas_ok_d;
    always @(posedge core_clk) prbs_meas_ok_d <= prbs_meas_ok;
    wire prbs_meas_start = prbs_meas_ok & ~prbs_meas_ok_d;
    
    // 复位 PRBS 检查器
    wire prbs_chk_rst = logic_rst | ber_clear_pulse | prbs_meas_start;

    wire [7:0] prbs_err_vec_int;
    reg prbs_locked_internal; 
    reg [31:0] good_cnt;
    reg [15:0] mask_cnt;
    reg        ber_enable;

    // 实例化 PRBS 检查器 [cite: 97]
    gtwizard_ultrascale_0_prbs_any #(
        .CHK_MODE    (1),
        .NBITS       (8)
    ) u_prbs_chk_rx (
        .RST      (prbs_chk_rst),
        .CLK      (core_clk),
        .DATA_IN  (fec_rx_data),
        .EN       (prbs_chk_fire),
        .DATA_OUT (prbs_err_vec_int),
        .i_force_lock (prbs_locked_internal)
    );

    wire prbs_match_fail = prbs_chk_fire && (|prbs_err_vec_int);
    wire [7:0] prbs_err_vec = prbs_chk_fire ? prbs_err_vec_int : 8'h00;

    function integer popcount8;
        input [7:0] v;
        integer k;
        begin
            popcount8 = 0;
            for (k = 0; k < 8; k = k + 1) popcount8 = popcount8 + v[k];
        end
    endfunction
    wire [3:0] current_err_num = popcount8(prbs_err_vec);

    // 延迟一拍用于对齐 valid (Block B 修复逻辑) [cite: 105]
    reg prbs_chk_fire_d;
    always @(posedge core_clk) begin
        if (logic_rst) prbs_chk_fire_d <= 1'b0;
        else prbs_chk_fire_d <= prbs_chk_fire;
    end

    // 锁定状态机 [cite: 106]
    always @(posedge core_clk) begin
        if (logic_rst || ber_clear_pulse || ~prbs_meas_ok) begin
            good_cnt             <= 32'd0;
            prbs_locked_internal <= 1'b0;
            mask_cnt             <= 16'd0;
            ber_enable           <= 1'b0;
        end else if (prbs_chk_fire) begin
            if (!prbs_locked_internal) begin
                // 搜索阶段
                ber_enable <= 1'b0;
                if (prbs_match_fail) begin
                    good_cnt <= 32'd0;
                end else begin
                    if (good_cnt >= (LOCK_THRESH-1)) begin
                        prbs_locked_internal <= 1'b1;
                        good_cnt <= 32'd0;
                        mask_cnt <= 16'd0;
                    end else begin
                        good_cnt <= good_cnt + 1'b1;
                    end
                end
            end else begin
                // 锁定阶段，等待 mask
                if (!ber_enable) begin
                    if (mask_cnt >= (1024-1)) ber_enable <= 1'b1;
                    else mask_cnt <= mask_cnt + 1'b1;
                end
            end
        end
    end

    // 统计计数器 [cite: 117]
    reg [63:0] total_bits_cnt;
    reg [63:0] total_err_cnt;

    always @(posedge core_clk) begin
        if (logic_rst || ber_clear_pulse) begin
            total_bits_cnt <= 64'd0;
            total_err_cnt  <= 64'd0;
        end else if (prbs_meas_ok && ber_enable && prbs_chk_fire_d) begin
            if (total_bits_cnt != 64'hFFFF_FFFF_FFFF_FFFF)
                total_bits_cnt <= total_bits_cnt + 64'd8;
            
            if (prbs_match_fail) begin
                if (total_err_cnt <= (64'hFFFF_FFFF_FFFF_FFFF - current_err_num))
                    total_err_cnt <= total_err_cnt + current_err_num;
                else
                    total_err_cnt <= 64'hFFFF_FFFF_FFFF_FFFF;
            end
        end
    end

    // ======================================================================
    // 7. UART TX (结果上报)
    // ======================================================================
    // 状态位组装 [cite: 144]
    wire [7:0] uart_status_byte = {
        1'b1,                  // [7] Alive
        1'b0,                  // [6] Reserved
        rx_realign_req,        // [5] Realigning
        prbs_locked_internal,  // [4] PRBS Locked
        rx_block_aligned,      // [3] Block ID Aligned 
        rx_frame_locked,       // [2] Frame Locked 
        cdr_stable_core,       // [1] CDR Stable
        sfp_real_status_core   // [0] Light (Real)
    };

    wire uart_tx_ready;
    reg uart_tx_valid;
    reg [7:0] uart_tx_data;

    uart_tx #(
        .CLK_FRE(CORE_CLK_MHZ),
        .BAUD_RATE(UART_BAUD)
    ) u_uart_tx (
        .clk(core_clk),
        .rst_n(logic_rst_n),
        .tx_data(uart_tx_data),
        .tx_data_valid(uart_tx_valid),
        .tx_data_ready(uart_tx_ready),
        .tx_pin(uart_txd)
    );

    // 十六进制字符转换函数
    function [7:0] hexchar(input [3:0] nib);
        hexchar = (nib < 10) ? (8'h30 + nib) : (8'h41 + (nib - 10));
    endfunction

    localparam integer PRINT_CNT_W = (PRINT_DIV <= 1) ? 1 : $clog2(PRINT_DIV);
    reg [PRINT_CNT_W-1:0] print_cnt;
    reg print_pulse;

    always @(posedge core_clk) begin
        if (logic_rst) begin print_cnt <= 0; print_pulse <= 0; end
        else if (print_cnt == PRINT_DIV-1) begin print_cnt <= 0; print_pulse <= 1; end
        else begin print_cnt <= print_cnt + 1; print_pulse <= 0; end
    end

    // UART 发送状态机 (输出 S=... B=... E=... C0=... Z0=... F0=... 格式) [cite: 152]
    reg [2:0] fsm_state;
    reg [7:0] msg_idx; // 扩大位宽以支持更长的消息
    reg [63:0] bits_frame, err_frame;
    reg [7:0] stat_frame;
    
    // 新增 RS 统计快照寄存器
    reg [31:0] rs_cnt0_frame, rs_nz0_frame, rs_fail0_frame;
    reg [31:0] rs_cnt1_frame, rs_nz1_frame, rs_fail1_frame;

    localparam S_IDLE_WAIT=0, S_PREPARE=1, S_SEND=2, S_WAIT_BUSY=3, S_WAIT_DONE=4;

    always @(posedge core_clk) begin
        if (logic_rst) begin
            fsm_state <= S_IDLE_WAIT;
            uart_tx_valid <= 0;
        end else begin
            uart_tx_valid <= 0;
            case (fsm_state)
                S_IDLE_WAIT: begin
                    if (print_pulse) begin 
                        bits_frame <= total_bits_cnt;
                        err_frame  <= total_err_cnt; 
                        stat_frame <= uart_status_byte;
                        
                        // 快照 RS 统计
                        rs_cnt0_frame  <= o_stat_cnt0;
                        rs_nz0_frame   <= o_stat_nz_cnt0;
                        rs_fail0_frame <= o_stat_fail_cnt0;
                        rs_cnt1_frame  <= o_stat_cnt1;
                        rs_nz1_frame   <= o_stat_nz_cnt1;
                        rs_fail1_frame <= o_stat_fail_cnt1;

                        msg_idx <= 0; fsm_state <= S_PREPARE;
                    end
                end
                S_PREPARE: begin
                    if (uart_tx_ready) begin
                        case (msg_idx)
                            // "S=XX "
                            0: uart_tx_data <= "S"; 1: uart_tx_data <= "=";
                            2: uart_tx_data <= hexchar(stat_frame[7:4]);
                            3: uart_tx_data <= hexchar(stat_frame[3:0]); 4: uart_tx_data <= " ";
                            
                            // "B=XP.. "
                            5: uart_tx_data <= "B"; 6: uart_tx_data <= "=";
                            7: uart_tx_data <= hexchar(bits_frame[63:60]); 8: uart_tx_data <= hexchar(bits_frame[59:56]);
                            9: uart_tx_data <= hexchar(bits_frame[55:52]); 10: uart_tx_data <= hexchar(bits_frame[51:48]);
                            11: uart_tx_data <= hexchar(bits_frame[47:44]);
                            12: uart_tx_data <= hexchar(bits_frame[43:40]);
                            13: uart_tx_data <= hexchar(bits_frame[39:36]); 14: uart_tx_data <= hexchar(bits_frame[35:32]);
                            15: uart_tx_data <= hexchar(bits_frame[31:28]); 16: uart_tx_data <= hexchar(bits_frame[27:24]);
                            17: uart_tx_data <= hexchar(bits_frame[23:20]); 18: uart_tx_data <= hexchar(bits_frame[19:16]);
                            19: uart_tx_data <= hexchar(bits_frame[15:12]); 20: uart_tx_data <= hexchar(bits_frame[11:8]);
                            21: uart_tx_data <= hexchar(bits_frame[7:4]);
                            22: uart_tx_data <= hexchar(bits_frame[3:0]);
                            23: uart_tx_data <= " "; 
                            
                            // "E=XP.. "
                            24: uart_tx_data <= "E"; 25: uart_tx_data <= "=";
                            26: uart_tx_data <= hexchar(err_frame[63:60]); 27: uart_tx_data <= hexchar(err_frame[59:56]);
                            28: uart_tx_data <= hexchar(err_frame[55:52]); 29: uart_tx_data <= hexchar(err_frame[51:48]);
                            30: uart_tx_data <= hexchar(err_frame[47:44]);
                            31: uart_tx_data <= hexchar(err_frame[43:40]);
                            32: uart_tx_data <= hexchar(err_frame[39:36]); 33: uart_tx_data <= hexchar(err_frame[35:32]);
                            34: uart_tx_data <= hexchar(err_frame[31:28]); 35: uart_tx_data <= hexchar(err_frame[27:24]);
                            36: uart_tx_data <= hexchar(err_frame[23:20]); 37: uart_tx_data <= hexchar(err_frame[19:16]);
                            38: uart_tx_data <= hexchar(err_frame[15:12]); 39: uart_tx_data <= hexchar(err_frame[11:8]);
                            40: uart_tx_data <= hexchar(err_frame[7:4]);
                            41: uart_tx_data <= hexchar(err_frame[3:0]);
                            42: uart_tx_data <= " ";

                            // "F0=XXXXXXXX " (Fail ch0)
                            43: uart_tx_data <= "F"; 44: uart_tx_data <= "0"; 45: uart_tx_data <= "=";
                            46: uart_tx_data <= hexchar(rs_fail0_frame[31:28]); 47: uart_tx_data <= hexchar(rs_fail0_frame[27:24]);
                            48: uart_tx_data <= hexchar(rs_fail0_frame[23:20]); 49: uart_tx_data <= hexchar(rs_fail0_frame[19:16]);
                            50: uart_tx_data <= hexchar(rs_fail0_frame[15:12]); 51: uart_tx_data <= hexchar(rs_fail0_frame[11:8]);
                            52: uart_tx_data <= hexchar(rs_fail0_frame[7:4]);   53: uart_tx_data <= hexchar(rs_fail0_frame[3:0]);
                            54: uart_tx_data <= " ";

                            // "Z0=XXXXXXXX " (Non-Zero ch0)
                            55: uart_tx_data <= "Z"; 56: uart_tx_data <= "0"; 57: uart_tx_data <= "=";
                            58: uart_tx_data <= hexchar(rs_nz0_frame[31:28]); 59: uart_tx_data <= hexchar(rs_nz0_frame[27:24]);
                            60: uart_tx_data <= hexchar(rs_nz0_frame[23:20]); 61: uart_tx_data <= hexchar(rs_nz0_frame[19:16]);
                            62: uart_tx_data <= hexchar(rs_nz0_frame[15:12]); 63: uart_tx_data <= hexchar(rs_nz0_frame[11:8]);
                            64: uart_tx_data <= hexchar(rs_nz0_frame[7:4]);   65: uart_tx_data <= hexchar(rs_nz0_frame[3:0]);
                            66: uart_tx_data <= " ";

                            // "F1=XXXXXXXX " (Fail ch1)
                            67: uart_tx_data <= "F"; 68: uart_tx_data <= "1"; 69: uart_tx_data <= "=";
                            70: uart_tx_data <= hexchar(rs_fail1_frame[31:28]); 71: uart_tx_data <= hexchar(rs_fail1_frame[27:24]);
                            72: uart_tx_data <= hexchar(rs_fail1_frame[23:20]); 73: uart_tx_data <= hexchar(rs_fail1_frame[19:16]);
                            74: uart_tx_data <= hexchar(rs_fail1_frame[15:12]); 75: uart_tx_data <= hexchar(rs_fail1_frame[11:8]);
                            76: uart_tx_data <= hexchar(rs_fail1_frame[7:4]);   77: uart_tx_data <= hexchar(rs_fail1_frame[3:0]);
                            78: uart_tx_data <= " ";

                            // "Z1=XXXXXXXX\r\n" (Non-Zero ch1)
                            79: uart_tx_data <= "Z"; 80: uart_tx_data <= "1"; 81: uart_tx_data <= "=";
                            82: uart_tx_data <= hexchar(rs_nz1_frame[31:28]); 83: uart_tx_data <= hexchar(rs_nz1_frame[27:24]);
                            84: uart_tx_data <= hexchar(rs_nz1_frame[23:20]); 85: uart_tx_data <= hexchar(rs_nz1_frame[19:16]);
                            86: uart_tx_data <= hexchar(rs_nz1_frame[15:12]); 87: uart_tx_data <= hexchar(rs_nz1_frame[11:8]);
                            88: uart_tx_data <= hexchar(rs_nz1_frame[7:4]);   89: uart_tx_data <= hexchar(rs_nz1_frame[3:0]);
                            
                            90: uart_tx_data <= 8'h0D; 91: uart_tx_data <= 8'h0A;
                            default: uart_tx_data <= "?";
                        endcase
                        fsm_state <= S_SEND;
                    end
                end
                S_SEND: begin uart_tx_valid <= 1; fsm_state <= S_WAIT_BUSY; end
                S_WAIT_BUSY: if (!uart_tx_ready) fsm_state <= S_WAIT_DONE;
                S_WAIT_DONE: if (uart_tx_ready) begin
                    if (msg_idx == 91) fsm_state <= S_IDLE_WAIT;
                    else begin
                        msg_idx <= msg_idx + 1;
                        fsm_state <= S_PREPARE;
                    end
                end
            endcase
        end
    end

endmodule