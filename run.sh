#!/bin/bash
set -xe

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

while getopts "r:t:d:" opt; do
    case "$opt" in
        r)  REPO=$OPTARG
        ;;
        t)  TAG_VER=$OPTARG
        ;;
        d)  DOCKER_REPO=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

# Build container images creating the directory.
# containers/
#   latest/ - An image including /usr/bin/qemu-$arch-status and /register script.
#   ${from_arch}_qemu-${to_arch}/ - Images including /usr/bin/qemu-$arch-status
#   register/ - An image including /register script.

from_arch="x86_64"
root_dir=$(pwd)
out_dir="containers"
releases_dir="releases/usr/bin/"

cd ${releases_dir}
for file in *; do
    tar -czf $file.tar.gz $file;
    mv $file.tar.gz x86_64_$file.tar.gz
done
cd ${root_dir}

# Generate register files.
cp -p "${out_dir}/latest/register.sh" "${out_dir}/register/"
cp -p "${out_dir}/latest/Dockerfile" "${out_dir}/register/"
# Comment out the line to copy qemu-*-static not to provide those.
sed -i '/^COPY qemu/ s/^/#/' "${out_dir}/register/Dockerfile"

for file in ${releases_dir}*
do
    if [[ $file =~ qemu-(.+)-static ]]; then
        to_arch=${BASH_REMATCH[1]}
        if [ "$from_arch" != "$to_arch" ]; then
            work_dir="${out_dir}/${from_arch}_qemu-${to_arch}"
            mkdir -p "${work_dir}"
            cp -p "${releases_dir}qemu-${to_arch}-static" ${work_dir}
            cp -p "${work_dir}/qemu-${to_arch}-static" "${out_dir}/latest/"
            cat > ${work_dir}/Dockerfile -<<EOF
FROM scratch
COPY qemu-${to_arch}-static /usr/bin/
EOF
            docker build -t ${DOCKER_REPO}:$from_arch-$to_arch-${TAG_VER} ${work_dir}
            for target in  "${DOCKER_REPO}:$from_arch-$to_arch" \
                "${DOCKER_REPO}:$to_arch-${TAG_VER}" \
                "${DOCKER_REPO}:$to_arch" ; do
                docker tag ${DOCKER_REPO}:$from_arch-$to_arch-${TAG_VER} ${target}
            done
            rm -rf "${work_dir}"
        fi
    fi
done

docker build -t ${DOCKER_REPO}:${TAG_VER} ${out_dir}/latest
docker tag ${DOCKER_REPO}:${TAG_VER} ${DOCKER_REPO}:latest
docker build -t ${DOCKER_REPO}:register ${out_dir}/register