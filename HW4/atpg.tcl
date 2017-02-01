#####################
# Read Design & Library
#####################
read_netlist DPA_dft.v
read_netlist /home/raid2_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v

#####################
# Build Model
#####################
run_build_model DPA

#####################
# View violation
#####################
report violations -all

#####################
# DRC
#####################
run_drc DPA_dft.spf

#####################
# Set fault list
#####################
set_faults -model stuck
add_faults -all

#####################
# Run ATPG
#####################
set_atpg -abort_limit 100 -merge high
run_atpg -auto_compression

#####################
# Write Patterns
#####################
write_patterns DPA_ATPG.wgl -format wgl
write_patterns DPA_ATPG.stil -format stil
write_patterns DPA_ATPG_tb.v -format verilog
