onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 25 {Main Clock and Reset}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/CLK_I
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/RST_I
add wave -noupdate -divider {Real Time Clock}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/PPS_in
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Seconds_out
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Minutes_out
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Hours_out
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Day_out
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Date_out
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Month_Century_out
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Year_out
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Ready
add wave -noupdate -divider -height 30 DeMux
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/UART_RXD
add wave -noupdate -divider -height 30 {Digital Output}
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_1
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_2
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_3
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_4
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_5
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_6
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_7
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_8
add wave -noupdate -divider -height 30 {Digital Input}
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_1
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_2
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_3
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_4
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_5
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_6
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_7
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_8
add wave -noupdate -divider -height 30 {Analog Input}
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH1_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH2_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH3_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH4_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH5_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH6_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH7_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH8_o
add wave -noupdate -divider -height 30 Mux
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/UART_TXD
add wave -noupdate -divider -height 30 Endat
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider {SPI I/O Driver}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_In_1/nCS_Output_1
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_In_1/nCS_Output_2
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_In_1/Sclk
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_In_1/Mosi
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_In_1/Miso
add wave -noupdate -divider {SPI Analog Drivers}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/CS1
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/CS2
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/CS3
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/CS4
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/Sclk
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/Mosi
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/Miso
add wave -noupdate -divider {I2C Driver}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Driver_1/sda
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Driver_1/scl
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5892267284 ps} 0} {{Cursor 2} {603225450000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 242
configure wave -valuecolwidth 96
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {14405727 ns}
