#!/bin/bash
set -e

for i in {1..17}; do
  as -g ex5.asm ex5_test${i} -o ex5_test${i}.o
  ld -g ex5_test${i}.o -o ex5_test${i}_run
  ./ex5_test${i}_run > ex5_test${i}.out
done