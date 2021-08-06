onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 25 {Main Clock and Reset}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/CLK_I
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/RST_I
add wave -noupdate -divider {Real Time Clock Handler}
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/data_read
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/ack_error
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/initialation_Status
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Slave_Address_Out
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Slave_read_nWrite
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Slave_Data_Out
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Get_Sample
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Seconds_in
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Minutes_in
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Hours_in
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Day_in
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Date_in
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Month_Century_in
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Year_in
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Write_RTC
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Seconds_out
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Minutes_out
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Hours_out
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Day_out
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Date_out
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Month_Century_out
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Year_out
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_Handler_1/Ready
add wave -noupdate -divider {RTC Testbench}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/I2C_Test_State
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Test_I2C_Config_State
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Test_I2C_Read_State
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Counters_State
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Seconds_TestData_i
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/data_test/Cycle_Count
add wave -noupdate -divider -height 30 DeMux
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/UART_RXD
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/Dig_Outputs_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/SET_Timer
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/byte_received
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/byte_received
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/CRC_byte_i
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/CRX
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/cmd_state
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
add wave -noupdate -divider -height 30 Endat
add wave -noupdate -divider -height 30 Mux
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/UART_TXD
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/no_of_chars2snd
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/no_of_chars2send
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/data2send
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/request_send_state
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
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/All_Modules_Trig
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/All_Modules_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_All_Modules
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/All_Data_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_100mS_Data
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_Operation
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Request_Data_Strobe
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Send_Data_Strobe
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/All_Data_Build_Trig_i
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/All_Data_Build_Trig_Done_i
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/RTC_Valid
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/RTC_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Real_Time_Clock_Ready
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Get_RTC
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/RTC_Build_Trig_i
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
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/busy
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Lockout
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Time_Data_Array
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/SET_Timer
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/gen_tx_ser_data/wait_cnt_rtc
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
WaveRestoreCursors {{Cursor 1} {14589590642 ps} 0} {{Cursor 2} {44713934771 ps} 0}
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
WaveRestoreZoom {0 ps} {36545859 ns}
