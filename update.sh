#!/bin/bash
set -e

[ -z "$VERSION" ] && VERSION="3.1.0-2"
[ -z "$REPO" ] && REPO="multiarch/qemu-user-static"

echo "VER: $VERSION"
echo "REPO: $REPO"

if [ -z "$VERSION" ]; then
    echo "usage: $0 -v VERSION" 2>&1
    echo "check https://github.com/${REPO}/releases for available versions" 2>&1
    exit 1
fi

from_arch="x86_64"
to_archs="aarch64 alpha arm armeb cris hppa i386 m68k microblaze microblazeel mips mips64 mips64el mipsel mipsn32 mipsn32el nios2 or1k ppc ppc64 ppc64abi32 ppc64le s390x sh4 sh4eb sparc sparc32plus sparc64 x86_64"

for to_arch in $to_archs; do
    if [ "$from_arch" != "$to_arch" ]; then
        docker build -t ${REPO}:$from_arch-$to_arch -<<EOF
FROM scratch
ADD https://github.com/${REPO}/releases/download/v${VERSION}/${from_arch}_qemu-${to_arch}-static.tar.gz /usr/bin
EOF
        docker tag ${REPO}:$from_arch-$to_arch ${REPO}:$to_arch
    fi
done

docker build -t ${REPO}:register register
