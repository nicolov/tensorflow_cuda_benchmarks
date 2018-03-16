#!/usr/bin/env bash

# This scripts run inside Docker and builds TensorFlow wheels with both
# clang and nvcc as CUDA compilers.

set -euxo pipefail

TF_COMMIT=49fc0a9abb8ae11adf9b4ee651954f30abdaf255

cd /tmp
wget https://github.com/tensorflow/tensorflow/archive/49fc0a9abb8ae11adf9b4ee651954f30abdaf255.tar.gz

tar -xf ${TF_COMMIT}.tar.gz
cd tensorflow-${TF_COMMIT}

# This is usually done by ./configure
echo 'export PYTHON_BIN_PATH="/usr/bin/python"' > tools/python_bin_path.sh

# Clang build
echo "import /src/tf_config_clang.bazelrc" > .bazelrc
bazel build --config=opt --config=cuda_clang //tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package /src/wheels/clang

# nvcc build
bazel clean --expunge
echo "import /src/tf_config_nvcc.bazelrc" > .bazelrc
cp /src/tf_config_nvcc.bazelrc .tf_configure.bazelrc
bazel build --config=opt --config=cuda //tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package /src/wheels/nvcc
