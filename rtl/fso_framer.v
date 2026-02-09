`timescale 1ns/1ps

module fso_framer #(
    parameter integer W                = 32,
    parameter integer PAYLOAD_WORDS    = 16,
    parameter integer FRAMES_PER_BLOCK = 255
)(
    input                         clk,
    input                         rst_n,

    // 上游 payload 流（32bit）
    input      [W-1:0]            i_payload_data,
    input                         i_payload_valid,
    input                         i_payload_block_start,   // word级块开始标志
    input                         scrambler_en,
    output reg                    o_payload_ready,

    // 下游 TX 流（32bit）与监控端口
    input                         i_tx_ready,
    output reg [W-1:0]            o_tx_data,
    output reg                    o_tx_valid,
    output wire [15:0]            o_frame_in_block,
    output wire [15:0]            o_block_id,
    output reg [15:0]             o_frame_index
);

    localparam [31:0] PREAMBLE_HI   = 32'hEB94_BDA3;
    localparam [31:0] PREAMBLE_LO   = 32'hF6AA_EE24;

    localparam [2:0]  S_WAIT_FIRST  = 3'd0;
    localparam [2:0]  S_PREAMBLE_HI = 3'd1;
    localparam [2:0]  S_PREAMBLE_LO = 3'd2;
    localparam [2:0]  S_HEADER      = 3'd3;
    localparam [2:0]  S_PAYLOAD     = 3'd4;
    localparam [2:0]  S_CRC         = 3'd5;

    reg [2:0]  state;
    reg [15:0] frame_index;
    reg [15:0] payload_cnt;       // 0..PAYLOAD_WORDS-1
    reg [15:0] block_id;
    reg [15:0] frame_in_block;
    reg        first_v;
    reg [31:0] first_d;
    reg        first_bs;          // 该word是否为块开始标志（用于更新block_id/frame_in_block）
    reg        blk_seeded;        // 避免reset后第一次 block_start 就 +1

    assign o_frame_in_block = frame_in_block;
    assign o_block_id       = block_id;

    wire tx_fire = o_tx_valid && i_tx_ready;
    wire        payload_use_first = first_v;
    wire [31:0] payload_word_sel  = payload_use_first ? first_d : i_payload_data;
    wire payload_have_word = (state == S_PAYLOAD) && ( first_v || i_payload_valid );
    wire payload_fire = (state == S_PAYLOAD) && tx_fire && payload_have_word;

    // ============================================================
    // 3) scrambler / CRC：reset/step 都必须基于真正发送的边界
    // ============================================================
    wire header_fire = (state == S_HEADER) && tx_fire;
    wire scram_rst   = header_fire;                // HEADER beat 真发出去 => reset
    wire scram_step  = payload_fire && scrambler_en;

    wire [31:0] scram_dout;
    scrambler u_scrambler (
        .clk       (clk),
        .rst       (!rst_n),
        .scram_rst (scram_rst),
        .scram_en  (scram_step),
        .data_in   (payload_word_sel),
        .data_out  (scram_dout)
    );

    // CRC：HEADER beat 真发出去 reset；payload_fire 推进（对未扰码payload做CRC）
    wire crc_rst_frame = header_fire;
    wire crc_rst       = (~rst_n) | crc_rst_frame;
    wire crc_en        = payload_fire;
    wire [31:0] crc_dout;

    crc32 u_crc32 (
        .clk     (clk),
        .rst     (crc_rst),
        .data_in (payload_word_sel),
        .crc_en  (crc_en),
        .crc_out (crc_dout)
    );

    always @(*) begin
        o_payload_ready = 1'b0;

        if (state == S_WAIT_FIRST) begin
            o_payload_ready = ~first_v;  // 只抓一个首word
        end else if (state == S_PAYLOAD) begin
            // first_v=1 时不向上游要；first_v=0 时只在下游ready时才要（直通无缓存）
            if (!first_v)
                o_payload_ready = i_tx_ready; // 直通且本拍要发出去
            else
                o_payload_ready = 1'b0;
        end else begin
            o_payload_ready = 1'b0;
        end
    end

    wire first_capture_fire = (state == S_WAIT_FIRST) && i_payload_valid && o_payload_ready;

    always @(*) begin
        o_tx_valid = 1'b0;
        o_tx_data  = {W{1'b0}};

        case (state)
            S_WAIT_FIRST: begin
                o_tx_valid = 1'b0;
            end

            S_PREAMBLE_HI: begin
                o_tx_valid = 1'b1;
                o_tx_data  = PREAMBLE_HI;
            end

            S_PREAMBLE_LO: begin
                o_tx_valid = 1'b1;
                o_tx_data  = PREAMBLE_LO;
            end

            S_HEADER: begin
                o_tx_valid = 1'b1;
                o_tx_data  = {block_id, frame_in_block};
            end

            S_PAYLOAD: begin
                // 有数据才valid；first_v=0 时 valid=i_payload_valid（上游需遵守valid稳定）
                o_tx_valid = payload_have_word;
                o_tx_data  = scrambler_en ? scram_dout : payload_word_sel;
            end

            S_CRC: begin
                o_tx_valid = 1'b1;
                o_tx_data  = crc_dout;
            end

            default: begin
                o_tx_valid = 1'b0;
                o_tx_data  = {W{1'b0}};
            end
        endcase
    end

    // ============================================================
    // 6) 状态机/计数器：只在对应 *_fire 时推进
    // ============================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= S_WAIT_FIRST;

            frame_index    <= 16'd0;
            o_frame_index  <= 16'd0;

            payload_cnt    <= 16'd0;
            block_id       <= 16'd0;
            frame_in_block <= 16'd0;

            first_v        <= 1'b0;
            first_d        <= 32'd0;
            first_bs       <= 1'b0;
            blk_seeded     <= 1'b0;
        end else begin
            case (state)

                // ------------------------------------------------
                // 必须先抓到“本帧首payload word”，才开始发 preamble/header/payload/crc
                // ------------------------------------------------
                S_WAIT_FIRST: begin
                    if (first_capture_fire) begin
                        first_v  <= 1'b1;
                        first_d  <= i_payload_data;
                        first_bs <= i_payload_block_start;

                        // ★block_id 更新：只在“首word被捕获”那拍更新，且与tx反压无关
                        if (i_payload_block_start) begin
                            if (!blk_seeded) begin
                                blk_seeded <= 1'b1;
                                block_id   <= 16'd0;
                            end else begin
                                block_id   <= block_id + 1'b1;
                            end
                            frame_in_block <= 16'd0;
                        end

                        state <= S_PREAMBLE_HI;
                    end
                end

                // ------------------------------------------------
                // 以下这些 state 都是“单beat输出”，只在 tx_fire 才推进
                // ------------------------------------------------
                S_PREAMBLE_HI: begin
                    if (tx_fire)
                        state <= S_PREAMBLE_LO;
                end

                S_PREAMBLE_LO: begin
                    if (tx_fire)
                        state <= S_HEADER;
                end

                S_HEADER: begin
                    if (tx_fire) begin
                        o_frame_index <= frame_index;
                        payload_cnt   <= 16'd0;
                        state         <= S_PAYLOAD;
                    end
                end

                // ------------------------------------------------
                // PAYLOAD：只有 payload_fire 才清 first_v / 加计数 / 跳转
                // ------------------------------------------------
                S_PAYLOAD: begin
                    if (payload_fire) begin
                        if (first_v)
                            first_v <= 1'b0;

                        if (payload_cnt == PAYLOAD_WORDS - 1) begin
                            payload_cnt <= 16'd0;
                            state       <= S_CRC;
                        end else begin
                            payload_cnt <= payload_cnt + 1'b1;
                            state       <= S_PAYLOAD;
                        end
                    end
                end

                // ------------------------------------------------
                // CRC：只有 tx_fire 才真正结束本帧并进入下一帧
                // ------------------------------------------------
                S_CRC: begin
                    if (tx_fire) begin
                        frame_index <= frame_index + 1'b1;

                        if (frame_in_block == FRAMES_PER_BLOCK - 1)
                            frame_in_block <= 16'd0;
                        else
                            frame_in_block <= frame_in_block + 1'b1;

                        state <= S_WAIT_FIRST;
                    end
                end

                default: begin
                    state <= S_WAIT_FIRST;
                end
            endcase
        end
    end

endmodule
