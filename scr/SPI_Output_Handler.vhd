-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- Kutunse SPI Addressable Port for AD7888 ADC
--
-- The firmware performs the following functions:
--
-- IConfiguration of the device.
-- The user can read the channels at any time, the data is only valid for
-- The method would be to place the address in the ADR_I register and issue a WE_
-- I signal for one ckl cycle only,one clock later the DAT_O will have the four
-- channel As below.
--
-- Signals and registers
-- Bit_Rate_Enable:  this signal is used for the 2Mhz clock for the SPI driver
--
-- Written by  : Raphael van Rensburg
-- Tested      : 13/02/2012 Simulation only - Initialiation. SPI read and writes,
--               data
--             : Test do file is SPI_Output.do
-- Last update : 14/02/2012 - Initial release  Version 1.0
-- Edited By   : Glen Taylor
--             : 28/06/2013 - Removed Test LED signal
--                            Commented the SPI_data_o as this is not used in
--                            this module, but should you required this module
--                            to be an I/O remove the commented three line and add the
--                            data out to the Entity.
-- Tested      : 28/06/2013 Simulation only - Initialiation. SPI read and writes,
--               data
--             : Test do file is ASC_SPI_Output.do
-- Outstanding : None

---------------------
---------------------
-- Last update          : Monde Manzini 06/02/2017  
--                      : Updated Header
--                      : Added Version Control
-- Version              : 1.1 
-- Change Note          : None

---------------------
---------------------
-- Last update          : Monde Manzini 22/08/2018  
--                      : Changed all the wait counters with 5 from 5 to 50
-- Version              : 1.2 
-- Change Note          : None

-- Updated By           : Monde Manzini
-- Version              : 1.3 24/08/2018 
--                      : Added 'nots' on the SPI Output Data Ports for reply to software
-- Version              : 1.4 15/11/2018 
--                      : Added Dig_Out Request from Mux 
-- Tested               : 22/08/2018
-- Type of Test         : (Simulation only).
-- Test Bench file Name : SPI_Output_Handler_Test_Bench
-- located at           : (https://katfs.kat.ac.za/svnAfricanArray/Software
--                        Repository/CommonCode/ScrCommon)
-- Test do file         : SPI_Output_Handler_Test_Bench.do
-- located at            (https://katfs.kat.ac.za/svnAfricanArray/Software
--                        Repository/CommonCode/Modelsim)
-- Outstanding          : Integrated testing with RF Controller Lab Standalone Rev.2
--                        and RF Controller ATP Rev.2
-- Outstanding          : Integrated testing with RF Controller Lab Standalone Rev.2
--                        and RF Controller ATP Rev.2

-- Edited by            : Monde Manzini
-- Version              : 1.1 19/11/2018  
--                      : Replaced Sample Rate with Request signal from Mux
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity SPI_Output_Handler is

  port (
    -- General Signals
       RST_I                : in  std_logic;
       CLK_I                : in  std_logic;
       SPI_Outport_1        : in  std_logic_vector(7 downto 0);
       SPI_Outport_2        : in  std_logic_vector(7 downto 0);
       SPI_Outport_3        : in  std_logic_vector(7 downto 0);
       SPI_Outport_4        : in  std_logic_vector(7 downto 0);
       SPI_Outport_5        : in  std_logic_vector(7 downto 0);
       SPI_Outport_6        : in  std_logic_vector(7 downto 0);
       SPI_Outport_7        : in  std_logic_vector(7 downto 0);
       SPI_Outport_8        : in  std_logic_vector(7 downto 0);
       SPI_Inport_1         : out std_logic_vector(7 downto 0);
       SPI_Inport_2         : out std_logic_vector(7 downto 0);
       SPI_Inport_3         : out std_logic_vector(7 downto 0);
       SPI_Inport_4         : out std_logic_vector(7 downto 0);
       SPI_Inport_5         : out std_logic_vector(7 downto 0);
       SPI_Inport_6         : out std_logic_vector(7 downto 0);
       SPI_Inport_7         : out std_logic_vector(7 downto 0);
       SPI_Inport_8         : out std_logic_vector(7 downto 0);
       SPI_Data_in          : in  std_logic_vector(15 downto 0);
       Input_Ready          : in  std_logic;
       Output_SPI_Data_out  : out std_logic_vector(15 downto 0);
       Output_Data_ready    : out std_logic;
       Output_Ready         : out std_logic;
       Output_Card_Select   : out std_logic;       
       busy                 : in  std_logic;
       Module_Number                      : in  std_logic_vector(7 downto 0);
       SPI_Output_Handler_Version_Request : in  std_logic;
       SPI_Output_Handler_Version_Name    : out std_logic_vector(255 downto 0); 
       SPI_Output_Handler_Version_Number  : out std_logic_vector(63 downto 0);
       SPI_Output_Handler_Version_Ready   : out std_logic; 
       Dig_Out_Request      : in  std_logic
       );
  
end    SPI_Output_Handler;

architecture Arch_DUT of SPI_Output_Handler is

  constant No_Op                 : std_logic_vector(7 downto 0)             := X"00";
  constant Config                : std_logic_vector(7 downto 0)             := X"04";
  constant Config_Transition     : std_logic_vector(7 downto 0)             := X"06";
  constant Config_1              : std_logic_vector(7 downto 0)             := X"09";
  constant Config_2              : std_logic_vector(7 downto 0)             := X"0A";
  constant Config_3              : std_logic_vector(7 downto 0)             := X"0B";
  constant Config_4              : std_logic_vector(7 downto 0)             := X"0C";  
  constant Config_5              : std_logic_vector(7 downto 0)             := X"0D";
  constant Config_6              : std_logic_vector(7 downto 0)             := X"0E";
  constant Config_7              : std_logic_vector(7 downto 0)             := X"0F";
  constant output                : std_logic_vector(7 downto 0)             := X"55";
  constant Inout_w_PU            : std_logic_vector(7 downto 0)             := X"7F";  

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

signal SPI_Output_Handler_Version_Name_i   : std_logic_vector(255 downto 0); 
signal SPI_Output_Handler_Version_Number_i : std_logic_vector(63 downto 0); 

  signal SPI_data_i              : std_logic_vector(15 downto 0);
  signal Output_Data_Ready_i     : std_logic;
  signal Lock		             : std_logic; 
  signal Trigger	             : std_logic;
  signal Card_Select_i           : std_logic; 
  
  begin
    Output_Card_Select  <= Card_Select_i;
    Output_Data_Ready   <= Output_Data_Ready_i;
    Output_SPI_Data_out <= SPI_data_i;
    
    SPI_Initialization: process(RST_I,CLK_I)
      
        variable bit_cnt       : integer range 0 to 1024;
        variable bit_number    : integer range 0 to 16;
        variable Device_number : integer range 0 to 4;
        variable int_cnt       : integer range 0 to 100;  -- initialization counter
        variable wait_cnt      : integer range 0 to 100;-- wait counter
        variable Delay_cnt     : integer range 0 to 1000;-- wait counter         
    begin
      if RST_I = '0' then
         bit_cnt                := 0;
         lock                   <= '0';
         Output_Data_Ready_i    <= '0';
         Output_Ready           <= '0';
         int_cnt                := 0;
         wait_cnt	              := 0;
         SPI_data_i             <= (others => '0');
         --
         SPI_Inport_1       <= (others => '0');
         SPI_Inport_2       <= (others => '0');   
         SPI_Inport_3       <= (others => '0');     
         SPI_Inport_4       <= (others => '0');
         SPI_Inport_5       <= (others => '0');
         SPI_Inport_6       <= (others => '0');   
         SPI_Inport_7       <= (others => '0');     
         SPI_Inport_8       <= (others => '0');
         --
      elsif CLK_I'event and CLK_I = '1' then
         -- Module_Name and Module_Number Updater
         SPI_Output_Handler_Version_Name_i   <= S & P & I & Space & O & U & T & P & U & T & Space & H & A & N & D & L & E & R &
         Space & Space & Space & Space & Space & Space & Space & 
         Space & Space & Space & Space & Space & Space & Space;
         
         SPI_Output_Handler_Version_Number_i <= Zero & Zero & Dot & Zero & One  & Dot & Zero & Two;

         if Module_Number = X"03" then
            if SPI_Output_Handler_Version_Request = '1' then
               SPI_Output_Handler_Version_Ready   <= '1';
               SPI_Output_Handler_Version_Name    <= SPI_Output_Handler_Version_Name_i;
               SPI_Output_Handler_Version_Number  <= SPI_Output_Handler_Version_Number_i;  
            else
               SPI_Output_Handler_Version_Ready <= '0';
            end if;
         else   
            SPI_Output_Handler_Version_Ready <= '0'; 
         end if;

         if Dig_Out_Request = '1' then
            Trigger     <= '1';
            bit_cnt     := 0;                      
          else
            Trigger     <= '0';               
         end if;
-------------------------------------------------------------------------------
-- Card 1 Configuration
-------------------------------------------------------------------------------          
       if int_cnt = 0 and busy = '0' and Lock = '0' then
          Card_Select_i         <=  '0';
          SPI_data_i            <= Config & X"01";
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 1 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;
          
       elsif int_cnt = 2 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_Transition & X"00";
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 3 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;    
          
       elsif int_cnt = 4 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_1 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 5 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;        
          
       elsif int_cnt = 6 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_2 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 7 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;        
          
       elsif int_cnt = 8 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_3 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 9 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;        
          
       elsif int_cnt = 10 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_4 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 11 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;      
          
       elsif int_cnt = 12 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_5 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 13 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;
          
       elsif int_cnt = 14 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_6 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 15 and busy = '0' and Lock = '0' then          
           if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;      
          
       elsif int_cnt = 16 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_7 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 17 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;        
-------------------------------------------------------------------------------
-- Card 2 Configuration
-------------------------------------------------------------------------------
       elsif int_cnt = 18 and busy = '0' and Lock = '0' then
          Card_Select_i         <=  '1';
          SPI_data_i            <= Config & X"01";
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt              := 0;
          
       elsif int_cnt = 19 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;
          
       elsif int_cnt = 20 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_Transition & X"00";
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 21 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;    
          
       elsif int_cnt = 22 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_1 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 23 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;        
          
       elsif int_cnt = 24 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_2 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 25 and busy = '0' and Lock = '0' then          
           if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;        
          
       elsif int_cnt = 26 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_3 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 27 and busy = '0' and Lock = '0' then          
           if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;        
          
       elsif int_cnt = 28 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_4 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 29 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;      
          
       elsif int_cnt = 30 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_5 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 31 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;
          
       elsif int_cnt = 32 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_6 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 33 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;      
          
       elsif int_cnt = 34 and busy = '0' and Lock = '0' then
          SPI_data_i            <= Config_7 & output;
          Output_Data_Ready_i   <= '1';
          int_cnt               := int_cnt + 1;
          lock                  <= '1';
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 35 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;        
-------------------------------------------------------------------------------
--Card 1 Output Write
-------------------------------------------------------------------------------          
       elsif int_cnt = 36 then  
          int_cnt               := int_cnt + 1;
          Output_Ready          <= '0'; 
          wait_cnt              := 5;
          
       elsif int_cnt = 37 then  
          wait_cnt              := 5;
          if Trigger  = '1' then
             int_cnt            := int_cnt + 1;
          end if;
          
       elsif int_cnt = 38 and busy = '0' and Lock = '0'  then
          Card_Select_i         <=  '0';
          SPI_data_i            <= X"44" & (not SPI_Outport_1);
          Output_Data_Ready_i   <= '1';
          lock                  <= '1';
          int_cnt               := int_cnt + 1;
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 39 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt            := int_cnt + 1;
             SPI_Inport_1       <= not SPI_Data_in(7 downto 0);
          else
             Delay_cnt          := Delay_cnt + 1;
          end if;
          
       elsif int_cnt = 40 and busy = '0' and Lock = '0' then
          SPI_data_i            <= X"4C" & (not SPI_Outport_2);
          Output_Data_Ready_i   <= '1';
          lock                  <= '1';
          int_cnt               := int_cnt + 1;
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 41 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt            := int_cnt + 1;
             SPI_Inport_2       <= not SPI_Data_in(7 downto 0);
          else
             Delay_cnt          := Delay_cnt + 1;
          end if;        
          
       elsif int_cnt = 42 and busy = '0' and Lock = '0' then
          SPI_data_i            <= X"54" & (not SPI_Outport_3); 
          Output_Data_Ready_i   <= '1';
          lock                  <= '1';
          int_cnt               := int_cnt + 1;
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 43 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt            := int_cnt + 1;
             SPI_Inport_3       <= not SPI_Data_in(7 downto 0);
          else
             Delay_cnt          := Delay_cnt + 1;
          end if;       
          
       elsif int_cnt = 44 and busy = '0' and Lock = '0' then          
          SPI_data_i            <= X"5C" & (not SPI_Outport_4);  
          Output_Data_Ready_i   <= '1';
          lock                  <= '1';
          int_cnt               := int_cnt + 1;
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 45 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt        := int_cnt + 1;
             SPI_Inport_4   <= not SPI_Data_in(7 downto 0);
          else
             Delay_cnt      := Delay_cnt + 1;
          end if;
          
        elsif int_cnt = 46 and busy = '0' and Lock = '0' then
           SPI_data_i           <= X"00" & X"00";  
           Output_Data_Ready_i  <= '1';
           lock                 <= '1';
           int_cnt              := int_cnt + 1;
           wait_cnt             := 50;
           Delay_cnt            := 0;
           
       elsif int_cnt = 47 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt     := int_cnt + 1;
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;        
-------------------------------------------------------------------------------
-- Card 2 Output Write
-------------------------------------------------------------------------------
       elsif int_cnt = 48 and busy = '0' and Lock = '0'  then
          Card_Select_i         <=  '1';
          SPI_data_i            <= X"44" & (not SPI_Outport_5);
          Output_Data_Ready_i   <= '1';
          lock                  <= '1';
          int_cnt               := int_cnt + 1;
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 49 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt        := int_cnt + 1;
             SPI_Inport_5   <= not SPI_Data_in(7 downto 0);
          else
             Delay_cnt      := Delay_cnt + 1;
          end if;
          
       elsif int_cnt = 50 and busy = '0' and Lock = '0' then
          SPI_data_i            <= X"4C" & (not SPI_Outport_6);
          Output_Data_Ready_i   <= '1';
          lock                  <= '1';
          int_cnt               := int_cnt + 1;
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 51 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt       := int_cnt + 1;
             SPI_Inport_6  <= not SPI_Data_in(7 downto 0);
          else
             Delay_cnt   := Delay_cnt + 1;
          end if;        
          
       elsif int_cnt = 52 and busy = '0' and Lock = '0' then
          SPI_data_i            <= X"54" & (not SPI_Outport_7); 
          Output_Data_Ready_i   <= '1';
          lock                  <= '1';
          int_cnt               := int_cnt + 1;
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 53 and busy = '0' and Lock = '0' then          
           if Delay_cnt = 500 then
             int_cnt        := int_cnt + 1;
             SPI_Inport_7   <= not SPI_Data_in(7 downto 0);
          else
             Delay_cnt      := Delay_cnt + 1;
          end if;       
          
       elsif int_cnt = 54 and busy = '0' and Lock = '0' then          
          SPI_data_i            <= X"5C" & (not SPI_Outport_8);  
          Output_Data_Ready_i   <= '1';
          lock                  <= '1';
          int_cnt               := int_cnt + 1;
          wait_cnt              := 50;
          Delay_cnt             := 0;
          
       elsif int_cnt = 55 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt            := int_cnt + 1;
             SPI_Inport_8       <= not SPI_Data_in(7 downto 0);
          else
             Delay_cnt          := Delay_cnt + 1;
          end if;
          
        elsif int_cnt = 56 and busy = '0' and Lock = '0' then
           SPI_data_i           <= X"00" & X"00";  
           Output_Data_Ready_i  <= '1';
           lock                 <= '1';
           int_cnt              := int_cnt + 1;
           wait_cnt             := 50;
           Delay_cnt            := 0;
           
       elsif int_cnt = 57 and busy = '0' and Lock = '0' then          
          if Delay_cnt = 500 then
             int_cnt            := int_cnt + 1;
          else
             Delay_cnt          := Delay_cnt + 1;
          end if;        
-------------------------------------------------------------------------------
-- End of Card 2 Output Write
-------------------------------------------------------------------------------             
       elsif int_cnt = 58 and busy = '0' and Lock = '0' then                    
          int_cnt        := 36;
          wait_cnt       := 50;
          Output_Ready   <= '1';
       else
          Output_Data_Ready_i <= '0';
          if wait_cnt = 0 then
             lock       <= '0';
          else
             wait_cnt   := wait_cnt - 1;
          end if;              
       end if;      
    end if;
          
    end process SPI_Initialization;          
  end Arch_DUT;


