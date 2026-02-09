module gearbox_32to8 (
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] in_data,
    input  wire        in_sync_rst,
    input  wire        in_valid,
    output wire        in_ready,

    output wire [7:0]  out_data,
    output wire        out_sync_rst,
    output wire        out_valid,
    input  wire        out_ready
);

    // ------------------------------------------------------------
    // 2-word elastic buffer: current + next
    // ------------------------------------------------------------
    reg        have_cur, have_nxt;
    reg [31:0] cur_data, nxt_data;
    reg        cur_flag, nxt_flag;

    reg [1:0]  byte_idx;

    // buffer full when both slots occupied
    assign in_ready = ~(have_cur & have_nxt);
    wire in_fire = in_valid & in_ready;

    // output side
    assign out_valid = have_cur;

    assign out_data =
        (byte_idx == 2'd0) ? cur_data[7:0]   :
        (byte_idx == 2'd1) ? cur_data[15:8]  :
        (byte_idx == 2'd2) ? cur_data[23:16] :
                             cur_data[31:24];

    // sync_rst only meaningful when the FIRST BYTE of that word is actually being presented
    assign out_sync_rst = have_cur & cur_flag & (byte_idx == 2'd0);

    wire out_fire = out_valid & out_ready;
    wire pop_word = out_fire & (byte_idx == 2'd3);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            have_cur <= 1'b0;
            have_nxt <= 1'b0;
            cur_data <= 32'd0;
            nxt_data <= 32'd0;
            cur_flag <= 1'b0;
            nxt_flag <= 1'b0;
            byte_idx <= 2'd0;
        end else begin
            // -------------------------
            // 1) advance output bytes
            // -------------------------
            if (out_fire) begin
                if (byte_idx == 2'd3) begin
                    byte_idx <= 2'd0;
                    // pop/shift happens below (so don't clear have_cur here directly)
                end else begin
                    byte_idx <= byte_idx + 1'b1;
                end
            end

            // -------------------------
            // 2) pop/shift current word at end-of-word
            // -------------------------
            if (pop_word) begin
                if (have_nxt) begin
                    cur_data <= nxt_data;
                    cur_flag <= nxt_flag;
                    have_cur <= 1'b1;
                    have_nxt <= 1'b0;
                end else begin
                    have_cur <= 1'b0;
                end
            end

            // -------------------------
            // 3) accept input word into cur/nxt (use updated occupancy conceptually)
            //    handle the case where pop_word frees a slot same cycle
            // -------------------------
            if (in_fire) begin
                // decide destination considering that pop_word might have freed/shifted
                // compute "will_have_cur" after pop/shift
                // (simple safe rule: fill cur if empty; else fill nxt)
                if (!have_cur || (pop_word && !have_nxt)) begin
                    // cur is (or becomes) empty this cycle
                    cur_data <= in_data;
                    cur_flag <= in_sync_rst;
                    have_cur <= 1'b1;
                end else begin
                    // cur occupied -> go to nxt
                    nxt_data <= in_data;
                    nxt_flag <= in_sync_rst;
                    have_nxt <= 1'b1;
                end
            end
        end
    end

    reg [31:0] in_words, out_bytes;
    always @(posedge clk or posedge rst) begin
    if (rst) begin
        in_words  <= 0;
        out_bytes <= 0;
    end else begin
        if (in_fire)  in_words  <= in_words + 1;
        if (out_fire) out_bytes <= out_bytes + 1;
    end
    end

endmodule
