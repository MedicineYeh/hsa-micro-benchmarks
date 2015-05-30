# Introduction
hsa-micro-benchmarks is a set of micro-benchmarks designed for HSA platforms to profile the detailed system behavior.
This is still an on-going work and not well-tested yet.
If you have any problems, feel free to post an issue.

# Pre-requests
This sample is modified from the original [CLOC](https://github.com/HSAFoundation/CLOC) sample code.
Please make sure you have set up the HSA environment before using this sample.

# Batch testing
Each file in the folder __test_set__ is a test set of micro-benchmarks with some arguments in the begining lines of the file.
Those arguments like __TIMES__ are parsed and processed by script in order to execute properly.

![Sample Image](/sample.png?raw=true "Sample Image")

## Arguments of Micro-benchmarks
* __TIMES__: Is the number of repeated times to minimize the overhead of each loop iteration. It is similar to the concept of loop-unrolling.

## Execution
1. Run `./run_set.sh` and the result will be shown on the screen as well as dumped to __output__ folder
2. Execute `head ./output/*` to see the result manually

* Run `./run_set.sh [TEST SET FILE]` to run a single test. Ex: `./run_set.sh ./test_set/ld_st`

# Normal Build an Test
* `make` to build
* `make test` to build and run
* `make clean` to clean the generated files

