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

entity SPI_Analog_Handler_Test_Bench is

end SPI_Analog_Handler_Test_Bench;

architecture Archtest_bench of SPI_Analog_Handler_Test_Bench is
	

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
  
  -- SPI Analog Driver Signals and Component
signal Address_i              : std_logic_vector(2 downto 0);
signal nCS_1_i                : std_logic;
signal nCS_2_i                : std_logic;
signal nCS_3_i                : std_logic;
signal nCS_4_i                : std_logic;
signal Sclk_i                 : std_logic;
signal Mosi_i                 : std_logic;
signal Miso_i                 : std_logic;
signal Version_Driver_i       : std_logic_vector(7 downto 0);
signal Address_out_1_i        : std_logic_vector(2 downto 0);
signal Address_out_2_i        : std_logic_vector(2 downto 0);
signal Data_valid_1_i         : std_logic;
signal Data_valid_2_i         : std_logic;
signal convert_1_i            : std_logic;
signal convert_2_i            : std_logic;
signal Analog_Input_Valid_1_i : std_logic;
signal Analog_Input_Valid_2_i : std_logic;
signal nCS_i                  : std_logic;

  component SPI_Analog is
    port (
      RST_I         : in  std_logic;
      CLK_I         : in  std_logic;
      CS1           : in  std_logic; 
      CS2           : in  std_logic; 
      CS3           : in  std_logic; 
      CS4           : in  std_logic;
      nCS           : out std_logic;
      Address       : in  std_logic_vector(2 downto 0);
      convert       : in  std_logic;
      nCS_1         : out std_logic;
      nCS_2         : out std_logic;
      nCS_3         : out std_logic;
      nCS_4         : out std_logic;
      Sclk          : out std_logic;
      Mosi          : out std_logic;
      Miso          : in  std_logic;
      AD_data       : out std_logic_vector(15 downto 0);
      Data_valid    : out std_logic
      );
  end component SPI_Analog;

-- SPI Analog Handler Signals and Component
signal Ana_In_Request_i    : std_logic;
signal Address_out_i       : std_logic_vector(2 downto 0);
signal convert_i           : std_logic;
signal CS1_i                : std_logic;
signal CS2_i                : std_logic;
signal CS3_i                : std_logic;
signal CS4_i                : std_logic;
signal AD_data_i            : std_logic_vector(15 downto 0);
signal Data_valid_i         : std_logic;
signal Channel_i            : std_logic_vector(775 downto 0);
signal Analog_Data_Valid_i  : std_logic;
signal Analog_Busy_i        : std_logic;
signal Version_Handler_i    : std_logic_vector(7 downto 0);
signal AD_data_1_i     : std_logic_vector(15 downto 0);
signal AD_data_2_i     : std_logic_vector(15 downto 0);
signal Data_Ready_i    : std_logic;
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

  component SPI_Analog_Handler is
    port (
      RST_I           : in  std_logic;
      CLK_I           : in  std_logic;
      One_mS_pulse    : in  std_logic;
      Address_out     : out std_logic_vector(2 downto 0);
      convert         : out std_logic;
      CS1             : out std_logic;
      CS2             : out std_logic;
      CS3             : out std_logic;
      CS4             : out std_logic;
      AD_data_in      : in  std_logic_vector(15 downto 0);
      Data_valid      : in  std_logic;
      CH1_o           : out std_logic_vector(15 downto 0);
      CH2_o           : out std_logic_vector(15 downto 0);
      CH3_o           : out std_logic_vector(15 downto 0);
      CH4_o           : out std_logic_vector(15 downto 0);
      CH5_o           : out std_logic_vector(15 downto 0);
      CH6_o           : out std_logic_vector(15 downto 0);
      CH7_o           : out std_logic_vector(15 downto 0);
      CH8_o           : out std_logic_vector(15 downto 0);
      CH9_o           : out std_logic_vector(15 downto 0);
      CH10_o          : out std_logic_vector(15 downto 0);
      CH11_o          : out std_logic_vector(15 downto 0);
      CH12_o          : out std_logic_vector(15 downto 0);
      CH13_o          : out std_logic_vector(15 downto 0);
      CH14_o          : out std_logic_vector(15 downto 0);
      CH15_o          : out std_logic_vector(15 downto 0);
      CH16_o          : out std_logic_vector(15 downto 0);
      CH17_o          : out std_logic_vector(15 downto 0);
      CH18_o          : out std_logic_vector(15 downto 0);
      CH19_o          : out std_logic_vector(15 downto 0);
      CH20_o          : out std_logic_vector(15 downto 0);
      CH21_o          : out std_logic_vector(15 downto 0);
      CH22_o          : out std_logic_vector(15 downto 0);
      CH23_o          : out std_logic_vector(15 downto 0);
      CH24_o          : out std_logic_vector(15 downto 0);
      CH25_o          : out std_logic_vector(15 downto 0);
      CH26_o          : out std_logic_vector(15 downto 0);
      CH27_o          : out std_logic_vector(15 downto 0);
      CH28_o          : out std_logic_vector(15 downto 0);
      CH29_o          : out std_logic_vector(15 downto 0);
      CH30_o          : out std_logic_vector(15 downto 0);
      CH31_o          : out std_logic_vector(15 downto 0);
      CH32_o          : out std_logic_vector(15 downto 0);
      CH33_o          : out std_logic_vector(15 downto 0);
      CH34_o          : out std_logic_vector(15 downto 0);
      CH35_o          : out std_logic_vector(15 downto 0);
      CH36_o          : out std_logic_vector(15 downto 0);
      CH37_o          : out std_logic_vector(15 downto 0);
      CH38_o          : out std_logic_vector(15 downto 0);
      CH39_o          : out std_logic_vector(15 downto 0);
      CH40_o          : out std_logic_vector(15 downto 0);
      CH41_o          : out std_logic_vector(15 downto 0);
      CH42_o          : out std_logic_vector(15 downto 0);
      CH43_o          : out std_logic_vector(15 downto 0);
      CH44_o          : out std_logic_vector(15 downto 0);
      CH45_o          : out std_logic_vector(15 downto 0);
      CH46_o          : out std_logic_vector(15 downto 0);
      CH47_o          : out std_logic_vector(15 downto 0);
      CH48_o          : out std_logic_vector(15 downto 0);
      Data_Ready      : out std_logic;
      Ana_In_Request  : in  std_logic
      );
  end component SPI_Analog_Handler;

-------------------------------------------------------------------------------
-- New Code Signal and Components
------------------------------------------------------------------------------- 
signal RST_I_i                  : std_logic;
signal CLK_I_i                  : std_logic;

signal Request_i                : std_logic;
---------------------------------------
----------------------------------------
-- General Signals
-------------------------------------------------------------------------------
  type Test_states is (idle, Data_Valid_Wait, Data_Valid_Count);
  
  signal Test_state       : Test_states;  


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

-- SPI Analog Handler Instance
-- Analog In Handler 1
SPI_Analog_Handler_1: entity work.SPI_Analog_Handler
port map (
  RST_I          => RST_I_i,
  CLK_I          => CLK_I_i,
  Address_out    => Address_out_1_i,
  convert        => convert_1_i,
  CS1            => CS1_i,
  CS2            => CS2_i,
  CS3            => CS3_i,
  CS4            => CS4_i,
  AD_data_in     => AD_data_1_i,
  Data_valid     => Data_valid_1_i,
  CH1_o          => CH1_o_i,
  CH2_o          => CH2_o_i,
  CH3_o          => CH3_o_i,
  CH4_o          => CH4_o_i,
  CH5_o          => CH5_o_i,
  CH6_o          => CH6_o_i,
  CH7_o          => CH7_o_i,
  CH8_o          => CH8_o_i,
  CH9_o          => CH9_o_i,
  CH10_o         => CH10_o_i,
  CH11_o         => CH11_o_i,
  CH12_o         => CH12_o_i,
  CH13_o         => CH13_o_i,
  CH14_o         => CH14_o_i,
  CH15_o         => CH15_o_i,
  CH16_o         => CH16_o_i,
  CH17_o         => CH17_o_i,
  CH18_o         => CH18_o_i,
  CH19_o         => CH19_o_i,
  CH20_o         => CH20_o_i,
  CH21_o         => CH21_o_i,
  CH22_o         => CH22_o_i,
  CH23_o         => CH23_o_i,
  CH24_o         => CH24_o_i,
  CH25_o         => CH25_o_i,
  CH26_o         => CH26_o_i,
  CH27_o         => CH27_o_i,
  CH28_o         => CH28_o_i,
  CH29_o         => CH29_o_i,
  CH30_o         => CH30_o_i,
  CH31_o         => CH31_o_i,
  CH32_o         => CH32_o_i,
  CH33_o         => CH33_o_i,
  CH34_o         => CH34_o_i,
  CH35_o         => CH35_o_i,
  CH36_o         => CH36_o_i,
  CH37_o         => CH37_o_i,
  CH38_o         => CH38_o_i,
  CH39_o         => CH39_o_i,
  CH40_o         => CH40_o_i,
  CH41_o         => CH41_o_i,
  CH42_o         => CH42_o_i,
  CH43_o         => CH43_o_i,
  CH44_o         => CH44_o_i,
  CH45_o         => CH45_o_i,
  CH46_o         => CH46_o_i,
  CH47_o         => CH47_o_i,
  CH48_o         => CH48_o_i,
  Data_Ready     => Analog_Input_Valid_1_i,
  Ana_In_Request => Ana_In_Request_i
  );
     
     -- SPI Analog Driver Instance
     SPI_Analog_1: entity work.SPI_Analog
     port map (
       RST_I      => RST_I_i,
       CLK_I      => CLK_I_i,
       CS1        => CS1_i,
       CS2        => CS2_i, 
       CS3        => CS3_i,
       CS4        => CS4_i,
       nCS        => nCS_i,
       Address    => Address_out_1_i,
       convert    => convert_1_i,
       nCS_1      => nCS_1_i,
       nCS_2      => nCS_2_i,
       nCS_3      => nCS_3_i,
       nCS_4      => nCS_4_i,
       Sclk       => Sclk_i,
       Mosi       => Mosi_i,
       Miso       => Miso_i,
       AD_data    => AD_data_1_i,
       Data_valid => Data_Valid_1_i
       );
              
Miso_i    <= -- Card 1 Port 1 to 8 
              '0', '1' after 2.00425 ms, '0' after 2.00629 ms, '1' after 2.00829 ms,
              '0' after 2.01033 ms, '1' after 2.01233 ms, '1' after 2.01247 ms, '1' after 2.01637 ms,
              '0' after 2.01841 ms, '1' after 2.02041 ms, '0' after 2.02245 ms, '0' after 2.02538 ms,
              '1' after 2.02649 ms, '0' after 2.027 ms, '1' after 2.029 ms, '0' after 2.033 ms,
              '0' after 2.034 ms,   '1' after 2.035 ms, '1' after 2.039 ms, '0' after 2.042 ms, 
              '1' after 2.045 ms,   '0' after 2.047 ms, '0' after 2.049 ms, '1' after 2.052 ms, 
              '0' after 2.055 ms,   '0' after 2.058 ms, '1' after 2.060 ms, '0' after 2.062 ms,
              '0' after 2.063 ms,   '1' after 2.065 ms, '0' after 2.067 ms,      
              '0' after 2.081 ms,   '1' after 2.08425 ms, '0' after 2.08629 ms, '1' after 2.08829 ms,
              '1' after 2.09033 ms, '1' after 2.09233 ms, '0' after 2.09247 ms, '1' after 2.09637 ms,
              '0' after 2.09841 ms, '1' after 2.10041 ms, '0' after 2.12245 ms, '1' after 2.12538 ms,
              '0' after 2.144 ms; 
               
Time_Stamping: process (CLK_I_i, RST_I_i)
  
  variable mS_Cnt  : integer range 0 to 7500;
  variable Req_Cnt : integer range 0 to 201;
  begin

    if RST_I_i = '0' then
       mS_Cnt           := 0;
       Ana_In_Request_i <= '0';
       Test_state       <= Idle;
    elsif CLK_I_i'event and CLK_I_i='1' then
       
       if OnemS_sStrobe = '1' then
          Ana_In_Request_i <= '1';
       else
          Ana_In_Request_i <= '0';
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

