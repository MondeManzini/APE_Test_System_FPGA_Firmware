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

entity SPI_Output_Test_Bench is

end SPI_Output_Test_Bench;

architecture Archtest_bench of SPI_Output_Test_Bench is
	

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
signal Busy_Out_i               : std_logic;
signal Digital_Output_Valid_i   : std_logic;

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
    SPI_Inport     : out std_logic_vector(15 downto 0);
    Busy           : out std_logic
    );
end component SPI_In_Output;

-- SPI Output Handler
-- Digital Output Signals and Component
signal Dig_Card1_1_B0_i       : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B1_i       : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B2_i       : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B3_i       : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B4_i       : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B5_i       : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B6_i       : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B7_i       : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B0_Out_i   : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B1_Out_i   : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B2_Out_i   : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B3_Out_i   : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B4_Out_i   : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B5_Out_i   : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B6_Out_i   : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B7_Out_i   : std_logic_vector(7 downto 0);
signal Dig_Out_Request_i      : std_logic;
signal Output_SPI_Data_out_i  : std_logic_vector(15 downto 0);
signal Output_Data_ready_i    : std_logic;
signal Output_Ready_i         : std_logic;
signal Output_Card_Select_i   : std_logic;
signal Version_i              : std_logic_vector(7 downto 0);

component SPI_Output is
  port (
    RST_I               : in  std_logic;
    CLK_I               : in  std_logic;
    SPI_Outport_1       : in  std_logic_vector(7 downto 0);
    SPI_Outport_2       : in  std_logic_vector(7 downto 0);
    SPI_Outport_3       : in  std_logic_vector(7 downto 0);
    SPI_Outport_4       : in  std_logic_vector(7 downto 0);
    SPI_Outport_5       : in  std_logic_vector(7 downto 0);
    SPI_Outport_6       : in  std_logic_vector(7 downto 0);
    SPI_Outport_7       : in  std_logic_vector(7 downto 0);
    SPI_Outport_8       : in  std_logic_vector(7 downto 0);
    SPI_Inport_1        : out std_logic_vector(7 downto 0);
    SPI_Inport_2        : out std_logic_vector(7 downto 0);
    SPI_Inport_3        : out std_logic_vector(7 downto 0);
    SPI_Inport_4        : out std_logic_vector(7 downto 0);
    SPI_Inport_5        : out std_logic_vector(7 downto 0);
    SPI_Inport_6        : out std_logic_vector(7 downto 0);
    SPI_Inport_7        : out std_logic_vector(7 downto 0);
    SPI_Inport_8        : out std_logic_vector(7 downto 0);
    SPI_Data_in         : in  std_logic_vector(15 downto 0);
    Input_Ready         : in  std_logic;
    Output_SPI_Data_out : out std_logic_vector(15 downto 0);
    Output_Data_ready   : out std_logic;
    Output_Ready        : out std_logic;
    Output_Card_Select  : out std_logic;
    busy                : in  std_logic;
    Dig_Out_Request     : in  std_logic
);
end component SPI_Output;

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
       SPI_Out_1: entity work.SPI_In_Output
         port map (
           RST_I          => RST_I_i,
           CLK_I          => CLK_I_i,
           nCS_Output_1   => nCS_Output_1_i,
           nCS_Output_2   => nCS_Output_2_i,
           Sclk           => Sclk_i,
           Mosi           => Mosi_i,
           Miso           => Mosi_i,  --Miso_i,
           Card_Select    => Output_Card_Select_i,
           Data_In_Ready  => Output_Data_ready_i,       
           SPI_Outport    => Output_SPI_Data_out_i,           
           SPI_Inport     => SPI_Inport_i, 
           Busy           => Busy_Out_i
           );

-- SPI Digital Out Handler Instance
       SPI_Output_1: entity work.SPI_Output
         port map (
           RST_I               => RST_I_i,
           CLK_I               => CLK_I_i,
           SPI_Outport_1       => Dig_Card1_1_B0_i,
           SPI_Outport_2       => Dig_Card1_1_B1_i,
           SPI_Outport_3       => Dig_Card1_1_B2_i,
           SPI_Outport_4       => Dig_Card1_1_B3_i,
           SPI_Outport_5       => Dig_Card1_1_B4_i,
           SPI_Outport_6       => Dig_Card1_1_B5_i,
           SPI_Outport_7       => Dig_Card1_1_B6_i,
           SPI_Outport_8       => Dig_Card1_1_B7_i,
           SPI_Inport_1        => Dig_Card1_1_B0_Out_i,
           SPI_Inport_2        => Dig_Card1_1_B1_Out_i,
           SPI_Inport_3        => Dig_Card1_1_B2_Out_i,
           SPI_Inport_4        => Dig_Card1_1_B3_Out_i,
           SPI_Inport_5        => Dig_Card1_1_B4_Out_i,
           SPI_Inport_6        => Dig_Card1_1_B5_Out_i,
           SPI_Inport_7        => Dig_Card1_1_B6_Out_i,
           SPI_Inport_8        => Dig_Card1_1_B7_Out_i,
           SPI_Data_in         => SPI_Inport_i,
           Input_Ready         => Data_Out_Ready_i,
           Output_SPI_Data_out => Output_SPI_Data_out_i,
           Output_Data_ready   => Output_Data_Ready_i,
           Output_ready        => Digital_Output_Valid_i,
           Output_Card_Select  => Output_Card_Select_i,
           busy                => Busy_Out_i,
           Dig_Out_Request     => Dig_Out_Request_i
       );


 --Miso_i    <= '0', '1' after 0.00425 ms, '0' after 0.00629 ms, '1' after 0.00829 ms,
 --             '0' after 0.01033 ms, '1' after 0.01233 ms, '1' after 0.01247 ms, '1' after 0.01637 ms,
 --             '0' after 0.01841 ms, '1' after 0.02041 ms, '0' after 0.02245 ms, '0' after 0.02538 ms,
 --             '1' after 0.02649 ms, '0' after 0.027 ms, '1' after 0.029 ms, '0' after 0.033 ms,
 --             '0' after 0.034 ms, '1' after 0.035 ms, '1' after 0.039 ms, '0' after 0.042 ms, 
 --             '1' after 0.045 ms, '0' after 0.047 ms, '0' after 0.049 ms, '1' after 0.052 ms, 
 --             '0' after 0.055 ms, '0' after 0.058 ms, '1' after 0.060 ms, '0' after 0.062 ms,
 --             '0' after 0.063 ms, '1' after 0.065 ms, '0' after 0.067 ms; 
                       
Time_Stamping: process (CLK_I_i, RST_I_i)
  
  variable mS_Cnt : integer range 0 to 401;
  begin

    if RST_I_i = '0' then
       Dig_Card1_1_B0_i   <= (others => '0');
       Dig_Card1_1_B1_i   <= (others => '0');
       Dig_Card1_1_B2_i   <= (others => '0');
       Dig_Card1_1_B3_i   <= (others => '0');
       Dig_Card1_1_B4_i   <= (others => '0');
       Dig_Card1_1_B5_i   <= (others => '0');
       Dig_Card1_1_B6_i   <= (others => '0');
       Dig_Card1_1_B7_i   <= (others => '0');
       mS_Cnt            := 0;  
       Dig_Out_Request_i <= '0';  
    elsif CLK_I_i'event and CLK_I_i='1' then

-- Configuring Digital Input Cards 
     
-- Start the Processes
       
       if Ten_mS_sStrobe = '1' then
          Dig_Out_Request_i <= '1';
       else  
          Dig_Out_Request_i <= '0'; 
       end if; 
       
       if Dig_Out_Request_i = '1' then
          mS_Cnt := mS_Cnt + 1;
       end if;  
       
       if Dig_Out_Request_i = '1' and mS_Cnt = 2 then
          Dig_Card1_1_B0_i   <= X"00";
          Dig_Card1_1_B1_i   <= X"00";
          Dig_Card1_1_B2_i   <= X"00";
          Dig_Card1_1_B3_i   <= X"00";
          Dig_Card1_1_B4_i   <= X"00";
          Dig_Card1_1_B5_i   <= X"00";
          Dig_Card1_1_B6_i   <= X"00";
          Dig_Card1_1_B7_i   <= X"00";
       elsif Dig_Out_Request_i = '1' and mS_Cnt = 4 then   
          Dig_Card1_1_B0_i   <= X"55";
          Dig_Card1_1_B1_i   <= X"55";
          Dig_Card1_1_B2_i   <= X"55";
          Dig_Card1_1_B3_i   <= X"55";
          Dig_Card1_1_B4_i   <= X"55";
          Dig_Card1_1_B5_i   <= X"55";
          Dig_Card1_1_B6_i   <= X"55";
          Dig_Card1_1_B7_i   <= X"55";
       elsif Dig_Out_Request_i = '1' and mS_Cnt = 6 then
          Dig_Card1_1_B0_i   <= X"AA";
          Dig_Card1_1_B1_i   <= X"AA";
          Dig_Card1_1_B2_i   <= X"AA";
          Dig_Card1_1_B3_i   <= X"AA";
          Dig_Card1_1_B4_i   <= X"AA";
          Dig_Card1_1_B5_i   <= X"AA";
          Dig_Card1_1_B6_i   <= X"AA";
          Dig_Card1_1_B7_i   <= X"AA";
       elsif Dig_Out_Request_i = '1' and mS_Cnt = 6 then
          Dig_Card1_1_B0_i   <= X"FF";
          Dig_Card1_1_B1_i   <= X"FF";
          Dig_Card1_1_B2_i   <= X"FF";
          Dig_Card1_1_B3_i   <= X"FF";
          Dig_Card1_1_B4_i   <= X"FF";
          Dig_Card1_1_B5_i   <= X"FF";
          Dig_Card1_1_B6_i   <= X"FF";
          Dig_Card1_1_B7_i   <= X"FF";
       elsif Dig_Out_Request_i = '1' and mS_Cnt = 8 then
          mS_Cnt            := 0;
          Dig_Card1_1_B0_i   <= X"00";
          Dig_Card1_1_B1_i   <= X"00";
          Dig_Card1_1_B2_i   <= X"00";
          Dig_Card1_1_B3_i   <= X"00";
          Dig_Card1_1_B4_i   <= X"00";
          Dig_Card1_1_B5_i   <= X"00";
          Dig_Card1_1_B6_i   <= X"00";
          Dig_Card1_1_B7_i   <= X"00";   
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

