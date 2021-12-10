#!/bin/sh
#
# Compile and run the test bench

[ -x "$(command -v iverilog)" ] || { echo "Install iverilog"; exit 1; }

# Clear out existing log file
#rm -f sha256_debug.log 

#Reading each line.
echo "Compiling sources for pipelined implementation"

iverilog -o sha256_core sha256_core.v
if [ $? != 0 ]; then
    echo "* Compilation error! Please fix."
exit 1;
fi
./sha256_core


# Run Yosys to synthesize 
echo "Running yosys to synthesize Unrolled and Pipelined implementation of SHA256"
yosys synth.ys

if [ $? != 0 ]; then
    echo "Synthesis failed.  Please check for error messages."
    exit 1;
fi

# Post synthesis simulation
echo "Compiling sources for post-synthesis simulation"

iverilog -o sha256_core -DCOMPRESSED_ISA testbench_mod.v axi4_mem_periph.v picorv32.v sha256_core.v
if [ $? != 0 ]; then
	echo "* Compilation error! Please fix."
    exit 1;
fi
./sha256_core

cat << EOF
End of run.sh
EOF