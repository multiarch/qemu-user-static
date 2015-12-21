#!/bin/sh

from_archs="x86_64"
to_archs="$(cat all-archs)"

for from_arch in $from_archs; do
    for to_arch in $to_archs; do
	mkdir -p archs/$from_arch-$to_arch
	cat > archs/$from_arch-$to_arch/Dockerfile <<EOF
FROM scratch
ADD https://github.com/multiarch/qemu-user-static/releases/download/v2.5.0/${from_arch}_qemu-${to_arch}-static.tar.xz /usr/bin
EOF
	docker build -t multiarch/qemu-user-static:$from_arch-$to_arch archs/$from_arch-$to_arch
	if [ "$from_arch" = "x86_64" ]; then
	    docker tag -f multiarch/qemu-user-static:$from_arch-$to_arch multiarch/qemu-user-static:$to_arch 
	fi
    done
done

docker build -t multiarch/qemu-user-static:register register
