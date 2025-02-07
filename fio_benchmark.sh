#!/bin/bash

# Usage: ./benchmark_nfs_local.sh /path/to/local /path/to/nfs /output/dir
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <local_dir> <nfs_dir> <output_dir>"
    exit 1
fi

# Paths from arguments
LOCAL_DIR="$1"
NFS_DIR="$2"
OUTPUT_DIR="$3"

# Benchmarking parameters
TEST_SIZE="1G"       # Size of each test file
BLOCK_SIZE="128k"    # Block size for sequential tests
RAND_BLOCK_SIZE="4k" # Block size for random tests
JOBS=4               # Number of parallel jobs
RUNTIME=30           # Duration of each test in seconds

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Function to run FIO test
run_fio() {
    local test_name=$1
    local directory=$2
    local rw_mode=$3
    local bs=$4
    local output_file="$OUTPUT_DIR/${test_name}.txt"

    echo "Running $test_name test on $directory..."
    
    fio --name="$test_name" \
        --directory="$directory" \
        --ioengine=libaio \
        --rw="$rw_mode" \
        --bs="$bs" \
        --numjobs="$JOBS" \
        --size="$TEST_SIZE" \
        --runtime="$RUNTIME" \
        --direct=1 \
        --group_reporting | tee "$output_file"

    echo "Results saved in $output_file"
}

# Run tests on local disk
run_fio "local_seq_write" "$LOCAL_DIR" "write" "$BLOCK_SIZE"
run_fio "local_seq_read" "$LOCAL_DIR" "read" "$BLOCK_SIZE"
run_fio "local_rand_write" "$LOCAL_DIR" "randwrite" "$RAND_BLOCK_SIZE"
run_fio "local_rand_read" "$LOCAL_DIR" "randread" "$RAND_BLOCK_SIZE"

# Run tests on NFS mount
run_fio "nfs_seq_write" "$NFS_DIR" "write" "$BLOCK_SIZE"
run_fio "nfs_seq_read" "$NFS_DIR" "read" "$BLOCK_SIZE"
run_fio "nfs_rand_write" "$NFS_DIR" "randwrite" "$RAND_BLOCK_SIZE"
run_fio "nfs_rand_read" "$NFS_DIR" "randread" "$RAND_BLOCK_SIZE"

echo "Benchmarking complete. Results are stored in $OUTPUT_DIR"

