
// ================================================================
// Simple sync FIFO (1-clock), show-ahead/FWFT style
//   - dout = mem[rd_ptr] always
//   - rd_en pops current element
// ================================================================
module rs_backend_fifo #(
    parameter integer WIDTH = 9,
    parameter integer DEPTH = 512
)(
    input  wire             clk,
    input  wire             rst,

    input  wire [WIDTH-1:0] din,
    input  wire             wr_en,
    output wire             full,

    output wire [WIDTH-1:0] dout,
    input  wire             rd_en,
    output wire             empty
);
    reg [WIDTH-1:0] mem [0:DEPTH-1];

    reg [$clog2(DEPTH):0]     count;
    reg [$clog2(DEPTH)-1:0]   wr_ptr, rd_ptr;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    // FWFT/show-ahead
    assign dout = mem[rd_ptr];

    wire do_wr = wr_en && ~full;
    wire do_rd = rd_en && ~empty;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count  <= 0;
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (do_wr) begin
                mem[wr_ptr] <= din;
                if (wr_ptr == DEPTH-1) wr_ptr <= 0;
                else wr_ptr <= wr_ptr + 1'b1;
            end

            if (do_rd) begin
                if (rd_ptr == DEPTH-1) rd_ptr <= 0;
                else rd_ptr <= rd_ptr + 1'b1;
            end

            case ({do_wr, do_rd})
              2'b10: count <= count + 1'b1;
              2'b01: count <= count - 1'b1;
              default: count <= count;
            endcase
        end
    end
endmodule
