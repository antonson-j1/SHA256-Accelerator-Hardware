#!/bin/sh
#
# Compile and run the test bench

[ -x "$(command -v iverilog)" ] || { echo "Install iverilog"; exit 1; }

# Clear out existing log file
#rm -f sha256_debug.log 

#Reading each line.
echo "Compiling sources for pipelined implementation"

iverilog -o sha256_unrolled_pipelined sha256_unrolled_pipelined.v
if [ $? != 0 ]; then
    echo "* Compilation error! Please fix."
exit 1;
fi
./sha256_unrolled_pipelined


# Run Yosys to synthesize 
echo "Running yosys to synthesize Unrolled and Pipelined implementation of SHA256"
yosys synth.ys

if [ $? != 0 ]; then
    echo "Synthesis failed.  Please check for error messages."
    exit 1;
fi

# Post synthesis simulation
echo "Compiling sources for post-synthesis simulation"

iverilog -o sha256_unrolled_pipelined -DCOMPRESSED_ISA testbench_mod.v axi4_mem_periph.v picorv32.v sha256_unrolled_pipelined.v
if [ $? != 0 ]; then
	echo "* Compilation error! Please fix."
    exit 1;
fi
./sha256_unrolled_pipelined

gcc -o sha256_c_implementation firmware/sha256_test.c firmware/sha256.c
if [ $? != 0 ]; then
    echo "* Compilation error! Please fix."
exit 1;
fi
./sha256_c_implementation 

cat << EOF
End of run.sh
EOF