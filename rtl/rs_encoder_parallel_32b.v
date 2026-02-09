`timescale 1ns / 1ps

module rs_encoder_parallel_32b #(
    parameter integer RS_K = 229,  // Data symbols
    parameter integer RS_N = 255   // Total symbols
)(
    input  wire         aclk,
    input  wire         aresetn,   // Active Low Reset

    // ==========================================================
    // S_AXIS Input (32-bit data from GTH/FIFO)
    // ==========================================================
    input  wire [31:0]  s_axis_input_tdata,
    input  wire         s_axis_input_tvalid,
    output wire         s_axis_input_tready,
    // 注意：输入不需要外部提供 tlast，模块内部根据计数器自动产生
    
    // ==========================================================
    // M_AXIS Output (32-bit Encoded Data to Interleaver)
    // ==========================================================
    output wire [31:0]  m_axis_output_tdata,
    output wire         m_axis_output_tvalid,
    input  wire         m_axis_output_tready,
    output wire         m_axis_output_tlast
);

    // ==========================================================
    // 1. 输入计数器 & TLAST 生成
    // ==========================================================
    // 我们需要计数 0 ~ 228 (共229个数据)，在第228时拉高 tlast
    reg [7:0] in_cnt;
    wire      input_fire = s_axis_input_tvalid && s_axis_input_tready;
    
    // 内部生成的 tlast，同时送给 4 个编码器
    wire      internal_input_tlast = (in_cnt == RS_K - 1);

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            in_cnt <= 8'd0;
        end else if (input_fire) begin
            if (internal_input_tlast)
                in_cnt <= 8'd0;
            else
                in_cnt <= in_cnt + 1'b1;
        end
    end

    // ==========================================================
    // 2. 信号拆分与 IP 例化
    // ==========================================================
    // 拆解 32-bit 输入
    wire [7:0] din0 = s_axis_input_tdata[7:0];
    wire [7:0] din1 = s_axis_input_tdata[15:8];
    wire [7:0] din2 = s_axis_input_tdata[23:16];
    wire [7:0] din3 = s_axis_input_tdata[31:24];

    // 4路 IP 的握手信号
    wire ready0, ready1, ready2, ready3;
    wire valid0, valid1, valid2, valid3;
    wire last0,  last1,  last2,  last3;
    wire [7:0] dout0, dout1, dout2, dout3;

    // 只有当 4 个编码器都准备好时，才向上游 assert ready
    assign s_axis_input_tready = ready0 & ready1 & ready2 & ready3;

    // ----------------------------------------------------------
    // Instance 0 (处理 Byte 0)
    // ----------------------------------------------------------
    rs_encoder_0 u_rs_enc_0 (
        .aclk(aclk),
        .s_axis_input_tdata(din0),
        .s_axis_input_tvalid(s_axis_input_tvalid), 
        .s_axis_input_tready(ready0),
        .s_axis_input_tlast(internal_input_tlast),
        
        .m_axis_output_tdata(dout0),
        .m_axis_output_tvalid(valid0),
        .m_axis_output_tready(m_axis_output_tready), // 下游反压直接透传
        .m_axis_output_tlast(last0),
        
        .event_s_input_tlast_missing(),
        .event_s_input_tlast_unexpected()
    );

    // ----------------------------------------------------------
    // Instance 1 (处理 Byte 1)
    // ----------------------------------------------------------
    rs_encoder_0 u_rs_enc_1 (
        .aclk(aclk),
        .s_axis_input_tdata(din1),
        .s_axis_input_tvalid(s_axis_input_tvalid),
        .s_axis_input_tready(ready1),
        .s_axis_input_tlast(internal_input_tlast),
        
        .m_axis_output_tdata(dout1),
        .m_axis_output_tvalid(valid1),
        .m_axis_output_tready(m_axis_output_tready),
        .m_axis_output_tlast(last1),
        
        .event_s_input_tlast_missing(),
        .event_s_input_tlast_unexpected()
    );

    // ----------------------------------------------------------
    // Instance 2 (处理 Byte 2)
    // ----------------------------------------------------------
    rs_encoder_0 u_rs_enc_2 (
        .aclk(aclk),
        .s_axis_input_tdata(din2),
        .s_axis_input_tvalid(s_axis_input_tvalid),
        .s_axis_input_tready(ready2),
        .s_axis_input_tlast(internal_input_tlast),
        
        .m_axis_output_tdata(dout2),
        .m_axis_output_tvalid(valid2),
        .m_axis_output_tready(m_axis_output_tready),
        .m_axis_output_tlast(last2),
        
        .event_s_input_tlast_missing(),
        .event_s_input_tlast_unexpected()
    );

    // ----------------------------------------------------------
    // Instance 3 (处理 Byte 3)
    // ----------------------------------------------------------
    rs_encoder_0 u_rs_enc_3 (
        .aclk(aclk),
        .s_axis_input_tdata(din3),
        .s_axis_input_tvalid(s_axis_input_tvalid),
        .s_axis_input_tready(ready3),
        .s_axis_input_tlast(internal_input_tlast),
        
        .m_axis_output_tdata(dout3),
        .m_axis_output_tvalid(valid3),
        .m_axis_output_tready(m_axis_output_tready),
        .m_axis_output_tlast(last3),
        
        .event_s_input_tlast_missing(),
        .event_s_input_tlast_unexpected()
    );

    // ==========================================================
    // 3. 输出合并与对齐 (Join Logic)
    // ==========================================================
    // 核心对齐逻辑：只有当 4 路 valid 全部为高时，才认为输出有效。
    // 这能处理及其微小的相位偏差（虽然理论上不会有）。
    assign m_axis_output_tvalid = valid0 & valid1 & valid2 & valid3;
    
    // 重新拼装为 32-bit
    assign m_axis_output_tdata  = {dout3, dout2, dout1, dout0};
    
    // TLAST 对齐：任意一路报 tlast 即可（理论上也是齐的）
    assign m_axis_output_tlast  = last0; 

endmodule