#!/bin/bash
#
# SPDX-License-Identifier: MIT
#

set -e

top_dir=$(readlink -f $(dirname $0)/..)
tools_dir=${top_dir}/tools
data_dir=${top_dir}/data

if [ $# -lt 2 ]; then
    echo "Usage: $(basename $0) <u-boot build dir> <qemu conf file> [extra-args]"
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

shift 2

connect_gdb=0
if [ "$1" = "gdb" ]; then
    connect_gdb=1
    shift 1
fi

swap_endianess=0
if [ "$1" = "swap" ]; then
    swap_endianess=1
    shift 1
fi

qemu_extra_args="$@"

U_BOOT_BUILD_DIR=$uboot_dir
source $conf_file

uboot_swap="${uboot_dir}/u-boot-swap.bin"
if [ "$swap_endianess" = "1" ]; then
    hexdump -v -e '1/4 "%08x"' -e '"\n"' ${uboot_bin} | xxd -r -p > ${uboot_swap}
    uboot_bin=${uboot_swap}
fi

qemu_pflash_bin=${uboot_dir}/pflash.bin
qemu_pflash="-drive if=pflash,file=${qemu_pflash_bin},format=raw"
qemu_network="-netdev user,id=ubtest,tftp=${data_dir}"
qemu_netdev="-device ${qemu_netdevice},netdev=ubtest"
qemu_gdb=""

if [ $connect_gdb -eq 1 ]; then
    qemu_pflash=""
    qemu_gdb="-s -bios ${uboot_bin}"
else
    dd if=/dev/zero bs=1M count=4 | tr '\000' '\377' > ${qemu_pflash_bin}
    dd if=${uboot_bin} of=${qemu_pflash_bin} conv=notrunc
fi

${qemu_bin} \
    -M ${qemu_machine} \
    -cpu ${qemu_cpu} \
    -m ${qemu_mem} \
    -nographic \
    ${qemu_pflash} \
    ${qemu_network} \
    ${qemu_netdev} \
    ${qemu_gdb} \
    ${qemu_extra_args}
