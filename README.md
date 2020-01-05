# SelectiveFilter
Mixed C++/AVX512 project to select values from an array that are greater than a specified cutoff value.
The C++ driver creates a large array of random integers, and then calls an assembly routine to count and sum all of the entries that meet the criterion. For comparison, the C++ driver also does the same calculations.

# AVX512 Instructions featured in the assembly code
vpbroadcastd - broadcast copy a dword value to 16 lanes of a ZMM register

vpcmpd - vector compare of dword values in two ZMM registers using a specified comparison operator

vpaddd - packed vector addition using opmask registers

# Timing
Computer: Xeon Silver 4114 running at 2.20 GHz, with an array of 12,800,000 integers.
Compiled with MSFT Visual Studio 2017.

AVX512 code: 9,473,456 clocks

C++ code: 145,623,094 clocks

The AVX512 code is roughly 16 times as fast.

# Note
The code in this project must be run on a computer that supports AVX512 Foundation (AVX512F) instructions, or with software that simulates these isntructions. 
