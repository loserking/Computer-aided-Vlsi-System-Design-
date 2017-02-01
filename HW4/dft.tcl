#####################
# Read Design
#####################
read_verilog DPA_syn.v
current_design DPA

#####################
# Link design
#####################
link
check_design

#####################
# Set design constraints 
#####################
source ./constraints.tcl

#####################
# Report design constraint violations
#####################
report_constraint -all_violators

#####################
# Pre-Scan Area/Timing/Power report
#####################
report_area > DPA_syn.area_rpt
report_timing > DPA_syn.timing_rpt
report_power > DPA_syn.power_rpt

#####################
# Set test timing
#####################
set test_default_delay 0
set test_default_bidir_delay 0
set test_default_strobe 40
set test_default_period 100

#####################
# Select scan style
#####################
set test_default_scan_style multiplexed_flip_flop

####################
# Create test protocol
####################
#create_test_protocol -infer_clock -infer_async
set_dft_signal -view existing_dft -type ScanClock -timing [list 45 55] -port clk
set_dft_signal -view existing_dft -type Reset -port reset -active_state 0
create_test_protocol

####################
# Report design constraint violations
#####################
report_constraint -all_violators

####################
# Pre-scan test design rule checking
####################
dft_drc

####################
# Set scan architecture
####################
set_scan_configuration -chain_count 1

#####################
# Preview scan chain 
#####################
preview_dft

#####################
# Build scan chain 
#####################
insert_dft

####################
# Report design constraint violations
####################
report_constraint -all_violators

####################
# Post-scan test design rule checking
####################
dft_drc

####################
# Report scan
####################
report_scan_path -view existing -chain all > DPA_dft.scan_path
report_scan_path -view existing -cell all > DPA_dft.scan_cell

####################
# Post-Scan Area/Timing/Power report
####################
report_area > DPA_dft.area_rpt
report_timing > DPA_dft.timing_rpt
report_power > DPA_dft.power_rpt

####################
# Write test protocol
####################
write_test_protocol -output DPA_syn_dft.spf

####################
# Write design
####################
write -hierarchy -format verilog -output DPA_dft.v
write -hierarchy -format ddc -output DPA_dft.ddc

####################
# Write SDF file
####################
write_sdf -version 2.1 -context verilog DPA_dft.sdf
