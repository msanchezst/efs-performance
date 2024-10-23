#!/bin/bash

# Array of block sizes to test
block_sizes=("4k" "1k" "512")

# Array of I/O patterns
io_patterns=("randread" "randwrite")

# EFS mount point
EFS_MOUNT=.

# Start ioping in the background
ioping -c 0 -i 1 $EFS_MOUNT > ioping_results.txt &
IOPING_PID=$!

# Start the timer
start_time=$(date +%s)

# Loop through block sizes and I/O patterns
for bs in "${block_sizes[@]}"; do
  for pattern in "${io_patterns[@]}"; do
    echo "Running test with block size: $bs, I/O pattern: $pattern"

    fio --name=${pattern}_${bs} \
        --ioengine=libaio \
        --rw=$pattern \
        --bs=$bs \
        --numjobs=4 \
        --size=1G \
        --runtime=120 \
        --time_based \
        --group_reporting \
        --directory=$EFS_MOUNT \
        --output=fio_results_${pattern}_${bs}.txt

    echo "Test completed for block size: $bs, I/O pattern: $pattern"
    echo "----------------------------------------"
  done
done

# Create custom kernel
kernel-create-start=$(date +%s)
kernel-create custom-kernel 3.12 "Custom kernel"
kernel-create-end=$(date +%s)
kernel-create-time=$((kernel-create-end - kernel-create-start))

# Stop ioping
kill $IOPING_PID

# Calculate the total time taken
end_time=$(date +%s)
total_time=$((end_time - start_time))

echo "Kernel creation time: $kernel-create-time seconds" > total_time.txt
echo "Test execution time: $total_time seconds" >> total_time.txt
echo "Total time: $((total_time + kernel-create-time)) seconds" >> total_time.txt

# Zip all the result output files
zip -r results.zip fio_results_*.txt ioping_results.txt total_time.txt

# Clean up the rand* files
rm -f rand*.0

echo "All tests completed. Results saved in results.zip"
