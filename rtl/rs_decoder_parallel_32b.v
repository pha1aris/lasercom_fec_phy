`timescale 1ns / 1ps

module rs_decoder_parallel_32b (
    input  wire         aclk,
    input  wire         aresetn,

    // 输入：数据 32bit + 擦除标记 4bit (每字节对应1bit)
    // s_axis_input_tuser_erase[0] 是 byte0 (tdata[7:0]) 的擦除标记
    input  wire [31:0]  s_axis_input_tdata,
    input  wire [3:0]   s_axis_input_tuser_erase, 
    input  wire         s_axis_input_tvalid,
    input  wire         s_axis_input_tlast, 
    output wire         s_axis_input_tready,

    // 输出：纯净的 32bit 数据
    output wire [31:0]  m_axis_output_tdata,
    output wire         m_axis_output_tvalid,
    output wire         m_axis_output_tlast,
    input  wire         m_axis_output_tready,
    
    // 统计：16-bit 统计信息 (只要有一路非0就算有错/纠正)
    output wire [15:0]  m_stat_tdata,
    output wire         m_stat_tvalid
);

    wire rst = ~aresetn;
    
    // 1. 拆分 Lane (32-bit -> 4x 8-bit, 加上 Erasure bit)
    // ------------------------------------------------------------
    // lane_din [8]   = Erasure Flag
    // lane_din [7:0] = Data
    wire [8:0] lane_din [0:3];
    assign lane_din[0] = {s_axis_input_tuser_erase[0], s_axis_input_tdata[7:0]};
    assign lane_din[1] = {s_axis_input_tuser_erase[1], s_axis_input_tdata[15:8]};
    assign lane_din[2] = {s_axis_input_tuser_erase[2], s_axis_input_tdata[23:16]};
    assign lane_din[3] = {s_axis_input_tuser_erase[3], s_axis_input_tdata[31:24]};

    wire [3:0] lane_ready;
    assign s_axis_input_tready = &lane_ready; // 所有 Lane Ready

    // 2. 例化 4 个 Backend
    // ------------------------------------------------------------
    wire [7:0]  lane_dout [0:3];
    wire [3:0]  lane_valid;
    wire [3:0]  lane_last;
    wire [15:0] lane_stat [0:3];
    wire [3:0]  lane_stat_valid;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : lanes
            rs_decode_backend_x4 #(
                .RS_N(255),
                .OUT_FIFO_DEPTH(1024)
            ) u_backend (
                .rst                (rst),
                .core_clk           (aclk),
                
                // 输入 9-bit
                .s_axis_input_tdata (lane_din[i]), 
                .s_axis_input_tvalid(s_axis_input_tvalid),
                .s_axis_input_tlast (s_axis_input_tlast),
                .s_axis_input_tready(lane_ready[i]),

                // 输出 8-bit
                .output_tdata       (lane_dout[i]),
                .output_tvalid      (lane_valid[i]),
                .output_tready      (m_axis_output_tready),
                
                // 统计 16-bit
                .stat_tdata         (lane_stat[i]),
                .stat_tvalid        (lane_stat_valid[i])
            );
        end
    endgenerate

    // 3. 输出合并
    // ------------------------------------------------------------
    assign m_axis_output_tvalid = &lane_valid;
    assign m_axis_output_tlast  = lane_last[0];
    assign m_axis_output_tdata  = {lane_dout[3], lane_dout[2], lane_dout[1], lane_dout[0]};

    // 统计聚合：这里简单地将所有路的统计进行 OR，或者你可以只引出 lane0
    assign m_stat_tdata  = lane_stat[0] | lane_stat[1] | lane_stat[2] | lane_stat[3];
    assign m_stat_tvalid = |lane_stat_valid;

endmodule