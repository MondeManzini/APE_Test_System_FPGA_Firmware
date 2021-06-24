--

-- DESCRIPTION
-- ===========
-- Transmitter Uart, this gets the data from the mux and send it back to the PC
-- Last update : 29/05/2021 - Monde Manzini

--              - Testbench: Main_Mux_Test_Bench located at
--                https://katfs.kat.ac.za/svnAfricanArray/SoftwareRepository/CommonCode/ScrCommon
--              - Main_Mux_Test_Bench.do file located at
--                https://katfs.kat.ac.za/svnAfricanArray/SoftwareRepository/CommonCode/Modelsim/ 
-- Version : 0.1

---------------------
---------------------

-- Edited By            : Monde Manzini
--                      : Changed the header
--                      : Updated version
-- Version              : 0.1 
-- Change Note          : 
-- Tested               : 07/05/2021
-- Test Bench file Name : Main_Mux_Test_Bench
-- located at           : (https://katfs.kat.ac.za/svnAfricanArray/Software
--                        Repository/CommonCode/ScrCommon)
-- Test do file         : Main_Mux_Test_Bench.do
-- located at            (https://katfs.kat.ac.za/svnAfricanArray/Software
--                        Repository/CommonCode/Modelsim)

-- Outstanding          : Integration ATP and Approval
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_UNSIGNED.all;

entity Main_Mux is
  port(
    CLK_I                               : in  std_logic;
    RST_I                               : in  std_logic;
-- Ser data out
    UART_TXD                            : out std_logic;
-- From Demux
    Message_Length                      : in  std_logic_vector(7 downto 0);
-------------------------------------------------------------------------------
-- Operation
-------------------------------------------------------------------------------
-- Time Stamp
   Timer_Sec_Reg_1                      : in  std_logic_vector(31 downto 0);
   Timer_mSec_Reg_1                     : in  std_logic_vector(15 downto 0);
    
-- Digital Output    
    Dig_Out_1_B0                        : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B1                        : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B2                        : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B3                        : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B4                        : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B5                        : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B6                        : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B7                        : in  std_logic_vector(7 downto 0);
    Digital_Input_Valid                 : in  std_logic;
    
-- Digital Input          
    Dig_In_1_B0                         : in  std_logic_vector(7 downto 0);
    Dig_In_1_B1                         : in  std_logic_vector(7 downto 0);        
    Dig_In_1_B2                         : in  std_logic_vector(7 downto 0);        
    Dig_In_1_B3                         : in  std_logic_vector(7 downto 0);
    Dig_In_1_B4                         : in  std_logic_vector(7 downto 0);
    Dig_In_1_B5                         : in  std_logic_vector(7 downto 0);        
    Dig_In_1_B6                         : in  std_logic_vector(7 downto 0);        
    Dig_In_1_B7                         : in  std_logic_vector(7 downto 0); 
    Digital_Output_Valid                : in  std_logic;
    	 
-- Analog In        
    -- Analog InS        
    -- Analog In 1        
    Alg_Card1_1                         : in  std_logic_vector(15 downto 0);        
    Alg_Card1_2                         : in  std_logic_vector(15 downto 0);                
    Alg_Card1_3                         : in  std_logic_vector(15 downto 0);
    Alg_Card1_4                         : in  std_logic_vector(15 downto 0);        
    Alg_Card1_5                         : in  std_logic_vector(15 downto 0);
    Alg_Card1_6                         : in  std_logic_vector(15 downto 0);
    Alg_Card1_7                         : in  std_logic_vector(15 downto 0);
    Alg_Card1_8                         : in  std_logic_vector(15 downto 0);
    Alg_Card1_9                         : in  std_logic_vector(15 downto 0);
    Alg_Card1_10                        : in  std_logic_vector(15 downto 0);        
    Alg_Card1_11                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_12                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_13                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_14                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_15                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_16                        : in  std_logic_vector(15 downto 0);        
    Alg_Card1_17                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_18                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_19                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_20                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_21                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_22                        : in  std_logic_vector(15 downto 0);        
    Alg_Card1_23                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_24                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_25                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_26                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_27                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_28                        : in  std_logic_vector(15 downto 0);        
    Alg_Card1_29                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_30                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_31                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_32                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_33                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_34                        : in  std_logic_vector(15 downto 0);        
    Alg_Card1_35                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_36                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_37                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_38                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_39                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_40                        : in  std_logic_vector(15 downto 0);        
    Alg_Card1_41                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_42                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_43                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_44                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_45                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_46                        : in  std_logic_vector(15 downto 0);        
    Alg_Card1_47                        : in  std_logic_vector(15 downto 0);
    Alg_Card1_48                        : in  std_logic_vector(15 downto 0);
    
    Analog_Input_Valid                  : in  std_logic;
    
    Version_Name                        : in std_logic_vector(255 downto 0); 
    Version_Number                      : in std_logic_vector(63 downto 0);
    Version_Data_Ready                  : in std_logic; 

-- Requests
    Ana_In_Request                      : out std_logic;
    Dig_In_Request                      : out std_logic;
    Dig_Out_Request                     : out std_logic;
     
    Baud_Rate_Enable                    : in  std_logic;  
    Data_Ready                          : in  std_logic;
    Watchdog_Reset                      : in  std_logic;
    Mux_watchdog                        : out std_logic;
    One_mS                              : in  std_logic;
    Main_Mux_Version_Name               : out std_logic_vector(255 downto 0);
    Main_Mux_Version_Number             : out std_logic_vector(63 downto 0);
    Main_Mux_Version_Ready              : out std_logic; 
    Main_Mux_Version_Request            : in  std_logic;
    Module_Number                       : in  std_logic_vector(7 downto 0)
    );

end Main_Mux;

architecture Arch_DUT of Main_Mux is


  constant Preamble1        : std_logic_vector(7 downto 0) := X"A5";
  constant Preamble2        : std_logic_vector(7 downto 0) := X"5A";
  constant Preamble3        : std_logic_vector(7 downto 0) := X"7E";
  
  constant Output_Card_1    : std_logic_vector(7 downto 0) := X"10";
  constant Output_Card_2    : std_logic_vector(7 downto 0) := X"11";
--  constant Output_Card_3    : std_logic_vector(7 downto 0) := X"12";
--  constant Output_Card_4    : std_logic_vector(7 downto 0) := X"13";
--  constant Output_Card_5    : std_logic_vector(7 downto 0) := X"14";
--  constant Output_Card_6    : std_logic_vector(7 downto 0) := X"15";
--  constant Output_Card_7    : std_logic_vector(7 downto 0) := X"16";
--  constant Output_Card_8    : std_logic_vector(7 downto 0) := X"17"; 
--  constant Output_Card_9    : std_logic_vector(7 downto 0) := X"18";
--  constant Output_Card_10    : std_logic_vector(7 downto 0) := X"19";
--  constant Output_Card_11    : std_logic_vector(7 downto 0) := X"1A";
--  constant Output_Card_12    : std_logic_vector(7 downto 0) := X"1B";
--  constant Output_Card_13    : std_logic_vector(7 downto 0) := X"1C";
--  constant Output_Card_14    : std_logic_vector(7 downto 0) := X"1D";
--  constant Output_Card_15    : std_logic_vector(7 downto 0) := X"1E";
--  constant Output_Card_16    : std_logic_vector(7 downto 0) := X"1F";

  constant Input_Card_1    : std_logic_vector(7 downto 0) := X"20";
  constant Input_Card_2    : std_logic_vector(7 downto 0) := X"21";
--  constant Input_Card_3    : std_logic_vector(7 downto 0) := X"22";
--  constant Input_Card_4    : std_logic_vector(7 downto 0) := X"23";
--  constant Input_Card_5    : std_logic_vector(7 downto 0) := X"24";
--  constant Input_Card_6    : std_logic_vector(7 downto 0) := X"25";
--  constant Input_Card_7    : std_logic_vector(7 downto 0) := X"26";
--  constant Input_Card_8    : std_logic_vector(7 downto 0) := X"27"; 
--  constant Input_Card_9    : std_logic_vector(7 downto 0) := X"28";
--  constant Input_Card_10    : std_logic_vector(7 downto 0) := X"29";
--  constant Input_Card_11    : std_logic_vector(7 downto 0) := X"2A";
--  constant Input_Card_12    : std_logic_vector(7 downto 0) := X"2B";
--  constant Input_Card_13    : std_logic_vector(7 downto 0) := X"2C";
--  constant Input_Card_14    : std_logic_vector(7 downto 0) := X"2D";
--  constant Input_Card_15    : std_logic_vector(7 downto 0) := X"2E";
--  constant Input_Card_16    : std_logic_vector(7 downto 0) := X"2F";

  constant Analog_Card_1    : std_logic_vector(7 downto 0) := X"30";
  constant Analog_Card_2    : std_logic_vector(7 downto 0) := X"31";
--  constant Input_Card_3    : std_logic_vector(7 downto 0) := X"22";
--  constant Input_Card_4    : std_logic_vector(7 downto 0) := X"23";
--  constant Input_Card_5    : std_logic_vector(7 downto 0) := X"24";
--  constant Input_Card_6    : std_logic_vector(7 downto 0) := X"25";
--  constant Input_Card_7    : std_logic_vector(7 downto 0) := X"26";
--  constant Input_Card_8    : std_logic_vector(7 downto 0) := X"27"; 
--  constant Input_Card_9    : std_logic_vector(7 downto 0) := X"28";
--  constant Input_Card_10    : std_logic_vector(7 downto 0) := X"29";
--  constant Input_Card_11    : std_logic_vector(7 downto 0) := X"2A";
--  constant Input_Card_12    : std_logic_vector(7 downto 0) := X"2B";
--  constant Input_Card_13    : std_logic_vector(7 downto 0) := X"2C";
--  constant Input_Card_14    : std_logic_vector(7 downto 0) := X"2D";
--  constant Input_Card_15    : std_logic_vector(7 downto 0) := X"2E";
--  constant Input_Card_16    : std_logic_vector(7 downto 0) := X"2F"; 
 
 
  type tx_states 	is (idle, sync, send_start, send_data, CRC_ready, send_stop);
  type tx_data_array is array (0 to 255) of std_logic_vector(7 downto 0);

  signal data2send                              : tx_data_array;
  signal CRC2send                               : tx_data_array;
  signal tx_state                               : tx_states;
  
  signal enable_div20                           : std_logic;
  signal sample_clock2                          : std_logic;
  signal no_of_chars                            : integer range 0 to 255;  
  signal no_of_chars2send                       : integer range 0 to 255;
  signal ComPort_no_of_chars2send               : integer range 0 to 255;
  signal baud_rate_reload                       : integer range 0 to 6000;
  signal busy                                   : std_logic;
  signal comms_done                             : std_logic;
  signal done                                   : std_logic;
  signal send_msg                               : std_logic;
  signal SerDataOut                             : std_logic;
  signal CRCSerDataOut                          : std_logic;
  signal SerData_Byte                           : std_logic_vector(7 downto 0);
  -- CRC 16 Signals
  signal X                                      : std_logic_vector(15 downto 0);
  signal CRC_Sum                                : std_logic_vector(15 downto 0);
  signal crc16_ready                            : std_logic;
  signal add_crc                                : std_logic;
  signal Send_Operation                         : std_logic;
  signal Send_ComPort_Data                      : std_logic;
  signal Send_ShaftEncoder                      : std_logic;
  signal lockout_trigger                        : std_logic;  
  signal lockout_Read_Trigger                   : std_logic;
  signal flag_WD                                : std_logic;
  signal Message_done                           : std_logic;
  signal Data_Ready_i                           : std_logic;

  signal Dig_Card1_1_B0_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B1_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B2_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B3_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B4_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B5_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B6_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_1_B7_i                       : std_logic_vector(7 downto 0);

  signal Dig_Card1_2_B0_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B1_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B2_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B3_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B4_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B5_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B6_i                       : std_logic_vector(7 downto 0);
  signal Dig_Card1_2_B7_i                       : std_logic_vector(7 downto 0);

  signal Time_Stamp_Byte_0_i                    : std_logic_vector(7 downto 0);
  signal Time_Stamp_Byte_1_i                    : std_logic_vector(7 downto 0);
  signal Time_Stamp_Byte_2_i                    : std_logic_vector(7 downto 0);
  signal Time_Stamp_Byte_3_i                    : std_logic_vector(7 downto 0);
  signal Dig_MilliSecond_B0_i                   : std_logic_vector(7 downto 0);
  signal Dig_MilliSecond_B1_i                   : std_logic_vector(7 downto 0);

   signal Alg_Card1_1_B0_i                       : std_logic_vector(7 downto 0);
  signal Alg_Card1_1_B1_i                       : std_logic_vector(7 downto 0);        
  signal Alg_Card1_2_B0_i                       : std_logic_vector(7 downto 0);
  signal Alg_Card1_2_B1_i                       : std_logic_vector(7 downto 0);                
  signal Alg_Card1_3_B0_i                       : std_logic_vector(7 downto 0);
  signal Alg_Card1_3_B1_i                       : std_logic_vector(7 downto 0);
  signal Alg_Card1_4_B0_i                       : std_logic_vector(7 downto 0);        
  signal Alg_Card1_4_B1_i                       : std_logic_vector(7 downto 0);        
  signal Alg_Card1_5_B0_i                       : std_logic_vector(7 downto 0);
  signal Alg_Card1_5_B1_i                       : std_logic_vector(7 downto 0);
  signal Alg_Card1_6_B0_i                       : std_logic_vector(7 downto 0);
  signal Alg_Card1_6_B1_i                       : std_logic_vector(7 downto 0);
  signal Alg_Card1_7_B0_i                       : std_logic_vector(7 downto 0);
  signal Alg_Card1_7_B1_i                       : std_logic_vector(7 downto 0);        
  signal Alg_Card1_8_B0_i                       : std_logic_vector(7 downto 0);
  signal Alg_Card1_8_B1_i                       : std_logic_vector(7 downto 0);                
  signal Alg_Card1_9_B0_i                       : std_logic_vector(7 downto 0);
  signal Alg_Card1_9_B1_i                       : std_logic_vector(7 downto 0);
  signal Alg_Card1_10_B0_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_10_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_11_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_11_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_12_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_12_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_13_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_13_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_14_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_14_B1_i                      : std_logic_vector(7 downto 0);                
  signal Alg_Card1_15_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_15_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_16_B0_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_16_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_17_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_17_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_18_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_18_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_19_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_19_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_20_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_20_B1_i                      : std_logic_vector(7 downto 0);                
  signal Alg_Card1_21_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_21_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_22_B0_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_22_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_23_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_23_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_24_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_24_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_25_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_25_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_26_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_26_B1_i                      : std_logic_vector(7 downto 0);                
  signal Alg_Card1_27_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_27_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_28_B0_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_28_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_29_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_29_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_30_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_30_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_31_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_31_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_32_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_32_B1_i                      : std_logic_vector(7 downto 0);                
  signal Alg_Card1_33_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_33_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_34_B0_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_34_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_35_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_35_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_36_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_36_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_37_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_37_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_38_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_38_B1_i                      : std_logic_vector(7 downto 0);                
  signal Alg_Card1_39_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_39_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_40_B0_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_40_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_41_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_41_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_42_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_42_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_43_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_43_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_44_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_44_B1_i                      : std_logic_vector(7 downto 0);                
  signal Alg_Card1_45_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_45_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_46_B0_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_46_B1_i                      : std_logic_vector(7 downto 0);        
  signal Alg_Card1_47_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_47_B1_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_48_B0_i                      : std_logic_vector(7 downto 0);
  signal Alg_Card1_48_B1_i                      : std_logic_vector(7 downto 0); 

  signal Message_length_i                       : std_logic_vector(7 downto 0);
  signal Ana_In_Request_i                       : std_logic;
  signal Dig_In_Request_i                       : std_logic;
  signal Dig_Out_Request_i                      : std_logic;
  signal Busy_Latch                             : std_logic;
  signal Ready_i                                : std_logic;
  signal Stack_100mS_Data                       : std_logic;
  signal Lockout                                : std_logic;
  signal Digital_Output_Ready                   : std_logic;
  signal Digital_Input_Ready                    : std_logic;
  signal Analog_Input_Ready                     : std_logic;
  signal All_Modules_Ready                      : std_logic;
  signal All_Modules_Trig                       : std_logic;
  signal Send_100mS_Data                        : std_logic;
  signal Send_All_Modules                       : std_logic;
  signal All_Data_Ready                         : std_logic;
  signal Analog_Input_Ready_1                   : std_logic;
  signal Analog_Input_Ready_2                   : std_logic;
  signal Request_Data_Strobe                    : std_logic;
  signal Send_Data_Strobe                       : std_logic;
  
  signal Version_Name_i             : std_logic_vector(255 downto 0); 
  signal Version_Number_i           : std_logic_vector(63 downto 0);  
  signal Send_Version_Data_Mess     : std_logic;
  signal Send_Version_Data_Ready    : std_logic;
  signal Send_Version_Data          : std_logic;
  signal Stack_Version_Data         : std_logic;
  signal Version_Data_Request       : std_logic;

--------------
-- Ascii Codes
--------------   
constant A        : std_logic_vector(7 downto 0) := X"41";
constant B        : std_logic_vector(7 downto 0) := X"42";
constant C        : std_logic_vector(7 downto 0) := X"43";
constant D        : std_logic_vector(7 downto 0) := X"44";
constant E        : std_logic_vector(7 downto 0) := X"45";
constant F        : std_logic_vector(7 downto 0) := X"46";
constant G        : std_logic_vector(7 downto 0) := X"47";
constant H        : std_logic_vector(7 downto 0) := X"48";
constant I        : std_logic_vector(7 downto 0) := X"49";
constant J        : std_logic_vector(7 downto 0) := X"4A";
constant K        : std_logic_vector(7 downto 0) := X"4B";
constant L        : std_logic_vector(7 downto 0) := X"4C";
constant M        : std_logic_vector(7 downto 0) := X"4D";
constant N        : std_logic_vector(7 downto 0) := X"4E";
constant O        : std_logic_vector(7 downto 0) := X"4F";
constant P        : std_logic_vector(7 downto 0) := X"50";
constant Q        : std_logic_vector(7 downto 0) := X"51";
constant R        : std_logic_vector(7 downto 0) := X"52";
constant S        : std_logic_vector(7 downto 0) := X"53";
constant T        : std_logic_vector(7 downto 0) := X"54";
constant U        : std_logic_vector(7 downto 0) := X"55";
constant V        : std_logic_vector(7 downto 0) := X"56";
constant W        : std_logic_vector(7 downto 0) := X"57";
constant eX       : std_logic_vector(7 downto 0) := X"58";
constant Y        : std_logic_vector(7 downto 0) := X"59";
constant Z        : std_logic_vector(7 downto 0) := X"5A";
constant Space    : std_logic_vector(7 downto 0) := X"20";
constant Dot      : std_logic_vector(7 downto 0) := X"2E";

constant Zero     : std_logic_vector(7 downto 0) := X"30";
constant One      : std_logic_vector(7 downto 0) := X"31";
constant Two      : std_logic_vector(7 downto 0) := X"32";
constant Three    : std_logic_vector(7 downto 0) := X"33";
constant Four     : std_logic_vector(7 downto 0) := X"34";
constant Five     : std_logic_vector(7 downto 0) := X"35";
constant Six      : std_logic_vector(7 downto 0) := X"36";
constant Seven    : std_logic_vector(7 downto 0) := X"37";
constant Eight    : std_logic_vector(7 downto 0) := X"38";
constant Nine     : std_logic_vector(7 downto 0) := X"39";

signal Main_Mux_Version_Name_i     : std_logic_vector(255 downto 0); 
signal Main_Mux_Version_Number_i   : std_logic_vector(63 downto 0);  

function reverse_any_bus (a : in std_logic_vector)
return std_logic_vector is
      variable result   :    std_logic_vector(a'range);
      alias aa          :    std_logic_vector(a'reverse_range) is a;
      begin
         for i in aa'range loop
            result(i) := aa(i);
            end loop;
            return result;
end;  -- function reverse_any_bus

begin

UART_TXD     	           <= SerDataOut;
Ana_In_Request           <= Ana_In_Request_i;
Dig_In_Request           <= Dig_In_Request_i;
Dig_Out_Request          <= Dig_Out_Request_i;
Version_Name_i           <= Version_Name;
Version_Number_i         <= Version_Number;

-- Build message
  gen_tx_ser_data : process (CLK_I, RST_I)
  
  variable Delay            : integer range 0 to 50;
  variable Request_Data_cnt : integer range 0 to 5000001;

  begin
    if RST_I = '0' then
      data2send                    <= (others => (others => '0'));
      CRC2send                     <= (others => (others => '0'));
      no_of_chars2send             <= 0;
      send_msg                     <= '0';
      Message_done                 <= '0';
      Dig_Card1_1_B0_i       <= (others => '0');
      Dig_Card1_1_B1_i       <= (others => '0');
      Dig_Card1_1_B2_i       <= (others => '0');
      Dig_Card1_1_B3_i       <= (others => '0');
      Dig_Card1_1_B4_i       <= (others => '0');
      Dig_Card1_1_B5_i       <= (others => '0');
      Dig_Card1_1_B6_i       <= (others => '0');
      Dig_Card1_1_B7_i       <= (others => '0');
      Dig_Card1_2_B0_i       <= (others => '0');
      Dig_Card1_2_B1_i       <= (others => '0');
      Dig_Card1_2_B2_i       <= (others => '0');
      Dig_Card1_2_B3_i       <= (others => '0');
      Dig_Card1_2_B4_i       <= (others => '0');
      Dig_Card1_2_B5_i       <= (others => '0');
      Dig_Card1_2_B6_i       <= (others => '0');
      Dig_Card1_2_B7_i       <= (others => '0');
      Alg_Card1_1_B0_i       <= (others => '0');
      Alg_Card1_1_B1_i       <= (others => '0');        
      Alg_Card1_2_B0_i       <= (others => '0');
      Alg_Card1_2_B1_i       <= (others => '0');               
      Alg_Card1_3_B0_i       <= (others => '0');
      Alg_Card1_3_B1_i       <= (others => '0');
      Alg_Card1_4_B0_i       <= (others => '0');       
      Alg_Card1_4_B1_i       <= (others => '0');      
      Alg_Card1_5_B0_i       <= (others => '0');
      Alg_Card1_5_B1_i       <= (others => '0');
      Alg_Card1_6_B0_i       <= (others => '0');
      Alg_Card1_6_B1_i       <= (others => '0');
      Alg_Card1_7_B0_i       <= (others => '0');
      Alg_Card1_7_B1_i       <= (others => '0');       
      Alg_Card1_8_B0_i       <= (others => '0');
      Alg_Card1_8_B1_i       <= (others => '0');                
      Alg_Card1_9_B0_i       <= (others => '0');
      Alg_Card1_9_B1_i       <= (others => '0');
      Alg_Card1_10_B0_i      <= (others => '0');       
      Alg_Card1_10_B1_i      <= (others => '0');     
      Alg_Card1_11_B0_i      <= (others => '0');
      Alg_Card1_11_B1_i      <= (others => '0');
      Alg_Card1_12_B0_i      <= (others => '0');
      Alg_Card1_12_B1_i      <= (others => '0');
      Alg_Card1_13_B0_i      <= (others => '0');
      Alg_Card1_13_B1_i      <= (others => '0');      
      Alg_Card1_14_B0_i      <= (others => '0');
      Alg_Card1_14_B1_i      <= (others => '0');               
      Alg_Card1_15_B0_i      <= (others => '0');
      Alg_Card1_15_B1_i      <= (others => '0');
      Alg_Card1_16_B0_i      <= (others => '0');        
      Alg_Card1_16_B1_i      <= (others => '0');       
      Alg_Card1_17_B0_i      <= (others => '0');
      Alg_Card1_17_B1_i      <= (others => '0');
      Alg_Card1_18_B0_i      <= (others => '0');
      Alg_Card1_18_B1_i      <= (others => '0');
      Alg_Card1_19_B0_i      <= (others => '0');
      Alg_Card1_19_B1_i      <= (others => '0');        
      Alg_Card1_20_B0_i      <= (others => '0');
      Alg_Card1_20_B1_i      <= (others => '0');                
      Alg_Card1_21_B0_i      <= (others => '0');
      Alg_Card1_21_B1_i      <= (others => '0');
      Alg_Card1_22_B0_i      <= (others => '0');       
      Alg_Card1_22_B1_i      <= (others => '0');       
      Alg_Card1_23_B0_i      <= (others => '0');
      Alg_Card1_23_B1_i      <= (others => '0');
      Alg_Card1_24_B0_i      <= (others => '0');
      Alg_Card1_24_B1_i      <= (others => '0');
      Alg_Card1_25_B0_i      <= (others => '0');
      Alg_Card1_25_B1_i      <= (others => '0');        
      Alg_Card1_26_B0_i      <= (others => '0');
      Alg_Card1_26_B1_i      <= (others => '0');               
      Alg_Card1_27_B0_i      <= (others => '0');
      Alg_Card1_27_B1_i      <= (others => '0');
      Alg_Card1_28_B0_i      <= (others => '0');        
      Alg_Card1_28_B1_i      <= (others => '0');        
      Alg_Card1_29_B0_i      <= (others => '0');
      Alg_Card1_29_B1_i      <= (others => '0');
      Alg_Card1_30_B0_i      <= (others => '0');
      Alg_Card1_30_B1_i      <= (others => '0');
      Alg_Card1_31_B0_i      <= (others => '0');
      Alg_Card1_31_B1_i      <= (others => '0');        
      Alg_Card1_32_B0_i      <= (others => '0');
      Alg_Card1_32_B1_i      <= (others => '0');                
      Alg_Card1_33_B0_i      <= (others => '0');
      Alg_Card1_33_B1_i      <= (others => '0');
      Alg_Card1_34_B0_i      <= (others => '0');        
      Alg_Card1_34_B1_i      <= (others => '0');        
      Alg_Card1_35_B0_i      <= (others => '0');
      Alg_Card1_35_B1_i      <= (others => '0');
      Alg_Card1_36_B0_i      <= (others => '0');
      Alg_Card1_36_B1_i      <= (others => '0');
      Alg_Card1_37_B0_i      <= (others => '0');
      Alg_Card1_37_B1_i      <= (others => '0');        
      Alg_Card1_38_B0_i      <= (others => '0');
      Alg_Card1_38_B1_i      <= (others => '0');                
      Alg_Card1_39_B0_i      <= (others => '0');
      Alg_Card1_39_B1_i      <= (others => '0');
      Alg_Card1_40_B0_i      <= (others => '0');        
      Alg_Card1_40_B1_i      <= (others => '0');        
      Alg_Card1_41_B0_i      <= (others => '0');
      Alg_Card1_41_B1_i      <= (others => '0');
      Alg_Card1_42_B0_i      <= (others => '0');
      Alg_Card1_42_B1_i      <= (others => '0');
      Alg_Card1_43_B0_i      <= (others => '0');
      Alg_Card1_43_B1_i      <= (others => '0');        
      Alg_Card1_44_B0_i      <= (others => '0');
      Alg_Card1_44_B1_i      <= (others => '0');                
      Alg_Card1_45_B0_i      <= (others => '0');
      Alg_Card1_45_B1_i      <= (others => '0');
      Alg_Card1_46_B0_i      <= (others => '0');       
      Alg_Card1_46_B1_i      <= (others => '0');       
      Alg_Card1_47_B0_i      <= (others => '0');
      Alg_Card1_47_B1_i      <= (others => '0');
      Alg_Card1_48_B0_i      <= (others => '0');
      Alg_Card1_48_B1_i      <= (others => '0');
      Send_100mS_Data            <= '0';    
      Stack_100mS_Data           <= '0';
      Dig_In_Request_i           <= '0';
      Dig_Out_Request_i          <= '0';
      Ana_In_Request_i           <= '0';
      Digital_Output_Ready       <= '0';
      Digital_Input_Ready        <= '0';
      Analog_Input_Ready         <= '0';
      All_Modules_Ready          <= '0';
      All_Modules_Trig           <= '0';
      Lockout                    <= '0';
      Send_Operation             <= '0';
      Request_Data_cnt           := 0;
      Request_Data_Strobe        <= '0'; 
      Send_Data_Strobe           <= '0';
      Send_Version_Data_Mess     <= '0';
      Send_Version_Data          <= '0';
      Stack_Version_Data         <= '0';
      Version_Data_Request       <= '0';
      Main_Mux_Version_Name      <= (others => '0');
      Main_Mux_Version_Name_i    <= (others => '0');
      Main_Mux_Version_Number    <= (others => '0'); 
      Main_Mux_Version_Number_i  <= (others => '0');
      Main_Mux_Version_Ready     <= '0';  
            report "The version number of Main_Mux is 1.3." severity note;  
    elsif CLK_I'event and CLK_I = '1' then

      Main_Mux_Version_Name_i    <= M & A & I & N & Space & M & U & eX & Space & Space &
                                    Space & Space & Space & Space & Space & Space & Space & Space &
                                    Space & Space & Space & Space & Space & Space & Space &
                                    Space & Space & Space & Space & Space & Space & Space;
      Main_Mux_Version_Number_i  <= Zero & Zero & Dot & Zero & One  & Dot & Zero & Three;  
      
      if Module_Number = X"00000008" then
         if Main_Mux_Version_Request = '1' then
            Main_Mux_Version_Ready    <= '1';
            Main_Mux_Version_Name     <= Main_Mux_Version_Name_i;
            Main_Mux_Version_Number   <= Main_Mux_Version_Number_i;  
         else
            Main_Mux_Version_Ready <= '0';
         end if;
      else   
          Main_Mux_Version_Ready <= '0'; 
      end if; 
    
      Time_Stamp_Byte_3_i      <= Timer_Sec_Reg_1(31 downto 24);
      Time_Stamp_Byte_2_i      <= Timer_Sec_Reg_1(23 downto 16);
      Time_Stamp_Byte_1_i      <= Timer_Sec_Reg_1(15 downto 8);
      Time_Stamp_Byte_0_i      <= Timer_Sec_Reg_1(7 downto 0);
      Dig_MilliSecond_B1_i     <= Timer_mSec_Reg_1(15 downto 8);
      Dig_MilliSecond_B0_i     <= Timer_mSec_Reg_1(7 downto 0);    

-- Modules Request Generator    
      --100mS
      if Request_Data_cnt = 5000 then  -- 100 ms Retrieve 000
         Send_Data_Strobe    <= '1';                  
         Request_Data_cnt    := 0;
      elsif Request_Data_cnt = 4900 then -- 90 ms Retrieve 000
         Request_Data_Strobe <= '1';
         Request_Data_cnt    := Request_Data_cnt + 1;
      else
         Request_Data_Strobe <= '0'; 
         Send_Data_Strobe    <= '0'; 
         Request_Data_cnt    := Request_Data_cnt + 1;
      end if;                    
 
      if Request_Data_Strobe = '1' then
         Dig_In_Request_i      <= '1';  
         Dig_Out_Request_i     <= '1';
         Ana_In_Request_i      <= '1';
      else   
         Dig_In_Request_i      <= '0';  
         Dig_Out_Request_i     <= '0';  
         Ana_In_Request_i      <= '0';
      end if;  

      if Send_Data_Strobe = '1' then 
         All_Modules_Trig  <= '1';
      end if; 
                    
-- Digital Output Incoming Data Validity Generator
  
       if Digital_Output_Valid = '1' then
          Digital_Output_Ready <= '1';
          Dig_Card1_2_B0_i     <= Dig_Out_1_B0;
          Dig_Card1_2_B1_i     <= Dig_Out_1_B1;
          Dig_Card1_2_B2_i     <= Dig_Out_1_B2;
          Dig_Card1_2_B3_i     <= Dig_Out_1_B3;
          Dig_Card1_2_B4_i     <= Dig_Out_1_B4;
          Dig_Card1_2_B5_i     <= Dig_Out_1_B5;
          Dig_Card1_2_B6_i     <= Dig_Out_1_B6;
          Dig_Card1_2_B7_i     <= Dig_Out_1_B7;
       end if;   
       
-- Digital Input Data Validity Generator       
       if Digital_Input_Valid = '1' then
          Digital_Input_Ready  <= '1';
          Dig_Card1_1_B0_i     <= Dig_In_1_B0;
          Dig_Card1_1_B1_i     <= Dig_In_1_B1;
          Dig_Card1_1_B2_i     <= Dig_In_1_B2;
          Dig_Card1_1_B3_i     <= Dig_In_1_B3;
          Dig_Card1_1_B4_i     <= Dig_In_1_B4;
          Dig_Card1_1_B5_i     <= Dig_In_1_B5;
          Dig_Card1_1_B6_i     <= Dig_In_1_B6;
          Dig_Card1_1_B7_i     <= Dig_In_1_B7;
       end if; 
           
-- Analog Input Data Validity Generator
       
       if Analog_Input_Valid = '1' then
          Analog_Input_Ready_1 <= '1';  
          Alg_Card1_1_B0_i     <= Alg_Card1_1(15 downto 8);
          Alg_Card1_1_B1_i     <= Alg_Card1_1(7 downto 0);        
          Alg_Card1_2_B0_i     <= Alg_Card1_2(15 downto 8);
          Alg_Card1_2_B1_i     <= Alg_Card1_2(7 downto 0);               
          Alg_Card1_3_B0_i     <= Alg_Card1_3(15 downto 8);
          Alg_Card1_3_B1_i     <= Alg_Card1_3(7 downto 0);
          Alg_Card1_4_B0_i     <= Alg_Card1_4(15 downto 8);       
          Alg_Card1_4_B1_i     <= Alg_Card1_4(7 downto 0);      
          Alg_Card1_5_B0_i     <= Alg_Card1_5(15 downto 8);
          Alg_Card1_5_B1_i     <= Alg_Card1_5(7 downto 0);
          Alg_Card1_6_B0_i     <= Alg_Card1_6(15 downto 8);
          Alg_Card1_6_B1_i     <= Alg_Card1_6(7 downto 0);
          Alg_Card1_7_B0_i     <= Alg_Card1_7(15 downto 8);
          Alg_Card1_7_B1_i     <= Alg_Card1_7(7 downto 0);       
          Alg_Card1_8_B0_i     <= Alg_Card1_8(15 downto 8);
          Alg_Card1_8_B1_i     <= Alg_Card1_8(7 downto 0);                
          Alg_Card1_9_B0_i     <= Alg_Card1_9(15 downto 8);
          Alg_Card1_9_B1_i     <= Alg_Card1_9(7 downto 0);
          Alg_Card1_10_B0_i    <= Alg_Card1_10(15 downto 8);       
          Alg_Card1_10_B1_i    <= Alg_Card1_10(7 downto 0);     
          Alg_Card1_11_B0_i    <= Alg_Card1_11(15 downto 8);
          Alg_Card1_11_B1_i    <= Alg_Card1_11(7 downto 0);
          Alg_Card1_12_B0_i    <= Alg_Card1_12(15 downto 8);
          Alg_Card1_12_B1_i    <= Alg_Card1_12(7 downto 0);
          Alg_Card1_13_B0_i    <= Alg_Card1_13(15 downto 8);
          Alg_Card1_13_B1_i    <= Alg_Card1_13(7 downto 0);      
          Alg_Card1_14_B0_i    <= Alg_Card1_14(15 downto 8);
          Alg_Card1_14_B1_i    <= Alg_Card1_14(7 downto 0);               
          Alg_Card1_15_B0_i    <= Alg_Card1_15(15 downto 8);
          Alg_Card1_15_B1_i    <= Alg_Card1_15(7 downto 0);
          Alg_Card1_16_B0_i    <= Alg_Card1_16(15 downto 8);        
          Alg_Card1_16_B1_i    <= Alg_Card1_16(7 downto 0);       
          Alg_Card1_17_B0_i    <= Alg_Card1_17(15 downto 8);
          Alg_Card1_17_B1_i    <= Alg_Card1_17(7 downto 0);
          Alg_Card1_18_B0_i    <= Alg_Card1_18(15 downto 8);
          Alg_Card1_18_B1_i    <= Alg_Card1_18(7 downto 0);
          Alg_Card1_19_B0_i    <= Alg_Card1_19(15 downto 8);
          Alg_Card1_19_B1_i    <= Alg_Card1_19(7 downto 0);        
          Alg_Card1_20_B0_i    <= Alg_Card1_20(15 downto 8);
          Alg_Card1_20_B1_i    <= Alg_Card1_20(7 downto 0);                
          Alg_Card1_21_B0_i    <= Alg_Card1_21(15 downto 8);
          Alg_Card1_21_B1_i    <= Alg_Card1_21(7 downto 0);
          Alg_Card1_22_B0_i    <= Alg_Card1_22(15 downto 8);       
          Alg_Card1_22_B1_i    <= Alg_Card1_22(7 downto 0);       
          Alg_Card1_23_B0_i    <= Alg_Card1_23(15 downto 8);
          Alg_Card1_23_B1_i    <= Alg_Card1_23(7 downto 0);
          Alg_Card1_24_B0_i    <= Alg_Card1_24(15 downto 8);
          Alg_Card1_24_B1_i    <= Alg_Card1_24(7 downto 0);
          Alg_Card1_25_B0_i    <= Alg_Card1_25(15 downto 8);
          Alg_Card1_25_B1_i    <= Alg_Card1_25(7 downto 0);        
          Alg_Card1_26_B0_i    <= Alg_Card1_26(15 downto 8);
          Alg_Card1_26_B1_i    <= Alg_Card1_26(7 downto 0);               
          Alg_Card1_27_B0_i    <= Alg_Card1_27(15 downto 8);
          Alg_Card1_27_B1_i    <= Alg_Card1_27(7 downto 0);
          Alg_Card1_28_B0_i    <= Alg_Card1_28(15 downto 8);        
          Alg_Card1_28_B1_i    <= Alg_Card1_28(7 downto 0);        
          Alg_Card1_29_B0_i    <= Alg_Card1_29(15 downto 8);
          Alg_Card1_29_B1_i    <= Alg_Card1_29(7 downto 0);
          Alg_Card1_30_B0_i    <= Alg_Card1_30(15 downto 8);
          Alg_Card1_30_B1_i    <= Alg_Card1_30(7 downto 0);
          Alg_Card1_31_B0_i    <= Alg_Card1_31(15 downto 8);
          Alg_Card1_31_B1_i    <= Alg_Card1_31(7 downto 0);        
          Alg_Card1_32_B0_i    <= Alg_Card1_32(15 downto 8);
          Alg_Card1_32_B1_i    <= Alg_Card1_32(7 downto 0);                
          Alg_Card1_33_B0_i    <= Alg_Card1_33(15 downto 8);
          Alg_Card1_33_B1_i    <= Alg_Card1_33(7 downto 0);
          Alg_Card1_34_B0_i    <= Alg_Card1_34(15 downto 8);        
          Alg_Card1_34_B1_i    <= Alg_Card1_34(7 downto 0);        
          Alg_Card1_35_B0_i    <= Alg_Card1_35(15 downto 8);
          Alg_Card1_35_B1_i    <= Alg_Card1_35(7 downto 0);
          Alg_Card1_36_B0_i    <= Alg_Card1_36(15 downto 8);
          Alg_Card1_36_B1_i    <= Alg_Card1_36(7 downto 0);
          Alg_Card1_37_B0_i    <= Alg_Card1_37(15 downto 8);
          Alg_Card1_37_B1_i    <= Alg_Card1_37(7 downto 0);        
          Alg_Card1_38_B0_i    <= Alg_Card1_38(15 downto 8);
          Alg_Card1_38_B1_i    <= Alg_Card1_38(7 downto 0);                
          Alg_Card1_39_B0_i    <= Alg_Card1_39(15 downto 8);
          Alg_Card1_39_B1_i    <= Alg_Card1_39(7 downto 0);
          Alg_Card1_40_B0_i    <= Alg_Card1_40(15 downto 8);        
          Alg_Card1_40_B1_i    <= Alg_Card1_40(7 downto 0);        
          Alg_Card1_41_B0_i    <= Alg_Card1_41(15 downto 8);
          Alg_Card1_41_B1_i    <= Alg_Card1_41(7 downto 0);
          Alg_Card1_42_B0_i    <= Alg_Card1_42(15 downto 8);
          Alg_Card1_42_B1_i    <= Alg_Card1_42(7 downto 0);
          Alg_Card1_43_B0_i    <= Alg_Card1_43(15 downto 8);
          Alg_Card1_43_B1_i    <= Alg_Card1_43(7 downto 0);        
          Alg_Card1_44_B0_i    <= Alg_Card1_44(15 downto 8);
          Alg_Card1_44_B1_i    <= Alg_Card1_44(7 downto 0);                
          Alg_Card1_45_B0_i    <= Alg_Card1_45(15 downto 8);
          Alg_Card1_45_B1_i    <= Alg_Card1_45(7 downto 0);
          Alg_Card1_46_B0_i    <= Alg_Card1_46(15 downto 8);       
          Alg_Card1_46_B1_i    <= Alg_Card1_46(7 downto 0);       
          Alg_Card1_47_B0_i    <= Alg_Card1_47(15 downto 8);
          Alg_Card1_47_B1_i    <= Alg_Card1_47(7 downto 0);
          Alg_Card1_48_B0_i    <= Alg_Card1_48(15 downto 8);
          Alg_Card1_48_B1_i    <= Alg_Card1_48(7 downto 0); 
       else
          Analog_Input_Ready_1  <= '0';   
       end if;   
  
-- Main Data Ready Generator          
       if  (Digital_Output_Ready = '1') and (Digital_Input_Ready  = '1')
       and (Analog_Input_Ready_1 = '1') and (Analog_Input_Ready_2 = '1')
       then
          All_Modules_Ready    <= '1';
          Digital_Output_Ready <= '0';
          Digital_Input_Ready  <= '0';
          Analog_Input_Ready_1 <= '0';
          Analog_Input_Ready_2 <= '0';
       end if;                  	     

      if (All_Modules_Ready = '1') and (All_Modules_Trig = '1')then              
         All_Modules_Ready     <= '0';
         All_Modules_Trig      <= '0';
         Send_All_Modules      <= '1';
      else
         Send_All_Modules      <= '0';
      end if; 
       
-- Race Condition Management           
       if (Send_All_Modules = '0') and (Version_Data_Ready = '0') then
          All_Data_Ready        <= '0';
          Version_Data_Request <= '0';
       elsif (Send_All_Modules = '0') and (Version_Data_Ready = '0')then   
          All_Data_Ready        <= '0';
          Version_Data_Request <= '0';
       elsif (Send_All_Modules = '1') and (Version_Data_Ready = '0')then
          All_Data_Ready        <= '1';
          Version_Data_Request <= '0';
       elsif (Send_All_Modules = '1') and (Version_Data_Ready = '0')then
          All_Data_Ready        <= '1';
          Version_Data_Request <= '0';   
       elsif (Send_All_Modules = '0') and (Version_Data_Ready = '1')then
          All_Data_Ready        <= '0';
          Version_Data_Request <= '1';
       elsif (Send_All_Modules = '1') and (Version_Data_Ready = '1')then
          All_Data_Ready        <= '1';
          if Delay = 50 then  
             Delay                := 0;
             Version_Data_Request <= '1';
          else
             Delay                := Delay + 1;  
          end if;   
       elsif (Send_All_Modules = '1') and (Version_Data_Ready = '1')then
          
          if Delay = 50 then  
             Delay                 := 0;
             All_Data_Ready        <= '1';
             Delay                 := Delay + 1; 
          elsif Delay = 51 then 
             All_Data_Ready        <= '0';
             Delay                 := Delay + 1; 
          elsif Delay = 60 then   
             Version_Data_Request <= '1';
             Delay                 := Delay + 1; 
          elsif Delay = 61 then   
             Version_Data_Request <= '0';   
             Delay                 := Delay + 1;
          else
             Delay                 := Delay + 1;  
             All_Data_Ready        <= '0';
             Version_Data_Request <= '0'; 
          end if;   
        
       else
         All_Data_Ready        <= '0';
         Version_Data_Request <= '0';
       end if;
          
-- Timestamp and Stacking
	     if All_Data_Ready = '1' then              
          if (Busy = '1') then
             Stack_100mS_Data           <= '1';
             Send_100mS_Data            <= '1';
          else
             Send_100mS_Data            <= '1';
             Stack_100mS_Data           <= '0';
          end if;  
       end if;   
                       
       if Version_Data_Request = '1' then
          if (Busy = '1') then
             Stack_Version_Data     <= '1';
				     Send_Version_Data_Mess <= '1';
          else
             Send_Version_Data_Mess <= '1';
             Stack_Version_Data     <= '0';
          end if;  
       end if;  
    
-- Send when Not Busy       
       if (Busy = '0') and (Lockout = '0') then
          if Send_100mS_Data = '1' then
             Send_Operation               <= '1';
             Send_100mS_Data              <= '0';
             Lockout                      <= '1';
          elsif Send_Version_Data_Mess = '1' then
             Send_Version_Data     <= '1';
             Send_Version_Data_Mess <= '0';
             Lockout                      <= '1';   
          elsif (Send_100mS_Data = '1') and (Stack_100mS_Data = '1') then
             Send_Operation               <= '1';
             Stack_100mS_Data             <= '0';
             Lockout                      <= '1';   
          elsif (Send_Version_Data = '1') and (Stack_Version_Data = '1') then
             Send_Version_Data     <= '1';
             Stack_Version_Data    <= '0';
             Lockout               <= '1';     
          end if;
       end if;   
        
       if busy = '1' and Lockout = '1' then
          lockout <= '0';
       end if;               	
-----------------------------------------
-- Operation
-----------------------------------------

         if Send_Operation = '1' then
            Send_Operation   <= '0';
            send_msg         <= '1';
            data2send(0)     <= Preamble1;
            data2send(1)     <= Preamble2;
            data2send(2)     <= Preamble3;
            data2send(3)     <= X"82";        -- Length
            data2send(4)     <= X"80";        -- Mode
  -- DATA
            data2send(5)     <= Time_Stamp_Byte_3_i;
            data2send(6)     <= Time_Stamp_Byte_2_i;
            data2send(7)     <= Time_Stamp_Byte_1_i;
            data2send(8)     <= Time_Stamp_Byte_0_i;
            data2send(9)     <= Dig_MilliSecond_B1_i;
            data2send(10)    <= Dig_MilliSecond_B0_i;

   -- Output Card 1       
            data2send(11)    <= Output_Card_1;       -- SPI Out
            data2send(12)    <= Dig_Card1_2_B3_i;
            data2send(13)    <= Dig_Card1_2_B2_i;
            data2send(14)    <= Dig_Card1_2_B1_i;
            data2send(15)    <= Dig_Card1_2_B0_i;
   -- Output Card 2		  
            data2send(16)    <= Output_Card_2;       -- SPI Out
            data2send(17)    <= Dig_Card1_2_B7_i;
            data2send(18)    <= Dig_Card1_2_B6_i;
            data2send(19)    <= Dig_Card1_2_B5_i;
            data2send(20)    <= Dig_Card1_2_B4_i;		  
   -- Input card 1      
            data2send(21)    <= Input_Card_1;       -- SPI In   
            data2send(22)    <= Dig_Card1_1_B3_i;
            data2send(23)    <= Dig_Card1_1_B2_i;        
            data2send(24)    <= Dig_Card1_1_B1_i;        
            data2send(25)    <= Dig_Card1_1_B0_i;
   -- Input Card 2		  
            data2send(26)    <= Input_Card_2;       -- SPI In   
            data2send(27)    <= Dig_Card1_1_B7_i;
            data2send(28)    <= Dig_Card1_1_B6_i;              
            data2send(29)    <= Dig_Card1_1_B5_i;        
            data2send(30)    <= Dig_Card1_1_B4_i;		  
    -- Analog Card 1 
            data2send(31)    <= Analog_Card_1;       -- SPI ADC
            data2send(32)    <= Alg_Card1_1_B0_i;
            data2send(33)    <= Alg_Card1_1_B1_i;        
            data2send(34)    <= Alg_Card1_2_B0_i;
            data2send(35)    <= Alg_Card1_2_B1_i;                
            data2send(36)    <= Alg_Card1_3_B0_i;
            data2send(37)    <= Alg_Card1_3_B1_i;
            data2send(38)    <= Alg_Card1_4_B0_i;        
            data2send(39)    <= Alg_Card1_4_B1_i;        
            data2send(40)    <= Alg_Card1_5_B0_i;
            data2send(41)    <= Alg_Card1_5_B1_i;
            data2send(42)    <= Alg_Card1_6_B0_i;
            data2send(43)    <= Alg_Card1_6_B1_i;
            data2send(44)    <= Alg_Card1_7_B0_i;
            data2send(45)    <= Alg_Card1_7_B1_i;        
            data2send(46)    <= Alg_Card1_8_B0_i;
            data2send(47)    <= Alg_Card1_8_B1_i;                
            data2send(48)    <= Alg_Card1_9_B0_i;
            data2send(49)    <= Alg_Card1_9_B1_i;
            data2send(50)    <= Alg_Card1_10_B0_i;        
            data2send(51)    <= Alg_Card1_10_B1_i;        
            data2send(52)    <= Alg_Card1_11_B0_i;
            data2send(53)    <= Alg_Card1_11_B1_i;
            data2send(54)    <= Alg_Card1_12_B0_i;
            data2send(55)    <= Alg_Card1_12_B1_i;
            data2send(56)    <= Alg_Card1_13_B0_i;
            data2send(57)    <= Alg_Card1_13_B1_i;             
            data2send(58)    <= Alg_Card1_14_B0_i;
            data2send(59)    <= Alg_Card1_14_B1_i;                     
            data2send(60)    <= Alg_Card1_15_B0_i;
            data2send(61)    <= Alg_Card1_15_B1_i;
            data2send(62)    <= Alg_Card1_16_B0_i;             
            data2send(63)    <= Alg_Card1_16_B1_i;        
            data2send(64)    <= Alg_Card1_17_B0_i;
            data2send(65)    <= Alg_Card1_17_B1_i;
            data2send(66)    <= Alg_Card1_18_B0_i;
            data2send(67)    <= Alg_Card1_18_B1_i;
            data2send(68)    <= Alg_Card1_19_B0_i;
            data2send(69)    <= Alg_Card1_19_B1_i;             
            data2send(70)    <= Alg_Card1_20_B0_i;
            data2send(71)    <= Alg_Card1_20_B1_i;                
            data2send(72)    <= Alg_Card1_21_B0_i;
            data2send(73)    <= Alg_Card1_21_B1_i;
            data2send(74)    <= Alg_Card1_22_B0_i;             
            data2send(75)    <= Alg_Card1_22_B1_i;        
            data2send(76)    <= Alg_Card1_23_B0_i;
            data2send(77)    <= Alg_Card1_23_B1_i;
            data2send(78)    <= Alg_Card1_24_B0_i;
            data2send(79)    <= Alg_Card1_24_B1_i;              		  
            data2send(80)    <= Alg_Card1_25_B0_i;
            data2send(81)    <= Alg_Card1_25_B1_i;             
            data2send(82)    <= Alg_Card1_26_B0_i;
            data2send(83)    <= Alg_Card1_26_B1_i;                     
            data2send(84)    <= Alg_Card1_27_B0_i;
            data2send(85)    <= Alg_Card1_27_B1_i;
            data2send(86)    <= Alg_Card1_28_B0_i;             
            data2send(87)    <= Alg_Card1_28_B1_i;        
            data2send(88)    <= Alg_Card1_29_B0_i;
            data2send(89)    <= Alg_Card1_29_B1_i;
            data2send(90)    <= Alg_Card1_30_B0_i;
            data2send(91)    <= Alg_Card1_30_B1_i;
            data2send(92)    <= Alg_Card1_31_B0_i;
            data2send(93)    <= Alg_Card1_31_B1_i;             
            data2send(94)    <= Alg_Card1_32_B0_i;
            data2send(95)    <= Alg_Card1_32_B1_i;                     
            data2send(96)    <= Alg_Card1_33_B0_i;
            data2send(97)    <= Alg_Card1_33_B1_i;
            data2send(98)    <= Alg_Card1_34_B0_i;        
            data2send(99)    <= Alg_Card1_34_B1_i;        
            data2send(100)   <= Alg_Card1_35_B0_i;
            data2send(101)   <= Alg_Card1_35_B1_i;
            data2send(102)   <= Alg_Card1_36_B0_i;
            data2send(103)   <= Alg_Card1_36_B1_i;
            data2send(104)   <= Alg_Card1_37_B0_i;
            data2send(105)   <= Alg_Card1_37_B1_i;        
            data2send(106)   <= Alg_Card1_38_B0_i;
            data2send(107)   <= Alg_Card1_38_B1_i;                      
            data2send(108)   <= Alg_Card1_39_B0_i;
            data2send(109)   <= Alg_Card1_39_B1_i;
            data2send(110)   <= Alg_Card1_40_B0_i;        
            data2send(111)   <= Alg_Card1_40_B1_i;        
            data2send(112)   <= Alg_Card1_41_B0_i;
            data2send(113)   <= Alg_Card1_41_B1_i;
            data2send(114)   <= Alg_Card1_42_B0_i;
            data2send(115)   <= Alg_Card1_42_B1_i;
            data2send(116)   <= Alg_Card1_43_B0_i;
            data2send(117)   <= Alg_Card1_43_B1_i;             
            data2send(118)   <= Alg_Card1_44_B0_i;
            data2send(119)   <= Alg_Card1_44_B1_i;                
            data2send(120)   <= Alg_Card1_45_B0_i;
            data2send(121)   <= Alg_Card1_45_B1_i;
            data2send(122)   <= Alg_Card1_46_B0_i;        
            data2send(123)   <= Alg_Card1_46_B1_i;        
            data2send(124)   <= Alg_Card1_47_B0_i;
            data2send(125)   <= Alg_Card1_47_B1_i;
            data2send(126)   <= Alg_Card1_48_B0_i;
            data2send(127)   <= Alg_Card1_48_B1_i;
                   
            no_of_chars2send <= 130;         -- alway 3 more then last number

            CRC2send(0)      <= reverse_any_bus(Preamble1);
            CRC2send(1)      <= reverse_any_bus(Preamble2);
            CRC2send(2)      <= reverse_any_bus(Preamble3);
            CRC2send(3)      <= reverse_any_bus(X"82");
            CRC2send(4)      <= reverse_any_bus(X"80");
        
            CRC2send(5)      <= reverse_any_bus(Time_Stamp_Byte_3_i);
            CRC2send(6)      <= reverse_any_bus(Time_Stamp_Byte_2_i);
            CRC2send(7)      <= reverse_any_bus(Time_Stamp_Byte_1_i);
            CRC2send(8)      <= reverse_any_bus(Time_Stamp_Byte_0_i);
            CRC2send(9)      <= reverse_any_bus(Dig_MilliSecond_B1_i);
            CRC2send(10)     <= reverse_any_bus(Dig_MilliSecond_B0_i);

            CRC2send(11)     <= reverse_any_bus(Output_Card_1);
            CRC2send(12)     <= reverse_any_bus(Dig_Card1_2_B3_i);
            CRC2send(13)     <= reverse_any_bus(Dig_Card1_2_B2_i);
            CRC2send(14)     <= reverse_any_bus(Dig_Card1_2_B1_i);
            CRC2send(15)     <= reverse_any_bus(Dig_Card1_2_B0_i);

            CRC2send(16)     <= reverse_any_bus(Output_Card_2);        
            CRC2send(17)     <= reverse_any_bus(Dig_Card1_2_B7_i);
            CRC2send(18)     <= reverse_any_bus(Dig_Card1_2_B6_i);        
            CRC2send(19)     <= reverse_any_bus(Dig_Card1_2_B5_i);        
            CRC2send(20)     <= reverse_any_bus(Dig_Card1_2_B4_i);

            CRC2send(21)     <= reverse_any_bus(Input_Card_1);
            CRC2send(22)     <= reverse_any_bus(Dig_Card1_1_B3_i);
            CRC2send(23)     <= reverse_any_bus(Dig_Card1_1_B2_i);
            CRC2send(24)     <= reverse_any_bus(Dig_Card1_1_B1_i);
            CRC2send(25)     <= reverse_any_bus(Dig_Card1_1_B0_i);
      
            CRC2send(26)    <= reverse_any_bus(Input_Card_2);        
            CRC2send(27)    <= reverse_any_bus(Dig_Card1_1_B7_i);
            CRC2send(28)    <= reverse_any_bus(Dig_Card1_1_B6_i);        
            CRC2send(29)    <= reverse_any_bus(Dig_Card1_1_B5_i);        
            CRC2send(30)    <= reverse_any_bus(Dig_Card1_1_B4_i);
        
            CRC2send(31)    <= reverse_any_bus(Analog_Card_1);    
            CRC2send(32)    <= reverse_any_bus(Alg_Card1_1_B0_i); 
            CRC2send(33)    <= reverse_any_bus(Alg_Card1_1_B1_i);       
            CRC2send(34)    <= reverse_any_bus(Alg_Card1_2_B0_i);   
            CRC2send(35)    <= reverse_any_bus(Alg_Card1_2_B1_i);              
            CRC2send(36)    <= reverse_any_bus(Alg_Card1_3_B0_i);  
            CRC2send(37)    <= reverse_any_bus(Alg_Card1_3_B1_i);  
            CRC2send(38)    <= reverse_any_bus(Alg_Card1_4_B0_i);         
            CRC2send(39)    <= reverse_any_bus(Alg_Card1_4_B1_i);       
            CRC2send(40)    <= reverse_any_bus(Alg_Card1_5_B0_i);  
            CRC2send(41)    <= reverse_any_bus(Alg_Card1_5_B1_i);  
            CRC2send(42)    <= reverse_any_bus(Alg_Card1_6_B0_i);   
            CRC2send(43)    <= reverse_any_bus(Alg_Card1_6_B1_i);   
            CRC2send(44)    <= reverse_any_bus(Alg_Card1_7_B0_i);  
            CRC2send(45)    <= reverse_any_bus(Alg_Card1_7_B1_i);     
            CRC2send(46)    <= reverse_any_bus(Alg_Card1_8_B0_i);  
            CRC2send(47)    <= reverse_any_bus(Alg_Card1_8_B1_i);                
            CRC2send(48)    <= reverse_any_bus(Alg_Card1_9_B0_i);
            CRC2send(49)    <= reverse_any_bus(Alg_Card1_9_B1_i); 
            CRC2send(50)    <= reverse_any_bus(Alg_Card1_10_B0_i);      
            CRC2send(51)    <= reverse_any_bus(Alg_Card1_10_B1_i);      
            CRC2send(52)    <= reverse_any_bus(Alg_Card1_11_B0_i);
            CRC2send(53)    <= reverse_any_bus(Alg_Card1_11_B1_i);
            CRC2send(54)    <= reverse_any_bus(Alg_Card1_12_B0_i);
            CRC2send(55)    <= reverse_any_bus(Alg_Card1_12_B1_i);
            CRC2send(56)    <= reverse_any_bus(Alg_Card1_13_B0_i);
            CRC2send(57)    <= reverse_any_bus(Alg_Card1_13_B1_i);           
            CRC2send(58)    <= reverse_any_bus(Alg_Card1_14_B0_i);
            CRC2send(59)    <= reverse_any_bus(Alg_Card1_14_B1_i);                    
            CRC2send(60)    <= reverse_any_bus(Alg_Card1_15_B0_i);
            CRC2send(61)    <= reverse_any_bus(Alg_Card1_15_B1_i);
            CRC2send(62)    <= reverse_any_bus(Alg_Card1_16_B0_i);            
            CRC2send(63)    <= reverse_any_bus(Alg_Card1_16_B1_i);       
            CRC2send(64)    <= reverse_any_bus(Alg_Card1_17_B0_i);
            CRC2send(65)    <= reverse_any_bus(Alg_Card1_17_B1_i);
            CRC2send(66)    <= reverse_any_bus(Alg_Card1_18_B0_i);
            CRC2send(67)    <= reverse_any_bus(Alg_Card1_18_B1_i);
            CRC2send(68)    <= reverse_any_bus(Alg_Card1_19_B0_i);
            CRC2send(69)    <= reverse_any_bus(Alg_Card1_19_B1_i);            
            CRC2send(70)    <= reverse_any_bus(Alg_Card1_20_B0_i);
            CRC2send(71)    <= reverse_any_bus(Alg_Card1_20_B1_i);               
            CRC2send(72)    <= reverse_any_bus(Alg_Card1_21_B0_i);
            CRC2send(73)    <= reverse_any_bus(Alg_Card1_21_B1_i);
            CRC2send(74)    <= reverse_any_bus(Alg_Card1_22_B0_i);          
            CRC2send(75)    <= reverse_any_bus(Alg_Card1_22_B1_i);       
            CRC2send(76)    <= reverse_any_bus(Alg_Card1_23_B0_i);
            CRC2send(77)    <= reverse_any_bus(Alg_Card1_23_B1_i);
            CRC2send(78)    <= reverse_any_bus(Alg_Card1_24_B0_i);
            CRC2send(79)    <= reverse_any_bus(Alg_Card1_24_B1_i);
            CRC2send(80)    <= reverse_any_bus(Alg_Card1_25_B0_i);
            CRC2send(81)    <= reverse_any_bus(Alg_Card1_25_B1_i);       
            CRC2send(82)    <= reverse_any_bus(Alg_Card1_26_B0_i);
            CRC2send(83)    <= reverse_any_bus(Alg_Card1_26_B1_i);               
            CRC2send(84)    <= reverse_any_bus(Alg_Card1_27_B0_i);
            CRC2send(85)    <= reverse_any_bus(Alg_Card1_27_B1_i);
            CRC2send(86)    <= reverse_any_bus(Alg_Card1_28_B0_i);       
            CRC2send(87)    <= reverse_any_bus(Alg_Card1_28_B1_i);       
            CRC2send(88)    <= reverse_any_bus(Alg_Card1_29_B0_i);
            CRC2send(89)    <= reverse_any_bus(Alg_Card1_29_B1_i);
            CRC2send(90)    <= reverse_any_bus(Alg_Card1_30_B0_i);
            CRC2send(91)    <= reverse_any_bus(Alg_Card1_30_B1_i);
            CRC2send(92)    <= reverse_any_bus(Alg_Card1_31_B0_i);
            CRC2send(93)    <= reverse_any_bus(Alg_Card1_31_B1_i);     
            CRC2send(94)    <= reverse_any_bus(Alg_Card1_32_B0_i);
            CRC2send(95)    <= reverse_any_bus(Alg_Card1_32_B1_i);               
            CRC2send(96)    <= reverse_any_bus(Alg_Card1_33_B0_i);
            CRC2send(97)    <= reverse_any_bus(Alg_Card1_33_B1_i);
            CRC2send(98)    <= reverse_any_bus(Alg_Card1_34_B0_i);       
            CRC2send(99)    <= reverse_any_bus(Alg_Card1_34_B1_i);      
            CRC2send(100)   <= reverse_any_bus(Alg_Card1_35_B0_i);
            CRC2send(101)   <= reverse_any_bus(Alg_Card1_35_B1_i);
            CRC2send(102)   <= reverse_any_bus(Alg_Card1_36_B0_i);
            CRC2send(103)   <= reverse_any_bus(Alg_Card1_36_B1_i);
            CRC2send(104)   <= reverse_any_bus(Alg_Card1_37_B0_i);
            CRC2send(105)   <= reverse_any_bus(Alg_Card1_37_B1_i);           
            CRC2send(106)   <= reverse_any_bus(Alg_Card1_38_B0_i);
            CRC2send(107)   <= reverse_any_bus(Alg_Card1_38_B1_i);                    
            CRC2send(108)   <= reverse_any_bus(Alg_Card1_39_B0_i);
            CRC2send(109)   <= reverse_any_bus(Alg_Card1_39_B1_i);
            CRC2send(110)   <= reverse_any_bus(Alg_Card1_40_B0_i);            
            CRC2send(111)   <= reverse_any_bus(Alg_Card1_40_B1_i);       
            CRC2send(112)   <= reverse_any_bus(Alg_Card1_41_B0_i);
            CRC2send(113)   <= reverse_any_bus(Alg_Card1_41_B1_i);
            CRC2send(114)   <= reverse_any_bus(Alg_Card1_42_B0_i);
            CRC2send(115)   <= reverse_any_bus(Alg_Card1_42_B1_i);
            CRC2send(116)   <= reverse_any_bus(Alg_Card1_43_B0_i);
            CRC2send(117)   <= reverse_any_bus(Alg_Card1_43_B1_i);            
            CRC2send(118)   <= reverse_any_bus(Alg_Card1_44_B0_i);
            CRC2send(119)   <= reverse_any_bus(Alg_Card1_44_B1_i);               
            CRC2send(120)   <= reverse_any_bus(Alg_Card1_45_B0_i);
            CRC2send(121)   <= reverse_any_bus(Alg_Card1_45_B1_i);
            CRC2send(122)   <= reverse_any_bus(Alg_Card1_46_B0_i);       
            CRC2send(123)   <= reverse_any_bus(Alg_Card1_46_B1_i);      
            CRC2send(124)   <= reverse_any_bus(Alg_Card1_47_B0_i);
            CRC2send(125)   <= reverse_any_bus(Alg_Card1_47_B1_i);
            CRC2send(126)   <= reverse_any_bus(Alg_Card1_48_B0_i);
            CRC2send(127)   <= reverse_any_bus(Alg_Card1_48_B1_i);
           
         elsif Send_Version_Data = '1' then
            Send_Version_Data <= '0';
            send_msg          <= '1';
            data2send(0)      <= Preamble1;
            data2send(1)      <= Preamble2;
            data2send(2)      <= Preamble3;
            data2send(3)      <= X"2f";        -- Length
            data2send(4)      <= X"80";        -- Mode

  -- Noise Diode Version Data
            data2send(5)      <= Version_Name_i(255 downto 248);
            data2send(6)      <= Version_Name_i(247 downto 240);
            data2send(7)      <= Version_Name_i(239 downto 232);
            data2send(8)      <= Version_Name_i(231 downto 224);
            data2send(9)      <= Version_Name_i(223 downto 216);
            data2send(10)     <= Version_Name_i(215 downto 208);
            data2send(11)     <= Version_Name_i(207 downto 200);
            data2send(12)     <= Version_Name_i(199 downto 192);
            data2send(13)     <= Version_Name_i(191 downto 184);
            data2send(14)     <= Version_Name_i(183 downto 176);
            data2send(15)     <= Version_Name_i(175 downto 168);
            data2send(16)     <= Version_Name_i(167 downto 160);
            data2send(17)     <= Version_Name_i(159 downto 152);
            data2send(18)     <= Version_Name_i(151 downto 144);
            data2send(19)     <= Version_Name_i(143 downto 136);
            data2send(20)     <= Version_Name_i(135 downto 128);
            data2send(21)     <= Version_Name_i(127 downto 120);
            data2send(22)     <= Version_Name_i(119 downto 112);
            data2send(23)     <= Version_Name_i(111 downto 104);
            data2send(24)     <= Version_Name_i(103 downto 96);
            data2send(25)     <= Version_Name_i(95 downto 88);
            data2send(26)     <= Version_Name_i(87 downto 80);
            data2send(27)     <= Version_Name_i(79 downto 72);    
            data2send(28)     <= Version_Name_i(71 downto 64);
            data2send(29)     <= Version_Name_i(63 downto 56);
            data2send(30)     <= Version_Name_i(55 downto 48);
            data2send(31)     <= Version_Name_i(47 downto 40);
            data2send(32)     <= Version_Name_i(39 downto 32);
            data2send(33)     <= Version_Name_i(31 downto 24);
            data2send(34)     <= Version_Name_i(23 downto 16);
            data2send(35)     <= Version_Name_i(15 downto 8);
            data2send(36)     <= Version_Name_i(7 downto 0);
            data2send(37)     <= Version_Number_i(63 downto 56);
            data2send(38)     <= Version_Number_i(55 downto 48);
            data2send(39)     <= Version_Number_i(47 downto 40);
            data2send(40)     <= Version_Number_i(39 downto 32);
            data2send(41)     <= Version_Number_i(31 downto 24);
            data2send(42)     <= Version_Number_i(23 downto 16);
            data2send(43)     <= Version_Number_i(15 downto 8);
            data2send(44)     <= Version_Number_i(7 downto 0);
                       
            no_of_chars2send  <= 47;         -- alway 3 more then last number

            CRC2send(0)       <= reverse_any_bus(Preamble1);
            CRC2send(1)       <= reverse_any_bus(Preamble2);
            CRC2send(2)       <= reverse_any_bus(Preamble3);
            CRC2send(3)       <= reverse_any_bus(X"2f");
            CRC2send(4)       <= reverse_any_bus(X"80");
        
            CRC2send(5)       <= reverse_any_bus(Version_Name_i(255 downto 248));
            CRC2send(6)       <= reverse_any_bus(Version_Name_i(247 downto 240));
            CRC2send(7)       <= reverse_any_bus(Version_Name_i(239 downto 232));
            CRC2send(8)       <= reverse_any_bus(Version_Name_i(231 downto 224));
            CRC2send(9)       <= reverse_any_bus(Version_Name_i(223 downto 216));
            CRC2send(10)      <= reverse_any_bus(Version_Name_i(215 downto 208));
            CRC2send(11)      <= reverse_any_bus(Version_Name_i(207 downto 200));
            CRC2send(12)      <= reverse_any_bus(Version_Name_i(199 downto 192));
            CRC2send(13)      <= reverse_any_bus(Version_Name_i(191 downto 184));
            CRC2send(14)      <= reverse_any_bus(Version_Name_i(183 downto 176));
            CRC2send(15)      <= reverse_any_bus(Version_Name_i(175 downto 168));
            CRC2send(16)      <= reverse_any_bus(Version_Name_i(167 downto 160));
            CRC2send(17)      <= reverse_any_bus(Version_Name_i(159 downto 152));
            CRC2send(18)      <= reverse_any_bus(Version_Name_i(151 downto 144));
            CRC2send(19)      <= reverse_any_bus(Version_Name_i(143 downto 136));
            CRC2send(20)      <= reverse_any_bus(Version_Name_i(135 downto 128));
            CRC2send(21)      <= reverse_any_bus(Version_Name_i(127 downto 120));
            CRC2send(22)      <= reverse_any_bus(Version_Name_i(119 downto 112));
            CRC2send(23)      <= reverse_any_bus(Version_Name_i(111 downto 104));
            CRC2send(24)      <= reverse_any_bus(Version_Name_i(103 downto 96));
            CRC2send(25)      <= reverse_any_bus(Version_Name_i(95 downto 88));
            CRC2send(26)      <= reverse_any_bus(Version_Name_i(87 downto 80));
            CRC2send(27)      <= reverse_any_bus(Version_Name_i(79 downto 72));    
            CRC2send(28)      <= reverse_any_bus(Version_Name_i(71 downto 64));
            CRC2send(29)      <= reverse_any_bus(Version_Name_i(63 downto 56));
            CRC2send(30)      <= reverse_any_bus(Version_Name_i(55 downto 48));
            CRC2send(31)      <= reverse_any_bus(Version_Name_i(47 downto 40));
            CRC2send(32)      <= reverse_any_bus(Version_Name_i(39 downto 32));
            CRC2send(33)      <= reverse_any_bus(Version_Name_i(31 downto 24));
            CRC2send(34)      <= reverse_any_bus(Version_Name_i(23 downto 16));
            CRC2send(35)      <= reverse_any_bus(Version_Name_i(15 downto 8));
            CRC2send(36)      <= reverse_any_bus(Version_Name_i(7 downto 0));
            CRC2send(37)      <= reverse_any_bus(Version_Number_i(63 downto 56));
            CRC2send(38)      <= reverse_any_bus(Version_Number_i(55 downto 48));
            CRC2send(39)      <= reverse_any_bus(Version_Number_i(47 downto 40));
            CRC2send(40)      <= reverse_any_bus(Version_Number_i(39 downto 32));
            CRC2send(41)      <= reverse_any_bus(Version_Number_i(31 downto 24));
            CRC2send(42)      <= reverse_any_bus(Version_Number_i(23 downto 16));
            CRC2send(43)      <= reverse_any_bus(Version_Number_i(15 downto 8));
            CRC2send(44)      <= reverse_any_bus(Version_Number_i(7 downto 0));
      else
        send_msg        <= '0';
        Message_done    <= '0';
      end if;
              
      if add_crc = '1' then
         data2send(no_of_chars2send - 2) <= CRC_Sum(15 downto 8);
         data2send(no_of_chars2send - 1) <= CRC_Sum(7 downto 0);
      end if;

    end if;
  end process gen_tx_ser_data;

  --Send message out

  uart_tx : process (CLK_I, RST_I)

    variable tx_counter  : integer range 0 to 15;
    variable bit_counter : integer range 0 to 8;
    variable tx_en       : std_logic;
    variable Wait_cnt    : integer range 0 to 50;
  begin
    if RST_I = '0' then
      tx_state      <= idle;
      tx_counter    := 0;
      SerDataOut    <= '1';             --idle
      CRCSerDataOut <= '1';
      bit_counter   := 0;
      tx_en         := '0';
      no_of_chars   <= 0;
      busy          <= '0';
      Busy_Latch    <= '0';
      done          <= '0';
      comms_done    <= '0';
      X             <= (others => '1');
      add_crc       <= '0';
      Wait_cnt      := 0;
      crc16_ready   <= '0';
      SerData_Byte  <= (others => '0');
      flag_WD       <= '0';
      Mux_watchdog  <= '0';
      
    elsif CLK_I'event and CLK_I = '1' then

      if Baud_Rate_Enable = '1' then  
         tx_en := '1';
      else
         tx_en := '0';
      end if;
      
      if Watchdog_Reset = '1' then
         flag_WD <= '1';
      end if;
      
      if flag_WD = '1' then
         flag_WD <= '0';
         Mux_watchdog <= '1';
      else
         Mux_watchdog <= '0';
      end if; 

      case tx_state is

        when idle =>
          
             done       <= '0';
             comms_done <= '0';
             busy       <= '0';

             if send_msg = '1' then
                tx_state      <= sync;
                busy          <= '1';
                
                bit_counter   := 0;
                CRCSerDataOut <= '1';
                SerDataOut    <= '1';       --idle state on line
             else
                tx_state      <= idle;
             end if;

        when sync =>
             add_crc  <= '0';
             tx_state <= send_start;


        when send_start =>
             if tx_en = '1' then
                SerDataOut    <= '0';       --start bit
                CRCSerDataOut <= '0';
                tx_state      <= send_data;
             end if;

        when send_data =>
             crc16_ready       <= '0';
             if tx_en = '1' then
                if bit_counter = 8 then
                   bit_counter := 0;
                   tx_state      <= send_stop;
                   no_of_chars   <= no_of_chars + 1;
                   SerDataOut    <= '1';     --stop_bit
                   CRCSerDataOut <= '1';
                else
                   SerDataOut    <= data2send(no_of_chars)(bit_counter);
                   CRCSerDataOut <= CRC2send(no_of_chars)(bit_counter);
                   SerData_Byte  <= data2send(no_of_chars);
                   bit_counter   := bit_counter + 1;
                   tx_state      <= CRC_ready;
                   Wait_cnt      := 0;
                end if;
             end if;

        when CRC_ready =>
             if Wait_cnt = 30 then
                crc16_ready <= '1';
                tx_state    <= send_data;
             else
                wait_cnt := wait_cnt + 1;
             end if;

        when send_stop =>
             if tx_en = '1' then
                if no_of_chars = no_of_chars2send then
                   tx_state    <= idle;
                   no_of_chars <= 0;
                   done        <= '1';
                   comms_done  <= '1';
                   busy        <= '0';
                elsif no_of_chars = 3 then
                   tx_state    <= sync;
                   X           <= (others => '1');
                elsif no_of_chars = no_of_chars2send - 2 then
                   tx_state    <= sync;
                   add_crc     <= '1';
                else
                  tx_state    <= sync;
                  comms_done  <= '0';
                end if;
             end if;
        end case;

        if crc16_ready = '1' then
           X(0)  <= CRCSerDataOut xor X(15);   
           X(1)  <= X(0);
           X(2)  <= X(1);
           X(3)  <= X(2);
           X(4)  <= X(3);
           X(5)  <= X(4) xor CRCSerDataOut xor X(15);
           X(6)  <= X(5);
           X(7)  <= X(6);
           X(8)  <= X(7);
           X(9)  <= X(8);
           X(10) <= X(9);
           X(11) <= X(10);
           X(12) <= X(11) xor CRCSerDataOut xor X(15);
           X(13) <= X(12);
           X(14) <= X(13);
           X(15) <= X(14);
        end if;
        CRC_Sum  <= X;
    end if;
  end process uart_tx;


end Arch_DUT;


