#!/bin/sh

QEMU_BIN_DIR=${QEMU_BIN_DIR:-/usr/bin}


if [ ! -d /proc/sys/fs/binfmt_misc ]; then
    echo "No binfmt support in the kernel."
    echo "  Try: '/sbin/modprobe binfmt_misc' from the host"
    exit 1
fi


if [ ! -f /proc/sys/fs/binfmt_misc/register ]; then
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
fi

entries="aarch64 arm m68k mips64 mipsel mipsn32el ppc64 sh4 sparc alpha armeb mips mips64el mipsn32 ppc ppc64le s390x sh4eb"

if [ "${1}" = "--reset" ]; then
    shift
    (
	cd /proc/sys/fs/binfmt_misc
	for file in $entries; do
            if [ -f $file ]; then
		echo -1 > "${file}"
            fi
	done
    )
fi

exec /qemu-binfmt-conf.sh --qemu-path="${QEMU_BIN_DIR}" $@
