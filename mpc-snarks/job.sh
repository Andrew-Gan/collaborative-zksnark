#!/bin/bash

export CMD="./scripts/bench.zsh plonk spdz 10 4"

$CMD
# compute-sanitizer --tool memcheck $CMD
# nsys profile --stats=true $CMD
