LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY Version_Reg IS
    PORT (
        CLK_I				: IN STD_LOGIC;
        RST_I				: IN STD_LOGIC;
        Version_Timestamp	: OUT STD_LOGIC_VECTOR(111  downto 0)
    );
END Version_Reg;
ARCHITECTURE rtl OF Version_Reg IS
    SIGNAL Version_Timestamp_i :  STD_LOGIC_VECTOR(111  downto 0);
BEGIN
  Version_Timestamp <= Version_Timestamp_i;
 PROCESS (CLK_I,RST_I)
  BEGIN
    IF (RST_I='0') THEN
      Version_Timestamp_i   <=X"0000000000000000000000000000";
    ELSIF rising_edge (CLK_I) THEN
      Version_Timestamp_i <= X"3230323130353237313532373237";
    END IF;
  END PROCESS;
END rtl;
