--

-- DESCRIPTION
-- ===========
-- Transmitter Uart, this gets the data from the mux and send it back to the PC
-- Last update : 29/05/2021 - Monde Manzini

--              - Testbench: Main_Mux_Test_Bench located at
--                https://katfs.kat.ac.za/svnAfricanArray/SoftwareRepository/CommonCode/ScrCommon
--              - Main_Mux_Test_Bench.do file located at
--                https://katfs.kat.ac.za/svnAfricanArray/SoftwareRepository/CommonCode/Modelsim/ 
-- Version : 0.1

---------------------
---------------------

-- Edited By            : Monde Manzini
--                      : Changed the header
--                      : Updated version
-- Version              : 0.1 
-- Change Note          : 
-- Tested               : 07/05/2021
-- Test Bench file Name : Main_Mux_Test_Bench
-- located at           : (https://katfs.kat.ac.za/svnAfricanArray/Software
--                        Repository/CommonCode/ScrCommon)
-- Test do file         : Main_Mux_Test_Bench.do
-- located at            (https://katfs.kat.ac.za/svnAfricanArray/Software
--                        Repository/CommonCode/Modelsim)

-- Outstanding          : Integration ATP and Approval
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_UNSIGNED.all;
use work.Version_Ascii.all;

entity Main_Mux is
  port(
   CLK_I                      : in  std_logic;
   RST_I                      : in  std_logic;
-- Ser data out
   UART_TXD                   : out std_logic;
-- From Demux
   Message_Length             : in  std_logic_vector(7 downto 0);
-------------------------------------------------------------------------------
-- Operation
-------------------------------------------------------------------------------
-- Time Stamp
   Seconds_out                : in std_logic_vector(7 downto 0); 
   Minutes_out                : in std_logic_vector(7 downto 0); 
   Hours_out                  : in std_logic_vector(7 downto 0); 
   Day_out                    : in std_logic_vector(7 downto 0); 
   Date_out                   : in std_logic_vector(7 downto 0); 
   Month_Century_out          : in std_logic_vector(7 downto 0); 
   Year_out                   : in std_logic_vector(7 downto 0); 
    
-- Digital Output    
   Dig_Out_1_B0               : in  std_logic_vector(7 downto 0);
   Dig_Out_1_B1               : in  std_logic_vector(7 downto 0);
   Dig_Out_1_B2               : in  std_logic_vector(7 downto 0);
   Dig_Out_1_B3               : in  std_logic_vector(7 downto 0);
   Dig_Out_1_B4               : in  std_logic_vector(7 downto 0);
   Dig_Out_1_B5               : in  std_logic_vector(7 downto 0);
   Dig_Out_1_B6               : in  std_logic_vector(7 downto 0);
   Dig_Out_1_B7               : in  std_logic_vector(7 downto 0);
   Digital_Input_Valid        : in  std_logic;
   
-- Digital Input          
   Dig_In_1_B0                : in  std_logic_vector(7 downto 0);
   Dig_In_1_B1                : in  std_logic_vector(7 downto 0);        
   Dig_In_1_B2                : in  std_logic_vector(7 downto 0);        
   Dig_In_1_B3                : in  std_logic_vector(7 downto 0);
   Dig_In_1_B4                : in  std_logic_vector(7 downto 0);
   Dig_In_1_B5                : in  std_logic_vector(7 downto 0);        
   Dig_In_1_B6                : in  std_logic_vector(7 downto 0);        
   Dig_In_1_B7                : in  std_logic_vector(7 downto 0); 
   Digital_Output_Valid       : in  std_logic;
    	 
-- Analog In        
   -- Analog InS        
   -- Analog In 1        
   Analog_Data                : in std_logic_vector(767 downto 0);
    
   Analog_Input_Valid         : in  std_logic;
   Version_Name               : in  std_logic_vector(255 downto 0); 
   Version_Number             : in  std_logic_vector(63 downto 0);
   Version_Data_Ready         : in  std_logic; 
   
-- Requests
   Ana_In_Request             : out std_logic;
   Dig_In_Request             : out std_logic;
   Dig_Out_Request            : out std_logic;
   Get_RTC                    : out std_logic;

   Real_Time_Clock_Request    : in std_logic;
   RTC_Valid                  : in std_logic;
   Baud_Rate_Enable           : in  std_logic;  
   Data_Ready                 : in  std_logic;
   One_mS                     : in  std_logic;
   Main_Mux_Version_Name      : out std_logic_vector(255 downto 0);
   Main_Mux_Version_Number    : out std_logic_vector(63 downto 0);
   Main_Mux_Version_Ready     : out std_logic; 
   Main_Mux_Version_Request   : in  std_logic;
   Module_Number              : in  std_logic_vector(7 downto 0)
   );

end Main_Mux;

architecture Arch_DUT of Main_Mux is


  constant Preamble1        : std_logic_vector(7 downto 0) := X"A5";
  constant Preamble2        : std_logic_vector(7 downto 0) := X"5A";
  constant Preamble3        : std_logic_vector(7 downto 0) := X"7E";
  
  constant Output_Card_1    : std_logic_vector(7 downto 0) := X"10";
  constant Output_Card_2    : std_logic_vector(7 downto 0) := X"11";

  constant Input_Card_1    : std_logic_vector(7 downto 0) := X"20";
  constant Input_Card_2    : std_logic_vector(7 downto 0) := X"21";

  constant Analog_Card_1    : std_logic_vector(7 downto 0) := X"30";
  constant Analog_Card_2    : std_logic_vector(7 downto 0) := X"31";

type tx_states 	is (idle, sync, send_start, send_data, CRC_ready, send_stop);
type tx_data_array is array (0 to 255) of std_logic_vector(7 downto 0);
type request_send_states is (Request_Idle, Requests_TX, Data_RX, Collect_Data);

signal data2send                  : tx_data_array;
signal CRC2send                   : tx_data_array;
signal tx_state                   : tx_states;
signal request_send_state         : request_send_states; 
-- end of state machines declaration

signal enable_div20               : std_logic;
signal sample_clock2              : std_logic;
signal no_of_chars                : integer range 0 to 255;  
signal no_of_chars2send           : integer range 0 to 255;
signal baud_rate_reload           : integer range 0 to 6000;
signal busy                       : std_logic;
signal comms_done                 : std_logic;
signal done                       : std_logic;
signal send_msg                   : std_logic;
signal SerDataOut                 : std_logic;
signal CRCSerDataOut              : std_logic;
signal SerData_Byte               : std_logic_vector(7 downto 0);
-- CRC 16 Signals
signal X                          : std_logic_vector(15 downto 0);
signal CRC_Sum                    : std_logic_vector(15 downto 0);
signal crc16_ready                : std_logic;
signal add_crc                    : std_logic;
signal Send_Operation             : std_logic;
signal Send_ComPort_Data          : std_logic;
signal Send_ShaftEncoder          : std_logic;
signal lockout_trigger            : std_logic;  
signal lockout_Read_Trigger       : std_logic;
signal flag_WD                    : std_logic;
signal Message_done                 : std_logic;
signal Data_Ready_i                 : std_logic;
signal Dig_Card1_1_B0_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B1_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B2_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B3_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B4_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B5_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B6_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_1_B7_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B0_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B1_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B2_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B3_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B4_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B5_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B6_i             : std_logic_vector(7 downto 0);
signal Dig_Card1_2_B7_i             : std_logic_vector(7 downto 0);

signal Message_length_i             : std_logic_vector(7 downto 0);
signal Ana_In_Request_i             : std_logic;
signal Dig_In_Request_i             : std_logic;
signal Dig_Out_Request_i            : std_logic;
signal Busy_Latch                   : std_logic;
signal Ready_i                      : std_logic;
signal Stack_100mS_Data             : std_logic;
signal Lockout                      : std_logic;
signal Digital_Output_Ready         : std_logic;
signal Digital_Input_Ready          : std_logic;
signal Analog_Input_Ready           : std_logic;
signal All_Modules_Ready            : std_logic;
signal All_Modules_Trig             : std_logic;
signal Send_100mS_Data              : std_logic;
signal Send_All_Modules             : std_logic;
signal All_Data_Ready               : std_logic;
signal Request_Data_Strobe          : std_logic;
signal Send_Data_Strobe             : std_logic;
signal RTC_Ready                    : std_logic;
signal Version_Name_i               : std_logic_vector(255 downto 0); 
signal Version_Number_i             : std_logic_vector(63 downto 0);  
signal Send_Version_Data_Mess       : std_logic;
signal Send_Version_Data_Ready      : std_logic;
signal Send_Version_Data            : std_logic;
signal Stack_Version_Data           : std_logic;
signal Version_Data_Request         : std_logic;
signal Send_RTC_Mess                : std_logic;
signal Send_RTC_Operation           : std_logic;
signal Stack_RTC_Data               : std_logic;
signal Send_RTC_Data                : std_logic;
signal RTC_Build_Trig_i             : std_logic;
signal RTC_Build_Trig_Done_i        : std_logic;     
signal Ver_Build_Trig_i             : std_logic;
signal Ver_Build_Trig_Done_i        : std_logic;
signal All_Data_Build_Trig_i        : std_logic;  
signal All_Data_Build_Trig_Done_i   : std_logic;  
signal Analog_Input_Load            : std_logic;
signal Real_Time_Clock_Ready        : std_logic;
signal Main_Mux_Version_Name_i      : std_logic_vector(255 downto 0); 
signal Main_Mux_Version_Number_i    : std_logic_vector(63 downto 0);  

-- Time Out
signal Seconds_out_i                : std_logic_vector(7 downto 0) := X"00";         
signal Minutes_out_i                : std_logic_vector(7 downto 0) := X"00";     
signal Hours_out_i                  : std_logic_vector(7 downto 0) := X"00";
signal Day_out_i                    : std_logic_vector(7 downto 0) := X"00";         
signal Date_out_i                   : std_logic_vector(7 downto 0) := X"00";     
signal Month_Century_out_i          : std_logic_vector(7 downto 0) := X"00";
signal Year_out_i                   : std_logic_vector(7 downto 0) := X"00";

signal no_of_chars2snd              : std_logic_vector(7 downto 0) := X"00";
signal mode_i                       : std_logic_vector(7 downto 0) := X"00";

type Time_Array is array (0 to 255) of std_logic_vector(7 downto 0);
signal Time_Data_Array        : Time_Array;

type Preamble_Array is array (0 to 255) of std_logic_vector(7 downto 0);
signal Preamble_Data_Array    : Preamble_Array;

type Digital_In_Array is array (0 to 255) of std_logic_vector(7 downto 0);
signal Digital_In_Data_Array  : Digital_In_Array;

type Digital_Out_Array is array (0 to 255) of std_logic_vector(7 downto 0);
signal Digital_Out_Data_Array : Digital_Out_Array;

type Analog_In_Array is array (0 to 767) of std_logic_vector(7 downto 0);
signal Analog_In_Data_Array   : Analog_In_Array; 

type Version_Array is array (0 to 255) of std_logic_vector(7 downto 0);
signal Version_Data_Array   : Version_Array;

function reverse_any_bus (a : in std_logic_vector)
return std_logic_vector is
      variable result   :    std_logic_vector(a'range);
      alias aa          :    std_logic_vector(a'reverse_range) is a;
      begin
         for i in aa'range loop
            result(i) := aa(i);
            end loop;
            return result;
end;  -- function reverse_any_bus

begin

UART_TXD     	            <= SerDataOut;
Ana_In_Request             <= Ana_In_Request_i;
Dig_In_Request             <= Dig_In_Request_i;
Dig_Out_Request            <= Dig_Out_Request_i;
Version_Name_i             <= Version_Name;
Version_Number_i           <= Version_Number;
Main_Mux_Version_Name_i    <= M & A & I & N & Space & M & U & X & Space & Space &
                              Space & Space & Space & Space & Space & Space & Space & Space &
                              Space & Space & Space & Space & Space & Space & Space &
                              Space & Space & Space & Space & Space & Space;
Main_Mux_Version_Number_i  <= Zero & Zero & Dot & Zero & One & Dot & Zero & Eight;
-- Build message
gen_tx_ser_data : process (CLK_I, RST_I)
  
variable Delay                               : integer range 0 to 50;
variable Request_Data_cnt                    : integer range 0 to 5000001;
variable Real_Time_Clock_Request_200mS_cnt   : integer range 0 to 5;   
variable Real_Time_Clock_Request_50mS_cnt    : integer range 0 to 5;
variable send_data_cnt                       : integer range 0 to 10;
variable wait_cnt_rtc                        : integer range 0 to 50;
variable wait_cnt_all                        : integer range 0 to 100;
variable wait_cnt_ver                        : integer range 0 to 100;
variable analog_data_load                    : integer range 0 to 100;

begin
   if RST_I = '0' then
      Preamble_Data_Array(0)     <= x"a5";
      Preamble_Data_Array(1)     <= x"5a";
      Preamble_Data_Array(2)     <= x"7e";
      data2send                  <= (others => (others => '0'));
      CRC2send                   <= (others => (others => '0'));
      no_of_chars2send           <= 0;
      send_msg                   <= '0';
      Message_done               <= '0';
      Send_100mS_Data            <= '0';    
      Stack_100mS_Data           <= '0';
      Dig_In_Request_i           <= '0';
      Dig_Out_Request_i          <= '0';
      Ana_In_Request_i           <= '0';
      Digital_Output_Ready       <= '0';
      Digital_Input_Ready        <= '0';
      Analog_Input_Ready         <= '0';
      All_Modules_Ready          <= '0';
      All_Modules_Trig           <= '0';
      RTC_Build_Trig_i           <= '0';
      RTC_Build_Trig_Done_i      <= '0';
      All_Data_Build_Trig_i      <= '0';
      All_Data_Build_Trig_Done_i <= '0';
      Ver_Build_Trig_i           <= '0';
      Ver_Build_Trig_Done_i      <= '0';
      Lockout                    <= '0';
      Send_Operation             <= '0';
      Request_Data_cnt           := 0;
      send_data_cnt              := 0;
      analog_data_load           := 0;
      wait_cnt_ver               := 0;
      Request_Data_Strobe        <= '0'; 
      Send_Data_Strobe           <= '0';
      Send_Version_Data_Mess     <= '0';
      Send_Version_Data          <= '0';
      Stack_Version_Data         <= '0';
      Version_Data_Request       <= '0';
      Send_All_Modules           <= '0';
      Send_Version_Data_Ready    <= '0';
      Send_RTC_Mess              <= '0';
      Send_RTC_Data              <= '0';
      Send_RTC_Operation         <= '0';
      Stack_RTC_Data             <= '0';
      Get_RTC                    <= '0';
      Real_Time_Clock_Ready      <= '0';
      RTC_Ready                  <= '0';
      Analog_Input_Load          <= '0';
      Main_Mux_Version_Name      <= (others => '0');
      Main_Mux_Version_Number    <= (others => '0'); 
      Main_Mux_Version_Ready     <= '0';  
      request_send_state         <= Request_Idle;
      report "The version number of Main_Mux is 00.01.08." severity note;      --if Module_Number = X"08" then
   elsif CLK_I'event and CLK_I = '1' then
      
      if Main_Mux_Version_Request = '1' then
         Main_Mux_Version_Ready    <= '1';
         Main_Mux_Version_Name     <= Main_Mux_Version_Name_i;
         Main_Mux_Version_Number   <= Main_Mux_Version_Number_i;  
      else
         Main_Mux_Version_Ready <= '0';
      end if;
      --else   
      --    Main_Mux_Version_Ready <= '0'; 
      --end if; 
    
      case Request_Send_State is
         when Request_Idle =>
            -----------------------------      
            -- Modules Request Generator    
                  --100mS
            -----------------------------
            
            if Real_Time_Clock_Request = '1' then 
               Get_RTC              <= '1';
               if busy = '1' then  
                  busy_latch           <= '1';
               elsif busy = '0' and busy_latch = '1' then 
                  busy_latch           <= '0';
                  Request_Send_State   <= Data_RX;
               elsif busy = '0' then
                  Request_Send_State   <= Data_RX;
               end if;
            elsif Request_Data_cnt = 650_000 then  -- 100 ms Retrieve 0 for 5000_000
               Send_Data_Strobe     <= '1';                  
               Request_Data_cnt     := 0;
               Request_Send_State   <= Data_RX;
            elsif Request_Data_cnt = 640_000 then -- 90 ms Retrieve 0 for 4900_000
               Request_Data_Strobe  <= '1';
               Request_Data_cnt     := Request_Data_cnt + 1;
               Request_Send_State   <= Requests_TX;
            else
               Request_Data_cnt        := Request_Data_cnt + 1;
               Dig_In_Request_i        <= '0';  
               Dig_Out_Request_i       <= '0';  
               Ana_In_Request_i        <= '0';
               Get_RTC                 <= '0';
               Send_All_Modules        <= '0';
               All_Modules_Trig        <= '0';
               Analog_Input_Load       <= '0';
               Real_Time_Clock_Ready   <= '0';
               Request_Send_State      <= Request_Idle;
            end if; 

         when Requests_TX =>
            Dig_In_Request_i     <= '1';  
            Dig_Out_Request_i    <= '1';
            Ana_In_Request_i     <= '1';
            Request_Data_Strobe  <= '0';
            Request_Send_State   <= Request_Idle;
            -----------------------------------      
            -- End of Modules Request Generator    
            -----------------------------------
         when Data_RX =>
            if Send_Data_Strobe = '1' then
               Send_Data_Strobe     <= '0';
               All_Modules_Trig     <= '1';
               Request_Send_State   <= Collect_Data;
            else
               Get_RTC              <= '0';
               Request_Send_State   <= Collect_Data;
            end if;

         when Collect_Data =>

            if RTC_Valid = '1' then
               Real_Time_Clock_Ready   <= '1';
               Time_Data_Array(0)      <= Seconds_out;
               Time_Data_Array(1)      <= Minutes_out;
               Time_Data_Array(2)      <= Hours_out;
               Time_Data_Array(3)      <= Day_out;
               Time_Data_Array(4)      <= Date_out;
               Time_Data_Array(5)      <= Month_Century_out;
               Time_Data_Array(6)      <= Year_out;
               Request_Send_State      <= Request_Idle;
            else
               Real_Time_Clock_Ready   <= '0';
            end if;

      -- Digital Output Incoming Data Validity Generator
            if Digital_Output_Valid = '1' then
               Digital_Output_Ready       <= '1';      -- Latch DO
               Digital_Out_Data_Array(0)  <= Output_Card_1;
               Digital_Out_Data_Array(1)  <= Dig_Out_1_B0;
               Digital_Out_Data_Array(2)  <= Dig_Out_1_B1;
               Digital_Out_Data_Array(3)  <= Dig_Out_1_B2;
               Digital_Out_Data_Array(4)  <= Dig_Out_1_B3;
               Digital_Out_Data_Array(5)  <= Output_Card_2;
               Digital_Out_Data_Array(6)  <= Dig_Out_1_B4;
               Digital_Out_Data_Array(7)  <= Dig_Out_1_B5;
               Digital_Out_Data_Array(8)  <= Dig_Out_1_B6;
               Digital_Out_Data_Array(9)  <= Dig_Out_1_B7;
            end if;   
            
      -- Digital Input Data Validity Generator       
            if Digital_Input_Valid = '1' then
               Digital_Input_Ready        <= '1';       -- Latch DI
               Digital_In_Data_Array(0)   <= Input_Card_1;
               Digital_In_Data_Array(1)   <= Dig_In_1_B0;
               Digital_In_Data_Array(2)   <= Dig_In_1_B1;
               Digital_In_Data_Array(3)   <= Dig_In_1_B2;
               Digital_In_Data_Array(4)   <= Dig_In_1_B3;
               Digital_In_Data_Array(5)   <= Input_Card_2;
               Digital_In_Data_Array(6)   <= Dig_In_1_B4;
               Digital_In_Data_Array(7)   <= Dig_In_1_B5;
               Digital_In_Data_Array(8)   <= Dig_In_1_B6;
               Digital_In_Data_Array(9)   <= Dig_In_1_B7;
            end if; 
               
      -- Analog Input Data Validity Generator
            
            if Analog_Input_Valid = '1' then
               Analog_Input_Load <= '1';        -- Latch AI
            end if;  

            if Analog_Input_Load = '1' then
               if analog_data_load = 100 then
                  analog_data_load     := 0;
                  Analog_Input_Ready   <= '1';        -- Latch AI
               else
                  analog_data_load := analog_data_load + 1;
                  for i in 0 to 95 loop
                     if i = 0 then
                        Analog_In_Data_Array(0) <= Analog_Card_1;
                     elsif i > 0 then
                        Analog_In_Data_Array(i-1) <= Analog_Data((7+((i-1) * 8)) downto (0+((i-1) * 8))); 
                     end if;  
                  end loop;
               end if;
            end if;

      -- Version Data Validity Generator
      if Version_Data_Ready = '1' THEN
         Ver_Build_Trig_i        <= '1';
         Version_Data_Array(0)   <= Version_Name_i(255 downto 248);
         Version_Data_Array(1)   <= Version_Name_i(247 downto 240);
         Version_Data_Array(2)   <= Version_Name_i(239 downto 232);
         Version_Data_Array(3)   <= Version_Name_i(231 downto 224);
         Version_Data_Array(4)   <= Version_Name_i(223 downto 216);
         Version_Data_Array(5)   <= Version_Name_i(215 downto 208);
         Version_Data_Array(6)   <= Version_Name_i(207 downto 200);
         Version_Data_Array(7)   <= Version_Name_i(199 downto 192);
         Version_Data_Array(8)   <= Version_Name_i(191 downto 184);
         Version_Data_Array(9)   <= Version_Name_i(183 downto 176);
         Version_Data_Array(10)  <= Version_Name_i(175 downto 168);
         Version_Data_Array(11)  <= Version_Name_i(167 downto 160);
         Version_Data_Array(12)  <= Version_Name_i(159 downto 152);
         Version_Data_Array(13)  <= Version_Name_i(151 downto 144);
         Version_Data_Array(14)  <= Version_Name_i(143 downto 136);
         Version_Data_Array(15)  <= Version_Name_i(135 downto 128);
         Version_Data_Array(16)  <= Version_Name_i(127 downto 120);
         Version_Data_Array(17)  <= Version_Name_i(119 downto 112);
         Version_Data_Array(18)  <= Version_Name_i(111 downto 104);
         Version_Data_Array(19)  <= Version_Name_i(103 downto 96);
         Version_Data_Array(20)  <= Version_Name_i(95 downto 88);
         Version_Data_Array(21)  <= Version_Name_i(87 downto 80);
         Version_Data_Array(22)  <= Version_Name_i(79 downto 72);    
         Version_Data_Array(23)  <= Version_Name_i(71 downto 64);
         Version_Data_Array(24)  <= Version_Name_i(63 downto 56);
         Version_Data_Array(25)  <= Version_Name_i(55 downto 48);
         Version_Data_Array(26)  <= Version_Name_i(47 downto 40);
         Version_Data_Array(27)  <= Version_Name_i(39 downto 32);
         Version_Data_Array(28)  <= Version_Name_i(31 downto 24);
         Version_Data_Array(29)  <= Version_Name_i(23 downto 16);
         Version_Data_Array(30)  <= Version_Name_i(15 downto 8);
         Version_Data_Array(31)  <= Version_Name_i(7 downto 0);
         Version_Data_Array(32)  <= Version_Number_i(63 downto 56);
         Version_Data_Array(33)  <= Version_Number_i(55 downto 48);
         Version_Data_Array(34)  <= Version_Number_i(47 downto 40);
         Version_Data_Array(35)  <= Version_Number_i(39 downto 32);
         Version_Data_Array(36)  <= Version_Number_i(31 downto 24);
         Version_Data_Array(37)  <= Version_Number_i(23 downto 16);
         Version_Data_Array(38)  <= Version_Number_i(15 downto 8);
         Version_Data_Array(39)  <= Version_Number_i(7 downto 0);
      end if;
  
   -- Main Data Ready Generator          
         if  (Digital_Output_Ready = '1') and (Digital_Input_Ready  = '1')
         and (Analog_Input_Ready = '1')
         then
            All_Modules_Ready    <= '1';
            Digital_Output_Ready <= '0';
            Digital_Input_Ready  <= '0';
            Analog_Input_Ready   <= '0';
            Analog_Input_Load    <= '0';
         end if;   
                     
         if (All_Modules_Ready = '1') and (All_Modules_Trig = '1') then              
            All_Modules_Ready     <= '0';
            All_Modules_Trig      <= '0';
            Send_All_Modules      <= '1';
            Request_Send_State    <= Request_Idle;
         else
            Send_All_Modules      <= '0';
         end if; 
      end case;

      -- Race Condition Management           
         if (Send_All_Modules = '0') and (Version_Data_Ready = '0') and (Real_Time_Clock_Ready = '0') then 
            All_Data_Ready       <= '0';
            Version_Data_Request <= '0';
            RTC_Ready            <= '0';
         elsif (Send_All_Modules = '1') and (Version_Data_Ready = '0') and (Real_Time_Clock_Ready = '0')  then
            All_Data_Ready       <= '1';
            Version_Data_Request <= '0';  
            RTC_Ready            <= '0';
         elsif (Send_All_Modules = '0') and (Version_Data_Ready = '1') and (Real_Time_Clock_Ready = '0') then
            All_Data_Ready       <= '0';
            Version_Data_Request <= '1';
            RTC_Ready            <= '0';
         elsif (Send_All_Modules = '0') and (Version_Data_Ready = '0') and (Real_Time_Clock_Ready = '1') then
            All_Data_Ready       <= '0';
            Version_Data_Request <= '0';
            RTC_Ready            <= '1';
         elsif (Send_All_Modules = '1') and (Version_Data_Ready = '1') and (Real_Time_Clock_Ready = '1') then
            All_Data_Ready       <= '1';
            if Delay = 50 then  
               Delay                := 0;
               Version_Data_Request <= '1';
            elsif Delay = 51 then
               Version_Data_Request <= '0';
            elsif Delay = 100 then
               RTC_Ready   <= '1';
               Delay       := 0;
            elsif Delay = 101 then
               RTC_Ready <= '0';
            else
               Delay     := Delay + 1;  
            end if;   
         else
            All_Data_Ready       <= '0';
            Version_Data_Request <= '0';
            --RTC_Ready            <= '0';
         end if;
            
   -- Timestamp and Stacking
         if All_Data_Ready = '1' then              
            All_Data_Build_Trig_i         <= '1';
         end if; 

         if All_Data_Build_Trig_i = '1' then
            if wait_cnt_all = 100 then
               wait_cnt_all               := 0;
               All_Data_Build_Trig_i      <= '0';
               All_Data_Build_Trig_Done_i <= '1';
            else
               wait_cnt_all      := wait_cnt_all + 1;
               -- Build All Modules Message
               no_of_chars2send  <= 122;
               no_of_chars2snd   <= std_logic_vector(to_unsigned(no_of_chars2send, no_of_chars2snd'length));
               mode_i            <= x"80";
               for i in 0 to 122 loop
                  if i < 3 THEN
                     data2send(i)   <= Preamble_Data_Array(i);
                     CRC2send(i)    <= Preamble_Data_Array(i);
                  elsif (i = 3) then
                     data2send(i)   <= no_of_chars2snd;
                     CRC2send(i)    <= no_of_chars2snd;
                  elsif (i = 4) then
                     data2send(i)   <= mode_i;
                     CRC2send(i)    <= mode_i;
                  elsif (i > 4) and (i < 15) then
                     -- Digital Output Message           
                     data2send(i)   <= Digital_Out_Data_Array(i-5);
                     CRC2send(i)    <= Digital_Out_Data_Array(i-5);
                  elsif (i > 14) and (i < 25) then
                     -- Digital Input Message       
                     data2send(i)   <= Digital_In_Data_Array(i-15);
                     CRC2send(i)    <= Digital_In_Data_Array(i-15);
                  elsif (i > 24) then
                     -- Analog Input Message
                     data2send(i)   <= Analog_In_Data_Array(i-25);
                     CRC2send(i)    <= Analog_In_Data_Array(i-25);
                  end if;
               end loop;
            end if;
         end if;   

         if All_Data_Build_Trig_Done_i = '1' then
            All_Data_Build_Trig_Done_i    <= '0';
            if (Busy = '1') then
               Stack_100mS_Data           <= '1';
               Send_100mS_Data            <= '0';
            else
               Send_100mS_Data            <= '1';
               Stack_100mS_Data           <= '0';
            end if; 
         end if;                        
         
         if Ver_Build_Trig_i = '1' then
            -- Build Version Message
            if wait_cnt_ver = 50 then
               wait_cnt_ver            := 0;
               Ver_Build_Trig_i        <= '0';
               Ver_Build_Trig_Done_i   <= '1';
            else
               wait_cnt_ver      := wait_cnt_ver + 1;
               no_of_chars2send  <= 39;
               no_of_chars2snd   <= std_logic_vector(to_unsigned(no_of_chars2send, no_of_chars2snd'length));
               mode_i            <= x"90";
               for i in 0 to 39 loop
                  if i < 3 THEN
                     data2send(i)   <= Preamble_Data_Array(i);
                     CRC2send(i)    <= Preamble_Data_Array(i);
                  elsif (i = 3) then
                     data2send(i)   <= no_of_chars2snd;
                     CRC2send(i)    <= no_of_chars2snd;
                  elsif (i = 4) then
                     data2send(i)   <= mode_i;
                     CRC2send(i)    <= mode_i;
                  elsif (i > 4) then
                     data2send(i)   <= Version_Data_Array(i);
                     CRC2send(i)    <= Version_Data_Array(i);
                  end if;
               end loop;
            end if;
         end if;

         if RTC_Ready = '1' then
            RTC_Build_Trig_i <= '1';
         end if; 

         if RTC_Build_Trig_i = '1' then
            -- Build RTC Message
            if wait_cnt_rtc = 50 then
               wait_cnt_rtc            := 0;
               RTC_Build_Trig_i        <= '0';
               RTC_Build_Trig_Done_i   <= '1';
            else
               wait_cnt_rtc      := wait_cnt_rtc + 1;
               no_of_chars2send  <= 14;
               no_of_chars2snd   <= std_logic_vector(to_unsigned(no_of_chars2send, no_of_chars2snd'length));
               mode_i            <= x"81";
               for i in 0 to 14 loop
                  if i < 3 THEN
                     data2send(i)   <= Preamble_Data_Array(i);
                     CRC2send(i)    <= Preamble_Data_Array(i);
                  elsif (i = 3) then
                     data2send(i)   <= no_of_chars2snd;
                     CRC2send(i)    <= no_of_chars2snd;
                  elsif (i = 4) then
                     data2send(i) <= mode_i;
                     CRC2send(i) <= mode_i;
                  elsif (i > 4) then
                     data2send(i)   <= Time_Data_Array(i-5);
                     CRC2send(i)    <= Time_Data_Array(i-5);
                  end if;
               end loop;
            end if;
         end if;

         if RTC_Build_Trig_Done_i = '1' then
            RTC_Build_Trig_Done_i   <= '0';
            if (Busy = '1') then
               Stack_RTC_Data <= '1';
               Send_RTC_Mess  <= '0';
            else
               Stack_RTC_Data <= '0';
               Send_RTC_Mess  <= '1';
            end if;
         end if;

         if Ver_Build_Trig_Done_i = '1' then
            Ver_Build_Trig_Done_i   <= '0';
            if (Busy = '1') then
               Stack_Version_Data     <= '1';
               Send_Version_Data_Mess <= '0';
            else
               Send_Version_Data_Mess <= '1';
               Stack_Version_Data     <= '0';
            end if;  
         end if;
           
   -- Send when Not Busy       
         if (Busy = '0') and (Lockout = '0') then
            if Send_100mS_Data = '1' then
               Send_Operation         <= '1';
               Send_100mS_Data        <= '0';
               Lockout                <= '1';
            elsif Send_Version_Data_Mess = '1' then
               Send_Version_Data      <= '1';
               Send_Version_Data_Mess <= '0';
               Lockout                <= '1';   
            elsif Send_RTC_Mess = '1' then
               Send_RTC_Operation   <= '1';
               Send_RTC_Mess        <= '0';
               Lockout              <= '1'; 
            elsif (Send_100mS_Data = '1') and (Stack_100mS_Data = '1') then
               Send_Operation       <= '1';
               Stack_100mS_Data     <= '0';
               Lockout              <= '1';   
            elsif (Send_Version_Data = '1') and (Stack_Version_Data = '1') then
               Send_Version_Data    <= '1';
               Stack_Version_Data   <= '0';
               Lockout              <= '1';     
            elsif (Send_RTC_Data = '1') and (Stack_RTC_Data = '1') then
               Send_RTC_Operation   <= '1';
               Stack_RTC_Data       <= '0';
               Lockout              <= '1';      
            end if;
         else
            Send_100mS_Data         <= '0';
            Send_All_Modules        <= '0';
            Send_RTC_Operation      <= '0';
            All_Data_Ready          <= '0';
         end if;   
         
         if busy = '1' and Lockout = '1' then
            lockout <= '0';
         end if;

-----------------------------------------
-- Operation
-----------------------------------------

      if Send_Operation = '1' then
         Send_100mS_Data  <= '0';
         Send_Operation   <= '0';
         send_msg         <= '1';
      elsif Send_Version_Data = '1' then
         Send_Version_Data <= '0';
         send_msg          <= '1';
      elsif Send_RTC_Operation = '1' then
         Send_RTC_Data        <= '0';
         Send_RTC_Operation   <= '0';
         send_msg             <= '1';
      else
        send_msg        <= '0';
        Message_done    <= '0';
      end if;
              
      if add_crc = '1' then
         data2send(no_of_chars2send - 2) <= CRC_Sum(15 downto 8);
         data2send(no_of_chars2send - 1) <= CRC_Sum(7 downto 0);
      end if;

    end if;
  end process gen_tx_ser_data;

  --Send message out

  uart_tx : process (CLK_I, RST_I)

    variable tx_counter  : integer range 0 to 15;
    variable bit_counter : integer range 0 to 8;
    variable tx_en       : std_logic;
    variable Wait_cnt    : integer range 0 to 50;
  begin
    if RST_I = '0' then
      tx_state      <= idle;
      tx_counter    := 0;
      SerDataOut    <= '1';             --idle
      CRCSerDataOut <= '1';
      bit_counter   := 0;
      tx_en         := '0';
      no_of_chars   <= 0;
      busy          <= '0';
      Busy_Latch    <= '0';
      done          <= '0';
      comms_done    <= '0';
      X             <= (others => '1');
      add_crc       <= '0';
      Wait_cnt      := 0;
      crc16_ready   <= '0';
      SerData_Byte  <= (others => '0');
      flag_WD       <= '0';      
    elsif CLK_I'event and CLK_I = '1' then

      if Baud_Rate_Enable = '1' then  
         tx_en := '1';
      else
         tx_en := '0';
      end if;

      case tx_state is

        when idle =>
          
             done       <= '0';
             comms_done <= '0';
             busy       <= '0';

             if send_msg = '1' then
                tx_state      <= sync;
                busy          <= '1';
                
                bit_counter   := 0;
                CRCSerDataOut <= '1';
                SerDataOut    <= '1';       --idle state on line
             else
                tx_state      <= idle;
             end if;

        when sync =>
             add_crc  <= '0';
             tx_state <= send_start;


        when send_start =>
             if tx_en = '1' then
                SerDataOut    <= '0';       --start bit
                CRCSerDataOut <= '0';
                tx_state      <= send_data;
             end if;

        when send_data =>
             crc16_ready       <= '0';
             if tx_en = '1' then
                if bit_counter = 8 then
                   bit_counter := 0;
                   tx_state      <= send_stop;
                   no_of_chars   <= no_of_chars + 1;
                   SerDataOut    <= '1';     --stop_bit
                   CRCSerDataOut <= '1';
                else
                   SerDataOut    <= data2send(no_of_chars)(bit_counter);
                   CRCSerDataOut <= CRC2send(no_of_chars)(bit_counter);
                   SerData_Byte  <= data2send(no_of_chars);
                   bit_counter   := bit_counter + 1;
                   tx_state      <= CRC_ready;
                   Wait_cnt      := 0;
                end if;
             end if;

        when CRC_ready =>
             if Wait_cnt = 30 then
                crc16_ready <= '1';
                tx_state    <= send_data;
             else
                wait_cnt := wait_cnt + 1;
             end if;

        when send_stop =>
             if tx_en = '1' then
                if no_of_chars = no_of_chars2send then
                   tx_state    <= idle;
                   no_of_chars <= 0;
                   done        <= '1';
                   comms_done  <= '1';
                   busy        <= '0';
                elsif no_of_chars = 3 then
                   tx_state    <= sync;
                   X           <= (others => '1');
                elsif no_of_chars = no_of_chars2send - 2 then
                   tx_state    <= sync;
                   add_crc     <= '1';
                else
                  tx_state    <= sync;
                  comms_done  <= '0';
                end if;
             end if;
        end case;

        if crc16_ready = '1' then
           X(0)  <= CRCSerDataOut xor X(15);   
           X(1)  <= X(0);
           X(2)  <= X(1);
           X(3)  <= X(2);
           X(4)  <= X(3);
           X(5)  <= X(4) xor CRCSerDataOut xor X(15);
           X(6)  <= X(5);
           X(7)  <= X(6);
           X(8)  <= X(7);
           X(9)  <= X(8);
           X(10) <= X(9);
           X(11) <= X(10);
           X(12) <= X(11) xor CRCSerDataOut xor X(15);
           X(13) <= X(12);
           X(14) <= X(13);
           X(15) <= X(14);
        end if;
        CRC_Sum  <= X;
    end if;
  end process uart_tx;


end Arch_DUT;


