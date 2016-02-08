#!/bin/bash
#
# Sample script for running U-Boot pytest framework in a
# Qemu MIPS Malta machine with a 24Kc CPU
# 
# Usage:
# - setup your toolchain by setting CROSS_COMPILE and CONFIG_USE_PRIVATE_LIBGCC=y
# - run this script from the U-Boot source directory
#

set -e
set -x

top_dir=$(readlink -f $(dirname $0))
bin_path=${top_dir}/bin
python_path=${top_dir}/py
board_type=malta
build_dir=/tmp/u-boot-test/${board_type}

PATH=${bin_path}:${PATH} \
PYTHONPATH=${python_path}:${PYTHONPATH} \
    ./test/py/test.py \
        --board-type ${board_type} \
        --board-identity qemu_24kc \
        --build --build-dir ${build_dir}
