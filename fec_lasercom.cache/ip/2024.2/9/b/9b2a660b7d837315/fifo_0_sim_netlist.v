// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Tue Jan 27 21:02:59 2026
// Host        : FSO-A running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ fifo_0_sim_netlist.v
// Design      : fifo_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu15eg-ffvb1156-2-i
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "fifo_0,fifo_generator_v13_2_11,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_11,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (srst,
    wr_clk,
    rd_clk,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    empty,
    wr_rst_busy,
    rd_rst_busy);
  input srst;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 write_clk CLK" *) (* x_interface_mode = "slave write_clk" *) (* x_interface_parameter = "XIL_INTERFACENAME write_clk, FREQ_HZ 1000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input wr_clk;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 read_clk CLK" *) (* x_interface_mode = "slave read_clk" *) (* x_interface_parameter = "XIL_INTERFACENAME read_clk, FREQ_HZ 1000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input rd_clk;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *) (* x_interface_mode = "slave FIFO_WRITE" *) input [7:0]din;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *) input wr_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *) (* x_interface_mode = "slave FIFO_READ" *) input rd_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *) output [7:0]dout;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *) output full;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *) output empty;
  output wr_rst_busy;
  output rd_rst_busy;

  wire [7:0]din;
  wire [7:0]dout;
  wire empty;
  wire full;
  wire rd_clk;
  wire rd_en;
  wire rd_rst_busy;
  wire srst;
  wire wr_clk;
  wire wr_en;
  wire wr_rst_busy;
  wire NLW_U0_almost_empty_UNCONNECTED;
  wire NLW_U0_almost_full_UNCONNECTED;
  wire NLW_U0_axi_ar_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_overflow_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_full_UNCONNECTED;
  wire NLW_U0_axi_ar_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_underflow_UNCONNECTED;
  wire NLW_U0_axi_aw_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_overflow_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_full_UNCONNECTED;
  wire NLW_U0_axi_aw_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_underflow_UNCONNECTED;
  wire NLW_U0_axi_b_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_overflow_UNCONNECTED;
  wire NLW_U0_axi_b_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_b_prog_full_UNCONNECTED;
  wire NLW_U0_axi_b_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_underflow_UNCONNECTED;
  wire NLW_U0_axi_r_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_overflow_UNCONNECTED;
  wire NLW_U0_axi_r_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_r_prog_full_UNCONNECTED;
  wire NLW_U0_axi_r_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_underflow_UNCONNECTED;
  wire NLW_U0_axi_w_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_overflow_UNCONNECTED;
  wire NLW_U0_axi_w_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_w_prog_full_UNCONNECTED;
  wire NLW_U0_axi_w_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_underflow_UNCONNECTED;
  wire NLW_U0_axis_dbiterr_UNCONNECTED;
  wire NLW_U0_axis_overflow_UNCONNECTED;
  wire NLW_U0_axis_prog_empty_UNCONNECTED;
  wire NLW_U0_axis_prog_full_UNCONNECTED;
  wire NLW_U0_axis_sbiterr_UNCONNECTED;
  wire NLW_U0_axis_underflow_UNCONNECTED;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_m_axi_arvalid_UNCONNECTED;
  wire NLW_U0_m_axi_awvalid_UNCONNECTED;
  wire NLW_U0_m_axi_bready_UNCONNECTED;
  wire NLW_U0_m_axi_rready_UNCONNECTED;
  wire NLW_U0_m_axi_wlast_UNCONNECTED;
  wire NLW_U0_m_axi_wvalid_UNCONNECTED;
  wire NLW_U0_m_axis_tlast_UNCONNECTED;
  wire NLW_U0_m_axis_tvalid_UNCONNECTED;
  wire NLW_U0_overflow_UNCONNECTED;
  wire NLW_U0_prog_empty_UNCONNECTED;
  wire NLW_U0_prog_full_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_s_axis_tready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire NLW_U0_underflow_UNCONNECTED;
  wire NLW_U0_valid_UNCONNECTED;
  wire NLW_U0_wr_ack_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_data_count_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_araddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_arburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_arlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_aruser_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_awaddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_awburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_awlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awuser_UNCONNECTED;
  wire [63:0]NLW_U0_m_axi_wdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_wstrb_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wuser_UNCONNECTED;
  wire [7:0]NLW_U0_m_axis_tdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tdest_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tid_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tkeep_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tstrb_UNCONNECTED;
  wire [3:0]NLW_U0_m_axis_tuser_UNCONNECTED;
  wire [10:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [10:0]NLW_U0_wr_data_count_UNCONNECTED;

  (* C_ADD_NGC_CONSTRAINT = "0" *) 
  (* C_APPLICATION_TYPE_AXIS = "0" *) 
  (* C_APPLICATION_TYPE_RACH = "0" *) 
  (* C_APPLICATION_TYPE_RDCH = "0" *) 
  (* C_APPLICATION_TYPE_WACH = "0" *) 
  (* C_APPLICATION_TYPE_WDCH = "0" *) 
  (* C_APPLICATION_TYPE_WRCH = "0" *) 
  (* C_AXIS_TDATA_WIDTH = "8" *) 
  (* C_AXIS_TDEST_WIDTH = "1" *) 
  (* C_AXIS_TID_WIDTH = "1" *) 
  (* C_AXIS_TKEEP_WIDTH = "1" *) 
  (* C_AXIS_TSTRB_WIDTH = "1" *) 
  (* C_AXIS_TUSER_WIDTH = "4" *) 
  (* C_AXIS_TYPE = "0" *) 
  (* C_AXI_ADDR_WIDTH = "32" *) 
  (* C_AXI_ARUSER_WIDTH = "1" *) 
  (* C_AXI_AWUSER_WIDTH = "1" *) 
  (* C_AXI_BUSER_WIDTH = "1" *) 
  (* C_AXI_DATA_WIDTH = "64" *) 
  (* C_AXI_ID_WIDTH = "1" *) 
  (* C_AXI_LEN_WIDTH = "8" *) 
  (* C_AXI_LOCK_WIDTH = "1" *) 
  (* C_AXI_RUSER_WIDTH = "1" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_AXI_WUSER_WIDTH = "1" *) 
  (* C_COMMON_CLOCK = "0" *) 
  (* C_COUNT_TYPE = "0" *) 
  (* C_DATA_COUNT_WIDTH = "11" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "8" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "1" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "8" *) 
  (* C_ENABLE_RLOCS = "0" *) 
  (* C_ENABLE_RST_SYNC = "1" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_ERROR_INJECTION_TYPE = "0" *) 
  (* C_ERROR_INJECTION_TYPE_AXIS = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WRCH = "0" *) 
  (* C_FAMILY = "zynquplus" *) 
  (* C_FULL_FLAGS_RST_VAL = "0" *) 
  (* C_HAS_ALMOST_EMPTY = "0" *) 
  (* C_HAS_ALMOST_FULL = "0" *) 
  (* C_HAS_AXIS_TDATA = "1" *) 
  (* C_HAS_AXIS_TDEST = "0" *) 
  (* C_HAS_AXIS_TID = "0" *) 
  (* C_HAS_AXIS_TKEEP = "0" *) 
  (* C_HAS_AXIS_TLAST = "0" *) 
  (* C_HAS_AXIS_TREADY = "1" *) 
  (* C_HAS_AXIS_TSTRB = "0" *) 
  (* C_HAS_AXIS_TUSER = "1" *) 
  (* C_HAS_AXI_ARUSER = "0" *) 
  (* C_HAS_AXI_AWUSER = "0" *) 
  (* C_HAS_AXI_BUSER = "0" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_AXI_RD_CHANNEL = "1" *) 
  (* C_HAS_AXI_RUSER = "0" *) 
  (* C_HAS_AXI_WR_CHANNEL = "1" *) 
  (* C_HAS_AXI_WUSER = "0" *) 
  (* C_HAS_BACKUP = "0" *) 
  (* C_HAS_DATA_COUNT = "0" *) 
  (* C_HAS_DATA_COUNTS_AXIS = "0" *) 
  (* C_HAS_DATA_COUNTS_RACH = "0" *) 
  (* C_HAS_DATA_COUNTS_RDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WACH = "0" *) 
  (* C_HAS_DATA_COUNTS_WDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WRCH = "0" *) 
  (* C_HAS_INT_CLK = "0" *) 
  (* C_HAS_MASTER_CE = "0" *) 
  (* C_HAS_MEMINIT_FILE = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_PROG_FLAGS_AXIS = "0" *) 
  (* C_HAS_PROG_FLAGS_RACH = "0" *) 
  (* C_HAS_PROG_FLAGS_RDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WACH = "0" *) 
  (* C_HAS_PROG_FLAGS_WDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WRCH = "0" *) 
  (* C_HAS_RD_DATA_COUNT = "0" *) 
  (* C_HAS_RD_RST = "0" *) 
  (* C_HAS_RST = "0" *) 
  (* C_HAS_SLAVE_CE = "0" *) 
  (* C_HAS_SRST = "1" *) 
  (* C_HAS_UNDERFLOW = "0" *) 
  (* C_HAS_VALID = "0" *) 
  (* C_HAS_WR_ACK = "0" *) 
  (* C_HAS_WR_DATA_COUNT = "0" *) 
  (* C_HAS_WR_RST = "0" *) 
  (* C_IMPLEMENTATION_TYPE = "6" *) 
  (* C_IMPLEMENTATION_TYPE_AXIS = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WRCH = "1" *) 
  (* C_INIT_WR_PNTR_VAL = "0" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_MEMORY_TYPE = "4" *) 
  (* C_MIF_FILE_NAME = "BlankString" *) 
  (* C_MSGON_VAL = "1" *) 
  (* C_OPTIMIZATION_MODE = "0" *) 
  (* C_OVERFLOW_LOW = "0" *) 
  (* C_POWER_SAVING_MODE = "0" *) 
  (* C_PRELOAD_LATENCY = "0" *) 
  (* C_PRELOAD_REGS = "1" *) 
  (* C_PRIM_FIFO_TYPE = "2kx9" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "512x72" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "512x72" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "6" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "7" *) 
  (* C_PROG_EMPTY_TYPE = "0" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "2047" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "2046" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "11" *) 
  (* C_RD_DEPTH = "2048" *) 
  (* C_RD_FREQ = "1" *) 
  (* C_RD_PNTR_WIDTH = "11" *) 
  (* C_REG_SLICE_MODE_AXIS = "0" *) 
  (* C_REG_SLICE_MODE_RACH = "0" *) 
  (* C_REG_SLICE_MODE_RDCH = "0" *) 
  (* C_REG_SLICE_MODE_WACH = "0" *) 
  (* C_REG_SLICE_MODE_WDCH = "0" *) 
  (* C_REG_SLICE_MODE_WRCH = "0" *) 
  (* C_SELECT_XPM = "0" *) 
  (* C_SYNCHRONIZER_STAGE = "2" *) 
  (* C_UNDERFLOW_LOW = "0" *) 
  (* C_USE_COMMON_OVERFLOW = "0" *) 
  (* C_USE_COMMON_UNDERFLOW = "0" *) 
  (* C_USE_DEFAULT_SETTINGS = "0" *) 
  (* C_USE_DOUT_RST = "1" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_ECC_AXIS = "0" *) 
  (* C_USE_ECC_RACH = "0" *) 
  (* C_USE_ECC_RDCH = "0" *) 
  (* C_USE_ECC_WACH = "0" *) 
  (* C_USE_ECC_WDCH = "0" *) 
  (* C_USE_ECC_WRCH = "0" *) 
  (* C_USE_EMBEDDED_REG = "0" *) 
  (* C_USE_FIFO16_FLAGS = "0" *) 
  (* C_USE_FWFT_DATA_COUNT = "0" *) 
  (* C_USE_PIPELINE_REG = "0" *) 
  (* C_VALID_LOW = "0" *) 
  (* C_WACH_TYPE = "0" *) 
  (* C_WDCH_TYPE = "0" *) 
  (* C_WRCH_TYPE = "0" *) 
  (* C_WR_ACK_LOW = "0" *) 
  (* C_WR_DATA_COUNT_WIDTH = "11" *) 
  (* C_WR_DEPTH = "2048" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "1" *) 
  (* C_WR_PNTR_WIDTH = "11" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_fifo_generator_v13_2_11 U0
       (.almost_empty(NLW_U0_almost_empty_UNCONNECTED),
        .almost_full(NLW_U0_almost_full_UNCONNECTED),
        .axi_ar_data_count(NLW_U0_axi_ar_data_count_UNCONNECTED[4:0]),
        .axi_ar_dbiterr(NLW_U0_axi_ar_dbiterr_UNCONNECTED),
        .axi_ar_injectdbiterr(1'b0),
        .axi_ar_injectsbiterr(1'b0),
        .axi_ar_overflow(NLW_U0_axi_ar_overflow_UNCONNECTED),
        .axi_ar_prog_empty(NLW_U0_axi_ar_prog_empty_UNCONNECTED),
        .axi_ar_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_prog_full(NLW_U0_axi_ar_prog_full_UNCONNECTED),
        .axi_ar_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_rd_data_count(NLW_U0_axi_ar_rd_data_count_UNCONNECTED[4:0]),
        .axi_ar_sbiterr(NLW_U0_axi_ar_sbiterr_UNCONNECTED),
        .axi_ar_underflow(NLW_U0_axi_ar_underflow_UNCONNECTED),
        .axi_ar_wr_data_count(NLW_U0_axi_ar_wr_data_count_UNCONNECTED[4:0]),
        .axi_aw_data_count(NLW_U0_axi_aw_data_count_UNCONNECTED[4:0]),
        .axi_aw_dbiterr(NLW_U0_axi_aw_dbiterr_UNCONNECTED),
        .axi_aw_injectdbiterr(1'b0),
        .axi_aw_injectsbiterr(1'b0),
        .axi_aw_overflow(NLW_U0_axi_aw_overflow_UNCONNECTED),
        .axi_aw_prog_empty(NLW_U0_axi_aw_prog_empty_UNCONNECTED),
        .axi_aw_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_prog_full(NLW_U0_axi_aw_prog_full_UNCONNECTED),
        .axi_aw_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_rd_data_count(NLW_U0_axi_aw_rd_data_count_UNCONNECTED[4:0]),
        .axi_aw_sbiterr(NLW_U0_axi_aw_sbiterr_UNCONNECTED),
        .axi_aw_underflow(NLW_U0_axi_aw_underflow_UNCONNECTED),
        .axi_aw_wr_data_count(NLW_U0_axi_aw_wr_data_count_UNCONNECTED[4:0]),
        .axi_b_data_count(NLW_U0_axi_b_data_count_UNCONNECTED[4:0]),
        .axi_b_dbiterr(NLW_U0_axi_b_dbiterr_UNCONNECTED),
        .axi_b_injectdbiterr(1'b0),
        .axi_b_injectsbiterr(1'b0),
        .axi_b_overflow(NLW_U0_axi_b_overflow_UNCONNECTED),
        .axi_b_prog_empty(NLW_U0_axi_b_prog_empty_UNCONNECTED),
        .axi_b_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_prog_full(NLW_U0_axi_b_prog_full_UNCONNECTED),
        .axi_b_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_rd_data_count(NLW_U0_axi_b_rd_data_count_UNCONNECTED[4:0]),
        .axi_b_sbiterr(NLW_U0_axi_b_sbiterr_UNCONNECTED),
        .axi_b_underflow(NLW_U0_axi_b_underflow_UNCONNECTED),
        .axi_b_wr_data_count(NLW_U0_axi_b_wr_data_count_UNCONNECTED[4:0]),
        .axi_r_data_count(NLW_U0_axi_r_data_count_UNCONNECTED[10:0]),
        .axi_r_dbiterr(NLW_U0_axi_r_dbiterr_UNCONNECTED),
        .axi_r_injectdbiterr(1'b0),
        .axi_r_injectsbiterr(1'b0),
        .axi_r_overflow(NLW_U0_axi_r_overflow_UNCONNECTED),
        .axi_r_prog_empty(NLW_U0_axi_r_prog_empty_UNCONNECTED),
        .axi_r_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_prog_full(NLW_U0_axi_r_prog_full_UNCONNECTED),
        .axi_r_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_rd_data_count(NLW_U0_axi_r_rd_data_count_UNCONNECTED[10:0]),
        .axi_r_sbiterr(NLW_U0_axi_r_sbiterr_UNCONNECTED),
        .axi_r_underflow(NLW_U0_axi_r_underflow_UNCONNECTED),
        .axi_r_wr_data_count(NLW_U0_axi_r_wr_data_count_UNCONNECTED[10:0]),
        .axi_w_data_count(NLW_U0_axi_w_data_count_UNCONNECTED[10:0]),
        .axi_w_dbiterr(NLW_U0_axi_w_dbiterr_UNCONNECTED),
        .axi_w_injectdbiterr(1'b0),
        .axi_w_injectsbiterr(1'b0),
        .axi_w_overflow(NLW_U0_axi_w_overflow_UNCONNECTED),
        .axi_w_prog_empty(NLW_U0_axi_w_prog_empty_UNCONNECTED),
        .axi_w_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_prog_full(NLW_U0_axi_w_prog_full_UNCONNECTED),
        .axi_w_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_rd_data_count(NLW_U0_axi_w_rd_data_count_UNCONNECTED[10:0]),
        .axi_w_sbiterr(NLW_U0_axi_w_sbiterr_UNCONNECTED),
        .axi_w_underflow(NLW_U0_axi_w_underflow_UNCONNECTED),
        .axi_w_wr_data_count(NLW_U0_axi_w_wr_data_count_UNCONNECTED[10:0]),
        .axis_data_count(NLW_U0_axis_data_count_UNCONNECTED[10:0]),
        .axis_dbiterr(NLW_U0_axis_dbiterr_UNCONNECTED),
        .axis_injectdbiterr(1'b0),
        .axis_injectsbiterr(1'b0),
        .axis_overflow(NLW_U0_axis_overflow_UNCONNECTED),
        .axis_prog_empty(NLW_U0_axis_prog_empty_UNCONNECTED),
        .axis_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_prog_full(NLW_U0_axis_prog_full_UNCONNECTED),
        .axis_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_rd_data_count(NLW_U0_axis_rd_data_count_UNCONNECTED[10:0]),
        .axis_sbiterr(NLW_U0_axis_sbiterr_UNCONNECTED),
        .axis_underflow(NLW_U0_axis_underflow_UNCONNECTED),
        .axis_wr_data_count(NLW_U0_axis_wr_data_count_UNCONNECTED[10:0]),
        .backup(1'b0),
        .backup_marker(1'b0),
        .clk(1'b0),
        .data_count(NLW_U0_data_count_UNCONNECTED[10:0]),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .int_clk(1'b0),
        .m_aclk(1'b0),
        .m_aclk_en(1'b0),
        .m_axi_araddr(NLW_U0_m_axi_araddr_UNCONNECTED[31:0]),
        .m_axi_arburst(NLW_U0_m_axi_arburst_UNCONNECTED[1:0]),
        .m_axi_arcache(NLW_U0_m_axi_arcache_UNCONNECTED[3:0]),
        .m_axi_arid(NLW_U0_m_axi_arid_UNCONNECTED[0]),
        .m_axi_arlen(NLW_U0_m_axi_arlen_UNCONNECTED[7:0]),
        .m_axi_arlock(NLW_U0_m_axi_arlock_UNCONNECTED[0]),
        .m_axi_arprot(NLW_U0_m_axi_arprot_UNCONNECTED[2:0]),
        .m_axi_arqos(NLW_U0_m_axi_arqos_UNCONNECTED[3:0]),
        .m_axi_arready(1'b0),
        .m_axi_arregion(NLW_U0_m_axi_arregion_UNCONNECTED[3:0]),
        .m_axi_arsize(NLW_U0_m_axi_arsize_UNCONNECTED[2:0]),
        .m_axi_aruser(NLW_U0_m_axi_aruser_UNCONNECTED[0]),
        .m_axi_arvalid(NLW_U0_m_axi_arvalid_UNCONNECTED),
        .m_axi_awaddr(NLW_U0_m_axi_awaddr_UNCONNECTED[31:0]),
        .m_axi_awburst(NLW_U0_m_axi_awburst_UNCONNECTED[1:0]),
        .m_axi_awcache(NLW_U0_m_axi_awcache_UNCONNECTED[3:0]),
        .m_axi_awid(NLW_U0_m_axi_awid_UNCONNECTED[0]),
        .m_axi_awlen(NLW_U0_m_axi_awlen_UNCONNECTED[7:0]),
        .m_axi_awlock(NLW_U0_m_axi_awlock_UNCONNECTED[0]),
        .m_axi_awprot(NLW_U0_m_axi_awprot_UNCONNECTED[2:0]),
        .m_axi_awqos(NLW_U0_m_axi_awqos_UNCONNECTED[3:0]),
        .m_axi_awready(1'b0),
        .m_axi_awregion(NLW_U0_m_axi_awregion_UNCONNECTED[3:0]),
        .m_axi_awsize(NLW_U0_m_axi_awsize_UNCONNECTED[2:0]),
        .m_axi_awuser(NLW_U0_m_axi_awuser_UNCONNECTED[0]),
        .m_axi_awvalid(NLW_U0_m_axi_awvalid_UNCONNECTED),
        .m_axi_bid(1'b0),
        .m_axi_bready(NLW_U0_m_axi_bready_UNCONNECTED),
        .m_axi_bresp({1'b0,1'b0}),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(1'b0),
        .m_axi_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rid(1'b0),
        .m_axi_rlast(1'b0),
        .m_axi_rready(NLW_U0_m_axi_rready_UNCONNECTED),
        .m_axi_rresp({1'b0,1'b0}),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(1'b0),
        .m_axi_wdata(NLW_U0_m_axi_wdata_UNCONNECTED[63:0]),
        .m_axi_wid(NLW_U0_m_axi_wid_UNCONNECTED[0]),
        .m_axi_wlast(NLW_U0_m_axi_wlast_UNCONNECTED),
        .m_axi_wready(1'b0),
        .m_axi_wstrb(NLW_U0_m_axi_wstrb_UNCONNECTED[7:0]),
        .m_axi_wuser(NLW_U0_m_axi_wuser_UNCONNECTED[0]),
        .m_axi_wvalid(NLW_U0_m_axi_wvalid_UNCONNECTED),
        .m_axis_tdata(NLW_U0_m_axis_tdata_UNCONNECTED[7:0]),
        .m_axis_tdest(NLW_U0_m_axis_tdest_UNCONNECTED[0]),
        .m_axis_tid(NLW_U0_m_axis_tid_UNCONNECTED[0]),
        .m_axis_tkeep(NLW_U0_m_axis_tkeep_UNCONNECTED[0]),
        .m_axis_tlast(NLW_U0_m_axis_tlast_UNCONNECTED),
        .m_axis_tready(1'b0),
        .m_axis_tstrb(NLW_U0_m_axis_tstrb_UNCONNECTED[0]),
        .m_axis_tuser(NLW_U0_m_axis_tuser_UNCONNECTED[3:0]),
        .m_axis_tvalid(NLW_U0_m_axis_tvalid_UNCONNECTED),
        .overflow(NLW_U0_overflow_UNCONNECTED),
        .prog_empty(NLW_U0_prog_empty_UNCONNECTED),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(rd_clk),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[10:0]),
        .rd_en(rd_en),
        .rd_rst(1'b0),
        .rd_rst_busy(rd_rst_busy),
        .rst(1'b0),
        .s_aclk(1'b0),
        .s_aclk_en(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arid(1'b0),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlock(1'b0),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_aruser(1'b0),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awid(1'b0),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlock(1'b0),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awuser(1'b0),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_buser(NLW_U0_s_axi_buser_UNCONNECTED[0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_ruser(NLW_U0_s_axi_ruser_UNCONNECTED[0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wid(1'b0),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wuser(1'b0),
        .s_axi_wvalid(1'b0),
        .s_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tdest(1'b0),
        .s_axis_tid(1'b0),
        .s_axis_tkeep(1'b0),
        .s_axis_tlast(1'b0),
        .s_axis_tready(NLW_U0_s_axis_tready_UNCONNECTED),
        .s_axis_tstrb(1'b0),
        .s_axis_tuser({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .sleep(1'b0),
        .srst(srst),
        .underflow(NLW_U0_underflow_UNCONNECTED),
        .valid(NLW_U0_valid_UNCONNECTED),
        .wr_ack(NLW_U0_wr_ack_UNCONNECTED),
        .wr_clk(wr_clk),
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[10:0]),
        .wr_en(wr_en),
        .wr_rst(1'b0),
        .wr_rst_busy(wr_rst_busy));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2024.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
md0AksSCeI3fOZtF7nrw91OgSzGoACBon4GH9ENTzaI4jlg22H1uTtXayX2Kz+g4ZH2j52rtMH8H
Xc49HVcThMzO1cRXu+SkL59MRQ87klGca4XtjrTtunJoQ+jyOKRwRBeIMHUdntbk2T1kbXHf9KkB
bNYGEMqSrbiDt7IJUx8=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
r6CzxR0T3O2wvZRQe25aX3/CWOx/3d/3vJvvS/XsrKr7v852GNQNqCBn+PKsunj0Ncep8DqHtVie
BE6tKIqZW+3txAUjrhSri5liuFWSnzAk+Drsb4RnvIy7BeOdAK6NhVhn8ZyplkJSHVwaGjN8gtPE
LeWEHPHf5qLnzqGKV7B6oIC7POGV6Vamos1p2z1xv2cEw4udvmtZ5EjzeyCMf+omtxEPxhPi6Z2h
ENlGOmuPMkWGMjP6HQCZ1Mi0uiST/zDo29UDIMmOGcsDMe97imU/z2ekKTPXXwjcV+9q+4zHRgJV
6JWWgjU9cztV5OMaEfpBgRBWae/ijWpPZaGuFA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
glFrHilvyO7nq7/OYhnyb9uU9d8UNGJruNnkmJWuTpgvyCDmtx7iVKPBPe1Bj9jUDT/HM9AGxvu0
g7b4TuMdVkegkVPeHhw31IW0HoTL8wPnrLEpzDVK+B7xl953hPKPe0vn+0EQh2UKeL5K8VLxmsSv
gbpEeToeR90yzlSUzDE=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
D4uBhES8Mkd0GCwY2aQOmEzTqz6hO5B9Wa2oyfVBEODkWyt+AHkIXn4tuBN05FcP2FVmgtVbvZX5
K6iog51IoPw5tv+pM5x8+bQBX/aZpf0c4to3qiX6RZuITpuSUWq/7sqQDqtMqDWOFMMnUBpTX+qI
t61NvyIZcfqRWo4yvIUV2Zh1etqYKDlhqRnMoBZKMeHFpVsp19nU4sf5Km7sSlPQ08vYD8qtJqgJ
ZDYC2KWFTHsnT+5anHvc80FgHt4zBHpPrGprgpltQmVmMZxUD6NRC9EvvXf+pBhgfwPHHePWIKUn
elLld/HEVeFw76SlVV8i4LsS4KWWOM+KmMprEg==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
EW9gHDqS12MVhy+y/xQVscLd4qOim+cNTepYzlas7WzqDJogZthddOuGjpm3a3fS/cMbF/h0O1Hb
Wjow664GIga0y96lkbkcJ3W8x/IGAsvgyrYT6ScsFhyq7tSd1HjvRG81BhhGM1mmpxfzh0Uqbfso
q+uVKPUmPnbQ/Gdu9YRoxmYVJdmUTpXJ5waYOdib8WNMPLdDfIo/FGrYrx2zYQBtpU5DwwVUTMrB
ZasEyxOj++icI5k5lR3Tx+3gdCFTy4XYQfcj2COm4gnVZ8FN/X1/+0ywsVGAc/OKL+mjMYH3NNH3
zfDO/TpYft+HaVl+CfF/U6IgJJeJs4qI4gB4FA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2023_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Myfv5Skg7QCxlNBoFiSTLAeIRYS0J0ArRihYk7dGAHZWAFlxJLgqo51W9P9zTVBurMJjZLtonoDJ
19RfxQj5GqhqN1A20s8xOFfLq6+uDG/V39xQFY32O626Kh4MMlH07hNJL5u1NjJWg1yze0XdFEe9
oLwKQz5lSKGMIh+VPXDuCGhShS+KhHwGEdS0lmA/IHPFNlRG1LsK0zQmUiNkG4kQ5OEVkQgvknNC
B6++ZDIYlT9WbZPs5giRY0zAhUepLPaO+N9F3fIBKVGw4ejbZOt0kXKixF86DDfLmF2+dov+PrTX
1MXJaea3YoQdR2c2MSHAk/TTkzg9ayjvxKaXpg==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ks9l+EPHXfDNnWd0exs1j0Q9iSNYaIExwQnpsi8TFJimjPtOkX050wFklsLBM83WyfuD+F2KLNnZ
Jg/aiIiGe9o424jOiEFdnAJuzrD0QL9WmhQ3W9iRJ7uPhha6NfR2WGTCCM4TpN8rTKLQDKxenVfv
6x83rnL5NQxvpp9cQh3zMma73qoEJjhTR9MD9cwA4VeKq2u/R0iTWBplX81vYFd9TW2qW5/Qyzzj
A0+pXzczcJKdggV8h8bYcO+PRC3t2XrufhnjvhjMLG2tPHSMW/soDH/v8KorXyWe5N/q12fo5auN
SXr3olNuB5kpiVS3mJAPV0z4UsFfu2A4hLH7MQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
e3AJKDEM9byJqwpkFZqMIMKMQPOR1VrLFkshor7HR0C+ol7Uv3XTGyvQrINdBEArX0eazF0cHWjC
9B4BhDnysAhT6SENcNHIYHUGQE7uiF7zgL7WhCxClwEnIAVj+PU9FmqlvbreEikHQfbeIDPyCLii
NAS97RDxWki/MfR33zvZX4eEolA/oTyRzr1MagBs7LN1UXyGPvnze8JzHxA3zHVedIIrBrZxkfoj
Loqe6tLYRlC45h1Yr3Wa2gh3LJGtOSji+m7E9Xua/pPh8A/CAD+TNBa5d/X7C3a4AWl2bYTi7HBY
Y8vaIjHiSosru5F2UOEQG9xekCbNRK1Apew1UIvntzCmDMMhlAgB78AUOE2YEWKd9GOl+aTZjMS3
GxAYzrtv/bDRkPOYbcG0SNT9xf+izRM3lX1E2vN3i3uU2Qrh73fjU1lk3PIe/A/H56UrNPDnGT9W
TvlJR47bLDtGyX2+dLvfTaZGRP8aepePOXXLIlvqwCJSMVhCB/hIbz7E

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
TfuXOFQtE7YhtTL4354NvKETmBCLSVnb+pbrT8gtzjU7pERE1Hu2ZVzHgVQXwt5RvwG1R/z2je+U
PzszCBhPNqUaXEhuJ0A/q0S/vvOOa6h6tW9MhiB3gnuqEFVWz5pbHZNfgrwh2gT8XyqLI8f1CoJM
xpcB2TbREV/kAAFMxIfH1Dg0KSO2dCeVV1na6N0AiMOQPvXZOB7QpXwNDbYfarWLtF0/l0hi4Fxu
Kgho2ggrUhajP0aKlrCQ9mLsqOyqJELeJldeD+vuUUqhYq4K4RrwtQF+B67lYc4AjznwQ92tUvYJ
ZspFoHJEScNvdFoHFTA2TQ2KToepsqXRiOCL1A==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
tmfbBpNtCYJ7zsgNxUzw7Dvn+hNn2PPUBeRfXSci/q2/OcQeF/eAAML8YIN1V+AEoAqZTE2/xRQz
+6zwVOLyAOLynMIBQ7EG7xReDJ9kEEiBjnMGO6NWdAsa/VcreVHrLD1PFtA1+WoVe6yOvNGK+Nbh
HjPkXyycyP6RQ4Rx/PtTxw31LOFVezddSgRlaKHTprKTP4LbjPG//onRBg3fAl8zwU1wYYNLzYCX
jwY7xfMkQyhUSpV2Tx3seqy2IYVl8jjxynFxfyxulvrJiqmc6aaKKBdkoOVbJ5eO2sCXFJB1mKEU
WR2Ee2ozisABzk9IcGILewCW7ghdLP82CRZv4A==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
GfDCxx9db4ripD5mvQy16BVlwPYfeC7ZobZXaX1my6WUDiKwd69J5SreUXKYD9lvZfI7djLgHkYm
5G247T4NX7zoBwc88bUD+tNvGNmzWFfSVVZqu8hjgd31lZXjy9uYdXA/gsE+T+JqEfRYdV8YoGgm
sREyiJjWRPDbx6kc8um8vlAK/Rjwz0EGVkGUoi/+UvxcnjG1PqCl7GSMOQ3gFMEOaxIflShnF2/c
//ioADxl3WjUGyTstMK54XlP8G1Hk95sSe/7Y+SbaIyoG8t6gGDimDJNuGs4JjDUi1V7Gxfzxk9+
O2J++9clyLkMZ3rRyxSvR+Xyrmn3YxjVC68GXw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 51424)
`pragma protect data_block
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
QQeYjYXbF3uX6Q==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
