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
bin_dir=${top_dir}/bin
conf_dir=${top_dir}/conf
python_dir=${top_dir}/py
build_dir=$(mktemp -d)

export PATH=${bin_dir}:${PATH}
export PYTHONPATH=${python_dir}:${PYTHONPATH}

ret=0
if [ $# -ge 1 ]; then
    conf_files=($@)
else
    conf_files=($(ls -1 $conf_dir))
fi

for conf_file in ${conf_files[*]}; do
    conf_base=$(basename $conf_file)
    conf_nosuffix=${conf_base%%.conf}
    conf_split=(${conf_nosuffix/-/ })
    board_type=${conf_split[0]}
    board_identity=${conf_split[1]}

    ./test/py/test.py \
        --board-type ${board_type} \
        --board-identity ${board_identity} \
        --build --build-dir ${build_dir}/${conf_nosuffix} \
        -k 'not (test_sleep or test_md)' || ret=$?
done

rm -rf ${build_dir}
exit $ret
