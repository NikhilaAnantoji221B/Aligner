#!/bin/bash

# Clean old logs and UCDB files
rm -f logs/*.log
rm -f ucdb/*.ucdb

# Paths
REGRESS_FILE="regressions/regress_list.txt"
LOG_DIR="logs"
UCDB_DIR="ucdb"

# Ensure directories exist
mkdir -p "$LOG_DIR" "$UCDB_DIR"

# Compile once before running tests
make clean > /dev/null
make comp > "$LOG_DIR/comp_all_tests.log"

# Run regressions
i=1
while IFS= read -r line || [[ -n "$line" ]]; do
  eval "$line"  # sets TESTNAME
  SEED=$(( RANDOM * RANDOM ))

  echo "[$i] Running $TESTNAME with SEED=$SEED"

  make run TESTNAME=$TESTNAME \
    UVM_ARGS="+UVM_TESTNAME=$TESTNAME +sv_seed=$SEED +UVM_MAX_QUIT_COUNT=1 +access +rw -f messages.f" \
    > "$LOG_DIR/sim_${TESTNAME}_${SEED}.log"

  ((i++))
done < "$REGRESS_FILE"

# Summarize errors and fatals
echo "==== REGRESSION ERROR SUMMARY ====" > "$LOG_DIR/summary.log"
for logfile in "$LOG_DIR"/sim_*.log; do
  errors=$(awk '/UVM_ERROR/ { e=$NF } END { print e+0 }' "$logfile")
  fatals=$(awk '/UVM_FATAL/ { f=$NF } END { print f+0 }' "$logfile")

  echo "$(basename "$logfile"): Errors=$errors, Fatals=$fatals" >> "$LOG_DIR/summary.log"
done

cat "$LOG_DIR/summary.log"
