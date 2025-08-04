#!/bin/bash
set -e

# cd to script's directory
cd "$(dirname "$0")"

proj_root="../../../.."

# STEP0: Increase MAX_CODE_SIZE in old compiler, otherwise it will not compile
# the large REs (those REs will be skipped) thus instruction counts will
# appear to be optimistically much smaller than reality. Note Cicero memory
# fits this bigger code.
sed -i 's/MAX_CODE_SIZE\s*=.*$/MAX_CODE_SIZE = 2048/g' $proj_root/cicero_compiler/ir_re2coprocessor.py

# STEP1: Build cicero_compiler_cpp
bash ./make_new_compiler.sh

# STEP2: Run benchmarks
# Check if the file already exists
if [ -f "all_compiletime_compilesize.csv" ]; then
    # File exists, skip the next command
    echo "Benchmark results already existing (all_compiletime_compilesize.csv), do not rerun."
else
    # File does not exist, run the command
    python3 $proj_root/scripts/measurements/measure_compiletime_compilesize/measure_all.py
fi

# STEP3: Measure compile time for new compiler
# Check if the file already exists
if [ -f "compiletime_new_compiler.csv" ]; then
    # File exists, skip the next command
    echo "Compile time results for new compiler already existing (compiletime_new_compiler.csv), do not rerun."
else
    # File does not exist, run the command
    python3 measure_comptime_cpp.py
fi

# STEP4: Combine the two results
python3 combine_results.py