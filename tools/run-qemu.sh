#!/bin/bash
#
# SPDX-License-Identifier: MIT
#

set -e

top_dir=$(readlink -f $(dirname $0)/..)
tools_dir=${top_dir}/tools
data_dir=${top_dir}/data

if [ $# -ne 2 ]; then
    echo "Usage: $(basename $0) <u-boot build dir> <qemu conf file>"
    exit 1
fi

uboot_dir=$(readlink -f $1)
if [ ! -d $uboot_dir ]; then
    echo "invalid U-Boot directory"
    exit 1
fi

uboot_bin=$uboot_dir/u-boot.bin
if [ ! -f $uboot_bin ]; then
    echo "invalid U-Boot binary"
    exit 1
fi

conf_file=$(readlink -f $2)
if [ ! -f $conf_file ]; then
    echo "invalid Qemu conf file"
    exit 1
fi

U_BOOT_BUILD_DIR=$uboot_dir
source $conf_file

qemu_pflash_bin=${uboot_dir}/pflash.bin
qemu_pflash="-drive if=pflash,file=${qemu_pflash_bin},format=raw"
qemu_network="-netdev user,id=ubtest,tftp=${data_dir}"
qemu_netdev="-device pcnet,netdev=ubtest"

dd if=/dev/zero bs=1M count=4 | tr '\000' '\377' > ${qemu_pflash_bin}
dd if=${uboot_bin} of=${qemu_pflash_bin} conv=notrunc

${qemu_bin} \
    -M ${qemu_machine} \
    -cpu ${qemu_cpu} \
    -m ${qemu_mem} \
    -nographic \
    ${qemu_pflash} \
    ${qemu_network} \
    ${qemu_netdev}
