#!/bin/bash

# Description: This script searches for result files that contain the string 'ENOSPC' 
# or the message 'no space left' in the 'results' directory.

# Check if the results directory exists
if [ ! -d "results" ]; then
  echo "Error: 'results' directory not found."
  exit 1
fi

# Loop through all .txt files in the results directory
for file in results/*.txt; do
  # Check if the file contains 'ENOSPC' or 'no space left'
  if grep -qiE 'ENOSPC|no space left' "$file"; then
    echo "Found in $file"
    # Remove lines containing 'ENOSPC' or 'no space left'
    sed -i '/ENOSPC/d;/no space left/d' "$file"
  fi
done