#!/bin/bash
set -e

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

GITHUB_REPO="multiarch/qemu-user-static"
DOCKER_REPO="multiarch/qemu-user-static"

while getopts "v:" opt; do
    case "$opt" in
        v)  VERSION=$OPTARG
        ;;
    esac
done

if [ -z "$VERSION" ]; then
    echo "usage: $0 -v VERSION" 2>&1
    echo "check https://github.com/${GITHUB_REPO}/releases for available versions" 2>&1
    exit 1
fi

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

from_arch="x86_64"
to_archs=("aarch64" "alpha" "arm" "armeb" "cris" "i386" "m68k" "microblaze" "microblazeel" "mips" "mips64" "mips64el" "mipsel" "mipsn32" "mipsn32el" "or32" "ppc" "ppc64" "ppc64abi32" "ppc64le" "s390x" "sh4" "sh4eb" "sparc" "sparc32plus" "sparc64" "tilegx" "x86_64")

for to_arch in "${to_archs[@]}"; do
    if [ "$from_arch" != "$to_arch" ]; then
        mkdir -p archs/$from_arch-$to_arch
        cat > archs/$from_arch-$to_arch/Dockerfile <<EOF
FROM scratch
ADD https://github.com/${GITHUB_REPO}/releases/download/v${VERSION}/${from_arch}_qemu-${to_arch}-static.tar.gz /usr/bin
EOF
        docker build -t ${DOCKER_REPO}:$from_arch-$to_arch archs/$from_arch-$to_arch
        docker tag ${DOCKER_REPO}:$from_arch-$to_arch ${DOCKER_REPO}:$to_arch
    fi
done

docker build -t ${DOCKER_REPO}:register register
