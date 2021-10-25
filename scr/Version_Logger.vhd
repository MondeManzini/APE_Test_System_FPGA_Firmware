-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- Version Logger

-- The firmware peEndat_Firmwareorms the following functions:
--
-- Receives version names from modules
-- Receives version numbers from modules
-- Receives version flags from modules
-- Generates one version name and one version number

-- Written By           : Monde Manzini
-- Version              : 1.0 
-- Change Note          : 
-- Tested               : 01/05/2017
-- Test Bench file Name : NVersion_Logger_Test_Bench
-- located at           : (https://katfs.kat.ac.za/svnAfricanArray/Software
--                        Repository/CommonCode/ScrCommon)
-- Test do file         : Version_Logger_Test_Bench.do
-- located at            (https://katfs.kat.ac.za/svnAfricanArray/Software
--                        Repository/CommonCode/Modelsim)
-- Outstanding          : System Integration tests

-- Outstanding          : Integration ATP and Approval
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
  
entity Version_Logger is

  port(
       CLK_I                                           : in  std_logic;
       RST_I                                           : in  std_logic;
       SPI_IO_Driver_Version_Ready_1                   : in  std_logic; 
       SPI_IO_Driver_Version_Ready_2                   : in  std_logic;
       SPI_Input_Handler_Version_Ready                 : in  std_logic; 
       SPI_Output_Handler_Version_Ready                : in  std_logic; 
       SPI_Analog_Driver_Version_Ready_1               : in  std_logic;  
       SPI_Analog_Handler_Version_Ready_1              : in  std_logic;
       Main_Demux_Version_Ready                        : in  std_logic; 
       Main_Mux_Version_Ready                          : in  std_logic; 
       Baud_Rate_Generator_Version_Ready               : in  std_logic; 
       APE_Test_System_FPGA_Firmware_Version_Ready     : in  std_logic;
       Real_Time_Clock_Handler_Version_Ready           : in  std_logic; 
       SPI_IO_Driver_Version_Name                      : in  std_logic_vector(255 downto 0); 
       SPI_IO_Driver_Version_Number                    : in  std_logic_vector(63 downto 0);
       SPI_Input_Handler_Version_Name                  : in  std_logic_vector(255 downto 0); 
       SPI_Input_Handler_Version_Number                : in  std_logic_vector(63 downto 0);
       SPI_Output_Handler_Version_Name                 : in  std_logic_vector(255 downto 0); 
       SPI_Output_Handler_Version_Number               : in  std_logic_vector(63 downto 0);
       SPI_Analog_Driver_Version_Name                  : in  std_logic_vector(255 downto 0); 
       SPI_Analog_Driver_Version_Number                : in  std_logic_vector(63 downto 0);
       SPI_Analog_Handler_Version_Name                 : in  std_logic_vector(255 downto 0); 
       SPI_Analog_Handler_Version_Number               : in  std_logic_vector(63 downto 0);
       Main_Demux_Version_Name                         : in  std_logic_vector(255 downto 0); 
       Main_Demux_Version_Number                       : in  std_logic_vector(63 downto 0);
       Main_Mux_Version_Name                           : in  std_logic_vector(255 downto 0); 
       Main_Mux_Version_Number                         : in  std_logic_vector(63 downto 0);
       Baud_Rate_Generator_Version_Name                : in  std_logic_vector(255 downto 0);
       Baud_Rate_Generator_Version_Number              : in  std_logic_vector(63 downto 0);
       APE_Test_System_FPGA_Firmware_Version_Name      : in  std_logic_vector(255 downto 0);
       APE_Test_System_FPGA_Firmware_Version_Number    : in  std_logic_vector(63 downto 0);
       Real_Time_Clock_Handler_Version_Name            : in  std_logic_vector(255 downto 0);
       Real_Time_Clock_Handler_Version_Number          : in  std_logic_vector(63 downto 0);
       Version_Data_Ready                              : out std_logic;
       Module_Number                                   : in  std_logic_vector(7 downto 0);
       Version_Name                                    : out std_logic_vector(255 downto 0); 
       Version_Number                                  : out std_logic_vector(63 downto 0)
      );
end Version_Logger;
   
architecture log_to_file of Version_Logger is

signal Version_Name_i       : std_logic_vector(255 downto 0);
signal Version_Number_i     : std_logic_vector(63 downto 0);
signal Version_Data_Ready_i : std_logic;

type   Version_Reader_States is (Idle,Detect_Modules,Send_Modules, Read_Modules);
signal Version_Reader_State  : Version_Reader_States;

begin

receive_data: process (RST_I,CLK_I)
   
begin                                       

if RST_I = '0' then
   Version_Number_i      <= (others=> '0');
   Version_Name_i        <= (others=> '0');
   Version_Number        <= (others=> '0');
   Version_Name          <= (others=> '0');
   Version_Data_Ready_i  <= '0';
   Version_Reader_State  <= Idle; 
elsif (CLK_I'event and CLK_I = '1') then

    case Version_Reader_State is
         when Idle =>
              Version_Data_Ready   <= '0';
              Version_Reader_State <= Detect_Modules;

         when Detect_Modules =>   
              case Module_Number is
                   when X"00" =>   

                   when X"01" =>
                        if (SPI_IO_Driver_Version_Ready_1 = '1') or
                           (SPI_IO_Driver_Version_Ready_2 = '1') then
                           Version_Reader_State <= Read_Modules;
                           Version_Name_i       <= SPI_IO_Driver_Version_Name;
                           Version_Number_i     <= SPI_IO_Driver_Version_Number;
                        end if;   

                   when X"02" =>   
                        if SPI_Input_Handler_Version_Ready = '1' then
                           Version_Reader_State <= Read_Modules;
                           Version_Name_i       <= SPI_Input_Handler_Version_Name; 
                           Version_Number_i     <= SPI_Input_Handler_Version_Number;
                        end if;   

                   when X"03" =>
                        if SPI_Output_Handler_Version_Ready = '1' then
                           Version_Reader_State <= Read_Modules;
                           Version_Name_i       <= SPI_Output_Handler_Version_Name; 
                           Version_Number_i     <= SPI_Output_Handler_Version_Number;
                        end if;       

                   when X"04" =>   
                        if (SPI_Analog_Driver_Version_Ready_1 = '1') then
                           Version_Reader_State <= Read_Modules;
                           Version_Name_i       <= SPI_Analog_Driver_Version_Name; 
                           Version_Number_i     <= SPI_Analog_Driver_Version_Number;
                        end if;       

                   when X"05" =>
                        if (SPI_Analog_Handler_Version_Ready_1 = '1') then
                           Version_Reader_State <= Read_Modules;
                           Version_Name_i       <= SPI_Analog_Handler_Version_Name; 
                           Version_Number_i     <= SPI_Analog_Handler_Version_Number;
                        end if;   

                    when X"07" =>
                         if Main_Demux_Version_Ready = '1' then
                           Version_Reader_State <= Read_Modules;
                           Version_Name_i       <= Main_Demux_Version_Name;
                           Version_Number_i     <= Main_Demux_Version_Number;
                         end if;    

                    when X"08" =>
                         if Main_Mux_Version_Ready = '1' then
                              Version_Reader_State <= Read_Modules;
                              Version_Name_i       <= Main_Mux_Version_Name;
                              Version_Number_i     <= Main_Mux_Version_Number;
                         end if;         

                    when X"0a" =>
                         if Baud_Rate_Generator_Version_Ready = '1' then
                              Version_Reader_State <= Read_Modules;
                              Version_Name_i       <= Baud_Rate_Generator_Version_Name;
                              Version_Number_i     <= Baud_Rate_Generator_Version_Number;
                         end if;    
                        
                    when X"09" =>
                         if Real_Time_Clock_Handler_Version_Ready = '1' then
                              Version_Reader_State <= Read_Modules;
                              Version_Name_i       <= Real_Time_Clock_Handler_Version_Name;
                              Version_Number_i     <= Real_Time_Clock_Handler_Version_Number;
                         end if;

                   when X"0e" =>
                        if APE_Test_System_FPGA_Firmware_Version_Ready = '1' then
                           Version_Reader_State   <= Read_Modules;
                           Version_Name_i         <= APE_Test_System_FPGA_Firmware_Version_Name;
                           Version_Number_i       <= APE_Test_System_FPGA_Firmware_Version_Number;
                        end if;                        

                   when others => 
              end case;    

         when Read_Modules =>      
              Version_Reader_State <= Send_Modules; 
              Version_Number       <= Version_Number_i;
              Version_Name         <= Version_Name_i;

    
         when Send_Modules =>      
              Version_Data_Ready    <= '1';
              Version_Reader_State  <= Idle; 
         
         when others =>      
              Version_Reader_State  <= Idle; 

         end case;
       
end if;
end process receive_data;



end log_to_file;
 
