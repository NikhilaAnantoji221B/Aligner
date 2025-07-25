# Makefile for compiling and running simulation using Mentor QuestaSim

# File locations
RTL_DIR = ../../rtl
TB_TOP_DIR = ../top

# File list
TOP_SRCS = $(RTL_DIR)/design.sv $(TB_TOP_DIR)/testbench.sv

# Default test if none specified
DEFAULT_TEST = cfs_algn_apb_tests_mapped_unmapped
TESTNAME ?= $(DEFAULT_TEST)
SEED ?= random

TOGGLE_DO=../../tb/sim/toggle_exclude.do

# UVM arguments
UVM_ARGS = +UVM_TESTNAME=$(TESTNAME) +UVM_MAX_QUIT_COUNT=1 +access +rw +ntb_random_seed=$(SEED) -f messages.f

# Simulation libraries
WORKLIB = work

# Log files
COMP_LOG = compile.log
SIM_LOG = sim.log
TRANSCRIPT = transcript

UCDB_DIR = ./ucdb
UCDB_FILE = $(UCDB_DIR)/$(TESTNAME).ucdb

# Default target
all: comp run

# Compile target
comp:
	@echo "[Compiling...]" | tee $(COMP_LOG)
	@rm -rf $(WORKLIB)
	@vlib $(WORKLIB) | tee -a $(COMP_LOG)
	@vmap $(WORKLIB) $(WORKLIB) | tee -a $(COMP_LOG)
	@vlog -sv -cover bcest -work $(WORKLIB) $(TOP_SRCS) +acc +define+QUESTA +incdir+$(RTL_DIR) +incdir+$(TB_TOP_DIR) \
		| tee -a $(COMP_LOG) | tee -a $(TRANSCRIPT)

# Run simulation (command-line)
run:
	@mkdir -p $(UCDB_DIR)
	@echo "[Running Simulation: TEST=$(TESTNAME), SEED=$(SEED)]" | tee $(SIM_LOG)
	@vsim -coverage -c work.testbench $(UVM_ARGS) \
		-do  "do $(TOGGLE_DO); coverage save -onexit $(UCDB_FILE); run -all; quit" \
		| tee -a $(SIM_LOG) | tee -a $(TRANSCRIPT)

# Run simulation (GUI)
grun:
	@echo "[Running Simulation with TESTNAME=$(TESTNAME) in GUI mode...]" | tee $(SIM_LOG)
	@vsim -coverage work.testbench $(UVM_ARGS) -do "do $(TOGGLE_DO);do wave.do; run -all; quit" | tee -a $(SIM_LOG) | tee -a $(TRANSCRIPT)

# Clean all
clean:
	rm -rf $(WORKLIB) $(COMP_LOG) $(SIM_LOG) $(TRANSCRIPT) vsim.wlf
	rm -rf $(UCDB_DIR)/*.ucdb $(UCDB_DIR)/merged.ucdb $(UCDB_DIR)/coverage_report logs regression.log

# Coverage report
report:
	@echo "[Merging UCDB files into $(UCDB_DIR)/merged.ucdb]"
	@vcover merge $(UCDB_DIR)/merged.ucdb $(shell find $(UCDB_DIR) -name '*.ucdb' ! -name 'merged.ucdb')
	@echo "[Generating HTML coverage report in $(UCDB_DIR)/coverage_report]"
	@vcover report -html -output $(UCDB_DIR)/coverage_report -details -verbose $(UCDB_DIR)/merged.ucdb
	@echo "[Opening HTML report with Firefox...]"
	@firefox $(UCDB_DIR)/coverage_report/index.html >/dev/null 2>&1 || echo "Please open $(UCDB_DIR)/coverage_report/index.html manually."

# Regression run
NUM_RUNS ?= 1

regress: comp
	@echo "[Starting Full Regression: $(NUM_RUNS) runs per test]" | tee regression.log
	@rm -rf logs ucdb
	@mkdir -p logs ucdb

	@seq 1 $(NUM_RUNS) | while read i; do \
		while read test; do \
			seed=$$(od -An -N2 -tu4 < /dev/urandom | tr -d ' '); \
			runid=$$(date +%s%N | cut -b1-13); \
			echo "[==============================]" | tee -a regression.log ; \
			echo "[Running $$test with SEED=$$seed]" | tee -a regression.log ; \
			vsim -coverage -c work.testbench \
				+UVM_TESTNAME=$$test +UVM_MAX_QUIT_COUNT=1 +access +rw +ntb_random_seed=$$seed -f messages.f \
				-do "do $(TOGGLE_DO);coverage save -onexit ucdb/$$test\_$$runid.ucdb; run -all; quit;" \
				> logs/$$test\_$$runid.log 2>&1 ; \
			grep -i -P "UVM_FATAL(?! *: *0)|UVM_ERROR(?! *: *0)|(\*UVM_FATAL)|(\*Error[^s:])|^#\s+Fatal" logs/$$test\_$$runid.log \
				&& echo "[❌ FAIL] $$test (SEED=$$seed)" | tee -a regression.log \
				|| echo "[✅ PASS] $$test (SEED=$$seed)" | tee -a regression.log ; \
			echo "[==============================]" | tee -a regression.log ; \
		done < regressions/regress_list.txt; \
	done

	@echo "[Merging coverage files...]" | tee -a regression.log
	@vcover merge merged.ucdb ucdb/*.ucdb
	@echo "[Regression Completed. Coverage saved to merged.ucdb]" | tee -a regression.log

.PHONY: all comp run grun clean regress report

