
-- DESCRIPTION
-- ===========
-- Decode the Version Message
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use work.txt_util.all;
use ieee.std_logic_UNSIGNED.all;

  entity Version_RX_UASRT is
      generic(
          version_verify_log_file   : string   := "Firmware Version Verification File.txt"
          );
    port (
         Clk                            : in  std_logic;
         nrst                           : in  std_logic;
-- Serial in from RS232                                       
         UART_RXD                       : in  std_logic;
           
-- Data Ready in
         Version_Data_Ready             : in std_logic;  
           
-- Version Data
         Version_Data                   : in std_logic_vector(199 downto 0)
      );

  end Version_RX_UASRT;
  
architecture Arch_DUT of Version_RX_UASRT is

  constant Preamble1         : std_logic_vector(7 downto 0) := X"A5"; 
  constant Preamble2         : std_logic_vector(7 downto 0) := X"5A";
  constant Preamble3         : std_logic_vector(7 downto 0) := X"7E";

 type clock_states is (wait_low,wait_high);
 type rx_states is (rx_idle,wait4start,found_start,get_data,look4end);
 type Ms_sync_states is (idle,sync_state,Wait_sync);

 type cmd_states is (idle, Get_Version, Next_Version_Byte, Check_Version, CRC_check_L, Set_Active, Active,
                     Send_ack, reset_Trigger, Length, pream1,get_Mode, pream2, pream3, branch, CRC_check
                     );
  
   signal clock_state              : clock_states;
   signal cmd_state                : cmd_states;
   signal rx_state                 : rx_states;
   signal Ms_sync_state            : Ms_sync_states;
 
       
-- Serial Data In
   signal SerDataIn              : std_logic;
  
-- Usart Signals
   signal fifo_reset             : std_logic;
   signal fifo_enable            : std_logic;
   signal sync_bit               : std_logic;
   signal count                  : integer range 0 to 127;
   signal Flag_rec               : std_logic; 
   signal q                      : std_logic_vector(7 downto 0);
   signal got_byte               : std_logic;
   signal enable_div_RX          : std_logic;
   signal wd_timer               : std_logic; 
   signal byte_received          : std_logic_vector(7 downto 0);  
 
 -- CRC 16 Signals
   signal CRC_byte_i             : std_logic_vector(15 downto 0);
   signal CRX                    : std_logic_vector(15 downto 0);
   signal CRC_In                 : std_logic_vector(7 downto 0);
   signal CRC_out                : std_logic;
   signal Calculate_CRC          : std_logic;
   signal CRC_reset              : std_logic;
   signal crc_data_bit           : std_logic;
   signal CRCIn_Bit              : std_logic;
   signal Message_Length_i       : std_logic_vector(7 downto 0);

   signal Messag_Length_i        : integer range 0 to 50;
   signal Version_Data_Length    : integer range 0 to 50;
   signal Version_Length         : integer range 0 to 50;
   signal Version_Data_i         : std_logic_vector(199 downto 0);
   signal Set_Version_Data_i     : std_logic_vector(199 downto 0) := x"5246430030322E31372E323031383131323031303534333900";
   signal Header_1_i             : std_logic_vector(7 downto 0);
   signal Header_2_i             : std_logic_vector(7 downto 0);
   signal Header_3_i             : std_logic_vector(7 downto 0);
   signal Mode_i                 : std_logic_vector(7 downto 0);


   file   l_file                : TEXT open write_mode is version_verify_log_file;
   
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
               clock     => Clk,
               enable    => fifo_enable,
               shiftin   => SerDataIn,
               q         => q,
               shiftout  => open 
               );
    
   fifo_reset                     <= not nrst;  
   SerDataIn                      <= UART_RXD;
 
 
 baud_rate_gen_rx: process (Clk, nrst)
   variable sample_div : integer range 0 to 6000;
 begin  
   if nrst = '0' then                    
      enable_div_RX <= '0';
      sample_div    := 27;          -- baud rate to 9600. 20nS clock 5208/16 =325               
-- Clock
   elsif Clk'event and Clk = '1' then   
     if sync_bit = '1' then
        sample_div     := 0;
     end if;
          
     if sample_div     = 27 then   -- baud rate to 115200 with 20MHz  
        sample_div     := 0;
        enable_div_RX  <= '1';
     else
        sample_div := sample_div + 1;
        enable_div_RX  <= '0';
     end if;     
   end if;
 end process baud_rate_gen_rx;

watch_dog: process (Clk, nrst)
    variable cnt : integer range 0 to 20000;
    variable Div_cnt : integer range 0 to 500;
  begin  
    if nrst = '0' then                    
       wd_timer <= '0';    
    elsif Clk'event and Clk = '1' then
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

   
uart_rx: process (Clk, nrst)
  
  variable sample_counter : integer range 0 to 15;
  variable data_bit_cnt : integer range 0 to 7;
  
 begin
   
   if nrst = '0' then                   
      rx_state        <= rx_idle;
      sample_counter  := 0;
      fifo_enable     <= '0';
      data_bit_cnt    := 0;
      byte_received   <= (others => '0');
      got_byte        <= '0';
      count           <= 0;
      sync_bit        <= '0';
      CRC_In          <= X"00";
   elsif Clk'event and Clk = '1' then
     
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

CRC16_Bit: process(Clk, nrst)
      variable data_bit_cnt : integer range 0 to 32;
begin
      if nrst = '0' then 
         crc_Data_bit  <= '0';
         data_bit_cnt  := 0;
         Calculate_CRC <= '0';
         CRCIn_Bit     <= '0';
      elsif Clk'event and Clk = '1' then
            
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
  
CRC16_new: process(Clk, nrst)
begin
      if nrst = '0' then 
         CRX <= (others=> '1');
      elsif Clk'event and Clk = '1' then
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
  
decode_cmd: process (Clk, nrst)

begin  
   if nrst = '0' then                  
      cmd_state                 <= idle;  
      Message_length_i          <= (others=> '0');
      Messag_length_i           <= 0;
      Version_Data_i            <= (others=> '0');
      Header_1_i                <= (others=> '0');
      Header_2_i                <= (others=> '0');
      Header_3_i                <= (others=> '0');
      Version_Data_i            <= (others=> '0');
      CRC_out                   <= '0';
      CRC_byte_i                <= (others=> '0');
    elsif Clk'event and Clk = '1' then
      
       if wd_timer = '1' then          
          cmd_state <= idle;
       end if;

       case cmd_state is
         when idle =>
              Flag_rec                <= '0';
              CRC_reset               <= '0';
              Messag_Length_i         <= 0;
              Version_Length          <= 0;
              Version_Data_Length     <= 0;
              if Version_Data_Ready = '1' then                     
                  cmd_state         <= pream1;
              else
                  cmd_state         <= idle;
              end if; 
              
           when pream1 =>   
              if got_byte = '1' then
                 if byte_received = Preamble1 then    -- Header Byte 0 -- A5
                    Header_1_i    <= byte_received;                                  
                    cmd_state     <= pream2;
                 end if;
              end if;
           
         when pream2 =>
              CRC_reset <= '0';
              if got_byte = '1' then           
                 if byte_received = Preamble2 then     -- Header Byte 1 -- 5A    
                    cmd_state  <= pream3;
                    Header_2_i <= byte_received; 
                    Flag_rec   <= '1';                    
                 else
                    cmd_state <= idle;
                 end if;
              end if;

         when pream3 =>
               CRC_reset <= '0';
               if got_byte = '1' then           
                  if byte_received = Preamble3 then    -- Header Byte 2 -- 7E 
                     cmd_state  <= Length;
                     Header_3_i <= byte_received; 
                     Flag_rec   <= '1';
                     CRC_reset  <= '1';                     
                  else
                     cmd_state  <= idle;
                  end if;
               end if;

         when Length =>
              CRC_reset   <= '0';
              if got_byte = '1' then
                 CRC_out           <= '1';
                 Message_Length_i  <= byte_received;    -- Length Byte 3
                 cmd_state         <= get_Mode;              
            end if;      
                              
-- Header     
         when get_Mode =>             
              CRC_reset <= '0';
              CRC_out   <= '0';
              if got_byte = '1' then
                 CRC_out         <= '1';
                 Mode_i          <= byte_received;
                 cmd_state       <= branch;
                 Messag_Length_i <= conv_integer(Message_Length_i);
              end if;
                        
            when branch =>
                cmd_state       <= Get_Version;
                Version_Length  <= (Messag_Length_i - 7);
              
-------------------------------------------------------------------------------
-- Version - From Colin to Us Mode "90"
-------------------------------------------------------------------------------
              
               when Get_Version =>
                   CRC_out           <= '0';
                   Version_Length      <= (Messag_Length_i - 7);
                   if got_byte = '1' then
                       CRC_out                        <= '1';
                       Version_Data_i(199-(Version_Data_Length * 8) downto 
                                    192-(Version_Data_Length * 8)) <= byte_received;    
                       cmd_state                      <= Next_Version_Byte;
                   end if;

               when Next_Version_Byte =>
                   Version_Data_Length <= (Version_Data_Length + 1);
                   cmd_state           <= Check_Version;

               when Check_Version =>
                   if (Version_Data_Length = Version_Length) then
                       cmd_state      <= CRC_check;
                   else  
                       cmd_state      <= Get_Version;
                   end if;
      
-- CRC checker
         when CRC_check =>
              Version_Data_Length         <= 0;
              Version_Length              <= 0;
              CRC_out <= '0';
              if got_byte = '1' then
                 CRC_byte_i(15 downto 8) <= byte_received;
                 cmd_state               <= CRC_check_L;                   
              end if;
                 
         when CRC_check_L =>
              CRC_out <= '0';
              if got_byte = '1' then
                 CRC_byte_i(7 downto 0)  <= byte_received;
                 cmd_state               <= Set_Active;                    
              end if;
                  
         when Set_Active =>
              CRC_out <= '0';
              if (CRC_byte_i = CRX) then
                 cmd_state  <= Send_ack;
                 report "Version CRCs check passed." severity note;
             else   
                 report "CRCs did not match. Message discarded." severity error;
                 cmd_state <= Idle;                      
              end if;   

          when Send_ack =>
              if Set_Version_Data_i = Version_Data_i then    
                  print(l_file, "# ------------Firmware Verification Log File -----------------");
                  print(l_file, "#-------------------------------------------------------------#");
                  print(l_file, " The firmware version build received is "& hstr(Version_Data_i) & "h");
                  print(l_file, " The received firmware version matches the stored Firmware Version");
                  report "Firmware Verification File created in the Modelsim folder" severity note;
                   cmd_state <= Active;
              else
                  print(l_file, "# ------------Firmware Verification Log File -----------------");
                  print(l_file, "#-------------------------------------------------------------#");
                  print(l_file, " The firmware version build received is "& hstr(Version_Data_i) & "h");
                  print(l_file, " The received firmware version does not match the stored Firmware Version");
                --  report "Firmware Verification File created in the Modelsim folder" severity failure;
                      cmd_state <= Active;
              end if;
                
            when Active =>                     
                cmd_state           <= reset_trigger;

            
            when reset_trigger =>
                cmd_state           <= idle;
                
        end case;              
   end if;
 end process decode_cmd;
      
  
end Arch_DUT;

