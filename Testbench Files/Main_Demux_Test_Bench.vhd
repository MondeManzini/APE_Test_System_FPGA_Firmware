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

entity Main_Demux_Test_Bench is

end Main_Demux_Test_Bench;

architecture Archtest_bench of Main_Demux_Test_Bench is
	

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

-- Main Demux Signals and Component
-- Demux Signals and Component
signal Piter_to_RFC_UART_RXD_i  : std_logic;
signal Time_Stamp_Byte_3_i      : std_logic_vector(7 downto 0);
signal Time_Stamp_Byte_2_i      : std_logic_vector(7 downto 0);
signal Time_Stamp_Byte_1_i      : std_logic_vector(7 downto 0);
signal Time_Stamp_Byte_0_i      : std_logic_vector(7 downto 0);
signal Dig_MilliSecond_B1_i     : std_logic_vector(7 downto 0);
signal Dig_MilliSecond_B0_i     : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B0_i         : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B1_i         : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B2_i         : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B3_i         : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B4_i         : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B5_i         : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B6_i         : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B7_i         : std_logic_vector(7 downto 0);
signal Input_Source_i           : std_logic_vector(7 downto 0);
signal Freq_Source_i            : std_logic_vector(7 downto 0);
signal Header_1_i               : std_logic_vector(7 downto 0);
signal Header_2_i               : std_logic_vector(7 downto 0);
signal Header_3_i               : std_logic_vector(7 downto 0);
signal Mode_i                   : std_logic_vector(7 downto 0);
signal Message_length_i         : std_logic_vector(7 downto 0);
signal Valon_Data_i             : std_logic_vector(223 downto 0);
signal Main_Demux_Ver_Reg_i     : STD_LOGIC_VECTOR(63 downto 0);
signal Time_Stamp_Ready_i       : std_logic;
signal Dig_Outputs_Ready_i      : std_logic;
signal Valon_Data_Ready_i       : std_logic;
signal Noise_Diode_Ready_i      : std_logic;
signal Version_Data_Ready_i     : std_logic;
  
  component Main_Demux is
    port (
      Clk                 : in  std_logic;
      nrst                : in  std_logic;
      UART_RXD            : in  std_logic;
      Time_Stamp_Byte_3   : out std_logic_vector(7 downto 0);
      Time_Stamp_Byte_2   : out std_logic_vector(7 downto 0);
      Time_Stamp_Byte_1   : out std_logic_vector(7 downto 0);
      Time_Stamp_Byte_0   : out std_logic_vector(7 downto 0);
      Dig_MilliSecond_B1  : out std_logic_vector(7 downto 0);
      Dig_MilliSecond_B0  : out std_logic_vector(7 downto 0);
      Dig_Card1_1_B0      : out std_logic_vector(7 downto 0);
      Dig_Card1_1_B1      : out std_logic_vector(7 downto 0);
      Dig_Card1_1_B2      : out std_logic_vector(7 downto 0);
      Dig_Card1_1_B3      : out std_logic_vector(7 downto 0);
      Dig_Card1_1_B4      : out std_logic_vector(7 downto 0);
      Dig_Card1_1_B5      : out std_logic_vector(7 downto 0);
      Dig_Card1_1_B6      : out std_logic_vector(7 downto 0);
      Dig_Card1_1_B7      : out std_logic_vector(7 downto 0);
      Input_Source        : out std_logic_vector(7 downto 0);
      Freq_Source         : out std_logic_vector(7 downto 0);
      Header_1            : out std_logic_vector(7 downto 0);
      Header_2            : out std_logic_vector(7 downto 0);
      Header_3            : out std_logic_vector(7 downto 0);
      Mode                : out std_logic_vector(7 downto 0);
      Message_length      : out std_logic_vector(7 downto 0);
      Valon_Data          : out std_logic_vector(223 downto 0);
      Time_Stamp_Ready    : out std_logic;
      Dig_Outputs_Ready   : out std_logic;
      Valon_Data_Ready    : out std_logic;
      Noise_Diode_Ready   : out std_logic;
      Version_Data_Ready  : out std_logic
      );
  end component Main_Demux;


-------------------------------------------------------------------------------
-- New Code Signal and Components
------------------------------------------------------------------------------- 
signal RST_I_i                  : std_logic;
signal CLK_I_i                  : std_logic;

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

-- Build State

-- Time Stamp Messages

    -- Set time to 5 seconds
signal Time_Stamp_Message_5_Sec          : std_logic_vector(130 downto 0):=                                
                                    stop_bit & X"53" &                    -- CRC L
                                    start_bit & stop_bit & X"27" &        -- CRC H 
                                    start_bit & stop_bit & X"00" &        -- mSByte0 
                                    start_bit & stop_bit & X"00" &        -- mSByte1 
                                    start_bit & stop_bit & X"05" &        -- TmStmpByte0
                                    start_bit & stop_bit & X"00" &        -- TmStmpByte1
                                    start_bit & stop_bit & X"00" &        -- TmStmpByte2
                                    start_bit & stop_bit & X"00" &        -- TmStmpByte3
                                    start_bit & stop_bit & X"80" &        -- Mode
                                    start_bit & stop_bit & X"0D" &        -- Length
                                    start_bit & stop_bit & X"7E" &        -- Preamb1
                                    start_bit & stop_bit & X"5A" &        -- Preamb2
                                    start_bit & stop_bit & X"A5" & "01";  -- Preamb1

    -- Set time to 10 seconds
signal Time_Stamp_Message_10_Sec          : std_logic_vector(130 downto 0):=                                
                                    stop_bit & X"62" &                    -- CRC L
                                    start_bit & stop_bit & X"0b" &        -- CRC H 
                                    start_bit & stop_bit & X"00" &        -- mSByte0 
                                    start_bit & stop_bit & X"00" &        -- mSByte1 
                                    start_bit & stop_bit & X"0A" &        -- TmStmpByte0
                                    start_bit & stop_bit & X"00" &        -- TmStmpByte1
                                    start_bit & stop_bit & X"00" &        -- TmStmpByte2
                                    start_bit & stop_bit & X"00" &        -- TmStmpByte3
                                    start_bit & stop_bit & X"80" &        -- Mode
                                    start_bit & stop_bit & X"0D" &        -- Length
                                    start_bit & stop_bit & X"7E" &        -- Preamb1
                                    start_bit & stop_bit & X"5A" &        -- Preamb2
                                    start_bit & stop_bit & X"A5" & "01";  -- Preamb1                                    

    -- Set time to 3 hrs
signal Time_Stamp_Message_3_Hrs          : std_logic_vector(130 downto 0):=                                
                                    stop_bit & X"9c" &                    -- CRC L
                                    start_bit & stop_bit & X"ee" &        -- CRC H 
                                    start_bit & stop_bit & X"00" &        -- mSByte0 
                                    start_bit & stop_bit & X"00" &        -- mSByte1 
                                    start_bit & stop_bit & X"b4" &        -- TmStmpByte0
                                    start_bit & stop_bit & X"00" &        -- TmStmpByte1
                                    start_bit & stop_bit & X"00" &        -- TmStmpByte2
                                    start_bit & stop_bit & X"00" &        -- TmStmpByte3
                                    start_bit & stop_bit & X"80" &        -- Mode
                                    start_bit & stop_bit & X"0D" &        -- Length
                                    start_bit & stop_bit & X"7E" &        -- Preamb1
                                    start_bit & stop_bit & X"5A" &        -- Preamb2
                                    start_bit & stop_bit & X"A5" & "01";  -- Preamb1

-- Digital Output Messages

    -- All Off  
signal Dig_Out_Message_All_Off           : std_logic_vector(170 downto 0):=                                
                                    stop_bit & X"8e" &                    -- CRC L
                                    start_bit & stop_bit & X"fa" &        -- CRC H
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte7 
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte6
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte5
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte4
                                    start_bit & stop_bit & X"11" &        -- OutputCard2
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte3 
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte2
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte1
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte0
                                    start_bit & stop_bit & X"10" &        -- OutputCard1
                                    start_bit & stop_bit & X"81" &        -- Mode
                                    start_bit & stop_bit & X"0D" &        -- Length
                                    start_bit & stop_bit & X"7E" &        -- Preamb1
                                    start_bit & stop_bit & X"5A" &        -- Preamb2
                                    start_bit & stop_bit & X"A5" & "01";  -- Preamb1    

    -- All On 
signal Dig_Out_Message_All_On           : std_logic_vector(170 downto 0):=                                
                                    stop_bit & X"fd" &                    -- CRC L
                                    start_bit & stop_bit & X"8a" &        -- CRC H
                                    start_bit & stop_bit & X"ff" &        -- DigOut1Byte7 
                                    start_bit & stop_bit & X"ff" &        -- DigOut1Byte6
                                    start_bit & stop_bit & X"ff" &        -- DigOut1Byte5
                                    start_bit & stop_bit & X"ff" &        -- DigOut1Byte4
                                    start_bit & stop_bit & X"11" &        -- OutputCard2
                                    start_bit & stop_bit & X"ff" &        -- DigOut1Byte3 
                                    start_bit & stop_bit & X"ff" &        -- DigOut1Byte2
                                    start_bit & stop_bit & X"ff" &        -- DigOut1Byte1
                                    start_bit & stop_bit & X"ff" &        -- DigOut1Byte0
                                    start_bit & stop_bit & X"10" &        -- OutputCard1
                                    start_bit & stop_bit & X"81" &        -- Mode
                                    start_bit & stop_bit & X"0D" &        -- Length
                                    start_bit & stop_bit & X"7E" &        -- Preamb1
                                    start_bit & stop_bit & X"5A" &        -- Preamb2
                                    start_bit & stop_bit & X"A5" & "01";  -- Preamb1                                               

    -- On Off  
signal Dig_Out_Message_On_Off           : std_logic_vector(170 downto 0):=                                
                                    stop_bit & X"33" &                    -- CRC L
                                    start_bit & stop_bit & X"55" &        -- CRC H
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte7 
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte6
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte5
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte4
                                    start_bit & stop_bit & X"11" &        -- OutputCard2
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte3 
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte2
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte1
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte0
                                    start_bit & stop_bit & X"10" &        -- OutputCard1
                                    start_bit & stop_bit & X"81" &        -- Mode
                                    start_bit & stop_bit & X"0D" &        -- Length
                                    start_bit & stop_bit & X"7E" &        -- Preamb1
                                    start_bit & stop_bit & X"5A" &        -- Preamb2
                                    start_bit & stop_bit & X"A5" & "01";  -- Preamb1

    -- On Off  
signal Dig_Out_Message_Off_On           : std_logic_vector(170 downto 0):=                                
                                    stop_bit & X"40" &                    -- CRC L
                                    start_bit & stop_bit & X"25" &        -- CRC H
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte7 
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte6
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte5
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte4
                                    start_bit & stop_bit & X"11" &        -- OutputCard2
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte3 
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte2
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte1
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte0
                                    start_bit & stop_bit & X"10" &        -- OutputCard1
                                    start_bit & stop_bit & X"81" &        -- Mode
                                    start_bit & stop_bit & X"0D" &        -- Length
                                    start_bit & stop_bit & X"7E" &        -- Preamb1
                                    start_bit & stop_bit & X"5A" &        -- Preamb2
                                    start_bit & stop_bit & X"A5" & "01";  -- Preamb1                                    
                                                                          
                                                                          
-- Valon Messages
    -- Read Valon Frequency
signal get_ComPort_freq_0A        : std_logic_vector(100 downto 0):=                                
                                    stop_bit  &  X"08" &                  -- CRC L
                                    start_bit & stop_bit & X"68" &        -- CRC H
                                    start_bit & stop_bit & X"80" &        -- Mode
                                    start_bit & stop_bit & X"19" &        -- Mode       -- Mode
                                    start_bit & stop_bit & X"00" & 
                                    start_bit & stop_bit & X"84" &        -- Byte4 
                                    start_bit & stop_bit & X"0A" &        -- Length
                                    start_bit & stop_bit & X"7E" &        -- Preamb1
                                    start_bit & stop_bit & X"5A" &        -- Preamb2
                                    start_bit & stop_bit & X"A5" & "01";  -- Preamb1


    -- Set Valon Frequency to 2450 MHz                                  
signal set_ComPort_freq_0A2450      : std_logic_vector(350 downto 0):=                                
                                    stop_bit  & X"bd" &
                                    start_bit & stop_bit & X"db" &        -- Byte24 
                                    start_bit & stop_bit & X"26" &        -- Byte12
                                    start_bit & stop_bit & X"2E" &        -- Byte11 
                                    start_bit & stop_bit & X"13" &        -- Byte10 
                                    start_bit & stop_bit & X"05" &        -- Byte9
                                    start_bit & stop_bit & X"00" &        -- Byte12
                                    start_bit & stop_bit & X"48" &        -- Byte11 
                                    start_bit & stop_bit & X"08" &        -- Byte10 
                                    start_bit & stop_bit & X"3C" &        -- Byte9
                                    start_bit & stop_bit & X"04" &        -- Byte12
                                    start_bit & stop_bit & X"8A" &        -- Byte11 
                                    start_bit & stop_bit & X"00" &        -- Byte10 
                                    start_bit & stop_bit & X"0B" &        -- Byte9
                                    start_bit & stop_bit & X"00" &        -- Byte12
                                    start_bit & stop_bit & X"00" &        -- Byte11 
                                    start_bit & stop_bit & X"00" &        -- Byte10 
                                    start_bit & stop_bit & X"42" &        -- Byte9
                                    start_bit & stop_bit & X"4E" &        -- Byte12
                                    start_bit & stop_bit & X"00" &        -- Byte11 
                                    start_bit & stop_bit & X"1A" &        -- Byte10 
                                    start_bit & stop_bit & X"09" &        -- Byte9   
                                    start_bit & stop_bit & X"80" &        -- Byte12
                                    start_bit & stop_bit & X"00" &        -- Byte11 
                                    start_bit & stop_bit & X"08" &        -- Byte10 
                                    start_bit & stop_bit & X"00" &        -- Byte9 
                                    start_bit & stop_bit & X"80" &        -- Byte8
                                    start_bit & stop_bit & X"00" &        -- Byte7
                                    start_bit & stop_bit & X"01" &        -- Byte6 
                                    start_bit & stop_bit & X"00" &        -- Byte5 
                                    start_bit & stop_bit & X"84" &        -- Byte4 
                                    start_bit & stop_bit & X"23" &        -- Byte3
                                    start_bit & stop_bit & X"7E" &        -- Byte2
                                    start_bit & stop_bit & X"5A" &        -- Byte1
                                    start_bit & stop_bit & X"A5" &  "01";      -- Command                                                                        

 signal ComPort_Init           : std_logic_vector(160 downto 0):=
                                    stop_bit  & X"D2" &
                                    start_bit & stop_bit & X"F8" &        -- Byte24    
                                    start_bit & stop_bit & X"01" &        -- Byte12
                                    start_bit & stop_bit & X"00" &        -- Byte11 
                                    start_bit & stop_bit & X"01" &        -- Byte10 
                                    start_bit & stop_bit & X"00" &        -- Byte9 
                                    start_bit & stop_bit & X"08" &        -- Byte8
                                    start_bit & stop_bit & X"60" &        -- Byte7
                                    start_bit & stop_bit & X"00" &        -- Byte6 
                                    start_bit & stop_bit & X"FF" & 
                                    start_bit & stop_bit & X"00" &        -- Byte5 
                                    start_bit & stop_bit & X"86" &        -- Byte4 
                                    start_bit & stop_bit & X"10" &        -- Byte3
                                    start_bit & stop_bit & X"7E" &        -- Byte2
                                    start_bit & stop_bit & X"5A" &        -- Byte1
                                    start_bit & stop_bit & X"A5" &  "01";    

-- Valon Messages
    -- Enable Roach Source                                    
signal roach_set_noisediode_enable        : std_logic_vector(100 downto 0):=

                                    stop_bit & X"B3" &                    -- CRC L
                                    start_bit & stop_bit & X"4F" &        -- CRC H 
                                    start_bit & stop_bit & X"00" &        -- Freq_Byte
                                    start_bit & stop_bit & X"08" &        -- Input_Byte
                                    start_bit & stop_bit & X"40" &        -- Mode  
                                    start_bit & stop_bit & X"87" &        -- Noise_Mode
                                    start_bit & stop_bit & X"0A" &        -- Length
                                    start_bit & stop_bit & X"7E" &        -- Preamb1
                                    start_bit & stop_bit & X"5A" &        -- Preamb2
                                    start_bit & stop_bit & X"A5" & "01";  -- Preamb1

    -- Enable DBBC Source 
signal dbbc_set_noisediode_all_outputs        : std_logic_vector(100 downto 0):=

                                    stop_bit & X"10" &                    -- CRC L
                                    start_bit & stop_bit & X"3A" &        -- CRC H 
                                    start_bit & stop_bit & X"00" &        -- Freq_Byte
                                    start_bit & stop_bit & X"FA" &        -- Input_Byte
                                    start_bit & stop_bit & X"40" &        -- Noise_Mode  
                                    start_bit & stop_bit & X"87" &        -- Mode
                                    start_bit & stop_bit & X"0A" &        -- Length
                                    start_bit & stop_bit & X"7E" &        -- Preamb1
                                    start_bit & stop_bit & X"5A" &        -- Preamb2
                                    start_bit & stop_bit & X"A5" & "01";  -- Preamb1 

    -- Enable PC Source 
signal pc_set_noisediode_enable_pc_full_off        : std_logic_vector(100 downto 0):=

                                    stop_bit & X"E5" &                    -- CRC L
                                    start_bit & stop_bit & X"41" &        -- CRC H 
                                    start_bit & stop_bit & X"40" &        -- Freq_Byte
                                    start_bit & stop_bit & X"FB" &        -- Input_Byte
                                    start_bit & stop_bit & X"40" &        -- Noise_Mode  
                                    start_bit & stop_bit & X"87" &        -- Mode
                                    start_bit & stop_bit & X"0A" &        -- Length
                                    start_bit & stop_bit & X"7E" &        -- Preamb1
                                    start_bit & stop_bit & X"5A" &        -- Preamb2
                                    start_bit & stop_bit & X"A5" & "01";  -- Preamb1  
                                    
                                    -- Generate Version Data  
signal set_version_data        : std_logic_vector(70 downto 0):=
stop_bit  &            X"21" &        -- CRC L
start_bit & stop_bit & X"07" &        -- CRC H
start_bit & stop_bit & X"90" &        -- Mode
start_bit & stop_bit & X"07" &        -- Length
start_bit & stop_bit & X"7e" &        -- Preamb1
start_bit & stop_bit & X"5a" &        -- Preamb2
start_bit & stop_bit & X"a5" & "01";  -- Preamb1

begin
      
 RST_I_i         <= snrst;
 CLK_I_i         <= sClok;
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

-- Main Demux Instance
Main_Demux_1: entity work.Main_Demux
port map (
  Clk                  => CLK_I_i,
  nrst                 => RST_I_i,
  UART_RXD             => Piter_to_RFC_UART_RXD_i,
  Time_Stamp_Byte_3    => Time_Stamp_Byte_3_i,
  Time_Stamp_Byte_2    => Time_Stamp_Byte_2_i,
  Time_Stamp_Byte_1    => Time_Stamp_Byte_1_i,
  Time_Stamp_Byte_0    => Time_Stamp_Byte_0_i,
  Dig_MilliSecond_B1   => Dig_MilliSecond_B1_i,
  Dig_MilliSecond_B0   => Dig_MilliSecond_B0_i,
  Dig_Card1_1_B0       => Dig_Card1_1_B0_i,
  Dig_Card1_1_B1       => Dig_Card1_1_B1_i,
  Dig_Card1_1_B2       => Dig_Card1_1_B2_i,
  Dig_Card1_1_B3       => Dig_Card1_1_B3_i,
  Dig_Card1_1_B4       => Dig_Card1_1_B4_i,
  Dig_Card1_1_B5       => Dig_Card1_1_B5_i,
  Dig_Card1_1_B6       => Dig_Card1_1_B6_i,
  Dig_Card1_1_B7       => Dig_Card1_1_B7_i,
  Input_Source         => Input_Source_i,
  Freq_Source          => Freq_Source_i,
  Header_1             => Header_1_i,
  Header_2             => Header_2_i,
  Header_3             => Header_3_i,
  Mode                 => Mode_i,
  Message_length       => Message_Length_i,
  Valon_Data           => Valon_Data_i,
  Time_Stamp_Ready     => Time_Stamp_Ready_i,
  Dig_Outputs_Ready    => Dig_Outputs_Ready_i,
  Valon_Data_Ready     => Valon_Data_Ready_i,
  Version_Data_Ready   => Version_Data_Ready_i,
  Noise_Diode_Ready    => Noise_Diode_Ready_i
  );   
     
  get_ser_port_data: process
begin
--Build State

Piter_to_RFC_UART_RXD_i    <= '0';
  
      wait for 1 us;                          
      wait for 2 ms;

-- Time Stamp Messages
-- 5 Sec

           for i in 0 to 70 loop             
             Piter_to_RFC_UART_RXD_i  <= set_version_data(i); 
           wait for bit_time_115200;
           end loop;  -- i
      wait for 5 ms; 

-- 10 Sec

           for i in 0 to 130 loop             
             Piter_to_RFC_UART_RXD_i  <= Time_Stamp_Message_10_Sec(i); 
           wait for bit_time_115200;
           end loop;  -- i
      wait for 5 ms; 

-- 3 Hr

           for i in 0 to 130 loop             
             Piter_to_RFC_UART_RXD_i  <= Time_Stamp_Message_3_Hrs(i); 
           wait for bit_time_115200;
           end loop;  -- i
      wait for 5 ms;             

-- Digital Outputs
-- All Off
           for i in 0 to 170 loop             
             Piter_to_RFC_UART_RXD_i  <= Dig_Out_Message_All_Off(i); 
           wait for bit_time_115200;
           end loop;  -- i
      wait for 5 ms;     

-- All On
           for i in 0 to 170 loop             
             Piter_to_RFC_UART_RXD_i  <= Dig_Out_Message_All_On(i); 
           wait for bit_time_115200;
           end loop;  -- i
      wait for 5 ms;        

-- Off-On
           for i in 0 to 170 loop             
             Piter_to_RFC_UART_RXD_i  <= Dig_Out_Message_On_Off(i); 
           wait for bit_time_115200;
           end loop;  -- i
      wait for 5 ms;    

-- On-Off
           for i in 0 to 170 loop             
             Piter_to_RFC_UART_RXD_i  <= Dig_Out_Message_Off_On(i); 
           wait for bit_time_115200;
           end loop;  -- i
      wait for 5 ms;            
         
-- ComPort 1     
           for i in 0 to 100 loop             
           Piter_to_RFC_UART_RXD_i  <= get_ComPort_freq_0A(i);
           wait for bit_time_115200;
           end loop;  -- i
      wait for 10 ms;

-- ComPort 2      
           for i in 0 to 350 loop             
           Piter_to_RFC_UART_RXD_i <= set_ComPort_freq_0A2450(i);
           wait for bit_time_115200;
           end loop;  -- i
      wait for 20 ms;  
                 
 -- Noise_Diode 
      -- Enable Roach
           for i in 0 to 100 loop             
            Piter_to_RFC_UART_RXD_i  <= roach_set_noisediode_enable(i);
            wait for bit_time_115200;
           end loop;  -- i 
           wait for 10 ms;
           
      -- Enable DBBC
           for i in 0 to 100 loop
               Piter_to_RFC_UART_RXD_i  <= dbbc_set_noisediode_all_outputs(i);
               wait for bit_time_115200;
           end loop;  -- i
           wait for 10 ms;
          
      -- Enable PC
           for i in 0 to 100 loop
               Piter_to_RFC_UART_RXD_i  <= pc_set_noisediode_enable_pc_full_off(i);
               wait for bit_time_115200;
           end loop;  -- i
           
      wait for 45 ms; 

end process get_ser_port_data;        
       
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

