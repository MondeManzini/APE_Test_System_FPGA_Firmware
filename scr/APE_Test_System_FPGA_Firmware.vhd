
-- ===========
--
-- APE Test System FPGA Firmware Top Module
--
-- 
-- Written by       : Monde Manzini
-- Tested           : 
-- Last update      : 09/06/2021 
-- Version          :  

-- Last update      : 29/06/2021 
--                  : Removed RF Controller Modules

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use work.txt_util.all;
use work.Version_Ascii.all;

entity APE_Test_System_FPGA_Firmware is
  port (

--------------------------Clock Input  ---------------------------------
    CLOCK_50                            : in    std_logic;                      --      50 MHz          
--------------------------Push Button  ---------------------------------                        
    KEY                                 : in    std_logic_vector(1 downto 0);   --      Pushbutton[1:0]                   
--------------------------DPDT Switch  ---------------------------------
    SW                                  : in    std_logic_vector(3 downto 0);   --      Toggle Switch[3:0]              
--------------------------LED    ------------------------------------
    LED                                 : out   std_logic_vector(7 downto 0);   --      LED [7:0]     
--------------------------SDRAM Interface  ---------------------------
    --DRAM_DQ                             : inout std_logic_vector(15 downto 0);  --      SDRAM Data bus 16 Bits
    --DRAM_DQM                            : out   std_logic_vector(1 downto 0);   --      SDRAM Data bus 2 Bits
    --DRAM_ADDR                           : out   std_logic_vector(12 downto 0);  --      SDRAM Address bus 13 Bits
    --DRAM_WE_N                           : out   std_logic;                      --      SDRAM Write Enable
    --DRAM_CAS_N                          : out   std_logic;                      --      SDRAM Column Address Strobe
    --DRAM_RAS_N                          : out   std_logic;                      --      SDRAM Row Address Strobe
    --DRAM_CS_N                           : out   std_logic;                      --      SDRAM Chip Select
    --DRAM_BA                             : out   std_logic_vector(1 downto 0);   --      SDRAM Bank Address 0
    --DRAM_CLK                            : out   std_logic;                      --      SDRAM Clock
    --DRAM_CKE                            : out   std_logic;                      --      SDRAM Clock Enable
 
--------------------------Accelerometer and EEPROM----------------
    --G_SENSOR_CS_N                       : out     std_logic;  
    --G_SENSOR_INT                        : in      std_logic;  
    I2C_SCLK                            : out     std_logic;  
    I2C_SDAT                            : inout   std_logic;  
--------------------------ADC--------------------------------------------------------
    --ADC_CS_N                            : out     std_logic;   
    --ADC_SADDR                           : out     std_logic; 
    --ADC_SCLK                            : out     std_logic; 
    --ADC_SDAT                            : in      std_logic;
--------------------------2x13 GPIO Header-----------------------------------------------
    GPIO_2_UP                           : inout   std_logic_vector(2 downto 0);
    GPIO_2                              : inout   std_logic_vector(8 downto 0);
    GPIO_2_IN                           : in      std_logic_vector(2 downto 0);
--------------------------GPIO_0, GPIO_0 connect to GPIO Default-----------------------
    GPIO_0                              : inout   std_logic_vector(33 downto 0);
    GPIO_0_IN                           : in      std_logic_vector(1 downto 0);
--------------------------GPIO_1, GPIO_1 connect to GPIO Default--------------------------
    GPIO_1                              : inout   std_logic_vector(33 downto 0);
    GPIO_1_IN                           : in      std_logic_vector(1 downto 0)
    );
end APE_Test_System_FPGA_Firmware;

architecture Arch_DUT of APE_Test_System_FPGA_Firmware is
  
-- Accelerometer and EEPROM
signal I2C_SCLK_i                       : std_logic;  
signal I2C_SDAT_i                       : std_logic; 

-- General Signals
signal RST_I_i                          : std_logic; 
signal CLK_I_i                          : STD_LOGIC;
signal One_uS_i                         : STD_LOGIC;     
signal One_mS_i                         : STD_LOGIC;              
signal Ten_mS_i                         : STD_LOGIC;
signal Twenty_mS_i                      : STD_LOGIC;             
signal Hunder_mS_i                      : STD_LOGIC;
signal UART_locked_i                    : STD_LOGIC;
signal One_Sec_i                        : STD_LOGIC;
signal Two_ms_i                         : STD_LOGIC;
signal One_mS_pulse_i                   : std_logic;
signal Twenty_Three_mS                  : std_LOGIC;

-- GPIO 0 Port Signals
signal FPGA_PPS_i                       : std_logic;
-- SPI Channel 1  
signal INT_1_1_i                        : std_logic;
signal MISO_1_i                         : std_logic;
signal INT_2_1_i                        : std_logic;       
signal SCKL_1_1_i                       : std_logic;
signal MOSI_1_i                         : std_logic;
signal CS_1_1_i                         : std_logic;       
signal CS_2_1_i                         : std_logic;

-- SPI Channel 2  
signal INT_1_2_i                        : std_logic;
signal MISO_2_i                         : std_logic;
signal INT_2_2_i                        : std_logic;
signal SCKL_1_2_i                       : std_logic;
signal CS_1_2_i                         : std_logic;              
signal MOSI_2_i                         : std_logic;       
signal CS_2_2_i                         : std_logic;

-- SPI Channel 3  
signal INT_1_3_i                        : std_logic;
signal INT_2_3_i                        : std_logic;
signal MISO_3_i                         : std_logic;
signal SCKL_1_3_i                       : std_logic;
signal CS_1_3_i                         : std_logic;
signal CS_2_3_i                         : std_logic;
signal MOSI_3_i                         : std_logic;

-- SPI Channel 4  
signal INT_1_4_i                        : std_logic;
signal MISO_4_i                         : std_logic;
signal INT_2_4_i                        : std_logic;
signal SCKL_1_4_i                       : std_logic;       
signal CS_2_4_i                         : std_logic;
signal CS_1_4_i                         : std_logic;
signal MOSI_4_i                         : std_logic;

-- SPI Channel 5
signal INT_1_5_i                        : std_logic;
signal MISO_5_i                         : std_logic;           
signal INT_2_5_i                        : std_logic;            
signal SCKL_1_5_i                       : std_logic;       
signal MOSI_5_i                         : std_logic;
signal CS_1_5_i                         : std_logic;
signal CS_2_5_i                         : std_logic;
  
-- GPIO 1 Port Signals
-- SPI Channel 6
signal INT_1_6_i                        : std_logic;
signal MISO_6_i                         : std_logic;
signal INT_2_6_i                        : std_logic;       
signal CS_1_6_i                         : std_logic;
signal CS_2_6_i                         : std_logic;
signal MOSI_6_i                         : std_logic;
signal SCKL_1_6_i                       : std_logic;

-- SPI Channel 7
signal MISO_7_i                         : std_logic;
signal INT_2_7_i                        : std_logic;       
signal INT_1_7_i                        : std_logic;              
signal CS_2_7_i                         : std_logic;
signal MOSI_7_i                         : std_logic;
signal SCKL_1_7_i                       : std_logic;
signal CS_1_7_i                         : std_logic;

-- SPI Channel 8
signal MISO_8_i                         : std_logic;
signal MOSI_8_i                         : std_logic;
signal INT_2_8_i                        : std_logic;
signal INT_1_8_i                        : std_logic;
signal CS_1_8_i                         : std_logic; 
signal CS_2_8A_i                        : std_logic;
signal SCKL_1_8_i                       : std_logic;

-- SPI Channel 9
signal MISO_9_i                         : std_logic;       
signal INT_2_9_i                        : std_logic;
signal INT_1_9_i                        : std_logic;       
signal CS_1_9_i                         : std_logic;
signal SCKL_1_9_i                       : std_logic;       
signal CS_2_9_i                         : std_logic;
signal MOSI_9_i                         : std_logic;

-- SPI Channel 10
signal INT_1_10_i                       : std_logic;
signal MISO_10_i                : std_logic;       
signal INT_2_10_i               : std_logic;   
signal MOSI_10_i                : std_logic;
signal SCKL_1_10_i              : std_logic;       
signal CS_2_10_i                : std_logic; 
signal CS_1_10_i                : std_logic;

-- GPIO 2 Port Signals
signal PC_Relay_Control_i       : std_logic; 

-- Timestamp from Tcl Script
signal Version_Timestamp_i      : STD_LOGIC_VECTOR(111 downto 0);       -- Ex. 20181120105439

-- Tope Level Firmware Module Name
constant ISC_Controller_name_i  : STD_LOGIC_VECTOR(23 downto 0) := x"495343";  -- RFC

-- Version Major Number - Hardcoded
constant Version_Major_High_i   : STD_LOGIC_VECTOR(7 downto 0) := x"30";  -- 0x
constant Version_Major_Low_i    : STD_LOGIC_VECTOR(7 downto 0) := x"31";  -- x1   -- Change to 00

constant Dot_i                  : STD_LOGIC_VECTOR(7 downto 0) := x"2e";  -- .
-- Version Minor Number - Hardcoded
constant Version_Minor_High_i   : STD_LOGIC_VECTOR(7 downto 0) := x"30";  -- 0x
constant Version_Minor_Low_i    : STD_LOGIC_VECTOR(7 downto 0) := x"30";  -- x0
-- Null Termination
constant Null_i                 : STD_LOGIC_VECTOR(7 downto 0) := x"00";  -- termination
signal Version_Register_i       : STD_LOGIC_VECTOR(199 downto 0);
signal Module_Number_i          : std_logic_vector(7 downto 0);
signal APE_Test_System_FPGA_Firmware_Version_Request_i : std_logic;

-- Firmware Module
signal APE_Test_System_FPGA_Firmware_Version_Name_i     : std_logic_vector(255 downto 0)    :=  A & P & E & Space & T & E & S & T & Space & S &
                                                                                                Y & S & T & E & M & Space & Space & F & P & G & A & 
                                                                                                Space & F & I & R & M & W & A & R & E & Space & Space;
signal APE_Test_System_FPGA_Firmware_Version_Number_i   : std_logic_vector(63 downto 0)     := Zero & Zero & Dot & Zero & Zero & Dot & Zero & Five;

-- Version Verification Signals and Component
component Version_RX_UASRT is
  generic(
    version_verify_log_file   : string   --:= "Firmware Version Verification File.txt"
    );
  port (
      Clk                : in  std_logic;
      nrst               : in  std_logic;
      UART_RXD           : in std_logic;
      Version_Data       : in STD_LOGIC_VECTOR(199 downto 0);
      Version_Data_Ready : in std_logic 
  );
end component Version_RX_UASRT; 

----------------------------------------------------------------------
-- Version Logger
----------------------------------------------------------------------
signal Version_Data_Ready_i                         : std_logic;
signal Version_Name_i                               : std_logic_vector(255 downto 0); 
signal Version_Number_i                             : std_logic_vector(63 downto 0);
signal APE_Test_System_FPGA_Firmware_Version_Ready_i    : std_logic;
signal APE_Test_System_FPGA_Firmware_Version_Load_i     : std_logic;

component Version_Logger is
  port (
    CLK_I                                         : in  std_logic;
    RST_I                                         : in  std_logic;
    SPI_IO_Driver_Version_Ready_1                 : in  std_logic;
    SPI_IO_Driver_Version_Ready_2                 : in  std_logic;
    SPI_Input_Handler_Version_Ready               : in  std_logic;
    SPI_Output_Handler_Version_Ready              : in  std_logic;
    SPI_Analog_Driver_Version_Ready_1             : in  std_logic;
    SPI_Analog_Handler_Version_Ready_1            : in  std_logic;
    Main_Demux_Version_Ready                      : in  std_logic; 
    Main_Mux_Version_Ready                        : in  std_logic; 
    APE_Test_System_FPGA_Firmware_Version_Ready   : in  std_logic; 
    Real_Time_Clock_Handler_Version_Ready         : in  std_logic; 
    Main_Mux_Version_Name                         : in  std_logic_vector(255 downto 0); 
    Main_Mux_Version_Number                       : in  std_logic_vector(63 downto 0);
    Main_Demux_Version_Name                       : in  std_logic_vector(255 downto 0); 
    Main_Demux_Version_Number                     : in  std_logic_vector(63 downto 0);
    SPI_IO_Driver_Version_Name                    : in  std_logic_vector(255 downto 0); 
    SPI_IO_Driver_Version_Number                  : in  std_logic_vector(63 downto 0);
    SPI_Input_Handler_Version_Name                : in  std_logic_vector(255 downto 0); 
    SPI_Input_Handler_Version_Number              : in  std_logic_vector(63 downto 0);
    SPI_Output_Handler_Version_Name               : in  std_logic_vector(255 downto 0); 
    SPI_Output_Handler_Version_Number             : in  std_logic_vector(63 downto 0);
    SPI_Analog_Driver_Version_Name                : in  std_logic_vector(255 downto 0); 
    SPI_Analog_Driver_Version_Number              : in  std_logic_vector(63 downto 0);
    SPI_Analog_Handler_Version_Name               : in  std_logic_vector(255 downto 0); 
    SPI_Analog_Handler_Version_Number             : in  std_logic_vector(63 downto 0);
    Baud_Rate_Generator_Version_Name              : in  std_logic_vector(255 downto 0);
    Baud_Rate_Generator_Version_Number            : in  std_logic_vector(63 downto 0);
    APE_Test_System_FPGA_Firmware_Version_Name    : in  std_logic_vector(255 downto 0);
    APE_Test_System_FPGA_Firmware_Version_Number  : in  std_logic_vector(63 downto 0);
    Real_Time_Clock_Handler_Version_Name          : in  std_logic_vector(255 downto 0);
    Real_Time_Clock_Handler_Version_Number        : in  std_logic_vector(63 downto 0);
    Version_Data_Ready                            : out std_logic;
    Module_Number                                 : in  std_logic_vector(7 downto 0);
    Version_Name                                  : out std_logic_vector(255 downto 0);
    Version_Number                                : out std_logic_vector(63 downto 0));
end component Version_Logger;

--------------------------------
-- Version Signals and Component
--------------------------------
component Version_Reg is
    generic(
        log_file   : string   --:= "Firmware Version Log File.txt"
    );
    port (
        CLK_I              : in  std_logic;
        RST_I              : in  std_logic;
        Version_Timestamp  : out STD_LOGIC_VECTOR(111 downto 0)
    );
end component Version_Reg; 

----------------------------------------------------------------------
-- RTC I2C Driver Component and Signals
----------------------------------------------------------------------
component I2C_Driver IS
  GENERIC(
    input_clk : INTEGER := 50_000_000;               --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz
    PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC                     --serial clock output of i2c bus
    );                   
END component I2C_Driver;

signal Real_Time_Clock_Handler_Version_Request_i   : std_logic;
signal Real_Time_Clock_Handler_Version_Name_i      : std_logic_vector(255 downto 0);  
signal Real_Time_Clock_Handler_Version_Number_i    : std_logic_vector(63 downto 0); 
signal Real_Time_Clock_Handler_Version_Ready_i     : std_logic;

----------------------------------------------------------------------
-- RTC I2C Handler Test Bench Component and Signals
----------------------------------------------------------------------
component Real_Time_Clock_I2C_Handler IS
  PORT(
-- General Signals
  RST_I                : in  std_logic;
  CLK_I 	            : in  std_logic;
  -- Inputs from I2C Driver
  Busy                 : in  std_logic;
  data_read            : in  std_logic_vector(7 downto 0);
  ack_error            : in std_logic;
  -- Outputs to I2C Driver
  initialation_Status  : out std_logic;
  Enable               : out std_logic;
  Slave_Address_Out    : out std_logic_vector(6 downto 0);
  Slave_read_nWrite    : out std_logic;
  Slave_Data_Out       : out std_logic_vector(7 downto 0);  
  -- Inputs
  Get_Sample           : in std_logic;
  Sync                 : in std_logic;
  Enable_in            : in std_logic;
  PPS_in               : in std_logic;
  -- Inputs from DeMux
  Seconds_in           : in std_logic_vector(7 downto 0); 
  Minutes_in           : in std_logic_vector(7 downto 0); 
  Hours_in             : in std_logic_vector(7 downto 0); 
  Day_in               : in std_logic_vector(7 downto 0); 
  Date_in              : in std_logic_vector(7 downto 0); 
  Month_Century_in     : in std_logic_vector(7 downto 0); 
  Year_in              : in std_logic_vector(7 downto 0); 
  Write_RTC            : in std_logic;

  -- Outputs for Mux
  Seconds_out          : out std_logic_vector(7 downto 0); 
  Minutes_out          : out std_logic_vector(7 downto 0); 
  Hours_out            : out std_logic_vector(7 downto 0); 
  Day_out              : out std_logic_vector(7 downto 0); 
  Date_out             : out std_logic_vector(7 downto 0); 
  Month_Century_out    : out std_logic_vector(7 downto 0); 
  Year_out             : out std_logic_vector(7 downto 0); 
  Ready                : out std_logic;
  ----------------------------------------------------------------
  -- Memory Port
  ----------------------------------------------------------------
  -- Outputs for Mux
  Seconds_out_mem                           : out std_logic_vector(7 downto 0);
  Minutes_out_mem                           : out std_logic_vector(7 downto 0);
  Hours_out_mem                             : out std_logic_vector(7 downto 0);
  Day_out_mem                               : out std_logic_vector(7 downto 0);
  Date_out_mem                              : out std_logic_vector(7 downto 0);
  Month_Century_out_mem                     : out std_logic_vector(7 downto 0);
  Year_out_mem                              : out std_logic_vector(7 downto 0);
  Ready_mem                                 : out std_logic;
  Real_Time_Clock_Handler_Version_Request   : in std_logic;
  Real_Time_Clock_Handler_Version_Name      : out std_logic_vector(255 downto 0);  
  Real_Time_Clock_Handler_Version_Number    : out std_logic_vector(63 downto 0); 
  Real_Time_Clock_Handler_Version_Ready     : out std_logic
  );                   
END component Real_Time_Clock_I2C_Handler;

signal Get_Sample_i             : std_logic;
signal Sync_i                   : std_logic;
signal Enable_in_i              : std_logic;
signal PPS_in_i                 : std_logic;
signal Enable_i                 : std_logic;
signal Address_i                : std_logic_vector(6 downto 0);
signal RnW_i                    : std_logic;
signal Data_WR_i                : std_logic_vector(7 downto 0);
signal Ready_i                  : std_logic;
signal Seconds_out_i            : std_logic_vector(7 downto 0);         
signal Minutes_out_i            : std_logic_vector(7 downto 0);     
signal Hours_out_i              : std_logic_vector(7 downto 0);
signal Day_out_i                : std_logic_vector(7 downto 0);         
signal Date_out_i               : std_logic_vector(7 downto 0);     
signal Month_Century_out_i      : std_logic_vector(7 downto 0);
signal Year_out_i               : std_logic_vector(7 downto 0);
signal Seconds_in_i             : std_logic_vector(7 downto 0);         
signal Minutes_in_i             : std_logic_vector(7 downto 0);     
signal Hours_in_i               : std_logic_vector(7 downto 0);
signal Day_in_i                 : std_logic_vector(7 downto 0);         
signal Date_in_i                : std_logic_vector(7 downto 0);     
signal Month_Century_in_i       : std_logic_vector(7 downto 0);
signal Year_in_i                : std_logic_vector(7 downto 0);
signal Ack_Error_i              : std_logic;
signal SDA_i                    : std_logic;
signal SCL_i                    : std_logic;  
signal lock_Out_i               : std_logic;
signal lock_Out2_i              : std_logic;
signal Busy_i                   : std_logic;
signal Data_RD_i                : std_logic_vector(7 downto 0);
signal Start_i                  : std_logic;
signal lockout_i                : std_logic;
signal initialation_Status_i    : std_logic;
signal Real_Time_Clock_Ready_i  : std_logic;
signal One_mSEC_Pulse_i         : std_logic;
signal Write_RTC_i              : std_logic;
signal Seconds_out_mem_i        : std_logic_vector(7 downto 0) := X"00";         
signal Minutes_out_mem_i        : std_logic_vector(7 downto 0) := X"00";     
signal Hours_out_mem_i          : std_logic_vector(7 downto 0) := X"00";
signal Day_out_mem_i            : std_logic_vector(7 downto 0) := X"00";         
signal Date_out_mem_i           : std_logic_vector(7 downto 0) := X"00";     
signal Month_Century_out_mem_i  : std_logic_vector(7 downto 0) := X"00";
signal Year_out_mem_i           : std_logic_vector(7 downto 0) := X"00";

----------------------------------------------------------------------
-- SPI Driver ignals and Component
----------------------------------------------------------------------
signal Card_Select_1_i    : std_logic;
signal Card_Select_2_i    : std_logic;

signal Data_In_Ready_1_i  : std_logic;
signal Data_In_Ready_2_i  : std_logic;

-- signal SPI_Outport_1_i    : std_logic_vector(15 downto 0);
-- signal SPI_Outport_2_i    : std_logic_vector(15 downto 0);

signal Data_Out_Ready_1_i : std_logic;
signal Data_Out_Ready_2_i : std_logic;

signal SPI_Inport_1_i     : std_logic_vector(15 downto 0);
signal SPI_Inport_2_i     : std_logic_vector(15 downto 0);

signal SPI_IO_Driver_Version_Request_1_i  : std_logic;
signal SPI_IO_Driver_Version_Request_2_i  : std_logic;
signal SPI_IO_Driver_Version_Request_3_i  : std_logic;

signal SPI_IO_Driver_Version_Name_1_i   : std_logic_vector(255 downto 0); 
signal SPI_IO_Driver_Version_Number_1_i : std_logic_vector(63 downto 0);
signal SPI_IO_Driver_Version_Ready_1_i  : std_logic; 
signal SPI_IO_Driver_Version_Name_2_i   : std_logic_vector(255 downto 0); 
signal SPI_IO_Driver_Version_Number_2_i : std_logic_vector(63 downto 0);
signal SPI_IO_Driver_Version_Ready_2_i  : std_logic;
signal SPI_IO_Driver_Version_Name_3_i   : std_logic_vector(255 downto 0); 
signal SPI_IO_Driver_Version_Number_3_i : std_logic_vector(63 downto 0);
signal SPI_IO_Driver_Version_Ready_3_i  : std_logic;
--signal SPI_IO_Driver_Version_Request_3_i : std_logic;

component SPI_IO_Driver is
    port (
      RST_I                         : in  std_logic;
      CLK_I                         : in  std_logic;
      nCS_Output_1                  : out std_logic;
      nCS_Output_2                  : out std_logic;
      Sclk                          : out std_logic;
      Mosi                          : out std_logic;
      Miso                          : in  std_logic;
      Card_Select                   : in  std_logic;
      Data_In_Ready                 : in  std_logic;
      SPI_Outport                   : in  std_logic_vector(15 downto 0);
      Data_Out_Ready                : out std_logic;
      SPI_Inport                    : out std_logic_vector(15 downto 0);
      Busy                          : out std_logic;
      Module_Number                 : in  std_logic_vector(7 downto 0);
      SPI_IO_Driver_Version_Request : in  std_logic;
      SPI_IO_Driver_Version_Name    : out std_logic_vector(255 downto 0); 
      SPI_IO_Driver_Version_Number  : out std_logic_vector(63 downto 0);
      SPI_IO_Driver_Version_Ready   : out std_logic     
      );
  end component SPI_IO_Driver;

----------------------------------------------------------------------
-- SPI Input Handler Signals and Component
----------------------------------------------------------------------
signal SPI_Inport_1_1_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_1_2_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_1_3_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_1_4_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_1_5_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_1_6_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_1_7_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_1_8_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_2_1_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_2_2_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_2_3_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_2_4_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_2_5_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_2_6_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_2_7_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_2_8_i                      : std_logic_vector(7 downto 0);
signal SPI_Data_out_1_i                      : std_logic_vector(15 downto 0);
signal SPI_Data_out_2_i                      : std_logic_vector(15 downto 0);

signal Input_Data_ready_1_i                  : std_logic;
signal Input_Data_ready_2_i                  : std_logic;

signal Input_Ready_1_i                       : std_logic;
signal Input_Ready_2_i                       : std_logic;

signal Input_Card_Select_1_i                 : std_logic;
signal Input_Card_Select_2_i                 : std_logic;

signal SPI_Data_in_1_i                       : std_logic_vector(15 downto 0);
signal SPI_Data_in_2_i                       : std_logic_vector(15 downto 0);

signal Input_Data_In_ready_1_i               : std_logic;
signal Input_Data_In_ready_2_i               : std_logic;
signal Sample_Rate_i                         : integer range 0 to 1000;
signal Dig_In_Request_1_i                    : std_logic;
signal Dig_In_Request_2_i                    : std_logic;
signal Dig_In_Request_i                      : std_logic;

signal Version_Input_Handler_i             : std_logic_vector(7 downto 0);
signal SPI_Input_Handler_Version_Request_1_i : std_logic;
signal SPI_Input_Handler_Version_Name_1_i    : std_logic_vector(255 downto 0); 
signal SPI_Input_Handler_Version_Number_1_i  : std_logic_vector(63 downto 0);
signal SPI_Input_Handler_Version_Ready_1_i   : std_logic; 
signal SPI_Input_Handler_Version_Request_2_i : std_logic;
signal SPI_Input_Handler_Version_Name_2_i    : std_logic_vector(255 downto 0); 
signal SPI_Input_Handler_Version_Number_2_i  : std_logic_vector(63 downto 0);
signal SPI_Input_Handler_Version_Ready_2_i   : std_logic;

component SPI_Input_Handler is
    port (
      RST_I                             : in  std_logic;
      CLK_I                             : in  std_logic;
      Int_1                             : in  std_logic;
      Int_2                             : in  std_logic;
      SPI_Inport_1                      : out std_logic_vector(7 downto 0);
      SPI_Inport_2                      : out std_logic_vector(7 downto 0);
      SPI_Inport_3                      : out std_logic_vector(7 downto 0);
      SPI_Inport_4                      : out std_logic_vector(7 downto 0);
      SPI_Inport_5                      : out std_logic_vector(7 downto 0);
      SPI_Inport_6                      : out std_logic_vector(7 downto 0);
      SPI_Inport_7                      : out std_logic_vector(7 downto 0);
      SPI_Inport_8                      : out std_logic_vector(7 downto 0);
      SPI_Data_out                      : out std_logic_vector(15 downto 0);
      Input_Data_ready                  : out std_logic;
      Input_Card_Select                 : out std_logic;
      SPI_Data_in                       : in  std_logic_vector(15 downto 0);
      Input_Ready                       : out std_logic;
      busy                              : in  std_logic;
      Dig_In_Request                    : in  std_logic;
      Module_Number                     : in  std_logic_vector(7 downto 0);    
      SPI_Input_Handler_Version_Request : in  std_logic;
      SPI_Input_Handler_Version_Name    : out std_logic_vector(255 downto 0); 
      SPI_Input_Handler_Version_Number  : out std_logic_vector(63 downto 0);
      SPI_Input_Handler_Version_Ready   : out std_logic  
      );
  end component SPI_Input_Handler;

----------------------------------------------------------------------
-- SPI Output Handler Signals and Component
----------------------------------------------------------------------
signal SPI_Outport_1_i                      : std_logic_vector(7 downto 0);
signal SPI_Outport_2_i                      : std_logic_vector(7 downto 0);
signal SPI_Outport_3_i                      : std_logic_vector(7 downto 0);
signal SPI_Outport_4_i                      : std_logic_vector(7 downto 0);
signal SPI_Outport_5_i                      : std_logic_vector(7 downto 0);
signal SPI_Outport_6_i                      : std_logic_vector(7 downto 0);
signal SPI_Outport_7_i                      : std_logic_vector(7 downto 0);
signal SPI_Outport_8_i                      : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B0_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B1_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B2_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B3_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B4_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B5_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B6_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B7_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B0_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B1_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B2_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B3_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B4_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B5_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B6_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B7_i                     : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B0_Out_i                 : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B1_Out_i                 : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B2_Out_i                 : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B3_Out_i                 : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B4_Out_i                 : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B5_Out_i                 : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B6_Out_i                 : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B7_Out_i                 : std_logic_vector(7 downto 0);
signal Output_SPI_Data_out_i                : std_logic_vector(15 downto 0);
signal Output_Data_Ready_i                  : std_logic;
signal Output_Ready_i                       : std_logic;
signal Output_Card_Select_i                 : std_logic;
signal SPI_Output_Handler_Version_Request_i : std_logic;
signal Dig_Out_Request_i                    : std_logic;
signal SPI_Output_Handler_Version_Name_i    : std_logic_vector(255 downto 0); 
signal SPI_Output_Handler_Version_Number_i  : std_logic_vector(63 downto 0);
signal SPI_Output_Handler_Version_Ready_i   : std_logic; 
signal Data_Out_Ready_i                     : std_logic; 
signal SPI_Inport_i                         : std_logic_vector(15 downto 0);
 
component SPI_Output_Handler is
    port (
      RST_I                                 : in  std_logic;
      CLK_I                                 : in  std_logic;
      SPI_Outport_1                         : in  std_logic_vector(7 downto 0);
      SPI_Outport_2                         : in  std_logic_vector(7 downto 0);
      SPI_Outport_3                         : in  std_logic_vector(7 downto 0);
      SPI_Outport_4                         : in  std_logic_vector(7 downto 0);
      SPI_Outport_5                         : in  std_logic_vector(7 downto 0);
      SPI_Outport_6                         : in  std_logic_vector(7 downto 0);
      SPI_Outport_7                         : in  std_logic_vector(7 downto 0);
      SPI_Outport_8                         : in  std_logic_vector(7 downto 0);
      SPI_Inport_1                          : out std_logic_vector(7 downto 0);
      SPI_Inport_2                          : out std_logic_vector(7 downto 0);
      SPI_Inport_3                          : out std_logic_vector(7 downto 0);
      SPI_Inport_4                          : out std_logic_vector(7 downto 0);
      SPI_Inport_5                          : out std_logic_vector(7 downto 0);
      SPI_Inport_6                          : out std_logic_vector(7 downto 0);
      SPI_Inport_7                          : out std_logic_vector(7 downto 0);
      SPI_Inport_8                          : out std_logic_vector(7 downto 0);
      SPI_Data_in                           : in  std_logic_vector(15 downto 0);
      Input_Ready                           : in  std_logic;
      Output_SPI_Data_out                   : out std_logic_vector(15 downto 0);
      Output_Data_ready                     : out std_logic;
      Output_Ready                          : out std_logic;
      Output_Card_Select                    : out std_logic;       
      busy                                  : in  std_logic;
      Module_Number                         : in  std_logic_vector(7 downto 0);
      SPI_Output_Handler_Version_Request    : in  std_logic;
      SPI_Output_Handler_Version_Name       : out std_logic_vector(255 downto 0); 
      SPI_Output_Handler_Version_Number     : out std_logic_vector(63 downto 0);
      SPI_Output_Handler_Version_Ready      : out std_logic; 
      Dig_Out_Request                       : in  std_logic
      );
  end component SPI_Output_Handler;

----------------------------------------------------------------------
-- Analog Input Driver Signals and Component
----------------------------------------------------------------------
signal CS1_i                                : std_logic;
signal CS2_i                                : std_logic;
signal CS3_i                                : std_logic;
signal CS4_i                                : std_logic;
signal CS1_1_i                              : std_logic;
signal CS2_1_i                              : std_logic;
signal CS3_1_i                              : std_logic;
signal CS4_1_i                              : std_logic;
signal CS1_2_i                              : std_logic;
signal CS2_2_i                              : std_logic;
signal CS3_2_i                              : std_logic;
signal CS4_2_i                              : std_logic;
signal nCS_i                                : std_logic;
signal Address_out_i                        : std_logic_vector(2 downto 0);
signal convert_i                            : std_logic;
signal nCS_1_1_i                            : std_logic;
signal nCS_2_1_i                            : std_logic;
signal nCS_3_1_i                            : std_logic;
signal nCS_4_1_i                            : std_logic;
signal nCS_1_2_i                            : std_logic;
signal nCS_2_2_i                            : std_logic;
signal nCS_3_2_i                            : std_logic;
signal nCS_4_2_i                            : std_logic;
signal AD_data_i                            : std_logic_vector(15 downto 0);
signal Data_valid_i                         : std_logic;
signal Analog_Input_Valid_i                 : std_logic;
signal nCS1_i                               : std_logic;
signal nCS2_i                               : std_logic;
signal Version_Analog_Driver_i              : std_logic_vector(7 downto 0);
signal SPI_Analog_Driver_Version_Name_i     : std_logic_vector(255 downto 0); 
signal SPI_Analog_Driver_Version_Number_i   : std_logic_vector(63 downto 0);
signal SPI_Analog_Driver_Version_Ready_i    : std_logic;  
signal SPI_Analog_Driver_Version_Request_i  : std_logic;

component SPI_Analog_Driver is
    port (
      RST_I                             : in  std_logic;
      CLK_I                             : in  std_logic;
      CS1                               : in  std_logic;
      CS2                               : in  std_logic;
      CS3                               : in  std_logic;
      CS4                               : in  std_logic;
      nCS                               : out std_logic;
      Address                           : in  std_logic_vector(2 downto 0);
      convert                           : in  std_logic;
      nCS_1                             : out std_logic;
      nCS_2                             : out std_logic;
      nCS_3                             : out std_logic;
      nCS_4                             : out std_logic;
      Sclk                              : out std_logic;
      Mosi                              : out std_logic;
      Miso                              : in  std_logic;
      AD_data                           : out std_logic_vector(15 downto 0);
      Data_valid                        : out std_logic;
      Module_Number                     : in  std_logic_vector(7 downto 0);
      SPI_Analog_Driver_Version_Request : in  std_logic;
      SPI_Analog_Driver_Version_Name    : out std_logic_vector(255 downto 0); 
      SPI_Analog_Driver_Version_Number  : out std_logic_vector(63 downto 0);
      SPI_Analog_Driver_Version_Ready   : out std_logic  
      );
  end component SPI_Analog_Driver;

----------------------------------------------------------------------
-- Analog In Handler Signals and Component
----------------------------------------------------------------------
signal Data_Ready_i                           : std_logic;
signal Analog_Data_i                          : std_logic_vector(767 downto 0);
signal Chip_Select_i                          : std_logic_vector(3 downto 0);
signal Version_Analog_Handler_1_i             : std_logic_vector(7 downto 0);
signal Version_Analog_Handler_2_i             : std_logic_vector(7 downto 0);
signal SPI_Analog_Handler_Version_Request_i   : std_logic;
signal SPI_Analog_Handler_Version_Name_i    : std_logic_vector(255 downto 0); 
signal SPI_Analog_Handler_Version_Number_i  : std_logic_vector(63 downto 0);
signal SPI_Analog_Handler_Version_Ready_i   : std_logic;

component SPI_Analog_Handler is
  port (
    RST_I                              : in  std_logic;
    CLK_I                              : in  std_logic;
    Address_out                        : out std_logic_vector(2 downto 0);
    convert                            : out std_logic;
    AD_data_in                         : in  std_logic_vector(15 downto 0);
    Data_valid                         : in  std_logic;
    Analog_Data                        : out std_logic_vector(767 downto 0);
    Chip_Select                        : out std_logic_vector(3 downto 0); 
    Data_Ready                         : out std_logic;
    Ana_In_Request                     : in  std_logic;
    Module_Number                      : in  std_logic_vector(7 downto 0);
    SPI_Analog_Handler_Version_Request : in  std_logic;
    SPI_Analog_Handler_Version_Name    : out std_logic_vector(255 downto 0); 
    SPI_Analog_Handler_Version_Number  : out std_logic_vector(63 downto 0);
    SPI_Analog_Handler_Version_Ready   : out std_logic 
    );
end component SPI_Analog_Handler;

----------------------------------------------------------------------
-- Demux Signals and Component
----------------------------------------------------------------------
signal Software_to_Controller_UART_RXD_i  : std_logic;
signal Time_Stamp_Byte_3_i                : std_logic_vector(7 downto 0);
signal Time_Stamp_Byte_2_i                : std_logic_vector(7 downto 0);
signal Time_Stamp_Byte_1_i                : std_logic_vector(7 downto 0);
signal Time_Stamp_Byte_0_i                : std_logic_vector(7 downto 0);
signal Dig_MilliSecond_B1_i               : std_logic_vector(7 downto 0);
signal Dig_MilliSecond_B0_i               : std_logic_vector(7 downto 0);
signal Dig_Outputs_Ready_i                : std_logic;
signal Demux_Data_Ready_i                 : std_logic;
signal Version_Demux_i                    : std_logic_vector(7 downto 0);
signal Main_Demux_Version_Name_i          : std_logic_vector(255 downto 0); 
signal Main_Demux_Version_Number_i        : std_logic_vector(63 downto 0);  
signal Main_Demux_Version_Ready_i         : std_logic; 
signal Endat_Sniffer_Version_Request_i : std_logic;

component Main_Demux is
  port (
    CLK_I                                         : in  std_logic;
    RST_I                                         : in  std_logic;
    UART_RXD                                      : in  std_logic;
    Seconds_out                                   : out std_logic_vector(7 downto 0); 
    Minutes_out                                   : out std_logic_vector(7 downto 0); 
    Hours_out                                     : out std_logic_vector(7 downto 0); 
    Day_out                                       : out std_logic_vector(7 downto 0); 
    Date_out                                      : out std_logic_vector(7 downto 0); 
    Month_Century_out                             : out std_logic_vector(7 downto 0); 
    Year_out                                      : out std_logic_vector(7 downto 0); 
    Dig_Card1_1_B0                                : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B1                                : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B2                                : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B3                                : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B4                                : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B5                                : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B6                                : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B7                                : out std_logic_vector(7 downto 0);
    Write_RTC                                     : in std_logic;
    SET_Timer                                     : out std_logic;
    GET_Timer                                     : out std_logic;
    Dig_Outputs_Ready                             : out std_logic;
    Module_Number                                 : out std_logic_vector(7 downto 0);
    SPI_IO_Driver_Version_Request                 : out std_logic;  
    SPI_Output_Handler_Version_Request            : out std_logic; 
    SPI_Input_Handler_Version_Request             : out std_logic; 
    SPI_Analog_Driver_Version_Request             : out std_logic;
    Real_Time_Clock_Handler_Version_Request       : out std_logic;
    SPI_Analog_Handler_Version_Request            : out std_logic; 
    Timer_Controller_Version_Request              : out std_logic;
    Main_Mux_Version_Request                      : out std_logic; 
    Baud_Rate_Generator_Version_Request           : out std_logic;
    APE_Test_System_FPGA_Firmware_Version_Request : out std_logic;  
    Endat_Sniffer_Version_Request                 : out std_logic; 
    Main_Demux_Version_Name                       : out std_logic_vector(255 downto 0); 
    Main_Demux_Version_Number                     : out std_logic_vector(63 downto 0);
    Main_Demux_Version_Ready                      : out std_logic 
    );
end component Main_Demux;

----------------------------------------------------------------------
-- Mux Signals and Component
----------------------------------------------------------------------
signal Controller_to_Software_UART_TXD_i  : std_logic;
signal Message_Length_i                   : std_logic_vector(7 downto 0);
signal Message_ID1_i                      : std_logic_vector(7 downto 0);
signal Digital_Input_Valid_1_i            : std_logic;
signal Digital_Input_Valid_2_i            : std_logic;
signal Digital_Output_Valid_i             : std_logic;
signal Tx_Rate_i                          : integer range 0 to 255;
signal Mux_Baud_Rate_Enable_i             : std_logic;
signal SYCN_Pulse_i                       : std_logic;
signal Watchdog_Reset_i                   : std_logic;
signal Watchdog_Status_in_i               : std_logic_vector(15 downto 0);
signal Mux_watchdog_i                     : std_logic;
signal Ana_In_Request_i                   : std_logic;
signal Dig_Out_1_B0_i                     : std_logic_vector(7 downto 0);
signal Dig_Out_1_B1_i                     : std_logic_vector(7 downto 0);
signal Dig_Out_1_B2_i                     : std_logic_vector(7 downto 0);
signal Dig_Out_1_B3_i                     : std_logic_vector(7 downto 0);
signal Dig_Out_1_B4_i                     : std_logic_vector(7 downto 0);
signal Dig_Out_1_B5_i                     : std_logic_vector(7 downto 0);
signal Dig_Out_1_B6_i                     : std_logic_vector(7 downto 0);
signal Dig_Out_1_B7_i                     : std_logic_vector(7 downto 0);
signal Dig_In_1_B0_i                      : std_logic_vector(7 downto 0);
signal Dig_In_1_B1_i                      : std_logic_vector(7 downto 0);
signal Dig_In_1_B2_i                      : std_logic_vector(7 downto 0);
signal Dig_In_1_B3_i                      : std_logic_vector(7 downto 0);
signal Dig_In_1_B4_i                      : std_logic_vector(7 downto 0);
signal Dig_In_1_B5_i                      : std_logic_vector(7 downto 0);
signal Dig_In_1_B6_i                      : std_logic_vector(7 downto 0);
signal Dig_In_1_B7_i                      : std_logic_vector(7 downto 0);
signal Main_Mux_Version_Name_i            : std_logic_vector(255 downto 0);
signal Main_Mux_Version_Number_i          : std_logic_vector(63 downto 0);
signal Main_Mux_Version_Ready_i           : std_logic; 
signal Main_Mux_Version_Request_i         : std_logic;
signal Real_Time_Clock_Request_i          : std_logic;
component Main_Mux is
  port (
    Clk                       : in  std_logic;
    RST_I                     : in  std_logic;
    UART_TXD                  : out std_logic;
    Message_Length            : in  std_logic_vector(7 downto 0);
    Seconds_out               : in std_logic_vector(7 downto 0); 
    Minutes_out               : in std_logic_vector(7 downto 0); 
    Hours_out                 : in std_logic_vector(7 downto 0); 
    Day_out                   : in std_logic_vector(7 downto 0); 
    Date_out                  : in std_logic_vector(7 downto 0); 
    Month_Century_out         : in std_logic_vector(7 downto 0); 
    Year_out                  : in std_logic_vector(7 downto 0);
    Dig_In_1_B0                : in  std_logic_vector(7 downto 0);
    Dig_In_1_B1                : in  std_logic_vector(7 downto 0);        
    Dig_In_1_B2                : in  std_logic_vector(7 downto 0);        
    Dig_In_1_B3                : in  std_logic_vector(7 downto 0);
    Dig_In_1_B4                : in  std_logic_vector(7 downto 0);
    Dig_In_1_B5                : in  std_logic_vector(7 downto 0);        
    Dig_In_1_B6                : in  std_logic_vector(7 downto 0);        
    Dig_In_1_B7                : in  std_logic_vector(7 downto 0); 
    Dig_In_2_B0                : in  std_logic_vector(7 downto 0);
    Dig_In_2_B1                : in  std_logic_vector(7 downto 0);        
    Dig_In_2_B2                : in  std_logic_vector(7 downto 0);        
    Dig_In_2_B3                : in  std_logic_vector(7 downto 0);
    Dig_In_2_B4                : in  std_logic_vector(7 downto 0);
    Dig_In_2_B5                : in  std_logic_vector(7 downto 0);        
    Dig_In_2_B6                : in  std_logic_vector(7 downto 0);        
    Dig_In_2_B7                : in  std_logic_vector(7 downto 0); 
    Digital_Input_Valid_1     : in  std_logic;
    Digital_Input_Valid_2     : in  std_logic;
    Dig_Out_1_B0               : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B1               : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B2               : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B3               : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B4               : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B5               : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B6               : in  std_logic_vector(7 downto 0);
    Dig_Out_1_B7               : in  std_logic_vector(7 downto 0);
    Digital_Output_Valid      : in  std_logic;
    Analog_Data               : in  std_logic_vector(767 downto 0);                
    Version_Register          : in  std_logic_vector(167 downto 0);
    Analog_Input_Valid        : in  std_logic;
    One_mS                    : in  std_logic;
    Baud_Rate_Enable          : in  std_logic;
    Real_Time_Clock_Request   : in  std_logic;
    Get_RTC                   : out std_logic;
    Version_Name              : in  std_logic_vector(255 downto 0); 
    Version_Number            : in  std_logic_vector(63 downto 0);
    Version_Data_Ready        : in  std_logic;
    RTC_Valid                 : in  std_logic;
    Data_Ready                : in  std_logic;
    Ana_In_Request            : out std_logic;
    Dig_In_Request            : out std_logic;
    Dig_Out_Request           : out std_logic;
    Main_Mux_Version_Name     : out std_logic_vector(255 downto 0);
    Main_Mux_Version_Number   : out std_logic_vector(63 downto 0);
    Main_Mux_Version_Ready    : out std_logic; 
    Main_Mux_Version_Request  : in  std_logic;
    Module_Number             : in  std_logic_vector(7 downto 0)
  );
end component Main_Mux;

-------------------------------------------------------------------------------
-- Endat Sniffer Component and Signals
-------------------------------------------------------------------------------

component EndatSniffer is
  generic 
  ( 
    MODE_BITS             : integer   :=  8;    -- Width of the mode data
    POS_BITS              : integer   :=  26;   -- Width of Position
    ADD_BITS              : integer   :=  25;   -- Width of Additional Data
    CRC_BITS              : integer   :=  5    -- Width of CRC 
  );
  port
   (
    clk                   : in  std_logic;     -- FPGA 50MHz clock
    reset_n               : in  std_logic;     -- FPGA Reset
    endat_clk             : in  std_logic;     -- Clock input from the EnDat sniffer Hardware
    endat_data            : in  std_logic;     -- Data input from the EnDat sniffer Hardware
    endat_enable          : in  std_logic;     -- request to sniff EnDat tranmission
    endat_mode_out        : out std_logic_vector(8 downto 0);  -- All data
    endat_Position_out    : out std_logic_vector(33 downto 0);  -- All data -- Updated
    endat_Data_1_out      : out std_logic_vector(31 downto 0);  -- All data
    endat_Data_2_out      : out std_logic_vector(31 downto 0);  -- All data
    data_cnt              : out integer; 
    endat_data_Ready      : out std_logic
  );
end component EndatSniffer;

signal endat_mode_out_i         : std_logic_vector(8 downto 0);
signal endat_Position_out_i     : std_logic_vector(31 downto 0);        -- Updated to 33
signal endat_Data_1_out_i       : std_logic_vector(31 downto 0);
signal endat_Data_2_out_i       : std_logic_vector(31 downto 0);
signal data_cnt_i               : integer;
signal endat_data_i             : std_logic;                 
signal endat_clk_i              : std_logic;
signal endat_data_Ready_i       : std_logic;

----------------------------------------------------------------------
-- Baud Rate for Mux Signals and Component
----------------------------------------------------------------------
signal baud_rate_i                            : integer range 0 to 7;
signal Baud_Rate_Enable_i                     : std_logic;  
signal Version_Baud_1_i                       : std_logic_vector(7 downto 0);
signal Version_Baud_2_i                       : std_logic_vector(7 downto 0);
signal Baud_Rate_Generator_Version_Name_1_i   : std_logic_vector(255 downto 0); 
signal Baud_Rate_Generator_Version_Number_1_i : std_logic_vector(63 downto 0); 
signal Baud_Rate_Generator_Version_Ready_1_i  : std_logic; 
signal Baud_Rate_Generator_Version_Name_2_i   : std_logic_vector(255 downto 0); 
signal Baud_Rate_Generator_Version_Number_2_i : std_logic_vector(63 downto 0); 
signal Baud_Rate_Generator_Version_Ready_2_i  : std_logic; 
signal Baud_Rate_Generator_Version_Request_i  : std_logic;  

component Baud_Rate_Generator is
  port (
    Clk                                 : in  std_logic;
    RST_I                               : in  std_logic;
    baud_rate                           : in  integer range 0 to 7;
    Baud_Rate_Enable                    : out std_logic;
    Module_Number                       : in  std_logic_vector(7 downto 0);
    Baud_Rate_Generator_Version_Request : in  std_logic; 
    Baud_Rate_Generator_Version_Name    : out std_logic_vector(255 downto 0);
    Baud_Rate_Generator_Version_Number  : out std_logic_vector(63 downto 0);
    Baud_Rate_Generator_Version_Ready   : out std_logic   
    );
end component Baud_Rate_Generator;

-- Temps
signal Temp_Tester 	: std_logic;
signal One_Sec_Delay : std_logic;

signal KEY_0       : std_logic;
signal KEY_1       : std_logic;
-- End of Signals and Components

-------------------------------------------------------------------------------
-- Clock for Genlock
-------------------------------------------------------------------------------  
signal PC_Comms_RX_i        : std_logic;
signal PC_Comms_TX_i        : std_logic;
signal Pieter_PC_Comms_RX_i : std_logic;
signal Pieter_PC_Comms_TX_i : std_logic;

signal Busy_In_1_i          : std_logic;
signal Busy_In_2_i          : std_logic;

signal Busy_Out_i      : std_logic;
signal SPI_Inpor_i     : std_logic_vector(15 downto 0);
signal Data_Out_Ready  : std_logic;
signal PC_Comms_TX     : std_logic;

signal One_Milli                        : std_logic;
signal SET_Timer_i                      : std_logic;
signal Seconds_out_mem_hi_i             : std_logic_vector(7 downto 0);
signal Seconds_out_mem_lo_i             : std_logic_vector(7 downto 0);
signal Minutes_out_mem_hi_i             : std_logic_vector(7 downto 0);
signal Minutes_out_mem_lo_i             : std_logic_vector(7 downto 0);
signal Hours_out_mem_hi_i               : std_logic_vector(7 downto 0);
signal Hours_out_mem_lo_i               : std_logic_vector(7 downto 0);
signal Day_out_mem_hi_i                 : std_logic_vector(7 downto 0);
signal Day_out_mem_lo_i                 : std_logic_vector(7 downto 0);
signal Date_out_mem_hi_i                : std_logic_vector(7 downto 0);
signal Date_out_mem_lo_i                : std_logic_vector(7 downto 0);
signal Month_Century_out_mem_hi_i       : std_logic_vector(7 downto 0);
signal Month_Century_out_mem_lo_i       : std_logic_vector(7 downto 0);
signal Year_out_mem_hi_i                : std_logic_vector(7 downto 0);
signal Year_out_mem_lo_i                : std_logic_vector(7 downto 0);
signal Ready_mem_i                      : std_logic;
signal Get_RTC_i                        : std_logic;
signal Get_Timer_i                      : std_logic;
signal I2C_Busy_i                       : std_logic;
signal RTC_Valid_i                        : std_logic;

-------------------------------------------------------------------------------
-- Code Start
-------------------------------------------------------------------------------  
begin

Firmware_Controller_Version_Updator: process(RST_I_i,CLK_I_i)
  variable APE_Test_System_FPGA_Firmware_Version_cnt: integer range 0 to 10;
  begin
    if RST_I_i = '0' then
      APE_Test_System_FPGA_Firmware_Version_Ready_i  <= '0';
      APE_Test_System_FPGA_Firmware_Version_Name_i   <= (others=>'0');
      APE_Test_System_FPGA_Firmware_Version_Number_i <= (others=>'0');
      APE_Test_System_FPGA_Firmware_Version_cnt      := 0;
      APE_Test_System_FPGA_Firmware_Version_Load_i   <= '0';
    elsif CLK_I_i'event and CLK_I_i = '1' then  
      
      if APE_Test_System_FPGA_Firmware_Version_Request_i = '1' then
        APE_Test_System_FPGA_Firmware_Version_Load_i   <= '1';
      else
        APE_Test_System_FPGA_Firmware_Version_Ready_i  <= '0';
      end if;
 
      if APE_Test_System_FPGA_Firmware_Version_Load_i = '1' then
        if APE_Test_System_FPGA_Firmware_Version_cnt = 5 then
          APE_Test_System_FPGA_Firmware_Version_Ready_i <= '1';
          APE_Test_System_FPGA_Firmware_Version_Load_i  <= '0';
          APE_Test_System_FPGA_Firmware_Version_cnt     := 0;
        else
          APE_Test_System_FPGA_Firmware_Version_cnt     := APE_Test_System_FPGA_Firmware_Version_cnt + 1;   
          APE_Test_System_FPGA_Firmware_Version_Ready_i <= '0';
        end if;  
      end if;     
 
   end if;
 end process Firmware_Controller_Version_Updator;

-------------------------------------------------------------------------------    
--  Wire
-------------------------------------------------------------------------------    
CLK_I_i             <= CLOCK_50;

-- SPI 1 Digital Input 1

-- Signal MApped in Accordance with Version 1 PCB
       
-- INS_________1
       
--INT_2_1_i           <= GPIO_0(25);
--INT_1_1_i           <= GPIO_0(29);
MISO_1_i            <= GPIO_0(31);
       
--- OUTS________1
GPIO_0(27)          <= SCKL_1_1_i;
GPIO_0(28)          <= MOSI_1_i;       
GPIO_0(30)          <= CS_1_1_i;       
GPIO_0(26)          <= CS_2_1_i;

-- SPI 2 Digital Output
       
-- Signal MApped in Accordance with Version 1 PCB

-- INS_________2
-- INT_1_2_i           <= GPIO_0(20);
-- INT_2_2_i           <= GPIO_0(24);
MISO_2_i            <= GPIO_0(21);

-- OUTS________2
GPIO_0(22)          <= SCKL_1_2_i;
GPIO_0(23)          <= CS_1_2_i;              
GPIO_0(32)          <= MOSI_2_i;       
GPIO_0(19)          <= CS_2_2_i;
              
-- SPI 3 Analog Input
       
-- Signal MApped in Accordance with Version 2 PCB
       
-- INS_________3		 
MISO_3_i            <= GPIO_0(13);
       
-- OUTS________3
GPIO_0(16)          <= SCKL_1_3_i;
GPIO_0(18)          <= CS_1_3_i;
GPIO_0(15)          <= INT_2_3_i;        
GPIO_0(33)          <= MOSI_3_i;       
GPIO_0(17)          <= INT_1_3_i;       
GPIO_0(14)          <= CS_2_3_i;        
       
-- SPI 4 Digital Input 2
 
 -- Version 1 PCB
 
 ---- INS________5
MISO_4_i           <= GPIO_0(8);
       
---- OUTS________5
GPIO_0(0)          <= SCKL_1_4_i;
GPIO_0(12)         <= MOSI_4_i;  
--GPIO_0()           <= CS_1_4_i;	 -- In GPIO_2	 
GPIO_0(11)         <= CS_2_4_i;
GPIO_0(9)          <= INT_1_4_i;       -- CS3
GPIO_0(10)         <= INT_2_4_i;       -- CS4
		 		 	 
--SPI 5 
       
GPIO_0(4)          <= '0';
GPIO_0(5)          <= '0';
GPIO_0(2)          <= '0';       
GPIO_0(7)          <= '0';       
GPIO_0(1)          <= '0';
                                                                  
 --GPIO1 Port Mapping 
GPIO_1(29)      <= '0';
GPIO_1(32)      <= '0';
GPIO_1(26)      <= '0';       
GPIO_1(28)      <= '0';
GPIO_1(27)      <= '0';
GPIO_1(30)      <= '0';
GPIO_1(31)      <= '0';       
GPIO_1(23)      <= '0';
GPIO_1(25)      <= '0';       
GPIO_1(33)      <= '0';              
GPIO_1(20)      <= '0';
GPIO_1(21)      <= '0';
GPIO_1(22)      <= '0';
GPIO_1(24)      <= '0';           
GPIO_1(15)      <= '0';
GPIO_1(14)      <= '0';
GPIO_1(18)      <= '0';
GPIO_1(19)      <= '0'; 
GPIO_1(16)      <= '0';
GPIO_1(17)      <= '0';  
GPIO_1(9)       <= '0';       
GPIO_1(0)       <= '0';
GPIO_1(10)      <= '0';       
GPIO_1(1)       <= '0';
GPIO_1(11)      <= '0';       
GPIO_1(13)      <= '0'; 
GPIO_1(12)      <= '0';
GPIO_1(5)       <= '0';      
GPIO_1(7)       <= '0';   
GPIO_1(2)       <= '0';
GPIO_1(6)       <= '0';       
GPIO_1(3)       <= '0'; 
GPIO_1(8)       <= '0'; 

-- GPIO2 Port Mapping
       
-- INS___________
Software_to_Controller_UART_RXD_i      <= GPIO_2(1); 
       -- OUTS__________        
GPIO_2(0)           <= Controller_to_Software_UART_TXD_i;
GPIO_2(6)           <= '1';     -- PC_Relay_Control_i;
GPIO_2(2)           <= MOSI_8_i;
GPIO_2(3)           <= CS_1_4_i;
           
-- Update Version Number when functionality changed
Version_Register_i <=  ISC_Controller_name_i & Null_i & Version_Major_High_i & Version_Major_Low_i & Dot_i &
Version_Minor_High_i & Version_Minor_Low_i & Dot_i &
Version_Timestamp_i & Null_i; 
-------------------------------------------------------------------------------    
--  Instantiations of Modules
-------------------------------------------------------------------------------

-- Version Register Instance
Ver_Reg_1: entity work.Version_Reg
port map (
    RST_I             => RST_I_i,
    CLK_I             => CLK_I_i,
    Version_Timestamp => Version_Timestamp_i
    );

---------------------------------
-- Version Control Instance 
---------------------------------

Version_Logger_1: entity work.Version_Logger
port map (
  CLK_I                                         => CLK_I_i,
  RST_I                                         => RST_I_i,
  SPI_IO_Driver_Version_Ready_1                 => SPI_IO_Driver_Version_Ready_1_i,
  SPI_IO_Driver_Version_Ready_2                 => SPI_IO_Driver_Version_Ready_2_i,
  SPI_Input_Handler_Version_Ready               => SPI_Input_Handler_Version_Ready_1_i,
  SPI_Output_Handler_Version_Ready              => SPI_Output_Handler_Version_Ready_i,
  SPI_Analog_Driver_Version_Ready_1             => SPI_Analog_Driver_Version_Ready_i,
  SPI_Analog_Handler_Version_Ready_1            => SPI_Analog_Handler_Version_Ready_i,
  APE_Test_System_FPGA_Firmware_Version_Ready   => APE_Test_System_FPGA_Firmware_Version_Ready_i,
  Version_Data_Ready                            => Version_Data_Ready_i,
  Real_Time_Clock_Handler_Version_Ready         => Real_Time_Clock_Handler_Version_Ready_i,
  Main_Demux_Version_Name                       => Main_Demux_Version_Name_i, 
  Main_Demux_Version_Number                     => Main_Demux_Version_Number_i,
  Main_Demux_Version_Ready                      => Main_Demux_Version_Ready_i, 
  Main_Mux_Version_Name                         => Main_Demux_Version_Name_i, 
  Main_Mux_Version_Number                       => Main_Demux_Version_Number_i,
  Main_Mux_Version_Ready                        => Main_Demux_Version_Ready_i, 
  SPI_IO_Driver_Version_Name                    => SPI_IO_Driver_Version_Name_1_i, 
  SPI_IO_Driver_Version_Number                  => SPI_IO_Driver_Version_Number_1_i,
  SPI_Input_Handler_Version_Name                => SPI_Input_Handler_Version_Name_1_i, 
  SPI_Input_Handler_Version_Number              => SPI_Input_Handler_Version_Number_1_i,
  SPI_Output_Handler_Version_Name               => SPI_Output_Handler_Version_Name_i, 
  SPI_Output_Handler_Version_Number             => SPI_Output_Handler_Version_Number_i, 
  SPI_Analog_Handler_Version_Name               => SPI_Analog_Handler_Version_Name_i, 
  SPI_Analog_Handler_Version_Number             => SPI_Analog_Handler_Version_Number_i,
  SPI_Analog_Driver_Version_Name                => SPI_Analog_Driver_Version_Name_i, 
  SPI_Analog_Driver_Version_Number              => SPI_Analog_Driver_Version_Number_i,
  Baud_Rate_Generator_Version_Name              => Baud_Rate_Generator_Version_Name_1_i,
  Baud_Rate_Generator_Version_Number            => Baud_Rate_Generator_Version_Number_1_i,
  Baud_Rate_Generator_Version_Ready             => Baud_Rate_Generator_Version_Ready_1_i,  
  APE_Test_System_FPGA_Firmware_Version_Name    => APE_Test_System_FPGA_Firmware_Version_Name_i,
  APE_Test_System_FPGA_Firmware_Version_Number  => APE_Test_System_FPGA_Firmware_Version_Number_i,
  Real_Time_Clock_Handler_Version_Name          => Real_Time_Clock_Handler_Version_Name_i, 
  Real_Time_Clock_Handler_Version_Number        => Real_Time_Clock_Handler_Version_Number_i,
  Module_Number                                 => Module_Number_i,
  Version_Name                                  => Version_Name_i,
  Version_Number                                => Version_Number_i
  );

-------------------------------------------------------------------------------
-- RTC I2C Driver Instance
-------------------------------------------------------------------------------
Real_Time_Clock_I2C_Driver_1: entity work.I2C_Driver
  PORT map (
    clk       => CLK_I_i,                  --system clock
    reset_n   => RST_I_i,                  --active low reset
    ena       => Enable_i,                 --latch in command
    addr      => Address_i,                --address of target slave
    rw        => RnW_i,                    --'0' is write, '1' is read
    data_wr   => Data_WR_i,                --data to write to slave
    busy      => I2C_Busy_i,                   --indicates transaction in progress
    data_rd   => Data_RD_i,                --data read from slave
    ack_error => Ack_Error_i,              --flag if improper acknowledge from slave
    sda       => SDA_i,                    --serial data output of i2c bus
    scl       => SCL_i                    -- serial clock output of i2c bus
    );    

-------------------------------------------------------------------------------
-- RTC I2C Handler Controller Instance
-------------------------------------------------------------------------------
Real_Time_Clock_Handler_1: entity work.Real_Time_Clock_I2C_Handler
    PORT map (
      CLK_I                                     => CLK_I_i,     
      RST_I                                     => RST_I_i,    
      Busy                                      => I2C_Busy_i,     
      data_read                                 => Data_RD_i,   
      ack_error                                 => Ack_Error_i, 
      initialation_Status                       => initialation_Status_i,
      Enable                                    => Enable_i,    
      Slave_Address_Out                         => Address_i,   
      Slave_read_nWrite                         => RnW_i,       
      Slave_Data_Out                            => Data_WR_i,   
      Get_Sample                                => Get_RTC_i,
      PPS_in                                    => PPS_in_i,
      Seconds_in                                => Seconds_in_i,          
      Minutes_in                                => Minutes_in_i,           
      Hours_in                                  => Hours_in_i,           
      Day_in                                    => Day_in_i,           
      Date_in                                   => Date_in_i, 
      Month_Century_in                          => Month_Century_in_i,   
      Year_in                                   => Year_in_i, 
      Write_RTC                                 => SET_Timer_i,           -- Write new RTC
      Seconds_out                               => Seconds_out_i,          
      Minutes_out                               => Minutes_out_i,           
      Hours_out                                 => Hours_out_i,           
      Day_out                                   => Day_out_i,           
      Date_out                                  => Date_out_i,
      Month_Century_out                         => Month_Century_out_i,    
      Year_out                                  => Year_out_i,   
      Ready                                     => RTC_Valid_i,
      Seconds_out_mem                           => Seconds_out_mem_i,
      Minutes_out_mem                           => Minutes_out_mem_i,
      Hours_out_mem                             => Hours_out_mem_i,
      Day_out_mem                               => Day_out_mem_i,
      Date_out_mem                              => Date_out_mem_i,
      Month_Century_out_mem                     => Month_Century_out_mem_i,
      Year_out_mem                              => Year_out_mem_i,
      Ready_mem                                 => Ready_mem_i,
      Real_Time_Clock_Handler_Version_Request   => Real_Time_Clock_Handler_Version_Request_i, 
      Real_Time_Clock_Handler_Version_Name      => Real_Time_Clock_Handler_Version_Name_i, 
      Real_Time_Clock_Handler_Version_Number    => Real_Time_Clock_Handler_Version_Number_i,
      Real_Time_Clock_Handler_Version_Ready     => Real_Time_Clock_Handler_Version_Ready_i 
      );  


-------------------------------------------------------------------------------                      
-- SPI In Driver Instance - Module 1
-------------------------------------------------------------------------------                      

SPI_In_1: entity work.SPI_IO_Driver
port map (
  RST_I                         => RST_I_i,
  CLK_I                         => CLK_I_i,
  nCS_Output_1                  => CS_1_1_i,
  nCS_Output_2                  => CS_2_1_i,
  Sclk                          => SCKL_1_1_i,
  Mosi                          => MOSI_1_i,
  Miso                          => MISO_1_i,
  Card_Select                   => Input_Card_Select_1_i,
  Data_In_Ready                 => Input_Data_Ready_1_i,       
  SPI_Outport                   => SPI_Data_out_1_i,           
  Data_Out_Ready                => Data_In_Ready_1_i,
  SPI_Inport                    => SPI_Inport_1_i,
  Busy                          => Busy_In_1_i,
  Module_Number                 => Module_Number_i,
  SPI_IO_Driver_Version_Request => SPI_IO_Driver_Version_Request_1_i,
  SPI_IO_Driver_Version_Name    => SPI_IO_Driver_Version_Name_1_i, 
  SPI_IO_Driver_Version_Number  => SPI_IO_Driver_Version_Number_1_i,
  SPI_IO_Driver_Version_Ready   => SPI_IO_Driver_Version_Ready_1_i                       
  );

-------------------------------------------------------------------------------                      
-- SPI Digital In Handler Instance - Module 2
-------------------------------------------------------------------------------                      

SPI_Input_Handler_1: SPI_Input_Handler
port map (
  RST_I                             => RST_I_i,
  CLK_I                             => CLK_I_i,
  Int_1                             => INT_1_1_i,
  Int_2                             => INT_2_1_i,
  SPI_Inport_1                      => SPI_Inport_1_1_i,
  SPI_Inport_2                      => SPI_Inport_1_2_i,
  SPI_Inport_3                      => SPI_Inport_1_3_i,
  SPI_Inport_4                      => SPI_Inport_1_4_i,
  SPI_Inport_5                      => SPI_Inport_1_5_i,
  SPI_Inport_6                      => SPI_Inport_1_6_i,
  SPI_Inport_7                      => SPI_Inport_1_7_i,
  SPI_Inport_8                      => SPI_Inport_1_8_i,
  Input_Ready                       => Digital_Input_Valid_1_i,
  SPI_Data_out                      => SPI_Data_out_1_i,
  Input_Data_ready                  => Input_Data_Ready_1_i,
  Input_Card_Select                 => Input_Card_Select_1_i,
  SPI_Data_in                       => SPI_Inport_1_i,
  busy                              => Busy_In_1_i,
  Dig_In_Request                    => Dig_In_Request_i,
  Module_Number                     => Module_Number_i,
  SPI_Input_Handler_Version_Request => SPI_Input_Handler_Version_Request_1_i,
  SPI_Input_Handler_Version_Name    => SPI_Input_Handler_Version_Name_1_i, 
  SPI_Input_Handler_Version_Number  => SPI_Input_Handler_Version_Number_1_i,
  SPI_Input_Handler_Version_Ready   => SPI_Input_Handler_Version_Ready_1_i   
  );

-------------------------------------------------------------------------------                      
-- SPI In 2 Driver Instance - Module 3
-------------------------------------------------------------------------------                      

SPI_In_2: entity work.SPI_IO_Driver
port map (
  RST_I                         => RST_I_i,
  CLK_I                         => CLK_I_i,
  nCS_Output_1                  => CS_1_4_i,
  nCS_Output_2                  => CS_2_4_i,
  Sclk                          => SCKL_1_4_i,
  Mosi                          => MOSI_4_i,
  Miso                          => MISO_4_i,
  Card_Select                   => Input_Card_Select_2_i,
  Data_In_Ready                 => Input_Data_Ready_2_i,       
  SPI_Outport                   => SPI_Data_out_2_i,           
  Data_Out_Ready                => Data_In_Ready_2_i,
  SPI_Inport                    => SPI_Inport_2_i,
  Busy                          => Busy_In_2_i,
  Module_Number                 => Module_Number_i,
  SPI_IO_Driver_Version_Request => SPI_IO_Driver_Version_Request_2_i,
  SPI_IO_Driver_Version_Name    => SPI_IO_Driver_Version_Name_2_i, 
  SPI_IO_Driver_Version_Number  => SPI_IO_Driver_Version_Number_2_i,
  SPI_IO_Driver_Version_Ready   => SPI_IO_Driver_Version_Ready_2_i                       
  );

-------------------------------------------------------------------------------                      
-- SPI Digital In Handler Instance - Module 4
-------------------------------------------------------------------------------                      

SPI_Input_Handler_2: SPI_Input_Handler
port map (
  RST_I                             => RST_I_i,
  CLK_I                             => CLK_I_i,
  Int_1                             => INT_1_1_i,
  Int_2                             => INT_2_1_i,
  SPI_Inport_1                      => SPI_Inport_2_1_i,
  SPI_Inport_2                      => SPI_Inport_2_2_i,
  SPI_Inport_3                      => SPI_Inport_2_3_i,
  SPI_Inport_4                      => SPI_Inport_2_4_i,
  SPI_Inport_5                      => SPI_Inport_2_5_i,
  SPI_Inport_6                      => SPI_Inport_2_6_i,
  SPI_Inport_7                      => SPI_Inport_2_7_i,
  SPI_Inport_8                      => SPI_Inport_2_8_i,
  Input_Ready                       => Digital_Input_Valid_2_i,
  SPI_Data_out                      => SPI_Data_out_2_i,
  Input_Data_ready                  => Input_Data_Ready_2_i,
  Input_Card_Select                 => Input_Card_Select_2_i,
  SPI_Data_in                       => SPI_Inport_2_i,
  busy                              => Busy_In_2_i,
  Dig_In_Request                    => Dig_In_Request_i,
  Module_Number                     => Module_Number_i,
  SPI_Input_Handler_Version_Request => SPI_Input_Handler_Version_Request_2_i,
  SPI_Input_Handler_Version_Name    => SPI_Input_Handler_Version_Name_2_i, 
  SPI_Input_Handler_Version_Number  => SPI_Input_Handler_Version_Number_2_i,
  SPI_Input_Handler_Version_Ready   => SPI_Input_Handler_Version_Ready_2_i   
  );
     
-------------------------------------------------------------------------------
 -- SPI Out Driver Instance - Module 5
-------------------------------------------------------------------------------
SPI_Out_1: SPI_IO_Driver
port map (
  RST_I                         => RST_I_i,
  CLK_I                         => CLK_I_i,
  nCS_Output_1                  => CS_1_2_i,
  nCS_Output_2                  => CS_2_2_i,
  Sclk                          => SCKL_1_2_i,
  Mosi                          => MOSI_2_i,
  Miso                          => MISO_2_i,
  Card_Select                   => Output_Card_Select_i,
  Data_In_Ready                 => Output_Data_Ready_i,      
  SPI_Outport                   => Output_SPI_Data_out_i,     
  Data_Out_Ready                => Data_Out_Ready_i,
  SPI_Inport                    => SPI_Inpor_i,
  Busy                          => Busy_Out_i,
  Module_Number                 => Module_Number_i,
  SPI_IO_Driver_Version_Request => SPI_IO_Driver_Version_Request_3_i,
  SPI_IO_Driver_Version_Name    => SPI_IO_Driver_Version_Name_3_i, 
  SPI_IO_Driver_Version_Number  => SPI_IO_Driver_Version_Number_3_i,
  SPI_IO_Driver_Version_Ready   => SPI_IO_Driver_Version_Ready_3_i               
  );
   
---------------------------------------------------------------------------------- 
-- SPI Digital Output Handler Instance [Box 1 Card 1 = 10 Card 2 = 11] - Module 3
----------------------------------------------------------------------------------       
SPI_Output_Handler_1: SPI_Output_Handler
port map (
  RST_I                                 => RST_I_i,
  CLK_I                                 => CLK_I_i,
  SPI_Outport_1                         => Dig_Card1_1_B0_i,
  SPI_Outport_2                         => Dig_Card1_1_B1_i,
  SPI_Outport_3                         => Dig_Card1_1_B2_i,
  SPI_Outport_4                         => Dig_Card1_1_B3_i,
  SPI_Outport_5                         => Dig_Card1_1_B4_i,
  SPI_Outport_6                         => Dig_Card1_1_B5_i,
  SPI_Outport_7                         => Dig_Card1_1_B6_i,
  SPI_Outport_8                         => Dig_Card1_1_B7_i,
  SPI_Inport_1                          => Dig_Card1_1_B0_Out_i,
  SPI_Inport_2                          => Dig_Card1_1_B1_Out_i,
  SPI_Inport_3                          => Dig_Card1_1_B2_Out_i,
  SPI_Inport_4                          => Dig_Card1_1_B3_Out_i,
  SPI_Inport_5                          => Dig_Card1_1_B4_Out_i,
  SPI_Inport_6                          => Dig_Card1_1_B5_Out_i,
  SPI_Inport_7                          => Dig_Card1_1_B6_Out_i,
  SPI_Inport_8                          => Dig_Card1_1_B7_Out_i,
  Output_SPI_Data_out                   => Output_SPI_Data_out_i,
  Output_Data_Ready                     => Output_Data_Ready_i,
  Output_Ready                          => Digital_Output_Valid_i,
  Output_Card_Select                    => Output_Card_Select_i,
  busy                                  => Busy_Out_i,
  Dig_Out_Request                       => Dig_Out_Request_i,
  SPI_Data_in                           => SPI_Inport_i,
  Input_Ready                           => Data_Out_Ready_i,
  Module_Number                         => Module_Number_i,
  SPI_Output_Handler_Version_Request    => SPI_Output_Handler_Version_Request_i,
  SPI_Output_Handler_Version_Name       => SPI_Output_Handler_Version_Name_i, 
  SPI_Output_Handler_Version_Number     => SPI_Output_Handler_Version_Number_i,
  SPI_Output_Handler_Version_Ready      => SPI_Output_Handler_Version_Ready_i       
  );
     

-------------------------------------------------------------------------------
-- Analog In Driver Instance - Module 4
-------------------------------------------------------------------------------
SPI_Analog_Driver_1: SPI_Analog_Driver
port map (
  RST_I                             => RST_I_i,
  CLK_I                             => CLK_I_i,
  CS1                               => Chip_Select_i(0),
  CS2                               => Chip_Select_i(1),
  CS3                               => Chip_Select_i(2),
  CS4                               => Chip_Select_i(3),
  nCS                               => nCS_i,
  Address                           => Address_out_i,  
  convert                           => convert_i,
  nCS_1                             => CS_1_3_i,
  nCS_2                             => CS_2_3_i,
  nCS_3                             => INT_1_3_i,
  nCS_4                             => INT_2_3_i,
  Sclk                              => SCKL_1_3_i,  
  Mosi                              => MOSI_3_i,
  Miso                              => MISO_3_i,
  AD_data                           => AD_data_i,
  Data_valid                        => Data_valid_i,
  Module_Number                     => Module_Number_i,
  SPI_Analog_Driver_Version_Request => SPI_Analog_Driver_Version_Request_i,
  SPI_Analog_Driver_Version_Name    => SPI_Analog_Driver_Version_Name_i, 
  SPI_Analog_Driver_Version_Number  => SPI_Analog_Driver_Version_Number_i,
  SPI_Analog_Driver_Version_Ready   => SPI_Analog_Driver_Version_Ready_i   
  );

-------------------------------------------------------------------------------                      
-- Analog In Handler 1 - Module 5
-------------------------------------------------------------------------------
SPI_Analog_Handler_1: SPI_Analog_Handler
port map (
  RST_I                              => RST_I_i,
  CLK_I                              => CLK_I_i,
  Address_out                        => Address_out_i,
  convert                            => convert_i,
  AD_data_in                         => AD_data_i,
  Data_valid                         => Data_valid_i,
  Chip_Select                        => Chip_Select_i, 
  Analog_Data                        => Analog_Data_i,
  Data_Ready                         => Analog_Input_Valid_i,
  Ana_In_Request                     => Ana_In_Request_i,
  Module_Number                      => Module_Number_i,
  SPI_Analog_Handler_Version_Request => SPI_Analog_Handler_Version_Request_i,
  SPI_Analog_Handler_Version_Name    => SPI_Analog_Handler_Version_Name_i, 
  SPI_Analog_Handler_Version_Number  => SPI_Analog_Handler_Version_Number_i,
  SPI_Analog_Handler_Version_Ready   => SPI_Analog_Handler_Version_Ready_i           
  );
 
-------------------------------------------------------------------------------
-- Demux Instance -  - Module 8
------------------------------------------------------------------------------- 
Main_Demux_1: entity work.Main_Demux
port map (
  CLK_I                                         => CLK_I_i,
  RST_I                                         => RST_I_i,
  UART_RXD                                      => Software_to_Controller_UART_RXD_i,
  Dig_Card1_1_B0                                => Dig_Card1_1_B0_i,
  Dig_Card1_1_B1                                => Dig_Card1_1_B1_i,
  Dig_Card1_1_B2                                => Dig_Card1_1_B2_i,
  Dig_Card1_1_B3                                => Dig_Card1_1_B3_i,
  Dig_Card1_1_B4                                => Dig_Card1_1_B4_i,
  Dig_Card1_1_B5                                => Dig_Card1_1_B5_i,
  Dig_Card1_1_B6                                => Dig_Card1_1_B6_i,
  Dig_Card1_1_B7                                => Dig_Card1_1_B7_i,
  SET_Timer                                     => SET_Timer_i,
  Dig_Outputs_Ready                             => Dig_Outputs_Ready_i,
  SPI_IO_Driver_Version_Request                 => SPI_IO_Driver_Version_Request_1_i,   
  SPI_Output_Handler_Version_Request            => SPI_Output_Handler_Version_Request_i,
  SPI_Input_Handler_Version_Request             => SPI_Input_Handler_Version_Request_1_i,
  SPI_Analog_Driver_Version_Request             => SPI_Analog_Driver_Version_Request_i,
  SPI_Analog_Handler_Version_Request            => SPI_Analog_Handler_Version_Request_i,
  Real_Time_Clock_Handler_Version_Request       => Real_Time_Clock_Handler_Version_Request_i,
  Main_Mux_Version_Request                      => Main_Mux_Version_Request_i, 
  Baud_Rate_Generator_Version_Request           => Baud_Rate_Generator_Version_Request_i,
  APE_Test_System_FPGA_Firmware_Version_Request => APE_Test_System_FPGA_Firmware_Version_Request_i,
  Endat_Sniffer_Version_Request                 => Endat_Sniffer_Version_Request_i,   
  Module_Number                                 => Module_Number_i,
  Main_Demux_Version_Name                       => Main_Demux_Version_Name_i, 
  Main_Demux_Version_Number                     => Main_Demux_Version_Number_i,
  Main_Demux_Version_Ready                      => Main_Demux_Version_Ready_i 
  );
           
-------------------------------------------------------------------------------
-- APE Firmware Controller Mux 
-------------------------------------------------------------------------------
Main_Mux_1: entity work.Main_Mux
port map (
  CLK_I                      => CLK_I_i,
  RST_I                      => RST_I_i,
  UART_TXD                   => Controller_to_Software_UART_TXD_i,
  Seconds_out                => Seconds_out_i,          
  Minutes_out                => Minutes_out_i,           
  Hours_out                  => Hours_out_i,           
  Day_out                    => Day_out_i,           
  Date_out                   => Date_out_i,
  Month_Century_out          => Month_Century_out_i,    
  Year_out                   => Year_out_i,
  Dig_Out_1_B0               => Dig_Card1_1_B0_i,
  Dig_Out_1_B1               => Dig_Card1_1_B1_i,
  Dig_Out_1_B2               => Dig_Card1_1_B2_i,
  Dig_Out_1_B3               => Dig_Card1_1_B3_i,
  Dig_Out_1_B4               => Dig_Card1_1_B4_i,
  Dig_Out_1_B5               => Dig_Card1_1_B5_i,
  Dig_Out_1_B6               => Dig_Card1_1_B6_i,
  Dig_Out_1_B7               => Dig_Card1_1_B7_i,
  Digital_Input_Valid_1      => Digital_Input_Valid_1_i,
  Digital_Input_Valid_2      => Digital_Input_Valid_2_i,
  Dig_In_1_B0                => SPI_Inport_1_1_i,                
  Dig_In_1_B1                => SPI_Inport_1_2_i,               
  Dig_In_1_B2                => SPI_Inport_1_3_i,                 
  Dig_In_1_B3                => b"0000000" & SPI_Inport_1_4_i(0),               
  Dig_In_1_B4                => SPI_Inport_1_5_i,                
  Dig_In_1_B5                => SPI_Inport_1_6_i,                
  Dig_In_1_B6                => SPI_Inport_1_7_i,                
  Dig_In_1_B7                => b"0000000" & SPI_Inport_1_8_i(0),  
  Dig_In_2_B0                => SPI_Inport_2_1_i,                
  Dig_In_2_B1                => SPI_Inport_2_2_i,               
  Dig_In_2_B2                => SPI_Inport_2_3_i,                 
  Dig_In_2_B3                => b"0000000" & SPI_Inport_2_4_i(0),               
  Dig_In_2_B4                => SPI_Inport_2_5_i,                
  Dig_In_2_B5                => SPI_Inport_2_6_i,                
  Dig_In_2_B6                => SPI_Inport_2_7_i,                
  Dig_In_2_B7                => b"0000000" & SPI_Inport_1_8_i(0),        
  Digital_Output_Valid       => Digital_Output_Valid_i,
  Analog_Data                => Analog_Data_i, 
  Analog_Input_Valid         => Analog_Input_Valid_i,
  Ana_In_Request             => Ana_In_Request_i,
  Dig_In_Request             => Dig_In_Request_i,                
  Dig_Out_Request            => Dig_Out_Request_i,               
  Baud_Rate_Enable           => Mux_Baud_Rate_Enable_i,
  Data_Ready                 => Data_Ready_i,
  Real_Time_Clock_Request    => Real_Time_Clock_Request_i,
  RTC_Valid                  => RTC_Valid_i,
  One_mS                     => One_mS_i,
  Module_Number              => Module_Number_i,
  Main_Mux_Version_Name      => Main_Mux_Version_Name_i, 
  Main_Mux_Version_Number    => Main_Mux_Version_Number_i,
  Main_Mux_Version_Ready     => Main_Mux_Version_Ready_i, 
  Main_Mux_Version_Request   => Main_Mux_Version_Request_i, 
  Message_Length             => Message_Length_i,
  Version_Name               => Version_Name_i,
  Version_Number             => Version_Number_i,
  Version_Data_Ready         => Version_Data_Ready_i
  );                              

-------------------------------------------------------------------------------
-- APE Endat Sniffer Instance 
-------------------------------------------------------------------------------
APE_Endat_Sniffer_1: entity work.EndatSniffer
port map (
    clk                  => CLK_I_i,                -- FPGA 50MHz clock
    reset_n              => RST_I_i,                -- FPGA Reset
    endat_clk            => endat_clk_i,            -- Clock input from the EnDat sniffer Hardware
    endat_data           => endat_data_i,           -- Data input from the EnDat sniffer Hardware
    endat_enable         => endat_clk_i,            -- request to sniff EnDat tranmission
    endat_mode_out       => endat_mode_out_i,       -- All data
    endat_Position_out   => endat_Position_out_i,   -- All data
    endat_Data_1_out     => endat_Data_1_out_i,     -- All data
    endat_Data_2_out     => endat_Data_2_out_i,     -- All data
    data_cnt             => data_cnt_i, 
    endat_data_Ready     => endat_data_Ready_i
);

-------------------------------------------------------------------------------
-- Baud Instance for Mux  
-------------------------------------------------------------------------------     
APE_Test_System_FPGA_Firmware_Baud_1: entity work.Baud_Rate_Generator
port map (
  Clk                                 => CLK_I_i,
  RST_I                               => RST_I_i,
  baud_rate                           => 5,
  Baud_Rate_Enable                    => Mux_Baud_Rate_Enable_i,
  Module_Number                       => Module_Number_i,
  Baud_Rate_Generator_Version_Request => Baud_Rate_Generator_Version_Request_i,
  Baud_Rate_Generator_Version_Name    => Baud_Rate_Generator_Version_Name_1_i,
  Baud_Rate_Generator_Version_Number  => Baud_Rate_Generator_Version_Number_1_i,
  Baud_Rate_Generator_Version_Ready   => Baud_Rate_Generator_Version_Ready_1_i  
  );

-------------------------------------------------------------------------------
-- Test Only
------------------------------------------------------------------------------- 
-- add switches and Leds
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
       
 Time_Trigger: process(RST_I_i,CLOCK_50)
    variable bit_cnt_OuS       : integer range 0 to 100;
    variable bit_cnt_OmS       : integer range 0 to 60000;
    variable bit_cnt_TmS       : integer range 0 to 600000;
    variable bit_cnt_20mS      : integer range 0 to 2000000;       
    variable bit_cnt_HmS       : integer range 0 to 6000000;
    variable Sec_Cnt           : integer range 0 to 11;
    variable Two_ms_cnt        : integer range 0 to 3;
	 variable Oms_Cnt           : integer range 0 to 30;
    begin
      if RST_I_i = '0' then
         bit_cnt_OuS       := 0;
         bit_cnt_OmS       := 0;
         bit_cnt_TmS       := 0;         
         bit_cnt_HmS       := 0;
         bit_cnt_20mS      := 0;          
         One_uS_i          <= '0';
         One_mS_i          <= '0';        
         Ten_mS_i          <= '0';
         Twenty_mS_i       <= '0';
         Hunder_mS_i       <= '0';
         One_Sec_i         <= '0';
      elsif CLOCK_50'event and CLOCK_50 = '1' then      
--1uS
            if bit_cnt_OuS = 50 then
               One_uS_i         <= '1';
               bit_cnt_OuS      := 0;                      
            else
               One_uS_i        <= '0';
               bit_cnt_OuS      := bit_cnt_OuS + 1;
            end if;
--1mS            
            if bit_cnt_OmS = 50000 then
               One_mS_i         <= '1';                 
               bit_cnt_OmS      := 0;
               Two_ms_cnt       := Two_ms_cnt + 1;
					OmS_Cnt          := OmS_Cnt + 1;
            else
               One_mS_i   <= '0';
               bit_cnt_OmS      := bit_cnt_OmS + 1;
            end if;
-- 2 ms
            if Two_ms_cnt = 2 then
               Two_ms_i     <= '1';
               Two_ms_cnt   := 0;
            else
               Two_ms_i      <= '0';
            end if;   
-- 10ms            
            if bit_cnt_TmS = 500000 then
               Ten_mS_i   <= '1';
               bit_cnt_TmS      := 0;                      
            else
               Ten_mS_i   <= '0';
               bit_cnt_TmS      := bit_cnt_TmS + 1;
            end if;

-- 20mS         
            if bit_cnt_20mS = 1000000 then
               Twenty_mS_i   <= '1';
               bit_cnt_20mS  := 0;                      
            else
               Twenty_mS_i   <= '0';
               bit_cnt_20mS  := bit_cnt_20mS + 1;
            end if;    

-- 23 ms For Send Test
            if Oms_Cnt = 23 then
               Oms_Cnt := 0;
	            Twenty_Three_mS <= '1';
	         else
               Twenty_Three_mS <= '0';
            end if;					
            
--100Ms
            if bit_cnt_HmS = 5000000 then
               Hunder_mS_i      <= '1';                  
               bit_cnt_HmS      := 0;
               Sec_Cnt          := Sec_Cnt + 1;
            else
               Hunder_mS_i      <= '0';
               bit_cnt_HmS      := bit_cnt_HmS + 1;
            end if;

-- 1 sec
            if Sec_Cnt = 10 then
               One_Sec_i <= '1';
               Sec_Cnt   := 0;
            else
              One_Sec_i  <= '0';
            end if;  
      end if;
 end process Time_Trigger;
                            
  Reset_gen : process(CLOCK_50)
          variable cnt : integer range 0 to 255;
        begin
          if (CLOCK_50'event) and (CLOCK_50 = '1') then            
            if cnt = 255 then
               RST_I_i <= '1';
            else
               cnt := cnt + 1;
               RST_I_i <= '0';
             end if;
          end if;
        end process Reset_gen; 
  
  end Arch_DUT;

