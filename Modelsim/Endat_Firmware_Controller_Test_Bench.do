onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 25 {Main Clock and Reset}
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/CLK_I_i
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/RST_I_i
add wave -noupdate -divider -height 30 DeMux
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Demux_1/Dig_Outputs_Ready
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Demux_1/Noise_Diode_Ready
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Demux_1/Time_Stamp_Ready
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Demux_1/Valon_Data_Ready
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Demux_1/Version_Data_Ready
add wave -noupdate -divider -height 30 {Digital Output}
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Output_Handler_1/SPI_Outport_1
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Output_Handler_1/SPI_Outport_2
add wave -noupdate -divider -height 30 {Digital Input}
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Output_Handler_1/SPI_Inport_1
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Output_Handler_1/SPI_Inport_2
add wave -noupdate -divider -height 30 {Analog Input}
add wave -noupdate -radix hexadecimal /a0212_0003_007_rf_controller_test_bench/SPI_Analog_Driver_1/AD_data
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Analog_Driver_1/Address
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Analog_Driver_1/convert
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Analog_Driver_1/CS1
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Analog_Driver_1/CS2
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Analog_Driver_1/CS3
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Analog_Driver_1/CS4
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Analog_Handler_1/CH0
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Analog_Handler_1/CH1
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Analog_Handler_2/CH0
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/SPI_Analog_Handler_2/CH1
add wave -noupdate -divider -height 30 Mux
add wave -noupdate -radix hexadecimal /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Alg_Card1_1
add wave -noupdate -radix hexadecimal /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Alg_Card1_2
add wave -noupdate -radix hexadecimal /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Alg_Card1_3
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/All_Data_Ready
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/All_Modules_Ready
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/All_Modules_Trig
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Ana_In_Request
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Analog_Input_Ready
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Analog_Input_Ready_1
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Analog_Input_Ready_2
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Analog_Input_Ready_bi
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Analog_Input_Ready_mono
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Analog_Input_Valid_1
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Analog_Input_Valid_2
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Dig_In_Request
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Dig_Out_Request
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Digital_Input_Ready
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Digital_Input_Valid
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Digital_Output_Ready
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Digital_Output_Valid
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Send_Operation
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Send_Valon_Data
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Send_Version_Data
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/UART_TXD
add wave -noupdate -radix hexadecimal /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/data2send
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Valon_Data
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Main_Mux_1/Valon_Data_Ready
add wave -noupdate -divider -height 30 {Noise Diode}
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Noise_Diode_1/DBBC_Source
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Noise_Diode_1/Freq_Source
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Noise_Diode_1/Freq_Source_Out
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Noise_Diode_1/Input_Source
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Noise_Diode_1/Noise_Diode_A
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Noise_Diode_1/Noise_Diode_B
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Noise_Diode_1/Noise_Diode_C
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Noise_Diode_1/Noise_Diode_D
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Noise_Diode_1/Noise_Valid
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Noise_Diode_1/Roach_Source
add wave -noupdate -divider -height 30 Valon
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Valon_TX_UASRT_1/UART_TXD
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Valon_RX_UASRT_1/UART_RXD
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Quad_Serial_Driver_1/CS_1_out
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Quad_Serial_Driver_1/CS_2_out
add wave -noupdate /a0212_0003_007_rf_controller_test_bench/Valon_TX_UASRT_1/Valon_Data
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
WaveRestoreCursors {{Cursor 1} {105152766893 ps} 0} {{Cursor 2} {603225450000 ps} 0}
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
WaveRestoreZoom {30373549350 ps} {44779276350 ps}
