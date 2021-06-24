-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
-- This module receive the NTP time from the Infrastructure PC software, this
-- time is then incremented using the FPGA clock. Should this time be out the
-- Infrasture software will then re sync the time. The FPGA will compare the
-- internal sec counter to the incoming PPS and just is sec counter internally
-- to maintain the clock accuracy.
--
-- Written by  : Monde Manzini Version 1.0
-- Tested      : 26/05/2016 
--             : Test Bench File Name Timer_Controller_Test_Bench
--               located at
--             : Test do file is Timer_Controller.do
--               located at
-- Last update : 26/05/2016 - Initial release  Version 1.0
-- Outstanding : 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Timer_Controller is
  
  port (
-- General Signals                  
    RST_I                            : in  std_logic;
    CLK_I                            : in  std_logic;
-- Timer Sync
    PPS_In                           : in  std_logic;
-- Input time
    SET_Timer                        : in  std_logic;    
    Timer_Sec_Reg                    : in  std_logic_vector(31 downto 0);
    Timer_mSec_Reg                   : in  std_logic_vector(15 downto 0);
-- Output time
    Timer_Sec_Reg_1                  : out std_logic_vector(31 downto 0);
    Timer_mSec_Reg_1                 : out std_logic_vector(15 downto 0);
    Timer_Controller_Version_Name    : out std_logic_vector(255 downto 0);
    Timer_Controller_Version_Number  : out std_logic_vector(63 downto 0);
    Timer_Controller_Version_Ready   : out std_logic; 
    Timer_Controller_Version_Request : in  std_logic;
    Module_Number                    : in  std_logic_vector(7 downto 0);
    One_mSEC_Pulse                   : out std_logic
    );

end Timer_Controller;

architecture Arch_DUT of Timer_Controller is
  
--type PPS_States is (PPS_Off, PPS_Trigger,PPS_Wait, PPS_Int_On, PPS_Int_Off);  

--Signal PPS_State           : PPS_States; 
  
signal One_mS_Enable_i     : std_logic;
signal PPS_Pulse           : std_logic;
signal One_mS_Cnt_i        : std_logic_vector(15 downto 0);
signal Timer_Sec_Reg_1_i   : std_logic_vector(31 downto 0);
signal Timer_mSec_Reg_1_i  : std_logic_vector(15 downto 0);
signal PPS_i               : std_logic_vector(1 downto 0);
signal One_mSEC_Pulse_i    : std_logic;

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
constant X        : std_logic_vector(7 downto 0) := X"58";
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

signal Timer_Controller_Version_Name_i   : std_logic_vector(255 downto 0); 
signal Timer_Controller_Version_Number_i : std_logic_vector(63 downto 0);  

  begin
-- Inputs

-- Outputs
Timer_Sec_Reg_1   <= Timer_Sec_Reg_1_i;
Timer_mSec_Reg_1  <= Timer_mSec_Reg_1_i;
One_mSEC_Pulse    <= One_mSEC_Pulse_i;

Time_Driver: process (CLK_I, RST_I)
             
    variable bit_cnt_OmS       : integer range 0 to 60000;            

    begin
      if RST_I = '0' then         
         bit_cnt_OmS                       := 0;  
         One_mSEC_Pulse_i                  <= '0'; 
         PPS_Pulse                         <= '0';      
         One_mS_Cnt_i                      <= (others => '0');  
         PPS_i                             <= (others => '0');                
         Timer_Sec_Reg_1_i                 <= (others => '0');
         Timer_mSec_Reg_1_i                <= (others => '0');  
         Timer_Controller_Version_Name     <= (others => '0');
         Timer_Controller_Version_Name_i   <= (others => '0');
         Timer_Controller_Version_Number   <= (others => '0'); 
         Timer_Controller_Version_Number_i <= (others => '0');
         Timer_Controller_Version_Ready    <= '0';      
                     report "The version number of Timer_Controller is 1.1." severity note;              -- Version 1.0       
      elsif CLK_I'event and CLK_I = '1' then

      Timer_Controller_Version_Name_i   <= T & I & M & E & R & Space & C & O & N & T & R & O & L & L & E & R &
                                           Space & Space & Space & Space & Space & Space & Space & Space &
                                           Space & Space & Space & Space & Space & Space & Space & Space;
                                           
      Timer_Controller_Version_Number_i <= Zero & Zero & Dot & Zero & One  & Dot & Zero & One;  
      
      if Module_Number = X"09" then
         if Timer_Controller_Version_Request = '1' then
            Timer_Controller_Version_Ready  <= '1';
            Timer_Controller_Version_Name   <= Timer_Controller_Version_Name_i;
            Timer_Controller_Version_Number <= Timer_Controller_Version_Number_i;  
         else
            Timer_Controller_Version_Ready  <= '0';
         end if;
      else   
            Timer_Controller_Version_Ready  <= '0'; 
      end if; 

-- Bit clock 50MHz = 20 nSec = 0 to 49999 per Sec
 
-- Sync clock to PPS
        PPS_i <= PPS_i(0) & PPS_In;

        if PPS_i = X"01" then
           PPS_Pulse <= '1';
        else
           PPS_Pulse <= '0';
        end if; 

        if PPS_Pulse = '1' then       
           One_mS_Cnt_i   <= X"0000";   --X"0001"; 
           bit_cnt_OmS    := 1; --0;
        end if;   

-- Sync time to Station Controller
        if SET_Timer = '1' then
           Timer_Sec_Reg_1_i  <= Timer_Sec_Reg;
           Timer_mSec_Reg_1_i <= Timer_mSec_Reg;
        else
           -- FPGA mSec Clock
           if bit_cnt_OmS = 50000 then                         
              bit_cnt_OmS       := 1; --0;  
              -- FPGA Sec Clock                        
              if (Timer_mSec_Reg_1_i + '1') = X"03E8" then
                 Timer_mSec_Reg_1_i  <= X"0000"; -- X"0001";          
                 Timer_Sec_Reg_1_i   <= Timer_Sec_Reg_1_i + '1';
              else
                 Timer_mSec_Reg_1_i <= Timer_mSec_Reg_1_i + '1';
              end if;   
              One_mSEC_Pulse_i  <= '1';
           else
              bit_cnt_OmS       := bit_cnt_OmS + 1;
              One_mSEC_Pulse_i  <= '0';
           end if;

        end if;  
       
      end if;
    end process Time_Driver;  
  end Arch_DUT;

