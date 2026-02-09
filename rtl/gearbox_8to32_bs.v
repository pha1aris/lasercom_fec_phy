module gearbox_8to32_bs (
    input             clk,
    input             rst,

    input      [7:0]  in_data,
    input             in_valid,
    input             in_block_start,
    output wire       in_ready,

    input             out_ready,
    output reg [31:0] out_data,
    output reg        out_valid,
    output reg        out_block_start
);

    reg [1:0]  byte_cnt;
    reg [31:0] word_reg;
    reg        word_has_block_start;

    wire out_fire = out_valid & out_ready;

    // 输出寄存器空，或者本拍会被消费 → 允许继续接收输入字节
    wire can_accept = ~out_valid | out_fire;
    assign in_ready = can_accept;

    wire byte_fire = in_valid & in_ready;

    // 可选：检测 block_start 是否落在非 byte0（这通常表示你上下游 reset/启动相位没对齐）
    reg bs_misaligned_err;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            byte_cnt             <= 2'd0;
            word_reg             <= 32'd0;
            word_has_block_start <= 1'b0;
            out_data             <= 32'd0;
            out_valid            <= 1'b0;
            out_block_start      <= 1'b0;
            bs_misaligned_err    <= 1'b0;
        end else begin
            // 默认：如果输出被消费，清 out_valid（同拍也可能产生新 word 再置回 1）
            if (out_fire) begin
                out_valid <= 1'b0;
            end

            if (byte_fire) begin
                // block_start 对齐性检查：理想情况只能出现在 byte_cnt==0
                if (in_block_start && (byte_cnt != 2'd0))
                    bs_misaligned_err <= 1'b1;

                word_has_block_start <= word_has_block_start | in_block_start;

                case (byte_cnt)
                    2'd0: word_reg[7:0]   <= in_data;
                    2'd1: word_reg[15:8]  <= in_data;
                    2'd2: word_reg[23:16] <= in_data;
                    2'd3: word_reg[31:24] <= in_data;
                endcase

                if (byte_cnt == 2'd3) begin
                    // 组满一个 32bit word：输出并拉高 valid
                    out_data        <= {in_data, word_reg[23:0]};
                    out_valid       <= 1'b1;

                    // 工业界建议：这里不要“OR 任意位置的 block_start”来当对齐；
                    // 正常情况下 in_block_start 应该只在 byte_cnt==0 出现，否则应视为错位。
                    out_block_start <= word_has_block_start | in_block_start;

                    byte_cnt             <= 2'd0;
                    word_has_block_start <= 1'b0;
                end else begin
                    byte_cnt <= byte_cnt + 1'b1;
                end
            end
        end
    end

endmodule
