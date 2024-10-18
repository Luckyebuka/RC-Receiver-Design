transcript off
#stop previous simulations
quit -sim	

# select a directory for creation of the work directory
cd {C:\ECE_501\Franklin\Design\Sequential_circuit\ART_Receiver}
vlib work
vmap work work

# compile the program and test-bench files
vcom +acc ../../Sequential_Logic/sim_mem_init/sim_mem_init.vhd
vcom +acc ../UART_transmitter/tUART.vhd
vcom +acc rUART.vhd
vcom +acc test_rUART.vhd

# initializing the simulation window and adding waves to the simulation window
vsim test_rUART
add wave sim:/test_rUART/recv_under_test/*
add wave sim:/test_rUART/dev_to_test/*
 
# define simulation time
run 5248210 ns
# zoom out
wave zoom full