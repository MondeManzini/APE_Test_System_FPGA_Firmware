-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- Edited By            : Monde Manzini
--                      : Updated version
-- Version              : 00.00.03
-- Change Note          : 
-- Tested               : 17/08/2021
-- Test Bench file Name : I2C_Driver_Test_Bench
-- located at           : (https://github.com/MondeManzini/Real_Time_Clock_Firmware/blob/main
--                        /Testbench%20Files/I2C_Driver_Test_Bench.vhd)
-- Test do file         : I2C_Driver_Test_Bench.do
-- located at            (https://github.com/MondeManzini/Real_Time_Clock_Firmware/blob/main
--                        /Modelsim)

-- Outstanding          : Integration ATP and Approval
--
-------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_arith.all;
    use ieee.numeric_std.all;
    use ieee.std_logic_UNSIGNED.all;

library modelsim_lib;
    use modelsim_lib.util.all;

entity I2C_Driver_Test_Bench is

end I2C_Driver_Test_Bench;

architecture Archtest_bench of I2C_Driver_Test_Bench is
	
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

----------------------------------------------------------------------
-- I2C Driver Test Bench Component and Signals
----------------------------------------------------------------------
component I2C_Driver IS
  GENERIC(
    input_clk : INTEGER := 50_000_000;               --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 400_000);                 --speed the i2c bus (scl) will run at in Hz
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

signal RnW_i         : std_logic;
signal SDA_i         : std_logic;
signal SCL_i         : std_logic;  
signal Get_Sample_i           : std_logic;
signal Sync_i                 : std_logic;
signal Enable_in_i            : std_logic;
signal PPS_in_i               : std_logic;
signal Enable_i               : std_logic;
signal Address_i              : std_logic_vector(6 downto 0);
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
signal lock_Out_i                   : std_logic;
signal lock_Out2_i                  : std_logic;
signal I2C_Busy_i                   : std_logic;
signal Busy_i                       : std_logic;
signal Data_RD_i                    : std_logic_vector(7 downto 0);
signal Start_i                      : std_logic;
signal lockout_i                    : std_logic;
signal initialation_Status_i        : std_logic;
signal Test_Data_i                  : std_logic_vector(7 downto 0);
signal UART_TXD_i                   : std_logic;
signal display_version_lock         : STD_LOGIC;
signal Version_Register_std_logic   : string(1 to 28);

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
signal Seconds_Register_i           : std_logic_vector(7 downto 0) := X"00"; 
signal Minutes_Register_i           : std_logic_vector(7 downto 0) := X"00"; 
signal Hours_Register_i             : std_logic_vector(7 downto 0) := X"00"; 
signal Day_Register_i               : std_logic_vector(7 downto 0) := X"00"; 
signal Date_Register_i              : std_logic_vector(7 downto 0) := X"00"; 
signal Mon_Cent_Register_i          : std_logic_vector(7 downto 0) := X"00"; 
signal Year_Register_i              : std_logic_vector(7 downto 0) := X"00"; 
signal Seconds_TestData_int         : integer range 0 to 60;
signal Minutes_TestData_int         : integer range 0 to 60;
signal Hours_TestData_int           : integer range 0 to 24;
signal Days_TestData_int            : integer range 0 to 31;
signal Months_Century_TestData_int  : integer range 0 to 12;
signal Real_Time_Clock_Ready_i      : std_logic;
-------------------------------------------------------------------------------
-- New Code Signal and Components
------------------------------------------------------------------------------- 
signal RST_I_i                  : std_logic;
signal CLK_I_i                  : std_logic;

---------------------------------------
----------------------------------------
-- General Signals
-------------------------------------------------------------------------------
type I2C_Test_States is (Wait_Start, Config_State, Read_State, Write_State);
type Test_I2C_Config_States is (StartEdge, StartFallingEdge, WriteData, RisingEdge, ReadData, FallingEdge, WriteAck, RisingEdgeAck, ReadAck,  
                              FallingEdgeAck, AckRisingEdge, WaitStop);
type Test_I2C_Read_States is (StartEdge, StartFallingEdge, WriteData, RisingEdge, ReadData, FallingEdge, WriteAck, RisingEdgeAck, ReadAck,  
                            FallingEdgeAck, AckRisingEdge, WaitStop);
type Test_I2C_Write_States is (StartEdge, StartFallingEdge, WriteData, RisingEdge, ReadData, FallingEdge, WriteAck, RisingEdgeAck, ReadAck,  
                            FallingEdgeAck, AckRisingEdge, WaitStop);
type Real_Time_Counters_States is (Idle, mS_counter, Min_counter, Hrs_counter, Days_counter, Mon_Cen_counter, Years_counter);
signal I2C_Test_State           : I2C_Test_States;
signal Test_I2C_Config_State    : Test_I2C_Config_States;
signal Test_I2C_Read_State      : Test_I2C_Read_States;
signal Test_I2C_Write_State     : Test_I2C_Write_States;
signal Real_Time_Counters_State : Real_Time_Counters_States;  

--signal TX_I2C_State  : TX_I2C_States;
--signal Mux_State    : Mux_States;

signal  sClok,snrst,sStrobe,PWM_sStrobe,newClk,Clk : std_logic := '0';
  signal  stx_data,srx_data : std_logic_vector(3 downto 0) := "0000";
  signal  sCnt         : integer range 0 to 7 := 0;
  signal  cont         : integer range 0 to 100;  
  signal  oClk,OneuS_sStrobe, Quad_CHA_sStrobe, Quad_CHB_sStrobe,OnemS_sStrobe,cStrobe,sStrobe_A,Ten_mS_sStrobe,Twenty_mS_sStrobe, Fifty_mS_sStrobe, Hun_mS_sStrobe : std_logic;

--  constant Baudrate : integer := 115200;
--  constant bit_time_4800      : time                         := 52.08*4 us;
--  constant bit_time_9600      : time                         := 52.08*2 us;    
--  constant bit_time_19200     : time                         := 52.08 us;
--  constant bit_time_57600     : time                         := 17.36 us;    
--  constant bit_time_115200    : time                         := 8.68 us;  
--  constant default_bit_time   : time                         := 52.08 us;  --19200  
--  constant start_bit          : std_logic := '0';
--  constant stop_bit           : std_logic := '1';
--  signal   bit_time           : time;
                                                                                                                                    
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
      
-------------------------------------------------------------------------------
-- Main Mux ADXL345 Instance
-------------------------------------------------------------------------------
I2C_Driver_1: entity work.I2C_Driver

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
    scl       => SCL_i                     --serial clock output of i2c bus
    );                   
              
data_test: process(CLK_I_i, RST_I_i)
  variable Config_Count       : integer range 0 to 50;
  variable Count              : integer range 0 to 150;
  variable Stop_Cnt           : integer range 0 to 50;
  variable Cycle_Count        : integer range 0 to 10;
  variable Edge_Count         : integer range 0 to 5000;
  variable Assert_Data_Count  : integer range 0 to 100;

begin
  if RST_I_i = '0' then
    Count                       := 0;
    Address_i                   <= "0000000";
    RnW_i                       <= '0';
    lock_Out_i                  <= '0';
    Delay_Count                 <= 0;
    Cycle_Count                 := 0;   
    Assert_Data_Count           := 0;
    lockout_i                   <= '0';
    TestData_i                  <= x"00";
    Seconds_TestData_i          <= x"00";
    Minutes_TestData_i          <= x"00";
    Hours_TestData_i            <= x"00";
    Days_TestData_i             <= x"00";
    Dates_TestData_i            <= x"00";
    Months_Century_TestData_i   <= x"00";
    Years_TestData_i            <= x"00";
    Data_WR_i                   <= x"00";
    SDA_i                       <= 'Z';
    Int_SCL_i                   <= '0';
    Start_Detected              <= '0';
    Byte_Address                <= '0';
    Test_Data_i                 <= X"00";
    Test_Byte_i                 <= X"00";
    I2C_Test_State              <= Wait_Start;
    I2C_Test_State              <= Wait_Start;
  elsif (CLK_I_i'event and CLK_I_i = '1') then

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
        if Busy_i = '0' then
          Address_i          <= "1101000";      
          RnW_i              <= '1';   
          Enable_i           <= '1'; 
          I2C_Test_State  <= Config_State;
        end if;   

      when Config_State =>
        case Test_I2C_Config_State is
          when StartEdge =>
            if Int_SCL_i = '1'and Int_SDA_i = '0' then  -- Start Condition
              Start_Detected          <= '1';
              Cycle_Count             := 7;  
              Byte_Address            <= '1';
              Byte_Count              <= 0;  
              Test_Data_i(6 downto 0) <= Address_i;
              Test_Byte_i             <= x"00";
              Test_I2C_Config_State   <= StartFallingEdge;
            end if;
                  
          when StartFallingEdge =>
            if Int_SCL_i = '0' then
              if Start_Detected = '1' then
                Delay_Count             <= 0;
                Test_I2C_Config_State   <= WriteData;
              end if;
            else
              Enable_i <= '0';
              Test_I2C_Config_State   <= StartFallingEdge;
            end if;
                                      
          when WriteData =>
            if Delay_Count = 31 then
              Test_I2C_Config_State <= RisingEdge;
              --SDA_i                 <= 'Z'; --Test_Data_i(Cycle_Count);      
            else
              Delay_Count           <= Delay_Count + 1;
              SDA_i                 <= Test_Data_i(Cycle_Count); 
            end if;
                  
          when RisingEdge =>
            if Int_SCL_i = '1' then
              Delay_Count           <= 0;
              Cycle_Count           := Cycle_Count - 1; 
              Test_I2C_Config_State <= ReadData;
            else
              Test_I2C_Config_State <= RisingEdge;
            end if;
              
          when ReadData =>
            if Delay_Count = 31 then
              -- Test_Byte_i(Cycle_Count)    <= SDA_i;
              Test_I2C_Config_State       <= FallingEdge;
            else
              Delay_Count                 <= Delay_Count + 1;
              Test_I2C_Config_State       <= ReadData;
              Test_Byte_i(Cycle_Count)    <= Int_SDA_i;
            end if;    
              
          when FallingEdge =>
            if Int_SCL_i = '0' then
              if Cycle_Count = 0 then
                Delay_Count             <= 0;
                Cycle_Count             := 7; 
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
              if Byte_Count = 1 and Test_Byte_i = X"68" then
                SDA_i                 <= '0';     -- Assert ACK
                Test_I2C_Config_State <= ReadAck;
              else
                Test_I2C_Config_State  <= WriteData;
              end if;   
            else
              Test_I2C_Config_State   <= RisingEdgeAck;
            end if;
                
          when ReadAck =>
            if Delay_Count = 31 then 
              SDA_i                 <= 'Z';     -- Clear ACK
              Test_I2C_Config_State <= FallingEdgeAck;
            else
              Delay_Count             <= Delay_Count + 1;
              Test_I2C_Config_State   <= ReadAck;
            end if;
                
          when FallingEdgeAck =>       
            if Int_SCL_i = '0' then
              Byte_Count            <= 0; 
              Delay_Count           <= 0;
              Test_I2C_Config_State <= AckRisingEdge;
          end if;
                    
          when AckRisingEdge =>    
            if Int_SCL_i = '1' then
              Test_I2C_Config_State <= WaitStop;
            end if;    

          when WaitStop =>       
            if Int_SCL_i = '1' and Int_SDA_i = '1' then     -- Stop condition
              I2C_Test_State        <= Read_State;
              Test_I2C_Read_State   <= StartEdge;
              Enable_i              <= '1';
            else
              Test_I2C_Config_State <= WaitStop;
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
            if Int_SCL_i = '1'and Int_SDA_i = '0' then -- Start Condition
              Start_Detected            <= '1';
              Cycle_Count               := 7;  
              Byte_Address              <= '1';
              Byte_Count                <= 0;  
              Assert_Data_Count         := 0;
              Test_Byte_i               <= x"00";
              Seconds_TestData_i        <= X"0f";        -- Seconds - 15
              Minutes_TestData_i        <= X"2e";        -- Minutes - 45 
              Hours_TestData_i          <= X"1d";        -- Hours - 22h
              Days_TestData_i           <= X"04";        -- Day - Thurs
              Dates_TestData_i          <= X"0c";        -- Date - 12
              Months_Century_TestData_i <= X"07";        -- Month - July
              Years_TestData_i          <= X"1b";        -- Year - 2021
              Test_I2C_Read_State       <= StartFallingEdge;
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
              case Assert_Data_Count is
                when 0 =>
                  Int_SDA_i           <= Seconds_TestData_i(Cycle_Count);
                  Test_I2C_Read_State <= RisingEdge;
                when 1 =>
                  Int_SDA_i           <= Minutes_TestData_i(Cycle_Count);
                  Test_I2C_Read_State <= RisingEdge;
                when 2 =>
                  Int_SDA_i           <= Hours_TestData_i(Cycle_Count);
                  Test_I2C_Read_State <= RisingEdge;
                when 3 =>
                  Int_SDA_i           <= Days_TestData_i(Cycle_Count);
                  Test_I2C_Read_State <= RisingEdge;
                when 4 =>
                  Int_SDA_i           <= Dates_TestData_i(Cycle_Count);
                  Test_I2C_Read_State <= RisingEdge;
                when 5 =>
                  Int_SDA_i           <= Months_Century_TestData_i(Cycle_Count);
                  Test_I2C_Read_State <= RisingEdge;
                when 6 =>
                  Int_SDA_i           <= Years_TestData_i(Cycle_Count);
                  Test_I2C_Read_State <= RisingEdge;
                when others =>
              end case;
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
                                        
          when ReadData =>     
            if Delay_Count = 31 then
              Test_Byte_i(Cycle_Count)  <= Int_SDA_i;  
              Test_I2C_Read_State       <= FallingEdge;
            else
              Delay_Count               <= Delay_Count + 1;
              Test_I2C_Read_State       <= ReadData;
            end if;  

            when FallingEdge =>
              if Int_SCL_i = '0' then
                if Cycle_Count = 0 then
                  Delay_Count         <= 0;
                  Cycle_Count         := 8; 
                  Byte_Count          <= Byte_Count + 1;
                  Assert_Data_Count   := Assert_Data_Count + 1; 
                  Test_I2C_Read_State <= WriteAck;
                else
                  Delay_Count         <= 0;
                  Test_I2C_Read_State <= WriteData;
                end if;
              end if;                          

            when WriteAck =>
              if Delay_Count = 31 then
                Delay_Count        <= 0; 
                if (Test_Byte_i = Seconds_TestData_i) and (Byte_Count = 1) then  
                  SDA_i               <= '0';     -- Assert ACK
                  Test_I2C_Read_State <= RisingEdgeAck;
                elsif (Test_Byte_i = Minutes_TestData_i) and (Byte_Count = 2) then
                  SDA_i               <= '0';     -- Assert ACK
                  Test_I2C_Read_State <= RisingEdgeAck;
                elsif (Test_Byte_i = Hours_TestData_i) and (Byte_Count = 3) then
                  SDA_i               <= '0';     -- Assert ACK
                  Test_I2C_Read_State <= RisingEdgeAck;
                elsif (Test_Byte_i = Days_TestData_i) and (Byte_Count = 4) then
                  SDA_i               <= '0';     -- Assert ACK
                  Test_I2C_Read_State <= RisingEdgeAck;
                elsif (Test_Byte_i = Dates_TestData_i) and (Byte_Count = 5) then
                  SDA_i               <= '0';     -- Assert ACK
                  Test_I2C_Read_State <= RisingEdgeAck;
                elsif (Test_Byte_i = Months_Century_TestData_i) and (Byte_Count = 6) then
                  SDA_i               <= '0';     -- Assert ACK
                  Test_I2C_Read_State <= RisingEdgeAck;
                elsif (Test_Byte_i = Years_TestData_i) and (Byte_Count = 7) then
                  SDA_i               <= '0';     -- Assert ACK
                  Test_I2C_Read_State <= RisingEdgeAck;
                end if;
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
                  SDA_i       <= 'Z';     -- Clear ACK 
                  Delay_Count <= 0;
                  if Byte_Count > 6 then
                      Test_I2C_Read_State <= AckRisingEdge;
                      Enable_i              <= '0';
                  else
                      Test_I2C_Read_State <= WriteData;
                  end if;
                else
                    Delay_Count     <= Delay_Count + 1;
                end if;   

            when AckRisingEdge =>    
                if Int_SCL_i = '1' then
                  Test_I2C_Read_State  <= WaitStop;
                  Enable_i             <= '1';
                end if;    

            when WaitStop =>       
                if Int_SCL_i = '1' and Int_SDA_i = '1' then -- Stop Condition
                    --Test_I2C_Read_State  <= ReStartEdge;
                    Test_I2C_Read_State  <= StartEdge;
                    I2C_Test_State  <= Write_State;
                end if;
        end case;

        when Write_State =>
          case Test_I2C_Write_State is
            when StartEdge =>
              if Int_SCL_i = '1'and SDA_i = '0' then -- Start Condition
                Start_Detected       <= '1';
                Cycle_Count          := 8;  
                Byte_Address         <= '1';
                Byte_Count           <= 0;  
                Assert_Data_Count    := 0;
                RnW_i                <= '0';
                Test_I2C_Write_State <= StartFallingEdge;
              end if;
                
            when StartFallingEdge =>
              if Int_SCL_i = '0' then
                if Start_Detected = '1' then
                  Delay_Count           <= 0;
                  Test_I2C_Write_State  <= WriteData;
                  -- Data_WR_i             <= X"2B";           -- 2B
                  
                end if;
              elsif Busy_i = '0' then
                Test_I2C_Write_State     <= StartEdge;
              else
                Test_I2C_Write_State     <= StartFallingEdge;
              end if;
                
            when WriteData =>
              if Delay_Count = 31 then
                
                case Assert_Data_Count is
                  when 0 =>
                    Data_WR_i             <= Seconds_TestData_i;          
                    Test_I2C_Write_State  <= RisingEdge;
                  when 1 =>
                    Data_WR_i             <= Minutes_TestData_i;         
                    Test_I2C_Write_State  <= RisingEdge;
                  when 2 =>
                    Data_WR_i             <= Hours_TestData_i;          
                    Test_I2C_Write_State  <= RisingEdge;
                  when 3 =>
                    Data_WR_i             <= Days_TestData_i;        
                    Test_I2C_Write_State  <= RisingEdge;
                  when 4 =>
                    Data_WR_i             <= Dates_TestData_i;          
                    Test_I2C_Write_State  <= RisingEdge;
                  when 5 =>
                    Data_WR_i             <= Months_Century_TestData_i;       
                    Test_I2C_Write_State  <= RisingEdge;
                  when 6 =>
                    Data_WR_i             <= Years_TestData_i;          
                    Test_I2C_Write_State  <= RisingEdge;
                  when others =>
                end case;
                Cycle_Count         := Cycle_Count - 1; 
              else
                Delay_Count         <= Delay_Count + 1;
              end if;
                
            when RisingEdge =>
                if Int_SCL_i = '1' then
                    Delay_Count          <= 0;
                    Int_SDA_i            <= Data_WR_i(Cycle_Count);
                    Test_I2C_Write_State <= ReadData;
                else
                    Test_I2C_Write_State <= RisingEdge;
                end if;
                                                    
            when ReadData => 
              if Delay_Count = 31 then
                case Assert_Data_Count is
                  when 0 =>
                    Seconds_Register_i(Cycle_Count) <= SDA_i;  -- Data Address 0x32
                    Test_I2C_Write_State            <= FallingEdge;
                                
                  when 1 =>
                    Minutes_Register_i(Cycle_Count) <= SDA_i;  -- Data Address 0x32
                    Test_I2C_Write_State            <= FallingEdge;
                
                  when 2 =>
                    Hours_Register_i(Cycle_Count) <= SDA_i;  -- Data Address 0x32
                    Test_I2C_Write_State          <= FallingEdge;
                
                  when 3 =>
                    Day_Register_i(Cycle_Count) <= SDA_i;  -- Data Address 0x32
                    Test_I2C_Write_State        <= FallingEdge;
                
                  when 4 =>
                    Date_Register_i(Cycle_Count) <= SDA_i;  -- Data Address 0x32
                    Test_I2C_Write_State         <= FallingEdge;
                
                  when 5 =>
                    Mon_Cent_Register_i(Cycle_Count) <= SDA_i;  -- Data Address 0x32
                    Test_I2C_Write_State             <= FallingEdge;
                
                  when 6 =>
                    Year_Register_i(Cycle_Count) <= SDA_i;  -- Data Address 0x32
                    Test_I2C_Write_State         <= FallingEdge;

                  when others =>
                
                end case;
              else
                Delay_Count                     <= Delay_Count + 1;
              end if;
                
            when FallingEdge =>
                if Int_SCL_i = '0' then
                    if Cycle_Count = 0 then
                        Delay_Count          <= 0;
                        Cycle_Count          := 8; 
                        Byte_Count           <= Byte_Count + 1;
                        Assert_Data_Count    := Assert_Data_Count + 1; 
                        Test_I2C_Write_State <= WriteAck;
                    else
                        Delay_Count         <= 0;
                        Test_I2C_Write_State <= WriteData;
                    end if;
                end if;                          
                
            when WriteAck =>
                if Delay_Count = 31 then
                    Delay_Count          <= 0;   
                    Test_I2C_Write_State <= RisingEdgeAck;
                else              
                    Delay_Count          <= Delay_Count + 1;   
                    Test_I2C_Write_State <= WriteAck;
                end if;     
                
            when RisingEdgeAck => 
                if Int_SCL_i = '1' then
                    Delay_Count          <= 0;
                    Test_I2C_Write_State <= ReadAck;
                else
                    Test_I2C_Write_State <= RisingEdgeAck;
                end if;
                
            when ReadAck =>
                if Int_SCL_i = '0' then
                    Test_I2C_Write_State <= FallingEdgeAck;
                end if;
                
            when FallingEdgeAck =>       
                if Int_SCL_i = '0' and Delay_Count = 31 then
                    Delay_Count             <= 0;
                    if Byte_Count > 6 then
                        Test_I2C_Write_State <= AckRisingEdge;
                        Byte_Count            <= 0;
                    elsif Seconds_Register_i = Data_WR_i and Byte_Count = 1 then
                      -- Master Ack
                      Test_I2C_Write_State <= WriteData;
                    elsif Minutes_Register_i = Data_WR_i and Byte_Count = 2 then
                      -- Master Ack
                      Test_I2C_Write_State <= WriteData;
                    elsif Hours_Register_i = Data_WR_i and Byte_Count = 3 then
                      -- Master Ack
                      Test_I2C_Write_State <= WriteData;   
                    elsif Day_Register_i = Data_WR_i and Byte_Count = 4 then
                      -- Master Ack
                      Test_I2C_Write_State <= WriteData;   
                    elsif Date_Register_i = Data_WR_i and Byte_Count = 5 then
                      -- Master Ack
                      Test_I2C_Write_State <= WriteData;   
                    elsif Mon_Cent_Register_i = Data_WR_i and Byte_Count = 6 then
                      -- Master Ack
                      Test_I2C_Write_State <= WriteData;       
                    elsif Year_Register_i = Data_WR_i and Byte_Count = 7 then
                      -- Master Ack
                      Test_I2C_Write_State <= WriteData;                       
                    end if;
                else
                    Delay_Count     <= Delay_Count + 1;
                end if;   
                
            when AckRisingEdge =>    
                if Int_SCL_i = '1' then
                    Test_I2C_Write_State  <= WaitStop;
                end if;    
                
            when WaitStop =>       
                if Int_SCL_i = '1' and Int_SDA_i = '1' then -- Stop Condition
                    Test_I2C_Write_State  <= StartEdge;
                    Enable_i              <= '0';
                end if;
        end case;

end case;
          
  --case TX_I2C_State is
  --  when Idle =>                              
  --    if Busy_i = '0' then
  --       Address_i          <= "1101000"; --     
  --       RnW_i              <= '0';   
  --       Data_WR_i          <= X"2D";  
  --       Enable_i           <= '1';
  --       TX_I2C_State       <= Write_SlaveAddress;
  --    end if;
        
  --  when Write_SlaveAddress =>                       
  --    if Busy_i = '1' and Count = 100 then     
  --      Address_i           <= "1101000"; --     
  --      RnW_i               <= '0';   
  --      Data_WR_i           <= X"d0";
  --      Count               := 0;
  --      TX_I2C_State        <= WaitnBusy;
  --    elsif Busy_i = '1' and Count < 100 then
  --      Count               := Count +1;                     
  --    end if;
                
  --    when WaitnBusy =>
  --      if Busy_i = '0' then
  --        TX_I2C_State      <= WriteData;
  --      end if;
              
  --    when WriteData =>                       
  --      if Busy_i = '1'  then     
  --        Enable_i          <= '0';
  --        TX_I2C_State      <= WriteData;                     
  --      end if;    
  --end case;   
         
end if;  
end process;
        
        
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
