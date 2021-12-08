
# Assignment 5 - Interfacing

*Note*: This is a forked repository of PicoRV32 - the original README is available at [[README_picorv32.md]].

## Problem statement
Interface the sequential multiplier you created in assignment 1 with the picorv32 processor.

## Given
The file [[firmware/hello.c]] has been modified to add functions that will write inputs to the `a` and `b` inputs of the multiplier, and there is another function that will wait on the return values.  Read these functions as well as the file [[axi4_mem_periph.v]] carefully and understand how the interfacing of C code with the peripheral is done.

You will now need to instantiate your seq_mult.v (add a line to the appropriate place in the Makefile so it compiles) and then create some new `reg` or `wire` signals in the `axi4_mem_periph` module to enable sending and receiving signals from the C code.

## Test
To run the test, you can just type `make` in the main folder.  This will compile the Verilog files for simulation with `iverilog`, and will also compile the C code to generate a *hex* file (instructions and data in hexadecimal format) that can be loaded into the CPU memory for execution.

The C code will feed in 2 numbers, and test whether the output from your multiplier is correct.  Of course you can cheat and just return the product from your `Mult_GetResult` function, but for the final tests we will be running with separate test code, so changes you make in the C code will not be reflected there.  You could also just do the multiplication in Verilog and return the result.  Neither of these is going to teach you anything about computer design, so if you need to do this to get at least a partial result, please indicate this properly in your code so that we can consider it for partial marks.

