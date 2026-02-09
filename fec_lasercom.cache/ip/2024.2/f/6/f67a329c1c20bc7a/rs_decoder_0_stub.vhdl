-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
-- Date        : Tue Jan 27 16:00:05 2026
-- Host        : FSO-A running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ rs_decoder_0_stub.vhdl
-- Design      : rs_decoder_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu15eg-ffvb1156-2-i
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  Port ( 
    aclk : in STD_LOGIC;
    s_axis_input_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axis_input_tvalid : in STD_LOGIC;
    s_axis_input_tlast : in STD_LOGIC;
    s_axis_input_tready : out STD_LOGIC;
    m_axis_output_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_output_tvalid : out STD_LOGIC;
    m_axis_output_tready : in STD_LOGIC;
    m_axis_output_tlast : out STD_LOGIC;
    m_axis_stat_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_stat_tvalid : out STD_LOGIC;
    m_axis_stat_tready : in STD_LOGIC;
    event_s_input_tlast_missing : out STD_LOGIC;
    event_s_input_tlast_unexpected : out STD_LOGIC;
    event_s_ctrl_tdata_invalid : out STD_LOGIC
  );

  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "rs_decoder_0,rs_decoder_v9_0_23,{}";
  attribute PARTIALLYOBFUSCATED : boolean;
  attribute PARTIALLYOBFUSCATED of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is std.standard.true;
  attribute core_generation_info : string;
  attribute core_generation_info of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "rs_decoder_0,rs_decoder_v9_0_23,{x_ipProduct=Vivado 2024.2,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=rs_decoder,x_ipVersion=9.0,x_ipCoreRevision=23,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_HAS_ACLKEN=0,C_HAS_ARESETN=0,C_HAS_S_AXIS_CTRL=0,C_HAS_S_AXIS_INPUT_TUSER=0,C_HAS_M_AXIS_OUTPUT_TUSER=0,C_S_AXIS_INPUT_TDATA_WIDTH=16,C_S_AXIS_INPUT_TUSER_WIDTH=1,C_S_AXIS_CTRL_TDATA_WIDTH=8,C_M_AXIS_OUTPUT_TDATA_WIDTH=8,C_M_AXIS_OUTPUT_TUSER_WIDTH=1,C_M_AXIS_STAT_TDATA_WIDTH=16,C_HAS_DATA_DEL=0,C_HAS_ERASE=1,C_HAS_ERR_STATS=0,C_HAS_INFO=0,C_HAS_N_IN=0,C_HAS_R_IN=0,C_GEN_START=0,C_H=1,C_K=229,C_N=255,C_POLYNOMIAL=0,C_SPEC=0,C_SYMBOL_WIDTH=8,C_IGNORE_ILLEGAL_N_R=1,C_DEFINE_LEGAL_R_VALS=0,C_NUM_LEGAL_R_VALUES=2,C_LEGAL_R_VECTOR_FILE=no_coe_file_loaded,C_NUM_CHANNELS=1,C_NUM_PUNC_PATTERNS=0,C_PUNCTURE_SELECT_FILE=no_coe_file_loaded,C_PUNCTURE_VECTOR_FILE=no_coe_file_loaded,C_MEMSTYLE=2,C_OUTPUT_CHECK_SYMBOLS=0,C_OPTIMISATION=1,C_SELF_RECOVERING=0,C_MEM_INIT_PREFIX=rs_decoder_0,C_ELABORATION_DIR=./,C_XDEVICEFAMILY=zynquplus,C_FAMILY=zynquplus,x_ipLicense=rs_decoder@2013.03(bought)}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "yes";
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  attribute syn_black_box : boolean;
  attribute black_box_pad_pin : string;
  attribute syn_black_box of stub : architecture is true;
  attribute black_box_pad_pin of stub : architecture is "aclk,s_axis_input_tdata[15:0],s_axis_input_tvalid,s_axis_input_tlast,s_axis_input_tready,m_axis_output_tdata[7:0],m_axis_output_tvalid,m_axis_output_tready,m_axis_output_tlast,m_axis_stat_tdata[15:0],m_axis_stat_tvalid,m_axis_stat_tready,event_s_input_tlast_missing,event_s_input_tlast_unexpected,event_s_ctrl_tdata_invalid";
  attribute x_interface_info : string;
  attribute x_interface_info of aclk : signal is "xilinx.com:signal:clock:1.0 aclk_intf CLK";
  attribute x_interface_mode : string;
  attribute x_interface_mode of aclk : signal is "slave aclk_intf";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of aclk : signal is "XIL_INTERFACENAME aclk_intf, ASSOCIATED_BUSIF M_AXIS_STAT:M_AXIS_OUTPUT:S_AXIS_CTRL:S_AXIS_INPUT, ASSOCIATED_RESET aresetn, ASSOCIATED_CLKEN aclken, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0";
  attribute x_interface_info of s_axis_input_tdata : signal is "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TDATA";
  attribute x_interface_mode of s_axis_input_tdata : signal is "slave S_AXIS_INPUT";
  attribute x_interface_parameter of s_axis_input_tdata : signal is "XIL_INTERFACENAME S_AXIS_INPUT, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute x_interface_info of s_axis_input_tvalid : signal is "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TVALID";
  attribute x_interface_info of s_axis_input_tlast : signal is "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TLAST";
  attribute x_interface_info of s_axis_input_tready : signal is "xilinx.com:interface:axis:1.0 S_AXIS_INPUT TREADY";
  attribute x_interface_info of m_axis_output_tdata : signal is "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TDATA";
  attribute x_interface_mode of m_axis_output_tdata : signal is "master M_AXIS_OUTPUT";
  attribute x_interface_parameter of m_axis_output_tdata : signal is "XIL_INTERFACENAME M_AXIS_OUTPUT, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute x_interface_info of m_axis_output_tvalid : signal is "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TVALID";
  attribute x_interface_info of m_axis_output_tready : signal is "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TREADY";
  attribute x_interface_info of m_axis_output_tlast : signal is "xilinx.com:interface:axis:1.0 M_AXIS_OUTPUT TLAST";
  attribute x_interface_info of m_axis_stat_tdata : signal is "xilinx.com:interface:axis:1.0 M_AXIS_STAT TDATA";
  attribute x_interface_mode of m_axis_stat_tdata : signal is "master M_AXIS_STAT";
  attribute x_interface_parameter of m_axis_stat_tdata : signal is "XIL_INTERFACENAME M_AXIS_STAT, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute x_interface_info of m_axis_stat_tvalid : signal is "xilinx.com:interface:axis:1.0 M_AXIS_STAT TVALID";
  attribute x_interface_info of m_axis_stat_tready : signal is "xilinx.com:interface:axis:1.0 M_AXIS_STAT TREADY";
  attribute x_interface_info of event_s_input_tlast_missing : signal is "xilinx.com:signal:interrupt:1.0 event_s_input_tlast_missing_intf INTERRUPT";
  attribute x_interface_mode of event_s_input_tlast_missing : signal is "master event_s_input_tlast_missing_intf";
  attribute x_interface_parameter of event_s_input_tlast_missing : signal is "XIL_INTERFACENAME event_s_input_tlast_missing_intf, SENSITIVITY EDGE_RISING, PortWidth 1";
  attribute x_interface_info of event_s_input_tlast_unexpected : signal is "xilinx.com:signal:interrupt:1.0 event_s_input_tlast_unexpected_intf INTERRUPT";
  attribute x_interface_mode of event_s_input_tlast_unexpected : signal is "master event_s_input_tlast_unexpected_intf";
  attribute x_interface_parameter of event_s_input_tlast_unexpected : signal is "XIL_INTERFACENAME event_s_input_tlast_unexpected_intf, SENSITIVITY EDGE_RISING, PortWidth 1";
  attribute x_interface_info of event_s_ctrl_tdata_invalid : signal is "xilinx.com:signal:interrupt:1.0 event_s_ctrl_tdata_invalid_intf INTERRUPT";
  attribute x_interface_mode of event_s_ctrl_tdata_invalid : signal is "master event_s_ctrl_tdata_invalid_intf";
  attribute x_interface_parameter of event_s_ctrl_tdata_invalid : signal is "XIL_INTERFACENAME event_s_ctrl_tdata_invalid_intf, SENSITIVITY EDGE_RISING, PortWidth 1";
  attribute x_core_info : string;
  attribute x_core_info of stub : architecture is "rs_decoder_v9_0_23,Vivado 2024.2";
begin
end;
