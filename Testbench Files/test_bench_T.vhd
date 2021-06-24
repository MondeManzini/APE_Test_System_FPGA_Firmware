-- $Id$
-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- This file contains some type and constant declarations, functions and
-- procedures which make up a tester module for use on a testbench suitable
-- for testing code.
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_arith.all;


entity test_bench_T is

  generic (
    Vec_Width  : positive := 4;
    ClkPer     : time     := 20 ns;
    StimuFile  : string   := "data.txt";
    ResultFile : string   := "results.txt");

  port (
    oVec : out std_logic_vector(Vec_Width-1 downto 0);
    oClk : out std_logic;
    iVec : in  std_logic_vector(3 downto 0));

end test_bench_T;

architecture Archtest_bench_T of test_bench_T is

procedure SkipWhite(variable Lp : inout line) is
         variable vCh : character;
begin
   while (Lp(Lp'left) = ' ') or (Lp(Lp'left) = HT) loop
      read(Lp, vCh);
   end loop;
end SkipWhite;

type tCharToStdLogic is array(character) of std_logic;
constant ToStdLogic : tCharToStdLogic := (
  'U' => 'U',
  'X' => 'X',
  '0' => '0',
  '1' => '1',
  'Z' => 'Z',  
  'W' => 'W',
  'L' => 'L',
  'H' => 'H',
  '-' => '-',
  others => 'X');

type tStdLogicToChar is array(std_logic) of character;
constant ToChar : tStdLogicToChar := (
  'U' => 'U',
  'X' => 'X',
  '0' => '0',
  '1' => '1',
  'Z' => 'Z',  
  'W' => 'W',
  'L' => 'L',
  'H' => 'H',
  '-' => '-');

function StringToSLV(sS : string) return std_logic_vector is
   variable vResult : std_logic_vector(sS'length-1 downto 0);
   variable vJ : integer;
begin
   vJ := sS'length - 1;
   for I in sS'range loop
      vResult(vJ) := ToStdLogic(sS(I));
      vJ := vJ - 1;
   end loop;  -- I
   return vResult;
end StringToSLV;

function StringToSigned(sS : string) return signed is
   variable vResult : signed(sS'length-1 downto 0);
   variable vJ : integer;
begin
   vJ := sS'length - 1;
   for I in sS'range loop
      vResult(vJ) := ToStdLogic(sS(I));
      vJ := vJ - 1;
   end loop;  -- I
   return vResult;
end StringToSigned;

function SLVToString(sVec : std_logic_vector) return string is
  alias aVec : std_logic_vector(1 to sVec'length) is sVec;
  variable vResult : string(aVec'range);
begin
  for I in aVec'range loop
    vResult(i) := ToChar(aVec(i));
  end loop;  -- I
  return vResult;
end SLVToString;


begin   -- architecture
  
  Gen_Clock: process
  begin
    oClk <= '0', '1' after ClkPer/2;
    wait for ClkPer;
  end process Gen_Clock;

  Reading: process
    file Vectors : text open read_mode is StimuFile;  -- '93
    variable vL : line;
    variable vFirstChar : character := '#';
    variable vDataInStr : string(1 to Vec_Width) := (others => '0');
    
  begin
    while not endfile(Vectors) loop
      readline(Vectors, vL);
      if (vL /= NULL) and (vL'length > 0) then
        if (vL(vL'left) /= '#') then
          SkipWhite(vL);
          read(vL, vDataInStr);
          oVec <= StringToSLV(vDataInStr);
          wait for ClkPer;        -- wait for BitClk period
        end if;
      end if;
    end loop; -- while not endfile
    wait;
  end process Reading;


  Writing: process
    file Results : text open write_mode is ResultFile;  -- '93
    variable vL : line;    
 begin
   write(vL, SLVToString(iVec));
   writeline(Results, vL);
   wait for ClkPer;        -- wait for BitClk period
   -- wait;
  end process Writing;

  
end Archtest_bench_T;
