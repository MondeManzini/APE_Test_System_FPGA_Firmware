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

entity Baud_Rate_Generator_Test_Bench is

end Baud_Rate_Generator_Test_Bench;

architecture Archtest_bench of Baud_Rate_Generator_Test_Bench is
	

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

-- Baud Rate Generator Signals and Component

signal baud_rate_i        : integer range 0 to 7;
signal Version_i          : std_logic_vector(7 downto 0);
signal Baud_Rate_Enable_i : std_logic;

component Baud_Rate_Generator is
  port (
    Clk              : in  std_logic;
    RST_I            : in  std_logic;
    baud_rate        : in  integer range 0 to 7;
    Version          : out std_logic_vector(7 downto 0);
    Baud_Rate_Enable : out std_logic
    );
end component Baud_Rate_Generator;

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
       
-- Baud Rate GeneratorInstance       
       Baud_Rate_Generator_1: entity work.Baud_Rate_Generator
         port map (
           Clk              => CLK_I_i,
           RST_I            => RST_I_i,
           baud_rate        => baud_rate_i,
           Version          => Version_i,
           Baud_Rate_Enable => Baud_Rate_Enable_i
           );
       
Time_Stamping: process (CLK_I_i, RST_I_i)
  
  variable mS_Cnt : integer range 0 to 401;
  begin

    if RST_I_i = '0' then

      baud_rate_i  <= 0;  
      mS_Cnt       := 0;
       
    elsif CLK_I_i'event and CLK_I_i='1' then
  
       if OnemS_sStrobe = '1' then
         mS_Cnt := mS_Cnt + 1;
       end if;

       if mS_Cnt = 5 then
          baud_rate_i  <= 0;  -- 9600
       elsif mS_Cnt = 10 then
          baud_rate_i  <= 1;  -- 19200
       elsif mS_Cnt = 15 then
          baud_rate_i  <= 2;  -- 38400
       elsif mS_Cnt = 20 then
          baud_rate_i  <= 3;  -- 57600
       elsif mS_Cnt = 25 then
          baud_rate_i  <= 4;  -- 76800
       elsif mS_Cnt = 30 then
          baud_rate_i  <= 5;  -- 115200
       elsif mS_Cnt = 35 then
          mS_Cnt       := 0; 
          baud_rate_i  <= 0;  -- 9600  
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

