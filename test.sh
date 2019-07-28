#!/bin/bash
set -xeo pipefail

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

while getopts "d:" opt; do
    case "$opt" in
        d)  DOCKER_REPO=$OPTARG
        ;;
    esac
done

if [ "${DOCKER_REPO}" = "" ]; then
    echo "DOCKER_REPO is required." 1>&2
    exit 1
fi

# Test cases

# ------------------------------------------------
# multiarch/qemu-user-static image

# It should register binfmt_misc entry with 'flags: F'
# by given "-p yes" option.
sudo docker run --rm --privileged ${DOCKER_REPO} --reset -p yes
cat /proc/sys/fs/binfmt_misc/qemu-aarch64
grep -q '^flags: F$' /proc/sys/fs/binfmt_misc/qemu-aarch64

# It should output the result of "uname -m".
docker pull arm64v8/ubuntu
docker run --rm -t arm64v8/ubuntu uname -m
# It should install a package.
docker build --rm -t "test/latest/ubuntu" -<<EOF
FROM arm64v8/ubuntu
RUN apt-get update && \
    apt-get -y install gcc
EOF

# It should output the result of "uname -m".
docker pull arm64v8/fedora
docker run --rm -t arm64v8/fedora uname -m
# It should install a package.
# TODO: Comment out as it takes a time.
# docker build --rm -t "test/latest/fedora" -<<EOF
# FROM arm64v8/fedora
# RUN dnf -y upgrade && \
#     dnf -y install gcc
# EOF

# ------------------------------------------------
# multiarch/qemu-user-static:register image

# It should register binfmt_misc entry with 'flags: '
# by given no "-p yes" option.
sudo docker run --rm --privileged ${DOCKER_REPO}:register --reset
cat /proc/sys/fs/binfmt_misc/qemu-aarch64
grep -q '^flags: $' /proc/sys/fs/binfmt_misc/qemu-aarch64

# ------------------------------------------------
# multiarch/qemu-user-static:$to_arch image
# multiarch/qemu-user-static:$from_arch-$to_arch image

# /usr/bin/qemu-aarch64-static should be included.
docker run --rm -t ${DOCKER_REPO}:aarch64 /usr/bin/qemu-aarch64-static --version
docker run --rm -t ${DOCKER_REPO}:x86_64-aarch64 /usr/bin/qemu-aarch64-static --version

# ------------------------------------------------
# Integration test
docker build --rm -t "test/integration/ubuntu" -<<EOF
FROM ${DOCKER_REPO}:x86_64-aarch64 as qemu
FROM arm64v8/ubuntu
COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
EOF
docker run --rm -t "test/integration/ubuntu" uname -m
