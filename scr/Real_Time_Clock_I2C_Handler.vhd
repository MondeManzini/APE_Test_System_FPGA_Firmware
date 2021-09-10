-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- Real Time Clock handle for the DS3231 device.
--
-- The firmware performs the following functions:
--    Writes slave address 0x68
--    Reads slave address 0x68
--       Seconds, Minutes, Hours, Days, Date, Months and Years
-- Written by: Glen Taylor, Monde Manzini
-- Tested      : ??/??/20?? Simulation only - Initialization.
--             : Test do file is wave.do
-- Last update : 29/06/2021 
-- Last update : ??/??/20?? - ??
-- Outstanding : 
-------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.Version_Ascii.all;

entity Real_Time_Clock_I2C_Handler is
  
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
-- Outputs to Mem Device   
   Get_Sample_mem             : out std_logic;
   Clear_mem                  : out std_logic;
-- Inputs from Mux
   Get_Sample                 : in std_logic;
   PPS_in                     : in std_logic;
-- Inputs from DeMux
   Seconds_in                 : in std_logic_vector(7 downto 0); 
   Minutes_in                 : in std_logic_vector(7 downto 0); 
   Hours_in                   : in std_logic_vector(7 downto 0); 
   Day_in                     : in std_logic_vector(7 downto 0); 
   Date_in                    : in std_logic_vector(7 downto 0); 
   Month_Century_in           : in std_logic_vector(7 downto 0); 
   Year_in                    : in std_logic_vector(7 downto 0); 
   Write_RTC                  : in std_logic;
-- Outputs for Mux
   Seconds_out                : out std_logic_vector(7 downto 0); 
   Minutes_out                : out std_logic_vector(7 downto 0); 
   Hours_out                  : out std_logic_vector(7 downto 0); 
   Day_out                    : out std_logic_vector(7 downto 0); 
   Date_out                   : out std_logic_vector(7 downto 0); 
   Month_Century_out          : out std_logic_vector(7 downto 0); 
   Year_out                   : out std_logic_vector(7 downto 0); 
   Ready                      : out std_logic;
   
----------------------------------------------------------------
-- Memory Port
----------------------------------------------------------------
-- Outputs for Mux
   Seconds_out_mem            : out std_logic_vector(7 downto 0);
   Minutes_out_mem            : out std_logic_vector(7 downto 0);
   Hours_out_mem              : out std_logic_vector(7 downto 0);
   Day_out_mem                : out std_logic_vector(7 downto 0);
   Date_out_mem               : out std_logic_vector(7 downto 0);
   Month_Century_out_mem      : out std_logic_vector(7 downto 0);
   Year_out_mem               : out std_logic_vector(7 downto 0);
   Ready_mem                  : out std_logic
   );
end Real_Time_Clock_I2C_Handler;

architecture Arch_DUT of Real_Time_Clock_I2C_Handler is

-- Read_Write Time Keeping Registers 
signal Seconds_register_i              : std_logic_vector(7 downto 0):= X"00"; -- 00H -- Initialize as 00 
signal Seconds_register_conf_i         : std_logic_vector(7 downto 0):= X"00"; -- 00H -- Initialize as 00 

signal Minutes_register_i              : std_logic_vector(7 downto 0):= X"01"; -- 01H -- Initialize as 00 
signal Minutes_register_conf_i         : std_logic_vector(7 downto 0):= X"00"; -- 00H -- Initialize as 00 

signal Hours_register_i                : std_logic_vector(7 downto 0):= X"02"; -- 02H -- Initialize as 00 
signal Hours_register_conf_i           : std_logic_vector(7 downto 0):= X"00"; -- 00 -- Initialize as 00 

signal Day_register_i                  : std_logic_vector(7 downto 0):= X"03"; -- 03H -- Initialize as 00 
signal Day_register_conf_i             : std_logic_vector(7 downto 0):= X"00"; -- 00H -- Initialize as 00 

signal Date_register_i                 : std_logic_vector(7 downto 0):= X"04"; -- 04H -- Initialize as 00 
signal Date_register_conf_i            : std_logic_vector(7 downto 0):= X"00"; -- 00H -- Initialize as 00    

signal Month_Century_register_i        : std_logic_vector(7 downto 0):= X"05"; -- 05H -- Initialize as 00 
signal Month_Century_register_conf_i   : std_logic_vector(7 downto 0):= X"00"; -- 05H -- Initialize as 00 

signal Year_register_i                 : std_logic_vector(7 downto 0):= X"06"; -- 06H -- Initialize as 00 
signal Year_register_conf_i            : std_logic_vector(7 downto 0):= X"00"; -- 06H -- Initialize as 00 

-- Read_Write Memory Time Keeping Registers Allocation
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


-- Special Function Registers
signal CTL_Reg_i                       : std_logic_vector(7 downto 0):= X"0e";  
signal CTL_Status_i                    : std_logic_vector(7 downto 0):= X"0f";  
signal CTL_Reg_conf_i                  : std_logic_vector(7 downto 0):= X"40";  
signal CTL_Status_conf_i               : std_logic_vector(7 downto 0):= X"00"; 
-- 
signal Enable_i                        : std_logic;
signal Ready_i                         : std_logic;
signal Ready_mem_i                     : std_logic;

signal Get_Sample_i                    : std_logic;
signal Start_i                         : std_logic;
signal Busy_i                          : std_logic;
signal Config_i                        : std_logic_vector(7 downto 0);
signal Slave_Data_i                    : std_logic_vector(7 downto 0);

-- Time Out
signal Seconds_out_i                   : std_logic_vector(7 downto 0) := X"00";         
signal Minutes_out_i                   : std_logic_vector(7 downto 0) := X"00";     
signal Hours_out_i                     : std_logic_vector(7 downto 0) := X"00";
signal Day_out_i                       : std_logic_vector(7 downto 0) := X"00";         
signal Date_out_i                      : std_logic_vector(7 downto 0) := X"00";     
signal Month_Century_out_i             : std_logic_vector(7 downto 0) := X"00";
signal Year_out_i                      : std_logic_vector(7 downto 0) := X"00";

----------------------------------------------------------------
-- Memory Signals
----------------------------------------------------------------
-- Time Out
signal Seconds_out_mem_i               : std_logic_vector(7 downto 0) := X"00";         
signal Minutes_out_mem_i               : std_logic_vector(7 downto 0) := X"00";     
signal Hours_out_mem_i                 : std_logic_vector(7 downto 0) := X"00";
signal Day_out_mem_i                   : std_logic_vector(7 downto 0) := X"00";         
signal Date_out_mem_i                  : std_logic_vector(7 downto 0) := X"00";     
signal Month_Century_out_mem_i         : std_logic_vector(7 downto 0) := X"00";
signal Year_out_mem_i                  : std_logic_vector(7 downto 0) := X"00";

signal Seconds_mem_i                   : std_logic_vector(7 downto 0);
signal Minutes_mem_i                   : std_logic_vector(7 downto 0);
signal Hours_mem_i                     : std_logic_vector(7 downto 0);
signal Day_mem_i                       : std_logic_vector(7 downto 0);
signal Date_mem_i                      : std_logic_vector(7 downto 0);
signal Month_Century_mem_i             : std_logic_vector(7 downto 0);
signal Year_mem_i                      : std_logic_vector(7 downto 0);

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
signal mem_flash_i                     : std_logic := '0';
signal mem_flash_done_i                : std_logic := '0';
--signal NumberBytes       : INTEGER RANGE 0 TO 20 := 0;

-- States
type   i2c_Controller_States is (Idle, Initialization, ReadData, WriteData);
signal i2c_Controller_State : i2c_Controller_States;
type   i2c_Intialization_States is (i2c_Idle, LoadData, WaitnBusy, Wait_Byte_Write, Wait_Busy_Low, StopInitialization,
       initialzation_Complete);
signal i2c_Intialization_State : i2c_Intialization_States;
type   i2c_ReadData_States is (Idle, Wait_Address, Wait_Read, Wait_Data, TestStop);
signal i2c_ReadData_State : i2c_ReadData_States;

type   i2c_WriteData_States is (Idle, Wait_Address, Wait_Write, Write_Data, Wait_Data, TestStop);
signal i2c_WriteData_State : i2c_WriteData_States;
-- Memory Flashing States
type   Mem_Controller_States is (Idle, Wait_ready, WriteData);
signal Mem_Controller_State : Mem_Controller_States;

type   i2c_WriteData_Mem_States is (Idle, Wait_Address_Mem, Wait_Write_Mem, Write_Data_Mem, Wait_Data_Mem, TestStop_Mem);
signal i2c_WriteData_Mem_State : i2c_WriteData_Mem_States;
------------------------------------------------------------------------------- 

  begin
-- i2C Controller Wires
Enable                  <= Enable_i;                  
Get_Sample_i            <= Get_Sample; 
slave_Data_Out          <= Slave_Data_i;
Seconds_out             <= Seconds_out_i;                
Minutes_out             <= Minutes_out_i;             
Hours_out               <= Hours_out_i;
Day_out                 <= Day_out_i;
Date_out                <= Date_out_i;
Month_Century_out       <= Month_Century_out_i;
Year_out                <= Year_out_i;
initialation_Status     <= initialation_Status_i;
busy_i                  <= busy;
Ready                   <= Ready_i;
-- Slave Read Data
Seconds_out_mem         <= Seconds_out_mem_i;    
Minutes_out_mem         <= Minutes_out_mem_i; 
Hours_out_mem           <= Hours_out_mem_i;
Day_out_mem             <= Day_out_mem_i;
Date_out_mem            <= Date_out_mem_i;
Month_Century_out_mem   <= Month_Century_out_mem_i;
Year_out_mem            <= Year_out_mem_i;
-------------------------------------------------------------------------------
-- i2C Controller
-------------------------------------------------------------------------------
I2C_Control :process (CLK_I,RST_I)
    --timing for clock generation
   Variable Count             : INTEGER RANGE 0 TO 150 := 0;
   Variable Config_Count      : INTEGER RANGE 0 TO 21 := 0;
   Variable Read_Count        : INTEGER RANGE 0 TO 10 := 0;
   Variable Write_Count       : INTEGER RANGE 0 TO 10 := 0;
   variable Mem_Read_Count    : INTEGER RANGE 0 TO 10 := 0;
   variable Mem_Write_Count   : INTEGER RANGE 0 TO 10 := 0;
   variable mem_flash_cnt     : integer range 0 to 1000;
   variable wait_cnt          : integer range 0 to 1200;
   variable wait_busy         : integer range 0 to 100;
begin
   if RST_I = '0' then 
      Count                   := 0;
      Config_Count            := 0;
      mem_flash_cnt           := 0;
      Slave_Address_i         <= "1101000";   -- 0xd0 - RTC Chip Address - 0x68?
      Slave_Register_i        <= X"00";
      lockout_i               <= '0';         
      Enable_i                <= '0';
      Ready_i                 <= '0';
      Slave_Data_i            <= X"00";
      initialation_Status_i   <= '0';
      i2c_Controller_State    <= Initialization;
      Seconds_out_i           <= X"00";
      Minutes_out_i           <= X"00";
      Hours_out_i             <= X"00";
      Day_out_i               <= X"00";
      Date_out_i              <= X"00";
      Month_Century_out_i     <= X"00";
      Year_out_i              <= X"00";
      Write_Count             := 0;
      Read_Count              := 0;
      wait_cnt                := 0;
   elsif CLK_I'event and CLK_I = '1' then

      case i2c_Controller_State is           
         when Initialization =>
            case i2c_Intialization_State is
               when i2c_Idle =>         
                  if Busy_i = '0' then
                     Slave_Address_Out       <= Slave_Address_i; -- 0x68 for DS3231    
                     Slave_read_nWrite       <= '0';   
                     Slave_Data_i            <= Slave_Register_i;
                     Enable_i                <= '1';
                     if Config_Count = 0 then 
                        Config_i <= Seconds_register_conf_i;
                     end if;
                     i2c_Intialization_State <= LoadData;
                  end if; 
                        
               when LoadData =>     
                  if Busy_i = '1' and Count = 100 then     
                     Slave_Address_Out       <= Slave_Address_i;      
                     Slave_read_nWrite       <= '0';   
                     Slave_Data_i            <= Config_i;
                     Count                   := 0;
                     Config_Count            := Config_Count + 1;
                     i2c_Intialization_State  <= WaitnBusy;
                  elsif Busy_i = '1' and Count < 100 then
                     Count := Count + 1;                     
                  end if; 

               when WaitnBusy =>                
                  if Busy_i = '0' then
                     i2c_Intialization_State <= Wait_Busy_Low;
                     case Config_Count is
                        when 0 => 
                           Config_i          <= Seconds_register_conf_i;
                           Slave_Register_i  <= Seconds_register_i;
                        when 1 =>
                           Config_i          <= Minutes_register_conf_i;
                           Slave_Register_i  <= Minutes_register_i;
                        when 2 =>
                           Config_i          <= Hours_register_conf_i;
                           Slave_Register_i  <= Hours_register_i;                              
                        when 3 =>
                           Config_i          <= Day_register_conf_i;
                           Slave_Register_i  <= Day_register_i;                               
                        when 4 =>
                           Config_i          <= Date_register_conf_i;
                           Slave_Register_i  <= Date_register_i;
                        when 5 =>
                           Config_i          <= Month_Century_register_conf_i;
                           Slave_Register_i  <= Month_Century_register_i;                              
                        when 6 =>
                           Config_i          <= Year_register_conf_i;
                           Slave_Register_i  <= Year_register_i;
                        when 7 =>
                           Config_i          <= CTL_Reg_conf_i;
                           Slave_Register_i  <= CTL_Reg_i;
                        when 8 =>
                           Config_i          <= CTL_Status_conf_i;
                           Slave_Register_i  <= CTL_Status_i;
                        when 9 => 
                           Slave_Address_i   <= "1010000";
                           Config_i          <= x"00";
                           Slave_Register_i  <= Seconds_register_conf_hi_i;
                        when 10 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Seconds_register_conf_lo_i;
                        when 11 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Hours_register_conf_hi_i; 
                        when 12 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Hours_register_conf_lo_i; 
                        when 13 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Day_register_conf_hi_i;                                
                        when 14 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Day_register_conf_lo_i;                               
                        when 15 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Date_register_conf_hi_i;
                        when 16 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Date_register_conf_lo_i;
                        when 17 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Month_Century_register_conf_hi_i; 
                        when 18 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Month_Century_register_conf_lo_i;                             
                        when 19 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Year_register_conf_hi_i;
                        when 20 =>
                           Config_i          <= x"00";
                           Slave_Register_i  <= Year_register_conf_lo_i;
                        when 21 => 
                           Config_i          <= x"00";  
                           Slave_Register_i  <= X"00";
                           mem_flash_i       <= '1';
                        
                        when others =>

                     end case; 
                  else   
                     i2c_Intialization_State <= WaitnBusy;                       
                  end if;
                     
               when Wait_Busy_Low =>
                  if Busy_i = '0' then  
                     Enable_i      <= '1';
                     Count         := 0;
                     i2c_Intialization_State  <= Wait_Byte_Write;
                  else 
                     i2c_Intialization_State  <= Wait_Busy_Low;                     
                  end if;  
                 
               when Wait_Byte_Write =>
                  if busy_i = '1' then
                     if Count= 100 then
                        Enable_i                <= '0';                           
                        i2c_Intialization_State <= StopInitialization;
                     else                  
                        Count                   := Count + 1;
                     end if;
                  end if; 
                      
               when StopInitialization =>                       
                  if Busy_i = '0'  then     
                     if Config_Count = 21 then
                        if mem_flash_done_i = '1' then
                           i2c_Intialization_State <= initialzation_Complete;
                           i2c_Controller_State    <= Idle;
                           initialation_Status_i   <= '1';
                           Config_Count            := 0;
                           mem_flash_i             <= '0';
                        else
                           mem_flash_i             <= '0';
                        end if;
                     else
                        i2c_Intialization_State  <= i2c_Idle;  
                     end if;   
                  end if;
                        
               when initialzation_Complete =>
                  initialation_Status_i    <= '0';
                  mem_flash_i              <= '0';               
            end case;

----------------------------                            
-- end of Initialization 
----------------------------

         when Idle =>
            initialation_Status_i   <= '0';
            Read_Count              := 0;
            Write_Count             := 0;
            if Get_Sample_i = '1' then
               i2c_ReadData_State   <= Idle;
               Read_Count           := 0;
               Slave_Register_i     <= Seconds_register_i;
               i2c_Controller_State <= ReadData;  
            elsif Write_RTC = '1' then
               i2c_WriteData_State  <= Idle;
               Write_Count          := 0;
               Slave_Register_i     <= Seconds_register_i;
               i2c_Controller_State <= WriteData; 
            else  
               i2c_Controller_State <= idle;
            end if;     
               
         when ReadData =>
            case i2c_ReadData_State is             
               when Idle =>         
                  if Busy_i = '0' then
                     Slave_Address_Out       <= Slave_Address_i;     
                     Slave_read_nWrite       <= '0';   
                     Slave_Data_i            <= Slave_Register_i;
                     Enable_i                <= '1';
                     Address_Lock_i          <= '0';       
                     i2c_ReadData_State      <= Wait_Address;
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
                  if Busy_i = '0' and Read_Count < 8 then
                     case Read_Count is
                        when 1 =>
                           Seconds_out_i        <= data_read;
                           i2c_ReadData_State   <= Wait_Read;

                        when 2 =>
                           Minutes_out_i        <= data_read;
                           i2c_ReadData_State   <= Wait_Read;

                        when 3 =>
                           Hours_out_i          <= data_read;
                           i2c_ReadData_State   <= Wait_Read;

                        when 4 =>
                           Day_out_i            <= data_read;
                           i2c_ReadData_State   <= Wait_Read;

                        when 5 =>
                           Date_out_i        <= data_read;
                           i2c_ReadData_State   <= Wait_Read;

                        when 6 =>
                           Month_Century_out_i  <= data_read;
                           i2c_ReadData_State   <= Wait_Read;

                        when 7 =>
                           Year_out_i        <= data_read;
                           i2c_ReadData_State   <= Wait_Read;

                        when others =>
                           i2c_ReadData_State   <= TestStop;

                     end case;
                  elsif Busy_i = '0' and Read_Count > 7 then      
                     Ready_i              <= '1';
                     Enable_i             <= '0';
                     i2c_ReadData_State   <= TestStop;                                                                                       
                  end if;

               when TestStop =>
                  Enable_i                <= '0';
                  Ready_i              <= '0';
                  Read_Count           := 0;                
                  i2c_Controller_State    <= idle;
                  i2c_ReadData_State      <= Idle;
                    
            end case;  
            
         when WriteData =>
            case i2c_WriteData_State is             
               when Idle =>         
                  if Busy_i = '0' then
                     Slave_Address_Out       <= Slave_Address_i;     
                     Slave_read_nWrite       <= '0';   
                     Slave_Data_i            <= Slave_Register_i;
                     Enable_i                <= '1';
                     Address_Lock_i          <= '0';       
                     i2c_WriteData_State      <= Wait_Address;
                  end if;
                
               when Wait_Address =>
                  if Busy_i = '1' and Address_Lock_i = '0' then
                     Address_Lock_i            <= '1';                       
                     Slave_Address_Out         <= Slave_Address_i;      
                     Slave_read_nWrite         <= '0';                       
                  elsif Busy_i = '0' and Address_Lock_i = '1' then
                     Address_Lock_i            <= '0';
                     i2c_WriteData_State       <= Wait_Write;                        
                  end if;
                 
               when Wait_Write =>
                  if Busy_i = '1' then
                     Slave_Address_Out         <= Slave_Address_i;      
                     Slave_read_nWrite         <= '0';   
                     Write_Count               := Write_Count + 1;                       
                     i2c_WriteData_State       <= Write_Data;                     
                  end if;

               when Write_Data =>
                  i2c_WriteData_State       <= Wait_Data;

               when Wait_Data =>
                  if Busy_i = '0' and Write_Count < 8 then
                     i2c_WriteData_State      <= Wait_Write; 
                     if Write_Count = 1 then
                        Slave_Data_i  <= Seconds_in;                                                                                 
                     elsif Write_Count = 2 then
                        Slave_Data_i  <= Minutes_in; 
                     elsif Write_Count = 3 then
                        Slave_Data_i  <= Hours_in;                          
                     elsif Write_Count = 4 then
                        Slave_Data_i  <= Day_in;                          
                     elsif Write_Count = 5 then
                        Slave_Data_i  <= Date_in;                          
                     elsif Write_Count = 6 then
                        Slave_Data_i  <= Month_Century_in;                            
                     elsif Write_Count = 7 then
                        Slave_Data_i  <= Year_in;                         
                     end if;                           
                  elsif Busy_i = '1' and Write_Count = 8 then
                     Slave_read_nWrite    <= '0';
                     Enable_i             <= '0';
                  elsif Busy_i = '0' and Write_Count = 8 then      
                     Ready_i              <= '1';
                     i2c_WriteData_State  <= TestStop;                                                                                       
                  end if;
                     
               when TestStop =>
                  Ready_i                 <= '0';
                  i2c_WriteData_State     <= Idle;
                  i2c_Controller_State    <= Idle;
                    
            end case;  
      end case;

   -----------------------------
   -- Writing/Reading the EEPROM
   -----------------------------
         case Mem_Controller_State is

            when Idle =>
               if mem_flash_i = '1' then
                  Mem_Read_Count          := 0;
                  Mem_Write_Count         := 0;
                  Slave_Register_i        <= Seconds_register_conf_hi_i;
                  Mem_Controller_State    <= Wait_ready;
                  i2c_WriteData_Mem_State <= Idle;  
               else  
                  Mem_Controller_State <= idle;
               end if;

            when Wait_ready =>
               if wait_busy = 100 then 
                  wait_busy            := 0;
                  Slave_Address_i      <= "1010000"; -- EEPROM 
                  -- Load Memory Slave Write Data
                  Seconds_mem_i        <= Seconds_out_i;
                  Minutes_mem_i        <= Minutes_out_i;
                  Hours_mem_i          <= Hours_out_i;
                  Day_mem_i            <= Day_out_i;
                  Date_mem_i           <= Date_out_i;
                  Month_Century_mem_i  <= Month_Century_out_i;
                  Year_mem_i           <= Year_out_i;
                  -- Load Version Numbers of Modules

                  Mem_Controller_State <= WriteData;
               else
                  wait_busy := wait_busy + 1;
               end if;

            when WriteData =>
               case i2c_WriteData_Mem_State is             
                  when Idle =>        
                     if Busy_i = '0' then
                        Slave_Address_Out       <= Slave_Address_i;     
                        Slave_read_nWrite       <= '0';   
                        Slave_Data_i            <= Slave_Register_i;
                        Enable_i                <= '1';
                        Address_Lock_i          <= '0';       
                        i2c_WriteData_Mem_State <= Wait_Address_Mem;
                     end if;

                  when Wait_Address_Mem =>
                     if Busy_i = '1' and Address_Lock_i = '0' then
                        Address_Lock_i            <= '1';                       
                        Slave_Address_Out         <= Slave_Address_i;      
                        Slave_read_nWrite         <= '0';                       
                     elsif Busy_i = '0' and Address_Lock_i = '1' then
                        Address_Lock_i            <= '0';
                        Mem_Write_Count           := Mem_Write_Count + 1; 
                        i2c_WriteData_Mem_State   <= Wait_Data_Mem;                        
                     end if;
   
                  when Wait_Data_Mem =>
                     if Busy_i = '0' and Write_Count < 8 then
                        
                        if Mem_Write_Count = 1 then
                           Slave_Data_i <= Seconds_mem_i; 
                           i2c_WriteData_Mem_State <= Wait_Address_Mem; 
                        Enable_i                <= '1';
                        elsif Mem_Write_Count = 2 then
                           Slave_Data_i <= Minutes_mem_i;
                           i2c_WriteData_Mem_State <= Wait_Address_Mem; 
                        Enable_i                <= '1';
                        elsif Mem_Write_Count = 3 then
                           Slave_Data_i <= Hours_mem_i;     
                           i2c_WriteData_Mem_State <= Wait_Address_Mem; 
                        Enable_i                <= '1';                    
                        elsif Mem_Write_Count = 4 then
                           Slave_Data_i <= Day_mem_i;     
                           i2c_WriteData_Mem_State <= Wait_Address_Mem; 
                        Enable_i                <= '1';                    
                        elsif Mem_Write_Count = 5 then
                           Slave_Data_i <= Date_mem_i;  
                           i2c_WriteData_Mem_State <= Wait_Address_Mem; 
                        Enable_i                <= '1';
                        elsif Mem_Write_Count = 6 then
                           Slave_Data_i <= Month_Century_mem_i;
                           i2c_WriteData_Mem_State <= Wait_Address_Mem; 
                        Enable_i                <= '1';
                        elsif Mem_Write_Count = 7 then
                           Slave_Data_i <= Year_mem_i; 
                           i2c_WriteData_Mem_State <= Wait_Address_Mem; 
                        Enable_i                <= '1';
                        end if;                           
                     elsif Busy_i = '1' and Mem_Write_Count = 8 then
                        Slave_read_nWrite    <= '0';    -- Write data to memory slave
                        Enable_i             <= '0';
                        i2c_WriteData_Mem_State <= Wait_Write_Mem;
                     elsif Busy_i = '0' and Mem_Write_Count = 8 then      
                        i2c_WriteData_Mem_State <= Wait_Write_Mem;                                                                                       
                     end if;
                   
                  when Wait_Write_Mem =>
                     if Busy_i = '1' then
                        Slave_Address_Out         <= Slave_Address_i;      
                        Slave_read_nWrite         <= '1';   
                        Mem_Read_Count            := Mem_Read_Count + 1;                       
                        i2c_WriteData_Mem_State   <= Write_Data_Mem;                     
                     end if;

                  when Write_Data_Mem =>
                     if Busy_i = '0' and Mem_Read_Count < 8 then
                                                                                                        
                        if Mem_Read_Count = 1 then
                           Seconds_out_mem_i       <= data_read; 
                           i2c_WriteData_Mem_State      <= Wait_Write_Mem;
                           Enable_i                <= '1'; 
                        elsif Mem_Read_Count = 2 then
                           Minutes_out_mem_i       <= data_read; 
                           i2c_WriteData_Mem_State      <= Wait_Write_Mem;
                           Enable_i                <= '1'; 
                        elsif Mem_Read_Count = 3 then
                           Hours_out_mem_i         <= data_read;  
                           i2c_WriteData_Mem_State      <= Wait_Write_Mem;
                           Enable_i                <= '1'; 
                        elsif Mem_Read_Count = 4 then
                           Day_out_mem_i           <= data_read;  
                           i2c_WriteData_Mem_State      <= Wait_Write_Mem;
                           Enable_i                <= '1'; 
                        elsif Mem_Read_Count = 5 then
                           Date_out_mem_i          <= data_read;    
                           i2c_WriteData_Mem_State      <= Wait_Write_Mem;
                           Enable_i                <= '1';                         
                        elsif Mem_Read_Count = 6 then
                           Month_Century_out_mem_i <= data_read;   
                           i2c_WriteData_Mem_State      <= Wait_Write_Mem;
                           Enable_i                <= '1';                                                    
                        elsif Mem_Read_Count = 7 then
                           Year_out_mem_i          <= data_read;    
                           i2c_WriteData_Mem_State      <= Wait_Write_Mem;
                           Enable_i                <= '1';                       
                        end if;                            
                     elsif Busy_i = '1' and Mem_Read_Count = 8 then
                        Slave_read_nWrite    <= '1';
                        Enable_i             <= '0';
                     elsif Busy_i = '0' and Mem_Read_Count = 8 then      
                        Ready_mem_i          <= '1';
                        mem_flash_done_i     <= '1';
                        i2c_WriteData_Mem_State   <= TestStop_Mem;                                                                                       
                     end if;
                        
                  when TestStop_Mem =>
                     Ready_mem_i             <= '0';  
                     mem_flash_done_i        <= '0';              
                     Mem_Controller_State    <= idle;
                     i2c_WriteData_Mem_State <= Idle;
                       
               end case; 
            end case;

   end if;
    
  end process I2C_Control; 
 
  end architecture Arch_DUT;    	      
