#!/usr/bin/env bash
# Copyright 2017 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ==============================================================================

set -e
set -x

N_JOBS=$(grep -c ^processor /proc/cpuinfo)

echo ""
echo "Bazel will use ${N_JOBS} concurrent job(s)."
echo ""

# Run configure.
export TF_NEED_GCP=0
export TF_NEED_HDFS=0
export PYTHON_BIN_PATH=`which python3`

export TF_NEED_ROCM=1
#export TF_CUDA_COMPUTE_CAPABILITIES=3.7

# Configure with all defaults
yes '' | ./configure

# Run bazel test command. Double test timeouts to avoid flakes.
bazel test --config=rocm --test_tag_filters=-no_oss,-no_gpu,-benchmark-test -k \
    --test_lang_filters=py --jobs=${N_JOBS} --test_timeout 300,450,1200,3600 \
    --build_tests_only --test_output=errors --local_test_jobs=1 \
    --run_under=//tensorflow/tools/ci_build/gpu_build:parallel_gpu_execute -- \
    //tensorflow/... -//tensorflow/compiler/... -//tensorflow/contrib/... \
    -//tensorflow/python/estimator:dnn_linear_combined_test \
    -//tensorflow/python/estimator:dnn_test \
    -//tensorflow/python/estimator:estimator_test \
    -//tensorflow/python/estimator:linear_test \
    -//tensorflow/python/feature_column:feature_column_test \
    -//tensorflow/python/kernel_tests:atrous_conv2d_test \
    -//tensorflow/python/kernel_tests:batch_matmul_op_test \
    -//tensorflow/python/kernel_tests:cholesky_op_test \
    -//tensorflow/python/kernel_tests:concat_op_test \
    -//tensorflow/python/kernel_tests:control_flow_ops_py_test \
    -//tensorflow/python/kernel_tests:conv_ops_3d_test \
    -//tensorflow/python/kernel_tests:conv_ops_test \
    -//tensorflow/python/kernel_tests:conv2d_transpose_test \
    -//tensorflow/python/kernel_tests:depthwise_conv_op_test \
    -//tensorflow/python/kernel_tests:fft_ops_test \
    -//tensorflow/python/kernel_tests:linalg_ops_test \
    -//tensorflow/python/kernel_tests:losses_test \
    -//tensorflow/python/kernel_tests:lrn_op_test \
    -//tensorflow/python/kernel_tests:matrix_inverse_op_test \
    -//tensorflow/python/kernel_tests:matrix_triangular_solve_op_test \
    -//tensorflow/python/kernel_tests:metrics_test \
    -//tensorflow/python/kernel_tests:neon_depthwise_conv_op_test \
    -//tensorflow/python/kernel_tests:pool_test \
    -//tensorflow/python/kernel_tests:pooling_ops_3d_test \
    -//tensorflow/python/kernel_tests:pooling_ops_test \
    -//tensorflow/python/kernel_tests:tensordot_op_test \
    -//tensorflow/python/kernel_tests:zero_division_test \
    -//tensorflow/python/profiler/internal:run_metadata_test \
    -//tensorflow/python/profiler:model_analyzer_test \
    -//tensorflow/python/profiler:profiler_test \
    -//tensorflow/python:control_flow_ops_test \
    -//tensorflow/python:cost_analyzer_test \
    -//tensorflow/python:layers_normalization_test \
    -//tensorflow/python:learning_rate_decay_test \
    -//tensorflow/python:math_ops_test \
    -//tensorflow/python:memory_optimizer_test \
    -//tensorflow/python:nn_fused_batchnorm_test \
    -//tensorflow/python:special_math_ops_test \
    -//tensorflow/python:timeline_test \
    -//tensorflow/python:training_ops_test

# Note: temp. disabling 38 unit tests in order to esablish a CI baseline (2018/06/05)
