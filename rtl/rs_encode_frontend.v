`timescale 1ns/1ps

//==============================================================
// rs_encode_frontend (Improved - optional but recommended)
//
// Fix:
//   [FIX-3] s_axis_input_tlast should be asserted on FIRE (valid&ready)
//          (more strictly AXIS compliant; avoids sticky tlast during stall)
//
// Everything else remains your original behavior.
//==============================================================
module rs_encode_frontend #(
    parameter integer RS_K = 229
)(
    input        clk,
    input        enc_clk,
    input        rst,

    output       fifo_input_rdy,
    input  [7:0] data_i,
    input        data_valid_i,

    input        m_axis_output_tready,
    output [7:0] m_axis_output_tdata,
    output       m_axis_output_tvalid,
    output       m_axis_output_tlast
);

    //============================================================
    // 1) reset sync
    //============================================================
    reg rst_enc_sync_r1, rst_enc_sync_r2;
    wire rst_enc;

    always @(posedge enc_clk or posedge rst) begin
        if (rst) begin
            rst_enc_sync_r1 <= 1'b1;
            rst_enc_sync_r2 <= 1'b1;
        end else begin
            rst_enc_sync_r1 <= 1'b0;
            rst_enc_sync_r2 <= rst_enc_sync_r1;
        end
    end
    assign rst_enc = rst_enc_sync_r2;

    reg reset_sync_r1, reset_sync_r2;
    wire reset_sync;
    always @(posedge clk or posedge rst) begin
        if (rst) {reset_sync_r1, reset_sync_r2} <= 2'b11;
        else     {reset_sync_r1, reset_sync_r2} <= {1'b0, reset_sync_r1};
    end
    assign reset_sync = reset_sync_r2;

    //============================================================
    // 2) async FIFO clk -> enc_clk (FWFT)
    //============================================================
    wire       full, empty;
    wire       wr_rst_busy, rd_rst_busy;
    wire [7:0] fifo_dout;
    wire       fifo_rd_en;

    assign fifo_input_rdy = !full && !wr_rst_busy;

    fifo_0 fifo0_inst2 (
        .srst        (reset_sync),
        .wr_clk      (clk),
        .rd_clk      (enc_clk),
        .din         (data_i),
        .wr_en       (fifo_input_rdy && data_valid_i),
        .rd_en       (fifo_rd_en),
        .dout        (fifo_dout),
        .full        (full),
        .empty       (empty),
        .wr_rst_busy (wr_rst_busy),
        .rd_rst_busy (rd_rst_busy)
    );

    //============================================================
    // 3) FWFT FIFO -> RS Encoder AXIS
    //============================================================
    wire fifo_vld = (!empty) && (!rd_rst_busy) && (!rst_enc);

    wire s_ready;
    wire fire = fifo_vld && s_ready;

    assign fifo_rd_en = fire;

    wire [7:0] s_axis_input_tdata  = fifo_dout;
    wire       s_axis_input_tvalid = fifo_vld;

    //============================================================
    // 4) tlast: count only on fire; assert tlast on fire beat
    //============================================================
    reg [7:0] byte_cnt;

    always @(posedge enc_clk or posedge rst_enc) begin
        if (rst_enc) begin
            byte_cnt <= 8'd0;
        end else if (fire) begin
            if (byte_cnt == RS_K-1)
                byte_cnt <= 8'd0;
            else
                byte_cnt <= byte_cnt + 1'b1;
        end
    end

    // [FIX-3]
    wire s_axis_input_tlast = fire && (byte_cnt == RS_K-1);

    //============================================================
    // 5) RS Encoder IP
    //============================================================
    wire event_s_input_tlast_missing;
    wire event_s_input_tlast_unexpected;

    rs_encoder_0 Encoder (
        .aclk                           (enc_clk),
        .s_axis_input_tdata             (s_axis_input_tdata),
        .s_axis_input_tvalid            (s_axis_input_tvalid),
        .s_axis_input_tready            (s_ready),
        .s_axis_input_tlast             (s_axis_input_tlast),
        .m_axis_output_tdata            (m_axis_output_tdata),
        .m_axis_output_tvalid           (m_axis_output_tvalid),
        .m_axis_output_tready           (m_axis_output_tready),
        .m_axis_output_tlast            (m_axis_output_tlast),
        .event_s_input_tlast_missing    (event_s_input_tlast_missing),
        .event_s_input_tlast_unexpected (event_s_input_tlast_unexpected)
    );

endmodule
