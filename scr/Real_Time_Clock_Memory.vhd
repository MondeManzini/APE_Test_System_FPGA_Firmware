-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- Controller for Memory based on the AT24C32 device.
--
-- The firmware performs the following functions:
-- Write data to the memory adresses instructed
-- Written by: Monde Manzini
-- Tested      : ??/??/20?? Simulation only - Initialization.
--             : Test do file is wave.do
-- Last update : 01/07/2021 
-- Last update : ??/??/20?? - ??
-- Outstanding : 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.Version_Ascii.all;

entity Real_Time_Clock_Memory is
  
   port (
-- General Signals
   RST_I                      : in  std_logic;
   CLK_I 	                  : in  std_logic;
-- Inputs from I2C Driver
   Busy                       : in  std_logic;
   data_read                  : in  std_logic_vector(7 downto 0);
   ack_error                  : in std_logic;
-- Outputs to I2C Driver
   initialation_Status        : out std_logic;
   Enable                     : out std_logic;
   Slave_Address_Out          : out std_logic_vector(6 downto 0);
   Slave_read_nWrite          : out std_logic;
   Slave_Data_Out             : out std_logic_vector(7 downto 0);  
-- Inputs from Handler
   Get_Sample_mem             : in std_logic;      
   Clear_mem                  : in std_logic;
-- Inputs from Handler
   Seconds_in_mem             : in std_logic_vector(7 downto 0); 
   Minutes_in_mem             : in std_logic_vector(7 downto 0); 
   Hours_in_mem               : in std_logic_vector(7 downto 0); 
   Day_in_mem                 : in std_logic_vector(7 downto 0); 
   Date_in_mem                : in std_logic_vector(7 downto 0); 
   Month_Century_in_mem       : in std_logic_vector(7 downto 0); 
   Year_in_mem                : in std_logic_vector(7 downto 0); 
-- Outputs for Mux
   Seconds_out_mem_hi         : out std_logic_vector(7 downto 0);
   Seconds_out_mem_lo         : out std_logic_vector(7 downto 0);
   Minutes_out_mem_hi         : out std_logic_vector(7 downto 0);
   Minutes_out_mem_lo         : out std_logic_vector(7 downto 0);
   Hours_out_mem_hi           : out std_logic_vector(7 downto 0);
   Hours_out_mem_lo           : out std_logic_vector(7 downto 0);
   Day_out_mem_hi             : out std_logic_vector(7 downto 0);
   Day_out_mem_lo             : out std_logic_vector(7 downto 0);
   Date_out_mem_hi            : out std_logic_vector(7 downto 0);
   Date_out_mem_lo            : out std_logic_vector(7 downto 0);
   Month_Century_out_mem_hi   : out std_logic_vector(7 downto 0);
   Month_Century_out_mem_lo   : out std_logic_vector(7 downto 0);
   Year_out_mem_hi            : out std_logic_vector(7 downto 0);
   Year_out_mem_lo            : out std_logic_vector(7 downto 0);
   Ready_mem                  : out std_logic
   );
end Real_Time_Clock_Memory;

architecture Arch_DUT of Real_Time_Clock_Memory is

-- Read_Write Time Keeping Registers Allocation
signal Seconds_register_conf_lo_i         : std_logic_vector(7 downto 0):= X"00"; -- 00H -- Initialize as 00 
signal Seconds_register_conf_hi_i         : std_logic_vector(15 downto 8):= X"00"; -- 00H -- Initialize as 00 

signal Minutes_register_conf_lo_i         : std_logic_vector(23 downto 16):= X"00"; -- 00H -- Initialize as 00 
signal Minutes_register_conf_hi_i         : std_logic_vector(31 downto 24):= X"00"; -- 00H -- Initialize as 00 

signal Hours_register_conf_lo_i           : std_logic_vector(39 downto 32):= X"00"; -- 00 -- Initialize as 00 
signal Hours_register_conf_hi_i           : std_logic_vector(47 downto 40):= X"00"; -- 00 -- Initialize as 00 

signal Day_register_conf_lo_i             : std_logic_vector(55 downto 48):= X"00"; -- 00H -- Initialize as 00
signal Day_register_conf_hi_i             : std_logic_vector(63 downto 56):= X"00"; -- 00H -- Initialize as 00 

signal Date_register_conf_lo_i            : std_logic_vector(71 downto 64):= X"00"; -- 00H -- Initialize as 00    
signal Date_register_conf_hi_i            : std_logic_vector(79 downto 72):= X"00"; -- 00H -- Initialize as 00    

signal Month_Century_register_conf_lo_i   : std_logic_vector(87 downto 80):= X"00"; -- 05H -- Initialize as 00 
signal Month_Century_register_conf_hi_i   : std_logic_vector(95 downto 88):= X"00"; -- 05H -- Initialize as 00 

signal Year_register_conf_lo_i            : std_logic_vector(103 downto 96):= X"00"; -- 06H -- Initialize as 00 
signal Year_register_conf_hi_i            : std_logic_vector(111 downto 104):= X"00"; -- 06H -- Initialize as 00 

-- 
signal Enable_i                        : std_logic;
signal Ready_mem_i                     : std_logic;
signal Get_Sample_i                    : std_logic;
signal Start_i                         : std_logic;
signal Busy_i                          : std_logic;
signal Config_i                        : std_logic_vector(7 downto 0);
signal Slave_Data_i                    : std_logic_vector(7 downto 0);

-- Time Out
signal Seconds_out_mem_i               : std_logic_vector(7 downto 0) := X"00";         
signal Minutes_out_mem_i               : std_logic_vector(7 downto 0) := X"00";     
signal Hours_out_mem_i                 : std_logic_vector(7 downto 0) := X"00";
signal Day_out_mem_i                   : std_logic_vector(7 downto 0) := X"00";         
signal Date_out_mem_i                  : std_logic_vector(7 downto 0) := X"00";     
signal Month_Century_out_mem_i         : std_logic_vector(7 downto 0) := X"00";
signal Year_out_mem_i                  : std_logic_vector(7 downto 0) := X"00";

signal Seconds_mem_hi_i                : std_logic_vector(7 downto 0);
signal Seconds_mem_lo_i                : std_logic_vector(7 downto 0);
signal Minutes_mem_hi_i                : std_logic_vector(7 downto 0);
signal Minutes_mem_lo_i                : std_logic_vector(7 downto 0);
signal Hours_mem_hi_i                  : std_logic_vector(7 downto 0);
signal Hours_mem_lo_i                  : std_logic_vector(7 downto 0);
signal Day_mem_hi_i                    : std_logic_vector(7 downto 0);
signal Day_mem_lo_i                    : std_logic_vector(7 downto 0);
signal Date_mem_hi_i                   : std_logic_vector(7 downto 0);
signal Date_mem_lo_i                   : std_logic_vector(7 downto 0);
signal Month_Century_mem_hi_i          : std_logic_vector(7 downto 0);
signal Month_Century_mem_lo_i          : std_logic_vector(7 downto 0);
signal Year_mem_hi_i                   : std_logic_vector(7 downto 0);
signal Year_mem_lo_i                   : std_logic_vector(7 downto 0);

signal Seconds_out_mem_hi_i            : std_logic_vector(7 downto 0);
signal Seconds_out_mem_lo_i            : std_logic_vector(7 downto 0);
signal Minutes_out_mem_hi_i            : std_logic_vector(7 downto 0);
signal Minutes_out_mem_lo_i            : std_logic_vector(7 downto 0);
signal Hours_out_mem_hi_i              : std_logic_vector(7 downto 0);
signal Hours_out_mem_lo_i              : std_logic_vector(7 downto 0);
signal Day_out_mem_hi_i                : std_logic_vector(7 downto 0);
signal Day_out_mem_lo_i                : std_logic_vector(7 downto 0);
signal Date_out_mem_hi_i               : std_logic_vector(7 downto 0);
signal Date_out_mem_lo_i               : std_logic_vector(7 downto 0);
signal Month_Century_out_mem_hi_i      : std_logic_vector(7 downto 0);
signal Month_Century_out_mem_lo_i      : std_logic_vector(7 downto 0);
signal Year_out_mem_hi_i               : std_logic_vector(7 downto 0);
signal Year_out_mem_lo_i               : std_logic_vector(7 downto 0);

signal Slave_Address_i                 : std_logic_vector(6 downto 0);
signal Slave_Register_i                : std_logic_vector(7 downto 0);
signal lockout_i                       : std_logic;
signal initialation_Status_i           : std_logic;
signal Address_Lock_i                  : std_logic := '0';
--signal NumberBytes       : INTEGER RANGE 0 TO 20 := 0;

-- States
type   i2c_Controller_States is (Idle, Initialization, ReadData);
signal i2c_Controller_State : i2c_Controller_States;
type   i2c_Intialization_States is (i2c_Idle, LoadData, WaitnBusy, Wait_Byte_Write, Wait_Busy_Low, StopInitialization, initialzation_Complete);
signal i2c_Intialization_State : i2c_Intialization_States;
type   i2c_ReadData_States is (Idle, Wait_Write, Write_Data, Wait_Address, Wait_Read, Wait_Data, TestStop);
signal i2c_ReadData_State        : i2c_ReadData_States;

------------------------------------------------------------------------------- 

  begin
-- i2C Controller Wires
Enable                     <= Enable_i;                  
Get_Sample_i               <= Get_Sample_mem; 
slave_Data_Out             <= Slave_Data_i;
-- Slave Read Data
Seconds_out_mem_hi         <= Seconds_out_mem_hi_i;    
Seconds_out_mem_lo         <= Seconds_out_mem_lo_i;                
Minutes_out_mem_hi         <= Minutes_out_mem_hi_i; 
Minutes_out_mem_lo         <= Minutes_out_mem_lo_i;
Hours_out_mem_hi           <= Hours_out_mem_hi_i;
Hours_out_mem_lo           <= Hours_out_mem_lo_i;
Day_out_mem_hi             <= Day_out_mem_hi_i;
Day_out_mem_lo             <= Day_out_mem_lo_i;
Date_out_mem_hi            <= Date_out_mem_hi_i;
Date_out_mem_lo            <= Date_out_mem_lo_i;
Month_Century_out_mem_hi   <= Month_Century_out_mem_hi_i;
Month_Century_out_mem_lo   <= Month_Century_out_mem_lo_i;
Year_out_mem_hi            <= Year_out_mem_hi_i;
Year_out_mem_lo            <= Year_out_mem_lo_i;
initialation_Status        <= initialation_Status_i;
busy_i                     <= busy;
Ready_mem                  <= Ready_mem_i;
-- Slave Write Data
Seconds_mem_hi_i(7 downto 4)        <= x"0";
Seconds_mem_hi_i(3 downto 0)        <= Seconds_in_mem(7 downto 4);
Seconds_mem_lo_i(7 downto 4)        <= Seconds_in_mem(3 downto 0);
Seconds_mem_lo_i(3 downto 0)        <= x"0";

Minutes_mem_hi_i(7 downto 4)        <= x"0";
Minutes_mem_hi_i(3 downto 0)        <= Minutes_in_mem(7 downto 4);
Minutes_mem_lo_i(7 downto 4)        <= Minutes_in_mem(3 downto 0);
Minutes_mem_lo_i(3 downto 0)        <= x"0";

Hours_mem_hi_i(7 downto 4)          <= x"0";
Hours_mem_hi_i(3 downto 0)          <= Hours_in_mem(7 downto 4);
Hours_mem_lo_i(7 downto 4)          <= Hours_in_mem(3 downto 0);
Hours_mem_lo_i(3 downto 0)          <= x"0";

Day_mem_hi_i(7 downto 4)            <= x"0";
Day_mem_hi_i(3 downto 0)            <= Day_in_mem(7 downto 4);
Day_mem_lo_i(7 downto 4)            <= Day_in_mem(3 downto 0);
Day_mem_lo_i(3 downto 0)            <= x"0";

Date_mem_hi_i(7 downto 4)           <= x"0";
Date_mem_hi_i(3 downto 0)           <= Date_in_mem(7 downto 4);
Date_mem_lo_i(7 downto 4)           <= Date_in_mem(3 downto 0);
Date_mem_lo_i(3 downto 0)           <= x"0";

Month_Century_mem_hi_i(7 downto 4)  <= x"0";
Month_Century_mem_hi_i(3 downto 0)  <= Month_Century_in_mem(7 downto 4);
Month_Century_mem_lo_i(7 downto 4)  <= Month_Century_in_mem(3 downto 0);
Month_Century_mem_lo_i(3 downto 0)  <= x"0";

Year_mem_hi_i(7 downto 4)           <= x"0";
Year_mem_hi_i(3 downto 0)           <= Year_in_mem(7 downto 4);
Year_mem_lo_i(7 downto 4)           <= Year_in_mem(3 downto 0);
Year_mem_lo_i(3 downto 0)           <= x"0";
-------------------------------------------------------------------------------
-- i2C Controller
-------------------------------------------------------------------------------
Memory_I2C_Control :process (CLK_I,RST_I)
    --timing for clock generation
   Variable Count             : INTEGER RANGE 0 TO 150 := 0;
   Variable Config_Count      : INTEGER RANGE 0 TO 12 := 0;
   Variable Read_Count        : INTEGER RANGE 0 TO 10 := 0;
   Variable Write_Count       : INTEGER RANGE 0 TO 10 := 0;
begin
   if RST_I = '0' then 
      Count                   := 0;
      Config_Count            := 0;
      Slave_Address_i         <= "1010000";   -- 0xA0
      Slave_Register_i        <= X"00";
      lockout_i               <= '0';         
      Enable_i                <= '0';
      Ready_mem_i             <= '0';
      Slave_Data_i            <= X"00";
      initialation_Status_i   <= '0';
      i2c_Controller_State    <= Initialization;
      Seconds_out_mem_i       <= X"00";
      Minutes_out_mem_i       <= X"00";
      Hours_out_mem_i         <= X"00";
      Day_out_mem_i           <= X"00";
      Date_out_mem_i          <= X"00";
      Month_Century_out_mem_i <= X"00";
      Year_out_mem_i          <= X"00";
   elsif CLK_I'event and CLK_I = '1' then

      case i2c_Controller_State is           
         when Initialization =>
            case i2c_Intialization_State is
               when i2c_Idle => 
                  initialation_Status_i    <= '0';        
                  if Busy_i = '0' then
                     Slave_Address_Out       <= Slave_Address_i; -- 0x68 for DS3231    
                     Slave_read_nWrite       <= '0';   
                     Slave_Data_i            <= Slave_Register_i;
                     Enable_i                <= '1';
                     if Config_Count = 0 then 
                        Config_i <= Seconds_register_conf_lo_i;
                     end if;
                     i2c_Intialization_State <= LoadData;
                  end if; 
                        
               when LoadData =>     
                  if Busy_i = '1' and Count = 100 then     
                     Slave_Address_Out        <= Slave_Address_i;      
                     Slave_read_nWrite        <= '0';   
                     Slave_Data_i             <= Config_i;
                     Count                    := 0;
                     Config_Count             := Config_Count + 1;
                     i2c_Intialization_State  <= WaitnBusy;
                  elsif Busy_i = '1' and Count < 100 then
                     Count := Count + 1;                     
                  end if; 
                                       
               when WaitnBusy =>
                  if Busy_i = '0' then
                     i2c_Intialization_State <= Wait_Busy_Low;
                     case Config_Count is
                        when 0 => 
                           Config_i          <= x"00";
                           Slave_Register_i  <= Seconds_register_conf_hi_i;
                        when 1 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Seconds_register_conf_lo_i;
                        when 2 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Hours_register_conf_hi_i; 
                        when 3 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Hours_register_conf_lo_i; 
                        when 4 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Day_register_conf_hi_i;                                
                        when 5 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Day_register_conf_lo_i;                               
                        when 6 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Date_register_conf_hi_i;
                        when 7 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Date_register_conf_lo_i;
                        when 8 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Month_Century_register_conf_hi_i; 
                        when 9 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Month_Century_register_conf_lo_i;                             
                        when 10 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Year_register_conf_hi_i;
                        when 11 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Year_register_conf_lo_i;
                        when 12 => 
                           Config_i          <= x"00";  
                           Slave_Register_i  <= X"00";
                     end case; 
                  else   
                     i2c_Intialization_State <= WaitnBusy;                       
                  end if;
                     
               when Wait_Busy_Low =>
                  if Busy_i = '0' then  
                     Enable_i                <= '1';
                     Count                   := 0;
                     i2c_Intialization_State <= Wait_Byte_Write;
                  else 
                     i2c_Intialization_State <= Wait_Busy_Low;                     
                  end if;  
                 
               when Wait_Byte_Write =>
                  if busy_i = '1' then
                     if Count= 100 then
                        Enable_i                <= '0';
                        i2c_Intialization_State <= StopInitialization;
                     else                  
                        Count := Count + 1;
                     end if;
                  end if; 
                      
               when StopInitialization =>                       
                  if Busy_i = '0'  then     
                     if Config_Count = 9 then
                        i2c_Intialization_State  <= initialzation_Complete;
                        i2c_Controller_State     <= Idle;
                        initialation_Status_i    <= '1';
                        Config_Count             := 0;
                     else
                        i2c_Intialization_State  <= i2c_Idle;  
                     end if;   
                  end if;

               when initialzation_Complete =>
                  initialation_Status_i    <= '1';               
            end case;
----------------------------                            
-- end of Initialization 
----------------------------
         when Idle =>
            initialation_Status_i    <= '0';
            if Get_Sample_i = '1' then
               i2c_ReadData_State   <= Idle;
               Read_Count           := 0;
               Slave_Register_i     <= Seconds_register_conf_lo_i;   -- Start to read from
               i2c_Controller_State <= ReadData;  
            else  
               i2c_Controller_State <= idle;
            end if;     
               
         when ReadData =>
            case i2c_ReadData_State is             
               when Idle =>         
                  if Busy_i = '0' then        -- Handler Ready Write Data
                     Slave_Address_Out       <= Slave_Address_i;     
                     Slave_read_nWrite       <= '0';   
                     Slave_Data_i            <= Slave_Register_i;
                     Enable_i                <= '1';
                     Address_Lock_i          <= '0';       
                     i2c_ReadData_State      <= Wait_Address;
                  end if;

               when Wait_Write =>
                  if Busy_i = '1' then
                     Slave_Address_Out         <= Slave_Address_i;      
                     -- Slave_read_nWrite         <= '1';   
                     Write_Count               := Write_Count + 1;                       
                     i2c_ReadData_State        <= Wait_Data;                     
                  end if;

               when Write_Data =>
                  if Busy_i = '0' and Write_Count < 16 then
                     i2c_ReadData_State      <= Wait_Write; 
                     if Write_Count = 1 then
                        Slave_Data_i <= Seconds_mem_hi_i; 
                     elsif Write_Count = 2 then
                        Slave_Data_i <= Seconds_mem_lo_i;  
                     elsif Write_Count = 3 then
                        Slave_Data_i <= Minutes_mem_hi_i;   
                     elsif Write_Count = 4 then
                        Slave_Data_i <= Minutes_mem_lo_i;
                     elsif Write_Count = 5 then
                        Slave_Data_i <= Hours_mem_hi_i;
                     elsif Write_Count = 6 then
                        Slave_Data_i <= Hours_mem_lo_i;                            
                     elsif Write_Count = 7 then
                        Slave_Data_i <= Day_mem_hi_i;                          
                     elsif Write_Count = 8 then
                        Slave_Data_i <= Day_mem_lo_i;                         
                     elsif Write_Count = 9 then
                        Slave_Data_i <= Date_mem_hi_i;                            
                     elsif Write_Count = 10 then
                        Slave_Data_i <= Date_mem_lo_i;  
                     elsif Write_Count = 11 then
                        Slave_Data_i <= Month_Century_mem_hi_i;                            
                     elsif Write_Count = 12 then
                        Slave_Data_i <= Month_Century_mem_lo_i;
                     elsif Write_Count = 13 then
                        Slave_Data_i <= Year_mem_hi_i;                            
                     elsif Write_Count = 14 then
                        Slave_Data_i <= Year_mem_lo_i;                       
                     end if;                           
                  elsif Busy_i = '1' and Write_Count = 15 then
                     Slave_read_nWrite    <= '0';    -- Write data to memory slave
                     Enable_i             <= '0';
                  elsif Busy_i = '0' and Write_Count = 15 then      
                     Ready_mem_i          <= '1';
                     i2c_ReadData_State   <= Wait_Address;                                                                                       
                  end if;

               when Wait_Address =>
                  if Busy_i = '1' and Address_Lock_i = '0' then
                     Address_Lock_i            <= '1';                       
                     Slave_Address_Out         <= Slave_Address_i;      
                     Slave_read_nWrite         <= '1';                       
                  elsif Busy_i = '0' and Address_Lock_i = '1' then
                     Address_Lock_i            <= '0';
                     i2c_ReadData_State        <= Wait_Read;                        
                  end if;
                 
               when Wait_Read =>
                  if Busy_i = '1' then
                     Slave_Address_Out         <= Slave_Address_i;      
                     Slave_read_nWrite         <= '1';   
                     Read_Count                := Read_Count + 1;                       
                     i2c_ReadData_State        <= Wait_Data;                     
                  end if;
                 
               when Wait_Data =>
                  if Busy_i = '0' and Read_Count < 11 then
                     i2c_ReadData_State            <= Wait_Read; 
                     if Read_Count = 1 then
                        Seconds_out_mem_hi_i       <= data_read; 
                     elsif Read_Count = 2 then
                        Seconds_out_mem_lo_i       <= data_read;  
                     elsif Read_Count = 3 then
                        Minutes_out_mem_hi_i       <= data_read;   
                     elsif Read_Count = 4 then
                        Minutes_out_mem_lo_i       <= data_read; 
                     elsif Read_Count = 5 then
                        Hours_out_mem_hi_i         <= data_read;
                     elsif Read_Count = 6 then
                        Hours_out_mem_lo_i         <= data_read;                             
                     elsif Read_Count = 7 then
                        Month_Century_out_mem_hi_i <= data_read;                          
                     elsif Read_Count = 8 then
                        Month_Century_out_mem_lo_i <= data_read;                          
                     elsif Read_Count = 9 then
                        Year_out_mem_hi_i          <= data_read;                            
                     elsif Read_Count = 10 then
                        Year_out_mem_lo_i          <= data_read;                          
                     end if;                           
                  elsif Busy_i = '1' and Read_Count = 11 then
                     Slave_read_nWrite    <= '1';
                     Enable_i             <= '0';
                  elsif Busy_i = '0' and Read_Count = 11 then      
                     Ready_mem_i          <= '1';
                     i2c_ReadData_State   <= TestStop;                                                                                       
                  end if;
                     
               when TestStop =>
                  Ready_mem_i             <= '0';                
                  i2c_Controller_State    <= idle;
                  i2c_ReadData_State      <= Idle;
                    
            end case;                        
         end case;

   -----------------------------
   -- Writing/reading the EEPROM
   -----------------------------

   end if;
    
  end process Maser_i2c_Control; 
 
  end architecture Arch_DUT;    	      
