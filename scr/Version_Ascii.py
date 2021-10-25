#import fpyga
#from fpyga import *
# from . import scr
import tkinter
# from . import Main_Mux

# Key-Value Pairs
ascii_lookup = {
    '0x41':   'A',
    '0x42':   'B',
    '0x43':   'C', 
    '0x44':   'D', 
    '0x45':   'E',
    '0x46':   'F', 
    '0x47':   'G', 
    '0x48':   'H', 
    '0x49':   'I', 
    '0x4a':   'J', 
    '0x4b':   'K', 
    '0x4c':   'L', 
    '0x4d':   'M', 
    '0x4e':   'N', 
    '0x4f':   'O', 
    '0x50':   'P', 
    '0x51':   'Q', 
    '0x52':   'R', 
    '0x53':   'S', 
    '0x54':   'T', 
    '0x55':   'U', 
    '0x56':   'V', 
    '0x57':   'W', 
    '0x58':   'Y', 
    '0x59':   'Z', 
    '0x20':   'Space', 
    '0x0e':   'Dot' 
    }

# print(Main_Mux_Version_Name)
for key,val in ascii_lookup:
    print(key, val)

#tcl_intrpr = tkinter.Tcl()
#res = tcl_intrpr.eval('expr 12+23')
#print(res)


#res = tcl_intrpr.call('expr', '123')
#print(res)


#res = tcl.intrpr.eval(timestamp)
#print(res)


""" 
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
constant eX       : std_logic_vector(7 downto 0) := X"58";
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

constant Space    : std_logic_vector(7 downto 0) := X"20";
constant Dot      : std_logic_vector(7 downto 0) := X"2E";
"""