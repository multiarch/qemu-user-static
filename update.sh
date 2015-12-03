#!/bin/sh

archs="aarch64 alpha arm armeb cris i386 m68k microblaze microblazeel mips mips64 mips64el mipsel mipsn32 mipsn32el or32 ppc ppc64 ppc64abi32 ppc64le s390x sh4 sh4eb sparc sparc32plus sparc64 unicore32 x86_64"

for arch in $archs; do
    mkdir -p $arch
    cat > $arch/Dockerfile <<EOF
FROM scratch
ADD https://github.com/multiarch/qemu-user-static/releases/download/v2.0.0/amd64_qemu-$arch-static.tar.gz /usr/bin
EOF
    docker build -t multiarch/qemu-user-static:$arch $arch
done
