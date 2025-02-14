#!/bin/bash

# Default values for parameters
TEST_SIZE="1G"
BLOCK_SIZE="128k"
RAND_BLOCK_SIZE="4k"
JOBS=4
RUNTIME=30
DIRECT_IO=1
PREFIX=""

# Usage function
usage() {
    echo "Usage: $0 --dir <test_dir> --out <output_dir> [options]"
    echo ""
    echo "Options:"
    echo "  --dir <path>         Path to test directory (required)"
    echo "  --out <path>         Output directory for results (required)"
    echo "  --prefix <name>      Prefix for result filenames (optional, default: '')"
    echo "  --size <size>        File size for each test (default: 1G)"
    echo "  --bs <size>          Block size for sequential tests (default: 128k)"
    echo "  --randbs <size>      Block size for random tests (default: 4k)"
    echo "  --jobs <num>         Number of parallel jobs (default: 4)"
    echo "  --runtime <seconds>  Test runtime per job (default: 30s)"
    echo "  --direct <0|1>       Use direct I/O (1 = enabled, default: 1)"
    echo ""
    echo "Example:"
    echo "  $0 --dir /mnt/local --out ./results --prefix my_host --size 2G --bs 256k"
    exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)
            TEST_DIR="$2"
            shift 2
            ;;
        --out)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --size)
            TEST_SIZE="$2"
            shift 2
            ;;
        --bs)
            BLOCK_SIZE="$2"
            shift 2
            ;;
        --randbs)
            RAND_BLOCK_SIZE="$2"
            shift 2
            ;;
        --jobs)
            JOBS="$2"
            shift 2
            ;;
        --runtime)
            RUNTIME="$2"
            shift 2
            ;;
        --direct)
            DIRECT_IO="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Check required arguments
if [[ -z "$TEST_DIR" || -z "$OUTPUT_DIR" ]]; then
    usage
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Function to run FIO test
run_fio() {
    local test_name=$1
    local rw_mode=$2
    local bs=$3
    local output_file="$OUTPUT_DIR/${PREFIX}${test_name}.txt"

    echo "Running $test_name test on $TEST_DIR..."
    
    fio --name="$test_name" \
        --directory="$TEST_DIR" \
        --ioengine=libaio \
        --rw="$rw_mode" \
        --bs="$bs" \
        --numjobs="$JOBS" \
        --size="$TEST_SIZE" \
        --runtime="$RUNTIME" \
        --direct="$DIRECT_IO" \
        --group_reporting | tee "$output_file"

    echo "Results saved in $output_file"
}

# Run tests
run_fio "${PREFIX}seq_write" "write" "$BLOCK_SIZE"
run_fio "${PREFIX}seq_read" "read" "$BLOCK_SIZE"
run_fio "${PREFIX}rand_write" "randwrite" "$RAND_BLOCK_SIZE"
run_fio "${PREFIX}rand_read" "randread" "$RAND_BLOCK_SIZE"

echo "Benchmarking complete. Results are stored in $OUTPUT_DIR"

