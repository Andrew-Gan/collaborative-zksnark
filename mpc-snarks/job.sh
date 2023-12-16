#!/bin/bash

./scripts/bench.zsh plonk spdz 10 2
cat output/delegator_full.out | rg "^··End:" &> output/delegator-filtered.out
# valgrind --leak-check=full ./ferret/emp-ot/run ./ferret/emp-ot/bin/test_ferret 28
# compute-sanitizer --tool memcheck --target-processes all ./ferret/emp-ot/run ./ferret/emp-ot/bin/test_ferret 28
# nsys profile --stats=true ./ferret/emp-ot/run ./ferret/emp-ot/bin/test_ferret 28
