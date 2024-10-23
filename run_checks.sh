#!/bin/bash

# Array of block sizes to test
block_sizes=("4k" "1k" "512")

# Array of I/O patterns
io_patterns=("randread" "randwrite")

# Array of write modes
write_modes=("read" "write" "rw")

# Array of I/O engines
io_engines=("libaio" "sync" "null")

# EFS mount point
EFS_MOUNT=.

# Start ioping in the background
ioping -c 0 -i 1 $EFS_MOUNT > ioping_results.txt &
IOPING_PID=$!

# Start the timer
start_time=$(date +%s)

# Loop through block sizes, I/O patterns, write modes, and I/O engines
for bs in "${block_sizes[@]}"; do
  for pattern in "${io_patterns[@]}"; do
    for mode in "${write_modes[@]}"; do
      for engine in "${io_engines[@]}"; do
        echo "Running test with block size: $bs, I/O pattern: $pattern, write mode: $mode, I/O engine: $engine"

        fio --name=${pattern}_${bs}_${mode}_${engine} \
            --ioengine=$engine \
            --rw=$mode \
            --bs=$bs \
            --numjobs=4 \
            --size=1G \
            --runtime=120 \
            --time_based \
            --group_reporting \
            --directory=$EFS_MOUNT \
            --output=fio_results_${pattern}_${bs}_${mode}_${engine}.txt

        echo "Test completed for block size: $bs, I/O pattern: $pattern, write mode: $mode, I/O engine: $engine"
        echo "----------------------------------------"
      done
    done
  done
done

# Create custom kernel
kernel_create_start=$(date +%s)
kernel-create custom-kernel 3.12 "Custom kernel"
kernel_create_end=$(date +%s)
kernel_create_time=$((kernel_create_end - kernel_create_start))

# Stop ioping
kill $IOPING_PID

# Calculate the total time taken
end_time=$(date +%s)
total_time=$((end_time - start_time))

echo "Kernel creation time: $kernel_create_time seconds" > total_time.txt
echo "Test execution time: $total_time seconds" >> total_time.txt
echo "Total time: $((total_time + kernel_create_time)) seconds" >> total_time.txt

# Create a tar archive of all result output files
tar -czf results.tar.gz fio_results_*.txt ioping_results.txt total_time.txt

# Clean up the rand* files
rm -f rand*.0

echo "All tests completed. Results saved in results.tar.gz"

