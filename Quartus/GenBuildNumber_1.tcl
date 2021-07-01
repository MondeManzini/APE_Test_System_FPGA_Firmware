# Generate timestamp of current time in format:
# 		YYYY 	- year (e.g. 2018)
#		mm		- month (e.g. 10)
#		dd		- day (e.g. 22)
#		HH		- hour (e.g. 10)
#		MM		- minute (e.g. 28)
#		SS		-	second (e.g. 45)
set timestamp [clock format [clock seconds] -format {%Y%m%d%H%M%S}]
# Write the timestamp as a Hexadecimal for ASCII character
binary scan $timestamp "H*" out

# If the script gets here, there were no errors.
proc generate_vhdl { hex_value } {

    set num_digits [string length $hex_value]
    set bit_width [expr { 4 * $num_digits } ]
    set high_index [expr { $bit_width - 1 } ]
    set reset_value [string repeat "0" $num_digits]

    if { [catch {
        set fh [open "Version_Reg.vhd" w ]
        puts $fh "LIBRARY ieee;\nUSE ieee.std_logic_1164.ALL;"
        puts $fh "ENTITY Version_Reg IS"
        puts $fh "    PORT ("
        puts $fh "        CLK_I				: IN STD_LOGIC;"
        puts $fh "        RST_I				: IN STD_LOGIC;"
        puts $fh "        Version_Timestamp	: OUT STD_LOGIC_VECTOR(${high_index} \ downto 0)"
        puts $fh "    );"
        puts $fh "END Version_Reg;"
        puts $fh "ARCHITECTURE rtl OF Version_Reg IS"
        puts $fh "    SIGNAL Version_Timestamp_i :  STD_LOGIC_VECTOR(${high_index} \ downto 0);"
        puts $fh "BEGIN"
		puts $fh "  Version_Timestamp <= Version_Timestamp_i;"
        puts $fh " PROCESS (CLK_I,RST_I)"
        puts $fh "  BEGIN"
        puts $fh "    IF (RST_I='0') THEN"
        puts $fh "      Version_Timestamp_i   <=X\"${reset_value}\";"
        puts $fh "    ELSIF rising_edge (CLK_I) THEN"
        puts $fh "      Version_Timestamp_i <= X\"${hex_value}\";"        
        puts $fh "    END IF;"
        puts $fh "  END PROCESS;"
        puts $fh "END rtl;"
        close $fh
    } res ] } {
        return -code error $res
    } else {
        return 1
    }

}


                              set timestamp_b [clock format [clock seconds] -format {%Y %m %d %H %M %S}]


    post_message -type info " -------------------------- Compilation Notes --------------------------\n

                              $timestamp_b Monde Manzini
                              Version_Reg VHDL file generated succesfully and stored at \n
                              https://github.com/MondeManzini/APE_Test_System_FPGA_Firmware/tree/master/Quartus\n
                              1. Please make sure the version of the top-level is updated.
                              2. Please make sure all .vhd files are checked in in github."


# Store Hexadecimal values in VHDL file
if { [catch { generate_vhdl $out } res] } {
    post_message -type error "Couldn't generate VHDL file\n$res"
}

  