-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- Kutunse SPI Addressable Port for AD7888 ADC
--
-- The firmware performs the following functions:
--
-- IConfiguration of the device.
-- The user can read the channels at any time, the data is only valid for
-- The method would be to place the address in the ADR_I register and issue a WE_
-- I signal for one ckl cycle only,one clock later the DAT_O will have the four
-- channel As below.
--
-- Signals and registers
-- Bit_Rate_Enable:  this signal is used for the 2Mhz clock for the SPI driver
--
-- Written by  : Raphael van Rensburg
-- Tested      : 13/02/2012 Simulation only - Initialiation. SPI read and writes,
--               data
--             : Test do file is SPI_Output.do
-- Last update : 14/02/2012 - Initial release  Version 1.0
-- Edited By   : Glen Taylor
--             : 28/06/2013 - Removed Test LED signal
--                            Commented the SPI_data_o as this is not used in
--                            this module, but should you required this module
--                            to be an I/O remove the commented three line and add the
--                            data out to the Entity.
-- Edited By   : Glen Taylor and Monde Manzini
--             : 26/05/2016 - Aadded EnableRateGenerator
--                          - Added Delay Timer
--                          - Fixed the header above
--                          - Removed Data_Out_Ready - not anywhere else
--                          - Top Level Data Ready comes from Handler to Mux 
-- Tested      : 26/05/2016 Simulation only - ????????
--             : Test do file is ????Monde to Add????.do
-- Outstanding : None
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity SPI_IO_Driver is

  port (
    -- General Signals
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
 -- Version Control
       Module_Number                 : in  std_logic_vector(7 downto 0);
       SPI_IO_Driver_Version_Request : in  std_logic;
       SPI_IO_Driver_Version_Name    : out std_logic_vector(255 downto 0); 
       SPI_IO_Driver_Version_Number  : out std_logic_vector(63 downto 0);
       SPI_IO_Driver_Version_Ready   : out std_logic  
       ); 
  
end    SPI_IO_Driver;

architecture Arch_DUT of SPI_IO_Driver is
   
  type SPI_Drive_states is (idle,CS_on,FE_1,RE_1,Cycle_cnt,CS_off,Last_Sclk);
  
  signal SPI_Drive_state       : SPI_Drive_states;  

  signal EnableRateGenarator   : std_logic;
  signal Start_Byte_Conversion : std_logic;
  signal Bit_Rate_Enable       : std_logic;
  signal SPI_data_o            : std_logic_vector(15 downto 0);-- Only for reading inputs
  signal SPI_data_i            : std_logic_vector(15 downto 0);
  signal Load_i                : std_logic;
  signal Write_Data            : std_logic;
  signal ncs                   : std_logic;  
 
--------------
-- Ascii Codes
--------------   
constant A        : std_logic_vector(7 downto 0) := X"41";
constant B        : std_logic_vector(7 downto 0) := X"42";
constant C        : std_logic_vector(7 downto 0) := X"43";
constant D        : std_logic_vector(7 downto 0) := X"44";
constant E        : std_logic_vector(7 downto 0) := X"45";
constant F        : std_logic_vector(7 downto 0) := X"46";
constant G        : std_logic_vector(7 downto 0) := X"47";
constant H        : std_logic_vector(7 downto 0) := X"48";
constant I        : std_logic_vector(7 downto 0) := X"49";
constant J        : std_logic_vector(7 downto 0) := X"4A";
constant K        : std_logic_vector(7 downto 0) := X"4B";
constant L        : std_logic_vector(7 downto 0) := X"4C";
constant M        : std_logic_vector(7 downto 0) := X"4D";
constant N        : std_logic_vector(7 downto 0) := X"4E";
constant O        : std_logic_vector(7 downto 0) := X"4F";
constant P        : std_logic_vector(7 downto 0) := X"50";
constant Q        : std_logic_vector(7 downto 0) := X"51";
constant R        : std_logic_vector(7 downto 0) := X"52";
constant S        : std_logic_vector(7 downto 0) := X"53";
constant T        : std_logic_vector(7 downto 0) := X"54";
constant U        : std_logic_vector(7 downto 0) := X"55";
constant V        : std_logic_vector(7 downto 0) := X"56";
constant W        : std_logic_vector(7 downto 0) := X"57";
constant X        : std_logic_vector(7 downto 0) := X"58";
constant Y        : std_logic_vector(7 downto 0) := X"59";
constant Z        : std_logic_vector(7 downto 0) := X"5A";
constant Space    : std_logic_vector(7 downto 0) := X"20";
constant Dot      : std_logic_vector(7 downto 0) := X"2E";

constant Zero     : std_logic_vector(7 downto 0) := X"30";
constant One      : std_logic_vector(7 downto 0) := X"31";
constant Two      : std_logic_vector(7 downto 0) := X"32";
constant Three    : std_logic_vector(7 downto 0) := X"33";
constant Four     : std_logic_vector(7 downto 0) := X"34";
constant Five     : std_logic_vector(7 downto 0) := X"35";
constant Six      : std_logic_vector(7 downto 0) := X"36";
constant Seven    : std_logic_vector(7 downto 0) := X"37";
constant Eight    : std_logic_vector(7 downto 0) := X"38";
constant Nine     : std_logic_vector(7 downto 0) := X"39";

signal SPI_IO_Driver_Version_Name_i   : std_logic_vector(255 downto 0); 
signal SPI_IO_Driver_Version_Number_i : std_logic_vector(63 downto 0); 
    
    begin

    SPI_Inport <=  SPI_data_o;
      
    SPI_Card_Driver: process (CLK_I, RST_I)
    begin 
      if RST_I = '0' then 
         nCS_Output_1 <= '1';
         nCS_Output_2 <= '1';
         SPI_data_i   <= X"0000";
              report "The version number of SPI_In_Output is 1.1." severity note;  
      elsif CLK_I'event and CLK_I = '1' then
        
         if Data_In_Ready = '1' then
            SPI_data_i    <= SPI_Outport;  
            Load_i        <= '1';
         else
            Load_i        <= '0';
         end if;
         
         if Card_Select = '0' then
            nCS_Output_1 <= nCS;
         elsif Card_Select = '1' then     
            nCS_Output_2 <= nCS;
         end if;
         
      end if;
    end process SPI_Card_Driver;
           
 
-- SPI driver read all 8 channel automatically
    SPI_Driver: process (CLK_I, RST_I)
      variable bit_cnt       : integer range 0 to 1000;
      variable bit_number    : integer range 0 to 16;
      variable byte_number   : integer range 0 to 9;
      variable Device_number : integer range 0 to 4;
      variable Delay_Timer   : integer range 0 to 100;      
    begin
      if RST_I = '0' then 
         bit_cnt                        := 0;
         bit_number                     := 16;       
         Bit_Rate_Enable                <= '0';
         Sclk                           <= '1'; 
         nCS                            <= '1';
         MOSI                           <= 'Z';                  
         SPI_data_o                     <= (others => '0');  -- Only for reading inputs
         Data_Out_Ready                 <= '0';                                           -- 
         EnableRateGenarator            <= '0';
         busy                           <= '0';
         start_byte_conversion          <= '0';
         Delay_Timer                    := 0;
         Write_Data                     <= '0';
         SPI_IO_Driver_Version_Name     <= (others => '0');
         SPI_IO_Driver_Version_Name_i   <= (others => '0');
         SPI_IO_Driver_Version_Number   <= (others => '0'); 
         SPI_IO_Driver_Version_Number_i <= (others => '0');
         SPI_IO_Driver_Version_Ready    <= '0'; 
      elsif CLK_I'event and CLK_I = '1' then

         SPI_IO_Driver_Version_Name_i    <= S & P & I & Space & I & O & Space & D & R & I & V & E & R &
                                            Space & Space & Space & Space & Space & Space & Space & 
                                            Space & Space & Space & Space & Space & Space & Space &
                                            Space & Space & Space & Space & Space;
         SPI_IO_Driver_Version_Number_i  <= Zero & Zero & Dot & Zero & One  & Dot & Zero & Two;

         if Module_Number = X"01" then
            if SPI_IO_Driver_Version_Request = '1' then
               SPI_IO_Driver_Version_Ready   <= '1';
               SPI_IO_Driver_Version_Name    <= SPI_IO_Driver_Version_Name_i;
               SPI_IO_Driver_Version_Number  <= SPI_IO_Driver_Version_Number_i;  
            else
               SPI_IO_Driver_Version_Ready <= '0';
            end if;
         else   
               SPI_IO_Driver_Version_Ready <= '0'; 
         end if; 

-- Bit clock 50MHz to 2MHz 50MHz = 20 nSec 2MHz = 500 nSEC 500/20 = 25
         if EnableRateGenarator = '1' then
            if bit_cnt = 100 then
               Bit_Rate_Enable    <= '1';
               bit_cnt            := 0;
            elsif bit_cnt = 20 then
               Write_Data         <= '1';
               bit_cnt            := bit_cnt + 1;
            else
               Write_Data         <= '0';
               Bit_Rate_Enable    <= '0';
               bit_cnt            := bit_cnt + 1;
            end if;   
         end if;
        
-- SPI Driver State Machine
         case SPI_Drive_State is
          when idle =>
               Sclk                   <= '1'; 
               nCS                    <= '1';            
               MOSI                   <= '0'; -- insert Read  bit 15
               if Load_i = '1' then
                  Sclk                <= '0';
                  bit_cnt             := 0;
                  EnableRateGenarator <= '1';
                  busy                <= '1';
                  SPI_Drive_State     <= CS_on;
               end if;
                 
-- Chip Sellect assertion               
          when CS_on =>               
               if Bit_Rate_Enable = '1' then                  
                  bit_number          := 16;
                  SPI_Drive_State     <= FE_1;
               elsif Write_Data = '1' then
                  nCS                 <= '0';   
               else
                  SPI_Drive_State     <= CS_on;   
               end if;
-- Falling edge genaration
          when FE_1 =>
               Sclk                  <= '0';             
               if Bit_Rate_Enable = '1' then                
                  SPI_Drive_State    <= RE_1;                 
               elsif Write_Data = '1'  then                 
                  MOSI               <= SPI_data_i(bit_number - 1);
               else
                  SPI_Drive_State    <= FE_1;   
               end if;
-- Rising edge genaration
          when RE_1 =>
               Sclk                  <= '1';              
               if Bit_Rate_Enable = '1' then                                                      
                  SPI_Drive_State           <= Cycle_cnt;
               elsif Write_Data = '1' then
                  SPI_data_o(bit_number-1)  <= Miso;    -- Only for reading inputs
                  SPI_Drive_State           <= RE_1;
               else
                  SPI_Drive_State           <= RE_1;   
               end if;
--Cycle counter for testing number of Bit send and recieved
          when Cycle_cnt =>
               bit_number := bit_number - 1;
               if bit_number = 0  then
                  SPI_Drive_State          <= CS_off;
                  Data_Out_Ready           <= '1';
               else
                  SPI_Drive_State          <= FE_1;
               end if;
-- Chip Sellect assertion               
          when CS_off =>
               Data_Out_Ready      <= '0';
               nCS                 <= '1';
               busy                <= '0';
               EnableRateGenarator <= '0';
               SPI_Drive_State     <= Last_Sclk;
               
          when Last_Sclk =>
               if Delay_Timer = 80 then
                  Delay_Timer     := 0;
                  SPI_Drive_State <= idle;
               elsif Delay_Timer = 20 then
                  Sclk        <= '0';
                  Delay_Timer := Delay_Timer + 1;
               else
                  Delay_Timer := Delay_Timer + 1;
               end if;
               
          when others =>
               busy               <= '0';
               SPI_Drive_State    <= idle;  
         end case;    
      end if;
    end process SPI_Driver;
      
  end Arch_DUT;

