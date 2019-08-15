#!/bin/bash
set -xe

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

while getopts "r:v:t:d:" opt; do
    case "$opt" in
        r)  REPO=$OPTARG
        ;;
        v)  VERSION=$OPTARG
        ;;
        t)  TAG_VER=$OPTARG
        ;;
        d)  DOCKER_REPO=$OPTARG
        ;;
    esac
done

if [ -z "$VERSION" ]; then
    echo "usage: $0 -v VERSION" 2>&1
    echo "check https://github.com/${REPO}/releases for available versions" 2>&1
    exit 1
fi

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

from_arch="x86_64"
to_archs="aarch64 aarch64_be alpha armeb arm cris hppa i386 m68k microblazeel microblaze mips64el mips64 mipsel mipsn32el mipsn32 mips nios2 or1k ppc64abi32 ppc64le ppc64 ppc riscv32 riscv64 s390x sh4eb sh4 sparc32plus sparc64 sparc tilegx trace-stap x86_64 xtensaeb xtensa"
# For casual test
# to_archs="aarch64"

# Build container images creating the directory.
# containers/
#   latest/ - An image including /usr/bin/qemu-$arch-status and /register script.
#   ${from_arch}_qemu-${to_arch}/ - Images including /usr/bin/qemu-$arch-status
#   register/ - An image including /register script.
out_dir="containers"

# Generate register files.
cp -p "${out_dir}/latest/register.sh" "${out_dir}/register/"
cp -p "${out_dir}/latest/Dockerfile" "${out_dir}/register/"
# Comment out the line to copy qemu-*-static not to provide those.
sed -i '/^COPY qemu/ s/^/#/' "${out_dir}/register/Dockerfile"

for to_arch in $to_archs; do
    if [ "$from_arch" != "$to_arch" ]; then
        work_dir="${out_dir}/${from_arch}_qemu-${to_arch}"
        mkdir -p "${work_dir}"
        curl -sSL -o "${work_dir}/${from_arch}_qemu-${to_arch}-static.tar.gz" \
            "https://github.com/${REPO}/releases/download/v${VERSION}/${from_arch}_qemu-${to_arch}-static.tar.gz"
        tar xzvf "${work_dir}/${from_arch}_qemu-${to_arch}-static.tar.gz" -C "${work_dir}"
        rm -f "${work_dir}/${from_arch}_qemu-${to_arch}-static.tar.gz"

        cp -p "${work_dir}/qemu-${to_arch}-static" "${out_dir}/latest/"

        cat > ${work_dir}/Dockerfile -<<EOF
FROM scratch
COPY qemu-${to_arch}-static /usr/bin/
EOF
        docker build -t ${DOCKER_REPO}:$from_arch-$to_arch-${TAG_VER} ${work_dir}
        for target in  "${DOCKER_REPO}:$from_arch-$to_arch" \
            "${DOCKER_REPO}:$to_arch-${TAG_VER}" \
            "${DOCKER_REPO}:$to_arch" ; do
            docker tag ${DOCKER_REPO}:$from_arch-$to_arch-${TAG_VER} "${target}"
        done
        rm -rf "${work_dir}"
    fi
done

docker build -t ${DOCKER_REPO}:${TAG_VER} "${out_dir}/latest"
docker tag ${DOCKER_REPO}:${TAG_VER} ${DOCKER_REPO}:latest
docker build -t ${DOCKER_REPO}:register "${out_dir}/register"
