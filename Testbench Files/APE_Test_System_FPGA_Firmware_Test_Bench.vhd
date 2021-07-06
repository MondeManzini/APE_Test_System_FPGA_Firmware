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
    use std.textio.all;
    use work.txt_util.all;
    use work.Version_Ascii.all;

library modelsim_lib;
    use modelsim_lib.util.all;

entity APE_Test_System_FPGA_Firmware_Test_Bench is

end APE_Test_System_FPGA_Firmware_Test_Bench;

architecture Archtest_bench of APE_Test_System_FPGA_Firmware_Test_Bench is
	
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

signal Version_Register_i       : STD_LOGIC_VECTOR(199 downto 0);

-- Timestamp from Tcl Script
signal Version_Timestamp_i      : STD_LOGIC_VECTOR(111 downto 0);       -- 20181120105439
  
-- Firmware Module
constant Endat_Firmware_Controller_name_i   : STD_LOGIC_VECTOR(23 downto 0) := x"524643";  -- Endat_FirmwareC

-- Version Major Number - Hardcoded
constant Version_Major_High_i   : STD_LOGIC_VECTOR(7 downto 0) := x"30";  -- 0x
constant Version_Major_Low_i    : STD_LOGIC_VECTOR(7 downto 0) := x"30";  -- x3

constant Dot_i                  : STD_LOGIC_VECTOR(7 downto 0) := x"2e";  -- .
-- Version Minor Number - Hardcoded
constant Version_Minor_High_i   : STD_LOGIC_VECTOR(7 downto 0) := x"32";  -- 0x
constant Version_Minor_Low_i    : STD_LOGIC_VECTOR(7 downto 0) := x"30";  -- x0
-- Null Termination
constant Null_i                 : STD_LOGIC_VECTOR(7 downto 0) := x"00";  -- termination

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
signal Endat_Firmware_Controller_Version_Ready_i    : std_logic;
signal Endat_Firmware_Controller_Version_Name_i     : std_logic_vector(255 downto 0);
signal Endat_Firmware_Controller_Version_Number_i   : std_logic_vector(63 downto 0);
signal Version_Endat_Firmware_controller            : std_logic_vector(7 downto 0);  
signal Endat_Firmware_Controller_Version_Request_i  : std_logic;
signal Endat_Firmware_Controller_Version_Load_i     : std_logic;

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
    Endat_Firmware_Controller_Version_Ready       : in  std_logic; 
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
    Endat_Firmware_Controller_Version_Name        : in  std_logic_vector(255 downto 0);
    Endat_Firmware_Controller_Version_Number      : in  std_logic_vector(63 downto 0);
    Version_Data_Ready                            : out std_logic;
    Module_Number                                 : in  std_logic_vector(7 downto 0);
    Version_Name                                  : out std_logic_vector(255 downto 0);
    Version_Number                                : out std_logic_vector(63 downto 0));
end component Version_Logger;
  
-- Version Signals and Component
component Version_Reg is
    generic(
        log_file   : string           --:= "Firmware Version Log File.txt"
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
END component Real_Time_Clock_I2C_Handler;

signal Get_Sample_i           : std_logic;
signal Sync_i                 : std_logic;
signal Enable_in_i            : std_logic;
signal PPS_in_i               : std_logic;
signal Enable_i               : std_logic;
signal Address_i              : std_logic_vector(6 downto 0);
signal RnW_i                  : std_logic;
signal Data_WR_i              : std_logic_vector(7 downto 0);
signal Ready_i                : std_logic;
signal Seconds_out_i          : std_logic_vector(7 downto 0);         
signal Minutes_out_i          : std_logic_vector(7 downto 0);     
signal Hours_out_i            : std_logic_vector(7 downto 0);
signal Day_out_i              : std_logic_vector(7 downto 0);         
signal Date_out_i             : std_logic_vector(7 downto 0);     
signal Month_Century_out_i    : std_logic_vector(7 downto 0);
signal Year_out_i             : std_logic_vector(7 downto 0);
signal Seconds_in_i           : std_logic_vector(7 downto 0);         
signal Minutes_in_i           : std_logic_vector(7 downto 0);     
signal Hours_in_i             : std_logic_vector(7 downto 0);
signal Day_in_i               : std_logic_vector(7 downto 0);         
signal Date_in_i              : std_logic_vector(7 downto 0);     
signal Month_Century_in_i     : std_logic_vector(7 downto 0);
signal Year_in_i              : std_logic_vector(7 downto 0);
signal Ack_Error_i            : std_logic;
signal SDA_i                  : std_logic;
signal SCL_i                  : std_logic;  
signal lock_Out_i             : std_logic;
signal lock_Out2_i            : std_logic;
signal Busy_i                 : std_logic;
signal Data_RD_i              : std_logic_vector(7 downto 0);
signal Start_i                : std_logic;
signal lockout_i              : std_logic;
signal initialation_Status_i  : std_logic;
signal TestData               : std_logic_vector(7 downto 0);


----------------------------------------------------------------------
-- SPI Driver ignals and Component
----------------------------------------------------------------------

signal nCS_Output_1_i                   : std_logic;
signal nCS_Output_2_i                   : std_logic;
signal Int_1_i                          : std_logic;
signal Int_2_i                          : std_logic;
signal Sclk_i                           : std_logic;
signal Mosi_i                           : std_logic;
signal Miso_i                           : std_logic;
signal Card_Select_i                    : std_logic;
signal Data_In_Ready_i                  : std_logic;
signal SPI_Outport_i                    : std_logic_vector(15 downto 0);
signal Data_Out_Ready_i                 : std_logic;
signal SPI_Inport                       : std_logic_vector(15 downto 0);
signal SPI_Inport_i                     : std_logic_vector(15 downto 0);  
signal Version_SPI_IO_Driver_1_i        : std_logic_vector(7 downto 0); 
signal Version_SPI_IO_Driver_2_i        : std_logic_vector(7 downto 0);
signal SPI_IO_Driver_Version_Request_i  : std_logic;
signal SPI_IO_Driver_Version_Name_1_i   : std_logic_vector(255 downto 0); 
signal SPI_IO_Driver_Version_Number_1_i : std_logic_vector(63 downto 0);
signal SPI_IO_Driver_Version_Ready_1_i  : std_logic; 
signal SPI_IO_Driver_Version_Name_2_i   : std_logic_vector(255 downto 0); 
signal SPI_IO_Driver_Version_Number_2_i : std_logic_vector(63 downto 0);
signal SPI_IO_Driver_Version_Ready_2_i  : std_logic;

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
signal SPI_Inport_1_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_2_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_3_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_4_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_5_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_6_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_7_i                      : std_logic_vector(7 downto 0);
signal SPI_Inport_8_i                      : std_logic_vector(7 downto 0);
signal SPI_Data_out_i                      : std_logic_vector(15 downto 0);
signal Input_Data_ready_i                  : std_logic;
signal Input_Ready_i                       : std_logic;
signal Input_Card_Select_i                 : std_logic;
signal SPI_Data_in_i                       : std_logic_vector(15 downto 0);
signal Input_Data_In_ready_i               : std_logic;
signal Sample_Rate_i                       : integer range 0 to 1000;
signal Dig_In_Request_i                    : std_logic;
signal Version_Input_Handler_i             : std_logic_vector(7 downto 0);
signal SPI_Input_Handler_Version_Request_i : std_logic;
signal SPI_Input_Handler_Version_Name_i    : std_logic_vector(255 downto 0); 
signal SPI_Input_Handler_Version_Number_i  : std_logic_vector(63 downto 0);
signal SPI_Input_Handler_Version_Ready_i   : std_logic; 

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
signal Version_Output_Handler_i             : std_logic_vector(7 downto 0);
signal Dig_Out_Request_i                    : std_logic;
signal SPI_Output_Handler_Version_Request_i : std_logic;
signal SPI_Output_Handler_Version_Name_i    : std_logic_vector(255 downto 0); 
signal SPI_Output_Handler_Version_Number_i  : std_logic_vector(63 downto 0);
signal SPI_Output_Handler_Version_Ready_i   : std_logic; 
signal Busy_Out_i                           : std_logic;

component SPI_Output_Handler is
  port (
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
    Input_Ready                         : in  std_logic;
    Output_SPI_Data_out                 : out std_logic_vector(15 downto 0);
    Output_Data_ready                   : out std_logic;
    Output_Ready                        : out std_logic;
    Output_Card_Select                  : out std_logic;       
    busy                                : in  std_logic;
    Module_Number                       : in  std_logic_vector(7 downto 0);
    SPI_Output_Handler_Version_Request  : in  std_logic;
    SPI_Output_Handler_Version_Name     : out std_logic_vector(255 downto 0); 
    SPI_Output_Handler_Version_Number   : out std_logic_vector(63 downto 0);
    SPI_Output_Handler_Version_Ready    : out std_logic; 
    Dig_Out_Request                     : in  std_logic
    );
end component SPI_Output_Handler;

----------------------------------------------------------------------
-- Analog Input Driver Signals and Component
----------------------------------------------------------------------
signal CS1_i                                : std_logic;
signal CS2_i                                : std_logic;
signal CS3_i                                : std_logic;
signal CS4_i                                : std_logic;
signal Address_out_i                        : std_logic_vector(2 downto 0);
signal convert_i                            : std_logic;
signal nCS_1_i                              : std_logic;
signal nCS_2_i                              : std_logic;
signal nCS_3_i                              : std_logic;
signal nCS_4_i                              : std_logic;
signal AD_data_i                            : std_logic_vector(15 downto 0);
signal Data_valid_i                         : std_logic;
signal Analog_Input_Valid_i                 : std_logic;
signal nCS1_i                               : std_logic;
signal nCS2_i                               : std_logic; 
signal nCS_i                                : std_logic; 
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
signal CH1_o_i                                : std_logic_vector(15 downto 0);
signal CH2_o_i                                : std_logic_vector(15 downto 0);
signal CH3_o_i                                : std_logic_vector(15 downto 0);
signal CH4_o_i                                : std_logic_vector(15 downto 0);
signal CH5_o_i                                : std_logic_vector(15 downto 0);
signal CH6_o_i                                : std_logic_vector(15 downto 0);
signal CH7_o_i                                : std_logic_vector(15 downto 0);
signal CH8_o_i                                : std_logic_vector(15 downto 0);
signal CH9_o_i                                : std_logic_vector(15 downto 0);
signal CH10_o_i                               : std_logic_vector(15 downto 0);
signal CH11_o_i                               : std_logic_vector(15 downto 0);
signal CH12_o_i                               : std_logic_vector(15 downto 0);
signal CH13_o_i                               : std_logic_vector(15 downto 0);
signal CH14_o_i                               : std_logic_vector(15 downto 0);
signal CH15_o_i                               : std_logic_vector(15 downto 0);
signal CH16_o_i                               : std_logic_vector(15 downto 0);
signal CH17_o_i                               : std_logic_vector(15 downto 0);
signal CH18_o_i                               : std_logic_vector(15 downto 0);
signal CH19_o_i                               : std_logic_vector(15 downto 0);
signal CH20_o_i                               : std_logic_vector(15 downto 0);
signal CH21_o_i                               : std_logic_vector(15 downto 0);
signal CH22_o_i                               : std_logic_vector(15 downto 0);
signal CH23_o_i                               : std_logic_vector(15 downto 0);
signal CH24_o_i                               : std_logic_vector(15 downto 0);
signal CH25_o_i                               : std_logic_vector(15 downto 0);
signal CH26_o_i                               : std_logic_vector(15 downto 0);
signal CH27_o_i                               : std_logic_vector(15 downto 0);
signal CH28_o_i                               : std_logic_vector(15 downto 0);
signal CH29_o_i                               : std_logic_vector(15 downto 0);
signal CH30_o_i                               : std_logic_vector(15 downto 0);
signal CH31_o_i                               : std_logic_vector(15 downto 0);
signal CH32_o_i                               : std_logic_vector(15 downto 0);
signal CH33_o_i                               : std_logic_vector(15 downto 0);
signal CH34_o_i                               : std_logic_vector(15 downto 0);
signal CH35_o_i                               : std_logic_vector(15 downto 0);
signal CH36_o_i                               : std_logic_vector(15 downto 0);
signal CH37_o_i                               : std_logic_vector(15 downto 0);
signal CH38_o_i                               : std_logic_vector(15 downto 0);
signal CH39_o_i                               : std_logic_vector(15 downto 0);
signal CH40_o_i                               : std_logic_vector(15 downto 0);
signal CH41_o_i                               : std_logic_vector(15 downto 0);
signal CH42_o_i                               : std_logic_vector(15 downto 0);
signal CH43_o_i                               : std_logic_vector(15 downto 0);
signal CH44_o_i                               : std_logic_vector(15 downto 0);
signal CH45_o_i                               : std_logic_vector(15 downto 0);
signal CH46_o_i                               : std_logic_vector(15 downto 0);
signal CH47_o_i                               : std_logic_vector(15 downto 0);
signal CH48_o_i                               : std_logic_vector(15 downto 0);
signal CH1_2_o_i                              : std_logic_vector(15 downto 0);
signal CH2_2_o_i                              : std_logic_vector(15 downto 0);
signal CH3_2_o_i                              : std_logic_vector(15 downto 0);
signal CH4_2_o_i                              : std_logic_vector(15 downto 0);
signal CH5_2_o_i                              : std_logic_vector(15 downto 0);
signal CH6_2_o_i                              : std_logic_vector(15 downto 0);
signal CH7_2_o_i                              : std_logic_vector(15 downto 0);
signal CH8_2_o_i                              : std_logic_vector(15 downto 0);
signal CH9_2_o_i                              : std_logic_vector(15 downto 0);
signal CH10_2_o_i                             : std_logic_vector(15 downto 0);
signal CH11_2_o_i                             : std_logic_vector(15 downto 0);
signal CH12_2_o_i                             : std_logic_vector(15 downto 0);
signal CH13_2_o_i                             : std_logic_vector(15 downto 0);
signal CH14_2_o_i                             : std_logic_vector(15 downto 0);
signal CH15_2_o_i                             : std_logic_vector(15 downto 0);
signal CH16_2_o_i                             : std_logic_vector(15 downto 0);
signal CH17_2_o_i                             : std_logic_vector(15 downto 0);
signal CH18_2_o_i                             : std_logic_vector(15 downto 0);
signal CH19_2_o_i                             : std_logic_vector(15 downto 0);
signal CH20_2_o_i                             : std_logic_vector(15 downto 0);
signal CH21_2_o_i                             : std_logic_vector(15 downto 0);
signal CH22_2_o_i                             : std_logic_vector(15 downto 0);
signal CH23_2_o_i                             : std_logic_vector(15 downto 0);
signal CH24_2_o_i                             : std_logic_vector(15 downto 0);
signal CH25_2_o_i                             : std_logic_vector(15 downto 0);
signal CH26_2_o_i                             : std_logic_vector(15 downto 0);
signal CH27_2_o_i                             : std_logic_vector(15 downto 0);
signal CH28_2_o_i                             : std_logic_vector(15 downto 0);
signal CH29_2_o_i                             : std_logic_vector(15 downto 0);
signal CH30_2_o_i                             : std_logic_vector(15 downto 0);
signal CH31_2_o_i                             : std_logic_vector(15 downto 0);
signal CH32_2_o_i                             : std_logic_vector(15 downto 0);
signal CH33_2_o_i                             : std_logic_vector(15 downto 0);
signal CH34_2_o_i                             : std_logic_vector(15 downto 0);
signal CH35_2_o_i                             : std_logic_vector(15 downto 0);
signal CH36_2_o_i                             : std_logic_vector(15 downto 0);
signal CH37_2_o_i                             : std_logic_vector(15 downto 0);
signal CH38_2_o_i                             : std_logic_vector(15 downto 0);
signal CH39_2_o_i                             : std_logic_vector(15 downto 0);
signal CH40_2_o_i                             : std_logic_vector(15 downto 0);
signal CH41_2_o_i                             : std_logic_vector(15 downto 0);
signal CH42_2_o_i                             : std_logic_vector(15 downto 0);
signal CH43_2_o_i                             : std_logic_vector(15 downto 0);
signal CH44_2_o_i                             : std_logic_vector(15 downto 0);
signal CH45_2_o_i                             : std_logic_vector(15 downto 0);
signal CH46_2_o_i                             : std_logic_vector(15 downto 0);
signal CH47_2_o_i                             : std_logic_vector(15 downto 0);
signal CH48_2_o_i                             : std_logic_vector(15 downto 0);
signal Version_Analog_Handler_1_i             : std_logic_vector(7 downto 0);
signal Version_Analog_Handler_2_i             : std_logic_vector(7 downto 0);
signal SPI_Analog_Handler_Version_Request_i   : std_logic;
signal SPI_Analog_Handler_Version_Name_i      : std_logic_vector(255 downto 0); 
signal SPI_Analog_Handler_Version_Number_i    : std_logic_vector(63 downto 0);
signal SPI_Analog_Handler_Version_Ready_i     : std_logic;

component SPI_Analog_Handler is
  port (
    RST_I                              : in  std_logic;
    CLK_I                              : in  std_logic;
    Address_out                        : out std_logic_vector(2 downto 0);
    convert                            : out std_logic;
    CS1                                : out std_logic;
    CS2                                : out std_logic;
    CS3                                : out std_logic;
    CS4                                : out std_logic;
    AD_data_in                         : in  std_logic_vector(15 downto 0);
    Data_valid                         : in  std_logic;
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
end component SPI_Analog_Handler;

----------------------------------------------------------------------
-- Timer Signals and Component
----------------------------------------------------------------------
signal One_mS_Enable_i                    : std_logic;
signal One_Sec_Enable_i                   : std_logic;
signal One_mS_Cnt_i                       : integer range 0 to 1024;
signal SET_Timer_i                        : std_logic;
signal One_mSEC_Pulse_i                   : std_logic;
signal Timer_Sec_Reg_i                    : std_logic_vector(31 downto 0);
signal Timer_mSec_Reg_i                   : std_logic_vector(15 downto 0);
signal Timer_Sec_Reg_1_i                  : std_logic_vector(31 downto 0);
signal Timer_mSec_Reg_1_i                 : std_logic_vector(15 downto 0);


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
signal Module_Number_i                    : std_logic_vector(7 downto 0);

component Main_Demux is
  port (
    CLK_I                               : in  std_logic;
    RST_I                               : in  std_logic;
    UART_RXD                            : in  std_logic;
    Timer_Sec_Reg                       : out std_logic_vector(31 downto 0);
    Timer_mSec_Reg                      : out std_logic_vector(15 downto 0);
    Dig_Card1_1_B0                      : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B1                      : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B2                      : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B3                      : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B4                      : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B5                      : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B6                      : out std_logic_vector(7 downto 0);
    Dig_Card1_1_B7                      : out std_logic_vector(7 downto 0);
    SET_Timer                           : out std_logic;
    Dig_Outputs_Ready                   : out std_logic;
    Module_Number                       : out std_logic_vector(7 downto 0);
    SPI_IO_Driver_Version_Request       : out std_logic;  
    SPI_Output_Handler_Version_Request  : out std_logic; 
    SPI_Input_Handler_Version_Request   : out std_logic; 
    SPI_Analog_Driver_Version_Request   : out std_logic;
    SPI_Analog_Handler_Version_Request  : out std_logic; 
    Main_Mux_Version_Request            : out std_logic; 
    Baud_Rate_Generator_Version_Request : out std_logic; 
    Endat_Controller_Version_Request    : out std_logic; 
    Main_Demux_Version_Name             : out std_logic_vector(255 downto 0); 
    Main_Demux_Version_Number           : out std_logic_vector(63 downto 0);
    Main_Demux_Version_Ready            : out std_logic 
    );
end component Main_Demux;

----------------------------------------------------------------------
-- Mux Signals and Component
----------------------------------------------------------------------
signal Controller_to_Software_UART_TXD_i  : std_logic;
signal Message_Length_i                   : std_logic_vector(7 downto 0);
signal Message_ID1_i                      : std_logic_vector(7 downto 0);
signal Digital_Input_Valid_i              : std_logic;
signal Dig_Card1_2_B0_i                   : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B1_i                   : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B2_i                   : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B3_i                   : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B4_i                   : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B5_i                   : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B6_i                   : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B7_i                   : std_logic_vector(7 downto 0);
signal Digital_Output_Valid_i             : std_logic;
signal Tx_Rate_i                          : integer range 0 to 255;
signal Mux_Baud_Rate_Enable_i             : std_logic;
signal SYCN_Pulse_i                       : std_logic;
signal Watchdog_Reset_i                   : std_logic;
signal Watchdog_Status_in_i               : std_logic_vector(15 downto 0);
signal Mux_watchdog_i                     : std_logic;
signal Ana_In_Request_i                   : std_logic;
signal Real_Time_Clock_Ready_i            : std_logic;

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

component Main_Mux is
    port (
        Clk                     : in  std_logic;
        RST_I                   : in  std_logic;
        UART_TXD                : out std_logic;
        Message_Length          : in  std_logic_vector(7 downto 0);
        Seconds_out             : in std_logic_vector(7 downto 0); 
        Minutes_out             : in std_logic_vector(7 downto 0); 
        Hours_out               : in std_logic_vector(7 downto 0); 
        Day_out                 : in std_logic_vector(7 downto 0); 
        Date_out                : in std_logic_vector(7 downto 0); 
        Month_Century_out       : in std_logic_vector(7 downto 0); 
        Year_out                : in std_logic_vector(7 downto 0); 
        Dig_Card1_1_B0          : in  std_logic_vector(7 downto 0);
        Dig_Card1_1_B1          : in  std_logic_vector(7 downto 0);
        Dig_Card1_1_B2          : in  std_logic_vector(7 downto 0);
        Dig_Card1_1_B3          : in  std_logic_vector(7 downto 0);
        Dig_Card1_1_B4          : in  std_logic_vector(7 downto 0);
        Dig_Card1_1_B5          : in  std_logic_vector(7 downto 0);
        Dig_Card1_1_B6          : in  std_logic_vector(7 downto 0);
        Dig_Card1_1_B7          : in  std_logic_vector(7 downto 0);
        Digital_Input_Valid     : in  std_logic;
        Dig_Card1_2_B0          : in  std_logic_vector(7 downto 0);
        Dig_Card1_2_B1          : in  std_logic_vector(7 downto 0);
        Dig_Card1_2_B2          : in  std_logic_vector(7 downto 0);
        Dig_Card1_2_B3          : in  std_logic_vector(7 downto 0);
        Dig_Card1_2_B4          : in  std_logic_vector(7 downto 0);
        Dig_Card1_2_B5          : in  std_logic_vector(7 downto 0);
        Dig_Card1_2_B6          : in  std_logic_vector(7 downto 0);
        Dig_Card1_2_B7          : in  std_logic_vector(7 downto 0);
        Digital_Output_Valid    : in  std_logic;
        Alg_Card1_1             : in  std_logic_vector(15 downto 0);        
        Alg_Card1_2             : in  std_logic_vector(15 downto 0);                
        Alg_Card1_3             : in  std_logic_vector(15 downto 0);
        Alg_Card1_4             : in  std_logic_vector(15 downto 0);        
        Alg_Card1_5             : in  std_logic_vector(15 downto 0);
        Alg_Card1_6             : in  std_logic_vector(15 downto 0);
        Alg_Card1_7             : in  std_logic_vector(15 downto 0);
        Alg_Card1_8             : in  std_logic_vector(15 downto 0);
        Alg_Card1_9             : in  std_logic_vector(15 downto 0);
        Alg_Card1_10            : in  std_logic_vector(15 downto 0);        
        Alg_Card1_11            : in  std_logic_vector(15 downto 0);
        Alg_Card1_12            : in  std_logic_vector(15 downto 0);
        Alg_Card1_13            : in  std_logic_vector(15 downto 0);
        Alg_Card1_14            : in  std_logic_vector(15 downto 0);
        Alg_Card1_15            : in  std_logic_vector(15 downto 0);
        Alg_Card1_16            : in  std_logic_vector(15 downto 0);        
        Alg_Card1_17            : in  std_logic_vector(15 downto 0);
        Alg_Card1_18            : in  std_logic_vector(15 downto 0);
        Alg_Card1_19            : in  std_logic_vector(15 downto 0);
        Alg_Card1_20            : in  std_logic_vector(15 downto 0);
        Alg_Card1_21            : in  std_logic_vector(15 downto 0);
        Alg_Card1_22            : in  std_logic_vector(15 downto 0);        
        Alg_Card1_23            : in  std_logic_vector(15 downto 0);
        Alg_Card1_24            : in  std_logic_vector(15 downto 0);
        Alg_Card1_25            : in  std_logic_vector(15 downto 0);
        Alg_Card1_26            : in  std_logic_vector(15 downto 0);
        Alg_Card1_27            : in  std_logic_vector(15 downto 0);
        Alg_Card1_28            : in  std_logic_vector(15 downto 0);        
        Alg_Card1_29            : in  std_logic_vector(15 downto 0);
        Alg_Card1_30            : in  std_logic_vector(15 downto 0);
        Alg_Card1_31            : in  std_logic_vector(15 downto 0);
        Alg_Card1_32            : in  std_logic_vector(15 downto 0);
        Alg_Card1_33            : in  std_logic_vector(15 downto 0);
        Alg_Card1_34            : in  std_logic_vector(15 downto 0);        
        Alg_Card1_35            : in  std_logic_vector(15 downto 0);
        Alg_Card1_36            : in  std_logic_vector(15 downto 0);
        Alg_Card1_37            : in  std_logic_vector(15 downto 0);
        Alg_Card1_38            : in  std_logic_vector(15 downto 0);
        Alg_Card1_39            : in  std_logic_vector(15 downto 0);
        Alg_Card1_40            : in  std_logic_vector(15 downto 0);        
        Alg_Card1_41            : in  std_logic_vector(15 downto 0);
        Alg_Card1_42            : in  std_logic_vector(15 downto 0);
        Alg_Card1_43            : in  std_logic_vector(15 downto 0);
        Alg_Card1_44            : in  std_logic_vector(15 downto 0);
        Alg_Card1_45            : in  std_logic_vector(15 downto 0);
        Alg_Card1_46            : in  std_logic_vector(15 downto 0);        
        Alg_Card1_47            : in  std_logic_vector(15 downto 0);
        Alg_Card1_48            : in  std_logic_vector(15 downto 0);        
        Version_Register        : in  std_logic_vector(167 downto 0);
        Analog_Input_Valid      : in  std_logic;
        One_mS_pulse            : in  std_logic;
        Tx_Rate                 : in  integer range 0 to 255;
        Baud_Rate_Enable        : in  std_logic;
        SYCN_Pulse              : out std_logic;
        Version_Data_Ready      : in  std_logic;
        Real_Time_Clock_Ready   : in std_logic;
        Data_Ready              : in  std_logic;
        Watchdog_Reset          : in  std_logic;
        Mux_watchdog            : out std_logic;
        Ana_In_Request          : out std_logic;
        Dig_In_Request          : out std_logic;
        Dig_Out_Request         : out std_logic
    );
end component Main_Mux;

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

 
signal Mosi                     : std_logic;
signal Miso                     : std_logic;
signal Sclk                     : std_logic;
signal Busy                     : std_logic;
signal Data_Out_Ready           : std_logic;
signal nCS_Output_1             : std_logic;
signal nCS_Output_2             : std_logic;
signal Sample_Rate_1_i          : integer range 0 to 20;
signal Ser_clk                  : std_logic;
signal Ser_clk1                  : std_logic;
signal DIN                       : std_logic;
signal DIN1                      : std_logic;
signal Ser_clk2                  : std_logic;
signal DIN2                      : std_logic;
signal DOUT                     : std_logic;
signal DOUT2                     : std_logic;


signal Dig_In_B0_i              : std_logic_vector(7 downto 0);
signal Dig_In_B1_i              : std_logic_vector(7 downto 0);
signal Dig_In_B2_i              : std_logic_vector(7 downto 0);
signal Dig_In_B3_i              : std_logic_vector(7 downto 0);
signal Dig_Out_B0_i             : std_logic_vector(7 downto 0);
signal Dig_Out_B1_i             : std_logic_vector(7 downto 0);
signal Dig_Out_B2_i             : std_logic_vector(7 downto 0);
signal Dig_Out_B3_i             : std_logic_vector(7 downto 0);

signal display_version_lock :STD_LOGIC;
signal Version_Register_std_logic : string(1 to 28);

-------------------------------------------------------------------------------
-- New Code Signal and Components
------------------------------------------------------------------------------- 
signal RST_I_i                  : std_logic;
signal CLK_I_i                  : std_logic;
signal Time_Mux                 : std_logic;
signal Roach_Trigger            : std_logic; 

signal TestData_i                   : std_logic_vector(7 downto 0); 
signal Int_SCL_i                    : std_logic;
signal Int_SDA_i                    : std_logic;
signal Start_Detected               : std_logic; 
signal Byte_Address                 : std_logic; 
signal busy_mux_lockout_i           : std_logic; 
signal Delay_Count                  : integer range 0 to 126;
signal Byte_Count                   : integer range 0 to 15;
signal Record_Slave_Address         : std_logic_vector(6 downto 0);
signal Test_Byte_i                  : std_logic_vector(7 downto 0); 
signal Lockout_Edge_i               : std_logic_vector(7 downto 0);
signal Seconds_TestData_i           : std_logic_vector(7 downto 0);
signal Minutes_TestData_i           : std_logic_vector(7 downto 0);
signal Hours_TestData_i             : std_logic_vector(7 downto 0);
signal Days_TestData_i              : std_logic_vector(7 downto 0);
signal Dates_TestData_i             : std_logic_vector(7 downto 0);
signal Years_TestData_i             : std_logic_vector(7 downto 0);
signal Months_Century_TestData_i    : std_logic_vector(7 downto 0);
signal Seconds_TestData_int         : integer range 0 to 60;
signal Minutes_TestData_int         : integer range 0 to 60;
signal Hours_TestData_int           : integer range 0 to 24;
signal Days_TestData_int            : integer range 0 to 31;
signal Months_Century_TestData_int  : integer range 0 to 12;

----------------------------------------
----------------------------------------
-- General Signals
-------------------------------------------------------------------------------
type I2C_Test_States is (Wait_Start, Config_State, Read_State);
type Test_I2C_Config_States is (StartEdge, StartFallingEdge, WriteData, RisingEdge, ReadData, FallingEdge, WriteAck, RisingEdgeAck, ReadAck,  
                              FallingEdgeAck, AckRisingEdge, WaitStop);
type Test_I2C_Read_States is (StartEdge, StartFallingEdge, WriteData, RisingEdge, ReadData, FallingEdge, WriteAck, RisingEdgeAck, ReadAck,  
                            FallingEdgeAck, AckRisingEdge, WaitStop, ReStartEdge,  StartFallingEdgeData_SA, WriteData_SA, RisingEdgeData_SA, Read_Slave_Data_SA, FallingEdgeData_SA, 
                            WriteAckData_SA, RisingEdgeAckData_SA, ReadAckData_SA, FallingEdgeAckData_SA, WriteData_Data, RisingEdgeData_Data, 
                            Read_Slave_Data_Data,  Test_Byte_Complete, FallingEdgeData_Data, WriteAckData_Data, RisingEdgeAckData_Data, ReadAckData_Data, FallingEdgeAckData_Data,
                            AckRisingEdgeData,WaitStopData);
type Real_Time_Counters_States is (Idle, mS_counter, Min_counter, Hrs_counter, Days_counter, Mon_Cen_counter, Years_counter);
signal I2C_Test_State           : I2C_Test_States;
signal Test_I2C_Config_State    : Test_I2C_Config_States;
signal Test_I2C_Read_State      : Test_I2C_Read_States;
signal Real_Time_Counters_State : Real_Time_Counters_States;  

signal  sClok,snrst,sStrobe,PWM_sStrobe,newClk,Clk : std_logic := '0';
signal  stx_data,srx_data : std_logic_vector(3 downto 0) := "0000";
signal  sCnt         : integer range 0 to 7 := 0;
signal  cont         : integer range 0 to 100;  
signal  oClk,OneuS_sStrobe, Quad_CHA_sStrobe, Quad_CHB_sStrobe,OnemS_sStrobe,cStrobe,sStrobe_A,Ten_mS_sStrobe,Twenty_mS_sStrobe, Fifty_mS_sStrobe, Hun_mS_sStrobe, Sec_sStrobe : std_logic;

constant Baudrate : integer := 115200;
constant bit_time_4800      : time                         := 52.08*4 us;
constant bit_time_9600      : time                         := 52.08*2 us;    
constant bit_time_19200     : time                         := 52.08 us;
constant bit_time_57600     : time                         := 17.36 us;    
constant bit_time_115200    : time                         := 8.68 us;  
constant default_bit_time   : time                         := 52.08 us;  --19200  
constant start_bit          : std_logic := '0';
constant stop_bit           : std_logic := '1';
signal   bit_time           : time;

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
signal Ready_mem_i                     : std_logic;

-- Build State
-- Good Build State 
------------------------------------------
-- Messages following the software scripts 
------------------------------------------

-- Digital Output Messages

signal digital_output_all_off      : std_logic_vector(170 downto 0):=                                
                                    stop_bit & X"a2" &                    -- CRC L
                                    start_bit & stop_bit & X"db" &        -- CRC H
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte7 
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte6
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte5
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte4
                                    start_bit & stop_bit & X"11" &        -- OutputCard2
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte3 
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte2
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte1
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte0
                                    start_bit & stop_bit & X"10" &        -- OutputCard1
                                    start_bit & stop_bit & X"81" &        -- Mode
                                    start_bit & stop_bit & X"11" &        -- Length
                                    start_bit & stop_bit & X"7e" &        -- Preamb1
                                    start_bit & stop_bit & X"5a" &        -- Preamb2
                                    start_bit & stop_bit & X"a5" & "01";  -- Preamb1
                                                                          
                                                                          
signal digital_output_01_on        : std_logic_vector(170 downto 0):=                                
                                    stop_bit & X"81" &                    -- CRC L
                                    start_bit & stop_bit & X"30" &        -- CRC H
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte7 
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte6
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte5
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte4
                                    start_bit & stop_bit & X"11" &        -- OutputCard2
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte3 
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte2
                                    start_bit & stop_bit & X"00" &        -- DigOut1Byte1
                                    start_bit & stop_bit & X"01" &        -- DigOut1Byte0
                                    start_bit & stop_bit & X"10" &        -- OutputCard1
                                    start_bit & stop_bit & X"81" &        -- Mode
                                    start_bit & stop_bit & X"11" &        -- Length
                                    start_bit & stop_bit & X"7e" &        -- Preamb1
                                    start_bit & stop_bit & X"5a" &        -- Preamb2
                                    start_bit & stop_bit & X"a5" & "01";  -- Preamb1
                                                                          
signal digital_output_off_on           : std_logic_vector(170 downto 0):=                                
                                    stop_bit & X"6c" &                    -- CRC L
                                    start_bit & stop_bit & X"04" &        -- CRC H
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte7 
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte6
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte5
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte4
                                    start_bit & stop_bit & X"11" &        -- OutputCard2
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte3 
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte2
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte1
                                    start_bit & stop_bit & X"55" &        -- DigOut1Byte0
                                    start_bit & stop_bit & X"10" &        -- OutputCard1
                                    start_bit & stop_bit & X"81" &        -- Mode
                                    start_bit & stop_bit & X"11" &        -- Length
                                    start_bit & stop_bit & X"7e" &        -- Preamb1
                                    start_bit & stop_bit & X"5a" &        -- Preamb2
                                    start_bit & stop_bit & X"a5" & "01";  -- Preamb1

signal digital_output_on_off           : std_logic_vector(170 downto 0):=                                
                                    stop_bit & X"1f" &                    -- CRC L
                                    start_bit & stop_bit & X"74" &        -- CRC H
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte7 
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte6
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte5
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte4
                                    start_bit & stop_bit & X"11" &        -- OutputCard2
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte3 
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte2
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte1
                                    start_bit & stop_bit & X"aa" &        -- DigOut1Byte0
                                    start_bit & stop_bit & X"10" &        -- OutputCard1
                                    start_bit & stop_bit & X"81" &        -- Mode
                                    start_bit & stop_bit & X"11" &        -- Length
                                    start_bit & stop_bit & X"7e" &        -- Preamb1
                                    start_bit & stop_bit & X"5a" &        -- Preamb2
                                    start_bit & stop_bit & X"a5" & "01";  -- Preamb1

signal digital_output_all_on           : std_logic_vector(170 downto 0):=                                
                                    stop_bit & X"34" &                    -- CRC L
                                    start_bit & stop_bit & X"e2" &        -- CRC H
                                    start_bit & stop_bit & X"11" &        -- DigOut1Byte7 
                                    start_bit & stop_bit & X"11" &        -- DigOut1Byte6
                                    start_bit & stop_bit & X"11" &        -- DigOut1Byte5
                                    start_bit & stop_bit & X"11" &        -- DigOut1Byte4
                                    start_bit & stop_bit & X"11" &        -- OutputCard2
                                    start_bit & stop_bit & X"11" &        -- DigOut1Byte3 
                                    start_bit & stop_bit & X"11" &        -- DigOut1Byte2
                                    start_bit & stop_bit & X"11" &        -- DigOut1Byte1
                                    start_bit & stop_bit & X"11" &        -- DigOut1Byte0
                                    start_bit & stop_bit & X"10" &        -- OutputCard1
                                    start_bit & stop_bit & X"81" &        -- Mode
                                    start_bit & stop_bit & X"11" &        -- Length
                                    start_bit & stop_bit & X"7e" &        -- Preamb1
                                    start_bit & stop_bit & X"5a" &        -- Preamb2
                                    start_bit & stop_bit & X"a5" & "01";  -- Preamb1

  signal Write_Reg_Cont        : std_logic_vector(350 downto 0):=                                
                                    stop_bit & X"12" &                    -- CRC L
                                    start_bit & stop_bit & X"88" &        -- CRC H
                                    start_bit & stop_bit & X"CC" &        -- Checksum
                                    start_bit & stop_bit & X"24" &        -- Byte24    
                                    start_bit & stop_bit & X"23" &        -- Byte23
                                    start_bit & stop_bit & X"22" &        -- Byte22
                                    start_bit & stop_bit & X"21" &        -- Byte21 
                                    start_bit & stop_bit & X"20" &        -- Byte20 
                                    start_bit & stop_bit & X"19" &        -- Byte19 
                                    start_bit & stop_bit & X"18" &        -- Byte18
                                    start_bit & stop_bit & X"17" &        -- Byte17
                                    start_bit & stop_bit & X"16" &        -- Byte16 
                                    start_bit & stop_bit & X"15" &        -- Byte15 
                                    start_bit & stop_bit & X"14" &        -- Byte14 
                                    start_bit & stop_bit & X"13" &        -- Byte13
                                    start_bit & stop_bit & X"12" &        -- Byte12
                                    start_bit & stop_bit & X"11" &        -- Byte11 
                                    start_bit & stop_bit & X"10" &        -- Byte10 
                                    start_bit & stop_bit & X"09" &        -- Byte9 
                                    start_bit & stop_bit & X"08" &        -- Byte8
                                    start_bit & stop_bit & X"07" &        -- Byte7
                                    start_bit & stop_bit & X"06" &        -- Byte6 
                                    start_bit & stop_bit & X"05" &        -- Byte5 
                                    start_bit & stop_bit & X"04" &        -- Byte4 
                                    start_bit & stop_bit & X"03" &        -- Byte3
                                    start_bit & stop_bit & X"02" &        -- Byte2
                                    start_bit & stop_bit & X"01" &        -- Byte1
                                    start_bit & stop_bit & X"08" &        -- Command
                                    start_bit & stop_bit & X"00" &        -- Val Unit
                                    start_bit & stop_bit & X"00" &        -- Exp Len
                                    start_bit & stop_bit & X"84" &        -- Mode
                                    start_bit & stop_bit & X"23" &        -- Length
                                    start_bit & stop_bit & X"7E" &        -- Preamb1
                                    start_bit & stop_bit & X"5A" &        -- Preamb2
                                    start_bit & stop_bit & X"A5" & "01";  -- Preamb1

-- Generate Version Data  
signal set_version_data        : std_logic_vector(70 downto 0):=
stop_bit  &            X"21" &        -- CRC L
    start_bit & stop_bit & X"07" &        -- CRC H
    start_bit & stop_bit & X"90" &        -- Mode
    start_bit & stop_bit & X"07" &        -- Length
    start_bit & stop_bit & X"7e" &        -- Preamb1
    start_bit & stop_bit & X"5a" &        -- Preamb2
    start_bit & stop_bit & X"a5" & "01";  -- Preamb1                                                                                                                                                  
--------------------------------------------------------------------------------------------------------------------------------------------------------
  -- SPI Input Signals
--------------------------------------------------------------------------------------------------------------------------------------------------------
begin
      
 RST_I_i            <= snrst;
 CLK_I_i            <= sClok;
 Version_Register_i <=  Endat_Firmware_Controller_name_i & Null_i & Version_Major_High_i & Version_Major_Low_i & Dot_i &
                        Version_Minor_High_i & Version_Minor_Low_i & Dot_i &
                        Version_Timestamp_i & Null_i; 
     
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
   
---------------------------------
-- Version Control Instance 
---------------------------------

Version_Logger_1: entity work.Version_Logger
port map (
  CLK_I                                     => CLK_I_i,
  RST_I                                     => RST_I_i,
  SPI_IO_Driver_Version_Ready_1             => SPI_IO_Driver_Version_Ready_1_i,
  SPI_IO_Driver_Version_Ready_2             => SPI_IO_Driver_Version_Ready_2_i,
  SPI_Input_Handler_Version_Ready           => SPI_Input_Handler_Version_Ready_i,
  SPI_Output_Handler_Version_Ready          => SPI_Output_Handler_Version_Ready_i,
  SPI_Analog_Driver_Version_Ready_1         => SPI_Analog_Driver_Version_Ready_i,
  SPI_Analog_Handler_Version_Ready_1        => SPI_Analog_Handler_Version_Ready_i,
  Endat_Firmware_Controller_Version_Ready   => Endat_Firmware_Controller_Version_Ready_i,
  Version_Data_Ready                        => Version_Data_Ready_i,
  Main_Demux_Version_Name                   => Main_Demux_Version_Name_i, 
  Main_Demux_Version_Number                 => Main_Demux_Version_Number_i,
  Main_Demux_Version_Ready                  => Main_Demux_Version_Ready_i, 
  Main_Mux_Version_Name                     => Main_Demux_Version_Name_i, 
  Main_Mux_Version_Number                   => Main_Demux_Version_Number_i,
  Main_Mux_Version_Ready                    => Main_Demux_Version_Ready_i, 
  SPI_IO_Driver_Version_Name                => SPI_IO_Driver_Version_Name_1_i, 
  SPI_IO_Driver_Version_Number              => SPI_IO_Driver_Version_Number_1_i,
  SPI_Input_Handler_Version_Name            => SPI_Input_Handler_Version_Name_i, 
  SPI_Input_Handler_Version_Number          => SPI_Input_Handler_Version_Number_i,
  SPI_Output_Handler_Version_Name           => SPI_Output_Handler_Version_Name_i, 
  SPI_Output_Handler_Version_Number         => SPI_Output_Handler_Version_Number_i, 
  SPI_Analog_Handler_Version_Name           => SPI_Analog_Handler_Version_Name_i, 
  SPI_Analog_Handler_Version_Number         => SPI_Analog_Handler_Version_Number_i,
  SPI_Analog_Driver_Version_Name            => SPI_Analog_Driver_Version_Name_i, 
  SPI_Analog_Driver_Version_Number          => SPI_Analog_Driver_Version_Number_i,
  Baud_Rate_Generator_Version_Name          => Baud_Rate_Generator_Version_Name_1_i,
  Baud_Rate_Generator_Version_Number        => Baud_Rate_Generator_Version_Number_1_i,
  Baud_Rate_Generator_Version_Ready         => Baud_Rate_Generator_Version_Ready_1_i,  
  Endat_Firmware_Controller_Version_Name    => Endat_Firmware_Controller_Version_Name_i,
  Endat_Firmware_Controller_Version_Number  => Endat_Firmware_Controller_Version_Number_i,
  Module_Number                             => Module_Number_i,
  Version_Name                              => Version_Name_i,
  Version_Number                            => Version_Number_i
  );

-- Module for Test Purpose -----------------------------
-- Version Verifier Instance
Ver_Dat_1: entity work.Version_RX_UASRT
    port map (
        nrst               => RST_I_i,
        Clk                => CLK_I_i,
        UART_RXD           => Controller_to_Software_UART_TXD_i,
        Version_Data       => Version_Register_i,
        Version_Data_Ready => SYCN_Pulse_i
    );    
------------------------------------------------------------
-- Version Register Instance
Ver_Reg_1: entity work.Version_Reg
    port map (
        RST_I             => RST_I_i,
        CLK_I             => CLK_I_i,
        Version_Timestamp => Version_Timestamp_i
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
    busy      => Busy_i,                   --indicates transaction in progress
    data_rd   => Data_RD_i,                --data read from slave
    ack_error => Ack_Error_i,              --flag if improper acknowledge from slave
    sda       => SDA_i,                    --serial data output of i2c bus
    scl       => SCL_i                    -- serial clock output of i2c bus
    );    

-------------------------------------------------------------------------------
-- RTC I2C Handler Controller Instance
-------------------------------------------------------------------------------
Real_Time_Clock_I2C_Handler_1: entity work.Real_Time_Clock_I2C_Handler
  PORT map (
    CLK_I                       => CLK_I_i,     
    RST_I                       => RST_I_i,    
    Busy                        => Busy_i,     
    data_read                   => Data_RD_i,   
    ack_error                   => Ack_Error_i, 
    initialation_Status         => initialation_Status_i,
    Enable                      => Enable_i,    
    Slave_Address_Out           => Address_i,   
    Slave_read_nWrite           => RnW_i,       
    Slave_Data_Out              => Data_WR_i,   
    Get_Sample                  => Get_Sample_i,
    PPS_in                      => PPS_in_i,
    Seconds_in                  => Seconds_in_i,          
    Minutes_in                  => Minutes_in_i,           
    Hours_in                    => Hours_in_i,           
    Day_in                      => Day_in_i,           
    Date_in                     => Date_in_i, 
    Month_Century_in            => Month_Century_in_i,   
    Year_in                     => Year_in_i, 
    Seconds_out                 => Seconds_out_i,          
    Minutes_out                 => Minutes_out_i,           
    Hours_out                   => Hours_out_i,           
    Day_out                     => Day_out_i,           
    Date_out                    => Date_out_i,
    Month_Century_out           => Month_Century_out_i,    
    Year_out                    => Year_out_i,   
    Ready                       => Real_Time_Clock_Ready_i,
    Seconds_out_mem_hi          => Seconds_out_mem_hi_i,
    Seconds_out_mem_lo          => Seconds_out_mem_lo_i,
    Minutes_out_mem_hi          => Minutes_out_mem_hi_i,
    Minutes_out_mem_lo          => Minutes_out_mem_lo_i,
    Hours_out_mem_hi            => Hours_out_mem_hi_i,
    Hours_out_mem_lo            => Hours_out_mem_lo_i,
    Day_out_mem_hi              => Day_out_mem_hi_i,
    Day_out_mem_lo              => Day_out_mem_lo_i,
    Date_out_mem_hi             => Date_out_mem_hi_i,
    Date_out_mem_lo             => Date_out_mem_lo_i,
    Month_Century_out_mem_hi    => Month_Century_out_mem_hi_i,
    Month_Century_out_mem_lo    => Month_Century_out_mem_lo_i,
    Year_out_mem_hi             => Year_out_mem_hi_i,
    Year_out_mem_lo             => Year_out_mem_lo_i,
    Ready_mem                   => Ready_mem_i  
    );   
    
-------------------------------------------------------------------------------                      
-- SPI In Driver Instance - Module 1
-------------------------------------------------------------------------------                      

SPI_In_1: entity work.SPI_IO_Driver
port map (
  RST_I                         => RST_I_i,
  CLK_I                         => CLK_I_i,
  nCS_Output_1                  => nCS_Output_1,
  nCS_Output_2                  => nCS_Output_2,
  Sclk                          => Sclk,
  Mosi                          => Mosi,
  Miso                          => Miso,
  Card_Select                   => Input_Card_Select_i,
  Data_In_Ready                 => Input_Data_Ready_i,       
  SPI_Outport                   => SPI_Data_out_i,           
  Data_Out_Ready                => Data_In_Ready_i,
  SPI_Inport                    => SPI_Inport_i,
  Busy                          => busy_i,
  Module_Number                 => Module_Number_i,
  SPI_IO_Driver_Version_Request => SPI_IO_Driver_Version_Request_i,
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
  Int_1                             => Int_1_i,
  Int_2                             => Int_2_i,
  SPI_Inport_1                      => SPI_Inport_1_i,
  SPI_Inport_2                      => SPI_Inport_2_i,
  SPI_Inport_3                      => SPI_Inport_3_i,
  SPI_Inport_4                      => SPI_Inport_4_i,
  SPI_Inport_5                      => SPI_Inport_5_i,
  SPI_Inport_6                      => SPI_Inport_6_i,
  SPI_Inport_7                      => SPI_Inport_7_i,
  SPI_Inport_8                      => SPI_Inport_8_i,
  Input_Ready                       => Digital_Input_Valid_i,
  SPI_Data_out                      => SPI_Data_out_i,
  Input_Data_ready                  => Input_Data_Ready_i,
  Input_Card_Select                 => Input_Card_Select_i,
  SPI_Data_in                       => SPI_Inport_i,
  busy                              => busy_i,
  Dig_In_Request                    => Dig_In_Request_i,
  Module_Number                     => Module_Number_i,
  SPI_Input_Handler_Version_Request => SPI_Input_Handler_Version_Request_i,
  SPI_Input_Handler_Version_Name    => SPI_Input_Handler_Version_Name_i, 
  SPI_Input_Handler_Version_Number  => SPI_Input_Handler_Version_Number_i,
  SPI_Input_Handler_Version_Ready   => SPI_Input_Handler_Version_Ready_i   
  );

-------------------------------------------------------------------------------
 -- SPI Out Driver Instance - Module 1
-------------------------------------------------------------------------------
SPI_Out_1: SPI_IO_Driver
port map (
  RST_I                         => RST_I_i,
  CLK_I                         => CLK_I_i,
  nCS_Output_1                  => nCS_Output_1_i,
  nCS_Output_2                  => nCS_Output_2_i,
  Sclk                          => Sclk_i,
  Mosi                          => Mosi_i,
  Miso                          => Miso_i,
  Card_Select                   => Output_Card_Select_i,
  Data_In_Ready                 => Output_Data_Ready_i,      
  SPI_Outport                   => Output_SPI_Data_out_i,     
  Data_Out_Ready                => Data_Out_Ready_i,
  SPI_Inport                    => SPI_Inport,
  Busy                          => Busy_Out_i,
  Module_Number                 => Module_Number_i,
  SPI_IO_Driver_Version_Request => SPI_IO_Driver_Version_Request_i,
  SPI_IO_Driver_Version_Name    => SPI_IO_Driver_Version_Name_2_i, 
  SPI_IO_Driver_Version_Number  => SPI_IO_Driver_Version_Number_2_i,
  SPI_IO_Driver_Version_Ready   => SPI_IO_Driver_Version_Ready_2_i               
  );

---------------------------------------------------------------------------------- 
-- SPI Digital Output Handler Instance [Box 1 Card 1 = 10 Card 2 = 11] - Module 3
----------------------------------------------------------------------------------       
SPI_Output_Handler_1: entity work.SPI_Output_Handler
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
  SPI_Data_in                           => SPI_Inport,
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
  CS1                               => CS1_i,
  CS2                               => CS2_i,
  CS3                               => CS3_i,
  CS4                               => CS4_i,
  nCS                               => nCS_i,
  Address                           => Address_out_i,  
  convert                           => convert_i,
  nCS_1                             => nCS_1_i,
  nCS_2                             => nCS_2_i,
  nCS_3                             => nCS_3_i,
  nCS_4                             => nCS_4_i,
  Sclk                              => Ser_clk1,  
  Mosi                              => DIN,
  Miso                              => DOUT,
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
  CS1                                => CS1_i,
  CS2                                => CS2_i,
  CS3                                => CS3_i,
  CS4                                => CS4_i,
  AD_data_in                         => AD_data_i,
  Data_valid                         => Data_valid_i,
  CH1_o                              => CH1_o_i,
  CH2_o                              => CH2_o_i,
  CH3_o                              => CH3_o_i,
  CH4_o                              => CH4_o_i,
  CH5_o                              => CH5_o_i,
  CH6_o                              => CH6_o_i,
  CH7_o                              => CH7_o_i,
  CH8_o                              => CH8_o_i,
  CH9_o                              => CH9_o_i,
  CH10_o                             => CH10_o_i,
  CH11_o                             => CH11_o_i,
  CH12_o                             => CH12_o_i,
  CH13_o                             => CH13_o_i,
  CH14_o                             => CH14_o_i,
  CH15_o                             => CH15_o_i,
  CH16_o                             => CH16_o_i,
  CH17_o                             => CH17_o_i,
  CH18_o                             => CH18_o_i,
  CH19_o                             => CH19_o_i,
  CH20_o                             => CH20_o_i,
  CH21_o                             => CH21_o_i,
  CH22_o                             => CH22_o_i,
  CH23_o                             => CH23_o_i,
  CH24_o                             => CH24_o_i,
  CH25_o                             => CH25_o_i,
  CH26_o                             => CH26_o_i,
  CH27_o                             => CH27_o_i,
  CH28_o                             => CH28_o_i,
  CH29_o                             => CH29_o_i,
  CH30_o                             => CH30_o_i,
  CH31_o                             => CH31_o_i,
  CH32_o                             => CH32_o_i,
  CH33_o                             => CH33_o_i,
  CH34_o                             => CH34_o_i,
  CH35_o                             => CH35_o_i,
  CH36_o                             => CH36_o_i,
  CH37_o                             => CH37_o_i,
  CH38_o                             => CH38_o_i,
  CH39_o                             => CH39_o_i,
  CH40_o                             => CH40_o_i,
  CH41_o                             => CH41_o_i,
  CH42_o                             => CH42_o_i,
  CH43_o                             => CH43_o_i,
  CH44_o                             => CH44_o_i,
  CH45_o                             => CH45_o_i,
  CH46_o                             => CH46_o_i,
  CH47_o                             => CH47_o_i,
  CH48_o                             => CH48_o_i,
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
  CLK_I                                     => CLK_I_i,
  RST_I                                     => RST_I_i,
  UART_RXD                                  => Software_to_Controller_UART_RXD_i,
  Timer_Sec_Reg                             => Timer_Sec_Reg_i,
  Timer_mSec_Reg                            => Timer_mSec_Reg_i,
  Dig_Card1_1_B0                            => Dig_Card1_1_B0_i,
  Dig_Card1_1_B1                            => Dig_Card1_1_B1_i,
  Dig_Card1_1_B2                            => Dig_Card1_1_B2_i,
  Dig_Card1_1_B3                            => Dig_Card1_1_B3_i,
  Dig_Card1_1_B4                            => Dig_Card1_1_B4_i,
  Dig_Card1_1_B5                            => Dig_Card1_1_B5_i,
  Dig_Card1_1_B6                            => Dig_Card1_1_B6_i,
  Dig_Card1_1_B7                            => Dig_Card1_1_B7_i,
  SET_Timer                                 => SET_Timer_i,
  Dig_Outputs_Ready                         => Dig_Outputs_Ready_i,
  SPI_IO_Driver_Version_Request             => SPI_IO_Driver_Version_Request_i,   
  SPI_Output_Handler_Version_Request        => SPI_Output_Handler_Version_Request_i,
  SPI_Input_Handler_Version_Request         => SPI_Input_Handler_Version_Request_i,
  SPI_Analog_Driver_Version_Request         => SPI_Analog_Driver_Version_Request_i,
  SPI_Analog_Handler_Version_Request        => SPI_Analog_Handler_Version_Request_i,
  Main_Mux_Version_Request                  => Main_Mux_Version_Request_i, 
  Baud_Rate_Generator_Version_Request       => Baud_Rate_Generator_Version_Request_i,
  Endat_Firmware_Controller_Version_Request => Endat_Firmware_Controller_Version_Request_i,  
  Module_Number                             => Module_Number_i,
  Main_Demux_Version_Name                   => Main_Demux_Version_Name_i, 
  Main_Demux_Version_Number                 => Main_Demux_Version_Number_i,
  Main_Demux_Version_Ready                  => Main_Demux_Version_Ready_i 
  );
        
-------------------------------------------------------------------------------
-- Endat Firmware Controller Mux 
-------------------------------------------------------------------------------
Main_Mux_1: entity work.Main_Mux
port map (
  CLK_I                      => CLK_I_i,
  RST_I                      => RST_I_i,
  UART_TXD                   => Controller_to_Software_UART_TXD_i,
  Dig_Out_1_B0               => Dig_Card1_1_B0_i,
  Dig_Out_1_B1               => Dig_Card1_1_B1_i,
  Dig_Out_1_B2               => Dig_Card1_1_B2_i,
  Dig_Out_1_B3               => Dig_Card1_1_B3_i,
  Dig_Out_1_B4               => Dig_Card1_1_B4_i,
  Dig_Out_1_B5               => Dig_Card1_1_B5_i,
  Dig_Out_1_B6               => Dig_Card1_1_B6_i,
  Dig_Out_1_B7               => Dig_Card1_1_B7_i,
  Digital_Input_Valid        => Digital_Input_Valid_i,
  Dig_In_1_B0                => SPI_Inport_1_i,                
  Dig_In_1_B1                => SPI_Inport_2_i,               
  Dig_In_1_B2                => SPI_Inport_3_i,                 
  Dig_In_1_B3                => SPI_Inport_4_i,               
  Dig_In_1_B4                => SPI_Inport_5_i,                
  Dig_In_1_B5                => SPI_Inport_6_i,                
  Dig_In_1_B6                => SPI_Inport_7_i,                
  Dig_In_1_B7                => SPI_Inport_8_i,         
  Digital_Output_Valid       => Digital_Output_Valid_i,
  Alg_Card1_1                => CH1_o_i,           
  Alg_Card1_2                => CH2_o_i,          
  Alg_Card1_3                => CH3_o_i,       
  Alg_Card1_4                => CH4_o_i,          
  Alg_Card1_5                => CH5_o_i,        
  Alg_Card1_6                => CH6_o_i,         
  Alg_Card1_7                => CH7_o_i,         
  Alg_Card1_8                => CH8_o_i,       
  Alg_Card1_9                => CH9_o_i,         
  Alg_Card1_10               => CH10_o_i,        
  Alg_Card1_11               => CH11_o_i,        
  Alg_Card1_12               => CH12_o_i,        
  Alg_Card1_13               => CH13_o_i,         
  Alg_Card1_14               => CH14_o_i,         
  Alg_Card1_15               => CH15_o_i,          
  Alg_Card1_16               => CH16_o_i,        
  Alg_Card1_17               => CH17_o_i,          
  Alg_Card1_18               => CH18_o_i,       
  Alg_Card1_19               => CH19_o_i,         
  Alg_Card1_20               => CH20_o_i,        
  Alg_Card1_21               => CH21_o_i,          
  Alg_Card1_22               => CH22_o_i,         
  Alg_Card1_23               => CH23_o_i,        
  Alg_Card1_24               => CH24_o_i,         
  Alg_Card1_25               => CH25_o_i,        
  Alg_Card1_26               => CH26_o_i,        
  Alg_Card1_27               => CH27_o_i,        
  Alg_Card1_28               => CH28_o_i,          
  Alg_Card1_29               => CH29_o_i,         
  Alg_Card1_30               => CH30_o_i,         
  Alg_Card1_31               => CH31_o_i,        
  Alg_Card1_32               => CH32_o_i,         
  Alg_Card1_33               => CH33_o_i,         
  Alg_Card1_34               => CH34_o_i,          
  Alg_Card1_35               => CH35_o_i,         
  Alg_Card1_36               => CH36_o_i,         
  Alg_Card1_37               => CH37_o_i,         
  Alg_Card1_38               => CH38_o_i,        
  Alg_Card1_39               => CH39_o_i,        
  Alg_Card1_40               => CH40_o_i,        
  Alg_Card1_41               => CH41_o_i,         
  Alg_Card1_42               => CH42_o_i,        
  Alg_Card1_43               => CH43_o_i,        
  Alg_Card1_44               => CH44_o_i,       
  Alg_Card1_45               => CH45_o_i,        
  Alg_Card1_46               => CH46_o_i,         
  Alg_Card1_47               => CH47_o_i,      
  Alg_Card1_48               => CH48_o_i, 
  Analog_Input_Valid         => Analog_Input_Valid_i,
  Ana_In_Request             => Ana_In_Request_i,
  Seconds_out                => Seconds_out_i,          
  Minutes_out                => Minutes_out_i,           
  Hours_out                  => Hours_out_i,           
  Day_out                    => Day_out_i,           
  Date_out                   => Date_out_i,
  Month_Century_out          => Month_Century_out_i,    
  Year_out                   => Year_out_i,
  Dig_In_Request             => Dig_In_Request_i,                
  Dig_Out_Request            => Dig_Out_Request_i,               
  Baud_Rate_Enable           => Mux_Baud_Rate_Enable_i,
  Data_Ready                 => Data_Ready_i,
  Real_Time_Clock_Ready      => Real_Time_Clock_Ready_i,
  Watchdog_Reset             => Watchdog_Reset_i,
  Mux_watchdog               => Mux_watchdog_i,
  One_mS                     => OnemS_sStrobe,
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

            
 bit_time <= bit_time_19200 when Baudrate = 19200 else bit_time_4800 when Baudrate = 4800 else
            bit_time_9600 when Baudrate = 9600 else bit_time_57600 when Baudrate = 57600 else
            bit_time_115200 when Baudrate = 115200 else default_bit_time;
 
 Miso    <= '0', '1' after 1 ms, '0' after 1.5 ms, '1' after 2 ms, '0' after 2.00004 ms, '1' after 2.5888 ms,
           '0' after 3.100 ms, '1' after 3.54298 ms, '0' after 4.051 ms, '1' after 4.5 ms, '0' after 5.698 ms,
           '1' after 6.012 ms, '0' after 6.498 ms, '1' after 7.02 ms, '0' after 7.45 ms, '1' after 8.032 ms,
           '0' after 8.67 ms, '1' after 9.1 ms, '0' after 9.66 ms, '1' after 10.08 ms, '0' after 10.7 ms,
           '1' after 10.894 ms, '1' after 11 ms, '0' after 11.21 ms, '1' after 11.99 ms,
           '0' after 12.21 ms, '1' after 12.698 ms, '0' after 12.865 ms, '1' after 13.549 ms, '1' after 14.03 ms,
           '1' after 14.513 ms, '0' after 15 ms, '1' after 16 ms, '0' after 16.5 ms, '1' after 20 ms, '0' after 20.00004 ms, '1' after 20.5888 ms,
           '0' after 23.100 ms, '1' after 23.54298 ms, '0' after 24.051 ms, '1' after 24.5 ms, '0' after 25.698 ms,
           '1' after 26.012 ms, '0' after 26.498 ms, '1' after 27.02 ms, '0' after 27.45 ms, '1' after 28.032 ms,
           '0' after 28.67 ms, '1' after 29.1 ms, '0' after 29.66 ms, '1' after 30.08 ms, '0' after 30.7 ms,
           '1' after 30.894 ms, '1' after 31 ms, '0' after 31.21 ms, '1' after 31.99 ms,
           '0' after 32.21 ms, '1' after 32.698 ms, '0' after 32.865 ms, '1' after 33.549 ms, '1' after 34.03 ms,
           '1' after 34.513 ms, '0' after 35 ms;
 
 Miso_i  <= '0', '1' after 1 ms, '0' after 1.5 ms, '1' after 2 ms, '0' after 2.00004 ms, '1' after 2.5888 ms,
           '0' after 3.100 ms, '1' after 3.54298 ms, '0' after 4.051 ms, '1' after 4.5 ms, '0' after 5.698 ms,
           '1' after 6.012 ms, '0' after 6.498 ms, '1' after 7.02 ms, '0' after 7.45 ms, '1' after 8.032 ms,
           '0' after 8.67 ms, '1' after 9.1 ms, '0' after 9.66 ms, '1' after 10.08 ms, '0' after 10.7 ms,
           '1' after 10.749 ms, '0' after 10.894 ms, '1' after 11 ms, '0' after 11.21 ms, '1' after 11.99 ms,
           '0' after 12.21 ms, '1' after 12.698 ms, '1' after 12.865 ms, '1' after 13.549 ms, '1' after 14.03 ms,
           '1' after 14.513 ms, '1' after 15 ms;
 
 DOUT    <= '0', '1' after 20.7 ms, '0' after 21 ms, '1' after 21.062 ms, '0' after 21.698 ms, '1' after 22 ms,
            '0' after 22.21 ms, '1' after 22.698 ms, '1' after 22.865 ms, '1' after 23.549 ms, '1' after 24.03 ms,
            '1' after 24.513 ms, '1' after 25 ms;

 DOUT2    <= '0', '1' after 13.12000 ms, '0' after 13.12500 ms, '1' after 13.13000 ms, '0' after 13.13539 ms, '1' after 13.13752 ms,
             '0' after 13.14132 ms, '1' after 13.15490 ms, '1' after 13.16000 ms, '1' after 13.17490 ms, '1' after 13.18122 ms,
             '1' after 13.18513 ms, '1' after 13.20000 ms, '1' after 13.22000 ms, '0' after 13.22500 ms, '1' after 13.23000 ms,
             '0' after 13.23539 ms, '1' after 13.23752 ms, '0' after 13.24132 ms, '1' after 13.25490 ms, '1' after 13.26000 ms,
             '1' after 13.27490 ms, '1' after 13.28122 ms,
             '1' after 13.28513 ms, '1' after 13.29000 ms;


Endat_Firmware_Controller_Version_Tester: process(CLK_I_i, RST_I_i)
  variable display_version_cnt  : integer range 0 to 50;
  
begin

if RST_I_i = '0' then
   display_version_lock <= '0';
   display_version_cnt  := 1;
   report "The version number of A0212-0003-007 Endat_Firmware Controller is 2.17." severity note;  -- For Modelsim
 elsif (CLK_I_i'event and CLK_I_i = '1') then
     
     if display_version_cnt = 0 then
        display_version_lock <= '0';
    else   
        display_version_cnt := display_version_cnt - 1;
        display_version_lock <= '1';
    end if;
            
     if display_version_lock = '1' then
        report "Version build number is " & hstr(Version_Register_i) & "h" severity note;
        --print(l_file, "#Firmware Version Log File#");
        --print(l_file, "#-------------------------#");
        --print(l_file, str(Version_Register_i) & " "& hstr(Version_Register_i)& "h");
    end if;
    
 end if;

 end process;

Firmware_Controller_Version_Updator: process(RST_I_i,CLK_I_i)
 variable Endat_Firmware_Controller_Version_cnt: integer range 0 to 10;
begin
  if RST_I_i = '0' then
     Endat_Firmware_Controller_Version_Ready_i  <= '0';
     Endat_Firmware_Controller_Version_Name_i   <= (others=>'0');
     Endat_Firmware_Controller_Version_Number_i <= (others=>'0');
     Endat_Firmware_Controller_Version_cnt      := 0;
     Endat_Firmware_Controller_Version_Load_i   <= '0';
  elsif CLK_I_i'event and CLK_I_i = '1' then  
     
     if Module_Number_i = X"0e" then
      if Endat_Firmware_Controller_Version_Request_i = '1' then
         Endat_Firmware_Controller_Version_Name_i   <= A & P & E & C & O & N & T & R & O & L & L & E & R &
                                           Space & Space & Space & Space & Space & Space & Space & Space &
                                           Space & Space & Space & Space & Space & Space & Space &
                                           Space & Space & Space & Space;
         Endat_Firmware_Controller_Version_Number_i <= ZeroE & ZeroE & Dot & ZeroE & One & Dot & ZeroE & Three; 
         Endat_Firmware_Controller_Version_Load_i   <= '1';
      else
         Endat_Firmware_Controller_Version_Ready_i <= '0';
      end if;

      if Endat_Firmware_Controller_Version_Load_i = '1' then
         if Endat_Firmware_Controller_Version_cnt = 5 then
            Endat_Firmware_Controller_Version_Ready_i <= '1';
            Endat_Firmware_Controller_Version_Load_i  <= '0';
            Endat_Firmware_Controller_Version_cnt     := 0;
         else
            Endat_Firmware_Controller_Version_cnt     := Endat_Firmware_Controller_Version_cnt + 1;   
            Endat_Firmware_Controller_Version_Ready_i <= '0';
         end if;  
      end if;   
     else   
      Endat_Firmware_Controller_Version_Ready_i <= '0'; 
     end if;   


  end if;
end process Firmware_Controller_Version_Updator;


------------------------------------------------------
-- I2C Test for Real Time Clock
------------------------------------------------------
data_test: process(CLK_I_i, RST_I_i)
    variable Stop_Cnt           : integer range 0 to 50;
    variable Cycle_Count        : integer range 0 to 10;
    variable Edge_Count         : integer range 0 to 5000;
    variable Assert_Data_Count  : integer range 0 to 100;
    variable OnemS_Count        : integer range 0 to 1002;
    variable Sample_Count       : integer range 0 to 1002;
    variable Latch_Sample_Count : integer range 0 to 1002;
    variable bus_clk_test       : integer range 0 to 400_000;
    variable v_TIME             : time := 0 ns;
    variable vee_TIME           : time := 0 ns;

begin
    if RST_I_i = '0' then
        -- bus_clk_test              := 400_000; -- Hz - mus be added to memory                      
        Delay_Count               <= 0;
        Cycle_Count               := 0;   
        Assert_Data_Count         := 0;
        lockout_i                 <= '0';
        TestData_i                <= x"00";
        Seconds_TestData_i        <= x"00";
        Minutes_TestData_i        <= x"00";
        Hours_TestData_i          <= x"00";
        Days_TestData_i           <= x"00";
        Dates_TestData_i          <= x"00";
        Months_Century_TestData_i <= x"00";
        Years_TestData_i          <= x"00";
        SDA_i                     <= 'Z';
        Int_SCL_i                 <= '0';
        Start_Detected            <= '0';
        Byte_Address              <= '0';
        busy_mux_lockout_i        <= '1';
        Test_Byte_i               <= X"68";
        OnemS_Count               := 0; 
        Sample_Count              := 0; 
        Latch_Sample_Count        := 0; 
        PPS_In_i                  <= '0';
    elsif (CLK_I_i'event and CLK_I_i = '1') then

        ----------------------------------
        -- Test No. of Samples in a Second
        ----------------------------------
        if OnemS_sStrobe = '1' then
            OnemS_Count := OnemS_Count + 1;
        end if;  
        
        if Get_Sample_i = '1' then
            Sample_Count := Sample_Count + 1;
        end if;
        
        if OnemS_Count = 1000 then
            Latch_Sample_Count  := Sample_Count;
        elsif OnemS_Count = 1001 then
            OnemS_Count   := 0;
            Sample_Count  := 0;
        end if;
        -----------------------------------------
        -- End of Test No. of Samples in a Second
        -----------------------------------------
        -----------------------------------------
        -- Slave and Test Clock Matching
        -----------------------------------------
        if SCL_i = '0' then
            Int_SCL_i   <= '0';
        else
            Int_SCL_i   <= '1';
        end if;    

        if SDA_i = '0' then
            Int_SDA_i   <= '0';
        else
            Int_SDA_i   <= '1';
        end if;  
             
        case I2C_Test_State is
            when Wait_Start =>
                if initialation_Status_i = '0' then
                    I2C_Test_State          <= Config_State;
                    Test_I2C_Config_State   <= StartEdge;
                elsif initialation_Status_i = '1' then 
                    I2C_Test_State          <= Read_State;
                end if;    
        
            when Config_State =>
                if initialation_Status_i = '0' then
                    I2C_Test_State  <= Config_State;
                elsif initialation_Status_i = '1' then 
                    I2C_Test_State  <= Read_State;
                end if;
                
                case Test_I2C_Config_State is
                    when StartEdge =>
                        if Int_SCL_i = '1'and Int_SDA_i = '0' then  -- Start Condition
                            Start_Detected          <= '1';
                            Cycle_Count             := 8;  
                            Byte_Address            <= '1';
                            Byte_Count              <= 0;  
                            Test_I2C_Config_State   <= StartFallingEdge;
                        end if;
                        
                    when StartFallingEdge =>
                        
                        if Int_SCL_i = '0' then
                            if Start_Detected = '1' then
                                Delay_Count             <= 0;
                                Test_I2C_Config_State   <= WriteData;
                            end if;
                        else
                            Test_I2C_Config_State       <= StartFallingEdge;
                        end if;
                                            
                    when WriteData =>
                        if Delay_Count = 31 then
                            Test_I2C_Config_State   <= RisingEdge;
                        else
                            Delay_Count             <= Delay_Count + 1;
                        end if;
                        
                    when RisingEdge =>
                        if Int_SCL_i = '1' then
                            Delay_Count             <= 0;
                            Cycle_Count             := Cycle_Count - 1; 
                            Test_I2C_Config_State   <= ReadData;
                        else
                            Test_I2C_Config_State   <= RisingEdge;
                        end if;
                    
                    when ReadData =>
                        if Delay_Count = 31 then
                            Test_Byte_i(Cycle_Count)    <= Int_SDA_i;
                            Test_I2C_Config_State       <= FallingEdge;
                        else
                            Delay_Count                 <= Delay_Count + 1;
                            Test_I2C_Config_State       <= ReadData;
                        end if;    
                    
                    when FallingEdge =>
                        if Int_SCL_i = '0' then
                            if Cycle_Count = 0 then
                                Delay_Count             <= 0;
                                Cycle_Count             := 8; 
                                Test_I2C_Config_State   <= WriteAck;
                            else
                                Delay_Count             <= 0;
                                Test_I2C_Config_State   <= WriteData;
                            end if;
                        end if;    
                    
                    when WriteAck =>
                        if Delay_Count = 31 then
                            Test_I2C_Config_State   <= RisingEdgeAck;
                            Byte_Count              <= Byte_Count + 1;  -- First Byte
                         else              
                            Delay_Count             <= Delay_Count + 1; 
                            Test_I2C_Config_State   <= WriteAck;
                         end if;     
                            
                    when RisingEdgeAck => 
                        if Int_SCL_i = '1' then
                            Delay_Count             <= 0;
                            Test_I2C_Config_State   <= ReadAck;
                        else
                            Test_I2C_Config_State   <= RisingEdgeAck;
                        end if;
                        
                    when ReadAck =>
                        if Delay_Count = 31 then  
                            if Start_Detected = '1' then
                                Test_I2C_Config_State  <= FallingEdgeAck;
                            else
                                Test_I2C_Config_State  <= FallingEdgeAck;
                            end if;
                        else
                            Delay_Count             <= Delay_Count + 1;
                            Test_I2C_Config_State   <= ReadAck;
                        end if;
                        
                    when FallingEdgeAck =>       
                        if Int_SCL_i = '0' then
                            if Byte_Count = 3 then
                                Byte_Count              <= 0; 
                                Delay_Count             <= 0;
                                Test_I2C_Config_State   <= AckRisingEdge;
                            else
                                Delay_Count             <= 0;
                                Test_I2C_Config_State   <= WriteData;
                            end if;   
                        end if;
                            
                    when AckRisingEdge =>    
                        if Int_SCL_i = '1' then
                            Test_I2C_Config_State  <= WaitStop;
                        end if;    

                    when WaitStop =>       
                        if Int_SCL_i = '1' and Int_SDA_i = '1' then     -- Stop condition
                            I2C_Test_State          <= Wait_Start;
                        else
                            Test_I2C_Config_State   <= WaitStop;
                        end if;  
                end case;
                
                ----------------------------------------------
                ----- End of Config --------------------------
                ----------------------------------------------
                
                ---------------------------------------------------
                ----- Start of Read Data --------------------------
                ---------------------------------------------------
                
            when Read_State =>
                case Test_I2C_Read_State is
                    when StartEdge =>
                        if Int_SCL_i = '1'and SDA_i = '0' then -- Start Condition
                            Start_Detected      <= '1';
                            Cycle_Count         := 8;  
                            Byte_Address        <= '1';
                            Byte_Count          <= 0;  
                            Test_I2C_Read_State <= StartFallingEdge;
                        end if;

                    when StartFallingEdge =>
                        if Int_SCL_i = '0' then
                            if Start_Detected = '1' then
                              Delay_Count           <= 0;
                              Test_I2C_Read_State   <= WriteData;
                            end if;
                        elsif Busy_i = '0' then
                            Test_I2C_Read_State     <= StartEdge;
                        else
                            Test_I2C_Read_State     <= StartFallingEdge;
                        end if;

                    when WriteData =>
                        if Delay_Count = 31 then
                            Test_I2C_Read_State <= RisingEdge;
                        else
                            Delay_Count         <= Delay_Count + 1;
                        end if;

                    when RisingEdge =>
                        if Int_SCL_i = '1' then
                            Delay_Count         <= 0;
                            Cycle_Count         := Cycle_Count - 1; 
                            Test_I2C_Read_State <= ReadData;
                        else
                            Test_I2C_Read_State <= RisingEdge;
                        end if;
                                                
                    when ReadData =>     -- Read Slave Address 0xd0 Reagister Address 0x
                        if Byte_Count >= 0 and Byte_Count < 3 then
                            if Delay_Count = 31 then
                                Test_Byte_i(Cycle_Count)    <= Int_SDA_i;  -- Data Address 0x32
                                Test_I2C_Read_State         <= FallingEdge;
                            else
                                Delay_Count                 <= Delay_Count + 1;
                                Test_I2C_Read_State         <= ReadData;
                            end if; 
                            if Byte_Count = 0 then
                                -- For RW bit
                                if SDA_i = '0' then
                                    report "Write Mode" severity note;
                                elsif SDA_i = '1' then
                                    report "Read Mode" severity note;
                                end if;
                            end if;
                        end if;    

                    when FallingEdge =>
                        if Int_SCL_i = '0' then
                            if Cycle_Count = 0 then
                                Delay_Count         <= 0;
                                Cycle_Count         := 8; 
                                Byte_Count          <= Byte_Count + 1; 
                                Test_I2C_Read_State <= WriteAck;
                            else
                                Delay_Count         <= 0;
                                Test_I2C_Read_State <= WriteData;
                            end if;
                        end if;                          

                    when WriteAck =>
                        if Delay_Count = 31 then
                            Delay_Count         <= 0;   
                            SDA_i               <= '0';     -- Assert ACK
                            Test_I2C_Read_State <= RisingEdgeAck;
                        else              
                            Delay_Count         <= Delay_Count + 1;   
                            Test_I2C_Read_State <= WriteAck;
                        end if;     

                    when RisingEdgeAck => 
                        if Int_SCL_i = '1' then
                            Delay_Count         <= 0;
                            Test_I2C_Read_State <= ReadAck;
                        else
                            Test_I2C_Read_State <= RisingEdgeAck;
                        end if;

                    when ReadAck =>
                        if Int_SCL_i = '0' then
                           Test_I2C_Read_State <= FallingEdgeAck;
                        end if;

                    when FallingEdgeAck =>       
                        if Int_SCL_i = '0' and Delay_Count = 31 then
                            SDA_i                   <= 'Z';     -- Clear ACK 
                            Delay_Count             <= 0;
                            if Byte_Count = 2 then
                                Test_I2C_Read_State <= AckRisingEdge;
                            else
                                Test_I2C_Read_State <= WriteData;
                            end if;
                        else
                            Delay_Count     <= Delay_Count + 1;
                        end if;   

                    when AckRisingEdge =>    
                        if Int_SCL_i = '1' then
                            Test_I2C_Read_State  <= WaitStop;
                        end if;    

                    when WaitStop =>       
                        if Int_SCL_i = '1' and Int_SDA_i = '1' then -- Stop Condition
                            Test_I2C_Read_State  <= ReStartEdge;
                        end if;
                        
                    -------------------------------------------
                    -- ReStart Condition
                    -------------------------------------------

                    when ReStartEdge =>
                        if Int_SCL_i = '1'and SDA_i = '0' then -- Start Condition
                            Start_Detected      <= '1';
                            Cycle_Count         := 8;  
                            Byte_Address        <= '1';
                            Byte_Count          <= 0;  
                            Test_I2C_Read_State <= StartFallingEdgeData_SA;
                        end if; 
                        
                    when StartFallingEdgeData_SA =>
                        if Int_SCL_i = '0' then
                            if Start_Detected = '1' then
                              Cycle_Count         := Cycle_Count - 1; 
                              Delay_Count         <= 0;
                              Test_I2C_Read_State <= WriteData_SA;
                                --Test_Byte_i         <= x"00";
                              --Seconds_TestData_i        <= Seconds_TestData_i;
                              --Minutes_TestData_i        <= Minutes_TestData_i;
                              --Hours_TestData_i          <= Hours_TestData_i;
                              --Days_TestData_i           <= Days_TestData_i;
                              --Dates_TestData_i          <= Dates_TestData_i;
                              --Months_Century_TestData_i <= Months_Century_TestData_i;
                              --Years_TestData_i          <= Years_TestData_i;
                            end if;
                        else
                            Test_I2C_Read_State      <= StartFallingEdgeData_SA;
                        end if;

                    when WriteData_SA =>
                        if Delay_Count = 31 then
                            Delay_Count                 <= 0;
                            Test_Byte_i(Cycle_Count)    <= Int_SDA_i;       -- Read Slave Address 0xd1 
                            Test_I2C_Read_State         <= RisingEdgeData_SA;
                        else
                            Delay_Count                 <= Delay_Count + 1;
                        end if;

                    when RisingEdgeData_SA =>
                        if Int_SCL_i = '1' then
                            Delay_Count         <= 0;
                            Test_I2C_Read_State <= Read_Slave_Data_SA;
                        else
                            Test_I2C_Read_State <= RisingEdgeData_SA;
                        end if;    
                        
                    when Read_Slave_Data_SA =>   -- Read Slave Address 0xd1 + RnW = 1 and 7 Bytes 0x                           
                        if Delay_Count = 31 then
                            Test_Byte_i(Cycle_Count)    <= Int_SDA_i;  -- Read Slave Address 0xd1 + RnW = 1
                            Test_I2C_Read_State         <= FallingEdgeData_SA;
                            -- For RW bit monitoring
                            if RnW_i = '0' then
                                report "Write Mode" severity note;
                                report "Correct Mode" severity note;
                            elsif RnW_i = '1' then
                                report "Read Mode" severity note;
                                report "Incorrect Mode" severity note;
                            end if; 
                        else
                            Delay_Count     <= Delay_Count + 1;
                        end if;
                        
                    when FallingEdgeData_SA =>
                        if Int_SCL_i = '0' then
                            if Cycle_Count = 0 then
                                Delay_Count         <= 0;
                                Cycle_Count         := 8;
                                Byte_Count          <= Byte_Count + 1;
                                SDA_i               <= 'Z';         -- Release bus for master ack
                                Test_I2C_Read_State <= WriteAckData_SA;
                            else
                                Delay_Count         <= 0;
                                Cycle_Count         := Cycle_Count - 1; 
                                Test_I2C_Read_State <= WriteData_SA;
                            end if;
                        end if;  
                        
                    when WriteAckData_SA =>
                        if Delay_Count = 31 then
                            Delay_Count         <= 0;   
                            SDA_i               <= '0';     -- Assert Slave ACK
                            Test_I2C_Read_State <= RisingEdgeAckData_SA;
                        else              
                            Delay_Count         <= Delay_Count + 1;   
                            Test_I2C_Read_State <= WriteAckData_SA;
                        end if;  

                    when RisingEdgeAckData_SA => 
                        if Int_SCL_i = '1' then
                            Delay_Count         <= 0;
                            Test_I2C_Read_State <= ReadAckData_SA;
                        else
                            Test_I2C_Read_State <= RisingEdgeAckData_SA;
                        end if;

                    when ReadAckData_SA =>                      
                        if Delay_Count = 31 then 
                            -- Test_Byte_i         <= X"00";
                            --Seconds_TestData_i          <= Seconds_TestData_i;
                            --Minutes_TestData_i          <= Minutes_TestData_i;
                            --Hours_TestData_i            <= Hours_TestData_i;
                            --Days_TestData_i             <= Days_TestData_i;
                            --Dates_TestData_i            <= Dates_TestData_i;
                            --Months_Century_TestData_i   <= Months_Century_TestData_i;
                            --Years_TestData_i            <= Years_TestData_i;
                            Delay_Count                 <= 0;
                            Test_I2C_Read_State <= FallingEdgeAckData_SA;
                        else
                            Delay_Count         <= Delay_Count + 1;
                            Test_I2C_Read_State <= ReadAckData_SA;
                        end if;

                    when FallingEdgeAckData_SA =>       
                        if Int_SCL_i = '0' then
                            Delay_Count         <= 0;
                            if Byte_Count > 7 then
                                Byte_Count          <= 0; 
                                Delay_Count         <= 0;
                                Test_I2C_Read_State <= AckRisingEdgeData;
                            else
                                Delay_Count         <= 0;
                                Cycle_Count         := Cycle_Count - 1;
                                Test_I2C_Read_State <= WriteData_Data;
                            end if;    
                            end if;
                            
                        when WriteData_Data =>
                            if Delay_Count = 31 then
                                Delay_Count          <= 0;
                                if Assert_Data_Count = 0 then
                                    SDA_i               <= Seconds_TestData_i(Cycle_Count);
                                    Test_I2C_Read_State <= RisingEdgeData_Data;
                                elsif Assert_Data_Count = 1 then    
                                    SDA_i               <= Minutes_TestData_i(Cycle_Count);
                                    Test_I2C_Read_State <= RisingEdgeData_Data;
                                elsif Assert_Data_Count = 2 then
                                    SDA_i               <= Hours_TestData_i(Cycle_Count);
                                    Test_I2C_Read_State <= RisingEdgeData_Data;
                                elsif Assert_Data_Count = 3 then
                                    SDA_i               <= Days_TestData_i(Cycle_Count);
                                    Test_I2C_Read_State <= RisingEdgeData_Data;
                                elsif Assert_Data_Count = 4 then
                                    SDA_i               <= Dates_TestData_i(Cycle_Count);
                                    Test_I2C_Read_State <= RisingEdgeData_Data;
                                elsif Assert_Data_Count = 5 then
                                    SDA_i               <= Months_Century_TestData_i(Cycle_Count);
                                    Test_I2C_Read_State <= RisingEdgeData_Data;
                                elsif Assert_Data_Count = 6 then
                                    Test_I2C_Read_State <= RisingEdgeData_Data;
                                    SDA_i               <= Years_TestData_i(Cycle_Count);
                                elsif Assert_Data_Count = 7 then
                                    Assert_Data_Count   := 0;
                                end if;    
                            else
                                Delay_Count          <= Delay_Count + 1;
                            end if;

                        when RisingEdgeData_Data =>
                            if Int_SCL_i = '1' then
                                Delay_Count         <= 0;
                                Test_I2C_Read_State <= Read_Slave_Data_Data;
                            else
                                Test_I2C_Read_State <= RisingEdgeData_Data;
                            end if;    

                        when Read_Slave_Data_Data =>   -- Read Slave Address 0xA6 + RnW = 1 and 7 Bytes 0x98                           
                            if Delay_Count = 31 then
                                Test_Byte_i(Cycle_Count)    <= Int_SDA_i;  -- Read Slave Address 0xd0 + RnW = 1
                                Test_I2C_Read_State         <= Test_Byte_Complete;
                                -- For RW bit monitoring
                                if RnW_i = '0' then
                                    report "Write Mode" severity note;
                                    report "Correct Mode" severity note;
                                elsif RnW_i = '1' then
                                    report "Read Mode" severity note;
                                    report "Incorrect Mode" severity note;
                                end if; 
                            else
                                Delay_Count     <= Delay_Count + 1;
                            end if;

                        when Test_Byte_Complete =>
                            Test_Byte_i(Cycle_Count)    <= Int_SDA_i;
                            if Byte_Count = 0 then
                                Test_I2C_Read_State     <= FallingEdgeData_Data;
                            elsif Byte_Count > 0 and Byte_Count <= 7 then
                                if Delay_Count = 31 then
                                    Test_Byte_i(Cycle_Count)    <= Int_SDA_i;
                                    Test_I2C_Read_State         <= FallingEdgeData_Data;
                                else
                                    Delay_Count                 <= Delay_Count + 1;
                                    Test_I2C_Read_State         <= Read_Slave_Data_Data;
                                end if; 
                            -- For RW bit monitoring
                                if RnW_i = '0' then
                                    report "Write Mode" severity note;
                                    report "Incorrect Mode" severity note;
                                elsif RnW_i = '1' then
                                    report "Read Mode" severity note;
                                    report "Correct Mode" severity note;
                                end if;
                            else
                                Test_I2C_Read_State     <= FallingEdgeData_Data;
                            end if;  

                        when FallingEdgeData_Data =>
                            if Int_SCL_i = '0' then
                                if Cycle_Count = 0 then
                                    Delay_Count         <= 0;
                                    Cycle_Count         := 8;
                                    Assert_Data_Count   := Assert_Data_Count + 1;  -- Recently Added Delete if not Working
                                    Byte_Count          <= Byte_Count + 1;
                                    SDA_i               <= 'Z';         -- Release bus for master ack
                                    Test_I2C_Read_State <= WriteAckData_Data;
                                else
                                    Delay_Count         <= 0;
                                    Cycle_Count         := Cycle_Count - 1;
                                    Test_I2C_Read_State <= WriteData_Data;
                                end if;
                            end if;  

                        when WriteAckData_Data =>
                            if Byte_Count = 1 then
                                if Delay_Count = 31 then
                                    Delay_Count         <= 0;   
                                    SDA_i               <= '0';     -- Assert Slave ACK
                                    Test_I2C_Read_State <= RisingEdgeAckData_Data;
                                else              
                                    Delay_Count         <= Delay_Count + 1;   
                                    Test_I2C_Read_State <= WriteAckData_Data;
                                end if;  

                            elsif Byte_Count > 1 and Byte_Count <= 8 then
                                if Delay_Count = 31 then
                                    Delay_Count         <= 0;   
                                    Test_I2C_Read_State <= RisingEdgeAckData_Data;
                                else              
                                    Delay_Count         <= Delay_Count + 1;   
                                    Test_I2C_Read_State <= WriteAckData_Data;
                                end if; 
                            elsif Byte_Count > 8 then

                                if Delay_Count = 31 then
                                    Delay_Count         <= 0;   
                                    Test_I2C_Read_State <= RisingEdgeAckData_Data;
                                else              
                                    Delay_Count         <= Delay_Count + 1;   
                                    Test_I2C_Read_State <= WriteAckData_Data;
                                end if; 
                            end if;

                        when RisingEdgeAckData_Data => 
                            if Int_SCL_i = '1' then
                                Delay_Count         <= 0;
                                Test_I2C_Read_State <= ReadAckData_Data;
                            else
                                Test_I2C_Read_State <= RisingEdgeAckData_Data;
                            end if;

                        when ReadAckData_Data =>                      
                            if Delay_Count = 31 then 
                                Cycle_Count         := 7;
                                Delay_Count         <= 0;
                                Test_I2C_Read_State <= FallingEdgeAckData_Data;
                            else
                                Delay_Count             <= Delay_Count + 1;
                                Test_I2C_Read_State     <= ReadAckData_Data;
                            end if;

                        when FallingEdgeAckData_Data =>       
                            if Int_SCL_i = '0' then
                                Delay_Count         <= 0;
                                if Byte_Count > 7 then
                                    Byte_Count          <= 0; 
                                    Delay_Count         <= 0;
                                    Test_I2C_Read_State <= AckRisingEdgeData;
                                else
                                    Delay_Count         <= 0;
                                    Test_I2C_Read_State <= WriteData_Data;
                                end if;    
                            end if;        

                    when AckRisingEdgeData =>    
                        if Int_SCL_i = '1' then
                            Test_I2C_Read_State  <= WaitStopData;
                        end if;    

                    when WaitStopData =>       
                        if Int_SCL_i = '1' and Int_SDA_i = '1' then -- 1st Stop Condition
                            Test_I2C_Read_State  <= StartEdge;

                        end if;
                end case;


        end case;

        
        -------------------------------
        -- Real Time Counters
        -------------------------------
        Seconds_TestData_int  <= conv_integer(Seconds_TestData_i);                
        Minutes_TestData_int <= conv_integer(Minutes_TestData_i);
        Hours_TestData_int      <= conv_integer(Hours_TestData_i);
        Days_TestData_int      <= conv_integer(Days_TestData_i);
        Months_Century_TestData_int <= conv_integer(Months_Century_TestData_i);

        case Real_Time_Counters_State is 

            when mS_counter =>
                -- Seconds counter
                if OnemS_sStrobe = '1' then
                    if Seconds_TestData_i = x"1d" then
                        Real_Time_Counters_State    <= Min_counter;
                        Seconds_TestData_i          <= x"00";
                    else
                        Seconds_TestData_i          <= Seconds_TestData_i + '1';
                    end if; 
                end if;
                
            when Min_counter =>
                -- Minutes counter
                if Minutes_TestData_i = x"03" then      -- 60 ms = 60 secs for simulation purposes
                    Real_Time_Counters_State    <= Hrs_counter;
                    Minutes_TestData_i          <= x"00";  
                else
                    Minutes_TestData_i          <= Minutes_TestData_i + '1';
                    Real_Time_Counters_State    <= mS_counter;
                end if;

            when Hrs_counter =>
                -- Hours counter
                if Hours_TestData_i = x"06" then    -- 06 mns = 1 hrs for simulation purposes
                    Real_Time_Counters_State    <= Days_counter;
                    Hours_TestData_i            <= x"00";
                else
                    Hours_TestData_i            <= Hours_TestData_i + '1';
                    Real_Time_Counters_State    <= Min_counter;
                end if;

            when Days_counter =>
                -- Days counter
                if Days_TestData_i = x"1e" then  
                    Real_Time_Counters_State    <= Mon_Cen_counter;
                    Days_TestData_i             <= x"00";
                else
                    Days_TestData_i             <= Days_TestData_i + '1';
                    Real_Time_Counters_State    <= Hrs_counter;
                end if;

            when Mon_Cen_counter =>    
                -- Months counter
                if Months_Century_TestData_i = x"0c" then
                    Real_Time_Counters_State    <= Years_counter;
                    Months_Century_TestData_i   <= x"00";
                else
                    Months_Century_TestData_i   <= Months_Century_TestData_i + '1';
                    Real_Time_Counters_State    <= Days_counter;
                end if;

            when Years_counter =>
                -- Months counter
                Years_TestData_i   <= Years_TestData_i + '1';
                Real_Time_Counters_State    <= Idle;

            when Idle =>
                Seconds_TestData_i          <= x"00";
                Minutes_TestData_i          <= x"00";
                Hours_TestData_i            <= x"00";
                Days_TestData_i             <= x"00";
                Months_Century_TestData_i   <= x"00";
                Years_TestData_i            <= x"00";
                Real_Time_Counters_State    <= mS_counter;
        end case;
    end if;

end process;

 Time_Mux <= '0', '1' after 26 ms, '0' after 26.00002 ms;
 
get_ser_port_data_digital_output: process
begin
      
      -- Version Data Asynchronous   
      for i in 0 to 70 loop             
          Software_to_Controller_UART_RXD_i  <= set_version_data(i);
          wait for bit_time_115200;
      end loop;  -- i
      wait for 3 ms;
      
      -- Digital Output Message Synchronous every 100ms
      wait for 1 us;     
      for i in 0 to 170 loop
          Software_to_Controller_UART_RXD_i  <= digital_output_01_on(i);
          wait for bit_time_115200;
      end loop;  -- i
      wait for 3 ms; 
    
      
      wait for 160 ms;
      
end process get_ser_port_data_digital_output;

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

    Sec_strobe: process
    begin
      Sec_sStrobe <= '0', '1' after 1000 ms, '0' after 1000.00002 ms;  
      wait for 1000.0001 ms;
    end process Sec_strobe;    
 
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

