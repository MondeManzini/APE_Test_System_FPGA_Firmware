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
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/request_send_state
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/gen_tx_ser_data/Request_Data_cnt
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/gen_tx_ser_data/Real_Time_Clock_Request_200mS_cnt
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/gen_tx_ser_data/Real_Time_Clock_Request_50mS_cnt
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Ana_In_Request_i
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Dig_In_Request_i
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Dig_Out_Request_i
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/Input_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/Input_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Digital_Output_Valid
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Digital_Input_Valid
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Analog_Input_Valid
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Digital_Output_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Analog_Input_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Digital_Input_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/All_Modules_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/All_Modules_Trig
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_100mS_Data
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_All_Modules
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/All_Data_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Request_Data_Strobe
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_Data_Strobe
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/RTC_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_Version_Data_Mess
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_Version_Data_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_Version_Data
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Stack_Version_Data
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Version_Data_Request
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_RTC_Mess
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_RTC_Operation
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Stack_RTC_Data
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Get_RTC
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_RTC_Data
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Real_Time_Clock_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Version_Data_Ready
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
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Driver_1/scl
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Driver_1/sda
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13297930000 ps} 0} {{Cursor 2} {25683712252 ps} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {0 ps} {55052067 ns}
