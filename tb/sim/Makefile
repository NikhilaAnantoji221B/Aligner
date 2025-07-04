# Makefile for compiling and running simulation using Mentor QuestaSim

# File locations
RTL_DIR = ../../rtl
TB_TOP_DIR = ../top

# File list
TOP_SRCS = $(RTL_DIR)/design.sv $(TB_TOP_DIR)/testbench.sv
#########################################################
# # Test and UVM options                                #
# # Tests available                                     #
# To run a specific test use the syntac below           #
# make run TESTNAME=<cfs_algn_md_tests_random_traffic>
#
# Use the below command to run with gui and view waveforms
# make grun TESTNAME=<cfs_algn_md_tests_random_traffic>  #
#########################################################
# ###########################
#cfs_algn_apb_tests_mapped_unmapped
#cfs_algn_md_tests_random_traffic
#cfs_algn_md_tests_cnt_drop
#cfs_algn_apb_tests_3_1_1
#cfs_algn_apb_tests_3_1_2
#cfs_algn_apb_tests_3_1_3
#cfs_algn_apb_tests_3_1_4
#cfs_algn_apb_tests_3_1_5
#cfs_algn_md_tests_3_2_1
# ###########################
# Default test if none specified
DEFAULT_TEST = cfs_algn_test_random
TESTNAME ?= $(DEFAULT_TEST)

# UVM options with dynamic test name and random seed
UVM_ARGS = +UVM_TESTNAME=$(TESTNAME) +UVM_MAX_QUIT_COUNT=1 +access +rw -f messages.f -sv_seed random 

# Simulation libraries
WORKLIB = work

# Log files
COMP_LOG = compile.log
SIM_LOG = sim.log
TRANSCRIPT = transcript

# Default target
all: comp run

# Compile target
comp:
	@echo "[Compiling...]" | tee $(COMP_LOG)
	@rm -rf $(WORKLIB)
	@vlib $(WORKLIB) | tee -a $(COMP_LOG)
	@vmap $(WORKLIB) $(WORKLIB) | tee -a $(COMP_LOG)
	@vlog -sv -cover bcest -work $(WORKLIB) $(TOP_SRCS) +acc +define+QUESTA +incdir+$(RTL_DIR) +incdir+$(TB_TOP_DIR) | tee -a $(COMP_LOG) | tee -a $(TRANSCRIPT)

# Run simulation (command-line mode)
run:
	@echo "[Running Simulation with TESTNAME=$(TESTNAME)...]" | tee $(SIM_LOG)
	@vsim -coverage -c -voptargs=+acc -do "run -all; quit" work.testbench $(UVM_ARGS) | tee -a $(SIM_LOG) | tee -a $(TRANSCRIPT)

grun:
	@echo "[Running Simulation with TESTNAME=$(TESTNAME) in GUI mode...]" | tee $(SIM_LOG)
	@vsim -coverage work.testbench $(UVM_ARGS) -do "do wave.do; run -all; quit" | tee -a $(SIM_LOG) | tee -a $(TRANSCRIPT)

# Clean up artifacts
clean:
	rm -rf $(WORKLIB) $(COMP_LOG) $(SIM_LOG) $(TRANSCRIPT) vsim.wlf

regress:
	./regressions/run_regression.sh

.PHONY: all comp run gui clean
