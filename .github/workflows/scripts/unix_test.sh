#!/bin/bash
set -ex

check_in_docker() {
    # This is a temporary solution to detect in a docker, but it should work
    if [[ $(whoami) == "dev" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

export TI_SKIP_VERSION_CHECK=ON
export TI_CI=1
export TI_IN_DOCKER=$(check_in_docker)

if [[ "$TI_IN_DOCKER" == "true" ]]; then
    source $HOME/miniconda/etc/profile.d/conda.sh
    conda activate "$PY"
fi
python3 -m pip install dist/*.whl
if [ -z "$GPU_TEST" ]; then
    python3 -m pip install -r requirements_test.txt
    python3 -m pip install "torch; python_version < '3.10'"
    # Paddle's develop package doesn't support CI's MACOS machine at present
    if [[ $OSTYPE == "linux-"* ]]; then
        python3 -m pip install "paddlepaddle==2.3.0; python_version < '3.10'"
    fi
else
    ## Only GPU machine uses system python.
    export PATH=$PATH:$HOME/.local/bin
    # pip will skip packages if already installed
    python3 -m pip install -r requirements_test.txt
    # Import Paddle's develop GPU package will occur error `Illegal Instruction`.

    # Log hardware info for the current CI-bot
    # There's random CI failure caused by "import paddle"
    # Top suspect is an issue with MKL support for specific CPU
    lscpu | grep "Model name"
fi

ti diagnose
ti changelog
echo "wanted archs: $TI_WANTED_ARCHS"

TI_PATH=$(python3 -c "import taichi;print(taichi.__path__[0])" | tail -1)
TI_LIB_DIR="$TI_PATH/_lib/runtime" ./build/taichi_cpp_tests

if [ -z "$GPU_TEST" ]; then
    if [[ $PLATFORM == *"m1"* ]]; then
	# Split per arch to avoid flaky test
        python3 tests/run_tests.py -vr2 -t4 -k "not torch and not paddle" -a cpu
        # Run metal and vulkan separately so that they don't use M1 chip simultaneously.
        python3 tests/run_tests.py -vr2 -t4 -k "not torch and not paddle" -a vulkan
        python3 tests/run_tests.py -vr2 -t2 -k "not torch and not paddle" -a metal
        python3 tests/run_tests.py -vr2 -t1 -k "torch" -a "$TI_WANTED_ARCHS"
    else
        # Fail fast, give priority to the error-prone tests
        if [[ $OSTYPE == "linux-"* ]]; then
            python3 tests/run_tests.py -vr2 -t1 -k "paddle" -a "$TI_WANTED_ARCHS"
        fi
        python3 tests/run_tests.py -vr2 -t4 -k "not paddle" -a "$TI_WANTED_ARCHS"
    fi
else
    # Split per arch to increase parallelism for linux GPU tests
    if [[ $TI_WANTED_ARCHS == *"cuda"* ]]; then
        python3 tests/run_tests.py -vr2 -t4 -k "not torch and not paddle" -a cuda
    fi
    if [[ $TI_WANTED_ARCHS == *"cpu"* ]]; then
        python3 tests/run_tests.py -vr2 -t8 -k "not torch and not paddle" -a cpu
    fi
    if [[ $TI_WANTED_ARCHS == *"vulkan"* ]]; then
        python3 tests/run_tests.py -vr2 -t8 -k "not torch and not paddle" -a vulkan
    fi
    if [[ $TI_WANTED_ARCHS == *"opengl"* ]]; then
        python3 tests/run_tests.py -vr2 -t4 -k "not torch and not paddle" -a opengl
    fi
    python3 tests/run_tests.py -vr2 -t1 -k "torch" -a "$TI_WANTED_ARCHS"
    # Paddle's paddle.fluid.core.Tensor._ptr() is only available on develop branch, and CUDA version on linux will get error `Illegal Instruction`
fi
