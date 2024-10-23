#!/bin/bash

# Function to shuffle an array
shuffle_array() {
  local array=("$@")
  local shuffled=()
  local rand_index
  local size=${#array[@]}

  while [ ${#array[@]} -gt 0 ]; do
    rand_index=$((RANDOM % ${#array[@]}))
    shuffled+=("${array[rand_index]}")
    unset 'array[rand_index]'
    array=("${array[@]}")
  done

  echo "${shuffled[@]}"
}

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

# Shuffle the arrays
shuffled_block_sizes=($(shuffle_array "${block_sizes[@]}"))
shuffled_io_patterns=($(shuffle_array "${io_patterns[@]}"))
shuffled_write_modes=($(shuffle_array "${write_modes[@]}"))
shuffled_io_engines=($(shuffle_array "${io_engines[@]}"))

# Loop through shuffled block sizes, I/O patterns, write modes, and I/O engines
for bs in "${shuffled_block_sizes[@]}"; do
  for pattern in "${shuffled_io_patterns[@]}"; do
    for mode in "${shuffled_write_modes[@]}"; do
      for engine in "${shuffled_io_engines[@]}"; do
        echo "Running test with block size: $bs, I/O pattern: $pattern, write mode: $mode, I/O engine: $engine"

        fio --name=${pattern}_${bs}_${mode}_${engine} \
            --ioengine=$engine \
            --rw=$mode \
            --bs=$bs \
            --numjobs=4 \
            --size=1G \
            --runtime=60 \
            --time_based \
            --group_reporting \
            --directory=$EFS_MOUNT \
            --output=fio_results_${pattern}_${bs}_${mode}_${engine}.txt

        echo "Test completed for block size: $bs, I/O pattern: $pattern, write mode: $mode, I/O engine: $engine"
        echo "----------------------------------------"

        # Clean up the .0 files
        rm -f rand*.0
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

# Create a tar archive of all result output files
tar -czf results.tar.gz fio_results_*.txt ioping_results.txt total_time.txt

echo "All tests completed. Results saved in results.tar.gz"
