#!/bin/bash

# Compile the test case generator and the brute-force script
g++ -o test_gen test_gen.cpp
g++ -o bruteforce_prefix_sum brute_force.cpp

# Compile the MPI program
mpic++ -o mpi_prefix_sum 3.cpp  

# Generate test cases
./test_gen

# Run the MPI program and brute-force program, then compare their outputs
mkdir -p results

for i in {1..15}; do
    echo "Running test case $i..."
    test_file="test_cases/test$i.txt"
    
    # Run brute-force method
    ./bruteforce_prefix_sum $test_file > results/brute_force_$i.txt

    # Run MPI method with 1 to 12 processes
    for np in {1..12}; do
        mpiexec -np $np --use-hwthread-cpus --oversubscribe ./mpi_prefix_sum < $test_file > results/mpi_$np_$i.txt

        # Compare the results
        if diff -q results/brute_force_$i.txt results/mpi_$np_$i.txt > /dev/null; then
            echo -e "Test case $i with $np processes: \e[32mPASSED\e[0m"
        else
            echo -e "Test case $i with $np processes: \e[31mFAILED\e[0m"
        fi
    done
done

# Clean up: Remove executables
rm -rf test_gen bruteforce_prefix_sum mpi_prefix_sum results/ test_cases/
