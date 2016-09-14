#
# SPDX-License-Identifier: MIT
#
# Test environment for MIPS Malta board
#

env__net_uses_pci = True
env__net_dhcp_server = False

env__net_static_env_vars = [
    ("ipaddr", "10.0.2.15"),
    ("serverip", "10.0.2.2"),
]

env__net_tftp_readable_file = {
    "fn": "ubtest.bin",
    "size": 1048576,
    "crc32": "c4d4fe09",
}
