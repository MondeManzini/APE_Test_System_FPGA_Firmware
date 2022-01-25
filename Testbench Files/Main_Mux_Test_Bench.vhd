-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- This file contains  modules which make up a testbench
-- suitable for testing the "device under test".
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

--library modelsim_lib;
--use modelsim_lib.util.all;

entity Main_Mux_Test_Bench is

end Main_Mux_Test_Bench;

architecture Archtest_bench of Main_Mux_Test_Bench is
	

  component test_bench_T
    generic (
      Vec_Width  : positive := 4;
      ClkPer     : time     := 20 ns;
      StimuFile  : string   := "data.txt";
      ResultFile : string   := "results.txt"
      );
    port (
      oVec : out std_logic_vector(Vec_Width-1 downto 0);
      oClk : out std_logic;
      iVec : in std_logic_vector(3 downto 0)
      );
  end component;

  -- Timestamp from Tcl Script
signal Version_Timestamp_i      : STD_LOGIC_VECTOR(111 downto 0);       -- 20181120105439

-- Tope Level Firmware Module Name
constant RF_Controller_name_i   : STD_LOGIC_VECTOR(23 downto 0) := x"524643";  -- RFC

-- Version Major Number - Hardcoded
constant Version_Major_High_i   : STD_LOGIC_VECTOR(7 downto 0) := x"30";  -- 0x
constant Version_Major_Low_i    : STD_LOGIC_VECTOR(7 downto 0) := x"33";  -- x3

constant Dot_i                  : STD_LOGIC_VECTOR(7 downto 0) := x"2e";  -- .
-- Version Minor Number - Hardcoded
constant Version_Minor_High_i   : STD_LOGIC_VECTOR(7 downto 0) := x"30";  -- 0x
constant Version_Minor_Low_i    : STD_LOGIC_VECTOR(7 downto 0) := x"30";  -- x0
-- Null Termination
constant Null_i                 : STD_LOGIC_VECTOR(7 downto 0) := x"00";  -- termination

-- Version Signals and Component
component Version_Reg is
    generic(
        log_file   : string   --:= "Firmware Version Log File.txt"
    );
    port (
        CLK_I              : in  std_logic;
        RST_I              : in  std_logic;
        Version_Timestamp  : out STD_LOGIC_VECTOR(111 downto 0)
    );
end component Version_Reg;

  -- Mux Signals and Component
  signal RFC_to_Pieter_UART_TXD_i : std_logic;
  signal UART_TXD_i             : std_logic;
  signal Message_ID1_i            : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B0_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B1_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B2_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B3_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B4_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B5_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B6_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B7_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B0_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B1_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B2_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B3_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B4_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B5_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B6_i         : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B7_i         : std_logic_vector(7 downto 0);
  signal SPI_Inport_1_i        : std_logic_vector(7 downto 0);
  signal SPI_Inport_2_i        : std_logic_vector(7 downto 0);
  signal SPI_Inport_3_i        : std_logic_vector(7 downto 0);
  signal SPI_Inport_4_i        : std_logic_vector(7 downto 0);
  signal SPI_Inport_5_i        : std_logic_vector(7 downto 0);
  signal SPI_Inport_6_i        : std_logic_vector(7 downto 0);
  signal SPI_Inport_7_i        : std_logic_vector(7 downto 0);
  signal SPI_Inport_8_i        : std_logic_vector(7 downto 0);
  signal CH1_o_i        : std_logic_vector(15 downto 0);
  signal CH2_o_i        : std_logic_vector(15 downto 0);
  signal CH3_o_i        : std_logic_vector(15 downto 0);
  signal CH4_o_i        : std_logic_vector(15 downto 0);
  signal CH5_o_i        : std_logic_vector(15 downto 0);
  signal CH6_o_i        : std_logic_vector(15 downto 0);
  signal CH7_o_i        : std_logic_vector(15 downto 0);
  signal CH8_o_i        : std_logic_vector(15 downto 0);
  signal CH9_o_i        : std_logic_vector(15 downto 0);
  signal CH10_o_i       : std_logic_vector(15 downto 0);
  signal CH11_o_i       : std_logic_vector(15 downto 0);
  signal CH12_o_i       : std_logic_vector(15 downto 0);
  signal CH13_o_i       : std_logic_vector(15 downto 0);
  signal CH14_o_i       : std_logic_vector(15 downto 0);
  signal CH15_o_i       : std_logic_vector(15 downto 0);
  signal CH16_o_i       : std_logic_vector(15 downto 0);
  signal CH17_o_i       : std_logic_vector(15 downto 0);
  signal CH18_o_i       : std_logic_vector(15 downto 0);
  signal CH19_o_i       : std_logic_vector(15 downto 0);
  signal CH20_o_i       : std_logic_vector(15 downto 0);
  signal CH21_o_i       : std_logic_vector(15 downto 0);
  signal CH22_o_i       : std_logic_vector(15 downto 0);
  signal CH23_o_i       : std_logic_vector(15 downto 0);
  signal CH24_o_i       : std_logic_vector(15 downto 0);
  signal CH25_o_i       : std_logic_vector(15 downto 0);
  signal CH26_o_i       : std_logic_vector(15 downto 0);
  signal CH27_o_i       : std_logic_vector(15 downto 0);
  signal CH28_o_i       : std_logic_vector(15 downto 0);
  signal CH29_o_i       : std_logic_vector(15 downto 0);
  signal CH30_o_i       : std_logic_vector(15 downto 0);
  signal CH31_o_i       : std_logic_vector(15 downto 0);
  signal CH32_o_i       : std_logic_vector(15 downto 0);
  signal CH33_o_i       : std_logic_vector(15 downto 0);
  signal CH34_o_i       : std_logic_vector(15 downto 0);
  signal CH35_o_i       : std_logic_vector(15 downto 0);
  signal CH36_o_i       : std_logic_vector(15 downto 0);
  signal CH37_o_i       : std_logic_vector(15 downto 0);
  signal CH38_o_i       : std_logic_vector(15 downto 0);
  signal CH39_o_i       : std_logic_vector(15 downto 0);
  signal CH40_o_i       : std_logic_vector(15 downto 0);
  signal CH41_o_i       : std_logic_vector(15 downto 0);
  signal CH42_o_i       : std_logic_vector(15 downto 0);
  signal CH43_o_i       : std_logic_vector(15 downto 0);
  signal CH44_o_i       : std_logic_vector(15 downto 0);
  signal CH45_o_i       : std_logic_vector(15 downto 0);
  signal CH46_o_i       : std_logic_vector(15 downto 0);
  signal CH47_o_i       : std_logic_vector(15 downto 0);
  signal CH48_o_i       : std_logic_vector(15 downto 0);
  signal CH1_2_o_i      : std_logic_vector(15 downto 0);
  signal CH2_2_o_i      : std_logic_vector(15 downto 0);
  signal CH3_2_o_i      : std_logic_vector(15 downto 0);
  signal CH4_2_o_i      : std_logic_vector(15 downto 0);
  signal CH5_2_o_i      : std_logic_vector(15 downto 0);
  signal CH6_2_o_i      : std_logic_vector(15 downto 0);
  signal CH7_2_o_i      : std_logic_vector(15 downto 0);
  signal CH8_2_o_i      : std_logic_vector(15 downto 0);
  signal CH9_2_o_i      : std_logic_vector(15 downto 0);
  signal CH10_2_o_i     : std_logic_vector(15 downto 0);
  signal CH11_2_o_i     : std_logic_vector(15 downto 0);
  signal CH12_2_o_i     : std_logic_vector(15 downto 0);
  signal CH13_2_o_i     : std_logic_vector(15 downto 0);
  signal CH14_2_o_i     : std_logic_vector(15 downto 0);
  signal CH15_2_o_i     : std_logic_vector(15 downto 0);
  signal CH16_2_o_i     : std_logic_vector(15 downto 0);
  signal CH17_2_o_i     : std_logic_vector(15 downto 0);
  signal CH18_2_o_i     : std_logic_vector(15 downto 0);
  signal CH19_2_o_i     : std_logic_vector(15 downto 0);
  signal CH20_2_o_i     : std_logic_vector(15 downto 0);
  signal CH21_2_o_i     : std_logic_vector(15 downto 0);
  signal CH22_2_o_i     : std_logic_vector(15 downto 0);
  signal CH23_2_o_i     : std_logic_vector(15 downto 0);
  signal CH24_2_o_i     : std_logic_vector(15 downto 0);
  signal CH25_2_o_i     : std_logic_vector(15 downto 0);
  signal CH26_2_o_i     : std_logic_vector(15 downto 0);
  signal CH27_2_o_i     : std_logic_vector(15 downto 0);
  signal CH28_2_o_i     : std_logic_vector(15 downto 0);
  signal CH29_2_o_i     : std_logic_vector(15 downto 0);
  signal CH30_2_o_i     : std_logic_vector(15 downto 0);
  signal CH31_2_o_i     : std_logic_vector(15 downto 0);
  signal CH32_2_o_i     : std_logic_vector(15 downto 0);
  signal CH33_2_o_i     : std_logic_vector(15 downto 0);
  signal CH34_2_o_i     : std_logic_vector(15 downto 0);
  signal CH35_2_o_i     : std_logic_vector(15 downto 0);
  signal CH36_2_o_i     : std_logic_vector(15 downto 0);
  signal CH37_2_o_i     : std_logic_vector(15 downto 0);
  signal CH38_2_o_i     : std_logic_vector(15 downto 0);
  signal CH39_2_o_i     : std_logic_vector(15 downto 0);
  signal CH40_2_o_i     : std_logic_vector(15 downto 0);
  signal CH41_2_o_i     : std_logic_vector(15 downto 0);
  signal CH42_2_o_i     : std_logic_vector(15 downto 0);
  signal CH43_2_o_i     : std_logic_vector(15 downto 0);
  signal CH44_2_o_i     : std_logic_vector(15 downto 0);
  signal CH45_2_o_i     : std_logic_vector(15 downto 0);
  signal CH46_2_o_i     : std_logic_vector(15 downto 0);
  signal CH47_2_o_i     : std_logic_vector(15 downto 0);
  signal CH48_2_o_i     : std_logic_vector(15 downto 0);
  signal Analog_Input_Valid_i     : std_logic;
  signal Tx_Rate_i                : integer range 0 to 255;
  signal Mux_Baud_Rate_Enable_i   : std_logic;
  signal SYCN_Pulse_i             : std_logic;
  signal Watchdog_Status_in_i     : std_logic_vector(15 downto 0);
  signal Version_Data_Ready_i     : std_logic;
  signal Message_Length_i       : std_logic_vector(7 downto 0);
  signal Timer_Sec_Reg_1_i      : std_logic_vector(31 downto 0);
  signal Timer_mSec_Reg_1_i     : std_logic_vector(15 downto 0);
  signal Dig_Out_1_B0_i         : std_logic_vector(7 downto 0);
  signal Dig_Out_1_B1_i         : std_logic_vector(7 downto 0);
  signal Dig_Out_1_B2_i         : std_logic_vector(7 downto 0);
  signal Dig_Out_1_B3_i         : std_logic_vector(7 downto 0);
  signal Dig_Out_1_B4_i         : std_logic_vector(7 downto 0);
  signal Dig_Out_1_B5_i         : std_logic_vector(7 downto 0);
  signal Dig_Out_1_B6_i         : std_logic_vector(7 downto 0);
  signal Dig_Out_1_B7_i         : std_logic_vector(7 downto 0);
  signal Digital_Input_Valid_i  : std_logic;
  signal Dig_In_1_B0_i          : std_logic_vector(7 downto 0);
  signal Dig_In_1_B1_i          : std_logic_vector(7 downto 0);
  signal Dig_In_1_B2_i          : std_logic_vector(7 downto 0);
  signal Dig_In_1_B3_i          : std_logic_vector(7 downto 0);
  signal Dig_In_1_B4_i          : std_logic_vector(7 downto 0);
  signal Dig_In_1_B5_i          : std_logic_vector(7 downto 0);
  signal Dig_In_1_B6_i          : std_logic_vector(7 downto 0);
  signal Dig_In_1_B7_i          : std_logic_vector(7 downto 0);
  signal Digital_Output_Valid_i : std_logic;
  signal Channel1_i             : std_logic_vector(775 downto 0);
  signal Channel2_i             : std_logic_vector(775 downto 0);
  signal Analog_Input_Valid_1_i : std_logic;
  signal Analog_Input_Valid_2_i : std_logic;
  signal Input_Source_i         : std_logic_vector(7 downto 0);
  signal Freq_Source_i          : std_logic_vector(7 downto 0);
  signal Noise_Diode_Valid_i    : std_logic;
  signal Valon_Data_i           : std_logic_vector(223 downto 0);
  signal Header_1_i             : std_logic_vector(7 downto 0);
  signal Header_2_i             : std_logic_vector(7 downto 0);
  signal Header_3_i             : std_logic_vector(7 downto 0);
  signal Mode_i                 : std_logic_vector(7 downto 0);
  signal Valon_Data_Ready_i     : std_logic;
  signal Baud_Rate_Enable_i     : std_logic;
  signal Valon_Message_length_i : std_logic_vector(7 downto 0);
  signal RX_Message_Length_i    : std_logic_vector(7 downto 0);
  signal RX_UART_RXD_i          : std_logic;
  signal RX_Demux_Data_Ready_i  : std_logic;
  signal RX_Valon_Data_Ready_i  : std_logic;
  signal RX_Valon_Data_i        : std_logic_vector(223 downto 0);
  signal RX_Header_1_i          : std_logic_vector(7 downto 0);
  signal RX_Header_2_i          : std_logic_vector(7 downto 0);
  signal RX_Header_3_i          : std_logic_vector(7 downto 0);     
  signal RX_Mode_i              : std_logic_vector(7 downto 0);
  signal Watchdog_Reset_i       : std_logic;
  signal Mux_watchdog_i         : std_logic;
  signal Ana_In_Request_i       : std_logic;
  signal Dig_In_Request_i       : std_logic;
  signal Dig_Out_Request_i      : std_logic;
  signal Analog_Busy_i          : std_logic;
  signal Version_i              : std_logic_vector(7 downto 0);
  signal Version_Register_i     : STD_LOGIC_VECTOR(199 downto 0);
  signal Noise_Diode_Out_i      : std_logic_vector(7 downto 0);
  signal Freq_Source_Out_i      : std_logic_vector(7 downto 0);
  signal Data_Ready_i           : std_logic;

  component Main_Mux is
      port (
          Clk                   : in  std_logic;
          RST_I                 : in  std_logic;
          UART_TXD              : out std_logic;
          Message_Length        : in  std_logic_vector(7 downto 0);
          Time_Stamp_Byte_3     : in  std_logic_vector(7 downto 0);
          Time_Stamp_Byte_2     : in  std_logic_vector(7 downto 0);
          Time_Stamp_Byte_1     : in  std_logic_vector(7 downto 0);
          Time_Stamp_Byte_0     : in  std_logic_vector(7 downto 0);
          Dig_MilliSecond_B1    : in  std_logic_vector(7 downto 0);
          Dig_MilliSecond_B0    : in  std_logic_vector(7 downto 0);
          Dig_Card1_1_B0        : in  std_logic_vector(7 downto 0);
          Dig_Card1_1_B1        : in  std_logic_vector(7 downto 0);
          Dig_Card1_1_B2        : in  std_logic_vector(7 downto 0);
          Dig_Card1_1_B3        : in  std_logic_vector(7 downto 0);
          Dig_Card1_1_B4        : in  std_logic_vector(7 downto 0);
          Dig_Card1_1_B5        : in  std_logic_vector(7 downto 0);
          Dig_Card1_1_B6        : in  std_logic_vector(7 downto 0);
          Dig_Card1_1_B7        : in  std_logic_vector(7 downto 0);
          Digital_Input_Valid   : in  std_logic;
          Dig_Card1_2_B0        : in  std_logic_vector(7 downto 0);
          Dig_Card1_2_B1        : in  std_logic_vector(7 downto 0);
          Dig_Card1_2_B2        : in  std_logic_vector(7 downto 0);
          Dig_Card1_2_B3        : in  std_logic_vector(7 downto 0);
          Dig_Card1_2_B4        : in  std_logic_vector(7 downto 0);
          Dig_Card1_2_B5        : in  std_logic_vector(7 downto 0);
          Dig_Card1_2_B6        : in  std_logic_vector(7 downto 0);
          Dig_Card1_2_B7        : in  std_logic_vector(7 downto 0);
          Digital_Output_Valid  : in  std_logic;
          Alg_Card1_1          : in  std_logic_vector(15 downto 0);        
          Alg_Card1_2          : in  std_logic_vector(15 downto 0);                
          Alg_Card1_3          : in  std_logic_vector(15 downto 0);
          Alg_Card1_4          : in  std_logic_vector(15 downto 0);        
          Alg_Card1_5          : in  std_logic_vector(15 downto 0);
          Alg_Card1_6          : in  std_logic_vector(15 downto 0);
          Alg_Card1_7          : in  std_logic_vector(15 downto 0);
          Alg_Card1_8          : in  std_logic_vector(15 downto 0);
          Alg_Card1_9          : in  std_logic_vector(15 downto 0);
          Alg_Card1_10         : in  std_logic_vector(15 downto 0);        
          Alg_Card1_11         : in  std_logic_vector(15 downto 0);
          Alg_Card1_12         : in  std_logic_vector(15 downto 0);
          Alg_Card1_13         : in  std_logic_vector(15 downto 0);
          Alg_Card1_14         : in  std_logic_vector(15 downto 0);
          Alg_Card1_15         : in  std_logic_vector(15 downto 0);
          Alg_Card1_16         : in  std_logic_vector(15 downto 0);        
          Alg_Card1_17         : in  std_logic_vector(15 downto 0);
          Alg_Card1_18         : in  std_logic_vector(15 downto 0);
          Alg_Card1_19         : in  std_logic_vector(15 downto 0);
          Alg_Card1_20         : in  std_logic_vector(15 downto 0);
          Alg_Card1_21         : in  std_logic_vector(15 downto 0);
          Alg_Card1_22         : in  std_logic_vector(15 downto 0);        
          Alg_Card1_23         : in  std_logic_vector(15 downto 0);
          Alg_Card1_24         : in  std_logic_vector(15 downto 0);
          Alg_Card1_25         : in  std_logic_vector(15 downto 0);
          Alg_Card1_26         : in  std_logic_vector(15 downto 0);
          Alg_Card1_27         : in  std_logic_vector(15 downto 0);
          Alg_Card1_28         : in  std_logic_vector(15 downto 0);        
          Alg_Card1_29         : in  std_logic_vector(15 downto 0);
          Alg_Card1_30         : in  std_logic_vector(15 downto 0);
          Alg_Card1_31         : in  std_logic_vector(15 downto 0);
          Alg_Card1_32         : in  std_logic_vector(15 downto 0);
          Alg_Card1_33         : in  std_logic_vector(15 downto 0);
          Alg_Card1_34         : in  std_logic_vector(15 downto 0);        
          Alg_Card1_35         : in  std_logic_vector(15 downto 0);
          Alg_Card1_36         : in  std_logic_vector(15 downto 0);
          Alg_Card1_37         : in  std_logic_vector(15 downto 0);
          Alg_Card1_38         : in  std_logic_vector(15 downto 0);
          Alg_Card1_39         : in  std_logic_vector(15 downto 0);
          Alg_Card1_40         : in  std_logic_vector(15 downto 0);        
          Alg_Card1_41         : in  std_logic_vector(15 downto 0);
          Alg_Card1_42         : in  std_logic_vector(15 downto 0);
          Alg_Card1_43         : in  std_logic_vector(15 downto 0);
          Alg_Card1_44         : in  std_logic_vector(15 downto 0);
          Alg_Card1_45         : in  std_logic_vector(15 downto 0);
          Alg_Card1_46         : in  std_logic_vector(15 downto 0);        
          Alg_Card1_47         : in  std_logic_vector(15 downto 0);
          Alg_Card1_48         : in  std_logic_vector(15 downto 0);
          Alg_Card2_1          : in  std_logic_vector(15 downto 0);        
          Alg_Card2_2          : in  std_logic_vector(15 downto 0);                
          Alg_Card2_3          : in  std_logic_vector(15 downto 0);
          Alg_Card2_4          : in  std_logic_vector(15 downto 0);        
          Alg_Card2_5          : in  std_logic_vector(15 downto 0);
          Alg_Card2_6          : in  std_logic_vector(15 downto 0);
          Alg_Card2_7          : in  std_logic_vector(15 downto 0);
          Alg_Card2_8          : in  std_logic_vector(15 downto 0);
          Alg_Card2_9          : in  std_logic_vector(15 downto 0);
          Alg_Card2_10         : in  std_logic_vector(15 downto 0);        
          Alg_Card2_11         : in  std_logic_vector(15 downto 0);
          Alg_Card2_12         : in  std_logic_vector(15 downto 0);
          Alg_Card2_13         : in  std_logic_vector(15 downto 0);
          Alg_Card2_14         : in  std_logic_vector(15 downto 0);
          Alg_Card2_15         : in  std_logic_vector(15 downto 0);
          Alg_Card2_16         : in  std_logic_vector(15 downto 0);        
          Alg_Card2_17         : in  std_logic_vector(15 downto 0);
          Alg_Card2_18         : in  std_logic_vector(15 downto 0);
          Alg_Card2_19         : in  std_logic_vector(15 downto 0);
          Alg_Card2_20         : in  std_logic_vector(15 downto 0);
          Alg_Card2_21         : in  std_logic_vector(15 downto 0);
          Alg_Card2_22         : in  std_logic_vector(15 downto 0);        
          Alg_Card2_23         : in  std_logic_vector(15 downto 0);
          Alg_Card2_24         : in  std_logic_vector(15 downto 0);
          Alg_Card2_25         : in  std_logic_vector(15 downto 0);
          Alg_Card2_26         : in  std_logic_vector(15 downto 0);
          Alg_Card2_27         : in  std_logic_vector(15 downto 0);
          Alg_Card2_28         : in  std_logic_vector(15 downto 0);        
          Alg_Card2_29         : in  std_logic_vector(15 downto 0);
          Alg_Card2_30         : in  std_logic_vector(15 downto 0);
          Alg_Card2_31         : in  std_logic_vector(15 downto 0);
          Alg_Card2_32         : in  std_logic_vector(15 downto 0);
          Alg_Card2_33         : in  std_logic_vector(15 downto 0);
          Alg_Card2_34         : in  std_logic_vector(15 downto 0);        
          Alg_Card2_35         : in  std_logic_vector(15 downto 0);
          Alg_Card2_36         : in  std_logic_vector(15 downto 0);
          Alg_Card2_37         : in  std_logic_vector(15 downto 0);
          Alg_Card2_38         : in  std_logic_vector(15 downto 0);
          Alg_Card2_40         : in  std_logic_vector(15 downto 0);        
          Alg_Card2_41         : in  std_logic_vector(15 downto 0);
          Alg_Card2_42         : in  std_logic_vector(15 downto 0);
          Alg_Card2_43         : in  std_logic_vector(15 downto 0);
          Alg_Card2_44         : in  std_logic_vector(15 downto 0);
          Alg_Card2_45         : in  std_logic_vector(15 downto 0);
          Alg_Card2_46         : in  std_logic_vector(15 downto 0);        
          Alg_Card2_47         : in  std_logic_vector(15 downto 0);
          Alg_Card2_48         : in  std_logic_vector(15 downto 0);
          Input_Source          : in  std_logic_vector(7 downto 0);
          Freq_Source           : in  std_logic_vector(7 downto 0);
          Valon_Data            : in  std_logic_vector(223 downto 0);
          Version_Register      : in  std_logic_vector(199 downto 0);
          Ana_In_Request        : out std_logic;
          Dig_In_Request        : out std_logic;
          Dig_Out_Request       : out std_logic;
          Analog_Input_Valid    : in  std_logic;
          Header_1              : in  std_logic_vector(7 downto 0);
          Header_2              : in  std_logic_vector(7 downto 0);
          Header_3              : in  std_logic_vector(7 downto 0);
          Mode                  : in  std_logic_vector(7 downto 0);
          One_mS_pulse          : in  std_logic;
          Tx_Rate               : in  integer range 0 to 255;
          Baud_Rate_Enable      : in  std_logic;
          SYCN_Pulse            : out std_logic;
          Version_Data_Ready    : in  std_logic;
          Data_Ready            : in  std_logic;
          Valon_Data_Ready      : in  std_logic;
          Noise_Diode_Valid     : in std_logic;
          Valon_Message_Length  : in  std_logic_vector(7 downto 0);
          Watchdog_Reset        : in  std_logic;
          Mux_watchdog          : out std_logic
      );
  end component Main_Mux;

  -- Baud Rate for Mux Signals and Component
  signal baud_rate_i          : integer range 0 to 7;

  component Baud_Rate_Generator is
      port (
          Clk              : in  std_logic;
          RST_I            : in  std_logic;
          baud_rate        : in  integer range 0 to 7;
          Baud_Rate_Enable : out std_logic
      );
  end component Baud_Rate_Generator;
  
-------------------------------------------------------------------------------
-- New Code Signal and Components
------------------------------------------------------------------------------- 
signal RST_I_i                  : std_logic;
signal CLK_I_i                  : std_logic;

signal Dig_Outputs_Ready_i      : std_logic;
signal Dig_Inputs_Ready_i       : std_logic;
signal Ana_Inputs_Ready_i       : std_logic;
signal Output_Lokcout           : std_logic;

type Mux_Text_States is (Idle, Valon_Data_State, All_Data_State, Version_Data_State, AllData_ValonData,
                        AllData_ValonData_VersionData, ValonData_VersionData, AllData_VersionData);

signal Mux_Text_State : Mux_Text_States;
---------------------------------------
----------------------------------------
-- General Signals
-------------------------------------------------------------------------------
  signal  sClok,snrst,sStrobe,PWM_sStrobe,newClk,Clk : std_logic := '0';
  signal  stx_data,srx_data : std_logic_vector(3 downto 0) := "0000";
  signal  sCnt         : integer range 0 to 7 := 0;
  signal  cont         : integer range 0 to 100;  
  signal  oClk,OneuS_sStrobe, Quad_CHA_sStrobe, Quad_CHB_sStrobe,OnemS_sStrobe,cStrobe,sStrobe_A,Ten_mS_sStrobe,Twenty_mS_sStrobe, Fifty_mS_sStrobe, Hun_mS_sStrobe : std_logic;

  constant Baudrate : integer := 115200;
  constant bit_time_4800      : time                         := 52.08*4 us;
  constant bit_time_9600      : time                         := 52.08*2 us;    
  constant bit_time_19200     : time                         := 52.08 us;
  constant bit_time_57600     : time                         := 17.36 us;    
  constant bit_time_115200    : time                         := 8.68 us;  
  constant default_bit_time   : time                         := 52.08 us;  --19200  
  constant start_bit          : std_logic := '0';
  constant stop_bit           : std_logic := '1';
  signal   bit_time           : time;
                                                                    
begin
      
 RST_I_i         <= snrst;
 CLK_I_i         <= sClok;
 
 Version_Register_i <=  RF_Controller_name_i & Null_i & Version_Major_High_i & Version_Major_Low_i & Dot_i &
                              Version_Minor_High_i & Version_Minor_Low_i & Dot_i &
                              Version_Timestamp_i & Null_i;
-------------------------------------------------------------------------------
-- New test Code
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Leave in code
-------------------------------------------------------------------------------   
    T1: test_bench_T
     port map(
       oVec => stx_data,
       oClk => sClok,
       iVec => srx_data
       );

           -- Version Register Instance
    Ver_Reg_1: entity work.Version_Reg
    port map (
        RST_I             => RST_I_i,
        CLK_I             => CLK_I_i,
        Version_Timestamp => Version_Timestamp_i
    );

-- Main Mux Instance
    -- Signal Chain Controller Mux 
    Main_Mux_1: entity work.Main_Mux
        port map (
            Clk                   => CLK_I_i,
            RST_I                 => RST_I_i,
            UART_TXD              => RFC_to_Pieter_UART_TXD_i,
            Valon_Message_Length  => RX_Message_Length_i,
            Message_Length        => Message_Length_i,
            Timer_Sec_Reg_1       => Timer_Sec_Reg_1_i,
            Timer_mSec_Reg_1      => Timer_mSec_Reg_1_i,
            Dig_Card1_1_B0        => Dig_Out_1_B0_i, 
            Dig_Card1_1_B1        => Dig_Out_1_B1_i,
            Dig_Card1_1_B2        => Dig_Out_1_B2_i,
            Dig_Card1_1_B3        => Dig_Out_1_B3_i,
            Dig_Card1_1_B4        => Dig_Out_1_B4_i,
            Dig_Card1_1_B5        => Dig_Out_1_B5_i,
            Dig_Card1_1_B6        => Dig_Out_1_B6_i,
            Dig_Card1_1_B7        => Dig_Out_1_B7_i,
            Digital_Input_Valid   => Digital_Input_Valid_i,
            Dig_Card1_2_B0        => Dig_In_1_B0_i,                
            Dig_Card1_2_B1        => Dig_In_1_B1_i,               
            Dig_Card1_2_B2        => Dig_In_1_B2_i,                 
            Dig_Card1_2_B3        => Dig_In_1_B3_i,               
            Dig_Card1_2_B4        => Dig_In_1_B4_i,                
            Dig_Card1_2_B5        => Dig_In_1_B5_i,                
            Dig_Card1_2_B6        => Dig_In_1_B6_i,                
            Dig_Card1_2_B7        => Dig_In_1_B7_i,         
            Digital_Output_Valid  => Digital_Output_Valid_i,
            Alg_Card1_1           => x"0d37",            
            Alg_Card1_2           => x"0d37",          
            Alg_Card1_3           => x"0d37",       
            Alg_Card1_4           => x"0d37",          
            Alg_Card1_5           => x"0d37",        
            Alg_Card1_6           => x"0d37",         
            Alg_Card1_7           => x"0d37",         
            Alg_Card1_8           => x"0d37",       
            Alg_Card1_9           => x"0d37",         
            Alg_Card1_10          => x"0d37",        
            Alg_Card1_11          => x"0d37",        
            Alg_Card1_12          => x"0d37",        
            Alg_Card1_13          => x"0d37",         
            Alg_Card1_14          => x"0d37",         
            Alg_Card1_15          => x"0d37",          
            Alg_Card1_16          => x"0d37",        
            Alg_Card1_17          => x"0d37",          
            Alg_Card1_18          => x"0d37",       
            Alg_Card1_19          => x"0d37",         
            Alg_Card1_20          => x"0d37",        
            Alg_Card1_21          => x"0d37",          
            Alg_Card1_22          => x"0d37",         
            Alg_Card1_23          => x"0d37",        
            Alg_Card1_24          => x"0d37",         
            Alg_Card1_25          => x"0d37",        
            Alg_Card1_26          => x"0d37",        
            Alg_Card1_27          => x"0d37",        
            Alg_Card1_28          => x"0d37",          
            Alg_Card1_29          => x"0d37",         
            Alg_Card1_30          => x"0d37",         
            Alg_Card1_31          => x"0d37",        
            Alg_Card1_32          => x"0d37",         
            Alg_Card1_33          => x"0d37",         
            Alg_Card1_34          => x"0d37",          
            Alg_Card1_35          => x"0d37",         
            Alg_Card1_36          => x"0d37",         
            Alg_Card1_37          => x"0d37",         
            Alg_Card1_38          => x"0d37",        
            Alg_Card1_39          => x"0d37",        
            Alg_Card1_40          => x"0d37",        
            Alg_Card1_41          => x"0d37",         
            Alg_Card1_42          => x"0d37",        
            Alg_Card1_43          => x"0d37",        
            Alg_Card1_44          => x"0d37",       
            Alg_Card1_45          => x"0d37",        
            Alg_Card1_46          => x"0d37",         
            Alg_Card1_47          => x"0d37",      
            Alg_Card1_48          => x"0d37", 
            Alg_Card2_1           => x"0d37",           
            Alg_Card2_2           => x"0d37",          
            Alg_Card2_3           => x"0d37",       
            Alg_Card2_4           => x"0d37",          
            Alg_Card2_5           => x"0d37",        
            Alg_Card2_6           => x"0d37",         
            Alg_Card2_7           => x"0d37",         
            Alg_Card2_8           => x"0d37",       
            Alg_Card2_9           => x"0d37",         
            Alg_Card2_10          => x"0d37",        
            Alg_Card2_11          => x"0d37",        
            Alg_Card2_12          => x"0d37",        
            Alg_Card2_13          => x"0d37",         
            Alg_Card2_14          => x"0d37",         
            Alg_Card2_15          => x"0d37",          
            Alg_Card2_16          => x"0d37",        
            Alg_Card2_17          => x"0d37",          
            Alg_Card2_18          => x"0d37",       
            Alg_Card2_19          => x"0d37",         
            Alg_Card2_20          => x"0d37",        
            Alg_Card2_21          => x"0d37",          
            Alg_Card2_22          => x"0d37",         
            Alg_Card2_23          => x"0d37",        
            Alg_Card2_24          => x"0d37",         
            Alg_Card2_25          => x"0d37",        
            Alg_Card2_26          => x"0d37",        
            Alg_Card2_27          => x"0d37",        
            Alg_Card2_28          => x"0d37",          
            Alg_Card2_29          => x"0d37",         
            Alg_Card2_30          => x"0d37",         
            Alg_Card2_31          => x"0d37",        
            Alg_Card2_32          => x"0d37",         
            Alg_Card2_33          => x"0d37",         
            Alg_Card2_34          => x"0d37",          
            Alg_Card2_35          => x"0d37",         
            Alg_Card2_36          => x"0d37",         
            Alg_Card2_37          => x"0d37",         
            Alg_Card2_38          => x"0d37",        
            Alg_Card2_39          => x"0d37",        
            Alg_Card2_40          => x"0d37",        
            Alg_Card2_41          => x"0d37",         
            Alg_Card2_42          => x"0d37",        
            Alg_Card2_43          => x"0d37",        
            Alg_Card2_44          => x"0d37",       
            Alg_Card2_45          => x"0d37",        
            Alg_Card2_46          => x"0d37",         
            Alg_Card2_47          => x"0d37",      
            Alg_Card2_48          => x"0d37",
            Input_Source          => Input_Source_i,
            Freq_Source           => Freq_Source_i,
            Valon_Data            => RX_Valon_Data_i,
            Version_Register      => Version_Register_i,
            Ana_In_Request        => Ana_In_Request_i,
            Dig_In_Request        => Dig_In_Request_i,                
            Dig_Out_Request       => Dig_Out_Request_i,
            Analog_Input_Valid_1  => Analog_Input_Valid_1_i,
            Analog_Input_Valid_2  => Analog_Input_Valid_2_i,
            Header_1              => RX_Header_1_i,
            Header_2              => RX_Header_2_i,
            Header_3              => RX_Header_3_i,
            Mode                  => RX_Mode_i,
            One_mS_pulse          => OneuS_sStrobe,
            Tx_Rate               => Tx_Rate_i,
            Baud_Rate_Enable      => Mux_Baud_Rate_Enable_i,
            SYCN_Pulse            => SYCN_Pulse_i,
            Data_Ready            => Data_Ready_i,
            Noise_Diode_Valid     => Noise_Diode_Valid_i,
            Valon_Data_Ready      => Valon_Data_Ready_i,
            Version_Data_Ready    => Version_Data_Ready_i,
            Watchdog_Reset        => Watchdog_Reset_i,
            Mux_watchdog          => Mux_watchdog_i
        );            

    -- Baud Instance for Mux       
    Main_Baud_1: entity work.Baud_Rate_Generator
        port map (
            Clk              => CLK_I_i,
            RST_I            => RST_I_i,
            baud_rate        => 5,
            Baud_Rate_Enable => Mux_Baud_Rate_Enable_i
        );  
     
Time_Controlled_Data_Generate: process (CLK_I_i, RST_I_i)
  
  variable mS_Cnt        : integer range 0 to 1000;
  variable Baud_rate_cnt : integer range 0 to 450;
  begin

    if RST_I_i = '0' then      
       Timer_Sec_Reg_1_i         <= (others => '0');
       Timer_mSec_Reg_1_i        <= (others => '0');
       Channel1_i                <= (others => '0');                 
       Channel2_i                <= (others => '0');
       Dig_In_1_B0_i             <= (others => '0');
       Dig_In_1_B1_i             <= (others => '0');
       Dig_In_1_B2_i             <= (others => '0');
       Dig_In_1_B3_i             <= (others => '0');
       Dig_In_1_B4_i             <= (others => '0');
       Dig_In_1_B5_i             <= (others => '0');
       Dig_In_1_B6_i             <= (others => '0');
       Dig_In_1_B7_i             <= (others => '0');
       Dig_Out_1_B0_i            <= (others => '0');
       Dig_Out_1_B1_i            <= (others => '0');
       Dig_Out_1_B2_i            <= (others => '0');
       Dig_Out_1_B3_i            <= (others => '0');
       Dig_Out_1_B4_i            <= (others => '0');
       Dig_Out_1_B5_i            <= (others => '0');
       Dig_Out_1_B6_i            <= (others => '0');
       Dig_Out_1_B7_i            <= (others => '0');
       Input_Source_i            <= (others => '0');
       Freq_Source_i             <= (others => '0');
       Valon_Data_i              <= (others => '0');
       RX_Valon_Data_i           <= (others => '0');
       Valon_Message_length_i    <= (others => '0');  
       RX_Message_Length_i       <= (others => '0'); 
       Header_1_i                <= (others => '0');  
       Header_2_i                <= (others => '0'); 
       Header_3_i                <= (others => '0');  
       Mode_i                    <= (others => '0');
       RX_Mode_i                 <= (others => '0');
       Dig_Inputs_Ready_i        <= '0';
       Dig_Outputs_Ready_i       <= '0';
       Ana_Inputs_Ready_i        <= '0';
       Noise_Diode_Valid_i       <= '0';
       Valon_Data_Ready_i        <= '0';
       Version_Data_Ready_i      <= '0';
       RX_Valon_Data_Ready_i     <= '0';
       Digital_Input_Valid_i     <= '0';
       Digital_Output_Valid_i    <= '0';
       Analog_Input_Valid_1_i    <= '0';
       Analog_Input_Valid_2_i    <= '0';
       Baud_Rate_Enable_i        <= '0';
       Analog_Busy_i             <= '0';
       Output_Lokcout            <= '0';
       mS_Cnt                    := 0;
       Baud_rate_cnt             := 0;       
       Mux_Text_State            <= idle;
   elsif CLK_I_i'event and CLK_I_i='1' then
       -- Sync mS Counter
       if OnemS_sStrobe = '1' then
           mS_Cnt := mS_Cnt + 1;
       end if;
       -- 
       -- Test Case Scenarios
       case Mux_Text_State is
           
           when Idle =>
               -- Noise_Diode_Valid_i     <= '0';
               Version_Data_Ready_i    <= '0';
               Valon_Data_Ready_i      <= '0';
               if mS_Cnt = 0 then                                   -- [0;0] Condition 1 of 8
                   Valon_Data_Ready_i       <= '0';
                   Version_Data_Ready_i     <= '0';
                   -- Noise_Diode_Valid_i      <= '0';
                   Mux_Text_State           <= Idle;
               elsif mS_Cnt > 0 then   
                   Mux_Text_State           <= Valon_Data_State;
               end if;    
               
           when Valon_Data_State =>
               if mS_Cnt = 50 then                               -- [0;1] Condition 2 of 8 - Async
                   Valon_Data_Ready_i       <= '1';
                   Version_Data_Ready_i     <= '1';
                   Mux_Text_State           <= All_Data_State;
               end if;    
                   
           when All_Data_State =>
               Valon_Data_Ready_i       <= '0';
               Version_Data_Ready_i     <= '0';
               if mS_Cnt = 99 then                               -- [1;0] Condition 3(1) of 8 - Sync
                   -- Noise_Diode_Valid_i      <= '1';
                   Mux_Text_State           <= AllData_ValonData;
               end if;
               
           when AllData_ValonData =>
               -- Noise_Diode_Valid_i          <= '0';
               if mS_Cnt = 202 then           -- [1;1] Condition 4 of 8 - Sync and Async
                   Valon_Data_Ready_i       <= '1';
                   -- Noise_Diode_Valid_i      <= '1';
                   Mux_Text_State           <= Version_Data_State;
               end if;
       
           when Version_Data_State =>
               -- Noise_Diode_Valid_i      <= '0';
               Valon_Data_Ready_i       <= '0';
               if mS_Cnt = 233 then                                -- [0;0] Condition 5 of 8 - Async and Async
                   Version_Data_Ready_i    <= '1';
                   Mux_Text_State          <= ValonData_VersionData;
               end if; 
               
           when ValonData_VersionData =>
               Version_Data_Ready_i    <= '0';
               if mS_Cnt = 270 then                                -- [0;1] Condition 6 of 8 - Async
                   Version_Data_Ready_i    <= '1';
                   Valon_Data_Ready_i      <= '1';
                   Mux_Text_State          <= AllData_VersionData;
               end if;    
               
           when AllData_VersionData =>
               Version_Data_Ready_i    <= '0';
               Valon_Data_Ready_i      <= '0';
               if mS_Cnt = 306 then                                -- [1;0] Condition 7 of 8 - Async
                  -- Noise_Diode_Valid_i     <= '1';
                   Version_Data_Ready_i    <= '1';
                   Mux_Text_State          <= AllData_ValonData_VersionData;
               end if; 
               
           when AllData_ValonData_VersionData =>
               Version_Data_Ready_i    <= '0';
               -- Noise_Diode_Valid_i     <= '0';
               if mS_Cnt = 406 then                                -- [1;1] Condition 8 of 8
                   mS_Cnt                  := 0;
                   -- Noise_Diode_Valid_i     <= '1';
                   Version_Data_Ready_i    <= '1';
                   Valon_Data_Ready_i      <= '1';
                   Mux_Text_State          <= Idle;
               else
                   -- Noise_Diode_Valid_i     <= '0';
                   Version_Data_Ready_i    <= '0';
                   Valon_Data_Ready_i      <= '0';
               end if; 
               
           when others =>
               Mux_Text_State          <= Idle;
       end case;
               
       
-- Configuring Digital Outputs
      -- Request Digital Outputs
      if Dig_Out_Request_i = '1' then 
          Dig_Outputs_Ready_i <= '1'; 
          Output_Lokcout      <= '1';
      elsif Dig_Out_Request_i = '0' and Output_Lokcout = '1' then
          Dig_Outputs_Ready_i <= '0';
          Output_Lokcout      <= '0';
      else  
          Dig_Outputs_Ready_i <= '0';   
      end if;  
      -- Send Digital Outputs to Mux
      if Dig_Outputs_Ready_i = '1' then
          Dig_Out_1_B0_i         <= X"AA";
          Dig_Out_1_B1_i         <= X"AA";
          Dig_Out_1_B2_i         <= X"AA";
          Dig_Out_1_B3_i         <= X"AA";
          Dig_Out_1_B4_i         <= X"AA";
          Dig_Out_1_B5_i         <= X"AA";
          Dig_Out_1_B6_i         <= X"AA";
          Dig_Out_1_B7_i         <= X"AA";
          Digital_Output_Valid_i <= '1';
      else
          Digital_Output_Valid_i <= '0';
      end if;  
 -- Reading Digital Inputs
      -- Request Digital Outputs
      if Dig_In_Request_i = '1' then
          Dig_Inputs_Ready_i <= '1'; 
      else  
          Dig_Inputs_Ready_i <= '0';   
      end if; 
      -- Send Digital Inputs to Mux
      if Dig_Inputs_Ready_i = '1' then
          Dig_In_1_B0_i         <= X"FF";
          Dig_In_1_B1_i         <= X"FF";
          Dig_In_1_B2_i         <= X"FF";
          Dig_In_1_B3_i         <= X"FF";
          Dig_In_1_B4_i         <= X"FF";
          Dig_In_1_B5_i         <= X"FF";
          Dig_In_1_B6_i         <= X"FF";
          Dig_In_1_B7_i         <= X"FF";
          Digital_Input_Valid_i <= '1';
      else
          Digital_Input_Valid_i <= '0';
      end if; 

-- Reading Analog Inputs
      -- Request Analog Inputs
      if Ana_In_Request_i = '1' then
          Ana_Inputs_Ready_i <= '1'; 
      else  
          Ana_Inputs_Ready_i <= '0';   
      end if;       
      -- Send Analog Inputs to Mux
      if Ana_Inputs_Ready_i = '1' then
          Analog_Input_Valid_1_i  <= '1';
          Analog_Input_Valid_2_i  <= '1';
      else
          Analog_Input_Valid_1_i  <= '0';
          Analog_Input_Valid_2_i  <= '0';
      end if; 

-- Configuring the valn
      if Valon_Data_Ready_i = '1' then
          Mode_i                            <= X"90";
          RX_Message_Length_i               <= X"23";  
          RX_Header_1_i                     <= X"A5";  
          RX_Header_2_i                     <= X"5A"; 
          RX_Header_3_i                     <= X"7E";  
          RX_Mode_i                         <= X"84";
          RX_Valon_Data_i(223 downto 216)   <= X"00";
          RX_Valon_Data_i(215 downto 208)   <= X"01";
          RX_Valon_Data_i(207 downto 200)   <= X"00";
          RX_Valon_Data_i(199 downto 192)   <= X"80";
          RX_Valon_Data_i(191 downto 184)   <= X"00";
          RX_Valon_Data_i(183 downto 176)   <= X"00";
          RX_Valon_Data_i(175 downto 168)   <= X"08"; 
          RX_Valon_Data_i(167 downto 160)   <= X"00";
      end if;
      
-- Configuring Noise Diode Inputs

      if Noise_Diode_Valid_i = '1' then
          Input_Source_i <= X"1B";
          Freq_Source_i  <= X"A0"; 
      end if;     
      
      -- if Version_Data_Ready_i = '1' then
      --   Version_Timestamp_i <= X"3230313831313230313035343339";
      -- end if;    
        
        if Baud_rate_cnt = 0 then
           Baud_rate_cnt      := 433;
           Baud_Rate_Enable_i <= '1';
        else
           Baud_rate_cnt      := Baud_rate_cnt - 1;
           Baud_Rate_Enable_i <= '0';
       end if;

    end if;
  end process Time_Controlled_Data_Generate;          
       
   strobe: process
   begin
     sStrobe <= '0', '1' after 200 ns, '0' after 430 ns;  
     wait for 200 us;
   end process strobe;

   strobe_SPI: process
   begin
     sStrobe_A <= '0', '1' after 200 ns, '0' after 430 ns;  
     wait for 1 ms;
   end process strobe_SPI;
  
    uS_strobe: process
    begin
      OneuS_sStrobe <= '0', '1' after 1 us, '0' after 1.020 us;  
      wait for 1 us;
    end process uS_strobe;

    mS_strobe: process
    begin
      OnemS_sStrobe <= '0', '1' after 1 ms, '0' after 1.00002 ms;  
      wait for 1.0001 ms;
    end process mS_strobe;

  Ten_mS_strobe: process
    begin
      Ten_mS_sStrobe <= '0', '1' after 10 ms, '0' after 10.00002 ms;  
      wait for 10.0001 ms;
    end process Ten_mS_strobe;

  Twenty_mS_strobe: process
    begin
      Twenty_mS_sStrobe <= '0', '1' after 20 ms, '0' after 20.00002 ms;  
      wait for 20.0001 ms;
    end process Twenty_mS_strobe;

  Fifty_mS_strobe: process
    begin
      Fifty_mS_sStrobe <= '0', '1' after 50 ms, '0' after 50.00002 ms;  
      wait for 50.0001 ms;
    end process Fifty_mS_strobe;  

  Hun_mS_strobe: process
    begin
      Hun_mS_sStrobe <= '0', '1' after 100 ms, '0' after 100.00002 ms;  
      wait for 100.0001 ms;
    end process Hun_mS_strobe;   

 
  Gen_Clock: process
  begin
    newClk <= '0', '1' after 40 ns;
    wait for 80 ns;
  end process Gen_Clock;
  
  Do_reset: process(sClok)
  begin
    if (sClok'event and sClok='1') then 
      if sCnt = 7 then
        sCnt <= sCnt;
      else 
        sCnt <= sCnt + 1;

        case sCnt is
          when 0 => snrst <= '0';
          when 1 => snrst <= '0';
          when 2 => snrst <= '0';
          when 3 => snrst <= '0';
          when 4 => snrst <= '0';
          when others => snrst <= '1';
        end case;

      end if;
   
  end if;
  end process;

end Archtest_bench;

