
-- DESCRIPTION
-- ===========
-- Main Demux: Decodes Commands from PC and passes the data to the command
--
-- Last update : 24/05/2021 - Monde Manzini
-- Version : 0.1

---------------------
---------------------

-- Edited By            : Monde Manzini
--                      : Changed the header
--                      : Updated version
-- Version              : 0.1 
-- Change Note          : 
-- Tested               : 07/05/2021
--              - Testbench: Main_Demux_Test_Bench located at
--                https://katfs.kat.ac.za/svnAfricanArray/SoftwareRepository/CommonCode/ScrCommon
--              - Main_Demux_Test_Bench.do file located at
--                https://katfs.kat.ac.za/svnAfricanArray/SoftwareRepository/CommonCode/Modelsim/ 

-- Outstanding : Code 83, Code 86 and Code 88 version and CRC
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_UNSIGNED.all;
use work.Version_Ascii.all;

  entity Main_Demux is
    port (
         CLK_I                                           : in  std_logic;
         RST_I                                           : in  std_logic;
-- Serial in from RS232                                       
         UART_RXD                                        : in  std_logic;
                     
-- Data Bytes

-- Real Time Clock
         Seconds_out                                     : out std_logic_vector(7 downto 0); 
         Minutes_out                                     : out std_logic_vector(7 downto 0); 
         Hours_out                                       : out std_logic_vector(7 downto 0); 
         Day_out                                         : out std_logic_vector(7 downto 0); 
         Date_out                                        : out std_logic_vector(7 downto 0); 
         Month_Century_out                               : out std_logic_vector(7 downto 0); 
         Year_out                                        : out std_logic_vector(7 downto 0); 

-- Output Card Bytes  
         Dig_Card1_1_B0                                  : out std_logic_vector(7 downto 0);     
         Dig_Card1_1_B1                                  : out std_logic_vector(7 downto 0);     
         Dig_Card1_1_B2                                  : out std_logic_vector(7 downto 0);     
         Dig_Card1_1_B3                                  : out std_logic_vector(7 downto 0);
         Dig_Card1_1_B4                                  : out std_logic_vector(7 downto 0);     
         Dig_Card1_1_B5                                  : out std_logic_vector(7 downto 0);     
         Dig_Card1_1_B6                                  : out std_logic_vector(7 downto 0);     
         Dig_Card1_1_B7                                  : out std_logic_vector(7 downto 0); 
                      
-- Flags
         SET_Timer                                       : out std_logic;
         Dig_Outputs_Ready                               : out std_logic;
         Module_Number                                   : out std_logic_vector(7 downto 0);
         SPI_IO_Driver_Version_Request                   : out std_logic;  
         SPI_Output_Handler_Version_Request              : out std_logic; 
         SPI_Input_Handler_Version_Request               : out std_logic; 
         SPI_Analog_Driver_Version_Request               : out std_logic;
         SPI_Analog_Handler_Version_Request              : out std_logic;
         Real_Time_Clock_Handler_Version_Request         : out std_logic;
         Main_Mux_Version_Request                        : out std_logic; 
         Baud_Rate_Generator_Version_Request             : out std_logic; 
         APE_Test_System_FPGA_Firmware_Version_Request   : out std_logic; 
         EndatSniffer_Version_Request                    : out std_logic;
         Main_Demux_Version_Name                         : out std_logic_vector(255 downto 0);
         Main_Demux_Version_Number                       : out std_logic_vector(63 downto 0);
         Main_Demux_Version_Ready                        : out std_logic 
      );

  end Main_Demux;
  
architecture Arch_DUT of Main_Demux is

  constant Preamble1         : std_logic_vector(7 downto 0) := X"A5"; 
  constant Preamble2         : std_logic_vector(7 downto 0) := X"5A";
  constant Preamble3         : std_logic_vector(7 downto 0) := X"7E";
 
  constant Ack_ok            : std_logic_vector(7 downto 0) := X"00";
  constant Lenght_Zero       : std_logic_vector(7 downto 0) := X"01";
  constant ID_1_Error        : std_logic_vector(7 downto 0) := X"02";
  constant MAC_Error         : std_logic_vector(7 downto 0) := X"03";
  constant CRC_error         : std_logic_vector(7 downto 0) := X"04";
  constant WD_Timer_error    : std_logic_vector(7 downto 0) := X"05";
  constant Long_error        : std_logic_vector(7 downto 0) := X"06";
  constant Short_error       : std_logic_vector(7 downto 0) := X"07";  
  
 type clock_states is (wait_low,wait_high);
 type rx_states is (rx_idle,wait4start,found_start,get_data,look4end);
 type Ms_sync_states is (idle,sync_state,Wait_sync);

 type cmd_states is (idle,Length, get_Mode, branch, get_mem, get_time_sec, get_version_mod_1,get_time_min,
                    get_time_hrs,get_time_days,get_time_date,get_time_mon_cen, get_time_yrs,
                    Get_Outputs,Store_Outputs, CRC_check, CRC_check_L, Set_Active,Active,Send_ack,Reset_Trigger, 
                    version_loader, Wait_Idle, Header_Check);
  
   signal clock_state              : clock_states;
   signal cmd_state                : cmd_states;
   signal rx_state                 : rx_states;
   signal Ms_sync_state            : Ms_sync_states;
 
-- Serial input
   signal SerDataIn                : std_logic;
   signal baud_rate_reload         : integer range 0 to 4095;
   signal Baud_rate_offset         : integer range 0 to 2000;
       
-- Data Storage
   -- Mode = Inputs
   signal Time_Stamp_Byte_3_i      : std_logic_vector(7 downto 0);
   signal Time_Stamp_Byte_2_i      : std_logic_vector(7 downto 0);
   signal Time_Stamp_Byte_1_i      : std_logic_vector(7 downto 0);
   signal Time_Stamp_Byte_0_i      : std_logic_vector(7 downto 0);
   signal Dig_MilliSecond_B1_i     : std_logic_vector(7 downto 0);
   signal Dig_MilliSecond_B0_i     : std_logic_vector(7 downto 0);

   signal Card_Type_1_i            : std_logic_vector(7 downto 0);     
   signal Card_Type_2_i            : std_logic_vector(7 downto 0);     
   signal Card_Type_3_i            : std_logic_vector(7 downto 0);     
   signal Card_Type_4_i            : std_logic_vector(7 downto 0);
  
   signal Dig_Card1_1_B0_i         : std_logic_vector(7 downto 0);     
   signal Dig_Card1_1_B1_i         : std_logic_vector(7 downto 0);     
   signal Dig_Card1_1_B2_i         : std_logic_vector(7 downto 0);     
   signal Dig_Card1_1_B3_i         : std_logic_vector(7 downto 0);
   signal Dig_Card1_1_B4_i         : std_logic_vector(7 downto 0);     
   signal Dig_Card1_1_B5_i         : std_logic_vector(7 downto 0);     
   signal Dig_Card1_1_B6_i         : std_logic_vector(7 downto 0);     
   signal Dig_Card1_1_B7_i         : std_logic_vector(7 downto 0);
    
   signal Output_Card_1_i          : std_logic_vector(7 downto 0);
   signal Output_Card_2_i          : std_logic_vector(7 downto 0);

   -- Mode = Clock
   signal Clock_Secs_3_i           : std_logic_vector(7 downto 0); 
   signal Clock_Secs_2_i           : std_logic_vector(7 downto 0); 
   signal Clock_Secs_1_i           : std_logic_vector(7 downto 0); 
   signal Clock_Secs_0_i           : std_logic_vector(7 downto 0);
   signal Clock_MSecs_2_i          : std_logic_vector(7 downto 0);
   signal Clock_MSecs_1_i          : std_logic_vector(7 downto 0);
   signal Clock_MSecs_0_i          : std_logic_vector(7 downto 0);
  
   signal Time_Config_i            : std_logic_vector(7 downto 0);
   signal Message_ID1_i            : std_logic_vector(7 downto 0);
   signal Mode_i                   : std_logic_vector(7 downto 0);
   signal Stored_Mode              : std_logic_vector(7 downto 0);
   signal byte_number              : integer range 0 to 255;
   signal Nack_Bit_i               : std_logic;
   signal Ack_Bit_i                : std_logic;
  
-- Usart Signals
   signal fifo_reset               : std_logic;
   signal fifo_enable              : std_logic;
   signal sync_bit                 : std_logic;
   signal count                    : integer range 0 to 127;
   signal Flag_rec                 : std_logic; 
   signal q                        : std_logic_vector(7 downto 0);
   signal got_byte                 : std_logic;
   signal enable_div_RX            : std_logic;
   signal wd_timer                 : std_logic; 
   signal byte_received            : std_logic_vector(7 downto 0);  
   signal ACK_Nack                 : std_logic;
   signal Link_OK_i                : std_logic;  
 -- CRC 16 Signals
   signal CRC_byte_i               : std_logic_vector(15 downto 0);
   signal CRX                      : std_logic_vector(15 downto 0);
   signal CRC_In                   : std_logic_vector(7 downto 0);
   signal CRC_out                  : std_logic;
   signal Calculate_CRC            : std_logic;
   signal CRC_reset                : std_logic;
   signal crc_data_bit             : std_logic;
   signal CRCIn_Bit                : std_logic;
   signal flag_WD                  : std_logic;
   signal Error_Code               : std_logic_vector(7 downto 0);
   signal Message_Length_i         : std_logic_vector(7 downto 0);
   signal Header_1_i               : std_logic_vector(7 downto 0);
   signal Header_2_i               : std_logic_vector(7 downto 0);
   signal Header_3_i               : std_logic_vector(7 downto 0);
-- Time Out
   signal Seconds_out_i            : std_logic_vector(7 downto 0) := X"00";         
   signal Minutes_out_i            : std_logic_vector(7 downto 0) := X"00";     
   signal Hours_out_i              : std_logic_vector(7 downto 0) := X"00";
   signal Day_out_i                : std_logic_vector(7 downto 0) := X"00";         
   signal Date_out_i               : std_logic_vector(7 downto 0) := X"00";     
   signal Month_Century_out_i      : std_logic_vector(7 downto 0) := X"00";
   signal Year_out_i               : std_logic_vector(7 downto 0) := X"00";
   signal Messag_Length_i          : integer range 0 to 50;

  signal SerDataOut                : std_logic;
  
  signal Module_Number_i              : std_logic_vector(7 downto 0);
  signal Main_Demux_Version_Request_i : std_logic;

signal Main_Demux_Version_Name_i     : std_logic_vector(255 downto 0); 
signal Main_Demux_Version_Number_i   : std_logic_vector(63 downto 0);  

function reverse_any_bus (a: in std_logic_vector)
return   std_logic_vector is
variable result: std_logic_vector(a'RANGE);
alias    aa: std_logic_vector(a'REVERSE_RANGE) is a;
begin
for i in aa'RANGE loop
result(i) := aa(i);
end loop;
return result;
end; -- function reverse_any_bus   

component myfifo8
   port (
         aclr           : IN  STD_LOGIC;
         clock          : IN  STD_LOGIC;
         enable         : IN  STD_LOGIC;
         shiftin        : IN  STD_LOGIC;
         q              : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
         shiftout       : OUT STD_LOGIC
         );
end component;

  begin

  
-- USART input buffer  
   u1: myfifo8
      port map (
               aclr      => fifo_reset,
               clock     => CLK_I,
               enable    => fifo_enable,
               shiftin   => SerDataIn,
               q         => q,
               shiftout  => open 
               );
    
   fifo_reset                     <= not RST_I;  
 --  SerDataIn                      <= UART_RXD;

   SerDataIn                      <= UART_RXD;
 
 baud_rate_gen_rx: process (CLK_I, RST_I)
   variable sample_div : integer range 0 to 6000;
 begin  
   if RST_I = '0' then                    
      enable_div_RX <= '0';
      sample_div    := 27;           -- baud rate to 9600. 20nS clock 5208/16 =325      
--      sample_div := 162;        -- baud rate to 19200. 20nS clock 
--      sample_div := 81;         -- baud rate to 38400. 20nS clock
--      sample_div := 54;         -- baud rate to 57600. 20nS clock
--     sample_div := 40;         -- baud rate to 76800. 20nS clock
--      sample_div := 27;         -- baud rate to 115200. 20nS clock           
-- Clock
   elsif CLK_I'event and CLK_I = '1' then   
     if sync_bit = '1' then
        sample_div     := 0;
     end if;
   
--    if sample_div = 324 then         -- baud rate to 9600
--     if sample_div = 162 then      -- baud rate to 19200 with 20MHz
--    if sample_div = 81 then       -- baud rate to 38400 with 20MHz
--       if sample_div = 54 then       -- baud rate to 57600 with 20MHz
--     if sample_div = 40 then       -- baud rate to 76800 with 20MHz        
     if sample_div     = 27 then   -- baud rate to 115200 with 20MHz  
        sample_div     := 0;
        enable_div_RX  <= '1';
     else
        sample_div     := sample_div + 1;
        enable_div_RX  <= '0';
     end if;  

   end if;
 end process baud_rate_gen_rx;

watch_dog: process (CLK_I, RST_I)

    variable cnt       : integer range 0 to 20000;
    variable Div_cnt   : integer range 0 to 500;
    variable div_pulse : std_logic;

  begin  
    if RST_I = '0' then                    
       wd_timer <= '0';    
    elsif CLK_I'event and CLK_I = '1' then
      if Div_cnt = 400 and cnt = 0 then
         wd_timer <= '1';       
      else
         wd_timer <= '0';
      end if;
      
       if Flag_rec = '1' then
          if cnt = 20000 then
             Div_cnt := Div_cnt + 1;
             cnt     := 0;
          else
           cnt := cnt + 1;
          end if;
       else
           cnt := 0;
           Div_cnt := 0;
       end if;
    end if;
 end process watch_dog;

uart_rx: process (CLK_I, RST_I)
  
  variable sample_counter : integer range 0 to 15;
  variable data_bit_cnt : integer range 0 to 7;
  
 begin
   
   if RST_I = '0' then                   
      rx_state        <= rx_idle;
      sample_counter  := 0;
      fifo_enable     <= '0';
      data_bit_cnt    := 0;
      byte_received   <= (others => '0');
      got_byte        <= '0';
      count           <= 0;
      sync_bit        <= '0';
      CRC_In          <= X"00";
   elsif CLK_I'event and CLK_I = '1' then
     
     case rx_state is
       when rx_idle =>                  
            data_bit_cnt    := 0;         
            sample_counter  := 0;
            got_byte        <= '0';
            if SerDataIn = '0' then
               rx_state <= rx_idle;
            elsif count = 10 and SerDataIn = '1'  then
               rx_state <= wait4start;
               count    <= 0;
               sync_bit <= '0';
            elsif SerDataIn = '1' then
               count <= count + 1;
            else  
               count <= 0;
            end if;                        
        
       when wait4start =>
            if SerDataIn = '1' then         
               rx_state <= wait4start;
            elsif count = 10 and SerDataIn = '0'  then
               rx_state       <= found_start;
               count          <= 0;
               sample_counter := 0;
               sync_bit       <= '1';
              
            elsif SerDataIn = '0' then
               count <= count + 1;
            else  
               count <= 0;
            end if;           
               
       when found_start =>
            sync_bit <= '0';
            if enable_div_RX = '1' then            
               if sample_counter = 15 then
                  sample_counter := 0; 
               else
                  sample_counter := sample_counter + 1;              
               end if;
            end if;
    
            if sample_counter = 8 then
           
               if SerDataIn = '0' then
                  rx_state     <= get_data;
                  data_bit_cnt := 0;
               else
                  rx_state <= rx_idle;
                  count    <= 0;
               end if;   
            end if;
         
       when get_data =>
  
            if enable_div_RX = '1' then
               if sample_counter = 15 then
                  sample_counter := 0;                            
               else
                  sample_counter := sample_counter + 1;              
               end if;
            end if;

            if enable_div_RX = '1' and sample_counter = 8 then
               if data_bit_cnt = 7 then
                  data_bit_cnt := 0;
                  rx_state     <= look4end;
                  fifo_enable  <= '0';
               else
                  data_bit_cnt := data_bit_cnt + 1;             
               end if;           
               fifo_enable <= '1';
            else           
               fifo_enable <= '0';
            end if;
              
       when look4end =>
            fifo_enable <= '0';
            if enable_div_RX = '1' then
               if sample_counter = 15 then
                  sample_counter := 0;               
               else              
                  sample_counter := sample_counter + 1;
               end if;
               
               if sample_counter = 8 then
                  got_byte       <= '1';
                  byte_received  <= q;
                  CRC_In         <= reverse_any_bus(q);
                  rx_state       <= rx_idle;
               end if;
            end if;
            
       when others =>
             rx_state <= rx_idle;
     end case;
   end if;
 end process uart_rx; 

CRC16_Bit: process(CLK_I, RST_I)
      variable data_bit_cnt : integer range 0 to 32;
begin
      if RST_I = '0' then 
         crc_Data_bit  <= '0';
         data_bit_cnt  := 0;
         Calculate_CRC <= '0';
         CRCIn_Bit     <= '0';
      elsif CLK_I'event and CLK_I = '1' then
            
            if CRC_out = '1' then
               Calculate_CRC <= '1';
               data_bit_cnt  := 0;
            end if;

            if Calculate_CRC = '1' then
               if data_bit_cnt = 0 then   
                  CRCIn_Bit    <= CRC_In(0);
                  data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 1 then  
                     crc_Data_bit <= '1';
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 2 then  
                     crc_Data_bit <= '0';
                     CRCIn_Bit    <= CRC_In(1);
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 3 then  
                     crc_Data_bit <= '1';
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 4 then  
                     crc_Data_bit <= '0';
                     CRCIn_Bit    <= CRC_In(2);
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 5 then  
                     crc_Data_bit <= '1';
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 6 then  
                     crc_Data_bit <= '0';
                     CRCIn_Bit    <= CRC_In(3);
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 7 then  
                     crc_Data_bit <= '1';
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 8 then  
                     crc_Data_bit <= '0';
                     CRCIn_Bit    <= CRC_In(4);
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 9 then  
                     crc_Data_bit <= '1';
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 10 then  
                     crc_Data_bit <= '0';
                     CRCIn_Bit    <= CRC_In(5);
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 11 then  
                     crc_Data_bit <= '1';
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 12 then  
                     crc_Data_bit <= '0';
                     CRCIn_Bit    <= CRC_In(6);
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 13 then  
                     crc_Data_bit <= '1';
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 14 then  
                     crc_Data_bit <= '0';
                     CRCIn_Bit    <= CRC_In(7);
                     data_bit_cnt := data_bit_cnt + 1;                     
               elsif data_bit_cnt = 15 then  
                     crc_Data_bit <= '1';
                     data_bit_cnt := data_bit_cnt + 1;
               elsif data_bit_cnt = 16 then  
                     crc_Data_bit  <= '0';
                     data_bit_cnt  := 0;
                     Calculate_CRC <= '0';
               end if;  
                   
            end if;
      end if;
 end process CRC16_bit;
  
CRC16_new: process(CLK_I, RST_I)
begin
      if RST_I = '0' then 
         CRX <= (others=> '1');
      elsif CLK_I'event and CLK_I = '1' then
            if CRC_reset = '1' then
               CRX <= (others=> '1');
            end if;
 
             if crc_Data_bit = '1'  then 
                CRX(0)  <= CRCIn_Bit xor CRX(15);
                CRX(1)  <= CRX(0);
                CRX(2)  <= CRX(1);
                CRX(3)  <= CRX(2);
                CRX(4)  <= CRX(3);
                CRX(5)  <= CRX(4) xor CRCIn_Bit xor CRX(15);
                CRX(6)  <= CRX(5); 
                CRX(7)  <= CRX(6);
                CRX(8)  <= CRX(7);
                CRX(9)  <= CRX(8);
                CRX(10) <= CRX(9);
                CRX(11) <= CRX(10);
                CRX(12) <= CRX(11) xor CRCIn_Bit xor CRX(15);
                CRX(13) <= CRX(12);
                CRX(14) <= CRX(13);
                CRX(15) <= CRX(14);
             end if;
      end if;
 end process CRC16_new;
  
decode_cmd: process (CLK_I, RST_I)

   variable Wait_cnt           : integer range 0 to 50;
   variable got_byte_cnt       : integer range 0 to 10;
  
begin  
   if RST_I = '0' then     
      Main_Demux_Version_Name                   <= (others => '0');
      Main_Demux_Version_Name_i                 <= (others => '0');
      Main_Demux_Version_Number                 <= (others => '0'); 
      Main_Demux_Version_Number_i               <= (others => '0');
      Main_Demux_Version_Ready                  <= '0';   
            report "The version number of Main_Demux is 00.01.04." severity note;                    
      cmd_state                                 <= idle;  
      Time_Stamp_Byte_3_i                       <= (others=> '0');
      Time_Stamp_Byte_2_i                       <= (others=> '0');
      Time_Stamp_Byte_1_i                       <= (others=> '0');
      Time_Stamp_Byte_0_i                       <= (others=> '0');
      Dig_MilliSecond_B1_i                      <= (others=> '0');
      Dig_MilliSecond_B0_i                      <= (others=> '0');
      Dig_Card1_1_B0_i                          <= (others=> '0');
      Dig_Card1_1_B1_i                          <= (others=> '0');
      Dig_Card1_1_B2_i                          <= (others=> '0');
      Dig_Card1_1_B3_i                          <= (others=> '0');
      Dig_Card1_1_B4_i                          <= (others=> '0');
      Dig_Card1_1_B5_i                          <= (others=> '0');
      Dig_Card1_1_B6_i                          <= (others=> '0');
      Dig_Card1_1_B7_i                          <= (others=> '0');
      Dig_Card1_1_B0                            <= (others=> '0');
      Dig_Card1_1_B1                            <= (others=> '0');
      Dig_Card1_1_B2                            <= (others=> '0');
      Dig_Card1_1_B3                            <= (others=> '0');
      Dig_Card1_1_B4                            <= (others=> '0');
      Dig_Card1_1_B5                            <= (others=> '0');
      Dig_Card1_1_B6                            <= (others=> '0');
      Dig_Card1_1_B7                            <= (others=> '0');
      Output_Card_1_i                           <= (others=> '0');
      Output_Card_2_i                           <= (others=> '0');
      --Messag_length_i                           <= 0;
      Seconds_out_i                             <= (others=> '0');
      Minutes_out_i                             <= (others=> '0');
      Hours_out_i                               <= (others=> '0');
      Day_out_i                                 <= (others=> '0');
      Date_out_i                                <= (others=> '0');
      Month_Century_out_i                       <= (others=> '0');
      Year_out_i                                <= (others=> '0');
      Seconds_out                               <= (others=> '0');
      Minutes_out                               <= (others=> '0');
      Hours_out                                 <= (others=> '0');
      Day_out                                   <= (others=> '0');
      Date_out                                  <= (others=> '0');
      Month_Century_out                         <= (others=> '0');
      Year_out                                  <= (others=> '0');
      CRC_byte_i                                <= (others=> '0');
      wait_cnt                                  := 0;
      got_byte_cnt                              := 0;
      SET_Timer                                 <= '0';
      Dig_Outputs_Ready                         <= '0';
      CRC_out                                   <= '0';
      Module_Number_i                           <= (others=> '0');
      Module_Number                             <= (others=> '0');
      SPI_Analog_Driver_Version_Request         <= '0';
      SPI_Analog_Handler_Version_Request        <= '0';
      Main_Demux_Version_Request_i              <= '0';  
      SPI_IO_Driver_Version_Request             <= '0';
      SPI_Output_Handler_Version_Request        <= '0';                 
      SPI_Input_Handler_Version_Request         <= '0';
      Main_Mux_Version_Request                  <= '0';
      Real_Time_Clock_Handler_Version_Request   <= '0';
      Baud_Rate_Generator_Version_Request       <= '0';
      APE_Test_System_FPGA_Firmware_Version_Request <= '0'; 
   elsif CLK_I'event and CLK_I = '1' then

       Main_Demux_Version_Name_i    <= M & A & I & N & Space & D & E & M & U & X &
                                       Space & Space & Space & Space & Space & Space & Space & Space &
                                       Space & Space & Space & Space & Space & Space & Space &
                                       Space & Space & Space & Space & Space & Space & Space;
       Main_Demux_Version_Number_i  <= Zero & Zero & Dot & Zero & One  & Dot & Zero & Four;  
      
       if Module_Number_i = X"07" then
          if Main_Demux_Version_Request_i = '1' then
             Main_Demux_Version_Ready    <= '1';
             Main_Demux_Version_Name     <= Main_Demux_Version_Name_i;
             Main_Demux_Version_Number   <= Main_Demux_Version_Number_i;  
          else
             Main_Demux_Version_Ready <= '0';
          end if;
       else   
           Main_Demux_Version_Ready <= '0'; 
       end if; 

       if wd_timer = '1' then          
          cmd_state <= idle;
       end if;
       
       case cmd_state is
         
         when idle =>
           
              Flag_rec                <= '0';
              CRC_reset               <= '0';
              Messag_Length_i         <= 0;
              got_byte_cnt            := 0;
              cmd_state               <= Wait_Idle;

         when Wait_Idle =>
              CRC_reset       <= '0';
              if got_byte = '1' then
                 got_byte_cnt := got_byte_cnt + 1;
                 cmd_state    <= Header_Check; 
              end if;

         when Header_Check =>  
               
              if got_byte_cnt = 1 then        -- Header Byte 0 -- A5
                 Header_1_i <= byte_received;                                  
                 Flag_rec   <= '1'; 
                 CRC_reset  <= '1';
                 cmd_state  <= Wait_Idle;
              elsif got_byte_cnt = 2 then     -- Header Byte 1 -- 5A 
                 Header_2_i <= byte_received; 
                 Flag_rec   <= '1'; 
                 CRC_reset  <= '1';  
                 cmd_state  <= Wait_Idle;
              elsif got_byte_cnt = 3 then     -- Header Byte 2 -- 7E    
                 Header_3_i <= byte_received; 
                 Flag_rec   <= '1';  
                 CRC_reset  <= '1'; 
                 if (Header_1_i = Preamble1) and (Header_2_i = Preamble2) 
                 and (Header_3_i = Preamble3) then
                     got_byte_cnt := 0;
                     cmd_state    <= Length;
                 end if;    
              end if;  
           
         when Length =>
              CRC_reset   <= '0';
              if got_byte = '1' then
                 CRC_out           <= '1';
                 Message_Length_i  <= byte_received;    -- Length Byte3
                 cmd_state         <= get_Mode;              
            end if;      
                              
-- Mode     
         when get_Mode =>             
              CRC_reset       <= '0';
              CRC_out         <= '0';
              Messag_Length_i <= conv_integer(Message_Length_i); -- Convert Message
              if got_byte = '1' then
                 CRC_out        <= '1';
                 Mode_i         <= byte_received;       -- Mode Byte4
                 cmd_state      <= branch;
              end if;
             
-- Branch
         when branch => 
      
            CRC_out <= '0'; 
              case Mode_i  is
                                        
                  when X"80" =>                       -- Mode Time Stamp
                     cmd_state           <= get_time_sec;
                        
                  when X"81" =>                       -- Mode Outputs
                     cmd_state           <= Get_Outputs;

                  when X"82" =>                       -- Mode Time Stamp
                     cmd_state           <= get_mem;

                  when X"90" =>                       -- Mode Version
                     cmd_state           <= get_version_mod_1;     

                  when others =>               
                     cmd_state <= idle;
                        
               end case;
-------------------------------------------------------------------------------
-- Time Config - From Software to Controller Mode "80"
-------------------------------------------------------------------------------
          when get_time_sec =>
               CRC_out <= '0';                           
               if got_byte = '1' then
                  CRC_out             <= '1';                
                  Seconds_out_i <= byte_received;   -- Time Stamp Byte 3 
                                                          -- Byte 5
                  cmd_state     <= get_time_min;
               end if;

          when get_time_min =>
               CRC_out <= '0';                           
               if got_byte = '1' then
                  CRC_out       <= '1';                
                  Minutes_out_i <= byte_received;   -- Time Stamp Byte 2 
                                                          -- Byte 6
                  cmd_state           <= get_time_hrs;
               end if;
--               
          when get_time_hrs =>
               CRC_out <= '0';                           
               if got_byte = '1' then
                  CRC_out             <= '1';                 
                  Hours_out_i <= byte_received;   -- Time Stamp Byte 1 --
                                                          -- Byte 7
                  cmd_state           <= get_time_days;
               end if;
-- 
          when get_time_days =>
               CRC_out <= '0';                           
               if got_byte = '1' then
                  CRC_out             <= '1';                 
                  Day_out_i <= byte_received;   -- Time Stamp Byte 0 --
                                                          -- Byte 8
                  cmd_state           <= get_time_date;
               end if;
      
          when get_time_date =>
               CRC_out <= '0';                           
               if got_byte = '1' then
                  CRC_out    <= '1';                
                  Date_out_i <= byte_received;  -- mS Byte 1 -- Byte 10
                  cmd_state  <= get_time_mon_cen;
               end if;
-- 
         when get_time_mon_cen =>
              CRC_out <= '0';                           
              if got_byte = '1' then
                 CRC_out              <= '1';                 
                 Month_Century_out_i  <= byte_received;    -- mS Byte 0 -- Byte 11
                 cmd_state            <= get_time_yrs;
              end if;   

         when get_time_yrs =>
            CRC_out <= '0';                           
            if got_byte = '1' then
               CRC_out              <= '1';                 
               Year_out_i           <= byte_received;    -- mS Byte 0 -- Byte 11
               cmd_state            <= CRC_check;
            end if;  
-------------------------------------------------------------------------------
-- Outputs - From Colin to Us - Mode "81"
-------------------------------------------------------------------------------
         when Get_Outputs =>
            CRC_out <= '0'; 
            if got_byte = '1' then
               CRC_out      <= '1';   
               got_byte_cnt := got_byte_cnt + 1;
               cmd_state    <= Store_Outputs; 
            end if;

         when Store_Outputs =>  
            case got_byte_cnt is
               when 1 =>
                  Output_Card_1_i   <= byte_received;   
                  cmd_state         <= Get_Outputs;
               when 2 =>
                  Dig_Card1_1_B3_i <= byte_received;    
                  cmd_state        <= Get_Outputs;
               when 3 =>
                  Dig_Card1_1_B2_i <= byte_received;    
                  cmd_state        <= Get_Outputs;
               when 4 =>
                  Dig_Card1_1_B1_i <= byte_received;    
                  cmd_state        <= Get_Outputs; 

               when 5 =>
                  Dig_Card1_1_B0_i <= byte_received;    
                  cmd_state        <= Get_Outputs; 
               
               when 6 =>
                  Output_Card_2_i  <= byte_received;    
                  cmd_state        <= Get_Outputs; 

               when 7 =>
                  Dig_Card1_1_B7_i <= byte_received;    
                  cmd_state        <= Get_Outputs;

               when 8 =>
                  Dig_Card1_1_B6_i <= byte_received;    
                  cmd_state        <= Get_Outputs;

               when 9 =>
                  Dig_Card1_1_B5_i <= byte_received;    
                  cmd_state        <= Get_Outputs;

               when 10 =>
                  Dig_Card1_1_B4_i <= byte_received;    
                  got_byte_cnt     := 0;
                  cmd_state        <= CRC_check;
               
                when others =>
            end case;

            --if got_byte_cnt = 1 then        
            --   Output_Card_1_i   <= byte_received;   -- Output Card 1 Byte5
            --   cmd_state         <= Get_Outputs;
            --elsif got_byte_cnt = 2 then     
            --   Dig_Card1_1_B3_i <= byte_received;    -- Output Card 1 Byte6
            --   cmd_state        <= Get_Outputs;
            --elsif got_byte_cnt = 3 then       
            --   Dig_Card1_1_B2_i <= byte_received;    -- Output Card 1 Byte7 
            --   cmd_state        <= Get_Outputs;
            --elsif got_byte_cnt = 4 then       
            --   Dig_Card1_1_B1_i <= byte_received;    -- Output Card 1 Byte8 
            --   cmd_state        <= Get_Outputs;   
            --elsif got_byte_cnt = 5 then       
            --   Dig_Card1_1_B0_i <= byte_received;    -- Output Card 1 Byte9 
            --   cmd_state        <= Get_Outputs;     
            --elsif got_byte_cnt = 6 then       
            --   Output_Card_2_i  <= byte_received;    -- Output Card 2 Byte10 
            --   cmd_state        <= Get_Outputs;   
            --elsif got_byte_cnt = 7 then     
            --   Dig_Card1_1_B7_i <= byte_received;    -- Output Card 1 Byte11
            --   cmd_state        <= Get_Outputs;
            --  elsif got_byte_cnt = 8 then       
            --   Dig_Card1_1_B6_i <= byte_received;    -- Output Card 1 Byte12 
            --   cmd_state        <= Get_Outputs;
            --elsif got_byte_cnt = 9 then       
            --   Dig_Card1_1_B5_i <= byte_received;    -- Output Card 1 Byte13 
            --   cmd_state        <= Get_Outputs;   
            --elsif got_byte_cnt = 10 then       
            --   Dig_Card1_1_B4_i <= byte_received;    -- Output Card 1 Byte14
            --   got_byte_cnt     := 0;
            --   cmd_state        <= CRC_check;
            --end if;   

-------------------------------------------------------------------------------
-- Version Config - From Software to Controller Mode "90"
-------------------------------------------------------------------------------      
         when get_version_mod_1 =>
               CRC_out <= '0';                           
               if got_byte = '1' then
                  CRC_out         <= '1';                
                  Module_Number_i <= byte_received;  
                  cmd_state       <= CRC_Check;
               end if;            

-- CRC checker           
         when CRC_check =>
              got_byte_cnt        := 0;
              CRC_out        <= '0';
              if got_byte = '1' then
                 CRC_byte_i(15 downto 8)       <= byte_received;
                 cmd_state                     <= CRC_check_L;                   
              end if;
                 
         when CRC_check_L =>

              CRC_out <= '0';
              if got_byte = '1' then
                 CRC_byte_i(7 downto 0)       <= byte_received;
                 cmd_state                    <= Set_Active;                    
              end if;
                  
         when Set_Active =>
              CRC_out    <= '0';
              if CRC_byte_i =  CRX then
                 cmd_state <= Send_ack;
              else
                 cmd_state <= Idle;                      
              end if;

         when Send_ack =>
            cmd_state <= Active;
                
         when Active =>
      
            if Mode_i = X"80" then         -- Inputs Time Stamp
                                       
               Seconds_out                <= Seconds_out_i;                
               Minutes_out                <= Minutes_out_i;             
               Hours_out                  <= Hours_out_i;
               Day_out                    <= Day_out_i;
               Date_out                   <= Date_out_i;
               Month_Century_out          <= Month_Century_out_i;
               Year_out                   <= Year_out_i;
               SET_Timer                  <= '1';
               cmd_state                  <= reset_trigger;
                    
            elsif Mode_i = X"81" then
                                       
               Dig_Card1_1_B0        <= Dig_Card1_1_B0_i;
               Dig_Card1_1_B1        <= Dig_Card1_1_B1_i;
               Dig_Card1_1_B2        <= Dig_Card1_1_B2_i;
               Dig_Card1_1_B3        <= Dig_Card1_1_B3_i;
               Dig_Card1_1_B4        <= Dig_Card1_1_B4_i;
               Dig_Card1_1_B5        <= Dig_Card1_1_B5_i;
               Dig_Card1_1_B6        <= Dig_Card1_1_B6_i;
               Dig_Card1_1_B7        <= Dig_Card1_1_B7_i;

               Dig_Outputs_Ready     <= '1';

               cmd_state             <= reset_trigger;
  
            elsif Mode_i = X"90" then        
               Module_Number         <= Module_Number_i;
               cmd_state             <= version_loader;
                                        
            end if;  

         when version_loader =>  
            cmd_state             <= reset_trigger; 
            case Module_Number_i is
               when X"00" =>
                  SPI_IO_Driver_Version_Request                   <= '0';
                  SPI_Input_Handler_Version_Request               <= '0';
                  SPI_Output_Handler_Version_Request              <= '0';
                  SPI_Analog_Driver_Version_Request               <= '0';
                  SPI_Analog_Handler_Version_Request              <= '0';
                  Main_Demux_Version_Request_i                    <= '0'; 
                  Main_Mux_Version_Request                        <= '0';
                  Real_Time_Clock_Handler_Version_Request         <= '0';
                  Baud_Rate_Generator_Version_Request             <= '0';
                  APE_Test_System_FPGA_Firmware_Version_Request   <= '0';                      
               when X"01" =>
                  SPI_IO_Driver_Version_Request                <= '1';
                  when X"02" =>
                     SPI_Input_Handler_Version_Request            <= '1';
                  when X"03" =>
                     SPI_Output_Handler_Version_Request           <= '1';
                  when X"04" =>
                     SPI_Analog_Driver_Version_Request            <= '1';
                  when X"05" =>
                     SPI_Analog_Handler_Version_Request           <= '1';
                  when X"07" =>
                     Main_Demux_Version_Request_i                 <= '1';  
                  when X"08" =>
                     Main_Mux_Version_Request                     <= '1';    
                  when X"09" =>
                     Real_Time_Clock_Handler_Version_Request      <= '1';  
                  when X"0a" =>
                     Baud_Rate_Generator_Version_Request          <= '1';
                  when X"0b" =>       
                     APE_Test_System_FPGA_Firmware_Version_Request   <= '1';   
                  when X"0c" =>       
                     EndatSniffer_Version_Request                    <= '1';                      
                  when others =>     

               end case;   

                 
            when reset_trigger =>
                 got_byte_cnt                               := 0;
                 SET_Timer                                  <= '0';
                 Dig_Outputs_Ready                          <= '0';
                 SPI_IO_Driver_Version_Request              <= '0';
                 SPI_Output_Handler_Version_Request         <= '0';                 
                 SPI_Input_Handler_Version_Request          <= '0';
                 Main_Demux_Version_Request_i               <= '0'; 
                 SPI_Analog_Driver_Version_Request          <= '0';
                 SPI_Analog_Handler_Version_Request         <= '0';
                 Main_Mux_Version_Request                   <= '0';
                 Real_Time_Clock_Handler_Version_Request    <= '0';
                 Baud_Rate_Generator_Version_Request        <= '0';
                 APE_Test_System_FPGA_Firmware_Version_Request  <= '0';  
                 cmd_state                                  <= idle;

            when others =>     
                 cmd_state           <= idle;
					               
            end case;              
   end if;
 end process decode_cmd;
      
  
end Arch_DUT;

