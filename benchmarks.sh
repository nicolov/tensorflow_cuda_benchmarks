#!/usr/bin/env bash

# This script runs inside Docker and runs TF benchmarks using the wheels
# compiled under both clang and nvcc.

set -euxo pipefail

TF_BENCHMARKS_COMMIT=08cec8436e77da49dd17ab2f8c65a80545dc138b
BENCHMARK_COMMAND="python tf_cnn_benchmarks.py --batch_size=32 --model=resnet50 --variable_update=parameter_server"

cd /tmp
wget https://github.com/tensorflow/benchmarks/archive/08cec8436e77da49dd17ab2f8c65a80545dc138b.tar.gz

tar -xvf ${TF_BENCHMARKS_COMMIT}.tar.gz
cd benchmarks-${TF_BENCHMARKS_COMMIT}

cd scripts/tf_cnn_benchmarks

rm -rf /src/output
mkdir -p /src/output

run_benchmark () {
    pip uninstall -y tensorflow || true
    find "/src/wheels/${1}" -type f -name '*.whl' -exec pip install {} ';'
    ${BENCHMARK_COMMAND} --num_gpus="${2}" | tee "/src/output/${1}-${2}gpus.txt"    
}

run_benchmark "clang" "1"
run_benchmark "clang" "2"
run_benchmark "nvcc" "1"
run_benchmark "nvcc" "2"

# Fix ownership for the host
chown -R 1000:1000 /src/output
