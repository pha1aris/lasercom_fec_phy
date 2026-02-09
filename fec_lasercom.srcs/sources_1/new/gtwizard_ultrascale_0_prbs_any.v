`timescale 1ps/1ps

module gtwizard_ultrascale_0_prbs_any#(
      parameter CHK_MODE = 0,
      parameter INV_PATTERN = 0,
      parameter POLY_LENGHT = 7,
      parameter POLY_TAP = 6,
      parameter NBITS = 16 
)(
    input wire RST,
    input wire CLK,
    input wire [NBITS - 1:0] DATA_IN,
    input wire EN,
    output reg [NBITS - 1:0] DATA_OUT = {NBITS{1'b1}},
    // 【新增端口】 1 = 强制内部闭环（精准统计模式）； 0 = 外部输入反馈（自同步模式）
    input wire i_force_lock 
);

  //--------------------------------------------
  // Internal variables
  //--------------------------------------------

   wire [1:POLY_LENGHT] prbs[NBITS:0];
   wire [NBITS - 1:0] data_in_i;
   wire [NBITS - 1:0] prbs_xor_a;
   wire [NBITS - 1:0] prbs_xor_b;
   wire [NBITS:1] prbs_msb;
   reg  [1:POLY_LENGHT]prbs_reg = {(POLY_LENGHT){1'b1}};

  //--------------------------------------------
  // Implementation
  //--------------------------------------------

   assign data_in_i = INV_PATTERN == 0 ? DATA_IN : ( ~DATA_IN);
   assign prbs[0] = prbs_reg;

   genvar I;
   generate for (I=0; I<NBITS; I=I+1) begin : g1
      assign prbs_xor_a[I] = prbs[I][POLY_TAP] ^ prbs[I][POLY_LENGHT]; // 内部计算的正确值
      assign prbs_xor_b[I] = prbs_xor_a[I] ^ data_in_i[I];             // 比较结果 (Error Bit)
      
      // 【核心修改】
      // 如果 i_force_lock 为 1，强制使用内部产生的 prbs_xor_a 更新寄存器。
      // 这样即使 data_in_i 有误码，也不会污染移位寄存器，从而避免误码扩散。
      assign prbs_msb[I+1] = (CHK_MODE == 0 || i_force_lock == 1) ? prbs_xor_a[I] : data_in_i[I];
      
      assign prbs[I+1] = {prbs_msb[I+1] , prbs[I][1:POLY_LENGHT-1]};
   end
   endgenerate

   always @(posedge CLK) begin
      if(RST == 1'b 1) begin
         prbs_reg <= {POLY_LENGHT{1'b1}};
         DATA_OUT <= {NBITS{1'b1}};
      end
      else if(EN == 1'b 1) begin
         DATA_OUT <= prbs_xor_b;
         prbs_reg <= prbs[NBITS];
      end
  end

endmodule