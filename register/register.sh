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


if [ "${1}" = "--reset" ]; then
    shift
    (
	cd /proc/sys/fs/binfmt_misc
	for file in *; do
	    case "${file}" in
		status|register)
		    ;;
		*)
		    echo -1 > "${file}"
		    ;;
	    esac
	done
    )
fi

exec /qemu-binfmt-conf.sh --qemu-path="${QEMU_BIN_DIR}" $@
