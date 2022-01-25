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

entity SPI_Analog_Test_Bench is

end SPI_Analog_Test_Bench;

architecture Archtest_bench of SPI_Analog_Test_Bench is
	

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
  signal nCS_i          : std_logic;
  signal Address_i      : std_logic_vector(2 downto 0);
  signal convert_i      : std_logic;
  signal nCS_1_i        : std_logic;
  signal nCS_2_i        : std_logic;
  signal nCS_3_i        : std_logic;
  signal nCS_4_i        : std_logic;
  signal Sclk_i         : std_logic;
  signal Mosi_i         : std_logic;
  signal Miso_i         : std_logic;
  signal AD_data_i      : std_logic_vector(15 downto 0);
  signal Data_valid_1_i : std_logic;
  signal Data_valid_2_i : std_logic;
  signal CS1_i          : std_logic;
  signal CS2_i          : std_logic;
  signal CS3_i          : std_logic;
  signal CS4_i          : std_logic;

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
     Address    => Address_i,
     convert    => convert_i,
     nCS_1      => nCS_1_i,
     nCS_2      => nCS_2_i,
     nCS_3      => nCS_3_i,
     nCS_4      => nCS_4_i,
     Sclk       => Sclk_i,
     Mosi       => Mosi_i,
     Miso       => Miso_i,
     AD_data    => AD_data_i,
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
  
  variable mS_Cnt : integer range 0 to 401;
  begin

    if RST_I_i = '0' then
       mS_Cnt       := 0;
       Address_i  	<= (others =>'0');
       CS1_i        <= '1';
       CS2_i        <= '1';
       CS3_i        <= '1';
       CS4_i        <= '1';
       convert_i    <= '0';
    elsif CLK_I_i'event and CLK_I_i='1' then
    
       if OnemS_sStrobe = '1' then
          mS_Cnt := mS_Cnt + 1;
       end if;   

-- Configuring Analog Input 

    if mS_Cnt = 2 then
       mS_Cnt     := 0;
       Address_i  <= b"101";    
       convert_i  <= '1';
       CS1_i      <= '0';
    else
       convert_i  <= '0';   
    end if;

    if Data_Valid_1_i = '1' then
      CS1_i      <= '1';
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

