#!/bin/bash

output_file="tests_output.out"
script_path="./run_test.sh"

# Truncate the output file if it exists, or create it if it doesn't
> $output_file

# Loop through each exi directory
for i in {1..5}; do
  ex_dir="ex${i}"

  # Check if the directory exists
  if [[ -d $ex_dir ]]; then
    asm_file="${ex_dir}/ex${i}.asm"

    # Find test files matching the pattern exi_testj
    for test_file in $(ls ${ex_dir}/ex${i}_test* | grep -P "^${ex_dir}/ex${i}_test\d+$"); do
      echo "Running: $script_path $asm_file $test_file" | tee -a $output_file
      $script_path $asm_file $test_file >> $output_file 2>&1
      echo -e "_____________________________________________________________\n" >> $output_file  # Add a line of underscores between tests
    done
  fi
done
