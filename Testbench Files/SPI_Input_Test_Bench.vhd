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

entity SPI_Input_Test_Bench is

end SPI_Input_Test_Bench;

architecture Archtest_bench of SPI_Input_Test_Bench is
	

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

-- SPI I/O Driver Signals and Component
signal nCS_Output_1_i           : std_logic;
signal nCS_Output_2_i           : std_logic;
signal Int_1_i                  : std_logic;
signal Int_2_i                  : std_logic;
signal Sclk_i                   : std_logic;
signal Mosi_i                   : std_logic;
signal Miso_i                   : std_logic;
signal Card_Select_i            : std_logic;
signal Data_In_Ready_i          : std_logic;
signal SPI_Outport_i            : std_logic_vector(15 downto 0);
signal Data_Out_Ready_i         : std_logic;
signal SPI_Inport               : std_logic_vector(15 downto 0);
signal SPI_Inport_i             : std_logic_vector(15 downto 0);  
signal Busy_i                   : std_logic;
signal Busy_In_i                : std_logic;
signal Version_Driver_i         : std_logic_vector(7 downto 0);

component SPI_In_Output is
  port (
    RST_I          : in  std_logic;
    CLK_I          : in  std_logic;
    nCS_Output_1   : out std_logic;
    nCS_Output_2   : out std_logic;
    Sclk           : out std_logic;
    Mosi           : out std_logic;
    Miso           : in  std_logic;
    Card_Select    : in  std_logic;
    Data_In_Ready  : in  std_logic;
    SPI_Outport    : in  std_logic_vector(15 downto 0);
    Data_Out_Ready : out std_logic;
    SPI_Inport     : out std_logic_vector(15 downto 0);
    Busy           : out std_logic
    );
end component SPI_In_Output;

-- SPI Input Handler
-- Digital Input Signals and Component
signal SPI_Inport_1_i        : std_logic_vector(7 downto 0);
signal SPI_Inport_2_i        : std_logic_vector(7 downto 0);
signal SPI_Inport_3_i        : std_logic_vector(7 downto 0);
signal SPI_Inport_4_i        : std_logic_vector(7 downto 0);
signal SPI_Inport_5_i        : std_logic_vector(7 downto 0);
signal SPI_Inport_6_i        : std_logic_vector(7 downto 0);
signal SPI_Inport_7_i        : std_logic_vector(7 downto 0);
signal SPI_Inport_8_i        : std_logic_vector(7 downto 0);
signal SPI_Data_out_i        : std_logic_vector(15 downto 0);
signal Input_Data_ready_i    : std_logic;
signal Input_Ready_i         : std_logic;
signal Input_Card_Select_i   : std_logic;
signal SPI_Data_in_i         : std_logic_vector(15 downto 0);
signal Input_Data_In_ready_i : std_logic;
signal Digital_Input_Valid_i : std_logic;
signal Dig_In_Request_i      : std_logic;

signal Version_i             : std_logic_vector(7 downto 0);

component SPI_Input is
  port (
    RST_I               : in  std_logic;
    CLK_I               : in  std_logic;
    Int_1               : in  std_logic;
    Int_2               : in  std_logic;
    SPI_Inport_1        : out std_logic_vector(7 downto 0);
    SPI_Inport_2        : out std_logic_vector(7 downto 0);
    SPI_Inport_3        : out std_logic_vector(7 downto 0);
    SPI_Inport_4        : out std_logic_vector(7 downto 0);
    SPI_Inport_5        : out std_logic_vector(7 downto 0);
    SPI_Inport_6        : out std_logic_vector(7 downto 0);
    SPI_Inport_7        : out std_logic_vector(7 downto 0);
    SPI_Inport_8        : out std_logic_vector(7 downto 0);
    SPI_Data_out        : out std_logic_vector(15 downto 0);
    Input_Data_ready    : out std_logic;
    Input_Card_Select   : out std_logic;
    SPI_Data_in         : in  std_logic_vector(15 downto 0);
    Input_Ready         : out std_logic;
    busy                : in  std_logic;
    Dig_In_Request      : in  std_logic
);
end component SPI_Input;

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

-- SPI In Driver Instance
       SPI_In_1: entity work.SPI_In_Output
         port map (
           RST_I          => RST_I_i,
           CLK_I          => CLK_I_i,
           nCS_Output_1   => nCS_Output_1_i,
           nCS_Output_2   => nCS_Output_2_i,
           Sclk           => Sclk_i,
           Mosi           => Mosi_i,
           Miso           => Miso_i,
           Card_Select    => Input_Card_Select_i,
           Data_In_Ready  => Input_Data_Ready_i,       
           SPI_Outport    => SPI_Data_out_i,           
           SPI_Inport     => SPI_Inport_i,
           Busy           => Busy_In_i
           );

-- SPI Digital In Handler Instance

SPI_Input_1: entity work.SPI_Input
port map (
  RST_I               => RST_I_i,
  CLK_I               => CLK_I_i,
  Int_1               => Int_1_i, 
  Int_2               => Int_2_i, 
  SPI_Inport_1        => SPI_Inport_1_i,
  SPI_Inport_2        => SPI_Inport_2_i,
  SPI_Inport_3        => SPI_Inport_3_i,
  SPI_Inport_4        => SPI_Inport_4_i,
  SPI_Inport_5        => SPI_Inport_5_i,
  SPI_Inport_6        => SPI_Inport_6_i,
  SPI_Inport_7        => SPI_Inport_7_i,
  SPI_Inport_8        => SPI_Inport_8_i,
  SPI_Data_out        => SPI_Data_out_i,
  Input_Data_ready    => Input_Data_Ready_i,
  Input_Ready         => Digital_Input_Valid_i,
  Input_Card_Select   => Input_Card_Select_i,
  SPI_Data_in         => SPI_Inport_i,
  busy                => Busy_In_i,
  Dig_In_Request      => Dig_In_Request_i
);

 --Miso_i    <= '0', '1' after 0.00425 ms, '0' after 0.00629 ms, '1' after 0.00829 ms,
 --             '0' after 0.01033 ms, '1' after 0.01233 ms, '1' after 0.01247 ms, '1' after 0.01637 ms,
 --             '0' after 0.01841 ms, '1' after 0.02041 ms, '0' after 0.02245 ms, '0' after 0.02538 ms,
 --             '1' after 0.02649 ms, '0' after 0.027 ms, '1' after 0.029 ms, '0' after 0.033 ms,
 --             '0' after 0.034 ms, '1' after 0.035 ms, '1' after 0.039 ms, '0' after 0.042 ms, 
 --             '1' after 0.045 ms, '0' after 0.047 ms, '0' after 0.049 ms, '1' after 0.052 ms, 
 --             '0' after 0.055 ms, '0' after 0.058 ms, '1' after 0.060 ms, '0' after 0.062 ms,
 --              '0' after 0.063 ms, '1' after 0.065 ms, '0' after 0.067 ms; 
              
Miso_i    <= -- Card 1 Port 1 to 8 
              '0', '1' after 10.00425 ms, '0' after 10.00629 ms, '1' after 10.00829 ms,
              '0' after 10.01033 ms, '1' after 10.01233 ms, '1' after 10.01247 ms, '1' after 10.01637 ms,
              '0' after 10.01841 ms, '1' after 10.02041 ms, '0' after 10.02245 ms, '0' after 10.02538 ms,
              '1' after 10.02649 ms, '0' after 10.027 ms, '1' after 10.029 ms, '0' after 10.033 ms,
              '0' after 10.034 ms,   '1' after 10.035 ms, '1' after 10.039 ms, '0' after 10.042 ms, 
              '1' after 10.045 ms,   '0' after 10.047 ms, '0' after 10.049 ms, '1' after 10.052 ms, 
              '0' after 10.055 ms,   '0' after 10.058 ms, '1' after 10.060 ms, '0' after 10.062 ms,
              '0' after 10.063 ms,   '1' after 10.065 ms, '0' after 10.067 ms,      
              '0' after 10.081 ms,   '1' after 10.08425 ms, '0' after 10.08629 ms, '1' after 10.08829 ms,
              '1' after 10.09033 ms, '1' after 10.09233 ms, '0' after 10.09247 ms, '1' after 10.09637 ms,
              '0' after 10.09841 ms, '1' after 10.10041 ms, '0' after 10.12245 ms, '1' after 10.12538 ms,
              '0' after 10.144 ms,   
              -- Card 1 Port 9 to 16
              '1' after 10.15507 ms, '0' after 10.15807 ms, '1' after 10.16023 ms,
              '0' after 10.16273 ms, '1' after 10.16477 ms, '0' after 10.16679 ms, '1' after 10.16881 ms,
              '0' after 10.17081 ms, '0' after 10.17285 ms, '0' after 10.17323 ms, '1' after 10.17723 ms,
              '0' after 10.17823 ms, '0' after 10.17885 ms, '0' after 10.17923 ms, '1' after 10.18023 ms,
              '0' after 10.18178 ms, '0' after 10.18278 ms, '0' after 10.18379 ms, '1' after 10.18480 ms,
              '0' after 10.18578 ms, '0' after 10.18678 ms, '0' after 10.18779 ms, '1' after 10.18880 ms,
              '0' after 10.18978 ms, '0' after 10.19178 ms, '0' after 10.19279 ms, '1' after 10.19480 ms,
              '0' after 10.19578 ms, '0' after 10.19678 ms, '0' after 10.19979 ms, '1' after 10.20020 ms,
              '0' after 10.20040 ms, '0' after 10.20042 ms, '0' after 10.20044 ms, '1' after 10.20046 ms,
              '0' after 10.20060 ms, '0' after 10.20082 ms, '0' after 10.20144 ms, '1' after 10.20146 ms,
              '0' after 10.20240 ms, '0' after 10.20242 ms, '0' after 10.20244 ms, '1' after 10.20346 ms,
              '0' after 10.20440 ms, '0' after 10.20442 ms, '0' after 10.20444 ms, '1' after 10.20446 ms,
              '0' after 10.21440 ms, '0' after 10.21442 ms, '0' after 10.21444 ms, '1' after 10.21446 ms,
              '0' after 10.22135 ms, 
              -- Card 1 Port 17 to 24
              '0' after 10.23139 ms, '0' after 10.23542 ms, '0' after 10.23644 ms, '1' after 10.23746 ms,
              '0' after 10.23839 ms, '0' after 10.23942 ms, '0' after 10.24044 ms, '1' after 10.24084 ms,
              '0' after 10.24139 ms, '0' after 10.24142 ms, '0' after 10.24144 ms, '1' after 10.24184 ms,
              '0' after 10.24199 ms, '0' after 10.24202 ms, '0' after 10.24210 ms, '1' after 10.24215 ms,
              '0' after 10.24217 ms, '0' after 10.24220 ms, '0' after 10.24230 ms, '1' after 10.24245 ms,
              '0' after 10.25217 ms, '0' after 10.25220 ms, '0' after 10.25230 ms, '1' after 10.25245 ms,
              '0' after 10.26217 ms, '0' after 10.26220 ms, '0' after 10.26230 ms, '1' after 10.26245 ms,
              '0' after 10.27217 ms, '0' after 10.27220 ms, '0' after 10.27230 ms, '1' after 10.27245 ms,
              '0' after 10.28217 ms, '0' after 10.28220 ms, '0' after 10.28230 ms, '1' after 10.28245 ms,
              '0' after 10.29217 ms, '0' after 10.29220 ms, '0' after 10.29230 ms, '1' after 10.29245 ms,
              -- Card 1 Port 25
              '1' after 10.30425 ms, '0' after 10.30629 ms, '1' after 10.30829 ms,
              '0' after 10.31033 ms, '1' after 10.31233 ms, '1' after 10.31247 ms, '1' after 10.31637 ms,
              '0' after 10.31841 ms, '1' after 10.32041 ms, '0' after 10.32245 ms, '0' after 10.32538 ms,
              '1' after 10.32649 ms, '0' after 10.32755 ms, '1' after 10.32933 ms, '0' after 10.33333 ms,
              
              '1' after 10.35507 ms, '0' after 10.35807 ms, '1' after 10.36023 ms,
              '0' after 10.36273 ms, '1' after 10.36477 ms, '0' after 10.36679 ms, '1' after 10.36881 ms,
              '0' after 10.37081 ms, '0' after 10.37285 ms, '0' after 10.37323 ms, '1' after 10.37723 ms,
              '0' after 10.37823 ms, '0' after 10.37885 ms, '0' after 10.37923 ms, '1' after 10.38023 ms,
              '0' after 10.38178 ms, '0' after 10.38278 ms, '0' after 10.38379 ms, '1' after 10.38480 ms,
              '0' after 10.38578 ms, '0' after 10.38678 ms, '0' after 10.38779 ms, '1' after 10.38880 ms,
              '0' after 10.38978 ms, '0' after 10.39178 ms, '0' after 10.39279 ms, '1' after 10.39480 ms,
              '0' after 10.39578 ms, '0' after 10.39678 ms, '0' after 10.39979 ms, '1' after 10.40020 ms,
              '0' after 10.40040 ms, '0' after 10.40042 ms, '0' after 10.40044 ms, '1' after 10.40046 ms,
              '0' after 10.40060 ms, '0' after 10.40082 ms, '0' after 10.40144 ms, '1' after 10.40146 ms,
              '0' after 10.40240 ms, '0' after 10.40242 ms, '0' after 10.40244 ms, '1' after 10.40346 ms,
              '0' after 10.40440 ms, '0' after 10.40442 ms, '0' after 10.40444 ms, '1' after 10.40446 ms,
              '0' after 10.41440 ms, '0' after 10.41442 ms, '0' after 10.41444 ms, '1' after 10.41446 ms,
              '0' after 10.42135 ms, 
              -- Card 1 Port 17 to 24
              '0' after 10.43139 ms, '0' after 10.43542 ms, '0' after 10.43644 ms, '1' after 10.43746 ms,
              '0' after 10.43839 ms, '0' after 10.43942 ms, '0' after 10.44044 ms, '1' after 10.44084 ms,
              '0' after 10.44139 ms, '0' after 10.44142 ms, '0' after 10.44144 ms, '1' after 10.44184 ms,
              '0' after 10.44199 ms, '0' after 10.44202 ms, '0' after 10.44210 ms, '1' after 10.44215 ms,
              '0' after 10.44217 ms, '0' after 10.44220 ms, '0' after 10.44230 ms, '1' after 10.44245 ms,
              '0' after 10.45217 ms, '0' after 10.45220 ms, '0' after 10.45230 ms, '1' after 10.45245 ms,
              '0' after 10.46217 ms, '0' after 10.46220 ms, '0' after 10.46230 ms, '1' after 10.46245 ms,
              '0' after 10.47217 ms, '0' after 10.47220 ms, '0' after 10.47230 ms, '1' after 10.47245 ms,
              '0' after 10.48217 ms, '0' after 10.48220 ms, '0' after 10.48230 ms, '1' after 10.48245 ms,
              '0' after 10.49217 ms, '0' after 10.49220 ms, '0' after 10.49230 ms, '1' after 10.49245 ms,
              -- Card 1 Port 25
              '1' after 10.50425 ms, '0' after 10.50629 ms, '1' after 10.50829 ms,
              '0' after 10.51033 ms, '1' after 10.51233 ms, '1' after 10.51247 ms, '1' after 10.51637 ms,
              '0' after 10.51841 ms, '1' after 10.52041 ms, '0' after 10.52245 ms, '0' after 10.52538 ms,
              '1' after 10.52649 ms, '0' after 10.52755 ms, '1' after 10.52933 ms, '0' after 10.53333 ms,
              '1' after 10.60425 ms, '0' after 10.60629 ms, '1' after 10.60829 ms,
              '0' after 10.61033 ms, '1' after 10.61233 ms, '1' after 10.61247 ms, '1' after 10.61637 ms,
              '0' after 10.61841 ms, '1' after 10.62041 ms, '0' after 10.62245 ms, '0' after 10.62538 ms,
              '1' after 10.62649 ms, '0' after 10.62755 ms, '1' after 10.62933 ms, '0' after 10.63333 ms,
              '1' after 10.70425 ms, '0' after 10.70629 ms, '1' after 10.70829 ms,
              '0' after 10.71033 ms, '1' after 10.71233 ms, '1' after 10.71247 ms, '1' after 10.71637 ms,
              '0' after 10.71841 ms, '1' after 10.72041 ms, '0' after 10.72245 ms, '0' after 10.72538 ms,
              '1' after 10.72649 ms, '0' after 10.72755 ms, '1' after 10.72933 ms, '0' after 10.73333 ms;              

Time_Stamping: process (CLK_I_i, RST_I_i)
  
  variable mS_Cnt : integer range 0 to 401;
  begin

    if RST_I_i = '0' then
       Dig_In_Request_i <= '0';
    elsif CLK_I_i'event and CLK_I_i='1' then

-- Configuring Digital Input Cards 
     
-- Start the Processes
       if Ten_mS_sStrobe = '1' then
          Dig_In_Request_i <= '1';
       else  
          Dig_In_Request_i <= '0'; 
       end if;  
           
    end if;
  end process Time_Stamping;
       
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

