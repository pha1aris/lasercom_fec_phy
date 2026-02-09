`timescale 1ns/1ps

module fifo_8b_flag_sync #(
    parameter integer DEPTH  = 64,
    parameter integer GUARD  = 1
)(
    input  wire            clk,
    input  wire            rst,

    input  wire [7:0]      in_data,
    input  wire            in_flag,
    input  wire            in_valid,
    output wire            in_ready,

    output wire [7:0]      out_data,
    output wire            out_flag,
    output wire            out_valid,
    input  wire            out_ready
);

    localparam integer AW = $clog2(DEPTH);

    // 存储数据 + flag
    reg [8:0] mem [0:DEPTH-1];

    // 指针
    reg [AW:0] wr_ptr;
    reg [AW:0] rd_ptr;

    // 输出寄存（关键：打断组合环）
    reg        out_valid_r;
    reg [7:0]  out_data_r;
    reg        out_flag_r;

    // mem 中的使用量（不含 out_reg）
    wire [AW:0] used_mem  = wr_ptr - rd_ptr;
    wire        empty_mem = (used_mem == { (AW+1){1'b0} });

    // 总使用量（把 out_reg 也算进去，避免“容量 +1”）
    wire [AW:0] used_total = used_mem + {{AW{1'b0}}, out_valid_r};

    localparam [AW:0] FULL_LEVEL = DEPTH - GUARD;
    wire almost_full = (used_total >= FULL_LEVEL);

    assign in_ready  = ~almost_full;
    assign out_valid = out_valid_r;
    assign out_data  = out_data_r;
    assign out_flag  = out_flag_r;

    wire push = in_valid && in_ready;
    wire take = out_valid_r && out_ready;

    // 需要装填输出寄存器：1) out_reg 空，或 2) 本拍被消费
    wire need_refill = (~out_valid_r) || take;

    // refill 优先级：
    // - mem 非空：从 mem 读（同步装入 out_reg，并 rd_ptr++）
    // - mem 为空但本拍 push：直接旁路 in_* 到 out_reg（不写 mem、不动指针）
    wire do_mem_refill = need_refill && ~empty_mem;
    wire do_bypass     = need_refill &&  empty_mem && push;

    // push 是否真正写入 mem（旁路时不写）
    wire do_mem_write  = push && ~do_bypass;

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr      <= { (AW+1){1'b0} };
            rd_ptr      <= { (AW+1){1'b0} };
            out_valid_r <= 1'b0;
            out_data_r  <= 8'd0;
            out_flag_r  <= 1'b0;

            // 仿真清零（综合会推掉/无关功能）
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= 9'd0;
            end
        end else begin
            // 写 mem
            if (do_mem_write) begin
                mem[wr_ptr[AW-1:0]] <= {in_flag, in_data};
                wr_ptr <= wr_ptr + 1'b1;
            end

            // refill out_reg
            if (do_bypass) begin
                // 旁路：新数据直接成为输出
                out_valid_r <= 1'b1;
                out_data_r  <= in_data;
                out_flag_r  <= in_flag;
            end else if (do_mem_refill) begin
                // 同步取 mem：把读数据寄存到输出
                {out_flag_r, out_data_r} <= mem[rd_ptr[AW-1:0]];
                out_valid_r <= 1'b1;
                rd_ptr      <= rd_ptr + 1'b1;
            end else if (take) begin
                // 被消费且无可补：输出无效
                out_valid_r <= 1'b0;
            end
        end
    end

endmodule
