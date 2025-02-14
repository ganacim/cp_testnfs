#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -p PREFIX"
    exit 1
}

# Parse command line arguments
while getopts ":p:" opt; do
    case $opt in
        p) PREFIX="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check required arguments
if [[ -z "$PREFIX" ]]; then
    usage
fi

# Define arrays of parameters
BLOCK_SIZES=("4k" "16k" "64k" "256k" "1m")
JOB_COUNTS=(1 2 4 8 16)
FILE_SIZES=("1G" "5G" "10G")

# Define other parameters
OUTPUT_DIR="./results"
TEST_DIR="/mnt/test"
RUNTIME=60
DIRECT_IO=1

# Export variables to be used by fio_benchmark.sh
export OUTPUT_DIR TEST_DIR PREFIX RUNTIME DIRECT_IO

# Loop through each combination of parameters
for BLOCK_SIZE in "${BLOCK_SIZES[@]}"; do
    for JOBS in "${JOB_COUNTS[@]}"; do
        for TEST_SIZE in "${FILE_SIZES[@]}"; do
            export BLOCK_SIZE JOBS TEST_SIZE
            ./fio_benchmark.sh
        done
    done
done

echo "Batch testing complete. Results are stored in $OUTPUT_DIR"