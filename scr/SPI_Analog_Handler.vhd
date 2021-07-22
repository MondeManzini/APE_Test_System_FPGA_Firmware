-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- Ghana BM0 SPI ADC Handler
--
-- The firmware performs the following functions:
--
-- IConfiguration of the device.
-- Performing a read of each channel ever 0.75mSec.
-- Data is stored in the following address and the data will be stored
-- the user can read the channels at any time, the data is only valid for
-- 1mSec and will be up dated.
-- channel As below.
--
--
-- Signals and registers
-- Bit_Rate_Enable:  this signal is used for the 2Mhz clock for the SPI driver
-- TEN_PPS        :  is the 100mSec input signal which is used to start a conversion
--                   cycle for the next 8 ADC channels.
--
-- Firmware updated to handle 4 chip selects CS1, CS2, CS3 and CS4
-- and communicate to 3 AD7888 Chips Per Analog Card
-- Firmware uses one state machine that reads all three ADCs onthe analog card

--
-- Written by  : Raphael van Rensburg
-- Tested      : 16/02/2014
--              
-- Last update : 16/09/2014 - Monde Manzini
-- Last update : 29/05/2016 - Monde Manzini
--              - Added Analog Data Requests
--              - Added the Version Control
--              - Updated Header with date
--              - Testbench: SPI_Analog_Handler_Test_Bench located at
--                https://katfs.kat.ac.za/svnAfricanArray/SoftwareRepository/CommonCode/ScrCommon
--              - SPI_Analog_Handler_Test_Bench.do file located at
--                https://katfs.kat.ac.za/svnAfricanArray/SoftwareRepository/CommonCode/Modelsim/ 
-- Outstanding :
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.Version_Ascii.all;

entity SPI_Analog_Handler is

  port (
    -- General Signals                  
    RST_I                              : in std_logic;
    CLK_I                              : in std_logic;
    -- SPI Output
    Address_out                        : out std_logic_vector(2 downto 0);
    convert                            : out std_logic;
    CS1                                : out std_logic; 
    CS2                                : out std_logic;
    CS3                                : out std_logic;
    CS4                                : out std_logic;
    --SPI Input
    AD_data_in                         : in  std_logic_vector(15 downto 0);
    Data_valid                         : in  std_logic;    
    -- ADC Channel Outputs
    CH1_o                              : out std_logic_vector(15 downto 0);
    CH2_o                              : out std_logic_vector(15 downto 0);
    CH3_o                              : out std_logic_vector(15 downto 0);
    CH4_o                              : out std_logic_vector(15 downto 0);
    CH5_o                              : out std_logic_vector(15 downto 0);
    CH6_o                              : out std_logic_vector(15 downto 0);
    CH7_o                              : out std_logic_vector(15 downto 0);
    CH8_o                              : out std_logic_vector(15 downto 0);	 
    CH9_o                              : out std_logic_vector(15 downto 0);
    CH10_o                             : out std_logic_vector(15 downto 0);
    CH11_o                             : out std_logic_vector(15 downto 0);
    CH12_o                             : out std_logic_vector(15 downto 0);
    CH13_o                             : out std_logic_vector(15 downto 0);
    CH14_o                             : out std_logic_vector(15 downto 0);
    CH15_o                             : out std_logic_vector(15 downto 0);
    CH16_o                             : out std_logic_vector(15 downto 0);
    CH17_o                             : out std_logic_vector(15 downto 0);
    CH18_o                             : out std_logic_vector(15 downto 0);
    CH19_o                             : out std_logic_vector(15 downto 0);
    CH20_o                             : out std_logic_vector(15 downto 0);
    CH21_o                             : out std_logic_vector(15 downto 0);
    CH22_o                             : out std_logic_vector(15 downto 0);
    CH23_o                             : out std_logic_vector(15 downto 0);
    CH24_o                             : out std_logic_vector(15 downto 0);
    CH25_o                             : out std_logic_vector(15 downto 0);
    CH26_o                             : out std_logic_vector(15 downto 0);
    CH27_o                             : out std_logic_vector(15 downto 0);
    CH28_o                             : out std_logic_vector(15 downto 0);
    CH29_o                             : out std_logic_vector(15 downto 0);
    CH30_o                             : out std_logic_vector(15 downto 0);
    CH31_o                             : out std_logic_vector(15 downto 0);
    CH32_o                             : out std_logic_vector(15 downto 0);
    CH33_o                             : out std_logic_vector(15 downto 0);
    CH34_o                             : out std_logic_vector(15 downto 0);
    CH35_o                             : out std_logic_vector(15 downto 0);
    CH36_o                             : out std_logic_vector(15 downto 0);
    CH37_o                             : out std_logic_vector(15 downto 0);
    CH38_o                             : out std_logic_vector(15 downto 0);
    CH39_o                             : out std_logic_vector(15 downto 0);
    CH40_o                             : out std_logic_vector(15 downto 0);
    CH41_o                             : out std_logic_vector(15 downto 0);
    CH42_o                             : out std_logic_vector(15 downto 0);
    CH43_o                             : out std_logic_vector(15 downto 0);
    CH44_o                             : out std_logic_vector(15 downto 0);
    CH45_o                             : out std_logic_vector(15 downto 0);
    CH46_o                             : out std_logic_vector(15 downto 0);
    CH47_o                             : out std_logic_vector(15 downto 0);
    CH48_o                             : out std_logic_vector(15 downto 0); 
    Data_Ready                         : out std_logic;
    Ana_In_Request                     : in  std_logic;
    Module_Number                      : in  std_logic_vector(7 downto 0);
    SPI_Analog_Handler_Version_Request : in  std_logic;
    SPI_Analog_Handler_Version_Name    : out std_logic_vector(255 downto 0); 
    SPI_Analog_Handler_Version_Number  : out std_logic_vector(63 downto 0);
    SPI_Analog_Handler_Version_Ready   : out std_logic 
    ); 

end SPI_Analog_Handler;

architecture Arch_DUT of SPI_Analog_Handler is

  constant CH0 : std_logic_vector(2 downto 0) := b"000";
  constant CH1 : std_logic_vector(2 downto 0) := b"001";
  constant CH2 : std_logic_vector(2 downto 0) := b"010";
  constant CH3 : std_logic_vector(2 downto 0) := b"011";
  constant CH4 : std_logic_vector(2 downto 0) := b"100";
  constant CH5 : std_logic_vector(2 downto 0) := b"101";
  constant CH6 : std_logic_vector(2 downto 0) := b"110";
  constant CH7 : std_logic_vector(2 downto 0) := b"111";

signal SPI_Analog_Handler_Version_Name_i   : std_logic_vector(255 downto 0); 
signal SPI_Analog_Handler_Version_Number_i : std_logic_vector(63 downto 0); 

  type SPI_Drive_states is (CS_Off,Idle,
-- Chip one  
                                Convertion_Dummy_1,Wait_Dummy_1,
                                Convertion_CH1,Wait_CH1,Convertion_CH2,Wait_CH2,
			        Convertion_CH3,Wait_CH3,Convertion_CH4,Wait_CH4,
				Convertion_CH5,Wait_CH5,Convertion_CH6,Wait_CH6,
				Convertion_CH7,Wait_CH7,Convertion_CH8,Wait_CH8,
-- Chip two
                                Convertion_Dummy_2,Wait_Dummy_2,
                                Convertion_CH9,Wait_CH9,Convertion_CH10,Wait_CH10,
			        Convertion_CH11,Wait_CH11,Convertion_CH12,Wait_CH12,
				Convertion_CH13,Wait_CH13,Convertion_CH14,Wait_CH14,
				Convertion_CH15,Wait_CH15,Convertion_CH16,Wait_CH16,
-- Chip three										  
				Convertion_Dummy_3,Wait_Dummy_3,
                                Convertion_CH17,Wait_CH17,Convertion_CH18,Wait_CH18,
			        Convertion_CH19,Wait_CH19,Convertion_CH20,Wait_CH20,
				Convertion_CH21,Wait_CH21,Convertion_CH22,Wait_CH22,
				Convertion_CH23,Wait_CH23,Convertion_CH24,Wait_CH24,
-- Chip four										  
				Convertion_Dummy_4,Wait_Dummy_4,
                                Convertion_CH25,Wait_CH25,Convertion_CH26,Wait_CH26,
			        Convertion_CH27,Wait_CH27,Convertion_CH28,Wait_CH28,
				Convertion_CH29,Wait_CH29,Convertion_CH30,Wait_CH30,
				Convertion_CH31,Wait_CH31,Convertion_CH32,Wait_CH32,
-- Chip five										  
				Convertion_Dummy_5,Wait_Dummy_5,
                                Convertion_CH33,Wait_CH33,Convertion_CH34,Wait_CH34,
			        Convertion_CH35,Wait_CH35,Convertion_CH36,Wait_CH36,
				Convertion_CH37,Wait_CH37,Convertion_CH38,Wait_CH38,
				Convertion_CH39,Wait_CH39,Convertion_CH40,Wait_CH40,
-- Chip six										  
				Convertion_Dummy_6,Wait_Dummy_6,
                                Convertion_CH41,Wait_CH41,Convertion_CH42,Wait_CH42,
			        Convertion_CH43,Wait_CH43,Convertion_CH44,Wait_CH44,
				Convertion_CH45,Wait_CH45,Convertion_CH46,Wait_CH46,
				Convertion_CH47,Wait_CH47,Convertion_CH48,Wait_CH48,
-- Chip seven										  
				wait_Idle);
  
  signal SPI_Drive_state        : SPI_Drive_states;  

  signal EnableRateGenarator    : std_logic;
  signal Bit_Rate_Enable        : std_logic;
  signal SPI_data_o             : std_logic_vector(15 downto 0);
  signal SPI_data_i             : std_logic_vector(15 downto 0);
 
  signal CS1_i                  : std_logic;
  signal CS2_i                  : std_logic;
  signal CS3_i                  : std_logic;
  signal CS4_i                  : std_logic;
  signal Send_i                 : std_logic;
  signal CH1_i                  : std_logic_vector(15 downto 0);
  signal CH2_i                  : std_logic_vector(15 downto 0);
  signal CH3_i                  : std_logic_vector(15 downto 0);
  signal CH4_i                  : std_logic_vector(15 downto 0);
  signal CH5_i                  : std_logic_vector(15 downto 0);
  signal CH6_i                  : std_logic_vector(15 downto 0);
  signal CH7_i                  : std_logic_vector(15 downto 0);
  signal CH8_i                  : std_logic_vector(15 downto 0);
  signal CH9_i                  : std_logic_vector(15 downto 0);
  signal CH10_i                 : std_logic_vector(15 downto 0);
  signal CH11_i                 : std_logic_vector(15 downto 0);
  signal CH12_i                 : std_logic_vector(15 downto 0);
  signal CH13_i                 : std_logic_vector(15 downto 0);
  signal CH14_i                 : std_logic_vector(15 downto 0);
  signal CH15_i                 : std_logic_vector(15 downto 0);
  signal CH16_i                 : std_logic_vector(15 downto 0);
  signal CH17_i                 : std_logic_vector(15 downto 0);
  signal CH18_i                 : std_logic_vector(15 downto 0);
  signal CH19_i                 : std_logic_vector(15 downto 0);
  signal CH20_i                 : std_logic_vector(15 downto 0);
  signal CH21_i                 : std_logic_vector(15 downto 0);
  signal CH22_i                 : std_logic_vector(15 downto 0);
  signal CH23_i                 : std_logic_vector(15 downto 0);
  signal CH24_i                 : std_logic_vector(15 downto 0);
  signal CH25_i                 : std_logic_vector(15 downto 0);
  signal CH26_i                 : std_logic_vector(15 downto 0);
  signal CH27_i                 : std_logic_vector(15 downto 0);
  signal CH28_i                 : std_logic_vector(15 downto 0);
  signal CH29_i                 : std_logic_vector(15 downto 0);
  signal CH30_i                 : std_logic_vector(15 downto 0);
  signal CH31_i                 : std_logic_vector(15 downto 0);
  signal CH32_i                 : std_logic_vector(15 downto 0);
  signal CH33_i                 : std_logic_vector(15 downto 0);
  signal CH34_i                 : std_logic_vector(15 downto 0);
  signal CH35_i                 : std_logic_vector(15 downto 0);
  signal CH36_i                 : std_logic_vector(15 downto 0);
  signal CH37_i                 : std_logic_vector(15 downto 0);
  signal CH38_i                 : std_logic_vector(15 downto 0);
  signal CH39_i                 : std_logic_vector(15 downto 0);
  signal CH40_i                 : std_logic_vector(15 downto 0);
  signal CH41_i                 : std_logic_vector(15 downto 0);
  signal CH42_i                 : std_logic_vector(15 downto 0);
  signal CH43_i                 : std_logic_vector(15 downto 0);
  signal CH44_i                 : std_logic_vector(15 downto 0);
  signal CH45_i                 : std_logic_vector(15 downto 0);
  signal CH46_i                 : std_logic_vector(15 downto 0);
  signal CH47_i                 : std_logic_vector(15 downto 0);
  signal CH48_i                 : std_logic_vector(15 downto 0);
  signal data_ok                : std_logic;
  signal Data_Ready_i           : std_logic;  
  
  begin
    
Data_Ready     <= Data_Ready_i;
CS1            <= CS1_i;
CS2            <= CS2_i;
CS3            <= CS3_i;
CS4            <= CS4_i;
CH1_o          <= CH1_i;
CH2_o          <= CH2_i;
CH3_o          <= CH3_i;
CH4_o          <= CH4_i;
CH5_o          <= CH5_i;
CH6_o          <= CH6_i;
CH7_o          <= CH7_i;
CH8_o          <= CH8_i;
CH9_o          <= CH9_i;
CH10_o         <= CH10_i;
CH11_o         <= CH11_i;
CH12_o         <= CH12_i;
CH13_o         <= CH13_i;
CH14_o         <= CH14_i;
CH15_o         <= CH15_i;
CH16_o         <= CH16_i;
CH17_o         <= CH17_i;
CH18_o         <= CH18_i;
CH19_o         <= CH19_i;
CH20_o         <= CH20_i;
CH21_o         <= CH21_i;
CH22_o         <= CH22_i;
CH23_o         <= CH23_i;
CH24_o         <= CH24_i;
CH25_o         <= CH25_i;
CH26_o         <= CH26_i;
CH27_o         <= CH27_i;
CH28_o         <= CH28_i;
CH29_o         <= CH29_i;
CH30_o         <= CH30_i;
CH31_o         <= CH31_i;
CH32_o         <= CH32_i;
CH33_o         <= CH33_i;
CH34_o         <= CH34_i;
CH35_o         <= CH35_i;
CH36_o         <= CH36_i;
CH37_o         <= CH37_i;
CH38_o         <= CH38_i;
CH39_o         <= CH39_i;
CH40_o         <= CH40_i;
CH41_o         <= CH41_i;
CH42_o         <= CH42_i;
CH43_o         <= CH43_i;
CH44_o         <= CH44_i;
CH45_o         <= CH45_i;
CH46_o         <= CH46_i;
CH47_o         <= CH47_i;
CH48_o         <= CH48_i;

-- SPI driver read all 8 channel automatically
    SPI_Driver: process (CLK_I, RST_I)
      variable Channel_cnt    : integer range 0 to 8;
      variable wait_cnt       : integer range 0 to 60;
      
    begin
      if RST_I = '0' then 
         Channel_cnt    	 := 0;
         wait_cnt                := 0;
         Address_out		 <= ( others => '0');
         convert                 <= '0';                 
         CH1_i 		         <= ( others => '0');
         CH2_i                   <= ( others => '0');
         CH3_i                   <= ( others => '0');
         CH4_i                   <= ( others => '0');
         CH5_i                   <= ( others => '0');
         CH6_i                   <= ( others => '0');
         CH7_i                   <= ( others => '0');
         CH8_i                   <= ( others => '0');
         CH9_i                   <= ( others => '0');
         CH10_i                  <= ( others => '0');
         CH11_i                  <= ( others => '0');
         CH12_i                  <= ( others => '0');
         CH13_i                  <= ( others => '0');
         CH14_i                  <= ( others => '0');
         CH15_i                  <= ( others => '0');
         CH16_i                  <= ( others => '0');
         CH17_i                  <= ( others => '0');
         CH18_i                  <= ( others => '0');
         CH19_i                  <= ( others => '0');
         CH20_i                  <= ( others => '0');
         CH21_i                  <= ( others => '0');
         CH22_i                  <= ( others => '0');
         CH23_i                  <= ( others => '0');
         CH24_i                  <= ( others => '0');
         CH25_i                  <= ( others => '0');
         CH26_i                  <= ( others => '0');
         CH27_i                  <= ( others => '0');
         CH28_i                  <= ( others => '0');
         CH29_i                  <= ( others => '0');
         CH30_i                  <= ( others => '0');
         CH31_i                  <= ( others => '0');
         CH32_i                  <= ( others => '0');
         CH33_i                  <= ( others => '0');
         CH34_i                  <= ( others => '0');
         CH35_i                  <= ( others => '0');
         CH36_i                  <= ( others => '0');
         CH37_i                  <= ( others => '0');
         CH38_i                  <= ( others => '0');
         CH39_i                  <= ( others => '0');
         CH40_i                  <= ( others => '0');
         CH41_i                  <= ( others => '0');
         CH42_i                  <= ( others => '0');
         CH43_i                  <= ( others => '0');
         CH44_i                  <= ( others => '0');
         CH45_i                  <= ( others => '0');
         CH46_i                  <= ( others => '0');
         CH47_i                  <= ( others => '0');
         CH48_i                  <= ( others => '0');     
         CS1_i                   <= '0';
         CS2_i                   <= '0';
         CS3_i                   <= '0';
         CS4_i                   <= '0';
         SPI_Drive_state         <= Idle;
         Data_Ready_i            <= '0';
         data_ok                 <= '0';
         SPI_Analog_Handler_Version_Name     <= (others => '0');
         SPI_Analog_Handler_Version_Name_i   <= (others => '0');
         SPI_Analog_Handler_Version_Number   <= (others => '0'); 
         SPI_Analog_Handler_Version_Number_i <= (others => '0');
         SPI_Analog_Handler_Version_Ready    <= '0'; 
         report "The version number of SPI_Analog_Handler is 00.01.01." severity note;  
      elsif CLK_I'event and CLK_I = '1' then          
                  
         SPI_Analog_Handler_Version_Name_i   <= S & P & I & Space & A & N & A & L & O & G & Space & H & A & N & D & L & E & R &
                                                Space & Space & Space & Space & Space & Space & Space & 
                                                Space & Space & Space & Space & Space & Space & Space;
                                                
         SPI_Analog_Handler_Version_Number_i <= Zero & Zero & Dot & Zero & One & Dot & Zero & One;

         if Module_Number = X"05" then
            if SPI_Analog_Handler_Version_Request = '1' then
               SPI_Analog_Handler_Version_Ready  <= '1';
               SPI_Analog_Handler_Version_Name   <= SPI_Analog_Handler_Version_Name_i;
               SPI_Analog_Handler_Version_Number <= SPI_Analog_Handler_Version_Number_i;  
            else
               SPI_Analog_Handler_Version_Ready  <= '0';
            end if;
         else   
               SPI_Analog_Handler_Version_Ready  <= '0'; 
         end if; 

-- SPI Driver CB25a State Machine
         case SPI_Drive_State is
          when Idle =>
				       CS1_i                <= '0';
               CS2_i                <= '0';
               CS3_i                <= '0';
               CS4_i                <= '0';
               if Ana_In_Request = '1' then
                  CS1_i                <= '1';
                  CS2_i                <= '0';
                  CS3_i                <= '0';
                  CS4_i                <= '0'; 
                  SPI_Drive_state      <= Convertion_Dummy_1;
               else
                  SPI_Drive_state      <= Idle;   
               end if;   
					
-- Channel zero chip 1
          when Convertion_Dummy_1 =>            
               Address_out                 <= CH0;                     -- Write Channel 0 Address
               convert                     <= '1';
 
               SPI_Drive_State             <= Wait_Dummy_1;
                              
          when Wait_Dummy_1 =>
               convert                     <= '0';                              
               if Data_valid = '1' then
                  wait_cnt                 := 0;
		              data_ok                <= '1';
               end if; 
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok               <= '0';	
                     SPI_Drive_State       <= Convertion_CH1;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;   
               end if; 
                            
-- Channel one chip 1
          when Convertion_CH1 =>            
               Address_out                 <= CH1;
               convert                     <= '1';
               SPI_Drive_State             <= Wait_CH1;
                             
          when Wait_CH1 =>
               convert                     <= '0';                              
               if Data_valid = '1' then
                  wait_cnt                 := 0;
                  CH1_i                    <= AD_data_in;
                  data_ok                  <= '1';
               end if; 
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok               <= '0';                 
		               SPI_Drive_State       <= Convertion_CH2;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if; 
               end if;	
               				
-- Channel two chip 1
          when Convertion_CH2 =>            
               Address_out                 <= CH2;
               convert        	           <= '1';
               SPI_Drive_State             <= Wait_CH2;
               
          when Wait_CH2 =>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;
                  CH2_i                    <= AD_data_in;
                  data_ok                  <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH3;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;                  
               end if; 
                             
-- Channel three chip 1
          when Convertion_CH3 =>            
               Address_out                 <= CH3;
               convert                     <= '1';
               SPI_Drive_State             <= Wait_CH3;
               
          when Wait_CH3=>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;
                  CH3_i                    <= AD_data_in;
                  data_ok                  <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH4;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;  
                            
-- Channel Four chip 1
          when Convertion_CH4 =>            
               Address_out                 <= CH4;
               convert                     <= '1';
               SPI_Drive_State             <= Wait_CH4;
               
          when Wait_CH4=>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;
                  CH4_i                    <= AD_data_in;
                  data_ok                  <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                                  
                  data_ok                  <= '0';
                  SPI_Drive_State          <= Convertion_CH5;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if; 
               
-- Channel Five chip 1
          when Convertion_CH5 =>            
               Address_out                 <= CH5;
               convert                     <= '1';
               SPI_Drive_State             <= Wait_CH5;
               
          when Wait_CH5=>
               convert                     <= '0';               
               if Data_valid = '1' then
                  wait_cnt                 := 0;
                  CH5_i                    <= AD_data_in;
                  data_ok                  <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then                                  
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH6;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if; 
               end if;
                
-- Channel Six chip 1
          when Convertion_CH6 =>            
               Address_out                 <= CH6;
               convert                     <= '1';
               SPI_Drive_State             <= Wait_CH6;
               
          when Wait_CH6 =>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;
                  CH6_i                    <= AD_data_in;
                  data_ok                  <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then                                                   
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH7;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;     
                          
-- Channel Seven chip 1
          when Convertion_CH7 =>            
               Address_out                 <= CH7;
               convert                     <= '1';
               SPI_Drive_State             <= Wait_CH7;
               
          when Wait_CH7      =>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;
                  CH7_i                    <= AD_data_in;
                  data_ok                  <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                                                   
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH8;
               
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;
               
-- Channel Eight chip 1
          when Convertion_CH8 =>            
               Address_out                 <= CH0;
               convert                     <= '1';
               SPI_Drive_State             <= Wait_CH8;
               
          when Wait_CH8=>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;
                  CH8_i                    <= AD_data_in;
                  data_ok                  <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                                                   
                     data_ok               <= '0';
                     CS1_i                 <= '0';
                     CS2_i                 <= '1';
                     CS3_i                 <= '0';
                     CS4_i                 <= '0';
                     --Data_Ready_i          <= '1';        -- Temp
  --                   SPI_Drive_State       <= wait_Idle;  -- Temp
                     SPI_Drive_State       <= Convertion_Dummy_2;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;	
               									
-- End of Chip 1
-- Start of Chip 2
-- Channel zero chip 2
          when Convertion_Dummy_2 =>            
               Address_out                 <= CH0;
               convert                     <= '1';
               SPI_Drive_State             <= Wait_Dummy_2;
               
          when Wait_Dummy_2 =>
               convert                     <= '0';                              
               if Data_valid = '1' then
                  wait_cnt                 := 0;
                  data_ok                  <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then                                  
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH9;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if; 
                             
-- Channel one chip 2
          when Convertion_CH9 =>            
               Address_out                 <= CH1;
               convert                     <= '1';
               --CS1_i                       <= '0';
               --CS2_i                       <= '1';
               SPI_Drive_State             <= Wait_CH9;

          when Wait_CH9 =>
               convert                     <= '0';                              
               if Data_valid = '1' then
                  wait_cnt                 := 0;                 
                  CH9_i                    <= AD_data_in;
                  data_ok                  <= '1';
               end if;               
               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH10;
							
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;
               
-- Channel two chip 2
          when Convertion_CH10 =>            
               Address_out                 <= CH2;
               convert  	                <= '1';
               --CS1_i                       <= '0';
               --CS2_i                       <= '1';
               SPI_Drive_State             <= Wait_CH10;

          when Wait_CH10 =>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;                 
                  CH10_i                   <= AD_data_in;
                  data_ok                  <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                                  
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH11;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;   
                           
-- Channel three chip 2
          when Convertion_CH11 =>            
               Address_out                 <= CH3;
               convert                     <= '1';
               --CS1_i                       <= '0';
               --CS2_i                       <= '1';
               SPI_Drive_State             <= Wait_CH11;

          when Wait_CH11 =>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;                 
                  CH11_i                   <= AD_data_in;
                  data_ok                  <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                                  
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH12;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;    
                          
-- Channel Four chip 2
          when Convertion_CH12 =>            
               Address_out                 <= CH4;
               convert                     <= '1';
               --CS1_i                       <= '0';
               --CS2_i                       <= '1';
               SPI_Drive_State             <= Wait_CH12;

          when Wait_CH12   =>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;                 
                  CH12_i                   <= AD_data_in;
                  data_ok                  <= '1';
               end if;
               
               if data_ok = '1' then                 
                  if wait_cnt = 60 then                 
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH13;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if; 
               
-- Channel Five chip 2
          when Convertion_CH13  =>            
               Address_out                 <= CH5;
               convert                     <= '1';
               --CS1_i                       <= '0';
               --CS2_i                       <= '1';
               SPI_Drive_State             <= Wait_CH13;

          when Wait_CH13  =>
               convert                     <= '0';               
               if Data_valid = '1' then
                  wait_cnt                 := 0;                 
                  CH13_i                   <= AD_data_in;
                  data_ok                  <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then                                  
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH14;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if; 
               
-- Channel Six chip 2
          when Convertion_CH14 =>            
               Address_out                 <= CH6;
               convert                     <= '1';
               --CS1_i                       <= '0';
               --CS2_i                       <= '1';
               SPI_Drive_State             <= Wait_CH14;
               
          when Wait_CH14   =>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;                 
                  CH14_i                   <= AD_data_in;
                  data_ok                  <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then                                  
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH15;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;    
                           
-- Channel Seven chip 2
          when Convertion_CH15 =>            
               Address_out                 <= CH7;
               convert                     <= '1';
               --CS1_i                       <= '0';
               --CS2_i                       <= '1';
               SPI_Drive_State             <= Wait_CH15;
               
          when Wait_CH15  =>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;                 
                  CH15_i                   <= AD_data_in;
                  data_ok                  <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                                  
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH16;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;   
               end if;
               
-- Channel Eight chip 2
          when Convertion_CH16 =>            
               Address_out                 <= CH0;
               convert                     <= '1';
               --CS1_i                       <= '0';
               --CS2_i                       <= '1';
               SPI_Drive_State             <= Wait_CH16;
               
          when Wait_CH16       =>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;
                  CH16_i                   <= AD_data_in;
                  data_ok                  <= '1';
						--Data_Ready_i             <= '1';                --Temp Remove
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                                                   
                     data_ok               <= '0';
                     CS1_i                 <= '1';
                     CS2_i                 <= '1';
                     CS3_i                 <= '0';
                     CS4_i                 <= '0';
                    -- Data_Ready_i          <= '1';        -- Temp
                     --SPI_Drive_State       <= wait_idle;
                     SPI_Drive_State       <= Convertion_Dummy_3;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;
               						
-- End of Chip 2
-- Start of Chip 3
-- Channel zero chip 3
          when Convertion_Dummy_3 =>            
               Address_out                 <= CH0;
               convert                     <= '1';
               
               SPI_Drive_State             <= Wait_Dummy_3;

          when Wait_Dummy_3 =>
               convert                     <= '0';                              
               if Data_valid = '1' then
                  wait_cnt                 := 0;                 
                  data_ok                  <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH17;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;              
-- Channel one
          when Convertion_CH17 =>            
               Address_out                 <= CH1;
               convert                     <= '1';
               --CS1_i                       <= '1';
               --CS2_i                       <= '1';
               SPI_Drive_State             <= Wait_CH17;

          when Wait_CH17 =>
               convert                     <= '0';                              
               if Data_valid = '1' then
                  wait_cnt                 := 0;                 
                  CH17_i                   <= AD_data_in;
                  data_ok                  <= '1';
               end if;               
               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH18;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;
-- Channel two
          when Convertion_CH18 =>            
               Address_out                 <= CH2;
               convert  	           <= '1';
               --CS1_i                       <= '1';
               --CS2_i                       <= '1';
               SPI_Drive_State             <= Wait_CH18;

          when Wait_CH18 =>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;                 
                  CH18_i                   <= AD_data_in;
                  data_ok                  <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH19;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;               
-- Channel three
          when Convertion_CH19 =>            
               Address_out                 <= CH3;
               convert                     <= '1';
               --CS1_i                       <= '1';
               --CS2_i                       <= '1';
               SPI_Drive_State             <= Wait_CH19;

          when Wait_CH19 =>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;                 
                  CH19_i                   <= AD_data_in;
                  data_ok                  <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH20;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if;               
-- Channel Four
          when Convertion_CH20 =>            
               Address_out                 <= CH4;
               convert                     <= '1';
               --CS1_i                       <= '1';
               --CS2_i                       <= '1';
               SPI_Drive_state             <= Wait_CH20;

          when Wait_CH20=>
               convert                     <= '0';                
               if Data_valid = '1' then
                  wait_cnt                 := 0;                 
                  CH20_i                   <= AD_data_in;
                  data_ok                  <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH21;
                  else
                     wait_cnt              := wait_cnt + 1;
                  end if;
               end if; 
-- Channel Five
          when Convertion_CH21 =>            
               Address_out                 <= CH5;
               convert                     <= '1';
               --CS1_i                       <= '1';
               --CS2_i                       <= '1';
               SPI_Drive_state             <= Wait_CH21;

          when Wait_CH21   =>
               convert                     <= '0';               
               if Data_valid = '1' then
                  wait_cnt              := 0;                 
                  CH21_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok              <= '0';
                     SPI_Drive_State      <= Convertion_CH22;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if; 
-- Channel Six
          when Convertion_CH22 =>            
               Address_out              <= CH6;
               convert                  <= '1';
               --CS1_i                    <= '1';
               --CS2_i                    <= '1';
               SPI_Drive_State          <= Wait_CH22;

          when Wait_CH22   =>
               convert           <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;                 
                  CH22_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok             <= '0';
                     SPI_Drive_State     <= Convertion_CH23;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;                
-- Channel Seven chip 3
          when Convertion_CH23 =>            
               Address_out              <= CH7;
               convert                  <= '1';
               --CS1_i                    <= '1';
               --CS2_i                    <= '1';
               SPI_Drive_State      <= Wait_CH23;
               

          when Wait_CH23=>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;                 
                  CH23_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok           <= '0';
                     SPI_Drive_State   <= Convertion_CH24;
							
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
				   end if;		
-- Channel Eight chip 3
          when Convertion_CH24 =>            
               Address_out              <= CH0;
               convert                  <= '1';
               --CS1_i                    <= '1';
               --CS2_i                    <= '1';
               SPI_Drive_State          <= Wait_CH24;	
					
          when Wait_CH24    =>
               convert           <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;                 
                  CH24_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok               <= '0';
                     CS1_i                    <= '0';
                     CS2_i                    <= '0';
                     CS3_i                    <= '1';
                     CS4_i                    <= '0';
               
		               SPI_Drive_State       <= Convertion_Dummy_4;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if; 	
					
-- End of Chip 3
-- Start of Chip 4
-- Channel zero chip 4
          when Convertion_Dummy_4 =>            
               Address_out              <= CH0;
               convert                  <= '1';
               
               SPI_Drive_State          <= Wait_Dummy_4;

          when Wait_Dummy_4 =>
               convert                  <= '0';                              
               if Data_valid = '1' then
                  wait_cnt              := 0;                 
                  data_ok               <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok            <= '0';
                     SPI_Drive_State    <= Convertion_CH25;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;              
-- Channel one chip 4
          when Convertion_CH25 =>            
               Address_out              <= CH1;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH25;

          when Wait_CH25 =>
               convert                  <= '0';                              
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH25_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok            <= '0';
                     SPI_Drive_State    <= Convertion_CH26;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;
-- Channel two chip 4
          when Convertion_CH26   =>            
               Address_out              <= CH2;
               convert  	              <= '1';
               SPI_Drive_State          <= Wait_CH26;

          when Wait_CH26 =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH26_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok             <= '0';
                     SPI_Drive_State     <= Convertion_CH27;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;               
-- Channel three chip 4
          when Convertion_CH27 =>            
               Address_out              <= CH3;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH27;

          when Wait_CH27   =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH27_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok            <= '0';
                     SPI_Drive_State    <= Convertion_CH28;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;               
-- Channel Four chip 4
          when Convertion_CH28 =>            
               Address_out              <= CH4;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH28;

          when Wait_CH28  =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH28_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok            <= '0';
                     SPI_Drive_State    <= Convertion_CH29;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if; 
-- Channel Five chip 4
          when Convertion_CH29 =>            
               Address_out              <= CH5;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH29;

          when Wait_CH29 =>
               convert                  <= '0';               
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH29_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok            <= '0';
                     SPI_Drive_State    <= Convertion_CH30;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if; 
-- Channel Six chip 4
          when Convertion_CH30 =>            
               Address_out              <= CH6;
               convert                  <= '1';
              
               SPI_Drive_State          <= Wait_CH30;

          when Wait_CH30  =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH30_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then                 
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH31;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;                
-- Channel Seven chip 4
          when Convertion_CH31  =>            
               Address_out              <= CH7;
               convert                  <= '1';
               SPI_Drive_State         <= Wait_CH31;

          when Wait_CH31=>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH31_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok            <= '0';
                     SPI_Drive_State    <= Convertion_CH32;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
				   end if;		
           
--	Channel Eight chip 4					
          when Convertion_CH32  =>            
               Address_out              <= CH0;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH32;

          when Wait_CH32 =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH32_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok            <= '0';
                     CS1_i              <= '0';
                     CS2_i              <= '0';
                     CS3_i              <= '0';
                     CS4_i              <= '1';
                     SPI_Drive_State    <= Convertion_Dummy_5;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;						
               end if;
					
					
-- End of Chip 4
-- Start of Chip 5 
-- Channel zero chip 5
          when Convertion_Dummy_5 =>            
               Address_out              <= CH0;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_Dummy_5;

          when Wait_Dummy_5 =>
               convert                  <= '0';                              
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  data_ok               <= '1';
               end if;

               if data_ok= '1' then
                  if wait_cnt = 60 then
                     data_ok             <= '0';
                     SPI_Drive_State     <= Convertion_CH33;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;              
-- Channel one
          when Convertion_CH33 =>            
               Address_out              <= CH1;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH33;

          when Wait_CH33 =>
               convert                  <= '0';                              
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH33_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok             <= '0';
                     SPI_Drive_State     <= Convertion_CH34;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;
-- Channel two chip 5
          when Convertion_CH34 =>            
               Address_out              <= CH2;
               convert  	             <= '1';
               SPI_Drive_State          <= Wait_CH34;

          when Wait_CH34 =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH34_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok            <= '0';
                     SPI_Drive_State    <= Convertion_CH35;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;               
-- Channel three chip 5
          when Convertion_CH35 =>            
               Address_out              <= CH3;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH35;

          when Wait_CH35  =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH35_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok             <= '0';
                     SPI_Drive_State     <= Convertion_CH36;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;               
-- Channel Four chip 5
          when Convertion_CH36 =>            
               Address_out              <= CH4;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH36;

          when Wait_CH36     =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH36_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok              <= '0';
                     SPI_Drive_State      <= Convertion_CH37;
                  else
                     wait_cnt             := wait_cnt + 1;
                  end if;
               end if; 
-- Channel Five chip 5
          when Convertion_CH37 =>            
               Address_out              <= CH5;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH37;

          when Wait_CH37   =>
               convert                  <= '0';               
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH37_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok            <= '0';
                     SPI_Drive_State     <= Convertion_CH38;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if; 
-- Channel Six chip 5
          when Convertion_CH38 =>            
               Address_out              <= CH6;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH38;

          when Wait_CH38    =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH38_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok            <= '0';
                     SPI_Drive_State    <= Convertion_CH39;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;                
-- Channel Seven chip 5
          when Convertion_CH39 =>            
               Address_out              <= CH7;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH39;

          when Wait_CH39   =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH39_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH40;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;
					
-- Channel Eight chip 5
          when Convertion_CH40 =>            
               Address_out              <= CH0;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH40;

          when Wait_CH40   =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH40_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok               <= '0';
                     CS1_i                 <= '0';
                     CS2_i                 <= '0';
                     CS3_i                 <= '1';
                     CS4_i                 <= '1';
                     SPI_Drive_State       <= Convertion_Dummy_6;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;					
-- End of Chip 5
-- Start of Chip 6
-- Channel zero chip 6
          when Convertion_Dummy_6 =>            
               Address_out              <= CH0;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_Dummy_6;

          when Wait_Dummy_6 =>
               convert                  <= '0';                              
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  data_ok               <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH41;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;              
-- Channel one chip 6
          when Convertion_CH41 =>            
               Address_out              <= CH1;
               convert                  <= '1';
               SPI_Drive_state          <= Wait_CH41;

          when Wait_CH41 =>
               convert                  <= '0';                              
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH41_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH42;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;
-- Channel two
          when Convertion_CH42 =>            
               Address_out        <= CH2;
               convert  	        <= '1';
               SPI_Drive_State    <= Wait_CH42;

          when Wait_CH42 =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH42_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH43;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;               
-- Channel three chip 6
          when Convertion_CH43 =>            
               Address_out              <= CH3;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH43;

          when Wait_CH43  =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH43_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH44;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;               
-- Channel Four chip 6
          when Convertion_CH44 =>            
               Address_out              <= CH4;
               convert                  <= '1';
               SPI_Drive_State         <= Wait_CH44;

          when Wait_CH44=>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH44_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok            <= '0';
                     SPI_Drive_State    <= Convertion_CH45;
                  else
                     wait_cnt           := wait_cnt + 1;
                  end if;
               end if; 
-- Channel Five chip 6
          when Convertion_CH45 =>            
               Address_out              <= CH5;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH45;

          when Wait_CH45  =>
               convert                  <= '0';               
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH45_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok            <= '0';
                     SPI_Drive_State    <= Convertion_CH46;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if; 
-- Channel Six chip 6
          when Convertion_CH46 =>            
               Address_out              <= CH6;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH46;

          when Wait_CH46    =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  wait_cnt              := 0;
                  CH46_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;

               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok               <= '0';
                     SPI_Drive_State       <= Convertion_CH47;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;                
-- Channel Seven chip 6
          when Convertion_CH47 =>            
               Address_out              <= CH7;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH47;

          when Wait_CH47=>
               convert                  <= '0';                
               if Data_valid = '1' then
		              wait_cnt              := 0;
                  CH47_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
					
	             if data_ok = '1' then
		             if wait_cnt = 60 then
                     data_ok            <= '0';
                     SPI_Drive_State    <= Convertion_CH48;
                  else
                     wait_cnt           := wait_cnt + 1;
                  end if;
	            end if;		

-- Channel Eight chip 6
          when Convertion_CH48 =>            
               Address_out              <= CH0;
               convert                  <= '1';
               SPI_Drive_State          <= Wait_CH48;

          when Wait_CH48   =>
               convert                  <= '0';                
               if Data_valid = '1' then
                  CH48_i                <= AD_data_in;
                  data_ok               <= '1';
               end if;
               
               if data_ok = '1' then
                  if wait_cnt = 60 then
                     data_ok               <= '0';
                     Data_Ready_i          <= '1';
                     SPI_Drive_State       <= Wait_Idle;
                  else
                     wait_cnt := wait_cnt + 1;
                  end if;
               end if;
               
-- End of Chip 6					
          when Wait_Idle  => 
	             data_ok           <= '0';
               Data_Ready_i      <= '0';
               SPI_Drive_state   <= Idle;						
                  
          when others =>
               SPI_Drive_State      <= Idle;  
          end case;
       
      end if;
    end process SPI_Driver;  
  end Arch_DUT;
